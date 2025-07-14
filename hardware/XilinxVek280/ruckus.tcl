# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2025.1 of Vivado (or later)
if { [VersionCheck 2025.1] < 0 } {exit -1}

# Check for valid FPGA
if { $::env(PRJ_PART) != "xcve2802-vsvh1760-2MP-e-S" } {
   puts "\n\nERROR: PRJ_PART must be either xcve2802-vsvh1760-2MP-e-S in the Makefile\n\n"; exit -1
}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"
loadConstraints -dir "$::DIR_PATH/xdc"
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/rtl"

# Set the board part
set_property board_part xilinx.com:vek280:part0:1.2 [current_project]

# Load the block design
if  { $::env(VIVADO_VERSION) >= 2025.1 } {
   set bdVer "2025.1"
}
loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.bd"
# loadBlockDesign -path "$::DIR_PATH/bd/${bdVer}/AxiSocVersalCpuCore.tcl"
