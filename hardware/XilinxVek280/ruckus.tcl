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

##############################################
# Note on how I added the AXI stream interface
##############################################
# set_property -dict [list \
   # CONFIG.CLK_NAMES {aclk0} \
   # CONFIG.NAME_MI_AXIS {M00_AXIS,M01_AXIS,M02_AXIS,M03_AXIS,M04_AXIS,M05_AXIS,M06_AXIS,M07_AXIS,M08_AXIS,M09_AXIS,M10_AXIS,M11_AXIS,M12_AXIS,M13_AXIS,M14_AXIS,M15_AXIS,} \
   # CONFIG.NAME_SI_AXIS {S00_AXIS,S01_AXIS,S02_AXIS,S03_AXIS,S04_AXIS,S05_AXIS,S06_AXIS,S07_AXIS,S08_AXIS,S09_AXIS,S10_AXIS,S11_AXIS,S12_AXIS,S13_AXIS,S14_AXIS,S15_AXIS,} \
   # CONFIG.NUM_CLKS {1} \
   # CONFIG.NUM_MI_AXIS {16} \
   # CONFIG.NUM_SI_AXIS {16} \
# ] [get_bd_cells ai_engine_0]
