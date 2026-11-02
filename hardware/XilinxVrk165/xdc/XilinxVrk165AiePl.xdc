##############################################################################
## This file is part of 'axi-soc-versal-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-soc-versal-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
##
## Pin the AIE-PL boundary stream channels of hardware/XilinxVrk165 to the sites the
## free placement chose.
##
## The block design exports 16 master (ai_pl_ch_0..15, M00_AXIS_0..M15_AXIS_0) and
## 16 slave (pl_ai_ch_0..15, S00_AXIS_0..S15_AXIS_0) 128-bit AXI-Stream channels on
## ai_engine_0. Nothing steered the placement: this file only records where it landed.
## A later re-implementation must not move the channels, because AIE graphs compiled
## separately pin their PLIOs to matching shim columns and channels.
##
## Observed rule:
##   - sites are AIE_PL_X<n>Y<m>, BELs are AIE_PL_M_AXIS_<k> (master) and AIE_PL_S_AXIS_<k> (slave)
##   - each 128-bit channel is a macro of two 64-bit member cells on consecutive BELs;
##     only the first member (even BEL index) is constrained, the macro carries the
##     second one along and Vivado rejects a BEL on it
##   - each used site shares its interface tile with one AIE_SHIMSWITCH site:
##       AIE_PL_X10Y0 tile=AIE_INTF_B2_CORE_X11Y0 shimswitch=AIE_SHIMSWITCH_X11Y0
##       AIE_PL_X11Y0 tile=AIE_INTF_B3_CORE_X12Y0 shimswitch=AIE_SHIMSWITCH_X12Y0
##       AIE_PL_X12Y0 tile=AIE_INTF_B0_CORE_X13Y0 shimswitch=AIE_SHIMSWITCH_X13Y0
##       AIE_PL_X13Y0 tile=AIE_INTF_B1_CORE_X14Y0 shimswitch=AIE_SHIMSWITCH_X14Y0
##       AIE_PL_X14Y0 tile=AIE_INTF_B2_CORE_X15Y0 shimswitch=AIE_SHIMSWITCH_X15Y0
##       AIE_PL_X15Y0 tile=AIE_INTF_B3_CORE_X16Y0 shimswitch=AIE_SHIMSWITCH_X16Y0
##
## Raw placement of the first channel of each direction:
##   S00_AXIS_0 (pl_ai_ch_0): LOC AIE_PL_X10Y0, BEL AIE_PL_S_AXIS_0
##   M00_AXIS_0 (ai_pl_ch_0): LOC AIE_PL_X10Y0, BEL AIE_PL_M_AXIS_0
## The adf::shim column and channel of the AIE graph PLIOs must match this placement.
##
## Regenerate from a routed checkpoint of the frozen block design that was built without
## this file:
##   vivado -mode batch -source scripts/gen_vrk_aiepl_xdc.tcl -tclargs <routed dcp> <out xdc> <hwName>
##############################################################################

set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_0/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_0/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_1/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_1/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_2/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_2/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_3/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_3/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_4/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_4/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_5/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_5/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_6/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_6/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_7/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_7/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_8/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_8/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_9/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X15Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_9/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_10/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_10/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_11/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_11/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_12/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_12/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_13/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_13/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_14/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_14/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_15/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_15/inst/ai_pl_channel_inst/AIE_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_0/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_0/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_1/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_1/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_2/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_2/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_3/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_3/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_4/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_4/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_5/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_5/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_6/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_6/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_7/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_7/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_8/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_8/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_9/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_9/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_10/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_10/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_11/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_11/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_12/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_12/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_13/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_13/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_14/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_14/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_15/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_15/inst/pl_ai_channel_inst/AIE_PL_S_AXIS64<0>_INST}]
