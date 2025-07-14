-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AXI SOC Core
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
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;

library axi_soc_versal_core;
use axi_soc_versal_core.AxiSocVersalPkg.all;
use axi_soc_versal_core.HardwareTypePkg.all;

entity AxiSocVersalCpu is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      axiClk             : out   sl;    -- 250 MHz
      axiRst             : out   sl;
      auxClk             : out   sl;    -- 100 MHz
      auxRst             : out   sl;
      -- Slave AXI4 Interface
      dmaReadMaster      : in    AxiReadMasterType;
      dmaReadSlave       : out   AxiReadSlaveType;
      dmaWriteMaster     : in    AxiWriteMasterType;
      dmaWriteSlave      : out   AxiWriteSlaveType;
      -- Master AXI-Lite Interface
      regReadMaster      : out   AxiLiteReadMasterType;
      regReadSlave       : in    AxiLiteReadSlaveType;
      regWriteMaster     : out   AxiLiteWriteMasterType;
      regWriteSlave      : in    AxiLiteWriteSlaveType;
      dmaCtrlReadMaster  : out   AxiLiteReadMasterType;
      dmaCtrlReadSlave   : in    AxiLiteReadSlaveType;
      dmaCtrlWriteMaster : out   AxiLiteWriteMasterType;
      dmaCtrlWriteSlave  : in    AxiLiteWriteSlaveType;
      -- Interrupt Interface
      dmaIrq             : in    sl;
      -- PS Memory Ports
      psMemIn            : in    PsMemInType;
      psMemOut           : out   PsMemOutType;
      psMemInOut         : inout PsMemInOutType);
end AxiSocVersalCpu;

architecture mapping of AxiSocVersalCpu is

   component AxiSocVersalCpuCore is
      port (
         ch0_lpddr4_trip1_dq_a    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip1_dq_b    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip1_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_ca_a    : out   std_logic_vector (5 downto 0);
         ch0_lpddr4_trip1_cs_a    : out   std_logic;
         ch0_lpddr4_trip1_ck_t_a  : out   std_logic;
         ch0_lpddr4_trip1_ck_c_a  : out   std_logic;
         ch0_lpddr4_trip1_cke_a   : out   std_logic;
         ch0_lpddr4_trip1_dmi_a   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_dmi_b   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip1_reset_n : out   std_logic;
         ch1_lpddr4_trip1_dq_a    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip1_dq_b    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip1_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_ca_a    : out   std_logic_vector (5 downto 0);
         ch1_lpddr4_trip1_cs_a    : out   std_logic;
         ch1_lpddr4_trip1_ck_t_a  : out   std_logic;
         ch1_lpddr4_trip1_ck_c_a  : out   std_logic;
         ch1_lpddr4_trip1_cke_a   : out   std_logic;
         ch1_lpddr4_trip1_dmi_a   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_dmi_b   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip1_reset_n : out   std_logic;
         lpddr4_clk1_clk_p        : in    std_logic;
         lpddr4_clk1_clk_n        : in    std_logic;
         ch0_lpddr4_trip2_dq_a    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip2_dq_b    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip2_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_ca_a    : out   std_logic_vector (5 downto 0);
         ch0_lpddr4_trip2_cs_a    : out   std_logic;
         ch0_lpddr4_trip2_ck_t_a  : out   std_logic;
         ch0_lpddr4_trip2_ck_c_a  : out   std_logic;
         ch0_lpddr4_trip2_cke_a   : out   std_logic;
         ch0_lpddr4_trip2_dmi_a   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_dmi_b   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip2_reset_n : out   std_logic;
         ch1_lpddr4_trip2_dq_a    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip2_dq_b    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip2_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_ca_a    : out   std_logic_vector (5 downto 0);
         ch1_lpddr4_trip2_cs_a    : out   std_logic;
         ch1_lpddr4_trip2_ck_t_a  : out   std_logic;
         ch1_lpddr4_trip2_ck_c_a  : out   std_logic;
         ch1_lpddr4_trip2_cke_a   : out   std_logic;
         ch1_lpddr4_trip2_dmi_a   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_dmi_b   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip2_reset_n : out   std_logic;
         lpddr4_clk2_clk_p        : in    std_logic;
         lpddr4_clk2_clk_n        : in    std_logic;
         ch0_lpddr4_trip3_dq_a    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip3_dq_b    : inout std_logic_vector (15 downto 0);
         ch0_lpddr4_trip3_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_ca_a    : out   std_logic_vector (5 downto 0);
         ch0_lpddr4_trip3_cs_a    : out   std_logic;
         ch0_lpddr4_trip3_ck_t_a  : out   std_logic;
         ch0_lpddr4_trip3_ck_c_a  : out   std_logic;
         ch0_lpddr4_trip3_cke_a   : out   std_logic;
         ch0_lpddr4_trip3_dmi_a   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_dmi_b   : inout std_logic_vector (1 downto 0);
         ch0_lpddr4_trip3_reset_n : out   std_logic;
         ch1_lpddr4_trip3_dq_a    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip3_dq_b    : inout std_logic_vector (15 downto 0);
         ch1_lpddr4_trip3_dqs_t_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_dqs_t_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_dqs_c_a : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_dqs_c_b : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_ca_a    : out   std_logic_vector (5 downto 0);
         ch1_lpddr4_trip3_cs_a    : out   std_logic;
         ch1_lpddr4_trip3_ck_t_a  : out   std_logic;
         ch1_lpddr4_trip3_ck_c_a  : out   std_logic;
         ch1_lpddr4_trip3_cke_a   : out   std_logic;
         ch1_lpddr4_trip3_dmi_a   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_dmi_b   : inout std_logic_vector (1 downto 0);
         ch1_lpddr4_trip3_reset_n : out   std_logic;
         lpddr4_clk3_clk_p        : in    std_logic;
         lpddr4_clk3_clk_n        : in    std_logic;
         dma_araddr               : in    std_logic_vector (48 downto 0);
         dma_arburst              : in    std_logic_vector (1 downto 0);
         dma_arcache              : in    std_logic_vector (3 downto 0);
         dma_arid                 : in    std_logic_vector (5 downto 0);
         dma_arlen                : in    std_logic_vector (7 downto 0);
         dma_arlock               : in    std_logic;
         dma_arprot               : in    std_logic_vector (2 downto 0);
         dma_arqos                : in    std_logic_vector (3 downto 0);
         dma_arsize               : in    std_logic_vector (2 downto 0);
         dma_aruser               : in    std_logic_vector (9 downto 0);
         dma_awaddr               : in    std_logic_vector (48 downto 0);
         dma_awburst              : in    std_logic_vector (1 downto 0);
         dma_awcache              : in    std_logic_vector (3 downto 0);
         dma_awid                 : in    std_logic_vector (5 downto 0);
         dma_awlen                : in    std_logic_vector (7 downto 0);
         dma_awlock               : in    std_logic;
         dma_awprot               : in    std_logic_vector (2 downto 0);
         dma_awqos                : in    std_logic_vector (3 downto 0);
         dma_awsize               : in    std_logic_vector (2 downto 0);
         dma_awuser               : in    std_logic_vector (9 downto 0);
         dma_awvalid              : in    std_logic;
         dma_bready               : in    std_logic;
         dma_rready               : in    std_logic;
         dma_wlast                : in    std_logic;
         dma_wvalid               : in    std_logic;
         dma_arready              : out   std_logic;
         dma_arvalid              : in    std_logic;
         dma_awready              : out   std_logic;
         dma_bid                  : out   std_logic_vector (5 downto 0);
         dma_bresp                : out   std_logic_vector (1 downto 0);
         dma_bvalid               : out   std_logic;
         dma_rid                  : out   std_logic_vector (5 downto 0);
         dma_rlast                : out   std_logic;
         dma_rresp                : out   std_logic_vector (1 downto 0);
         dma_rvalid               : out   std_logic;
         dma_wready               : out   std_logic;
         dma_wdata                : in    std_logic_vector (127 downto 0);
         dma_wstrb                : in    std_logic_vector (15 downto 0);
         dma_rdata                : out   std_logic_vector (127 downto 0);
         dmaCtrl_awid             : out   std_logic_vector (15 downto 0);
         dmaCtrl_awaddr           : out   std_logic_vector (43 downto 0);
         dmaCtrl_awlen            : out   std_logic_vector (7 downto 0);
         dmaCtrl_awsize           : out   std_logic_vector (2 downto 0);
         dmaCtrl_awburst          : out   std_logic_vector (1 downto 0);
         dmaCtrl_awlock           : out   std_logic;
         dmaCtrl_awcache          : out   std_logic_vector (3 downto 0);
         dmaCtrl_awprot           : out   std_logic_vector (2 downto 0);
         dmaCtrl_awvalid          : out   std_logic;
         dmaCtrl_awuser           : out   std_logic_vector (15 downto 0);
         dmaCtrl_awready          : in    std_logic;
         dmaCtrl_wlast            : out   std_logic;
         dmaCtrl_wvalid           : out   std_logic;
         dmaCtrl_wready           : in    std_logic;
         dmaCtrl_bid              : in    std_logic_vector (15 downto 0);
         dmaCtrl_bresp            : in    std_logic_vector (1 downto 0);
         dmaCtrl_bvalid           : in    std_logic;
         dmaCtrl_bready           : out   std_logic;
         dmaCtrl_arid             : out   std_logic_vector (15 downto 0);
         dmaCtrl_araddr           : out   std_logic_vector (43 downto 0);
         dmaCtrl_arlen            : out   std_logic_vector (7 downto 0);
         dmaCtrl_arsize           : out   std_logic_vector (2 downto 0);
         dmaCtrl_arburst          : out   std_logic_vector (1 downto 0);
         dmaCtrl_arlock           : out   std_logic;
         dmaCtrl_arcache          : out   std_logic_vector (3 downto 0);
         dmaCtrl_arprot           : out   std_logic_vector (2 downto 0);
         dmaCtrl_arvalid          : out   std_logic;
         dmaCtrl_aruser           : out   std_logic_vector (15 downto 0);
         dmaCtrl_arready          : in    std_logic;
         dmaCtrl_rid              : in    std_logic_vector (15 downto 0);
         dmaCtrl_rresp            : in    std_logic_vector (1 downto 0);
         dmaCtrl_rlast            : in    std_logic;
         dmaCtrl_rvalid           : in    std_logic;
         dmaCtrl_rready           : out   std_logic;
         dmaCtrl_awqos            : out   std_logic_vector (3 downto 0);
         dmaCtrl_arqos            : out   std_logic_vector (3 downto 0);
         dmaCtrl_wdata            : out   std_logic_vector (31 downto 0);
         dmaCtrl_wstrb            : out   std_logic_vector (3 downto 0);
         dmaCtrl_rdata            : in    std_logic_vector (31 downto 0);
         axiLite_awid             : out   std_logic_vector (15 downto 0);
         axiLite_awaddr           : out   std_logic_vector (43 downto 0);
         axiLite_awlen            : out   std_logic_vector (7 downto 0);
         axiLite_awsize           : out   std_logic_vector (2 downto 0);
         axiLite_awburst          : out   std_logic_vector (1 downto 0);
         axiLite_awlock           : out   std_logic;
         axiLite_awcache          : out   std_logic_vector (3 downto 0);
         axiLite_awprot           : out   std_logic_vector (2 downto 0);
         axiLite_awvalid          : out   std_logic;
         axiLite_awuser           : out   std_logic_vector (15 downto 0);
         axiLite_awready          : in    std_logic;
         axiLite_wlast            : out   std_logic;
         axiLite_wvalid           : out   std_logic;
         axiLite_wready           : in    std_logic;
         axiLite_bid              : in    std_logic_vector (15 downto 0);
         axiLite_bresp            : in    std_logic_vector (1 downto 0);
         axiLite_bvalid           : in    std_logic;
         axiLite_bready           : out   std_logic;
         axiLite_arid             : out   std_logic_vector (15 downto 0);
         axiLite_araddr           : out   std_logic_vector (43 downto 0);
         axiLite_arlen            : out   std_logic_vector (7 downto 0);
         axiLite_arsize           : out   std_logic_vector (2 downto 0);
         axiLite_arburst          : out   std_logic_vector (1 downto 0);
         axiLite_arlock           : out   std_logic;
         axiLite_arcache          : out   std_logic_vector (3 downto 0);
         axiLite_arprot           : out   std_logic_vector (2 downto 0);
         axiLite_arvalid          : out   std_logic;
         axiLite_aruser           : out   std_logic_vector (15 downto 0);
         axiLite_arready          : in    std_logic;
         axiLite_rid              : in    std_logic_vector (15 downto 0);
         axiLite_rresp            : in    std_logic_vector (1 downto 0);
         axiLite_rlast            : in    std_logic;
         axiLite_rvalid           : in    std_logic;
         axiLite_rready           : out   std_logic;
         axiLite_awqos            : out   std_logic_vector (3 downto 0);
         axiLite_arqos            : out   std_logic_vector (3 downto 0);
         axiLite_wdata            : out   std_logic_vector (31 downto 0);
         axiLite_wstrb            : out   std_logic_vector (3 downto 0);
         axiLite_rdata            : in    std_logic_vector (31 downto 0);
         dmaIrq                   : in    std_logic;
         dmaClk                   : in    std_logic;
         plClk                    : out   std_logic;
         plRstL                   : out   std_logic
         );
   end component AxiSocVersalCpuCore;

   signal plClk  : sl;
   signal plRstL : sl;

   signal dmaClk  : sl;
   signal dmaRst  : sl;
   signal dmaRstL : sl;

   signal dummy : slv(3 downto 0);

   signal readMasters  : AxiReadMasterArray(1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal readSlaves   : AxiReadSlaveArray(1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);
   signal writeMasters : AxiWriteMasterArray(1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal writeSlaves  : AxiWriteSlaveArray(1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);

begin

   axiClk <= dmaClk;
   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => dmaClk,
         rstIn  => dmaRstL,
         rstOut => axiRst);

   U_axiLite : entity axi_soc_versal_core.AxiSocVersalAxiConvt
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clock and Reset
         axiClk           => dmaClk,
         axiRstL          => dmaRstL,
         -- Slave AXI4 Interface
         sAxiReadMaster   => readMasters(0),
         sAxiReadSlave    => readSlaves(0),
         sAxiWriteMaster  => writeMasters(0),
         sAxiWriteSlave   => writeSlaves(0),
         -- Master AXI-Lite Interface
         mAxilReadMaster  => regReadMaster,
         mAxilReadSlave   => regReadSlave,
         mAxilWriteMaster => regWriteMaster,
         mAxilWriteSlave  => regWriteSlave);

   U_dmaCtrl : entity axi_soc_versal_core.AxiSocVersalAxiConvt
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clock and Reset
         axiClk           => dmaClk,
         axiRstL          => dmaRstL,
         -- Slave AXI4 Interface
         sAxiReadMaster   => readMasters(1),
         sAxiReadSlave    => readSlaves(1),
         sAxiWriteMaster  => writeMasters(1),
         sAxiWriteSlave   => writeSlaves(1),
         -- Master AXI-Lite Interface
         mAxilReadMaster  => dmaCtrlReadMaster,
         mAxilReadSlave   => dmaCtrlReadSlave,
         mAxilWriteMaster => dmaCtrlWriteMaster,
         mAxilWriteSlave  => dmaCtrlWriteSlave);

   -------------------
   -- AXI SOC IP Core
   -------------------
   U_CPU : AxiSocVersalCpuCore
      port map (
         -- User AXI-Lite Interface
         axiLite_araddr(43 downto 0) => readMasters(0).araddr(43 downto 0),
         axiLite_arburst(1 downto 0) => readMasters(0).arburst(1 downto 0),
         axiLite_arcache(3 downto 0) => readMasters(0).arcache(3 downto 0),
         axiLite_arid(15 downto 0)   => readMasters(0).arid(15 downto 0),
         axiLite_arlen(7 downto 0)   => readMasters(0).arlen(7 downto 0),
         axiLite_arlock              => readMasters(0).arlock(0),
         axiLite_arprot(2 downto 0)  => readMasters(0).arprot(2 downto 0),
         axiLite_arqos(3 downto 0)   => readMasters(0).arqos(3 downto 0),
         axiLite_arready             => readSlaves(0).arready,
         axiLite_arsize(2 downto 0)  => readMasters(0).arsize(2 downto 0),
         axiLite_aruser(15 downto 0) => open,
         axiLite_arvalid             => readMasters(0).arvalid,
         axiLite_awaddr(43 downto 0) => writeMasters(0).awaddr(43 downto 0),
         axiLite_awburst(1 downto 0) => writeMasters(0).awburst(1 downto 0),
         axiLite_awcache(3 downto 0) => writeMasters(0).awcache(3 downto 0),
         axiLite_awid(15 downto 0)   => writeMasters(0).awid(15 downto 0),
         axiLite_awlen(7 downto 0)   => writeMasters(0).awlen(7 downto 0),
         axiLite_awlock              => writeMasters(0).awlock(0),
         axiLite_awprot(2 downto 0)  => writeMasters(0).awprot(2 downto 0),
         axiLite_awqos(3 downto 0)   => writeMasters(0).awqos(3 downto 0),
         axiLite_awready             => writeSlaves(0).awready,
         axiLite_awsize(2 downto 0)  => writeMasters(0).awsize(2 downto 0),
         axiLite_awuser(15 downto 0) => open,
         axiLite_awvalid             => writeMasters(0).awvalid,
         axiLite_bid(15 downto 0)    => writeSlaves(0).bid(15 downto 0),
         axiLite_bready              => writeMasters(0).bready,
         axiLite_bresp(1 downto 0)   => AXI_RESP_OK_C,  -- Always respond OK
         axiLite_bvalid              => writeSlaves(0).bvalid,
         axiLite_rdata(31 downto 0)  => readSlaves(0).rdata(31 downto 0),
         axiLite_rid(15 downto 0)    => readSlaves(0).rid(15 downto 0),
         axiLite_rlast               => readSlaves(0).rlast,
         axiLite_rready              => readMasters(0).rready,
         axiLite_rresp(1 downto 0)   => AXI_RESP_OK_C,  -- Always respond OK
         axiLite_rvalid              => readSlaves(0).rvalid,
         axiLite_wdata(31 downto 0)  => writeMasters(0).wdata(31 downto 0),
         axiLite_wlast               => writeMasters(0).wlast,
         axiLite_wready              => writeSlaves(0).wready,
         axiLite_wstrb(3 downto 0)   => writeMasters(0).wstrb(3 downto 0),
         axiLite_wvalid              => writeMasters(0).wvalid,
         -- DMA AXI-Lite Interface
         dmaCtrl_araddr(43 downto 0) => readMasters(1).araddr(43 downto 0),
         dmaCtrl_arburst(1 downto 0) => readMasters(1).arburst(1 downto 0),
         dmaCtrl_arcache(3 downto 0) => readMasters(1).arcache(3 downto 0),
         dmaCtrl_arid(15 downto 0)   => readMasters(1).arid(15 downto 0),
         dmaCtrl_arlen(7 downto 0)   => readMasters(1).arlen(7 downto 0),
         dmaCtrl_arlock              => readMasters(1).arlock(0),
         dmaCtrl_arprot(2 downto 0)  => readMasters(1).arprot(2 downto 0),
         dmaCtrl_arqos(3 downto 0)   => readMasters(1).arqos(3 downto 0),
         dmaCtrl_arready             => readSlaves(1).arready,
         dmaCtrl_arsize(2 downto 0)  => readMasters(1).arsize(2 downto 0),
         dmaCtrl_aruser(15 downto 0) => open,
         dmaCtrl_arvalid             => readMasters(1).arvalid,
         dmaCtrl_awaddr(43 downto 0) => writeMasters(1).awaddr(43 downto 0),
         dmaCtrl_awburst(1 downto 0) => writeMasters(1).awburst(1 downto 0),
         dmaCtrl_awcache(3 downto 0) => writeMasters(1).awcache(3 downto 0),
         dmaCtrl_awid(15 downto 0)   => writeMasters(1).awid(15 downto 0),
         dmaCtrl_awlen(7 downto 0)   => writeMasters(1).awlen(7 downto 0),
         dmaCtrl_awlock              => writeMasters(1).awlock(0),
         dmaCtrl_awprot(2 downto 0)  => writeMasters(1).awprot(2 downto 0),
         dmaCtrl_awqos(3 downto 0)   => writeMasters(1).awqos(3 downto 0),
         dmaCtrl_awready             => writeSlaves(1).awready,
         dmaCtrl_awsize(2 downto 0)  => writeMasters(1).awsize(2 downto 0),
         dmaCtrl_awuser(15 downto 0) => open,
         dmaCtrl_awvalid             => writeMasters(1).awvalid,
         dmaCtrl_bid(15 downto 0)    => writeSlaves(1).bid(15 downto 0),
         dmaCtrl_bready              => writeMasters(1).bready,
         dmaCtrl_bresp(1 downto 0)   => AXI_RESP_OK_C,  -- Always respond OK
         dmaCtrl_bvalid              => writeSlaves(1).bvalid,
         dmaCtrl_rdata(31 downto 0)  => readSlaves(1).rdata(31 downto 0),
         dmaCtrl_rid(15 downto 0)    => readSlaves(1).rid(15 downto 0),
         dmaCtrl_rlast               => readSlaves(1).rlast,
         dmaCtrl_rready              => readMasters(1).rready,
         dmaCtrl_rresp(1 downto 0)   => AXI_RESP_OK_C,  -- Always respond OK
         dmaCtrl_rvalid              => readSlaves(1).rvalid,
         dmaCtrl_wdata(31 downto 0)  => writeMasters(1).wdata(31 downto 0),
         dmaCtrl_wlast               => writeMasters(1).wlast,
         dmaCtrl_wready              => writeSlaves(1).wready,
         dmaCtrl_wstrb(3 downto 0)   => writeMasters(1).wstrb(3 downto 0),
         dmaCtrl_wvalid              => writeMasters(1).wvalid,
         -- DMA Interface
         dmaClk                      => dmaClk,
         dmaIrq                      => dmaIrq,
         dma_araddr(39 downto 0)     => dmaReadMaster.araddr(AXI_SOC_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         dma_araddr(48 downto 40)    => (others => '0'),
         dma_arburst(1 downto 0)     => dmaReadMaster.arburst(1 downto 0),
         dma_arcache(3 downto 0)     => dmaReadMaster.arcache(3 downto 0),
         dma_arid(3 downto 0)        => dmaReadMaster.arid(AXI_SOC_CONFIG_C.ID_BITS_C-1 downto 0),
         dma_arid(5 downto 4)        => (others => '0'),
         dma_arlen(7 downto 0)       => dmaReadMaster.arlen(AXI_SOC_CONFIG_C.LEN_BITS_C-1 downto 0),
         dma_arlock                  => '0',
         dma_arprot(2 downto 0)      => dmaReadMaster.arprot(2 downto 0),
         dma_arqos(3 downto 0)       => dmaReadMaster.arqos(3 downto 0),
         dma_arready                 => dmaReadSlave.arready,
         dma_arsize(2 downto 0)      => dmaReadMaster.arsize(2 downto 0),
         dma_aruser                  => (others => '0'),
         dma_arvalid                 => dmaReadMaster.arvalid,
         dma_awaddr(39 downto 0)     => dmaWriteMaster.awaddr(AXI_SOC_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         dma_awaddr(48 downto 40)    => (others => '0'),
         dma_awburst(1 downto 0)     => dmaWriteMaster.awburst(1 downto 0),
         dma_awcache(3 downto 0)     => dmaWriteMaster.awcache(3 downto 0),
         dma_awid(3 downto 0)        => dmaWriteMaster.awid(AXI_SOC_CONFIG_C.ID_BITS_C-1 downto 0),
         dma_awid(5 downto 4)        => (others => '0'),
         dma_awlen(7 downto 0)       => dmaWriteMaster.awlen(AXI_SOC_CONFIG_C.LEN_BITS_C-1 downto 0),
         dma_awlock                  => '0',
         dma_awprot(2 downto 0)      => dmaWriteMaster.awprot(2 downto 0),
         dma_awqos(3 downto 0)       => dmaWriteMaster.awqos(3 downto 0),
         dma_awready                 => dmaWriteSlave.awready,
         dma_awsize(2 downto 0)      => dmaWriteMaster.awsize(2 downto 0),
         dma_awuser                  => (others => '0'),
         dma_awvalid                 => dmaWriteMaster.awvalid,
         dma_bid(3 downto 0)         => dmaWriteSlave.bid(AXI_SOC_CONFIG_C.ID_BITS_C-1 downto 0),
         dma_bid(5 downto 4)         => dummy(1 downto 0),
         dma_bready                  => dmaWriteMaster.bready,
         dma_bresp(1 downto 0)       => dmaWriteSlave.bresp(1 downto 0),
         dma_bvalid                  => dmaWriteSlave.bvalid,
         dma_rdata(127 downto 0)     => dmaReadSlave.rdata(8*AXI_SOC_CONFIG_C.DATA_BYTES_C-1 downto 0),
         dma_rid(3 downto 0)         => dmaReadSlave.rid(AXI_SOC_CONFIG_C.ID_BITS_C-1 downto 0),
         dma_rid(5 downto 4)         => dummy(3 downto 2),
         dma_rlast                   => dmaReadSlave.rlast,
         dma_rready                  => dmaReadMaster.rready,
         dma_rresp(1 downto 0)       => dmaReadSlave.rresp(1 downto 0),
         dma_rvalid                  => dmaReadSlave.rvalid,
         dma_wdata(127 downto 0)     => dmaWriteMaster.wdata(8*AXI_SOC_CONFIG_C.DATA_BYTES_C-1 downto 0),
         dma_wlast                   => dmaWriteMaster.wlast,
         dma_wready                  => dmaWriteSlave.wready,
         dma_wstrb(15 downto 0)      => dmaWriteMaster.wstrb(AXI_SOC_CONFIG_C.DATA_BYTES_C-1 downto 0),
         dma_wvalid                  => dmaWriteMaster.wvalid,

         -- PS Memory Ports
         ch0_lpddr4_trip1_ca_a(5 downto 0)    => psMemOut.ch0_lpddr4_trip1_ca_a(5 downto 0),
         ch0_lpddr4_trip1_ck_c_a              => psMemOut.ch0_lpddr4_trip1_ck_c_a,
         ch0_lpddr4_trip1_ck_t_a              => psMemOut.ch0_lpddr4_trip1_ck_t_a,
         ch0_lpddr4_trip1_cke_a               => psMemOut.ch0_lpddr4_trip1_cke_a,
         ch0_lpddr4_trip1_cs_a                => psMemOut.ch0_lpddr4_trip1_cs_a,
         ch0_lpddr4_trip1_dmi_a(1 downto 0)   => psMemInOut.ch0_lpddr4_trip1_dmi_a(1 downto 0),
         ch0_lpddr4_trip1_dmi_b(1 downto 0)   => psMemInOut.ch0_lpddr4_trip1_dmi_b(1 downto 0),
         ch0_lpddr4_trip1_dq_a(15 downto 0)   => psMemInOut.ch0_lpddr4_trip1_dq_a(15 downto 0),
         ch0_lpddr4_trip1_dq_b(15 downto 0)   => psMemInOut.ch0_lpddr4_trip1_dq_b(15 downto 0),
         ch0_lpddr4_trip1_dqs_c_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip1_dqs_c_a(1 downto 0),
         ch0_lpddr4_trip1_dqs_c_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip1_dqs_c_b(1 downto 0),
         ch0_lpddr4_trip1_dqs_t_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip1_dqs_t_a(1 downto 0),
         ch0_lpddr4_trip1_dqs_t_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip1_dqs_t_b(1 downto 0),
         ch0_lpddr4_trip1_reset_n             => psMemOut.ch0_lpddr4_trip1_reset_n,
         ch0_lpddr4_trip2_ca_a(5 downto 0)    => psMemOut.ch0_lpddr4_trip2_ca_a(5 downto 0),
         ch0_lpddr4_trip2_ck_c_a              => psMemOut.ch0_lpddr4_trip2_ck_c_a,
         ch0_lpddr4_trip2_ck_t_a              => psMemOut.ch0_lpddr4_trip2_ck_t_a,
         ch0_lpddr4_trip2_cke_a               => psMemOut.ch0_lpddr4_trip2_cke_a,
         ch0_lpddr4_trip2_cs_a                => psMemOut.ch0_lpddr4_trip2_cs_a,
         ch0_lpddr4_trip2_dmi_a(1 downto 0)   => psMemInOut.ch0_lpddr4_trip2_dmi_a(1 downto 0),
         ch0_lpddr4_trip2_dmi_b(1 downto 0)   => psMemInOut.ch0_lpddr4_trip2_dmi_b(1 downto 0),
         ch0_lpddr4_trip2_dq_a(15 downto 0)   => psMemInOut.ch0_lpddr4_trip2_dq_a(15 downto 0),
         ch0_lpddr4_trip2_dq_b(15 downto 0)   => psMemInOut.ch0_lpddr4_trip2_dq_b(15 downto 0),
         ch0_lpddr4_trip2_dqs_c_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip2_dqs_c_a(1 downto 0),
         ch0_lpddr4_trip2_dqs_c_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip2_dqs_c_b(1 downto 0),
         ch0_lpddr4_trip2_dqs_t_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip2_dqs_t_a(1 downto 0),
         ch0_lpddr4_trip2_dqs_t_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip2_dqs_t_b(1 downto 0),
         ch0_lpddr4_trip2_reset_n             => psMemOut.ch0_lpddr4_trip2_reset_n,
         ch0_lpddr4_trip3_ca_a(5 downto 0)    => psMemOut.ch0_lpddr4_trip3_ca_a(5 downto 0),
         ch0_lpddr4_trip3_ck_c_a              => psMemOut.ch0_lpddr4_trip3_ck_c_a,
         ch0_lpddr4_trip3_ck_t_a              => psMemOut.ch0_lpddr4_trip3_ck_t_a,
         ch0_lpddr4_trip3_cke_a               => psMemOut.ch0_lpddr4_trip3_cke_a,
         ch0_lpddr4_trip3_cs_a                => psMemOut.ch0_lpddr4_trip3_cs_a,
         ch0_lpddr4_trip3_dmi_a(1 downto 0)   => psMemInOut.ch0_lpddr4_trip3_dmi_a(1 downto 0),
         ch0_lpddr4_trip3_dmi_b(1 downto 0)   => psMemInOut.ch0_lpddr4_trip3_dmi_b(1 downto 0),
         ch0_lpddr4_trip3_dq_a(15 downto 0)   => psMemInOut.ch0_lpddr4_trip3_dq_a(15 downto 0),
         ch0_lpddr4_trip3_dq_b(15 downto 0)   => psMemInOut.ch0_lpddr4_trip3_dq_b(15 downto 0),
         ch0_lpddr4_trip3_dqs_c_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip3_dqs_c_a(1 downto 0),
         ch0_lpddr4_trip3_dqs_c_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip3_dqs_c_b(1 downto 0),
         ch0_lpddr4_trip3_dqs_t_a(1 downto 0) => psMemInOut.ch0_lpddr4_trip3_dqs_t_a(1 downto 0),
         ch0_lpddr4_trip3_dqs_t_b(1 downto 0) => psMemInOut.ch0_lpddr4_trip3_dqs_t_b(1 downto 0),
         ch0_lpddr4_trip3_reset_n             => psMemOut.ch0_lpddr4_trip3_reset_n,
         ch1_lpddr4_trip1_ca_a(5 downto 0)    => psMemOut.ch1_lpddr4_trip1_ca_a(5 downto 0),
         ch1_lpddr4_trip1_ck_c_a              => psMemOut.ch1_lpddr4_trip1_ck_c_a,
         ch1_lpddr4_trip1_ck_t_a              => psMemOut.ch1_lpddr4_trip1_ck_t_a,
         ch1_lpddr4_trip1_cke_a               => psMemOut.ch1_lpddr4_trip1_cke_a,
         ch1_lpddr4_trip1_cs_a                => psMemOut.ch1_lpddr4_trip1_cs_a,
         ch1_lpddr4_trip1_dmi_a(1 downto 0)   => psMemInOut.ch1_lpddr4_trip1_dmi_a(1 downto 0),
         ch1_lpddr4_trip1_dmi_b(1 downto 0)   => psMemInOut.ch1_lpddr4_trip1_dmi_b(1 downto 0),
         ch1_lpddr4_trip1_dq_a(15 downto 0)   => psMemInOut.ch1_lpddr4_trip1_dq_a(15 downto 0),
         ch1_lpddr4_trip1_dq_b(15 downto 0)   => psMemInOut.ch1_lpddr4_trip1_dq_b(15 downto 0),
         ch1_lpddr4_trip1_dqs_c_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip1_dqs_c_a(1 downto 0),
         ch1_lpddr4_trip1_dqs_c_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip1_dqs_c_b(1 downto 0),
         ch1_lpddr4_trip1_dqs_t_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip1_dqs_t_a(1 downto 0),
         ch1_lpddr4_trip1_dqs_t_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip1_dqs_t_b(1 downto 0),
         ch1_lpddr4_trip1_reset_n             => psMemOut.ch1_lpddr4_trip1_reset_n,
         ch1_lpddr4_trip2_ca_a(5 downto 0)    => psMemOut.ch1_lpddr4_trip2_ca_a(5 downto 0),
         ch1_lpddr4_trip2_ck_c_a              => psMemOut.ch1_lpddr4_trip2_ck_c_a,
         ch1_lpddr4_trip2_ck_t_a              => psMemOut.ch1_lpddr4_trip2_ck_t_a,
         ch1_lpddr4_trip2_cke_a               => psMemOut.ch1_lpddr4_trip2_cke_a,
         ch1_lpddr4_trip2_cs_a                => psMemOut.ch1_lpddr4_trip2_cs_a,
         ch1_lpddr4_trip2_dmi_a(1 downto 0)   => psMemInOut.ch1_lpddr4_trip2_dmi_a(1 downto 0),
         ch1_lpddr4_trip2_dmi_b(1 downto 0)   => psMemInOut.ch1_lpddr4_trip2_dmi_b(1 downto 0),
         ch1_lpddr4_trip2_dq_a(15 downto 0)   => psMemInOut.ch1_lpddr4_trip2_dq_a(15 downto 0),
         ch1_lpddr4_trip2_dq_b(15 downto 0)   => psMemInOut.ch1_lpddr4_trip2_dq_b(15 downto 0),
         ch1_lpddr4_trip2_dqs_c_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip2_dqs_c_a(1 downto 0),
         ch1_lpddr4_trip2_dqs_c_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip2_dqs_c_b(1 downto 0),
         ch1_lpddr4_trip2_dqs_t_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip2_dqs_t_a(1 downto 0),
         ch1_lpddr4_trip2_dqs_t_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip2_dqs_t_b(1 downto 0),
         ch1_lpddr4_trip2_reset_n             => psMemOut.ch1_lpddr4_trip2_reset_n,
         ch1_lpddr4_trip3_ca_a(5 downto 0)    => psMemOut.ch1_lpddr4_trip3_ca_a(5 downto 0),
         ch1_lpddr4_trip3_ck_c_a              => psMemOut.ch1_lpddr4_trip3_ck_c_a,
         ch1_lpddr4_trip3_ck_t_a              => psMemOut.ch1_lpddr4_trip3_ck_t_a,
         ch1_lpddr4_trip3_cke_a               => psMemOut.ch1_lpddr4_trip3_cke_a,
         ch1_lpddr4_trip3_cs_a                => psMemOut.ch1_lpddr4_trip3_cs_a,
         ch1_lpddr4_trip3_dmi_a(1 downto 0)   => psMemInOut.ch1_lpddr4_trip3_dmi_a(1 downto 0),
         ch1_lpddr4_trip3_dmi_b(1 downto 0)   => psMemInOut.ch1_lpddr4_trip3_dmi_b(1 downto 0),
         ch1_lpddr4_trip3_dq_a(15 downto 0)   => psMemInOut.ch1_lpddr4_trip3_dq_a(15 downto 0),
         ch1_lpddr4_trip3_dq_b(15 downto 0)   => psMemInOut.ch1_lpddr4_trip3_dq_b(15 downto 0),
         ch1_lpddr4_trip3_dqs_c_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip3_dqs_c_a(1 downto 0),
         ch1_lpddr4_trip3_dqs_c_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip3_dqs_c_b(1 downto 0),
         ch1_lpddr4_trip3_dqs_t_a(1 downto 0) => psMemInOut.ch1_lpddr4_trip3_dqs_t_a(1 downto 0),
         ch1_lpddr4_trip3_dqs_t_b(1 downto 0) => psMemInOut.ch1_lpddr4_trip3_dqs_t_b(1 downto 0),
         ch1_lpddr4_trip3_reset_n             => psMemOut.ch1_lpddr4_trip3_reset_n,
         lpddr4_clk1_clk_n                    => psMemIn.lpddr4_clk1_clk_n,
         lpddr4_clk1_clk_p                    => psMemIn.lpddr4_clk1_clk_p,
         lpddr4_clk2_clk_n                    => psMemIn.lpddr4_clk2_clk_n,
         lpddr4_clk2_clk_p                    => psMemIn.lpddr4_clk2_clk_p,
         lpddr4_clk3_clk_n                    => psMemIn.lpddr4_clk3_clk_n,
         lpddr4_clk3_clk_p                    => psMemIn.lpddr4_clk3_clk_p,

         -- Reference Clock and reset
         plClk  => plClk,
         plRstL => plRstL);

   U_Pll : entity surf.ClockManagerVersal
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => true,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '0',      -- Active LOW reset
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 4.0,      -- 250 MHz
         CLKFBOUT_MULT_G   => 10,       -- 2.5 GHz = 4 x 250 MHz
         CLKOUT0_DIVIDE_G  => 10,       -- 250 MHz = 2.5 GHz / 10
         CLKOUT1_DIVIDE_G  => 25)       -- 100 MHz = 2.5 GHz / 25
      port map(
         -- Clock Input
         clkIn     => plClk,
         rstIn     => plRstL,
         -- Clock Outputs
         clkOut(0) => dmaClk,
         clkOut(1) => auxClk,
         -- Reset Outputs
         rstOut(0) => dmaRst,
         rstOut(1) => auxRst);

   dmaRstL <= not(dmaRst);

end mapping;
