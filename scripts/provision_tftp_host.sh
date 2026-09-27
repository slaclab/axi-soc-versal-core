#!/bin/bash
##############################################################################
## This file is part of 'axi-soc-versal-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-soc-versal-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
##
## Idempotent host-side TFTP netboot provisioning: ensures the standalone
## dnsmasq TFTP server is configured and running, then stages the newest
## image.ub build for the selected board into /tftpboot along with a
## pxelinux.cfg/default PXE config that names it. Safe to re-run --
## a no-op re-invocation does not re-prompt for sudo and does not re-copy.
##
## With -B the script also stages the diskless set (pl.pdi, pl.dtbo and the
## standalone base DTB system-top.dtb, plus per-MAC copies of the set and
## image.ub via -M) for the tftp-only build, whose U-Boot env fetches and
## fpga-loads pl.pdi, applies pl.dtbo onto system-top.dtb and boots image.ub
## with that DTB. -A also stages the AIE PDIs and partition.conf sidecars and
## writes aie/manifest, which U-Boot reads to decide which AIE images to
## stack. Fallback-mode servers omit -B and only image.ub and PXE are staged.
##
## The TFTP root is flat: one image.ub and one pxelinux.cfg/default, so
## this assumes only one board on the server's subnet runs a netboot-mode
## BOOT.BIN against this root; a per-board override would be
## pxelinux.cfg/01-<mac>, which 'pxe get' tries first. For tftp-only the
## per-board override is -M, whose names U-Boot tries before the generic
## ones.
##############################################################################

set -euo pipefail

axi_soc_versal_core=$(realpath "$(dirname "$(readlink -f "$0")")/..")
hardwareDir="$axi_soc_versal_core/hardware"

TFTP_ROOT=/tftpboot
DNSMASQ_CONF=/etc/dnsmasq.d/tftp-lab.conf
PIDFILE=/run/dnsmasq-tftp-lab.pid

board=
srcOverride=
stageDiskless=0
aieDir=
macs=()

function show_help {
   echo "USAGE: $0 -b BOARD [-f PATH] [-B] [-M MAC] [-A DIR] [-H]"
   echo " -b BOARD     - Board name, must match a directory name in axi-soc-versal-core/hardware (required)"
   echo " -f PATH      - Explicit image.ub source path (bypasses build-dir auto-detect)"
   echo " -B           - Also stage the diskless set for tftp-only netboot: pl.pdi, pl.dtbo and"
   echo "                system-top.dtb from next to image.ub; without -A this also removes"
   echo "                the staged AIE pairs and aie/manifest (and each -M MAC's copies)"
   echo " -M MAC       - Also stage per-MAC copies of the diskless set and image.ub; repeatable;"
   echo "                implies -B; MAC colons or dashes, stored dash-form"
   echo " -A DIR       - Also stage the <name>.pdi and <name>.partition.conf pairs from DIR into"
   echo "                aie/ and write aie/manifest; implies -B; per-MAC too with -M"
   echo " -H           - Show this help text"
   exit 1
}

function die {
    echo "$@"
    exit 1
}

while getopts b:f:BM:A:H flag
do
    case "${flag}" in
        b) board=${OPTARG};;
        f) srcOverride=${OPTARG};;
        B) stageDiskless=1;;
        # Store the MAC lowercased with ':' -> '-'. U-Boot's loadpl_net and
        # loadaie_one use 'setexpr gsub' to request <name>.<mac-dashes>, so
        # the staged filename must match that dash form. Accepts -M with
        # colons or dashes.
        M) stageDiskless=1; m="${OPTARG,,}"; macs+=("${m//:/-}");;
        A) stageDiskless=1; aieDir=${OPTARG};;
        H) show_help;;
        *) show_help;;
    esac
done

[ -n "$board" ] || { echo "Missing required -b BOARD"; show_help; }

##############################################################################
# Validate -M and -A before anything reaches Step 0, so a bad value never
# triggers a root step or a file write.
##############################################################################

for m in ${macs[@]+"${macs[@]}"}; do
   [[ "$m" =~ ^[0-9a-f]{2}(-[0-9a-f]{2}){5}$ ]] || die "Invalid -M MAC '$m' (expected six hex octets, colon or dash separated)"
done

if [ -n "$aieDir" ]; then
   [ -d "$aieDir" ] || die "Invalid -A DIR '$aieDir' (not a directory)"
fi

##############################################################################
# Check for missing host tools before we start
##############################################################################

missing=0
for tool in dnsmasq find; do
   command -v "$tool" >/dev/null 2>&1 || { echo "Missing tool: $tool"; missing=1; }
done
if [ "$missing" -ne 0 ]; then
   die "Install the missing tool(s) above before running this script."
fi

##############################################################################
# Validate -b against the hardware/<Board> allow-list before using it in any
# find/cp command (never interpolate an unvalidated board name)
##############################################################################

[ -d "$hardwareDir/$board" ] || die "Unknown board '$board' (no directory $hardwareDir/$board)"

##############################################################################
# Step 0: ensure the TFTP root exists before anything references it. dnsmasq
# serves it (tftp-root), and the staging steps below cp/mkdir into it without
# sudo -- so create it root-side once, owned by the invoking user, 0755 so the
# privilege-dropped dnsmasq (user 'nobody') can still read it. Check-then-act:
# a re-run with the directory already usable never prompts for sudo.
##############################################################################

if [ ! -d "$TFTP_ROOT" ]; then
   echo "Creating $TFTP_ROOT"
   sudo install -d -m 0755 -o "$(id -un)" -g "$(id -gn)" "$TFTP_ROOT"
fi
[ -w "$TFTP_ROOT" ] || die "$TFTP_ROOT exists but is not writable by $(id -un); fix ownership (e.g. sudo chown $(id -un) $TFTP_ROOT)"

##############################################################################
# Board -> Yocto project-name glob mapping.
# This script serves only the VEK280 today; add a case here if/when this
# script needs to support additional boards' Yocto project-dir naming.
##############################################################################

function board_to_project_glob {
    case "$1" in
        XilinxVek280) echo "SimpleVek280Example*" ;;
        *) die "No Yocto project-name mapping for board '$1' (add one in board_to_project_glob())" ;;
    esac
}

##############################################################################
# stage_file FROM TO -- the check-then-act, verify-after-copy idiom Step 3
# above already uses, factored out for Step 5's many diskless-set copies.
##############################################################################

function stage_file {
    local from="$1" to="$2"
    if cmp -s "$from" "$to" 2>/dev/null; then
       echo "$to already up to date"
    else
       echo "Staging $from -> $to ($(stat -c%s "$from") bytes)"
       cp "$from" "$to"
       cmp -s "$from" "$to" || die "Post-copy verification failed: $to does not match $from"
    fi
}

##############################################################################
# print_aie_manifest NAMES... -- the single aie/manifest line U-Boot's
# 'env import -t' parses into aie_names for the loadaie_list loop.
##############################################################################

function print_aie_manifest {
    echo "aie_names=$*"
}

##############################################################################
# Step 1: ensure the dnsmasq TFTP-only config exists (check-then-act; only
# sudo tee if absent/different from the proven content). dnsmasq reads its
# conf file only at start-up, so a rewrite here forces Step 2 below to
# restart an already-running daemon rather than leave it serving the stale
# config.
##############################################################################

# The interface=eth2 line below assumes rdsrv403, whose eth2 carries the lab
# 10.0.0.0/24 subnet. On a host whose serving NIC differs, this line must be
# changed by hand, or the daemon binds the wrong interface and serves nothing
# with no error.
function print_dnsmasq_conf {
    cat <<'EOF'
interface=eth2
bind-interfaces
except-interface=lo
port=0
enable-tftp
tftp-root=/tftpboot
EOF
}

confChanged=0
if cmp -s <(print_dnsmasq_conf) "$DNSMASQ_CONF" 2>/dev/null; then
   echo "$DNSMASQ_CONF already up to date"
else
   echo "Installing $DNSMASQ_CONF"
   print_dnsmasq_conf | sudo tee "$DNSMASQ_CONF" >/dev/null
   confChanged=1
fi

##############################################################################
# Step 2: (re)launch the standalone dnsmasq instance if the pidfile does not
# name a live process, or if Step 1 just rewrote the conf out from under one
# (there is no dnsmasq.service on this host, and a live daemon never re-reads
# a rewritten conf on its own -- it must be restarted). A pidfile naming
# anything but a running dnsmasq may be a recycled pid after pid reuse, so it
# is never signalled: only the stale pidfile is removed.
#
# dnsmasq drops privileges to user 'nobody' after start-up, so a plain
# 'kill -0' from this (non-root) invoking user returns EPERM -- not ESRCH --
# once that happens, and cannot tell a live daemon from a dead one.
# is_running() therefore relies only on the /proc/$pid/comm name check, which
# any user can read and which covers both the still-owned and the
# privilege-dropped cases.
##############################################################################

function is_running {
    local pid
    pid=$(cat "$PIDFILE" 2>/dev/null) || return 1
    [ -n "$pid" ] || return 1
    [ -r "/proc/$pid/comm" ] && grep -qa dnsmasq "/proc/$pid/comm"
}

if is_running && [ "$confChanged" -eq 0 ]; then
   echo "dnsmasq already running (pid $(cat "$PIDFILE"))"
else
   if is_running; then
      pid=$(cat "$PIDFILE")
      echo "Restarting dnsmasq (pid $pid) to load the rewritten $DNSMASQ_CONF"
      sudo kill "$pid"
      waited=0
      while [ -d "/proc/$pid" ] && [ "$waited" -lt 10 ]; do
         sleep 1
         waited=$((waited + 1))
      done
      [ -d "/proc/$pid" ] && die "dnsmasq (pid $pid) did not exit within 10s"
   elif [ -f "$PIDFILE" ]; then
      echo "Removing stale $PIDFILE (pid $(cat "$PIDFILE") is not a running dnsmasq; not signalling it)"
      sudo rm -f "$PIDFILE"
   fi
   echo "Launching standalone dnsmasq"
   sudo dnsmasq --conf-file="$DNSMASQ_CONF" --pid-file="$PIDFILE"
fi

##############################################################################
# Step 3: resolve the image.ub source (explicit -f override, or auto-detect
# the newest build for the selected board) and hard-copy it flat into
# /tftpboot/image.ub only if it differs from what is already staged
##############################################################################

if [ -n "$srcOverride" ]; then
   src="$srcOverride"
   [ -f "$src" ] || die "Source file '$src' does not exist"
else
   projectGlob=$(board_to_project_glob "$board")
   buildRoot="/u1/${USER}/build/YoctoProjects"
   src=$(find "$buildRoot" -path "*${projectGlob}*/linux/image.ub" \
           -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
   [ -n "$src" ] || die "No image.ub found for board '$board' under $buildRoot"
fi

dest="$TFTP_ROOT/image.ub" # /tftpboot/image.ub -- the FIT the board's tftpboot fetches
if cmp -s "$src" "$dest" 2>/dev/null; then
   echo "$dest already up to date"
else
   echo "Staging $src -> $dest"
   cp "$src" "$dest"
   cmp -s "$src" "$dest" || die "Post-copy verification failed: $dest does not match $src"
   echo "Staged $(stat -c%s "$dest") bytes"
fi

##############################################################################
# Step 4: stage the PXE config the board's 'pxe get' fetches. U-Boot looks up
# pxelinux.cfg/01-<MAC> (per-board override) or pxelinux.cfg/default, parses the
# KERNEL line, and boots that FIT -- so boot behavior can change server-side
# without reflashing U-Boot. KERNEL points at the same flat image.ub staged
# above. Same check-then-act idempotency as the steps before it.
##############################################################################

PXE_DIR="$TFTP_ROOT/pxelinux.cfg"
PXE_DEFAULT="$PXE_DIR/default" # /tftpboot/pxelinux.cfg/default

function print_pxe_default {
    cat <<'EOF'
LABEL Linux
KERNEL image.ub
EOF
}

mkdir -p "$PXE_DIR"
if cmp -s <(print_pxe_default) "$PXE_DEFAULT" 2>/dev/null; then
   echo "$PXE_DEFAULT already up to date"
else
   echo "Staging $PXE_DEFAULT"
   print_pxe_default > "$PXE_DEFAULT"
fi

##############################################################################
# Step 5 (optional, -B/-M/-A): stage the diskless set for the tftp-only
# build. loadpl_net and loadaie_one probe <name>.<mac-dashes> before the
# generic <name>, so a per-MAC copy always outranks a generic one -- staging
# both keeps a per-board override working without disturbing other boards.
#
# The AIE PDI(s) named by -A must come from the same build as pl.pdi: an AIE
# image built against a different PL can still fpga-load cleanly and then
# fail at runtime or leave the design in an inconsistent state, so this
# script only stages what -A names, it does not try to prove the pairing.
#
# Superseded names (an AIE pair or manifest no longer in the new -A set) are
# removed only after the new set is staged and verified, so a failure
# partway through never leaves the served set with a name that has nothing
# valid behind it.
#
# Without -A, a -B or -M run removes the previously staged generic AIE pairs,
# aie/manifest, and each -M MAC's own AIE pairs and manifest, so an AIE image
# built against an older PL is never left stacked onto the pl.pdi just
# staged -- -A must be passed on every run that should keep serving AIE.
##############################################################################

if [ "$stageDiskless" -eq 1 ]; then
   srcDir=$(dirname "$src") # the directory holding the resolved image.ub

   for f in pl.pdi pl.dtbo system-top.dtb; do
      [ -f "$srcDir/$f" ] || die "No $f found next to image.ub at '$srcDir/$f'"
   done

   aieNames=()
   if [ -n "$aieDir" ]; then
      while IFS= read -r p; do
         aieNames+=("$(basename "$p" .pdi)")
      done < <(find "$aieDir" -maxdepth 1 -name '*.pdi' -printf '%f\n' | LC_ALL=C sort)
      [ ${#aieNames[@]} -gt 0 ] || die "No *.pdi found in -A DIR '$aieDir'"

      for n in "${aieNames[@]}"; do
         [[ "$n" =~ ^[A-Za-z0-9_.-]{1,31}$ ]] || die "Invalid AIE name '$n' in -A DIR '$aieDir' (expected 1 to 31 characters of A-Za-z0-9_.-)"
         conf="$aieDir/$n.partition.conf"
         [ -f "$conf" ] || die "No $n.partition.conf found in -A DIR '$aieDir'"
         body=$(command grep -vE '^[[:space:]]*(#.*)?$' "$conf" || true)
         nLines=$(printf '%s\n' "$body" | command grep -c . || true)
         [ "$nLines" -eq 2 ] || die "Invalid $conf: expected exactly one PARTITION_ID= and one UID= line"
         printf '%s\n' "$body" | command grep -qE '^PARTITION_ID=(0x[0-9A-Fa-f]+|[0-9]+)$' \
            || die "Invalid $conf: PARTITION_ID= line missing or not hex/decimal"
         printf '%s\n' "$body" | command grep -qE '^UID=(0x[0-9A-Fa-f]+|[0-9]+)$' \
            || die "Invalid $conf: UID= line missing or not hex/decimal"
      done
   fi

   stage_file "$srcDir/pl.pdi"         "$TFTP_ROOT/pl.pdi"
   stage_file "$srcDir/pl.dtbo"        "$TFTP_ROOT/pl.dtbo"
   stage_file "$srcDir/system-top.dtb" "$TFTP_ROOT/system-top.dtb"

   if [ -n "$aieDir" ]; then
      mkdir -p "$TFTP_ROOT/aie"
      for n in "${aieNames[@]}"; do
         stage_file "$aieDir/$n.pdi"            "$TFTP_ROOT/aie/$n.pdi"
         stage_file "$aieDir/$n.partition.conf" "$TFTP_ROOT/aie/$n.partition.conf"
      done
      manifestDest="$TFTP_ROOT/aie/manifest"
      if cmp -s <(print_aie_manifest "${aieNames[@]}") "$manifestDest" 2>/dev/null; then
         echo "$manifestDest already up to date"
      else
         echo "Staging $manifestDest"
         print_aie_manifest "${aieNames[@]}" > "$manifestDest"
      fi
   fi

   for mac in ${macs[@]+"${macs[@]}"}; do
      stage_file "$TFTP_ROOT/pl.pdi"         "$TFTP_ROOT/pl.pdi.$mac"
      stage_file "$TFTP_ROOT/pl.dtbo"        "$TFTP_ROOT/pl.dtbo.$mac"
      stage_file "$TFTP_ROOT/system-top.dtb" "$TFTP_ROOT/system-top.dtb.$mac"
      stage_file "$TFTP_ROOT/image.ub"       "$TFTP_ROOT/image.ub.$mac"
      if [ -n "$aieDir" ]; then
         for n in "${aieNames[@]}"; do
            stage_file "$TFTP_ROOT/aie/$n.pdi"            "$TFTP_ROOT/aie/$n.pdi.$mac"
            stage_file "$TFTP_ROOT/aie/$n.partition.conf" "$TFTP_ROOT/aie/$n.partition.conf.$mac"
         done
         macManifestDest="$TFTP_ROOT/aie/manifest.$mac"
         if cmp -s <(print_aie_manifest "${aieNames[@]}") "$macManifestDest" 2>/dev/null; then
            echo "$macManifestDest already up to date"
         else
            echo "Staging $macManifestDest"
            print_aie_manifest "${aieNames[@]}" > "$macManifestDest"
         fi
      fi
   done

   # Only now that the new set is staged and verified, remove any AIE pair
   # or manifest this invocation's scope supersedes -- doing it earlier
   # would leave a window where U-Boot could probe a name with nothing
   # behind it. Scoped to exactly the generic names and each -M MAC's own
   # names; never a glob across MACs, since other boards' per-MAC files may
   # share this root.
   function in_aie_names {
       local want="$1" n
       for n in ${aieNames[@]+"${aieNames[@]}"}; do
          [ "$n" = "$want" ] && return 0
       done
       return 1
   }

   for stale in "$TFTP_ROOT"/aie/*.pdi; do
      [ -e "$stale" ] || continue
      name=$(basename "$stale" .pdi)
      in_aie_names "$name" && continue
      echo "Removing superseded $stale"
      rm -f "$stale" "$TFTP_ROOT/aie/$name.partition.conf"
   done
   if [ -z "$aieDir" ] && [ -e "$TFTP_ROOT/aie/manifest" ]; then
      echo "Removing superseded $TFTP_ROOT/aie/manifest"
      rm -f "$TFTP_ROOT/aie/manifest"
   fi

   for mac in ${macs[@]+"${macs[@]}"}; do
      for stale in "$TFTP_ROOT"/aie/*.pdi."$mac"; do
         [ -e "$stale" ] || continue
         base=$(basename "$stale" ".pdi.$mac")
         in_aie_names "$base" && continue
         echo "Removing superseded $stale"
         rm -f "$stale" "$TFTP_ROOT/aie/$base.partition.conf.$mac"
      done
      if [ -z "$aieDir" ] && [ -e "$TFTP_ROOT/aie/manifest.$mac" ]; then
         echo "Removing superseded $TFTP_ROOT/aie/manifest.$mac"
         rm -f "$TFTP_ROOT/aie/manifest.$mac"
      fi
   done

   # Without -M this run cannot know the board's MAC, so any leftover
   # per-MAC file belongs to a board this invocation is not staging for. A
   # per-MAC name outranks the generic one in loadpl_net's probe order, so a
   # stale one would silently win over what was just staged -- flag it
   # rather than guess which board it belongs to or delete it.
   if [ ${#macs[@]} -eq 0 ]; then
      for leftover in "$TFTP_ROOT"/pl.pdi.* "$TFTP_ROOT"/pl.dtbo.* "$TFTP_ROOT"/system-top.dtb.* "$TFTP_ROOT"/image.ub.* "$TFTP_ROOT"/aie/manifest.*; do
         [ -e "$leftover" ] || continue
         echo "WARNING: $leftover outranks its generic name in loadpl_net's probe order." >&2
         echo "         Re-run with -M <board-MAC> to refresh or remove it." >&2
      done
   fi
fi
