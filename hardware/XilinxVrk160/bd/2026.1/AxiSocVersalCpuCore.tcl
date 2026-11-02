
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
set scripts_vivado_version 2026.1
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
   create_project project_1 myproj -part xcvr1602-vsva2488-2MP-e-S
   set_property BOARD_PART xilinx.com:vrk160_p:part0:1.0 [current_project]
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

  # Add USER_COMMENTS on $design_name
  set_property USER_COMMENTS.comment0 "	 	 ======================= >>>>>>>>> An Example Versal Embedded Common Platform <<<<<<<<< =======================
	 Note:
	 --> Board preset applied to PS_WIZARD and memory controller settings
	 --> AI Engine control path is connected to PS_WIZARD
	 --> V++ will connect AI Engine data path automatically
	 --> Execute TCL command : launch_simulation -scripts_only ,to establish the sim_1 source set hierarchy after successful design creation." [get_bd_designs $design_name]

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
xilinx.com:ip:ps_wizard:1.0\
xilinx.com:ip:axi_noc2:1.1\
xilinx.com:ip:util_ds_buf:2.2\
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
  set ch0_lpddr5_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 ch0_lpddr5_c0 ]

  set ch1_lpddr5_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 ch1_lpddr5_c0 ]

  set ch0_lpddr5_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 ch0_lpddr5_c1 ]

  set ch1_lpddr5_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 ch1_lpddr5_c1 ]

  set lpddr5_c2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 lpddr5_c2 ]

  set lpddr5_c3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr5_rtl:1.0 lpddr5_c3 ]

  set lpddr5_clk0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr5_clk0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {320000000} \
   ] $lpddr5_clk0

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

  set S00_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S00_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S00_AXIS_0

  set M00_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M00_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M00_AXIS_0

  set S01_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S01_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S01_AXIS_0

  set M01_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M01_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M01_AXIS_0

  set S02_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S02_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S02_AXIS_0

  set M02_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M02_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M02_AXIS_0

  set S03_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S03_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S03_AXIS_0

  set M03_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M03_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M03_AXIS_0

  set S04_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S04_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S04_AXIS_0

  set M04_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M04_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M04_AXIS_0

  set S05_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S05_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S05_AXIS_0

  set M05_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M05_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M05_AXIS_0

  set S06_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S06_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S06_AXIS_0

  set M06_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M06_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M06_AXIS_0

  set S07_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S07_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S07_AXIS_0

  set M07_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M07_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M07_AXIS_0

  set S08_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S08_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S08_AXIS_0

  set M08_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M08_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M08_AXIS_0

  set S09_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S09_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S09_AXIS_0

  set M09_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M09_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M09_AXIS_0

  set S10_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S10_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S10_AXIS_0

  set M10_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M10_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M10_AXIS_0

  set S11_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S11_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S11_AXIS_0

  set M11_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M11_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M11_AXIS_0

  set S12_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S12_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S12_AXIS_0

  set M12_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M12_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M12_AXIS_0

  set S13_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S13_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S13_AXIS_0

  set M13_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M13_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M13_AXIS_0

  set S14_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S14_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S14_AXIS_0

  set M14_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M14_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M14_AXIS_0

  set S15_AXIS_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S15_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S15_AXIS_0

  set M15_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M15_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $M15_AXIS_0


  # Create ports
  set dmaIrq [ create_bd_port -dir I -type intr dmaIrq ]
  set dmaClk [ create_bd_port -dir I -type clk -freq_hz 250000000 dmaClk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {dma:dmaCtrl:axiLite} \
 ] $dmaClk
  set plClk [ create_bd_port -dir O -type clk plClk ]
  set plRstL [ create_bd_port -dir O -type rst plRstL ]
  set aieClk [ create_bd_port -dir I -type clk -freq_hz 250000000 aieClk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS_0:M15_AXIS_0:M14_AXIS_0:M13_AXIS_0:M12_AXIS_0:M11_AXIS_0:M10_AXIS_0:M09_AXIS_0:M08_AXIS_0:M07_AXIS_0:M06_AXIS_0:M05_AXIS_0:M04_AXIS_0:M03_AXIS_0:M02_AXIS_0:M01_AXIS_0:S00_AXIS_0:S01_AXIS_0:S02_AXIS_0:S03_AXIS_0:S04_AXIS_0:S05_AXIS_0:S06_AXIS_0:S07_AXIS_0:S08_AXIS_0:S09_AXIS_0:S10_AXIS_0:S11_AXIS_0:S12_AXIS_0:S13_AXIS_0:S14_AXIS_0:S15_AXIS_0} \
 ] $aieClk

  # Create instance: ps_wizard_0, and set properties
  set ps_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ps_wizard:1.0 ps_wizard_0 ]
  set_property -dict [list \
    CONFIG.PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_HSM1_REF_CTRL_FREQMHZ) {200} \
    CONFIG.PS_PMC_CONFIG(PMC_CRP_PL0_REF_CTRL_FREQMHZ) {250} \
    CONFIG.PS_PMC_CONFIG(PMC_HSM1_CLK_OUT_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO0) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO1) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO10) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO12) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO2) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO3) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO36) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO4) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO5) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO6) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO7) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO8) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_MIO9) {DRIVE_STRENGTH 12mA SLEW slow PULL pullup SCHMITT 1 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION inout} \
    CONFIG.PS_PMC_CONFIG(PMC_OSPI_PERIPHERAL) {PRIMARY_ENABLE 1 SECONDARY_ENABLE 0 IO PMC_MIO_0:13 MODE Single} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30AD) {CD_ENABLE 0 POW_ENABLE 0 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_24 POW_IO PMC_MIO_17 WP_IO PMC_MIO_25 RESET_IO PMC_MIO_17 CLK_50_SDR_ITAP_DLY 0x00 CLK_50_SDR_OTAP_DLY\
0x00 CLK_50_DDR_ITAP_DLY 0x00 CLK_50_DDR_OTAP_DLY 0x00 CLK_100_SDR_OTAP_DLY 0x00 CLK_200_SDR_OTAP_DLY 0x00} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30AD_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD0_30_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 0 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30AD) {CD_ENABLE 1 POW_ENABLE 1 WP_ENABLE 0 RESET_ENABLE 0 CD_IO PMC_MIO_28 POW_IO PMC_MIO_51 WP_IO PMC_MIO_1 RESET_IO PMC_MIO_12 CLK_50_SDR_ITAP_DLY 0x25 CLK_50_SDR_OTAP_DLY\
0x4 CLK_50_DDR_ITAP_DLY 0x2A CLK_50_DDR_OTAP_DLY 0x3 CLK_100_SDR_OTAP_DLY 0x3 CLK_200_SDR_OTAP_DLY 0x2} \
    CONFIG.PS_PMC_CONFIG(PMC_SD1_30AD_PERIPHERAL) {PRIMARY_ENABLE 0 SECONDARY_ENABLE 1 IO PMC_MIO_26:36 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PMC_USE_PMC_AXI_NOC0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_ENET0_MDIO) {ENABLE 1 IO PS_MIO_24:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_ENET0_PERIPHERAL) {ENABLE 1 IO PS_MIO_0:11 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_FPD_AXI_PL_DATA_WIDTH) {32} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI0_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI1_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI1_MASTER) {R5_0} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI2_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI2_MASTER) {R5_1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI3_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI4_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI5_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_GEN_IPI6_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_I2C0_PERIPHERAL) {ENABLE 1 IO PMC_MIO_46:47 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_I2C1_PERIPHERAL) {ENABLE 1 IO PMC_MIO_44:45 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_I2CSYSMON_PERIPHERAL) {ENABLE 0 IO_TYPE MIO IO PS_MIO_13:14} \
    CONFIG.PS_PMC_CONFIG(PS_IRQ_USAGE) {CH0 1 CH1 0 CH2 0 CH3 0 CH4 0 CH5 0 CH6 0 CH7 0 CH8 0 CH9 0 CH10 0 CH11 0 CH12 0 CH13 0 CH14 0 CH15 0} \
    CONFIG.PS_PMC_CONFIG(PS_LPD_AXI_PL_DATA_WIDTH) {32} \
    CONFIG.PS_PMC_CONFIG(PS_MIO11) {DRIVE_STRENGTH 8mA SLEW slow PULL disable SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO12) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PS_MIO15) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO16) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION out} \
    CONFIG.PS_PMC_CONFIG(PS_MIO21) {DRIVE_STRENGTH 8mA SLEW slow PULL pullup SCHMITT 0 AUX_IO 0 USAGE GPIO OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO22) {DRIVE_STRENGTH 8mA SLEW slow PULL pulldown SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO7) {DRIVE_STRENGTH 8mA SLEW slow PULL disable SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_MIO9) {DRIVE_STRENGTH 8mA SLEW slow PULL disable SCHMITT 0 AUX_IO 0 USAGE Reserved OUTPUT_DATA default DIRECTION in} \
    CONFIG.PS_PMC_CONFIG(PS_NUM_FABRIC_RESETS) {1} \
    CONFIG.PS_PMC_CONFIG(PS_SLR_ID) {0} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_CLK) {ENABLE 1 IO PS_MIO_22 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC0_WAVEOUT) {ENABLE 1 IO PS_MIO_23 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_TTC1_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC2_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_TTC3_PERIPHERAL_ENABLE) {1} \
    CONFIG.PS_PMC_CONFIG(PS_UART0_PERIPHERAL) {ENABLE 1 IO PMC_MIO_42:43 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_UART1_PERIPHERAL) {ENABLE 1 IO PMC_MIO_38:39 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_USB3_PERIPHERAL) {ENABLE 1 IO PMC_MIO_13:25 IO_TYPE MIO} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_NOC0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_NOC1) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_AXI_PL) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_FPD_CCI_NOC) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_LPD_AXI_NOC0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_LPD_AXI_PL) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PL_AXI_FPD0) {1} \
    CONFIG.PS_PMC_CONFIG(PS_USE_PMCPL_CLK0) {1} \
    CONFIG.PS_PMC_CONFIG(SMON_INTERFACE_TO_USE) {I2C} \
    CONFIG.PS_PMC_CONFIG(SMON_PMBUS_ADDRESS) {0x18} \
  ] $ps_wizard_0


  # Create instance: Master_NoC, and set properties
  set Master_NoC [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 Master_NoC ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {8} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {8} \
    CONFIG.NUM_SI {8} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $Master_NoC


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M02_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M04_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M05_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M06_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $Master_NoC/M07_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $Master_NoC/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M01_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $Master_NoC/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true}} M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $Master_NoC/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M03_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins $Master_NoC/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins $Master_NoC/S04_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins $Master_NoC/S05_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins $Master_NoC/S06_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins $Master_NoC/S07_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $Master_NoC/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins $Master_NoC/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins $Master_NoC/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins $Master_NoC/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins $Master_NoC/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins $Master_NoC/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S06_AXI} \
 ] [get_bd_pins $Master_NoC/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S07_AXI} \
 ] [get_bd_pins $Master_NoC/aclk7]

  # Create instance: NoC_C0, and set properties
  set NoC_C0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 NoC_C0 ]
  set_property -dict [list \
    CONFIG.C0_CH0_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C0_CH0_Bank_700_701_702} \
    CONFIG.C0_CH1_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C0_CH1_Bank_700_701_702} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ADDRESS_MAP) {NA,NA,NA,NA,NA,NA,NA,NA,RA15,RA14,RA13,RA12,RA11,RA10,RA9,RA8,RA7,RA6,RA5,RA4,RA3,RA2,RA1,RA0,BA1,BA0,BG1,BG0,CA5,CA4,CA3,CA2,NC,CA1,CA0,NC,NC,NC,NC,NA} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_AUTO_PRECHARGE) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BACKGROUND_SCRUB) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BOARD_INTRF_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BURST_ADDR_WIDTH) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_COL_ADDR_WIDTH) {6} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CONTROLLERTYPE) {LPDDR5_SDRAM} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CRYPTO) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DATA_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_2T) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TFAW_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_SLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFCSB_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DM_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DQS_OSCI_EN) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_SIZE) {16Gb} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_WIDTH) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_EXTENDED_DDRMC5E) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TCSPD) {10938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCK) {1087} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TCSPD) {10938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCK) {938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_FREQ_SWITCHING) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INLINE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INPUTCLK0_PERIOD) {3125} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INTERLEAVE_SIZE) {128} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LATENCY_MODE) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LOW_TRFC_DPR) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2ACT) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2PBR) {90000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCPB) {140000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMPB) {190000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_X64_EN) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MAIN_DEVICE_TYPE) {Components} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC0_CONFIG_SEL) {config9} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC1_CONFIG_SEL) {config9} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MEMORY_DENSITY) {2GB} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CH) {2} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CK) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MC) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MCP) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_RANKS) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ON_DIE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_OP_TEMPERATURE) {LOW} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PERIODIC_READ) {ENABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PRE_DEF_ADDR_MAP_SEL) {ROW_BANK_COLUMN} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_RD_DBI) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_MODE) {NORMAL} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_TYPE) {ALL_BANK} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REF_AND_PER_CAL_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ROW_ADDR_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SCRUB_SIZE) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SELF_REFRESH) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SPEED_GRADE) {LPDDR5X-7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SYSTEM_CLOCK) {No_Buffer} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_TREFI) {3906000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_UBLAZE_BLI_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_USER_REFRESH) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WL_SET) {A} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WR_DBI) {true} \
    CONFIG.MC_CHAN_REGION1 {DDR_CH0_MED} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {5} \
    CONFIG.NUM_SI {0} \
  ] $NoC_C0


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C0/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C0/S01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C0/S02_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C0/S03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C0/S04_INI]

  # Create instance: NoC_C1, and set properties
  set NoC_C1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 NoC_C1 ]
  set_property -dict [list \
    CONFIG.C0_CH0_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C1_CH0_Bank_703_704_705} \
    CONFIG.C0_CH1_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C1_CH1_Bank_703_704_705} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ADDRESS_MAP) {NA,NA,NA,NA,NA,NA,NA,NA,RA15,RA14,RA13,RA12,RA11,RA10,RA9,RA8,RA7,RA6,RA5,RA4,RA3,RA2,RA1,RA0,BA1,BA0,BG1,BG0,CA5,CA4,CA3,CA2,NC,CA1,CA0,NC,NC,NC,NC,NA} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_AUTO_PRECHARGE) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BACKGROUND_SCRUB) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BOARD_INTRF_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BURST_ADDR_WIDTH) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_COL_ADDR_WIDTH) {6} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CONTROLLERTYPE) {LPDDR5_SDRAM} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CRYPTO) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DATA_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_2T) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TFAW_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_SLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFCSB_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DM_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DQS_OSCI_EN) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_SIZE) {16Gb} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_WIDTH) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_EXTENDED_DDRMC5E) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TCSPD) {10938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCK) {1087} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TCSPD) {10938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCK) {938} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_FREQ_SWITCHING) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INLINE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INPUTCLK0_PERIOD) {3125} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INTERLEAVE_SIZE) {128} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LATENCY_MODE) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LOW_TRFC_DPR) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2ACT) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2PBR) {90000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCPB) {140000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMPB) {190000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_X64_EN) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MAIN_DEVICE_TYPE) {Components} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC0_CONFIG_SEL) {config9} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC1_CONFIG_SEL) {config9} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MEMORY_DENSITY) {2GB} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CH) {2} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CK) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MC) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MCP) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_RANKS) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ON_DIE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_OP_TEMPERATURE) {LOW} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PERIODIC_READ) {ENABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PRE_DEF_ADDR_MAP_SEL) {ROW_BANK_COLUMN} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_RD_DBI) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_MODE) {NORMAL} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_TYPE) {ALL_BANK} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REF_AND_PER_CAL_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ROW_ADDR_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SCRUB_SIZE) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SELF_REFRESH) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SPEED_GRADE) {LPDDR5X-7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SYSTEM_CLOCK) {No_Buffer} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_TREFI) {3906000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_UBLAZE_BLI_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_USER_REFRESH) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WL_SET) {A} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WR_DBI) {true} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH1} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {3} \
    CONFIG.NUM_SI {0} \
  ] $NoC_C1


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C1/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C1/S01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C1/S02_INI]

  # Create instance: NoC_C2, and set properties
  set NoC_C2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 NoC_C2 ]
  set_property -dict [list \
    CONFIG.C0_CH0_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C2_Bank_706_707_int} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ADDRESS_MAP) {NA,NA,NA,NA,NA,NA,NA,NA,RA15,RA14,RA13,RA12,RA11,RA10,RA9,RA8,RA7,RA6,RA5,RA4,RA3,RA2,RA1,RA0,BA1,BA0,BG1,BG0,CA5,CA4,CA3,CA2,CA1,CA0,NC,NC,NC,NC,NA,NA} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_AUTO_PRECHARGE) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BACKGROUND_SCRUB) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BOARD_INTRF_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BURST_ADDR_WIDTH) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_COL_ADDR_WIDTH) {6} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CONTROLLERTYPE) {LPDDR5_SDRAM} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CRYPTO) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DATA_WIDTH) {32} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_2T) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TFAW_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_SLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFCSB_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DM_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DQS_OSCI_EN) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_SIZE) {16Gb} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_WIDTH) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_EXTENDED_DDRMC5E) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TCSPD) {10952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCK) {1081} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TCSPD) {10952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCK) {952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_FREQ_SWITCHING) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INLINE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INPUTCLK0_PERIOD) {5000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INTERLEAVE_SIZE) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LATENCY_MODE) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LOW_TRFC_DPR) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2ACT) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2PBR) {90000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCPB) {140000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMPB) {190000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_X64_EN) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MAIN_DEVICE_TYPE) {Components} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC0_CONFIG_SEL) {config13} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC3_CONFIG_SEL) {config13} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MEMORY_DENSITY) {4GB} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CH) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CK) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MC) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MCP) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_RANKS) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ON_DIE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_OP_TEMPERATURE) {LOW} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PERIODIC_READ) {ENABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PRE_DEF_ADDR_MAP_SEL) {ROW_BANK_COLUMN} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_RD_DBI) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_MODE) {NORMAL} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_TYPE) {ALL_BANK} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REF_AND_PER_CAL_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ROW_ADDR_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SCRUB_SIZE) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SELF_REFRESH) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SPEED_GRADE) {LPDDR5X-7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SYSTEM_CLOCK) {Internal} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_TREFI) {3906000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_UBLAZE_BLI_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_USER_REFRESH) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WL_SET) {A} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WR_DBI) {true} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH2} \
    CONFIG.NUM_MCP {2} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {3} \
    CONFIG.NUM_SI {0} \
  ] $NoC_C2


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C2/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C2/S01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C2/S02_INI]

  # Create instance: NoC_C3, and set properties
  set NoC_C3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 NoC_C3 ]
  set_property -dict [list \
    CONFIG.C0_CH0_LPDDR5_BOARD_INTERFACE {Lpddr5_Controller_C3_Bank_709_710_int} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ADDRESS_MAP) {NA,NA,NA,NA,NA,NA,NA,NA,RA15,RA14,RA13,RA12,RA11,RA10,RA9,RA8,RA7,RA6,RA5,RA4,RA3,RA2,RA1,RA0,BA1,BA0,BG1,BG0,CA5,CA4,CA3,CA2,CA1,CA0,NC,NC,NC,NC,NA,NA} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_AUTO_PRECHARGE) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BACKGROUND_SCRUB) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BOARD_INTRF_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_BURST_ADDR_WIDTH) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_COL_ADDR_WIDTH) {6} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CONTROLLERTYPE) {LPDDR5_SDRAM} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_CRYPTO) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DATA_WIDTH) {32} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_2T) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TFAW_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TREFSBRD_SLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC1_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFC2_DPR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DDR5_TRFCSB_DLR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DM_EN) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DQS_OSCI_EN) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_SIZE) {16Gb} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_DRAM_WIDTH) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_EXTENDED_DDRMC5E) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TCSPD) {10952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TCK) {1081} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F0_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_CL) {64} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TCCD_L_WR2) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TPD) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRP) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_DDR5_TRRD_L) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_BANK_ARCH) {BG} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TCSPD) {10952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPAB) {21000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRPPB) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_LP5_TRRD) {3750} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_RL) {25} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCCD_L) {4} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TCK) {952} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TFAW) {15000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRAS) {42000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRCD) {18000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TRTP) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TXP) {7000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_TZQLAT) {30000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_F1_WL) {12} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_FREQ_SWITCHING) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INLINE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INPUTCLK0_PERIOD) {5000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_INTERLEAVE_SIZE) {0} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LATENCY_MODE) {x16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LOW_TRFC_DPR) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2ACT) {7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TPBR2PBR) {90000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFCPB) {140000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMAB) {280000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_TRFMPB) {190000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_LP5_X64_EN) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MAIN_DEVICE_TYPE) {Components} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC0_CONFIG_SEL) {config13} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MC3_CONFIG_SEL) {config13} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_MEMORY_DENSITY) {4GB} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CH) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_CK) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MC) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_MCP) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_NUM_RANKS) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ON_DIE_ECC) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_OP_TEMPERATURE) {LOW} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PERIODIC_READ) {ENABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_PRE_DEF_ADDR_MAP_SEL) {ROW_BANK_COLUMN} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_RD_DBI) {true} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_MODE) {NORMAL} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REFRESH_TYPE) {ALL_BANK} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_REF_AND_PER_CAL_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_ROW_ADDR_WIDTH) {16} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SCRUB_SIZE) {1} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SELF_REFRESH) {DISABLE} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SPEED_GRADE) {LPDDR5X-7500} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_SYSTEM_CLOCK) {Internal} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_TREFI) {3906000} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_UBLAZE_BLI_INTF) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_USER_REFRESH) {false} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WL_SET) {A} \
    CONFIG.DDRMC5_CONFIG(DDRMC5_WR_DBI) {true} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH3} \
    CONFIG.NUM_MCP {2} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {3} \
    CONFIG.NUM_SI {0} \
  ] $NoC_C3


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C3/S00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C3/S01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $NoC_C3/S02_INI]

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf_0 ]
  set_property -dict [list \
    CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {lpddr5_clk0_1} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $util_ds_buf_0


  # Create instance: aggr_noc, and set properties
  set aggr_noc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 aggr_noc ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {7} \
    CONFIG.NUM_SI {0} \
  ] $aggr_noc


  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M01_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M02_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M04_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M05_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins $aggr_noc/M06_INI]

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine:2.0 ai_engine_0 ]
  set_property -dict [list \
    CONFIG.CLK_NAMES {aclk0} \
    CONFIG.NAME_MI_AXIS {M00_AXIS,M01_AXIS,M02_AXIS,M03_AXIS,M04_AXIS,M05_AXIS,M06_AXIS,M07_AXIS,M08_AXIS,M09_AXIS,M10_AXIS,M11_AXIS,M12_AXIS,M13_AXIS,M14_AXIS,M15_AXIS,} \
    CONFIG.NAME_SI_AXIS {S00_AXIS,S01_AXIS,S02_AXIS,S03_AXIS,S04_AXIS,S05_AXIS,S06_AXIS,S07_AXIS,S08_AXIS,S09_AXIS,S10_AXIS,S11_AXIS,S12_AXIS,S13_AXIS,S14_AXIS,S15_AXIS,} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI_AXIS {16} \
    CONFIG.NUM_SI_AXIS {16} \
  ] $ai_engine_0


  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M00_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M01_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M02_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M03_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M04_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M05_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M06_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M07_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M08_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M09_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M10_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M11_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M12_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M13_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M14_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/M15_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins $ai_engine_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S00_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S01_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S02_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S03_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S04_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S05_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S06_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S07_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S08_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S09_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S10_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S11_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S12_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S13_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S14_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins $ai_engine_0/S15_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS:M01_AXIS:M02_AXIS:M03_AXIS:M04_AXIS:M05_AXIS:M06_AXIS:M07_AXIS:M08_AXIS:M09_AXIS:M10_AXIS:M11_AXIS:M12_AXIS:M13_AXIS:M14_AXIS:M15_AXIS:S00_AXIS:S01_AXIS:S02_AXIS:S03_AXIS:S04_AXIS:S05_AXIS:S06_AXIS:S07_AXIS:S08_AXIS:S09_AXIS:S10_AXIS:S11_AXIS:S12_AXIS:S13_AXIS:S14_AXIS:S15_AXIS} \
 ] [get_bd_pins $ai_engine_0/aclk0]

  # Create instance: ConfigNoc, and set properties
  set ConfigNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 ConfigNoc ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $ConfigNoc


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CATEGORY {aie} \
 ] [get_bd_intf_pins $ConfigNoc/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $ConfigNoc/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $ConfigNoc/aclk0]

  # Create interface connections
  connect_bd_intf_net -intf_net ConfigNoc_M00_AXI [get_bd_intf_pins ConfigNoc/M00_AXI] [get_bd_intf_pins ai_engine_0/S00_AXI]
  connect_bd_intf_net -intf_net Master_NoC_M00_INI [get_bd_intf_pins Master_NoC/M00_INI] [get_bd_intf_pins NoC_C0/S00_INI]
  connect_bd_intf_net -intf_net Master_NoC_M01_INI [get_bd_intf_pins Master_NoC/M01_INI] [get_bd_intf_pins NoC_C0/S01_INI]
  connect_bd_intf_net -intf_net Master_NoC_M02_INI [get_bd_intf_pins Master_NoC/M02_INI] [get_bd_intf_pins NoC_C0/S02_INI]
  connect_bd_intf_net -intf_net Master_NoC_M03_INI [get_bd_intf_pins Master_NoC/M03_INI] [get_bd_intf_pins NoC_C0/S03_INI]
  connect_bd_intf_net -intf_net Master_NoC_M04_INI [get_bd_intf_pins NoC_C1/S00_INI] [get_bd_intf_pins Master_NoC/M04_INI]
  connect_bd_intf_net -intf_net Master_NoC_M05_INI [get_bd_intf_pins NoC_C2/S00_INI] [get_bd_intf_pins Master_NoC/M05_INI]
  connect_bd_intf_net -intf_net Master_NoC_M06_INI [get_bd_intf_pins NoC_C3/S00_INI] [get_bd_intf_pins Master_NoC/M06_INI]
  connect_bd_intf_net -intf_net Master_NoC_M07_INI [get_bd_intf_pins ConfigNoc/S00_INI] [get_bd_intf_pins Master_NoC/M07_INI]
  connect_bd_intf_net -intf_net NoC_C0_C0_CH0_LPDDR5 [get_bd_intf_ports ch0_lpddr5_c0] [get_bd_intf_pins NoC_C0/C0_CH0_LPDDR5]
  connect_bd_intf_net -intf_net NoC_C0_C0_CH1_LPDDR5 [get_bd_intf_ports ch1_lpddr5_c0] [get_bd_intf_pins NoC_C0/C0_CH1_LPDDR5]
  connect_bd_intf_net -intf_net NoC_C1_C0_CH0_LPDDR5 [get_bd_intf_ports ch0_lpddr5_c1] [get_bd_intf_pins NoC_C1/C0_CH0_LPDDR5]
  connect_bd_intf_net -intf_net NoC_C1_C0_CH1_LPDDR5 [get_bd_intf_ports ch1_lpddr5_c1] [get_bd_intf_pins NoC_C1/C0_CH1_LPDDR5]
  connect_bd_intf_net -intf_net NoC_C2_C0_CH0_LPDDR5 [get_bd_intf_ports lpddr5_c2] [get_bd_intf_pins NoC_C2/C0_CH0_LPDDR5]
  connect_bd_intf_net -intf_net NoC_C3_C0_CH0_LPDDR5 [get_bd_intf_ports lpddr5_c3] [get_bd_intf_pins NoC_C3/C0_CH0_LPDDR5]
  connect_bd_intf_net -intf_net S00_AXIS_0_1 [get_bd_intf_ports S00_AXIS_0] [get_bd_intf_pins ai_engine_0/S00_AXIS]
  connect_bd_intf_net -intf_net S01_AXIS_0_1 [get_bd_intf_ports S01_AXIS_0] [get_bd_intf_pins ai_engine_0/S01_AXIS]
  connect_bd_intf_net -intf_net S02_AXIS_0_1 [get_bd_intf_ports S02_AXIS_0] [get_bd_intf_pins ai_engine_0/S02_AXIS]
  connect_bd_intf_net -intf_net S03_AXIS_0_1 [get_bd_intf_ports S03_AXIS_0] [get_bd_intf_pins ai_engine_0/S03_AXIS]
  connect_bd_intf_net -intf_net S04_AXIS_0_1 [get_bd_intf_ports S04_AXIS_0] [get_bd_intf_pins ai_engine_0/S04_AXIS]
  connect_bd_intf_net -intf_net S05_AXIS_0_1 [get_bd_intf_ports S05_AXIS_0] [get_bd_intf_pins ai_engine_0/S05_AXIS]
  connect_bd_intf_net -intf_net S06_AXIS_0_1 [get_bd_intf_ports S06_AXIS_0] [get_bd_intf_pins ai_engine_0/S06_AXIS]
  connect_bd_intf_net -intf_net S07_AXIS_0_1 [get_bd_intf_ports S07_AXIS_0] [get_bd_intf_pins ai_engine_0/S07_AXIS]
  connect_bd_intf_net -intf_net S08_AXIS_0_1 [get_bd_intf_ports S08_AXIS_0] [get_bd_intf_pins ai_engine_0/S08_AXIS]
  connect_bd_intf_net -intf_net S09_AXIS_0_1 [get_bd_intf_ports S09_AXIS_0] [get_bd_intf_pins ai_engine_0/S09_AXIS]
  connect_bd_intf_net -intf_net S10_AXIS_0_1 [get_bd_intf_ports S10_AXIS_0] [get_bd_intf_pins ai_engine_0/S10_AXIS]
  connect_bd_intf_net -intf_net S11_AXIS_0_1 [get_bd_intf_ports S11_AXIS_0] [get_bd_intf_pins ai_engine_0/S11_AXIS]
  connect_bd_intf_net -intf_net S12_AXIS_0_1 [get_bd_intf_ports S12_AXIS_0] [get_bd_intf_pins ai_engine_0/S12_AXIS]
  connect_bd_intf_net -intf_net S13_AXIS_0_1 [get_bd_intf_ports S13_AXIS_0] [get_bd_intf_pins ai_engine_0/S13_AXIS]
  connect_bd_intf_net -intf_net S14_AXIS_0_1 [get_bd_intf_ports S14_AXIS_0] [get_bd_intf_pins ai_engine_0/S14_AXIS]
  connect_bd_intf_net -intf_net S15_AXIS_0_1 [get_bd_intf_ports S15_AXIS_0] [get_bd_intf_pins ai_engine_0/S15_AXIS]
  connect_bd_intf_net -intf_net aggr_noc_M00_INI [get_bd_intf_pins aggr_noc/M00_INI] [get_bd_intf_pins NoC_C0/S04_INI]
  connect_bd_intf_net -intf_net aggr_noc_M01_INI [get_bd_intf_pins aggr_noc/M01_INI] [get_bd_intf_pins NoC_C1/S01_INI]
  connect_bd_intf_net -intf_net aggr_noc_M02_INI [get_bd_intf_pins aggr_noc/M02_INI] [get_bd_intf_pins NoC_C1/S02_INI]
  connect_bd_intf_net -intf_net aggr_noc_M03_INI [get_bd_intf_pins aggr_noc/M03_INI] [get_bd_intf_pins NoC_C2/S01_INI]
  connect_bd_intf_net -intf_net aggr_noc_M04_INI [get_bd_intf_pins aggr_noc/M04_INI] [get_bd_intf_pins NoC_C2/S02_INI]
  connect_bd_intf_net -intf_net aggr_noc_M05_INI [get_bd_intf_pins aggr_noc/M05_INI] [get_bd_intf_pins NoC_C3/S01_INI]
  connect_bd_intf_net -intf_net aggr_noc_M06_INI [get_bd_intf_pins aggr_noc/M06_INI] [get_bd_intf_pins NoC_C3/S02_INI]
  connect_bd_intf_net -intf_net ai_engine_0_M00_AXIS [get_bd_intf_pins ai_engine_0/M00_AXIS] [get_bd_intf_ports M00_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M01_AXIS [get_bd_intf_pins ai_engine_0/M01_AXIS] [get_bd_intf_ports M01_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M02_AXIS [get_bd_intf_pins ai_engine_0/M02_AXIS] [get_bd_intf_ports M02_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M03_AXIS [get_bd_intf_pins ai_engine_0/M03_AXIS] [get_bd_intf_ports M03_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M04_AXIS [get_bd_intf_pins ai_engine_0/M04_AXIS] [get_bd_intf_ports M04_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M05_AXIS [get_bd_intf_pins ai_engine_0/M05_AXIS] [get_bd_intf_ports M05_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M06_AXIS [get_bd_intf_pins ai_engine_0/M06_AXIS] [get_bd_intf_ports M06_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M07_AXIS [get_bd_intf_pins ai_engine_0/M07_AXIS] [get_bd_intf_ports M07_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M08_AXIS [get_bd_intf_pins ai_engine_0/M08_AXIS] [get_bd_intf_ports M08_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M09_AXIS [get_bd_intf_pins ai_engine_0/M09_AXIS] [get_bd_intf_ports M09_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M10_AXIS [get_bd_intf_pins ai_engine_0/M10_AXIS] [get_bd_intf_ports M10_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M11_AXIS [get_bd_intf_pins ai_engine_0/M11_AXIS] [get_bd_intf_ports M11_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M12_AXIS [get_bd_intf_pins ai_engine_0/M12_AXIS] [get_bd_intf_ports M12_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M13_AXIS [get_bd_intf_pins ai_engine_0/M13_AXIS] [get_bd_intf_ports M13_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M14_AXIS [get_bd_intf_pins ai_engine_0/M14_AXIS] [get_bd_intf_ports M14_AXIS_0]
  connect_bd_intf_net -intf_net ai_engine_0_M15_AXIS [get_bd_intf_pins ai_engine_0/M15_AXIS] [get_bd_intf_ports M15_AXIS_0]
  connect_bd_intf_net -intf_net dma_1 [get_bd_intf_ports dma] [get_bd_intf_pins ps_wizard_0/PL_AXI_FPD0]
  connect_bd_intf_net -intf_net lpddr5_clk0_1_1 [get_bd_intf_ports lpddr5_clk0] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_AXI_NOC0 [get_bd_intf_pins ps_wizard_0/FPD_AXI_NOC0] [get_bd_intf_pins Master_NoC/S04_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_AXI_NOC1 [get_bd_intf_pins ps_wizard_0/FPD_AXI_NOC1] [get_bd_intf_pins Master_NoC/S05_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_AXI_PL [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL] [get_bd_intf_ports axiLite]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC0 [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC0] [get_bd_intf_pins Master_NoC/S00_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC1 [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC1] [get_bd_intf_pins Master_NoC/S01_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC2 [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC2] [get_bd_intf_pins Master_NoC/S02_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_FPD_CCI_NOC3 [get_bd_intf_pins ps_wizard_0/FPD_CCI_NOC3] [get_bd_intf_pins Master_NoC/S03_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_LPD_AXI_NOC0 [get_bd_intf_pins ps_wizard_0/LPD_AXI_NOC0] [get_bd_intf_pins Master_NoC/S06_AXI]
  connect_bd_intf_net -intf_net ps_wizard_0_LPD_AXI_PL [get_bd_intf_pins ps_wizard_0/LPD_AXI_PL] [get_bd_intf_ports dmaCtrl]
  connect_bd_intf_net -intf_net ps_wizard_0_PMC_AXI_NOC0 [get_bd_intf_pins ps_wizard_0/PMC_AXI_NOC0] [get_bd_intf_pins Master_NoC/S07_AXI]

  # Create port connections
  connect_bd_net -net ai_engine_0_s00_axi_aclk  [get_bd_pins ai_engine_0/s00_axi_aclk] \
  [get_bd_pins ConfigNoc/aclk0]
  connect_bd_net -net aieClk_1  [get_bd_ports aieClk] \
  [get_bd_pins ai_engine_0/aclk0]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_ports dmaClk] \
  [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk] \
  [get_bd_pins ps_wizard_0/lpd_axi_pl_aclk] \
  [get_bd_pins ps_wizard_0/pl_axi_fpd0_aclk]
  connect_bd_net -net dmaIrq_1  [get_bd_ports dmaIrq] \
  [get_bd_pins ps_wizard_0/pl_ps_irq0]
  connect_bd_net -net ps_wizard_0_fpd_axi_noc0_clk  [get_bd_pins ps_wizard_0/fpd_axi_noc0_clk] \
  [get_bd_pins Master_NoC/aclk4]
  connect_bd_net -net ps_wizard_0_fpd_axi_noc1_clk  [get_bd_pins ps_wizard_0/fpd_axi_noc1_clk] \
  [get_bd_pins Master_NoC/aclk5]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc0_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc0_clk] \
  [get_bd_pins Master_NoC/aclk0]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc1_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc1_clk] \
  [get_bd_pins Master_NoC/aclk1]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc2_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc2_clk] \
  [get_bd_pins Master_NoC/aclk2]
  connect_bd_net -net ps_wizard_0_fpd_cci_noc3_clk  [get_bd_pins ps_wizard_0/fpd_cci_noc3_clk] \
  [get_bd_pins Master_NoC/aclk3]
  connect_bd_net -net ps_wizard_0_hsm1_ref_clk  [get_bd_pins ps_wizard_0/hsm1_ref_clk] \
  [get_bd_pins NoC_C2/sys_clk0] \
  [get_bd_pins NoC_C3/sys_clk0]
  connect_bd_net -net ps_wizard_0_lpd_axi_noc0_clk  [get_bd_pins ps_wizard_0/lpd_axi_noc0_clk] \
  [get_bd_pins Master_NoC/aclk6]
  connect_bd_net -net ps_wizard_0_pl0_ref_clk  [get_bd_pins ps_wizard_0/pl0_ref_clk] \
  [get_bd_ports plClk]
  connect_bd_net -net ps_wizard_0_pl0_resetn  [get_bd_pins ps_wizard_0/pl0_resetn] \
  [get_bd_ports plRstL]
  connect_bd_net -net ps_wizard_0_pmc_axi_noc0_clk  [get_bd_pins ps_wizard_0/pmc_axi_noc0_clk] \
  [get_bd_pins Master_NoC/aclk7]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT  [get_bd_pins util_ds_buf_0/IBUF_OUT] \
  [get_bd_pins NoC_C0/sys_clk0] \
  [get_bd_pins NoC_C1/sys_clk0]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2] -force
  assign_bd_address -offset 0x070000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs axiLite/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_0] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2] -force
  assign_bd_address -offset 0x070000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs axiLite/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexa72_1] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2] -force
  assign_bd_address -offset 0x070000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs axiLite/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_dpc_0] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x000800000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED] -force
  assign_bd_address -offset 0x050000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2] -force
  assign_bd_address -offset 0x070000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs axiLite/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_pmc_0] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_LEGACY] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs dmaCtrl/Reg] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH0/pmcps_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH1/pmcps_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH2/pmcps_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH3/pmcps_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH4/pmcps_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH5/pmcps_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH6/pmcps_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ADMA_CH7/pmcps_0_psv_adma_7] -force
  assign_bd_address -offset 0xF0800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_PMC_ROM_INT/pmcps_0_psv_coresight_0] -force
  assign_bd_address -offset 0xF0D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A720_CTI_INT/pmcps_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0xF0D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A720_DBG_INT/pmcps_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0xF0D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A720_ETM_INT/pmcps_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0xF0D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A720_PMU_INT/pmcps_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0xF0D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A721_CTI_INT/pmcps_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0xF0D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A721_DBG_INT/pmcps_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0xF0D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A721_ETM_INT/pmcps_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0xF0D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_A721_PMU_INT/pmcps_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0xF0CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_APU_CTI_INT/pmcps_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0xF0C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_APU_ELA_INT/pmcps_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0xF0C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_APU_ETF_INT/pmcps_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0xF0C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_APU_FUN_INT/pmcps_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0xF0B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_FPD_ATM_INT/pmcps_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0xF0B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_FPD_STM_INT/pmcps_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0xF0980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CoreSight_LPD_ATM_INT/pmcps_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0xFD1A0000 -range 0x00140000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CRF/pmcps_0_psv_crf_0] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CRL/pmcps_0_psv_crl_0] -force
  assign_bd_address -offset 0xF1260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CRP_INT/pmcps_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_GEM0/pmcps_0_psv_ethernet_0] -force
  assign_bd_address -offset 0xFD360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_AFIFM0/pmcps_0_psv_fpd_afi_0] -force
  assign_bd_address -offset 0xFD380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_AFIFM2/pmcps_0_psv_fpd_afi_2] -force
  assign_bd_address -offset 0xFD5E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_GPCCI/pmcps_0_psv_fpd_cci_0] -force
  assign_bd_address -offset 0xFD700000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_GPV/pmcps_0_psv_fpd_gpv_0] -force
  assign_bd_address -offset 0xFD000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_MAINCCI/pmcps_0_psv_fpd_maincci_0] -force
  assign_bd_address -offset 0xFD390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_SLAVE_XMPU/pmcps_0_psv_fpd_slave_xmpu_0] -force
  assign_bd_address -offset 0xFD610000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_SLCR/pmcps_0_psv_fpd_slcr_0] -force
  assign_bd_address -offset 0xFD690000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_SLCR_SECURE/pmcps_0_psv_fpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFD5F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_SMMU/pmcps_0_psv_fpd_smmu_0] -force
  assign_bd_address -offset 0xFD800000 -range 0x00800000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_FPD_SMMUTCU/pmcps_0_psv_fpd_smmutcu_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PS_GPIO/pmcps_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PS_I2C0/pmcps_0_psv_i2c_0] -force
  assign_bd_address -offset 0xFF030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PS_I2C1/pmcps_0_psv_i2c_1] -force
  assign_bd_address -offset 0xFF330000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_0/pmcps_0_psv_ipi_0] -force
  assign_bd_address -offset 0xFF340000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_1/pmcps_0_psv_ipi_1] -force
  assign_bd_address -offset 0xFF350000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_2/pmcps_0_psv_ipi_2] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_3/pmcps_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_4/pmcps_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_5/pmcps_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_6/pmcps_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF3F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IPI_BUFFER/pmcps_0_psv_ipi_buffer] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_IPI/pmcps_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_NOBUF/pmcps_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PSM_IPI/pmcps_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_AFIFM4/pmcps_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_IOU_SECURE_SLCR/pmcps_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_IOU_SLCR/pmcps_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_SLCR/pmcps_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_SLCR_SECURE/pmcps_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_LPD_XPPU/pmcps_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_OCM/pmcps_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_OCM_MEM/pmcps_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_OCM_XMPU/pmcps_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0xF11E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_AES_INT/pmcps_0_psv_pmc_aes] -force
  assign_bd_address -offset 0xF11F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_BBRAM_CTRL_INT/pmcps_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0xF12D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CFRAME0_REG_INT/pmcps_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0xF12B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_CFU_APB_INT/pmcps_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0xF11C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_DMA0_INT/pmcps_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0xF11D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_DMA1_INT/pmcps_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0xF1250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_EFUSE_CACHE_INT/pmcps_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0xF1240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_EFUSE_CTRL_INT/pmcps_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0xF1110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_GLOBAL_INT/pmcps_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0xF1020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_GPIO_INT/pmcps_0_psv_pmc_gpio_0] -force
  assign_bd_address -offset 0xF1010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_OSPI_INT/pmcps_0_psv_pmc_ospi_0] -force
  assign_bd_address -offset 0xF0310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PPU1_MDM_HSD_INT/pmcps_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_OSPI_QSPI_FLASH/pmcps_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0xF2000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_RAM_INT/pmcps_0_psv_pmc_ram] -force
  assign_bd_address -offset 0xF6000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_RAM_NPI_INT/pmcps_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0xF1200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_ECDSA_RSA_INT/pmcps_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0xF12A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_RTC_INT/pmcps_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0xF1050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_SD1_INT/pmcps_0_psv_pmc_sd_1] -force
  assign_bd_address -offset 0xF1210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_SHA3_INT/pmcps_0_psv_pmc_sha] -force
  assign_bd_address -offset 0xF1220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_SLAVE_BOOT_INT/pmcps_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0xF2100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_SLAVE_BOOT_STREAM_INT/pmcps_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0xF1270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_SYSMON_INT/pmcps_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0xF1230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PSV_PMC_TRNG_INT/pmcps_0_psv_pmc_trng] -force
  assign_bd_address -offset 0xF12F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_XMPU_INT/pmcps_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0xF1310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_XPPU_INT/pmcps_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0xF1300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PMC_XPPU_NPI_INT/pmcps_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PSM_GLOBAL_REG/pmcps_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFC20000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_RAM_DATA/pmcps_0_psv_psm_ram_data_cntlr] -force
  assign_bd_address -offset 0xFFC00000 -range 0x00020000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_RAM_INSTR/pmcps_0_psv_psm_ram_instr_cntlr] -force
  assign_bd_address -offset 0xFFCD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PSM_TMR_INJECT/pmcps_0_psv_psm_tmr_inject_0] -force
  assign_bd_address -offset 0xFFCC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_PSM_TMR_MANAGER/pmcps_0_psv_psm_tmr_manager_0] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_R5_1_ATCM/pmcps_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_R5_1_BTCM/pmcps_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_R5_TCM_GLOBAL/pmcps_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_UART0/pmcps_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_UART1/pmcps_0_psv_sbsauart_1] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IOU_SCNTR/pmcps_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_IOU_SCNTRS/pmcps_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_TTC0/pmcps_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_TTC1/pmcps_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_TTC2/pmcps_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_TTC3/pmcps_0_psv_ttc_3] -force
  assign_bd_address -offset 0xFF9D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_USB2_REGS/pmcps_0_psv_usb_0] -force
  assign_bd_address -offset 0xFE200000 -range 0x00100000 -target_address_space [get_bd_addr_spaces dma] [get_bd_addr_segs ps_wizard_0/pmcps_0_USB_XHCI/pmcps_0_psv_usb_xhci_0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_0] [get_bd_addr_segs axiLite/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs axiLite/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_cortexr5_1] [get_bd_addr_segs dmaCtrl/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs NoC_C0/DDR_MC_PORTS/DDR_CH0_MED]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs NoC_C1/DDR_MC_PORTS/DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs NoC_C2/DDR_MC_PORTS/DDR_CH2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs NoC_C3/DDR_MC_PORTS/DDR_CH3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces ps_wizard_0/pmcps_0_psv_psm_0] [get_bd_addr_segs axiLite/Reg]


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


