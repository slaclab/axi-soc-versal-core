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

#####################################################
# Note on how I added the AXI stream interface to AIE
#####################################################
# set_property -dict [list \
   # CONFIG.CLK_NAMES {aclk0} \
   # CONFIG.NAME_MI_AXIS {M00_AXIS,M01_AXIS,M02_AXIS,M03_AXIS,M04_AXIS,M05_AXIS,M06_AXIS,M07_AXIS,M08_AXIS,M09_AXIS,M10_AXIS,M11_AXIS,M12_AXIS,M13_AXIS,M14_AXIS,M15_AXIS,} \
   # CONFIG.NAME_SI_AXIS {S00_AXIS,S01_AXIS,S02_AXIS,S03_AXIS,S04_AXIS,S05_AXIS,S06_AXIS,S07_AXIS,S08_AXIS,S09_AXIS,S10_AXIS,S11_AXIS,S12_AXIS,S13_AXIS,S14_AXIS,S15_AXIS,} \
   # CONFIG.NUM_CLKS {1} \
   # CONFIG.NUM_MI_AXIS {16} \
   # CONFIG.NUM_SI_AXIS {16} \
# ] [get_bd_cells ai_engine_0]

# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S00_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S01_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S02_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S03_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S04_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S05_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S06_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S07_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S08_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S09_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S10_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S11_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S12_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S13_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S14_AXIS_0]
# set_property -dict [list CONFIG.HAS_TKEEP 1 CONFIG.HAS_TLAST 1 CONFIG.TDATA_NUM_BYTES 16 CONFIG.TDEST_WIDTH 0 CONFIG.TUSER_WIDTH 0] [get_bd_intf_ports S15_AXIS_0]

# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M00_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M01_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M02_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M03_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M04_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M05_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M06_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M07_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M08_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M09_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M10_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M11_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M12_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M13_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M14_AXIS]
# set_property CONFIG.TDATA_NUM_BYTES 16 [get_bd_intf_pins /ai_engine_0/M15_AXIS]
