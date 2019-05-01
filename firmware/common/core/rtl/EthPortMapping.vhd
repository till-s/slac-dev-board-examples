-------------------------------------------------------------------------------
-- File       : EthPortMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-01-30
-- Last update: 2017-03-17
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Example Project Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;

entity EthPortMapping is
   generic (
      TPD_G           : time             := 1 ns;
      CLK_FREQUENCY_G : real             := 125.0E+6;
      MAC_ADDR_G      : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)
      IP_ADDR_G       : slv(31 downto 0) := x"0A02A8C0";  -- 192.168.2.10 (ETH only)
      DHCP_G          : boolean          := true;
      JUMBO_G         : boolean          := false;
      USE_RSSI_G      : boolean          := true;
      USE_JTAG_G      : boolean          := true;
      USER_UDP_PORT_G : natural          := 0);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- ETH interface
      txMaster        : out AxiStreamMasterType;
      txSlave         : in  AxiStreamSlaveType;
      rxMaster        : in  AxiStreamMasterType;
      rxSlave         : out AxiStreamSlaveType;
      rxCtrl          : out AxiStreamCtrlType   := AXI_STREAM_CTRL_UNUSED_C;
      -- PBRS Interface
      pbrsTxMaster    : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      pbrsTxSlave     : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      pbrsRxMaster    : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      pbrsRxSlave     : in  AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- HLS Interface
      hlsTxMaster     : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      hlsTxSlave      : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      hlsRxMaster     : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      hlsRxSlave      : in  AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- MB Interface
      mbTxMaster      : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      mbTxSlave       : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- raw UDP Interface
      udpTxMaster     : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      udpTxSlave      : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      udpRxMaster     : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      udpRxSlave      : in  AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- AXI-Lite Interface
      axilWriteMaster : out AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : in  AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
      axilReadMaster  : out AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : in  AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C
   );
end EthPortMapping;

architecture mapping of EthPortMapping is

   constant MB_STREAM_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 4,
      TID_BITS_C    => 4,
      TKEEP_MODE_C  => TKEEP_NORMAL_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_LAST_C);

   constant JTAG_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 0,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_FIXED_C,
      TUSER_BITS_C  => 0,
      TUSER_MODE_C  => TUSER_NONE_C);

   constant NUM_SERVERS_C  : integer                                 := ite(USE_RSSI_G, 1, 0) + ite(USE_JTAG_G, 1, 0) + ite(USER_UDP_PORT_G /= 0, 1, 0);

   constant RSSI_UDP_IDX_C : natural := 0;
   constant JTAG_UDP_IDX_C : natural := RSSI_UDP_IDX_C + ite(USE_RSSI_G, 1, 0);
   constant USER_UDP_IDX_C : natural := JTAG_UDP_IDX_C + ite(USE_JTAG_G, 1, 0);

   function udpServerPorts return PositiveArray is
   variable rval : PositiveArray(NUM_SERVERS_C - 1 downto 0);
   variable idx  : natural;
   begin
      idx := 0;
      if ( USE_RSSI_G ) then
         rval(idx) := 8192;
         idx       := idx + 1;
      end if;
      if ( USE_JTAG_G ) then
         rval(idx) := 2542;
         idx       := idx + 1;
      end if;
      if ( USER_UDP_PORT_G /= 0 ) then
         rval(idx) := USER_UDP_PORT_G;
         idx       := idx + 1;
      end if;
      return rval;
   end function udpServerPorts;

   constant SERVER_PORTS_C : PositiveArray(NUM_SERVERS_C-1 downto 0) := udpServerPorts;

   constant RSSI_SIZE_C : positive := 4;
   constant AXIS_CONFIG_C : AxiStreamConfigArray(RSSI_SIZE_C-1 downto 0) := (
      0 => ssiAxiStreamConfig(4),
      1 => ssiAxiStreamConfig(4),
      2 => ssiAxiStreamConfig(4),
      3 => MB_STREAM_CONFIG_C);

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

   signal rssiIbMasters   : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiIbSlaves    : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObMasters   : AxiStreamMasterArray(RSSI_SIZE_C-1 downto 0);
   signal rssiObSlaves    : AxiStreamSlaveArray(RSSI_SIZE_C-1 downto 0);

   signal spliceSOF       : AxiStreamMasterType;

begin

   ----------------------
   -- IPv4/ARP/UDP Engine
   ----------------------
   U_UDP : entity work.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => NUM_SERVERS_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false,
         -- General IPv4/ARP/DHCP Generics
         DHCP_G         => DHCP_G,
         CLK_FREQ_G     => CLK_FREQUENCY_G,
         COMM_TIMEOUT_G => 30)
      port map (
         -- Local Configurations
         localMac        => MAC_ADDR_G,
         localIp         => IP_ADDR_G,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => rxMaster,
         obMacSlave      => rxSlave,
         ibMacMaster     => txMaster,
         ibMacSlave      => txSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => clk,
         rst             => rst);

   GEN_RSSI : if (USE_RSSI_G) generate

   ------------------------------------------
   -- Software's RSSI Server Interface @ 8192
   ------------------------------------------
   U_RssiServer : entity work.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         MAX_SEG_SIZE_G      => 1024,
         SEGMENT_ADDR_SIZE_G => 7,
         APP_STREAMS_G       => RSSI_SIZE_C,
         APP_STREAM_ROUTES_G => (
            0                => X"00",
            1                => X"01",
            2                => X"02",
            3                => X"03"),
         CLK_FREQUENCY_G     => CLK_FREQUENCY_G,
         TIMEOUT_UNIT_G      => 1.0E-3,  -- In units of seconds
         SERVER_G            => true,
         RETRANSMIT_ENABLE_G => true,
         BYPASS_CHUNKER_G    => false,
         WINDOW_ADDR_SIZE_G  => 3,
         PIPE_STAGES_G       => 1,
         APP_AXIS_CONFIG_G   => AXIS_CONFIG_C,
         TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
         INIT_SEQ_N_G        => 16#80#
      )
      port map (
         clk_i             => clk,
         rst_i             => rst,
         openRq_i          => '1',
         -- Application Layer Interface
         sAppAxisMasters_i => rssiIbMasters,
         sAppAxisSlaves_o  => rssiIbSlaves,
         mAppAxisMasters_o => rssiObMasters,
         mAppAxisSlaves_i  => rssiObSlaves,
         -- Transport Layer Interface
         sTspAxisMaster_i  => obServerMasters(RSSI_UDP_IDX_C),
         sTspAxisSlave_o   => obServerSlaves (RSSI_UDP_IDX_C),
         mTspAxisMaster_o  => ibServerMasters(RSSI_UDP_IDX_C),
         mTspAxisSlave_i   => ibServerSlaves (RSSI_UDP_IDX_C)
      );

   ---------------------------------------
   -- TDEST = 0x0: Register access control
   ---------------------------------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C(0)
      )
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain)
         sAxisClk         => clk,
         sAxisRst         => rst,
         sAxisMaster      => rssiObMasters(0),
         sAxisSlave       => rssiObSlaves(0),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => clk,
         mAxisRst         => rst,
         mAxisMaster      => rssiIbMasters(0),
         mAxisSlave       => rssiIbSlaves(0),
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => clk,
         axilRst          => rst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave
      );

   --------------------------
   -- TDEST = 0x1: TX/RX PBRS
   --------------------------
   rssiIbMasters(1) <= pbrsTxMaster;
   pbrsTxSlave      <= rssiIbSlaves(1);
   pbrsRxMaster     <= rssiObMasters(1);
   rssiObSlaves(1)  <= pbrsRxSlave;

   ------------------------
   -- TDEST = 0x2: HLS AXIS
   ------------------------
   rssiIbMasters(2) <= hlsTxMaster;
   hlsTxSlave       <= rssiIbSlaves(2);
   hlsRxMaster      <= rssiObMasters(2);
   rssiObSlaves(2)  <= hlsRxSlave;

   --------------------------
   -- TDEST = 0x3: TX/RX PBRS
   --------------------------
   rssiIbMasters(3) <= mbTxMaster;
   mbTxSlave        <= rssiIbSlaves(3);

   ------------------------------
   -- Terminate Unused interfaces
   ------------------------------
   rssiObSlaves(3) <= AXI_STREAM_SLAVE_FORCE_C;

   end generate; -- if USE_RSSI_G


   GEN_JTAG : if ( USE_JTAG_G ) generate

   P_SPLICE : process(spliceSOF)
      variable v : AxiStreamMasterType;
   begin
      v                   := spliceSOF;
      v.tUser(1 downto 0) := "10";
      ibServerMasters(JTAG_UDP_IDX_C)  <= v;
   end process P_SPLICE;


   U_AxisBscan : entity work.AxisJtagDebugBridge
      generic map (
         TPD_G        => TPD_G,
         AXIS_WIDTH_G => EMAC_AXIS_CONFIG_C.TDATA_BYTES_C,
         AXIS_FREQ_G  => CLK_FREQUENCY_G,
         CLK_DIV2_G   => 5,
         MEM_DEPTH_G  => (2048/EMAC_AXIS_CONFIG_C.TDATA_BYTES_C)
      )
      port map (
         axisClk      => clk,
         axisRst      => rst,

         mAxisReq     => obServerMasters(JTAG_UDP_IDX_C),
         sAxisReq     => obServerSlaves (JTAG_UDP_IDX_C),

         mAxisTdo     => spliceSOF,
         sAxisTdo     => ibServerSlaves (JTAG_UDP_IDX_C)
      );
   end generate; -- if USE_JTAG_G

   GEN_USER_UDP : if ( USER_UDP_PORT_G /= 0 ) generate
      ibServerMasters(USER_UDP_IDX_C) <= udpTxMaster;
      udpTxSlave                      <= ibServerSlaves (USER_UDP_IDX_C);
      udpRxMaster                     <= obServerMasters(USER_UDP_IDX_C);
      obServerSlaves (USER_UDP_IDX_C) <= udpRxSlave;
   end generate; -- if USER_UDP_PORT_G /= 0

end mapping;
