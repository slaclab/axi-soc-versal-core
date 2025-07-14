-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- This file is part of 'axi-soc-versal-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'axi-soc-versal-core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;

library axi_soc_versal_core;
use axi_soc_versal_core.AxiSocVersalPkg.all;

package HardwareTypePkg is

   constant HW_TYPE_C : slv(31 downto 0) := HW_TYPE_XILINX_VEK280_C;

   type psMemOutType is record
      ch0_lpddr4_trip1_ca_a    : std_logic_vector (5 downto 0);
      ch0_lpddr4_trip1_cs_a    : std_logic;
      ch0_lpddr4_trip1_ck_t_a  : std_logic;
      ch0_lpddr4_trip1_ck_c_a  : std_logic;
      ch0_lpddr4_trip1_cke_a   : std_logic;
      ch0_lpddr4_trip1_reset_n : std_logic;
      ch1_lpddr4_trip1_ca_a    : std_logic_vector (5 downto 0);
      ch1_lpddr4_trip1_cs_a    : std_logic;
      ch1_lpddr4_trip1_ck_t_a  : std_logic;
      ch1_lpddr4_trip1_ck_c_a  : std_logic;
      ch1_lpddr4_trip1_cke_a   : std_logic;
      ch1_lpddr4_trip1_reset_n : std_logic;
      ch0_lpddr4_trip2_ca_a    : std_logic_vector (5 downto 0);
      ch0_lpddr4_trip2_cs_a    : std_logic;
      ch0_lpddr4_trip2_ck_t_a  : std_logic;
      ch0_lpddr4_trip2_ck_c_a  : std_logic;
      ch0_lpddr4_trip2_cke_a   : std_logic;
      ch0_lpddr4_trip2_reset_n : std_logic;
      ch1_lpddr4_trip2_ca_a    : std_logic_vector (5 downto 0);
      ch1_lpddr4_trip2_cs_a    : std_logic;
      ch1_lpddr4_trip2_ck_t_a  : std_logic;
      ch1_lpddr4_trip2_ck_c_a  : std_logic;
      ch1_lpddr4_trip2_cke_a   : std_logic;
      ch1_lpddr4_trip2_reset_n : std_logic;
      ch0_lpddr4_trip3_ca_a    : std_logic_vector (5 downto 0);
      ch0_lpddr4_trip3_cs_a    : std_logic;
      ch0_lpddr4_trip3_ck_t_a  : std_logic;
      ch0_lpddr4_trip3_ck_c_a  : std_logic;
      ch0_lpddr4_trip3_cke_a   : std_logic;
      ch0_lpddr4_trip3_reset_n : std_logic;
      ch1_lpddr4_trip3_ca_a    : std_logic_vector (5 downto 0);
      ch1_lpddr4_trip3_cs_a    : std_logic;
      ch1_lpddr4_trip3_ck_t_a  : std_logic;
      ch1_lpddr4_trip3_ck_c_a  : std_logic;
      ch1_lpddr4_trip3_cke_a   : std_logic;
      ch1_lpddr4_trip3_reset_n : std_logic;
   end record psMemOutType;

   type psMemInOutType is record
      ch0_lpddr4_trip1_dq_a    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip1_dq_b    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip1_dqs_t_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip1_dqs_t_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip1_dqs_c_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip1_dqs_c_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip1_dmi_a   : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip1_dmi_b   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dq_a    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip1_dq_b    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip1_dqs_t_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dqs_t_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dqs_c_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dqs_c_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dmi_a   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip1_dmi_b   : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dq_a    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip2_dq_b    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip2_dqs_t_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dqs_t_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dqs_c_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dqs_c_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dmi_a   : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip2_dmi_b   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dq_a    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip2_dq_b    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip2_dqs_t_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dqs_t_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dqs_c_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dqs_c_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dmi_a   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip2_dmi_b   : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dq_a    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip3_dq_b    : std_logic_vector (15 downto 0);
      ch0_lpddr4_trip3_dqs_t_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dqs_t_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dqs_c_a : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dqs_c_b : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dmi_a   : std_logic_vector (1 downto 0);
      ch0_lpddr4_trip3_dmi_b   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dq_a    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip3_dq_b    : std_logic_vector (15 downto 0);
      ch1_lpddr4_trip3_dqs_t_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dqs_t_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dqs_c_a : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dqs_c_b : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dmi_a   : std_logic_vector (1 downto 0);
      ch1_lpddr4_trip3_dmi_b   : std_logic_vector (1 downto 0);
   end record psMemInOutType;

   type psMemInType is record
      lpddr4_clk1_clk_p : std_logic;
      lpddr4_clk1_clk_n : std_logic;
      lpddr4_clk2_clk_p : std_logic;
      lpddr4_clk2_clk_n : std_logic;
      lpddr4_clk3_clk_p : std_logic;
      lpddr4_clk3_clk_n : std_logic;
   end record psMemInType;

end package HardwareTypePkg;
