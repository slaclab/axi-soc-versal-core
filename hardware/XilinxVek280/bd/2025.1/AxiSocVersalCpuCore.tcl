
################################################################
# This is a generated script based on design: AxiSocVersalCpuCore
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source AxiSocVersalCpuCore_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcve2802-vsvh1760-2MP-e-S
   set_property BOARD_PART xilinx.com:vek280:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name AxiSocVersalCpuCore

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:versal_cips:3.4\
xilinx.com:ip:axi_noc:1.1\
xilinx.com:ip:ai_engine:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ch0_lpddr4_trip1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_trip1 ]

  set ch1_lpddr4_trip1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_trip1 ]

  set lpddr4_clk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_clk1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $lpddr4_clk1

  set ch0_lpddr4_trip2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_trip2 ]

  set ch1_lpddr4_trip2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_trip2 ]

  set lpddr4_clk2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_clk2 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $lpddr4_clk2

  set ch0_lpddr4_trip3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_trip3 ]

  set ch1_lpddr4_trip3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_trip3 ]

  set lpddr4_clk3 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_clk3 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $lpddr4_clk3

  set dma [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 dma ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {10} \
   CONFIG.AWUSER_WIDTH {10} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {6} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $dma

  set dmaCtrl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 dmaCtrl ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {44} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   ] $dmaCtrl

  set axiLite [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 axiLite ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {44} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   ] $axiLite


  # Create ports
  set dmaIrq [ create_bd_port -dir I -type intr dmaIrq ]
  set dmaClk [ create_bd_port -dir I -type clk -freq_hz 250000000 dmaClk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {dma:dmaCtrl:axiLite} \
 ] $dmaClk
  set plClk [ create_bd_port -dir O -type clk plClk ]
  set plRstL [ create_bd_port -dir O -type rst plRstL ]

  # Create instance: CIPS_0, and set properties
  set CIPS_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:3.4 CIPS_0 ]
  set_property -dict [list \
    CONFIG.CLOCK_MODE {Custom} \
    CONFIG.DDR_MEMORY_MODE {Custom} \
    CONFIG.PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
    CONFIG.PS_PL_CONNECTIVITY_MODE {Custom} \
    CONFIG.PS_PMC_CONFIG { \
      CLOCK_MODE {Custom} \
      DDR_MEMORY_MODE {Custom} \
      DESIGN_MODE {1} \
      DEVICE_INTEGRITY_MODE {Sysmon temperature voltage and external IO monitoring} \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {250} \
      PMC_GPIO0_MIO_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 25}}} \
      PMC_GPIO1_MIO_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26 .. 51}}} \
      PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO37 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA high} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO38 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA high} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_OSPI_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
      PMC_REF_CLK_FREQMHZ {33.3333} \
      PMC_SD1 {{CD_ENABLE 1} {CD_IO {PMC_MIO 28}} {POW_ENABLE 1} {POW_IO {PMC_MIO 51}} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 12}} {WP_ENABLE 0} {WP_IO {PMC_MIO 1}}} \
      PMC_SD1_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x3} {CLK_200_SDR_OTAP_DLY 0x2} {CLK_50_DDR_ITAP_DLY 0x36} {CLK_50_DDR_OTAP_DLY 0x3} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x4} {ENABLE 1} {IO\
{PMC_MIO 26 .. 36}}} \
      PMC_SD1_SLOT_TYPE {SD 3.0} \
      PMC_USE_PMC_NOC_AXI0 {1} \
      PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
      PS_CAN0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 14 .. 15}}} \
      PS_CAN1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 16 .. 17}}} \
      PS_CRL_CAN0_REF_CTRL_FREQMHZ {160} \
      PS_CRL_CAN1_REF_CTRL_FREQMHZ {160} \
      PS_ENET0_MDIO {{ENABLE 1} {IO {PS_MIO 24 .. 25}}} \
      PS_ENET0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 11}}} \
      PS_GEN_IPI0_ENABLE {1} \
      PS_GEN_IPI0_MASTER {A72} \
      PS_GEN_IPI1_ENABLE {1} \
      PS_GEN_IPI1_MASTER {R5_0} \
      PS_GEN_IPI2_ENABLE {1} \
      PS_GEN_IPI2_MASTER {R5_1} \
      PS_GEN_IPI3_ENABLE {1} \
      PS_GEN_IPI3_MASTER {A72} \
      PS_GEN_IPI4_ENABLE {1} \
      PS_GEN_IPI4_MASTER {A72} \
      PS_GEN_IPI5_ENABLE {1} \
      PS_GEN_IPI5_MASTER {A72} \
      PS_GEN_IPI6_ENABLE {1} \
      PS_GEN_IPI6_MASTER {A72} \
      PS_I2C0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 46 .. 47}}} \
      PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 44 .. 45}}} \
      PS_I2CSYSMON_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 39 .. 40}}} \
      PS_IRQ_USAGE {{CH0 1} {CH1 0} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
      PS_MIO7 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO9 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_M_AXI_FPD_DATA_WIDTH {32} \
      PS_M_AXI_LPD_DATA_WIDTH {32} \
      PS_NUM_FABRIC_RESETS {1} \
      PS_PCIE_EP_RESET1_IO {PS_MIO 18} \
      PS_PCIE_EP_RESET2_IO {PS_MIO 19} \
      PS_PCIE_RESET {ENABLE 1} \
      PS_PL_CONNECTIVITY_MODE {Custom} \
      PS_TTC0_PERIPHERAL_ENABLE {1} \
      PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 42 .. 43}}} \
      PS_USB3_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 13 .. 25}}} \
      PS_USE_FPD_AXI_NOC0 {1} \
      PS_USE_FPD_AXI_NOC1 {1} \
      PS_USE_FPD_CCI_NOC {1} \
      PS_USE_M_AXI_FPD {1} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_LPD_AXI0 {1} \
      PS_USE_PMCPL_CLK0 {1} \
      PS_USE_S_AXI_FPD {1} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_INTERFACE_TO_USE {I2C} \
      SMON_PMBUS_ADDRESS {0x18} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
    } \
  ] $CIPS_0


  # Create instance: Master_NoC, and set properties
  set Master_NoC [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 Master_NoC ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {8} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {7} \
    CONFIG.NUM_SI {8} \
  ] $Master_NoC


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M02_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M04_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /Master_NoC/M05_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /Master_NoC/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /Master_NoC/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /Master_NoC/S02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M03_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /Master_NoC/S03_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /Master_NoC/S04_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /Master_NoC/S05_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /Master_NoC/S06_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /Master_NoC/S07_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /Master_NoC/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /Master_NoC/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /Master_NoC/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /Master_NoC/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /Master_NoC/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /Master_NoC/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S06_AXI} \
 ] [get_bd_pins /Master_NoC/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S07_AXI} \
 ] [get_bd_pins /Master_NoC/aclk7]

  # Create instance: noc_lpddr0, and set properties
  set noc_lpddr0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 noc_lpddr0 ]
  set_property -dict [list \
    CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_trip1} \
    CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_trip1} \
    CONFIG.MC_CHANNEL_INTERLEAVING {true} \
    CONFIG.MC_CHAN_REGION1 {DDR_LOW1} \
    CONFIG.MC_CH_INTERLEAVING_SIZE {4K_Bytes} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {5} \
    CONFIG.NUM_SI {0} \
    CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_clk1} \
  ] $noc_lpddr0


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr0/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr0/S01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr0/S02_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr0/S03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr0/S04_INI]

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine:2.0 ai_engine_0 ]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins /ai_engine_0/S00_AXI]

  # Create instance: ConfigNoc, and set properties
  set ConfigNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 ConfigNoc ]
  set_property -dict [list \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $ConfigNoc


  set_property -dict [ list \
   CONFIG.CATEGORY {aie} \
 ] [get_bd_intf_pins /ConfigNoc/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /ConfigNoc/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /ConfigNoc/aclk0]

  # Create instance: noc_lpddr1, and set properties
  set noc_lpddr1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 noc_lpddr1 ]
  set_property -dict [list \
    CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_trip2} \
    CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_trip2} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH1} \
    CONFIG.NUM_MCP {2} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
    CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_clk2} \
  ] $noc_lpddr1


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr1/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr1/S01_INI]

  # Create instance: noc_lpddr2, and set properties
  set noc_lpddr2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 noc_lpddr2 ]
  set_property -dict [list \
    CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_trip3} \
    CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_trip3} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH2} \
    CONFIG.NUM_MCP {2} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
    CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_clk3} \
  ] $noc_lpddr2


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr2/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /noc_lpddr2/S01_INI]

  # Create instance: aggr_noc, and set properties
  set aggr_noc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 aggr_noc ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {3} \
    CONFIG.NUM_SI {0} \
  ] $aggr_noc


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /aggr_noc/M00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /aggr_noc/M01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /aggr_noc/M02_INI]

  # Create interface connections
  connect_bd_intf_net -intf_net CIPS_0_FPD_AXI_NOC_0 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_0] [get_bd_intf_pins Master_NoC/S04_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_AXI_NOC_1 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_1] [get_bd_intf_pins Master_NoC/S05_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_0 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_0] [get_bd_intf_pins Master_NoC/S00_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_1 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_1] [get_bd_intf_pins Master_NoC/S01_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_2 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_2] [get_bd_intf_pins Master_NoC/S02_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_3 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_3] [get_bd_intf_pins Master_NoC/S03_AXI]
  connect_bd_intf_net -intf_net CIPS_0_LPD_AXI_NOC_0 [get_bd_intf_pins CIPS_0/LPD_AXI_NOC_0] [get_bd_intf_pins Master_NoC/S06_AXI]
  connect_bd_intf_net -intf_net CIPS_0_M_AXI_FPD [get_bd_intf_ports axiLite] [get_bd_intf_pins CIPS_0/M_AXI_FPD]
  connect_bd_intf_net -intf_net CIPS_0_M_AXI_LPD [get_bd_intf_ports dmaCtrl] [get_bd_intf_pins CIPS_0/M_AXI_LPD]
  connect_bd_intf_net -intf_net CIPS_0_PMC_NOC_AXI_0 [get_bd_intf_pins CIPS_0/PMC_NOC_AXI_0] [get_bd_intf_pins Master_NoC/S07_AXI]
  connect_bd_intf_net -intf_net ConfigNoc_M00_AXI [get_bd_intf_pins ConfigNoc/M00_AXI] [get_bd_intf_pins ai_engine_0/S00_AXI]
  connect_bd_intf_net -intf_net Master_NoC_M00_INI [get_bd_intf_pins Master_NoC/M00_INI] [get_bd_intf_pins noc_lpddr0/S00_INI]
  connect_bd_intf_net -intf_net Master_NoC_M01_INI [get_bd_intf_pins Master_NoC/M01_INI] [get_bd_intf_pins noc_lpddr0/S01_INI]
  connect_bd_intf_net -intf_net Master_NoC_M02_INI [get_bd_intf_pins Master_NoC/M02_INI] [get_bd_intf_pins noc_lpddr0/S02_INI]
  connect_bd_intf_net -intf_net Master_NoC_M03_INI [get_bd_intf_pins Master_NoC/M03_INI] [get_bd_intf_pins noc_lpddr0/S03_INI]
  connect_bd_intf_net -intf_net Master_NoC_M04_INI [get_bd_intf_pins Master_NoC/M04_INI] [get_bd_intf_pins noc_lpddr1/S00_INI]
  connect_bd_intf_net -intf_net Master_NoC_M05_INI [get_bd_intf_pins Master_NoC/M05_INI] [get_bd_intf_pins noc_lpddr2/S00_INI]
  connect_bd_intf_net -intf_net Master_NoC_M06_INI [get_bd_intf_pins Master_NoC/M06_INI] [get_bd_intf_pins ConfigNoc/S00_INI]
  connect_bd_intf_net -intf_net S_AXI_FPD_0_1 [get_bd_intf_ports dma] [get_bd_intf_pins CIPS_0/S_AXI_FPD]
  connect_bd_intf_net -intf_net aggr_noc_M00_INI [get_bd_intf_pins aggr_noc/M00_INI] [get_bd_intf_pins noc_lpddr0/S04_INI]
  connect_bd_intf_net -intf_net aggr_noc_M01_INI [get_bd_intf_pins aggr_noc/M01_INI] [get_bd_intf_pins noc_lpddr1/S01_INI]
  connect_bd_intf_net -intf_net aggr_noc_M02_INI [get_bd_intf_pins aggr_noc/M02_INI] [get_bd_intf_pins noc_lpddr2/S01_INI]
  connect_bd_intf_net -intf_net lpddr4_clk1_1 [get_bd_intf_ports lpddr4_clk1] [get_bd_intf_pins noc_lpddr0/sys_clk0]
  connect_bd_intf_net -intf_net lpddr4_clk2_1 [get_bd_intf_ports lpddr4_clk2] [get_bd_intf_pins noc_lpddr1/sys_clk0]
  connect_bd_intf_net -intf_net lpddr4_clk3_1 [get_bd_intf_ports lpddr4_clk3] [get_bd_intf_pins noc_lpddr2/sys_clk0]
  connect_bd_intf_net -intf_net noc_lpddr0_CH0_LPDDR4_0 [get_bd_intf_ports ch0_lpddr4_trip1] [get_bd_intf_pins noc_lpddr0/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net noc_lpddr0_CH1_LPDDR4_0 [get_bd_intf_ports ch1_lpddr4_trip1] [get_bd_intf_pins noc_lpddr0/CH1_LPDDR4_0]
  connect_bd_intf_net -intf_net noc_lpddr1_CH0_LPDDR4_0 [get_bd_intf_ports ch0_lpddr4_trip2] [get_bd_intf_pins noc_lpddr1/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net noc_lpddr1_CH1_LPDDR4_0 [get_bd_intf_ports ch1_lpddr4_trip2] [get_bd_intf_pins noc_lpddr1/CH1_LPDDR4_0]
  connect_bd_intf_net -intf_net noc_lpddr2_CH0_LPDDR4_0 [get_bd_intf_ports ch0_lpddr4_trip3] [get_bd_intf_pins noc_lpddr2/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net noc_lpddr2_CH1_LPDDR4_0 [get_bd_intf_ports ch1_lpddr4_trip3] [get_bd_intf_pins noc_lpddr2/CH1_LPDDR4_0]

  # Create port connections
  connect_bd_net -net CIPS_0_fpd_axi_noc_axi0_clk  [get_bd_pins CIPS_0/fpd_axi_noc_axi0_clk] \
  [get_bd_pins Master_NoC/aclk4]
  connect_bd_net -net CIPS_0_fpd_axi_noc_axi1_clk  [get_bd_pins CIPS_0/fpd_axi_noc_axi1_clk] \
  [get_bd_pins Master_NoC/aclk5]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi0_clk  [get_bd_pins CIPS_0/fpd_cci_noc_axi0_clk] \
  [get_bd_pins Master_NoC/aclk0]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi1_clk  [get_bd_pins CIPS_0/fpd_cci_noc_axi1_clk] \
  [get_bd_pins Master_NoC/aclk1]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi2_clk  [get_bd_pins CIPS_0/fpd_cci_noc_axi2_clk] \
  [get_bd_pins Master_NoC/aclk2]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi3_clk  [get_bd_pins CIPS_0/fpd_cci_noc_axi3_clk] \
  [get_bd_pins Master_NoC/aclk3]
  connect_bd_net -net CIPS_0_lpd_axi_noc_clk  [get_bd_pins CIPS_0/lpd_axi_noc_clk] \
  [get_bd_pins Master_NoC/aclk6]
  connect_bd_net -net CIPS_0_pl0_ref_clk  [get_bd_pins CIPS_0/pl0_ref_clk] \
  [get_bd_ports plClk]
  connect_bd_net -net CIPS_0_pl0_resetn  [get_bd_pins CIPS_0/pl0_resetn] \
  [get_bd_ports plRstL]
  connect_bd_net -net CIPS_0_pmc_axi_noc_axi0_clk  [get_bd_pins CIPS_0/pmc_axi_noc_axi0_clk] \
  [get_bd_pins Master_NoC/aclk7]
  connect_bd_net -net ai_engine_0_s00_axi_aclk  [get_bd_pins ai_engine_0/s00_axi_aclk] \
  [get_bd_pins ConfigNoc/aclk0]
  connect_bd_net -net m_axi_fpd_aclk_0_1  [get_bd_ports dmaClk] \
  [get_bd_pins CIPS_0/m_axi_fpd_aclk] \
  [get_bd_pins CIPS_0/m_axi_lpd_aclk] \
  [get_bd_pins CIPS_0/s_axi_fpd_aclk]
  connect_bd_net -net pl_ps_irq0_0_1  [get_bd_ports dmaIrq] \
  [get_bd_pins CIPS_0/pl_ps_irq0]

  # Create address segments
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_lpddr0/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_lpddr0/S01_INI/C1_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_lpddr0/S02_INI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_lpddr0/S02_INI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_lpddr0/S03_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_lpddr0/S03_INI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/LPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/LPD_AXI_NOC_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs axiLite/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_LPD] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0] [get_bd_addr_segs noc_lpddr0/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0] [get_bd_addr_segs noc_lpddr1/S00_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0] [get_bd_addr_segs noc_lpddr2/S00_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0xFD5C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_apu_0] -force
  assign_bd_address -offset 0xFF060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_canfd_0] -force
  assign_bd_address -offset 0xFF070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_canfd_1] -force
  assign_bd_address -offset 0xF0800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0xF0D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0xF0D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0xF0D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0xF0D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0xF0D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0xF0D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0xF0D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0xF0D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0xF0CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0xF0C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0xF0C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0xF0C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0xF0F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0xF0FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0xF0FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0xF0F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0xF0F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0xF0F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0xF0F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0xF0F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0xF0F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0xF0B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0xF0BB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_fpd_cti1b] -force
  assign_bd_address -offset 0xF0BC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_fpd_cti1c] -force
  assign_bd_address -offset 0xF0BD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_fpd_cti1d] -force
  assign_bd_address -offset 0xF0B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0xF0980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0xF09D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_lpd_cti] -force
  assign_bd_address -offset 0xF08D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_pmc_cti] -force
  assign_bd_address -offset 0xF0A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_r50_cti] -force
  assign_bd_address -offset 0xF0A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_coresight_r51_cti] -force
  assign_bd_address -offset 0xFD1A0000 -range 0x00140000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_crf_0] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0xF1260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ethernet_0] -force
  assign_bd_address -offset 0xFD360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_afi_0] -force
  assign_bd_address -offset 0xFD380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_afi_2] -force
  assign_bd_address -offset 0xFD5E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_cci_0] -force
  assign_bd_address -offset 0xFD700000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_gpv_0] -force
  assign_bd_address -offset 0xFD000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_maincci_0] -force
  assign_bd_address -offset 0xFD390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_slave_xmpu_0] -force
  assign_bd_address -offset 0xFD610000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_slcr_0] -force
  assign_bd_address -offset 0xFD690000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFD5F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_smmu_0] -force
  assign_bd_address -offset 0xFD800000 -range 0x00800000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_fpd_smmutcu_0] -force
  assign_bd_address -offset 0xFF020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_i2c_0] -force
  assign_bd_address -offset 0xFF030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_i2c_1] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF3F0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_buffer] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0xF11E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0xF11F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0xF12D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0xF12B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0xF11C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0xF11D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0xF1250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0xF1240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0xF1110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0xF1020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_gpio_0] -force
  assign_bd_address -offset 0xF1010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_ospi_0] -force
  assign_bd_address -offset 0xF0310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0xF2000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0xF6000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0xF1200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0xF12A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0xF1050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_sd_1] -force
  assign_bd_address -offset 0xF1210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0xF1220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0xF2100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0xF1270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0xF1230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0xF12F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0xF1310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0xF1300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF9D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_usb_0] -force
  assign_bd_address -offset 0xFE200000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs CIPS_0/S_AXI_FPD/pspmc_0_psv_usb_xhci_0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


