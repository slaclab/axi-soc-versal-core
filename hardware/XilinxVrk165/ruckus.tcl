# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2026.1 of Vivado (or later)
if { [VersionCheck 2026.1] < 0 } {exit -1}

# Check for valid FPGA (production silicon only, reject ES1 parts first)
if { [string match "*-es1*" $::env(PRJ_PART)] } {
   puts "\n\nERROR: PRJ_PART ($::env(PRJ_PART)) is an ES1 part. Production silicon (xcvr1652-vsva2488-2MP-e-S) is required\n\n"; exit -1
}
if { $::env(PRJ_PART) != "xcvr1652-vsva2488-2MP-e-S" } {
   puts "\n\nERROR: PRJ_PART must be xcvr1652-vsva2488-2MP-e-S in the Makefile\n\n"; exit -1
}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"
loadConstraints -dir "$::DIR_PATH/xdc"
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/rtl"

# Set the board part
# The production board files are vendored next to this file because Vivado 2026.1 ships ES1 board files only.
# ruckus creates the project before this file runs and create_project snapshots the board.repoPaths param,
# so the board_part_repo_paths project property (also saved in the .xpr for the child runs) is the
# registration that takes effect. The param is mirrored for the current session.
set boardPart "xilinx.com:vrk165:part0:1.0"
if { [string match "*xilinx.com:vrk165_es:part0*" $boardPart] } {
   puts "\n\nERROR: board part $boardPart is an ES1 board. Production board files are required\n\n"; exit -1
}
set boardRepo [file normalize "$::DIR_PATH/board_repo"]

# Append the vendored board repo to the project property (once)
set prjRepos [get_property board_part_repo_paths [current_project]]
set found 0
foreach repo $prjRepos { if { [file normalize $repo] eq $boardRepo } { set found 1 } }
if { !$found } {
   set_property board_part_repo_paths [concat $prjRepos [list $boardRepo]] [current_project]
}

# Mirror it in the param (once)
set parRepos [get_param board.repoPaths]
set found 0
foreach repo $parRepos { if { [file normalize $repo] eq $boardRepo } { set found 1 } }
if { !$found } {
   set_param board.repoPaths [concat $parRepos [list $boardRepo]]
}

# Read the registration back before it is used
set found 0
foreach repo [get_property board_part_repo_paths [current_project]] { if { [file normalize $repo] eq $boardRepo } { set found 1 } }
if { !$found } {
   puts "\n\nERROR: board_part_repo_paths does not include $boardRepo\n\n"; exit -1
}
if { [catch {set_property board_part $boardPart [current_project]} err] } {
   puts "\n\nERROR: board part $boardPart not available (ES1 board files are not supported): $err\n\n"; exit -1
}
if { [get_property board_part [current_project]] != $boardPart } {
   puts "\n\nERROR: board_part must be $boardPart\n\n"; exit -1
}

# Load the block design
set bdVer "2026.1"
loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.bd"
# loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.tcl"

# When using Segmented Configuration, lock the NoC to a pre-computed solution so
# the static NoC stays identical between the static and dynamic partitions.
# NOTE: the .ncr is keyed by hierarchical instance name. It assumes the
# application instantiates AxiSocVersalCore as "U_Core" at the top level.
# A different label or a changed block design requires regenerating the .ncr
# from the impl run directory (written next to the routed DCP) and re-checking
# with pr_verify against the golden routed DCP.
# The lock is skipped with a warning until the .ncr is harvested from the first routed build.
if { $::env(USE_SEGMENTED_CONFIG) != 0 } {
   set ncr "$::DIR_PATH/bd/${bdVer}/XilinxVrk165NoC.ncr"
   if { [file exists $ncr] } {
      loadNoCSolution -path $ncr
   } else {
      puts "WARNING: $ncr not found, NoC solution not locked"
   }
}
