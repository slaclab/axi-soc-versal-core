##############################################################################
## This file is part of 'axi-soc-versal-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-soc-versal-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
# Usage: vivado -mode batch -notrace -nojournal -source gen_vrk_bd_seed.tcl -tclargs <boardRepoDir> <boardPart> <outDir>
#   boardRepoDir : directory holding the vendored production board files (hardware/<Hw>/board_repo)
#   boardPart    : xilinx.com:vrk160_p:part0:1.0 or xilinx.com:vrk165:part0:1.0
#   outDir       : scratch directory (project, raw CED export and stripped seed are written here)
lassign $argv boardRepo boardPart outDir
file mkdir $outDir

# Production board files only (create_project snapshots board.repoPaths, so set it first)
set_param board.repoPaths [list $boardRepo]
if { ![regexp {^xilinx.com:(vrk160_p|vrk165):part0:1\.0$} $boardPart] } {
   puts "ERROR: unexpected board part $boardPart"; exit 1
}
set bp [get_board_parts -quiet $boardPart]
if { $bp eq "" } { puts "ERROR: $boardPart not found under $boardRepo"; exit 1 }
set part [get_property PART_NAME $bp]
if { [string match "*-es1*" $part] } { puts "ERROR: ES1 part $part"; exit 1 }

create_project -force ced_example $outDir/ced_example -part $part
set_property board_part $boardPart [current_project]

# AMD eval-board example (Versal Embedded Common Platform 2.0, VRK base board variant)
set bdName AxiSocVersalCpuCore
create_bd_design $bdName
instantiate_example_design -design $bdName -project ced_example -project_location $outDir/ced_example \
   -options [list Design_type.VALUE Base Include_AIE.VALUE true bufg_clk.VALUE 100] \
   [get_example_designs xilinx.com:design:versal_comn_platform:2.0]
write_bd_tcl -force $outDir/ced_raw.tcl

# The CED hardcodes LPDDR5X-8533; the prod board preset must have replaced it on every controller
foreach n {NoC_C0 NoC_C1 NoC_C2 NoC_C3} {
   set d [get_property CONFIG.DDRMC5_CONFIG [get_bd_cells $n]]
   if { [dict get $d DDRMC5_SPEED_GRADE] ne "LPDDR5X-7500" } {
      puts "ERROR: $n speed grade is [dict get $d DDRMC5_SPEED_GRADE], expected LPDDR5X-7500"; exit 1
   }
   puts "CHECK $n [dict get $d DDRMC5_SPEED_GRADE] tCK=[dict get $d DDRMC5_F0_TCK] refclk_ps=[dict get $d DDRMC5_INPUTCLK0_PERIOD]"
}

# Strip to PS / NoC / DDR / AIE scope. Keep clk_wizard_0 and rst_clk so the PS PL clock
# stays driven and the BD validates; the SLAC block design later replaces them with plClk/plRstL.
# The CED marks the PS-to-PL net DONT_TOUCH: delete it first or write_bd_tcl emits a dangling set_property.
catch {delete_bd_objs [get_bd_intf_nets ps_wizard_0_FPD_AXI_PL]}
foreach c {ctrl_smc axi_bram_ctrl_0 axi_bram_ctrl_0_bram axi_gpio_0 axi_gpio_1 axi_gpio_2 axi_uart16550_0} {
   delete_bd_objs [get_bd_cells $c]
}
delete_bd_objs [get_bd_intf_ports {gpio_led gpio_dp gpio_pb pl_uart_bank713}]
validate_bd_design -force
save_bd_design
write_bd_tcl -force $outDir/seed_raw.tcl

# core CI rejects trailing blanks in *.tcl (write_bd_tcl emits two such lines)
set fh [open $outDir/seed_raw.tcl r]; set txt [read $fh]; close $fh
set fh [open $outDir/AxiSocVersalCpuCore.tcl w]
puts -nonewline $fh [regsub -all -line {[ \t]+$} $txt {}]
close $fh
puts "SEED DONE: $outDir/AxiSocVersalCpuCore.tcl"
