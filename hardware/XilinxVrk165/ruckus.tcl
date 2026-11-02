# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2026.1.1 of Vivado (or later): Vivado 2026.1 installs only the ES1 board files
if { [VersionCheck 2026.1.1] < 0 } {exit -1}

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
set_property board_part xilinx.com:vrk165:part0:1.0 [current_project]

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
if { $::env(USE_SEGMENTED_CONFIG) != 0 } {
   loadNoCSolution -path "$::DIR_PATH/bd/${bdVer}/XilinxVrk165NoC.ncr"
}
