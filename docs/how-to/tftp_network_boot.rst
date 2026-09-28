TFTP Network Boot
==================

Boot the Linux kernel over Ethernet using TFTP instead of the SD card,
with automatic fallback to the on-SD image if the network path fails.

.. note::

   Netboot is **opt-in**. The default build mode is ``sd-only``, which never
   attempts DHCP or TFTP at all, so a board on a network with no TFTP server
   pays none of the timeouts described below. Everything on this page applies
   to boards built with ``-m fallback`` or ``-m tftp-only``; see
   :ref:`Step 2 <tftp-boot-modes>` for the full mode table.

How It Works
------------

On power-up, the Versal boot ROM loads ``BOOT.BIN`` (the PLM, the static PDI
with the PS and NoC configuration, TF-A and U-Boot) from the SD card,
exactly as in a normal SD boot, in every mode. From there, U-Boot fetches
**only the kernel FIT image** (``image.ub``) over TFTP instead of reading it
from the SD card, then boots it with ``bootm``. The SD card stays in the
board and still holds a known-good ``image.ub``, so if the TFTP fetch fails,
U-Boot falls back to booting that on-SD image automatically. Nothing about
the first boot stage changes: only where the kernel FIT comes from.

The kernel FIT is fetched **PXE-first**. U-Boot first tries to download
a PXE ("pxelinux") config from the TFTP server --
``pxelinux.cfg/01-<MAC>`` (the board's MAC, dash-separated and
lowercased, with the ``01-`` ARP-hardware-type prefix) if a
board-specific file exists, otherwise ``pxelinux.cfg/default`` -- parses
its ``KERNEL`` line, and boots the FIT that line names. Only if no PXE
config is served does U-Boot fall back to fetching ``image.ub``
directly by name. The PXE config lets you change a board's boot
behavior server-side -- pointing it at a different FIT, for example --
**without reflashing U-Boot or editing the board's U-Boot
environment**. Either path still relies on ``serverip`` (the TFTP
server address) being set, explicitly or via DHCP.

On boards built **tftp-only** for diskless (no-SD) operation, U-Boot also
loads the PL and its device tree over TFTP before booting the kernel, so the
PL can be updated server-side without reflashing. ``loadpl_net`` runs this
diskless flow in order:

1. Fetch ``pl.pdi`` (the segmented build's dynamic PDI) and
   ``fpga load 0 0x10000000 ${filesize}`` it.
2. Fetch the standalone base DTB ``system-top.dtb`` (the same DTB
   ``image.ub``'s FIT embeds, with ``__symbols__``) to ``fdt_addr_r``, and
   ``pl.dtbo`` to ``fdtoverlay_addr_r``, then ``fdt apply
   ${fdtoverlay_addr_r}`` to live-patch the PL device-tree nodes onto the
   base DTB.
3. ``fdt set /chosen slac,boot-mode tftp-only`` -- the marker
   ``startup-app-init`` reads to know U-Boot already loaded the PL (see
   below).
4. On a build with the ``aie`` machine feature, fetch ``aie/manifest`` and,
   for each name it lists, fetch and ``fpga load`` ``aie/<name>.pdi``, then
   fetch ``aie/<name>.partition.conf`` and import ``PARTITION_ID``/``UID``
   into ``/chosen/slac,aie/<name>`` for ``startup-app-init`` to pick up at
   boot.
5. Fetch ``image.ub`` and ``bootm ${kernel_addr_r} ${kernel_addr_r}
   ${fdt_addr_r}`` with the patched DTB as the explicit FDT argument -- not
   ``pxe boot``, which would boot the FIT's own embedded DTB and drop the
   overlay.

Each file is probed most- to least-specific, the per-MAC name before the
generic one:

.. code-block:: text

   pl.pdi.00-0a-35-00-00-01                     pl.pdi
   system-top.dtb.00-0a-35-00-00-01             system-top.dtb
   pl.dtbo.00-0a-35-00-00-01                    pl.dtbo
   aie/manifest.00-0a-35-00-00-01               aie/manifest
   aie/<name>.pdi.00-0a-35-00-00-01             aie/<name>.pdi
   aie/<name>.partition.conf.00-0a-35-00-00-01  aie/<name>.partition.conf
   image.ub.00-0a-35-00-00-01                   image.ub

The MAC is dash-separated and lowercased. (U-Boot's ``tftpboot`` treats
a ``:`` in a filename as a ``hostIP:file`` separator, so the env uses
``setexpr gsub`` to rewrite ``${ethaddr}``'s colons to dashes before the
fetch.) A miss costs one immediate TFTP "not found" reply rather than a
timeout, so the extra probes are effectively free -- **provided the server
is reachable**. If nothing answers at all, each probe instead waits its
full request timeout; see **Troubleshooting**.

This whole diskless sequence is one ``&&`` chain: any fetch, ``fpga load``
or ``fdt apply`` failure aborts netboot before the kernel boots, so a net
kernel never runs over an unprogrammed or stale PL. A ``fallback`` or
``sd-only`` build does **not** load the PL in U-Boot at all -- its PL is
programmed later, after Linux boots, by ``startup-app-init`` running
``fpgautil`` against the SD card's ``/boot/pl.pdi`` and ``/boot/pl.dtbo``
(unchanged from a normal SD boot). ``BOOT.BIN`` itself carries no PL image
in any mode -- only the PLM and the static PDI (the PS and NoC
configuration); the PL always comes from ``pl.pdi``, whichever path loads
it.

Why the PL must be programmed before the drivers load: the
``axi_memory_map`` and ``axi_stream_dma`` kernel modules bind to AXI
endpoints that only exist once the PL is configured, so loading them
against an unprogrammed PL produces cryptic DMA/AXI errors (or an AXI
bus hang). To prevent that, ``startup-app-init`` gates the ``insmod``
step on ``$pl_programmed`` -- set when its own ``fpgautil`` load of
``/boot/pl.pdi`` plus ``/boot/pl.dtbo`` succeeds, or when the
``tftp-only`` ``/chosen slac,boot-mode`` marker is present. It does
**not** read ``/sys/class/fpga_manager/fpga0/state`` to decide this:
Versal's FPGA manager has no state-readback op after a U-Boot-driven load
and reports ``unknown`` regardless of whether the PL is actually
programmed (see **Verification** below). If the PL is not programmed, it
logs an ``ERROR: PL not programmed`` line, **skips the driver load, and
lets Linux continue booting** rather than halting -- so the board still
comes up with networking and a shell (a minimal recovery environment)
instead of stopping. The only path that deliberately halts before Linux
is a failed diskless fetch or load in ``tftp-only`` mode (the netboot
``&&`` chain aborts the boot); a ``fallback`` or ``sd-only`` board always
reaches Linux.

.. note::

   Because ``BOOT.BIN`` carries no PL image in any mode -- only the PLM and
   the static PDI -- a ``fallback`` or ``sd-only`` board that is missing
   ``/boot/pl.pdi`` or ``/boot/pl.dtbo`` boots with the PL unprogrammed and
   no DMA drivers (``startup-app-init`` prints the both-required
   ``WARNING`` described in **Verification** below); there is no
   ``operating`` fallback state to mask that. Once the PL is loaded,
   confirm the running firmware with ``axiversiondump`` (printed near the
   end of ``startup-app-init``).

The active U-Boot network stack is lwIP (U-Boot 2026.01,
``CONFIG_NET_LWIP``); a bound DHCP lease prints a line starting with
``DHCP client bound to address``. The netboot hooks are added to
U-Boot's ``CFG_EXTRA_ENV_SETTINGS`` macro, which is shared across boards
built on this platform.

On a diskless boot, ``startup-app-init`` sees the ``/chosen
slac,boot-mode`` marker and skips both the SD ``fpgautil`` load and the
``/boot/aie`` loop, so PL or AIE files left on ``/boot`` from a prior
SD-mode boot never override what U-Boot just loaded. For each AIE image
U-Boot stacked, it writes ``/run/aie/<name>.partition.conf`` from
``/chosen/slac,aie/<name>`` before starting
``aie-partition-init@<name>.service``, exactly as the SD path writes the
same file from ``/boot/aie/<name>.partition.conf``.

Prerequisites
-------------

- The board has been imaged and booted at least once (see
  :doc:`sd_card_imaging` in this how-to section), or has had the PL updated
  via the :repo:`README.md` section "How to remote update the PL bitstream
  (Versal)".
- A development host on the same network as the board, with
  ``dnsmasq`` and ``curl`` installed. The provisioning script in Step 1
  uses ``sudo`` to write the server configuration and launch the
  daemon.
- Serial console access for observing boot messages:

  .. code-block:: bash

     cu --line /dev/ttyUSB1 --speed 115200 --parity=none

.. note::

   The host IP, network interface, board IP, and serial device shown
   below (e.g. ``10.0.0.1``, ``eth2``, ``/dev/ttyUSB1``) are values to
   replace with your own. The netboot path does not depend on any
   particular subnet; the board takes its IP from whatever DHCP server is
   present on your network, and only ``serverip`` needs to be set
   explicitly to point at your TFTP host. The provisioning script's
   ``dnsmasq`` configuration binds ``interface=eth2``; edit that line by
   hand on a host whose serving NIC differs, or the daemon binds the
   wrong interface and serves nothing with no error.

Steps
-----

1. Set up the host TFTP server using the provisioning script,
   :repo:`scripts/provision_tftp_host.sh`, provided in the
   platform repository. The ``-b BOARD`` argument is required and must
   match a directory name under ``axi-soc-versal-core/hardware``
   (``XilinxVek280`` shown here as an example):

   .. code-block:: bash

      scripts/provision_tftp_host.sh -b XilinxVek280

   The script is idempotent: it writes the TFTP server configuration
   (``/etc/dnsmasq.d/tftp-lab.conf``), stages the latest built
   ``image.ub`` for that board into the TFTP root (``/tftpboot``), stages
   a PXE config at ``/tftpboot/pxelinux.cfg/default``, and launches a
   standalone ``dnsmasq`` instance serving ``/tftpboot``. Re-running it
   against an already-provisioned host is a no-op -- it does not re-prompt
   for ``sudo`` and does not start a second daemon. Do not hand-derive
   the TFTP server configuration yourself.

   The staged ``/tftpboot/pxelinux.cfg/default`` is minimal -- it simply
   names the FIT to boot:

   .. code-block:: text

      LABEL Linux
      KERNEL image.ub

   To give one board different boot behavior than the rest, add a
   MAC-specific override file beside it, named for that board's MAC
   address as ``pxelinux.cfg/01-aa-bb-cc-dd-ee-ff`` (the ``01-`` prefix
   plus the MAC dash-separated and lowercased). U-Boot prefers the
   MAC-specific file over ``default`` when both are present, so you can
   repoint a single board -- at a different FIT, say -- without touching
   the shared ``default`` config or reflashing that board's U-Boot.

   For a **tftp-only** (diskless) board, also stage the Versal PL set so
   U-Boot can fetch, ``fpga load`` and ``fdt apply`` it (see **How It
   Works**).

   Add ``-B`` to stage the diskless set, ``-M <mac>`` (repeatable) for
   per-board copies, and ``-A <dir>`` to stage AIE images:

   .. code-block:: bash

      scripts/provision_tftp_host.sh -b XilinxVek280 -B -M 00:0a:35:00:00:01 -A <path>/AieLoopback/ip

   ``-B`` stages ``pl.pdi``, ``pl.dtbo`` and ``system-top.dtb`` from next
   to ``image.ub``. ``-M <mac>`` (repeatable, colons or dashes, stored
   dash-form lowercase) adds per-MAC copies of that set and ``image.ub``;
   it implies ``-B``. ``-A <dir>`` stages each ``<name>.pdi`` and
   ``<name>.partition.conf`` pair from ``<dir>`` into ``aie/`` and writes
   ``aie/manifest``, which U-Boot's ``loadaie_net`` reads to decide which
   AIE images to stack; each name must be 1 to 31 characters from
   ``A-Za-z0-9_.-``, and each sidecar exactly one ``PARTITION_ID=`` line
   and one ``UID=`` line. ``-A`` implies ``-B`` and follows ``-M`` -- a
   per-MAC copy is staged for the AIE set too.

   ``-B`` without ``-A`` removes the staged AIE set: the generic AIE
   pairs, ``aie/manifest``, and each ``-M`` MAC's own copies. Pass ``-A``
   on every run that should keep serving AIE, or a rebuilt PL is served
   diskless with a stale AIE image stacked on top of it.

   ``fallback``-mode servers do not need any of this -- omit
   ``-B``/``-M``/``-A`` and only ``image.ub`` and the PXE config are
   staged. ``sd-only`` boards need no TFTP server at all, so this whole
   step is unnecessary for them.

   The server is **TFTP-only** (``dnsmasq`` runs with DNS and DHCP
   disabled), so it is safe to run alongside an existing site DHCP
   server on the same segment -- the board still gets its lease from
   that DHCP server, and this host only answers TFTP requests.

   If the script cannot auto-detect a built ``image.ub`` for the board
   (``No image.ub found for board ...``), point it at the file
   explicitly with ``-f``:

   .. code-block:: bash

      scripts/provision_tftp_host.sh -b XilinxVek280 -f /path/to/linux/image.ub

   Before involving the board, confirm the host is serving the diskless
   set by fetching each file back over TFTP from the host itself:

   .. code-block:: bash

      curl -sf -o /tmp/verify_image.ub tftp://10.0.0.1/image.ub
      cmp /tmp/verify_image.ub /tftpboot/image.ub

      curl -sf -o /tmp/verify_pl.pdi tftp://10.0.0.1/pl.pdi
      cmp /tmp/verify_pl.pdi /tftpboot/pl.pdi

      curl -sf -o /tmp/verify_system-top.dtb tftp://10.0.0.1/system-top.dtb
      cmp /tmp/verify_system-top.dtb /tftpboot/system-top.dtb

      curl -sf -o /tmp/verify_pl.dtbo tftp://10.0.0.1/pl.dtbo
      cmp /tmp/verify_pl.dtbo /tftpboot/pl.dtbo

      curl -sf -o /tmp/verify_aie_manifest tftp://10.0.0.1/aie/manifest
      cmp /tmp/verify_aie_manifest /tftpboot/aie/manifest

   A clean ``curl`` exit and a matching ``cmp`` prove the TFTP path is
   good end-to-end without needing the board. To stop the server, kill
   the PID it recorded:

   .. code-block:: bash

      sudo kill "$(cat /run/dnsmasq-tftp-lab.pid)"

.. _tftp-boot-modes:

2. Choose the board's boot mode at build time. The boot mode is
   baked into U-Boot -- and therefore into ``BOOT.BIN`` -- when the Yocto
   image is built, via the ``-m`` flag to ``BuildYoctoProject.sh`` (see
   the :repo:`README.md` "BuildYoctoProject.sh options" section for the
   full build invocation):

   .. list-table::
      :header-rows: 1
      :widths: 25 75

      * - ``-m`` value
        - Boot behavior
      * - ``sd-only`` (default)
        - Never attempts netboot: no DHCP, no TFTP, and none of the
          ~85-110 s of timeouts a ``fallback`` board pays on a network with
          no reachable TFTP server. ``run netboot`` is still defined and
          available by hand at the ``Versal>`` prompt for recovery.
      * - ``fallback``
        - Tries netboot first; on any failure boots the known-good
          ``image.ub`` from the SD card.
      * - ``tftp-only``
        - Tries netboot only; on failure prints ``TFTP-only build: not
          falling back to SD`` and halts at the ``Versal>`` prompt. The SD
          image is never consulted.

   ``sd-only`` is the default, so it is applied even when ``-m`` is
   omitted, and a default build therefore does **not** netboot. The three
   modes produce byte-distinct ``BOOT.BIN`` images. To read a board's mode
   straight out of the artifact -- no board required -- grep the ``bootcmd``
   that was baked into it:

   .. code-block:: bash

      strings -a BOOT.BIN | grep -a '^bootcmd='

   .. code-block:: text

      bootcmd=echo SD-only build: skipping netboot; run sdboot           <- sd-only
      bootcmd=run netboot; run sdboot                                    <- fallback
      bootcmd=run netboot; echo TFTP-only build: not falling back to SD  <- tftp-only

   That works on a freshly built image or on the SD card's copy at
   ``/boot/BOOT.BIN``, and unlike a checksum it does not go stale between
   rebuilds.

   .. note::

      ``strings -a BOOT.BIN | grep -aE '^(netboot|loadpl_net|loadpl_skip)='``
      is a **weaker** check: ``loadpl_skip`` is selected by both ``fallback``
      and ``sd-only``, so that grep separates ``tftp-only`` from the other
      two but cannot tell those two apart. Only the ``bootcmd=`` line
      identifies a mode uniquely.

   Runtime behavior also distinguishes the modes: a ``fallback`` board
   SD-boots after its TFTP attempts fail, a ``tftp-only`` board halts, and
   an ``sd-only`` board prints ``SD-only build: skipping netboot`` and shows
   no ``DHCP client bound`` or TFTP lines at all. The login-banner hostname
   is **not** a mode indicator: it is identical in all three modes (see
   **Verification** below).

   The mode also decides where the PL comes from. A ``tftp-only`` build
   needs ``pl.pdi``, ``pl.dtbo`` and ``system-top.dtb`` staged on the TFTP
   server (Step 1, ``-B``/``-M``), plus the AIE set when a manifest is
   served (``-A``), and **halts** rather than boot if any is missing. PL
   and AIE files may stay on ``/boot`` on a board that boots
   ``tftp-only``: the ``/chosen slac,boot-mode`` marker makes
   ``startup-app-init`` skip both the SD ``fpgautil`` load and the
   ``/boot/aie`` loop, so nothing left there overrides what U-Boot just
   loaded. A ``fallback`` or ``sd-only`` build ignores any staged diskless
   set entirely and programs the PL from the SD card's ``/boot/pl.pdi`` and
   ``/boot/pl.dtbo`` after Linux boots, exactly as a normal SD boot does.

   To get the resulting ``BOOT.BIN`` onto the board, see
   :doc:`sd_card_imaging` for a fresh SD card, or replace it in place on a
   board that is already imaged with the same Linux ``cp`` the
   :repo:`README.md` section "How to remote update the PL bitstream
   (Versal)" uses for the PL (see the warning immediately below).

   .. warning::

      To switch a board between any two of the three modes, it
      is sufficient to replace only ``BOOT.BIN`` on the SD card's FAT
      boot partition. On boards imaged by this platform's tooling
      (1 GiB FAT32 boot partition), do that with a plain Linux ``cp``
      to the mounted ``/boot`` partition. **Never use U-Boot's
      ``fatwrite`` command and never use a raw ``mmc write``** to do
      this: this platform keeps a saved U-Boot environment on that same
      FAT partition (see the ``saveenv`` warning in Step 3), and both a
      saved environment and a ``fatwrite`` write the boot partition from
      U-Boot -- a path this platform never relies on and has not
      characterized for safety. A raw ``mmc write`` risks bricking the
      boot partition entirely.

3. Run netboot manually from the ``Versal>`` prompt. To reach the
   prompt, press any key on the serial console during the autoboot
   countdown to interrupt it, then step through the fetch by hand.

   These commands mirror the built-in ``netboot`` environment command
   (installed via ``CFG_EXTRA_ENV_SETTINGS``, see **How It Works**),
   which waits up to about 12 seconds for the board's EEPROM MAC to
   become readable before running ``dhcp`` -- skipped entirely if a
   static ``ipaddr`` is already set -- then runs the mode's PL-load step
   (``loadpl_net`` on ``tftp-only``, the diskless flow described above;
   ``loadpl_skip`` on ``fallback``/``sd-only``, which does nothing) and
   tries ``pxe get`` / ``pxe boot`` and, only if no PXE config is served,
   falls back to ``tftpboot 0x10000000 image.ub`` then
   ``bootm 0x10000000``; ``run netboot`` performs the whole
   fetch-and-boot. Exhausting the EEPROM wait with no MAC found skips this
   ``dhcp`` attempt entirely, so the sequential ``bootcmd`` falls straight
   through to the mode action without a TFTP attempt. Doing it by hand
   lets you set ``serverip`` explicitly (``netboot`` itself does not) and
   watch each stage.

   On a ``fallback`` or ``tftp-only`` board, boot time reaches ``netboot``
   through U-Boot's ``bootcmd`` -- ``run netboot; <mode-action>`` -- which
   runs ``netboot`` and then the mode-specific action from Step 2 (SD boot
   for ``fallback``, halt for ``tftp-only``). The mode action runs whenever
   ``netboot`` **returns to U-Boot at all**: a successful boot hands control
   to the kernel and never comes back, so simply reaching the mode action is
   the failure signal. The fallback therefore does **not** depend on
   ``netboot`` reporting a nonzero exit code -- some boot methods (notably
   ``pxe boot``) return 0 even when no kernel booted.

   An ``sd-only`` board's ``bootcmd`` is not of that form at all: it omits
   ``run netboot`` entirely, which is the whole point of the mode. The
   ``netboot``, ``loadpl_net``, and ``loadpl_skip`` environment variables are
   still defined there, though, so this manual sequence is exactly how you
   exercise netboot on such a board without rebuilding it.

   .. code-block:: text

      dhcp
      setenv serverip 10.0.0.1
      pxe get
      pxe boot

   ``pxe get`` downloads the ``pxelinux.cfg`` file (MAC-specific first,
   then ``default``) from ``serverip``, and ``pxe boot`` loads and boots
   the FIT its ``KERNEL`` line names.

   **Mixed addressing -- board IP from DHCP, TFTP server set by hand.**
   When your DHCP server assigns the board's IP but does not advertise a
   usable TFTP ``next-server`` (or advertises the wrong one), set
   ``serverip`` yourself and let DHCP handle only the board address, then
   run the built-in ``netboot``:

   .. code-block:: text

      setenv serverip 10.0.0.1
      saveenv                    # optional: persist across reboots
      run netboot

   The shipped ``netboot`` **preserves a non-empty ``serverip`` across
   its own internal ``dhcp`` call**, and clears ``tftpserverip`` (which
   ``tftpboot`` and ``pxe`` would otherwise prefer over ``serverip``), so
   your TFTP-server choice stays authoritative. This is required because
   U-Boot's lwIP ``dhcp`` always overwrites ``serverip`` with the DHCP
   server's own address and may set ``tftpserverip`` from the DHCP
   next-server field. To hand TFTP addressing back to DHCP, clear it
   again with ``setenv serverip`` (and ``saveenv`` if you had persisted
   it).

   .. warning::

      ``saveenv`` costs more than it looks. This build keeps a saved
      U-Boot environment in ``uboot.env`` (and a redundant copy,
      ``uboot-redund.env``) on the SD card's FAT boot partition. A saved
      environment overrides the one compiled into ``BOOT.BIN``, so a
      later build's ``bootcmd``, ``netboot``, or ``loadpl_net`` is then
      silently ignored: the board keeps booting the old way after an
      apparently successful reflash. Prefer leaving addressing volatile.
      To undo a ``saveenv``, delete ``uboot.env`` and ``uboot-redund.env``
      from ``/boot`` in Linux and reboot -- U-Boot then falls back to the
      environment compiled into ``BOOT.BIN``.

   To fetch the FIT directly instead -- the fallback path ``netboot``
   takes when no PXE config is served -- skip the ``pxe`` commands and
   fetch ``image.ub`` by name:

   .. code-block:: text

      dhcp
      setenv serverip 10.0.0.1
      tftpboot 0x10000000 image.ub
      bootm 0x10000000

   ``dhcp`` acquires a lease from your network's DHCP server (a bound
   lease prints ``DHCP client bound to address``). Set ``serverip``
   explicitly to your TFTP host rather than relying on a DHCP
   ``next-server`` option. Use the load address ``0x10000000`` exactly
   as shown -- this is the address this platform's boot flow is built
   around, not a generic default.

   On a ``tftp-only`` build, ``netboot`` first runs its ``loadpl_net``
   step to load the PL and its device tree from the TFTP-served diskless
   set before fetching the kernel. To reproduce that by hand:

   .. code-block:: text

      dhcp
      setenv serverip 10.0.0.1
      setexpr macfn gsub : - ${ethaddr}
      tftpboot 0x10000000 pl.pdi
      fpga load 0 0x10000000 ${filesize}
      tftpboot ${fdt_addr_r} system-top.dtb
      tftpboot ${fdtoverlay_addr_r} pl.dtbo
      fdt addr ${fdt_addr_r}
      fdt resize 0x10000
      fdt apply ${fdtoverlay_addr_r}
      fdt set /chosen slac,boot-mode tftp-only
      tftpboot ${kernel_addr_r} image.ub
      bootm ${kernel_addr_r} ${kernel_addr_r} ${fdt_addr_r}

   ``run loadpl_net`` does all of this by itself (with the AIE stack added
   on a build with the ``aie`` machine feature) on **any** mode's
   ``BOOT.BIN``, since ``loadpl_net`` is defined in every mode --
   ``fallback`` and ``sd-only`` builds simply never call it from
   ``bootcmd``.

   If your network has no DHCP server, set a static IP instead (keep
   it volatile -- do not ``saveenv`` -- so a plain ``reset`` restores the
   DHCP path):

   .. code-block:: text

      setenv ipaddr 10.0.0.50
      setenv serverip 10.0.0.1
      setenv gatewayip 10.0.0.1
      setenv netmask 255.255.255.0
      run netboot

Verification
------------

A bound DHCP lease is the first sign networking is up:

.. code-block:: text

   DHCP client bound to address 10.0.0.10 (1015 ms)

A successful kernel FIT fetch reports its size (roughly 111 MiB for this
build):

.. code-block:: text

   Bytes transferred = 116469919

On a ``tftp-only`` build, the diskless fetches run first. A per-MAC miss
draws an immediate refusal and the generic name follows right behind it:

.. code-block:: text

   Filename 'pl.pdi.00-0a-35-00-00-01'.
   TFTP error: 256 (file /tftpboot/pl.pdi.00-0a-35-00-00-01 not found for 10.0.0.10)
   Filename 'pl.pdi'.
   Bytes transferred = 2274720

The PLM confirms the load right after ``fpga load`` returns:

.. code-block:: text

   [10080.657]Subsystem PDI Load: Done

The same per-MAC-then-generic fetch runs for ``system-top.dtb``,
``pl.dtbo``, ``aie/manifest`` (on an ``aie`` build), each AIE image and its
sidecar, and finally ``image.ub``. Once Linux is up, ``startup-app-init``
logs the marker it saw:

.. code-block:: text

   tftp-only boot (/chosen slac,boot-mode): U-Boot loaded pl.pdi and applied pl.dtbo, skipping the SD fpgautil load
   /sys/class/fpga_manager/fpga0/state: unknown

``unknown`` is **expected** here -- Versal's FPGA manager has no
state-readback op after a U-Boot-driven load, so this line is not a failure
indicator on ``tftp-only`` (contrast the SD path below). Confirm the mode
from the device tree itself:

.. code-block:: bash

   cat /proc/device-tree/chosen/slac,boot-mode

which prints ``tftp-only``. On an ``aie`` build, confirm the AIE partition
started:

.. code-block:: bash

   systemctl show aie-partition-init@AieLoopback -p ActiveState

which reports ``active``.

On an ``sd-only`` or ``fallback`` boot, ``startup-app-init`` instead
confirms its own load:

.. code-block:: text

   2nd-stage PL load: /boot/pl.pdi + /boot/pl.dtbo present
   /sys/class/fpga_manager/fpga0/state: operating

If the PL is not programmed at all, ``startup-app-init`` prints an
``ERROR: PL not programmed`` line and skips the driver load instead of
failing later with cryptic DMA errors.

Reaching a login prompt confirms the board booted:

.. code-block:: text

   SimpleVek280Example login:

The banner hostname comes from the project name of the built image
(``SimpleVek280Example`` here), not from the ``hardware`` directory name
(``XilinxVek280``) used in Step 1. It is the same for **all three** boot
modes, so it does not tell you which mode's ``BOOT.BIN`` is running --
distinguish the modes with the ``strings -a BOOT.BIN | grep -a
'^bootcmd='`` check from Step 2, or by the runtime behavior (a
``fallback`` build SD-boots after its TFTP attempts fail; a ``tftp-only``
build halts; an ``sd-only`` build prints ``SD-only build: skipping
netboot`` and never touches the network). Finally, confirm the board is
reachable over the network:

.. code-block:: bash

   ping -c 4 10.0.0.10

Troubleshooting
----------------

.. list-table::
   :header-rows: 1
   :widths: 40 30 30

   * - Symptom
     - Cause
     - Fix
   * - No ``Bytes transferred`` line; ``TFTP error: -1 (Request
       timeout)``, then a kernel banner boots anyway
     - TFTP fetch failed; a ``fallback`` build booted the on-SD
       ``image.ub`` instead
     - Confirm the host is serving the FIT with the host-side ``curl``
       check in Step 1, and that ``serverip`` on the board points at
       that host
   * - ``pxe get`` fails or is skipped; ``netboot`` silently used the
       direct ``image.ub`` fetch instead of a PXE config
     - No ``pxelinux.cfg`` file is being served (missing, misnamed, or
       not fetchable over TFTP)
     - Confirm ``/tftpboot/pxelinux.cfg/default`` exists and fetch it
       back from the host with the same TFTP check as Step 1
       (``curl -sf tftp://10.0.0.1/pxelinux.cfg/default``)
   * - ``netboot`` takes 1-2 minutes to fail (repeated ``TFTP error: -1
       (Request timeout)``) before the SD fallback or halt runs
     - No TFTP server is answering. ``netboot`` is PXE-first, so
       ``pxe get`` walks 13 ``pxelinux.cfg`` names before the direct FIT
       fetch, and each of those 14 attempts waits its **full** request
       timeout (~6 s) when nothing replies: ~85 s with the daemon stopped,
       ~110 s under a silent ``DROP`` firewall rule
     - Expected when TFTP is unreachable, and **not** a hang. ICMP
       ``destination unreachable`` does *not* shorten it -- a stopped
       daemon does emit it, and each attempt still times out anyway, so
       the presence or absence of ICMP lines does not distinguish the two
       cases. Restore TFTP reachability: once the server answers, a
       missing file draws an immediate ``TFTP error: 256`` refusal and the
       whole 14-name walk costs almost nothing. If the board has **no**
       TFTP server by design, rebuild it with ``-m sd-only`` (Step 2) --
       that removes ``run netboot`` from ``bootcmd`` entirely and is the
       structural fix rather than a workaround
   * - ``TFTP-only build: not falling back to SD`` followed by a halt
       at a bare ``Versal>`` prompt, no kernel banner
     - Expected behavior: a ``tftp-only`` build halts by design when
       TFTP fails, instead of silently falling back to an SD image.
       (An ``sd-only`` build never prints this, since it never runs
       ``netboot`` from ``bootcmd``.)
     - Bring the TFTP host back up and run ``reset``, or reflash the
       board with a ``fallback`` or ``sd-only`` build's ``BOOT.BIN``
   * - An ``sd-only`` board drops to ``Versal>``, or pays TFTP timeouts
       anyway, despite ``bootcmd`` containing no ``run netboot``
     - SD boot itself failed, so ``distro_bootcmd`` fell through the
       ``mmc`` targets to its trailing ``pxe``/``dhcp`` targets. A missing
       or corrupt ``/boot/boot.scr`` or ``/boot/image.ub`` is the usual
       cause; in ``sd-only`` there is no netboot path masking it
     - Confirm both files are present on the FAT boot partition (they are
       staged by ``BuildYoctoProject.sh`` and validated in its release file
       list). Re-image per :doc:`sd_card_imaging` if either is missing
   * - ``tftp-only`` netboot halts at ``Versal>`` after a TFTP error on
       ``pl.pdi``, ``system-top.dtb`` or ``pl.dtbo``
     - The diskless set is not fully staged on the server under the
       probed names; the mandatory ``loadpl_net`` step aborts netboot
       (never boots a net kernel over an unprogrammed or stale PL)
     - Stage it in Step 1 with ``-B`` (and ``-M`` for a per-MAC copy),
       then confirm each file with the host-side ``curl`` checks in
       Step 1
   * - Board loads a stale ``pl.pdi`` (or ``pl.dtbo``/``system-top.dtb``)
       even after re-running ``provision_tftp_host.sh``
     - A per-MAC name outranks the generic one, and a run without ``-M``
       cannot clean per-MAC leftovers -- it only warns about them
     - Re-run with ``-M <board-MAC>``, which refreshes that per-MAC copy
   * - ``tftp-only`` netboot halts at ``Versal>`` after a fetch error on
       a manifest-named AIE PDI or its ``.partition.conf`` sidecar
     - ``loadaie_one`` is also part of the mandatory ``&&`` chain: a
       manifest naming an image that is missing, or whose sidecar is
       missing or malformed, aborts netboot the same way a missing PL
       file does
     - Re-stage with ``-A`` from the AIE build's ``ip`` directory (the
       same directory ``make program`` deploys from), then confirm
       ``aie/manifest`` and that image's files with ``curl``
   * - ``ERROR: PL not programmed`` at the end of boot; no runtime
       application starts
     - ``startup-app-init`` found ``$pl_programmed`` unset -- neither its
       own ``fpgautil`` load nor the ``tftp-only`` marker succeeded
     - On a ``tftp-only`` board confirm the diskless set staged and
       ``fpga load``/``fdt apply`` succeeded; on an SD board confirm
       ``/boot/pl.pdi`` and ``/boot/pl.dtbo`` are both present and valid
   * - No ``DHCP client bound`` line appears at all
     - The board is not getting a DHCP lease on this network
     - Use the static-IP override shown in Step 3
   * - ``fatwrite`` fails with "no space left" even though the FAT
       partition has free space
     - This platform's saved-environment path shares the same FAT boot
       partition that ``fatwrite`` writes to, and that write path is not
       relied upon or characterized here
     - Do not use ``fatwrite`` or a raw ``mmc write``; boot Linux and
       ``cp`` the new file to the mounted boot partition (see the
       warning in Step 2)
   * - TFTP fetches fail after ``dhcp`` even though ``serverip`` was set
       correctly by hand
     - lwIP ``dhcp`` overwrote ``serverip`` with the DHCP server's own
       address, or set ``tftpserverip`` from the DHCP next-server (which
       ``tftpboot`` and ``pxe`` prefer over ``serverip``)
     - Set ``serverip`` **before** ``run netboot`` -- the shipped
       ``netboot`` preserves a non-empty ``serverip`` across its internal
       ``dhcp`` and clears ``tftpserverip``. To return to DHCP-supplied
       addressing, clear it with ``setenv serverip``
   * - A PXE config is served and ``pxe boot`` runs, but no kernel boots
       and the board does not fall back to SD (or halt) as expected
     - The PXE label's ``KERNEL`` FIT could not be retrieved; upstream
       ``pxe boot`` returns exit status 0 even on that failure
     - Handled by design: ``bootcmd`` is sequential
       (``run netboot; <mode-action>``), so the SD fallback (or
       ``tftp-only`` halt) runs regardless of ``netboot``'s exit code.
       Confirm the ``KERNEL`` file named in the ``pxelinux.cfg`` is
       actually served (``curl -sf tftp://<serverip>/<name>``)
   * - ``No valid MAC address found`` prints early during boot
     - Expected on a cold power-on: this prints before the EEPROM MAC
       becomes readable; ``netboot`` reads it separately, later, at the
       wait described in the next row
     - Not a fault -- continue watching the console
   * - A pause of up to about 12 seconds appears just before ``dhcp``
       runs
     - The EEPROM MAC wait: ``netboot`` polls the board's EEPROM for up
       to about 12 seconds before running ``dhcp``, when no static
       ``ipaddr`` is set
     - Expected; exhausting the wait with no MAC found skips this
       ``dhcp`` attempt and the sequential ``bootcmd`` falls straight
       through to the mode action
   * - ``No AIE manifest served, booting PL only``
     - No ``-A`` was passed on the last ``provision_tftp_host.sh`` run
       for this server (or a run with only ``-B``/``-M`` cleared a
       previously staged AIE set)
     - Re-stage with ``-A <dir>`` from the AIE build's ``ip`` directory
   * - Journal line ``no AIE service started from /chosen/slac,aie``
     - Either no manifest was served (U-Boot passed no AIE image at
       all), or every node under ``/chosen/slac,aie`` was malformed --
       check the ``ERROR: malformed`` line just above it for which
     - Re-stage the AIE set with ``-A``, or fix the malformed sidecar it
       names and rebuild

How long the SD fallback takes depends entirely on whether the TFTP
server *answers*. A single ``tftpboot`` gives up after roughly 6 seconds,
but ``netboot`` is PXE-first: ``pxe get`` tries 13 ``pxelinux.cfg`` names
ahead of the direct FIT fetch, so a ``fallback`` board on a network with
**no reachable TFTP server** pays that timeout 14 times over -- about
85 seconds with the daemon stopped, and about 110 seconds if packets are
silently dropped. When the server *is* reachable and merely missing a
file, every attempt is refused immediately and the fallback is effectively
instant. Allow up to ~2 minutes before concluding a board has hung, and
see the ``Request timeout`` entry above.

That full 14-attempt cost needs a **reachable DHCP server** as well as an
unreachable TFTP one. ``netboot`` starts with ``dhcp`` in an ``&&`` chain, so
on a network with no DHCP server at all it short-circuits at the DHCP
timeout and never reaches the TFTP attempts. An ``sd-only`` board pays
neither: its ``bootcmd`` contains no ``run netboot``, so there is no DHCP
attempt and no TFTP attempt on the boot path at all.

.. note::

   ``sd-only`` removes netboot from the **success** path, not from every
   possible path. ``sdboot`` is ``run distro_bootcmd``, which walks
   ``boot_targets`` in order; the ``mmc`` targets come first and a healthy SD
   card short-circuits there, but a board whose SD boot *fails* still falls
   through to ``distro_bootcmd``'s trailing ``pxe`` and ``dhcp`` targets and
   can pay the usual timeouts there. That tail is identical to a
   ``fallback`` build's and is unchanged by this mode. Read the list off an
   artifact with ``strings -a BOOT.BIN | grep -a '^boot_targets='``.

Notes
-----

- Recovering a board that no longer boots at all is not covered here;
  re-image it per :doc:`sd_card_imaging`, or bring a ``tftp-only`` board
  back with a ``fallback`` or ``sd-only`` build's ``BOOT.BIN`` (Step 2's
  warning on switching modes).

- The diskless PL, overlay and AIE stack is deliberately mode-gated and
  all-or-nothing: in ``tftp-only`` it is mandatory (halt on failure), and
  in ``fallback`` and ``sd-only`` it is skipped entirely so the SD
  ``fpgautil`` load stays authoritative and there is no double-program. It
  does **not** fetch a network PL to override an inserted SD in either of
  those modes.

  .. note::

     A "best-effort" variant -- where U-Boot loads a network PL if one is
     served but continues (rather than halting) if none is -- would let a
     net PL override an inserted SD. That is out of scope here; the
     current design keeps each mode a coherent stack (full-network in
     ``tftp-only``, SD-owned PL in ``fallback``, and no network on the
     boot path at all in ``sd-only``). If such a mode is added later, it
     must preserve netboot's ``&&`` failure chain -- a fetch, ``fpga load``
     or ``fdt apply`` failure must still be able to abort the boot --
     rather than relaxing the chain to ``;``.

- The per-MAC filename is dash-separated (``pl.pdi.00-0a-35-00-00-01``),
  like the ``pxelinux.cfg`` MAC form but without the ``01-`` prefix.
  U-Boot's ``tftpboot`` parses the first ``:`` in a filename as a
  ``hostIP:file`` separator, so a colon-form name (``${ethaddr}``
  verbatim) is silently mis-parsed and never fetched; ``loadpl_net``
  therefore rewrites the colons to dashes with ``setexpr gsub`` before the
  fetch (requires ``CONFIG_CMD_SETEXPR`` and ``CONFIG_REGEX``, both on in
  this Versal U-Boot build).

- ``BOOT.BIN`` carries only the PLM and the static PDI (the PS and NoC
  configuration) in every mode -- Versal's segmented configuration flow
  keeps the PL out of it entirely. The PL always comes from ``pl.pdi``,
  whichever path loads it: U-Boot's ``fpga load`` on ``tftp-only``, or
  ``startup-app-init``'s ``fpgautil`` on ``fallback``/``sd-only``.

- ``tftp-only`` halts at the ``Versal>`` prompt on a missing PL file and
  has no SD fallback, so a bad server-side ``pl.pdi`` keeps the board off
  the network until the server is fixed. See
  https://github.com/slaclab/Simple-VEK280-Example/issues/3 for that
  interaction with remote PL updates.
