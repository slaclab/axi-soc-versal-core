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
## Pin the AIE-PL boundary stream channels to fixed shim interface sites.
##
## The VEK280 BD exports 16 master (Mxx_AXIS_0, ai_pl_ch_0..15) and
## 16 slave (Sxx_AXIS_0, pl_ai_ch_0..15) 128-bit PL stream channels on
## ai_engine_0. Without these constraints the Vivado placer is free to
## assign each channel to any AIE_ML_PL site/channel pair, and a future
## re-implementation could silently move them. AIE graphs compiled
## separately (aiecompiler against the base .xpfm, which carries NO PL
## stream metadata) must pin their PLIOs to matching shim columns with
##   adf::location<adf::PLIO>(io) = adf::shim(column, channel);
## where column = site X index + 1 and channel = the 64-bit BEL index of
## the channel pair anchor below (each 128-bit channel occupies an
## even/odd AXIS64 BEL pair; only the even anchor is constrained — the
## placer macro carries the odd member along).
##
## e.g. S00_AXIS_0 = pl_ai_ch_0 -> AIE_ML_PL_X10Y0 / S_AXIS_0
##        => adf::shim(11, 0)   (as used by Simple-VEK280-Example)
##
## Derived from the implemented SimpleVek280Example design
## (Vivado 2025.2 routed checkpoint). If the BD AIE interface
## configuration changes (channel count/width), regenerate by opening
## the routed .dcp and dumping LOC/BEL of
##   */ai_engine_0/U0/{ai_pl,pl_ai}_ch_*/inst/*_channel_inst/* leafs.
##############################################################################

set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_0/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_0/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_1/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_1/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_2/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_2/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_3/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_3/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_4/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_4/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_5/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_5/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_6/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_6/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_7/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_7/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_8/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X14Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_8/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_9/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X15Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_9/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_10/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_10/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_11/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_11/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_12/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_12/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_13/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_13/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_14/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_14/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_M_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_15/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/ai_pl_ch_15/inst/ai_pl_channel_inst/AIE_ML_PL_M_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_0/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_0/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_1/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_1/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_2/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_2/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_3/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_3/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_4/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_4/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_5/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X12Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_5/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_6/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_6/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_7/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_7/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_8/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_8/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_9/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X13Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_9/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_10/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_10/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_11/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X10Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_11/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_12/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_12/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_2 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_13/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_13/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_4 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_14/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_14/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property BEL AIE_ML_PL_S_AXIS_6 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_15/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
set_property LOC AIE_ML_PL_X11Y0 [get_cells {U_Core/REAL_CPU.U_CPU/U_CPU/ai_engine_0/U0/pl_ai_ch_15/inst/pl_ai_channel_inst/AIE_ML_PL_S_AXIS64<0>_INST}]
