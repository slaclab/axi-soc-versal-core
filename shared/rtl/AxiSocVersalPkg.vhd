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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiPkg.all;

package AxiSocVersalPkg is

   -- System Clock Frequency/Period
   constant DMA_CLK_FREQ_C   : real := 250.0E+6;              -- units of Hz
   constant DMA_CLK_PERIOD_C : real := (1.0/DMA_CLK_FREQ_C);  -- units of seconds

   -- Aux Clock Frequency/Period
   constant AUX_CLK_FREQ_C   : real := 100.0E+6;              -- units of Hz
   constant AUX_CLK_PERIOD_C : real := (1.0/AUX_CLK_FREQ_C);  -- units of seconds

   -- Application Address Offset
   constant APP_ADDR_OFFSET_C : slv(31 downto 0) := x"8000_0000";

   -- SOC AXI Configuration
   constant AXI_SOC_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,               -- 40-bit address interface
      DATA_BYTES_C => 16,               -- 128-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 DMA IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface

   -- DMA AXI Stream Configuration
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => AXI_SOC_CONFIG_C.DATA_BYTES_C,  -- Map the widths of the AXI interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 3,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   -- AIE AXI Stream Configuration
   constant AIE_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 16,              -- 128-bit data interface
      TDEST_BITS_C  => 0,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_NORMAL_C,
      TUSER_BITS_C  => 0,
      TUSER_MODE_C  => TUSER_NONE_C);

   -- List of PCIe Hardware Types
   constant HW_TYPE_UNDEFINED_C     : slv(31 downto 0) := x"00_00_00_00";
   constant HW_TYPE_XILINX_VEK280_C : slv(31 downto 0) := x"00_00_00_01";  -- XilinxVek280
   constant HW_TYPE_RESERVED_C      : slv(31 downto 0) := x"FF_FF_FF_FF";

end package AxiSocVersalPkg;
