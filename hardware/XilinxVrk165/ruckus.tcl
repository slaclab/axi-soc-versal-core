# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2026.2 of Vivado (or later)
if { [VersionCheck 2026.2] < 0 } {exit -1}

# Check for valid FPGA (production silicon, or ES1 silicon on the VRK165 ES1 board)
if { $::env(PRJ_PART) == "xcvr1652-vsva2488-2MP-e-S" } {
   set isEs1 0
} elseif { $::env(PRJ_PART) == "xcvr1652-vsva2488-2MP-e-S-es1" } {
   set isEs1 1
   puts "\n\nWARNING: PRJ_PART ($::env(PRJ_PART)) is an ES1 part, targeting the VRK165 ES1 board (xilinx.com:vrk165_es:part0:1.2)\n\n"
} else {
   puts "\n\nERROR: PRJ_PART must be xcvr1652-vsva2488-2MP-e-S (or xcvr1652-vsva2488-2MP-e-S-es1 for the ES1 board) in the Makefile\n\n"; exit -1
}

# The NoC solution (.ncr) was computed on the production part
if { $isEs1 && $::env(USE_SEGMENTED_CONFIG) != 0 } {
   puts "\n\nERROR: USE_SEGMENTED_CONFIG is not supported on the ES1 part (the NoC solution is for xcvr1652-vsva2488-2MP-e-S)\n\n"; exit -1
}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"
loadConstraints -dir "$::DIR_PATH/xdc"
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/rtl"

# Set the board part
if { $isEs1 } {
   set_property board_part xilinx.com:vrk165_es:part0:1.2 [current_project]
} else {
   set_property board_part xilinx.com:vrk165:part0:1.1 [current_project]
}

# Load the block design
set bdVer "2026.2"
# The .bd is tied to the production part, so the ES1 build regenerates it from the .tcl
if { $isEs1 } {
   loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.tcl"
} else {
   loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.bd"
   # loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.tcl"
}

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
