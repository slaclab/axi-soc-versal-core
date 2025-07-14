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

entity AxiSocVersalAxiConvt is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      axiClk           : in  sl;
      axiRstL          : in  sl;
      -- Slave AXI4 Interface
      sAxiReadMaster   : in  AxiReadMasterType;
      sAxiReadSlave    : out AxiReadSlaveType;
      sAxiWriteMaster  : in  AxiWriteMasterType;
      sAxiWriteSlave   : out AxiWriteSlaveType;
      -- Master AXI-Lite Interface
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType);
end AxiSocVersalAxiConvt;

architecture mapping of AxiSocVersalAxiConvt is

   component AxiSocVersalAxiConvtCore is
      port (
         aclk           : in  std_logic;
         aresetn        : in  std_logic;
         s_axi_awid     : in  std_logic_vector(15 downto 0);
         s_axi_awaddr   : in  std_logic_vector(31 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(31 downto 0);
         s_axi_wstrb    : in  std_logic_vector(3 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bid      : out std_logic_vector(15 downto 0);
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_arid     : in  std_logic_vector(15 downto 0);
         s_axi_araddr   : in  std_logic_vector(31 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rid      : out std_logic_vector(15 downto 0);
         s_axi_rdata    : out std_logic_vector(31 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(31 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(31 downto 0);
         m_axi_wstrb    : out std_logic_vector(3 downto 0);
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_araddr   : out std_logic_vector(31 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(31 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic
         );
   end component;

   signal plClk  : sl;
   signal plRstL : sl;

   signal dmaClk  : sl;
   signal dmaRst  : sl;
   signal dmaRstL : sl;

   signal readMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal readSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;
   signal writeMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal writeSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;

begin

   readMaster    <= sAxiReadMaster;
   sAxiReadSlave <= readSlave;

   writeMaster    <= sAxiWriteMaster;
   sAxiWriteSlave <= writeSlave;

   U_IpCore : AxiSocVersalAxiConvtCore
      port map (
         -- Clock and Reset
         aclk           => axiClk,
         aresetn        => axiRstL,
         -- Slave AXI4 InterfaceQuick Access
         s_axi_awid     => writeMaster.awid(15 downto 0),
         s_axi_awaddr   => writeMaster.awaddr(31 downto 0),
         s_axi_awlen    => writeMaster.awlen(7 downto 0),
         s_axi_awsize   => writeMaster.awsize(2 downto 0),
         s_axi_awburst  => writeMaster.awburst(1 downto 0),
         s_axi_awlock   => writeMaster.awlock(0 downto 0),
         s_axi_awcache  => writeMaster.awcache(3 downto 0),
         s_axi_awprot   => writeMaster.awprot(2 downto 0),
         s_axi_awregion => (others => '0'),
         s_axi_awqos    => writeMaster.awqos(3 downto 0),
         s_axi_awvalid  => writeMaster.awvalid,
         s_axi_awready  => writeSlave.awready,
         s_axi_wdata    => writeMaster.wdata(31 downto 0),
         s_axi_wstrb    => writeMaster.wstrb(3 downto 0),
         s_axi_wlast    => writeMaster.wlast,
         s_axi_wvalid   => writeMaster.wvalid,
         s_axi_wready   => writeSlave.wready,
         s_axi_bid      => writeSlave.bid(15 downto 0),
         s_axi_bresp    => writeSlave.bresp(1 downto 0),
         s_axi_bvalid   => writeSlave.bvalid,
         s_axi_bready   => writeMaster.bready,
         s_axi_arid     => readMaster.arid(15 downto 0),
         s_axi_araddr   => readMaster.araddr(31 downto 0),
         s_axi_arlen    => readMaster.arlen(7 downto 0),
         s_axi_arsize   => readMaster.arsize(2 downto 0),
         s_axi_arburst  => readMaster.arburst(1 downto 0),
         s_axi_arlock   => readMaster.arlock(0 downto 0),
         s_axi_arcache  => readMaster.arcache(3 downto 0),
         s_axi_arprot   => readMaster.arprot(2 downto 0),
         s_axi_arregion => (others => '0'),
         s_axi_arqos    => readMaster.arqos(3 downto 0),
         s_axi_arvalid  => readMaster.arvalid,
         s_axi_arready  => readSlave.arready,
         s_axi_rid      => readSlave.rid(15 downto 0),
         s_axi_rdata    => readSlave.rdata(31 downto 0),
         s_axi_rresp    => readSlave.rresp(1 downto 0),
         s_axi_rlast    => readSlave.rlast,
         s_axi_rvalid   => readSlave.rvalid,
         s_axi_rready   => readMaster.rready,
         -- Master AXI-Lite Interface
         m_axi_awaddr   => mAxilWriteMaster.awaddr,
         m_axi_awprot   => mAxilWriteMaster.awprot,
         m_axi_awvalid  => mAxilWriteMaster.awvalid,
         m_axi_awready  => mAxilWriteSlave.awready,
         m_axi_wdata    => mAxilWriteMaster.wdata,
         m_axi_wstrb    => mAxilWriteMaster.wstrb,
         m_axi_wvalid   => mAxilWriteMaster.wvalid,
         m_axi_wready   => mAxilWriteSlave.wready,
         m_axi_bresp    => mAxilWriteSlave.bresp,
         m_axi_bvalid   => mAxilWriteSlave.bvalid,
         m_axi_bready   => mAxilWriteMaster.bready,
         m_axi_araddr   => mAxilReadMaster.araddr,
         m_axi_arprot   => mAxilReadMaster.arprot,
         m_axi_arvalid  => mAxilReadMaster.arvalid,
         m_axi_arready  => mAxilReadSlave.arready,
         m_axi_rdata    => mAxilReadSlave.rdata,
         m_axi_rresp    => mAxilReadSlave.rresp,
         m_axi_rvalid   => mAxilReadSlave.rvalid,
         m_axi_rready   => mAxilReadMaster.rready);

end mapping;
