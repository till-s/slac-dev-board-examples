-------------------------------------------------------------------------------
-- File       : AppCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-15
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
use work.AxiLitePkg.all;
use work.TimingConnectorPkg.all;
use work.TimingPkg.all;

entity AppCore is
   generic (
      TPD_G                   : time             := 1 ns;
      BUILD_INFO_G            : BuildInfoType;
      XIL_DEVICE_G            : string           := "7SERIES";
      AXIL_BASE_ADDR_G        : slv(31 downto 0) := x"00000000";
      APP_TYPE_G              : string           := "ETH";
      AXIS_SIZE_G             : positive         := 1;
      MAC_ADDR_G              : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)
      IP_ADDR_G               : slv(31 downto 0) := x"0A02A8C0";  -- 192.168.2.10 (ETH only)
      DHCP_G                  : boolean          := true;
      JUMBO_G                 : boolean          := false;
      USE_RSSI_G              : boolean          := true;
      USE_JTAG_G              : boolean          := true;
      USER_UDP_PORT_G         : natural          := 0;
      AXIL_CLK_FREQUENCY_G    : real             := 50.0E6;
      TPGMINI_G               : boolean          := true;
      GEN_TIMING_G            : boolean          := true;
      TIMING_UDP_MSG_G        : boolean          := true;
      TIMING_GTP_HAS_COMMON_G : boolean          := true;
      NUM_TRIGS_G             : natural          := 8;
      TIMING_TRIG_INVERT_G    : slv              := ""; -- slv(NUM_TRIGS_G - 1 downto 0) -- defaults to all '0' when empty
      NUM_AXIL_SLAVES_G       : natural          := 1
   );
   port (
      -- Clock and Reset
      clk              : in  sl;
      rst              : in  sl;
      -- AXIS interface
      txMasters        : out AxiStreamMasterArray(AXIS_SIZE_G-1 downto 0);
      txSlaves         : in  AxiStreamSlaveArray (AXIS_SIZE_G-1 downto 0) := (others => AXI_STREAM_SLAVE_FORCE_C);
      rxMasters        : in  AxiStreamMasterArray(AXIS_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      rxSlaves         : out AxiStreamSlaveArray (AXIS_SIZE_G-1 downto 0);
      rxCtrl           : out AxiStreamCtrlArray  (AXIS_SIZE_G-1 downto 0);

      sAxilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      sAxilReadSlave   : out AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
      sAxilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      sAxilWriteSlave  : out AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;

      mAxilReadMasters : out AxiLiteReadMasterArray (NUM_AXIL_SLAVES_G - 1 downto 0) := (others => AXI_LITE_READ_MASTER_INIT_C);
      mAxilReadSlaves  : in  AxiLiteReadSlaveArray  (NUM_AXIL_SLAVES_G - 1 downto 0) := (others => AXI_LITE_READ_SLAVE_INIT_C);
      mAxilWriteMasters: out AxiLiteWriteMasterArray(NUM_AXIL_SLAVES_G - 1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
      mAxilWriteSlaves : in  AxiLiteWriteSlaveArray (NUM_AXIL_SLAVES_G - 1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_INIT_C);
      -- Timing MGT
      timingIb         : in  TimingWireIbType := TIMING_WIRE_IB_INIT_C;
      timingOb         : out TimingWireObType := TIMING_WIRE_OB_INIT_C;
      timingRx         : out TimingRxType     := TIMING_RX_INIT_C;
      -- IRQ
      irqOut           : out slv(7 downto 0);
      -- ADC Ports
      vPIn             : in  sl;
      vNIn             : in  sl;
      -- Config
      macAddrOut       : out slv(47 downto 0)
   );
end AppCore;

architecture mapping of AppCore is

   signal sAxilReadMasters : AxiLiteReadMasterArray (1 downto 0) := (others => AXI_LITE_READ_MASTER_INIT_C );
   signal sAxilReadSlaves  : AxiLiteReadSlaveArray  (1 downto 0) := (others => AXI_LITE_READ_SLAVE_INIT_C  );
   signal sAxilWriteMasters: AxiLiteWriteMasterArray(1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal sAxilWriteSlaves : AxiLiteWriteSlaveArray (1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_INIT_C );

   signal pbrsTxMaster     : AxiStreamMasterType;
   signal pbrsTxSlave      : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
   signal pbrsRxMaster     : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal pbrsRxSlave      : AxiStreamSlaveType;

   signal hlsTxMaster      : AxiStreamMasterType;
   signal hlsTxSlave       : AxiStreamSlaveType   := AXI_STREAM_SLAVE_FORCE_C;
   signal hlsRxMaster      : AxiStreamMasterType  := AXI_STREAM_MASTER_INIT_C;
   signal hlsRxSlave       : AxiStreamSlaveType;

   signal mbTxMaster       : AxiStreamMasterType;
   signal mbTxSlave        : AxiStreamSlaveType    := AXI_STREAM_SLAVE_FORCE_C;
   signal mbRxMaster       : AxiStreamMasterType   := AXI_STREAM_MASTER_INIT_C;
   signal mbRxSlave        : AxiStreamSlaveType;

   signal timingTxMaster   : AxiStreamMasterType;
   signal timingTxSlave    : AxiStreamSlaveType   := AXI_STREAM_SLAVE_FORCE_C;
   signal timingRxMaster   : AxiStreamMasterType  := AXI_STREAM_MASTER_INIT_C;
   signal timingRxSlave    : AxiStreamSlaveType;

   signal macAddr          : slv(47 downto 0);
   signal ipAddr           : slv(31 downto 0);

begin

   GEN_ETH : if (APP_TYPE_G = "ETH") generate
      --------------------------
      -- UDP Port Mapping Module
      --------------------------
      U_EthPortMapping : entity work.EthPortMapping
         generic map (
            TPD_G           => TPD_G,
            MAC_ADDR_G      => MAC_ADDR_G,
            IP_ADDR_G       => IP_ADDR_G,
            DHCP_G          => DHCP_G,
            JUMBO_G         => JUMBO_G,
            USE_RSSI_G      => USE_RSSI_G,
            USE_JTAG_G      => USE_JTAG_G,
            USER_UDP_PORT_G => USER_UDP_PORT_G,
            CLK_FREQUENCY_G => AXIL_CLK_FREQUENCY_G
         )
         port map (
            -- Clock and Reset
            clk             => clk,
            rst             => rst,
            -- Config
            macAddrIn       => macAddr,
            ipAddrIn        => ipAddr,
            -- AXIS interface
            txMaster        => txMasters(0),
            txSlave         => txSlaves(0),
            rxMaster        => rxMasters(0),
            rxSlave         => rxSlaves(0),
            rxCtrl          => rxCtrl(0),
            -- PBRS Interface
            pbrsTxMaster    => pbrsTxMaster,
            pbrsTxSlave     => pbrsTxSlave,
            pbrsRxMaster    => pbrsRxMaster,
            pbrsRxSlave     => pbrsRxSlave,
            -- HLS Interface
            hlsTxMaster     => hlsTxMaster,
            hlsTxSlave      => hlsTxSlave,
            hlsRxMaster     => hlsRxMaster,
            hlsRxSlave      => hlsRxSlave,
            -- AXI-Lite interface
            axilWriteMaster => sAxilWriteMasters(0),
            axilWriteSlave  => sAxilWriteSlaves (0),
            axilReadMaster  => sAxilReadMasters (0),
            axilReadSlave   => sAxilReadSlaves  (0),
            -- Microblaze stream
            mbTxMaster      => mbTxMaster,
            mbTxSlave       => mbTxSlave,
            mbRxMaster      => mbRxMaster,
            mbRxSlave       => mbRxSlave,
            -- Timing stream
            udpTxMaster     => timingTxMaster,
            udpTxSlave      => timingTxSlave,
            udpRxMaster     => timingRxMaster,
            udpRxSlave      => timingRxSlave
         );

   end generate;

   sAxilWriteMasters(1) <= sAxilWriteMaster;
   sAxilWriteSlave      <= sAxilWriteSlaves(1);
   sAxilReadMasters(1)  <= sAxilReadMaster;
   sAxilReadSlave       <= sAxilReadSlaves(1);

   -------------------
   -- AXI-Lite Modules
   -------------------
   U_Reg : entity work.AppReg
      generic map (
         TPD_G                   => TPD_G,
         BUILD_INFO_G            => BUILD_INFO_G,
         XIL_DEVICE_G            => XIL_DEVICE_G,
         AXIL_BASE_ADDR_G        => AXIL_BASE_ADDR_G,
         AXIL_CLK_FREQ_G         => AXIL_CLK_FREQUENCY_G,
         MAC_ADDR_G              => MAC_ADDR_G,
         IP_ADDR_G               => IP_ADDR_G,
         USE_SLOWCLK_G           => true,
         TPGMINI_G               => TPGMINI_G,
         GEN_TIMING_G            => GEN_TIMING_G,
         TIMING_UDP_MSG_G        => TIMING_UDP_MSG_G,
         TIMING_GTP_HAS_COMMON_G => TIMING_GTP_HAS_COMMON_G,
         INVERT_TRIG_POLARITY_G  => TIMING_TRIG_INVERT_G,
         NUM_EXT_SLAVES_G        => NUM_AXIL_SLAVES_G,
         NUM_TRIGS_G             => NUM_TRIGS_G
      )
      port map (
         -- Clock and Reset
         clk                  => clk,
         rst                  => rst,
         -- AXI-Lite interface
         sAxilWriteMasters    => sAxilWriteMasters,
         sAxilWriteSlaves     => sAxilWriteSlaves,
         sAxilReadMasters     => sAxilReadMasters,
         sAxilReadSlaves      => sAxilReadSlaves,

         axilReadMasters      => mAxilReadMasters,
         axilReadSlaves       => mAxilReadSlaves,
         axilWriteMasters     => mAxilWriteMasters,
         axilWriteSlaves      => mAxilWriteSlaves,
         -- PBRS Interface
         pbrsTxMaster         => pbrsTxMaster,
         pbrsTxSlave          => pbrsTxSlave,
         pbrsRxMaster         => pbrsRxMaster,
         pbrsRxSlave          => pbrsRxSlave,
         -- HLS Interface
         hlsTxMaster          => hlsTxMaster,
         hlsTxSlave           => hlsTxSlave,
         hlsRxMaster          => hlsRxMaster,
         hlsRxSlave           => hlsRxSlave,
         -- Microblaze stream
         mbTxMaster           => mbTxMaster,
         mbTxSlave            => mbTxSlave,
         mbRxMaster           => mbRxMaster,
         mbRxSlave            => mbRxSlave,
         -- Timing
         timingIb             => timingIb,
         timingOb             => timingOb,
         timingRx             => timingRx,

         obTimingEthMsgMaster => timingTxMaster,
         obTimingEthMsgSlave  => timingTxSlave,
         ibTimingEthMsgMaster => timingRxMaster,
         ibTimingEthMsgSlave  => timingRxSlave,
         -- ADC Ports
         vPIn                 => vPIn,
         vNIn                 => vNIn,
         -- IRQ Ports
         irqOut               => irqOut,
         -- Config
         macAddrOut           => macAddr,
         ipAddrOut            => ipAddr
      );

   macAddrOut <= macAddr;

end mapping;
