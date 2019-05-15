-------------------------------------------------------------------------------
-- File       : AppReg.vhd
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
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.TimingPkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AppReg is
   generic (
      TPD_G            : time             := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      XIL_DEVICE_G     : string           := "7SERIES";
      AXIL_BASE_ADDR_G : slv(31 downto 0) := x"00000000";
      IP_ADDR_G        : slv(31 downto 0) := x"410AA8C0";      -- 192.168.2.10 (ETH only)
      MAC_ADDR_G       : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01 (ETH only)
      USE_SLOWCLK_G    : boolean          := false;
      NUM_TRIGS_G      : natural          := 8;
      TPGMINI_G        : boolean          := true;
      GEN_TIMING_G     : boolean          := true;
      TIMING_UDP_MSG_G : boolean          := false;
      NUM_EXT_SLAVES_G : natural          := 1;
      INVERT_POLARITY_G: slv              := ""; -- slv(NUM_TRIGS_G - 1 downto 0) -- defaults to all '0' when empty
      USE_ILAS_G       : slv(1 downto 0)  := "00");
   port (
      -- Clock and Reset
      clk                  : in  sl;
      rst                  : in  sl;
      -- AXI-Lite interface
      axilWriteMaster      : in  AxiLiteWriteMasterType;
      axilWriteSlave       : out AxiLiteWriteSlaveType;
      axilReadMaster       : in  AxiLiteReadMasterType;
      axilReadSlave        : out AxiLiteReadSlaveType;
      -- PBRS Interface
      pbrsTxMaster         : out AxiStreamMasterType;
      pbrsTxSlave          : in  AxiStreamSlaveType;
      pbrsRxMaster         : in  AxiStreamMasterType;
      pbrsRxSlave          : out AxiStreamSlaveType;
      -- MB Interface
      mbTxMaster           : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      mbTxSlave            : in  AxiStreamSlaveType;
      mbRxMaster           : in  AxiStreamMasterType;
      mbRxSlave            : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- ADC Ports
      vPIn                 : in  sl;
      vNIn                 : in  sl;
      -- Timing
      timingRefClkP        : in  sl := '0';
      timingRefClkN        : in  sl := '1';
      timingRecClk         : out sl := '0';
      timingRecRst         : out sl := '0';
      timingRxP            : in  sl := '0';
      timingRxN            : in  sl := '1';
      timingTxP            : out sl;
      timingTxN            : out sl;
      timingTrig           : out TimingTrigType;
      timingTxStat         : out TimingPhyStatusType;
      timingRxStat         : out TimingPhyStatusType;
      timingTxClk          : out sl;
      ibTimingEthMsgMaster : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      ibTimingEthMsgSlave  : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      obTimingEthMsgMaster : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      obTimingEthMsgSlave  : in  AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- IRQ
      irqOut               : out slv(7 downto 0)    := (others => '0');
      -- AXI Lite (external slaves)
      axilReadMasters      : out AxiLiteReadMasterArray (NUM_EXT_SLAVES_G - 1 downto 0);
      axilReadSlaves       : in  AxiLiteReadSlaveArray  (NUM_EXT_SLAVES_G - 1 downto 0);
      axilWriteMasters     : out AxiLiteWriteMasterArray(NUM_EXT_SLAVES_G - 1 downto 0);
      axilWriteSlaves      : in  AxiLiteWriteSlaveArray (NUM_EXT_SLAVES_G - 1 downto 0);
      macAddrOut           : out slv(47 downto 0);
      ipAddrOut            : out slv(31 downto 0)
   );
end AppReg;

architecture mapping of AppReg is

   constant NUM_LOC_IRQS_C     : natural := 2;

   constant AXIL_CLK_FREQ_C    : real := 50.0E6;
   constant CLK_PERIOD_C       : real := 1.0/AXIL_CLK_FREQ_C;


   constant SHARED_MEM_WIDTH_C : positive                           := 10;
   constant IRQ_ADDR_C         : slv(SHARED_MEM_WIDTH_C-1 downto 0) := (others => '1');

   constant NUM_WRITE_REG_C    : natural := 5;

   constant MISC_CTL_IDX_C  : natural := 0;
   constant IRQ_CTL_IDX_C   : natural := 1;
   constant IP_ADDR_IDX_C   : natural := 2;
   constant MAC_ADDR_IDX_C  : natural := 3;

   constant INI_WRITE_REG_C : Slv32Array(NUM_WRITE_REG_C - 1 downto 0) := (
      MiSC_CTL_IDX_C     => x"0000_0000",
      IRQ_CTL_IDX_C      => x"0000_0000",
      IP_ADDR_IDX_C      => IP_ADDR_G,
      MAC_ADDR_IDX_C     => MAC_ADDR_G(31 downto 0),
      MAC_ADDR_IDX_C + 1 => (x"0000" & MAC_ADDR_G(47 downto 32))
   );

   constant NUM_READ_REG_C     : natural := 3;

   constant TX_CLK_CNT_IDX_C   : natural := 0;
   constant TIMING_STA_IDX_C   : natural := 1;
   constant IRQ_STA_IDX_C      : natural := 2;

   constant NUM_AXI_MASTERS_C  : natural := 10 + NUM_EXT_SLAVES_G;

   constant VERSION_INDEX_C : natural := 0;
   constant XADC_INDEX_C    : natural := 1;
   constant SYS_MON_INDEX_C : natural := 2;
   constant MEM_INDEX_C     : natural := 3;
   constant PRBS_TX_INDEX_C : natural := 4;
   constant PRBS_RX_INDEX_C : natural := 5;
   constant FIFO_INDEX_C    : natural := 6;
   constant TIM_GTX_INDEX_C : natural := 7;
   constant TIM_COR_INDEX_C : natural := 8;
   constant TIM_TRG_INDEX_C : natural := 9;
   constant EXT_SLV_INDEX_C : natural :=10;


   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) :=
      genAxiLiteConfig( NUM_AXI_MASTERS_C, AXIL_BASE_ADDR_G, 24, 20 );

   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := ( others => AXI_LITE_WRITE_SLAVE_INIT_C );
   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0)  := ( others => AXI_LITE_READ_SLAVE_INIT_C );

   signal axiWrValid : sl;
   signal axiWrAddr  : slv(SHARED_MEM_WIDTH_C-1 downto 0);

   signal rstN       : sl;

   signal writeRegsLoc : Slv32Array(NUM_WRITE_REG_C-1 downto 0);
   signal readRegsLoc  : Slv32Array(NUM_READ_REG_C-1 downto 0) := (others => (others => '0'));
   signal cntLoc       : slv(31 downto 0);


   signal timingRefClk      : sl := '0';
   signal timingRecClkLoc   : sl := '0';
   signal timingRecRstLoc   : sl := '1';
   signal timingTxUsrClk    : sl := '0';
   signal timingTxUsrRst    : sl := '1';
   signal timingTxUsrRstEnb : sl := '1';
   signal timingTxRstAllAxi : sl;
   signal timingTxRstAllTmg : sl;
   signal timingCdrStable   : sl;
   signal timingLoopback    : slv(2 downto 0) := "000";
   signal timingClkSel      : sl;
   signal timingLoopbackSel : slv(2 downto 0) := "000";

   signal timingRefCnt      : unsigned(31 downto 0) := x"0000_0000";

   signal timingTxPhy       : TimingPhyType;
   signal timingTxPhyLoc    : TimingPhyType;
   signal timingRxPhy       : TimingRxType;
   signal timingRxControl   : TimingPhyControlType;
   signal timingRxStatus    : TimingPhyStatusType := TIMING_PHY_STATUS_INIT_C;
   signal timingTxStatus    : TimingPhyStatusType := TIMING_PHY_STATUS_INIT_C;
   signal timingTxRstAsyn   : sl;

   signal timingBus         : TimingBusType;
   signal appTimingMode     : sl;
   signal appTimingTrig     : TimingTrigType;

   signal appTimingClk      : sl;
   signal appTimingRst      : sl;

   signal axilReadSlaveLoc  : AxiLiteReadSlaveType;
   signal axilWriteSlaveLoc : AxiLiteWriteSlaveType;

   signal locIrqs           : slv(NUM_LOC_IRQS_C - 1 downto 0);

begin

   rstN <= not rst;

   axilReadSlave  <= axilReadSlaveLoc;
   axilWriteSlave <= axilWriteSlaveLoc;

   axilReadMasters (NUM_EXT_SLAVES_G - 1 downto 0) <= mAxilReadMasters (NUM_EXT_SLAVES_G + EXT_SLV_INDEX_C - 1 downto EXT_SLV_INDEX_C);
   axilWriteMasters(NUM_EXT_SLAVES_G - 1 downto 0) <= mAxilWriteMasters(NUM_EXT_SLAVES_G + EXT_SLV_INDEX_C - 1 downto EXT_SLV_INDEX_C);
   mAxilReadSlaves (NUM_EXT_SLAVES_G + EXT_SLV_INDEX_C - 1 downto EXT_SLV_INDEX_C) <= axilReadSlaves (NUM_EXT_SLAVES_G - 1 downto 0);
   mAxilWriteSlaves(NUM_EXT_SLAVES_G + EXT_SLV_INDEX_C - 1 downto EXT_SLV_INDEX_C) <= axilWriteSlaves(NUM_EXT_SLAVES_G - 1 downto 0);

   ---------------------------
   -- AXI-Lite Crossbar Module
   ---------------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlaveLoc,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlaveLoc,
         mAxiWriteMasters    => mAxilWriteMasters,
         mAxiWriteSlaves     => mAxilWriteSlaves,
         mAxiReadMasters     => mAxilReadMasters,
         mAxiReadSlaves      => mAxilReadSlaves,
         axiClk              => clk,
         axiClkRst           => rst);

   GEN_ILA_0 : if ( (USE_ILAS_G and "01") /= "00") generate

   U_Ila_0 : entity work.IlaAxiLite
      port map (
         axilClk        => clk,

         mAxilRead      => axilReadMaster,
         sAxilRead      => axilReadSlaveLoc,
         mAxilWrite     => axilWriteMaster,
         sAxilWrite     => axilWriteSlaveLoc
      );
   end generate;

   ---------------------------
   -- AXI-Lite: Version Module
   ---------------------------
   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G            => TPD_G,
         BUILD_INFO_G     => BUILD_INFO_G,
         XIL_DEVICE_G     => XIL_DEVICE_G,
         EN_DEVICE_DNA_G  => true,
         CLK_PERIOD_G     => CLK_PERIOD_C,
         USE_SLOWCLK_G    => USE_SLOWCLK_G)
      port map (
         axiReadMaster  => mAxilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(VERSION_INDEX_C),
         axiClk         => clk,
         axiRst         => rst);

   GEN_7SERIES : if (XIL_DEVICE_G = "7SERIES") generate
      ------------------------
      -- AXI-Lite: XADC Module
      ------------------------
      U_XADC : entity work.AxiXadcWrapper
         generic map (
            TPD_G            => TPD_G
         )
         port map (
            axiReadMaster  => mAxilReadMasters(XADC_INDEX_C),
            axiReadSlave   => mAxilReadSlaves(XADC_INDEX_C),
            axiWriteMaster => mAxilWriteMasters(XADC_INDEX_C),
            axiWriteSlave  => mAxilWriteSlaves(XADC_INDEX_C),
            axiClk         => clk,
            axiRst         => rst,
            vPIn           => vPIn,
            vNIn           => vNIn);

      --------------------------
      -- AXI-Lite: SYSMON Module
      --------------------------
      mAxilReadSlaves (SYS_MON_INDEX_C) <= AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      mAxilWriteSlaves(SYS_MON_INDEX_C) <= AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   end generate;

   GEN_ULTRA_SCALE : if (XIL_DEVICE_G = "ULTRASCALE") generate
      ------------------------
      -- AXI-Lite: XADC Module
      ------------------------
      mAxilReadSlaves (XADC_INDEX_C) <= AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      mAxilWriteSlaves(XADC_INDEX_C) <= AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

      --------------------------
      -- AXI-Lite: SYSMON Module
      --------------------------
      U_SysMon : entity work.SystemManagementWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            axiReadMaster  => mAxilReadMasters(SYS_MON_INDEX_C),
            axiReadSlave   => mAxilReadSlaves(SYS_MON_INDEX_C),
            axiWriteMaster => mAxilWriteMasters(SYS_MON_INDEX_C),
            axiWriteSlave  => mAxilWriteSlaves(SYS_MON_INDEX_C),
            axiClk         => clk,
            axiRst         => rst,
            vPIn           => vPIn,
            vNIn           => vNIn);
   end generate;

   --------------------------------
   -- AXI-Lite Shared Memory Module
   --------------------------------
   U_Mem : entity work.AxiDualPortRam
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => true,
         REG_EN_G     => true,
         AXI_WR_EN_G  => true,
         SYS_WR_EN_G  => false,
         COMMON_CLK_G => false,
         ADDR_WIDTH_G => SHARED_MEM_WIDTH_C,
         DATA_WIDTH_G => 32)
      port map (
         -- Clock and Reset
         clk            => clk,
         rst            => rst,
         -- AXI-Lite Write Monitor
         axiWrValid     => axiWrValid,
         axiWrAddr      => axiWrAddr,
         -- AXI-Lite Interface
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(MEM_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(MEM_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(MEM_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(MEM_INDEX_C));

   -------------------
   -- AXI-Lite PRBS RX
   -------------------
   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map (
         TPD_G                      => TPD_G,
         MASTER_AXI_PIPE_STAGES_G   => 1,
         MASTER_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         mAxisClk        => clk,
         mAxisRst        => rst,
         mAxisMaster     => pbrsTxMaster,
         mAxisSlave      => pbrsTxSlave,
         locClk          => clk,
         locRst          => rst,
         trig            => '0',
         packetLength    => X"000000ff",
         tDest           => X"00",
         tId             => X"00",
         axilReadMaster  => mAxilReadMasters(PRBS_TX_INDEX_C),
         axilReadSlave   => mAxilReadSlaves(PRBS_TX_INDEX_C),
         axilWriteMaster => mAxilWriteMasters(PRBS_TX_INDEX_C),
         axilWriteSlave  => mAxilWriteSlaves(PRBS_TX_INDEX_C));

   -------------------
   -- AXI-Lite PRBS RX
   -------------------
   U_SsiPrbsRx : entity work.SsiPrbsRx
      generic map (
         TPD_G                     => TPD_G,
         SLAVE_AXI_STREAM_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         sAxisClk       => clk,
         sAxisRst       => rst,
         sAxisMaster    => pbrsRxMaster,
         sAxisSlave     => pbrsRxSlave,
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(PRBS_RX_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(PRBS_RX_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(PRBS_RX_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(PRBS_RX_INDEX_C));

   cntLoc <= slv( timingRefCnt );

   U_SYNC_CLK_CNT : entity work.SynchronizerVector
      generic map (
         WIDTH_G => 32
      )
      port map(
         clk     => clk,
         rst     => rst,
         dataIn  => cntLoc,
         dataOut => readRegsLoc(TX_CLK_CNT_IDX_C)
      );

   U_SYNC_RX_STAT : entity work.SynchronizerVector
      generic map (
         WIDTH_G => 5
      )
      port map(
         clk        => clk,
         rst        => rst,
         dataIn(0)  => timingRxStatus.resetDone,
         dataIn(1)  => timingRxStatus.locked,
         dataIn(2)  => timingRxStatus.bufferByDone,
         dataIn(3)  => timingRxStatus.bufferByErr,
         dataIn(4)  => timingTxStatus.resetDone,
         dataOut    => readRegsLoc(TIMING_STA_IDX_C)(4 downto 0)
      );

   U_LOC_REGS : entity work.AxiLiteRegs
      generic map (
         TPD_G            => TPD_G,
         NUM_WRITE_REG_G  => NUM_WRITE_REG_C,
         INI_WRITE_REG_G  => INI_WRITE_REG_C,
         NUM_READ_REG_G   => NUM_READ_REG_C
      )
      port map (
         -- AXI-Lite Bus
         axiClk           => clk,
         axiClkRst        => rst,
         axiReadMaster    => mAxilReadMasters(FIFO_INDEX_C),
         axiReadSlave     => mAxilReadSlaves(FIFO_INDEX_C),
         axiWriteMaster   => mAxilWriteMasters(FIFO_INDEX_C),
         axiWriteSlave    => mAxilWriteSlaves(FIFO_INDEX_C),
         -- User Read/Write registers
         writeRegister    => writeRegsLoc,
         readRegister     => readRegsLoc
     );

   timingTxRstAllAxi <= writeRegsLoc(MISC_CTL_IDX_C)(0);

   ipAddrOut                <= writeRegsLoc(IP_ADDR_IDX_C);
   macAddrOut(31 downto  0) <= writeRegsLoc(MAC_ADDR_IDX_C    )(31 downto 0);
   macAddrOut(47 downto 32) <= writeRegsLoc(MAC_ADDR_IDX_C + 1)(15 downto 0);

   GEN_TIMING : if ( GEN_TIMING_G ) generate
      signal clkAlwaysActive : sl := '1';
   begin

   P_TIMING_REF_CNT : process ( timingRefClk ) is
   begin
      if ( rising_edge( timingRefClk ) ) then
         timingRefCnt <= timingRefCnt + 1;
      end if;
   end process P_TIMING_REF_CNT;

   U_TimingGt : entity work.TimingGtCoreWrapper
      generic map (
         TPD_G              => TPD_G,
         AXIL_CLK_FREQ_G    => AXIL_CLK_FREQ_C,
         AXIL_BASE_ADDR_G   => AXI_CROSSBAR_MASTERS_CONFIG_C(TIM_GTX_INDEX_C).baseAddr
      )
      port map (
         axilClk            => clk,
         axilRst            => rst,

         axilReadMaster     => mAxilReadMasters (TIM_GTX_INDEX_C),
         axilReadSlave      => mAxilReadSlaves  (TIM_GTX_INDEX_C),
         axilWriteMaster    => mAxilWriteMasters(TIM_GTX_INDEX_C),
         axilWriteSlave     => mAxilWriteSlaves (TIM_GTX_INDEX_C),

         stableClk          => clk,

         gtRefClk           => timingRefClk,

         gtRxP              => timingRxP,
         gtRxN              => timingRxN,

         gtTxP              => timingTxP,
         gtTxN              => timingTxN,

         rxControl          => timingRxControl,
         rxStatus           => timingRxStatus,
         rxUsrClk           => timingRecClkLoc,
         rxData             => timingRxPhy.data,
         rxDataK            => timingRxPhy.dataK,
         rxDispErr          => timingRxPhy.dspErr,
         rxDecErr           => timingRxPhy.decErr,
         rxOutClk           => timingRecClkLoc,

         txControl          => timingTxPhyLoc.control,
         txStatus           => timingTxStatus,
         txUsrClk           => timingTxUsrClk,
         txUsrClkActive     => clkAlwaysActive,
         txData             => timingTxPhyLoc.data,
         txDataK            => timingTxPhyLoc.dataK,
         txOutClk           => timingTxUsrClk,
         loopback           => timingLoopbackSel
      );

   timingTxClk <= timingTxUsrClk;


   P_TIMING_PHY : process( timingTxPhy, timingTxRstAllAxi, timingTxRstAsyn ) is
      variable v : TimingPhyType;
   begin
      v                  := timingTxPhy;
      v.control.reset    := timingTxPhy.control.reset or timingTxRstAsyn or timingTxRstAllAxi;

      timingTxPhyLoc     <= v;
   end process P_TIMING_PHY;

   -- reset the timing core only when they request a 'full' reset from
   -- the local register. The TPGMini core is UNRESPONSIVE while in reset!
   -- When requesting a TX reset form the TPGMini core then we reset the
   -- transmitter only (but not the TimingCore TX).

   U_SYNC_TX_RST_ALL : entity work.Synchronizer
      port map (
         clk                 => timingTxUsrClk,
         dataIn              => timingTxRstAllAxi,
         dataOut             => timingTxRstAllTmg
      );

   P_TXRESET_GATE : process ( timingTxUsrClk ) is
   begin
      if ( rising_edge( timingTxUsrClk ) ) then
         if ( timingTxRstAllTmg = '1' ) then
            timingTxUsrRstEnb <= '1';
         elsif ( timingTxStatus.resetDone = '1' ) then
            timingTxUsrRstEnb <= '0';
         end if;
      end if;
   end process P_TXRESET_GATE;


   U_TimingCore : entity work.TimingCore
      generic map (
         TPD_G               => TPD_G,
         STREAM_L1_G         => TIMING_UDP_MSG_G,
         ETHMSG_AXIS_CFG_G   => EMAC_AXIS_CONFIG_C,
         AXIL_RINGB_G        => false,
         TPGMINI_G           => TPGMINI_G, -- seems unused
         USE_TPGMINI_G       => TPGMINI_G,
         ASYNC_G             => false,
         AXIL_BASE_ADDR_G    => AXI_CROSSBAR_MASTERS_CONFIG_C(TIM_COR_INDEX_C).baseAddr
      )
      port map (
         gtTxUsrClk          => timingTxUsrClk,
         gtTxUsrRst          => timingTxUsrRst,

         gtRxRecClk          => timingRecClkLoc,
         gtRxData            => timingRxPhy.data,
         gtRxDataK           => timingRxPhy.dataK,
         gtRxDispErr         => timingRxPhy.dspErr,
         gtRxDecErr          => timingRxPhy.decErr,
         gtRxControl         => timingRxControl,
         gtRxStatus          => timingRxStatus,
         gtTxReset           => timingTxRstAsyn, -- axi clock domain
         gtLoopback          => timingLoopbackSel,

         timingPhy           => timingTxPhy,
         timingClkSel        => timingClkSel,

         appTimingClk        => appTimingClk,
         appTimingRst        => appTimingRst,
         appTimingBus        => timingBus,
         appTimingMode       => appTimingMode,

         axilClk             => clk,
         axilRst             => rst,
         axilReadMaster      => mAxilReadMasters (TIM_COR_INDEX_C),
         axilReadSlave       => mAxilReadSlaves  (TIM_COR_INDEX_C),
         axilWriteMaster     => mAxilWriteMasters(TIM_COR_INDEX_C),
         axilWriteSlave      => mAxilWriteSlaves (TIM_COR_INDEX_C),

         ibEthMsgMaster      => ibTimingEthMsgMaster,
         ibEthMsgSlave       => ibTimingEthMsgSlave,

         obEthMsgMaster      => obTimingEthMsgMaster,
         obEthMsgSlave       => obTimingEthMsgSlave
      );

   U_EvrV2 : entity work.EvrV2CoreTriggers
      generic map (
         TPD_G               => TPD_G,
         NCHANNELS_G         => NUM_TRIGS_G, -- event selectors
         NTRIGGERS_G         => NUM_TRIGS_G,
         INVERT_POLARITY_G   => INVERT_POLARITY_G,
         TRIG_DEPTH_G        => 19,
         COMMON_CLK_G        => false,
         AXIL_BASEADDR_G     => AXI_CROSSBAR_MASTERS_CONFIG_C(TIM_TRG_INDEX_C).baseAddr
      )
      port map (
         -- AXI-Lite and IRQ Interface
         axilClk             => clk,
         axilRst             => rst,
         axilReadMaster      => mAxilReadMasters (TIM_TRG_INDEX_C),
         axilReadSlave       => mAxilReadSlaves  (TIM_TRG_INDEX_C),
         axilWriteMaster     => mAxilWriteMasters(TIM_TRG_INDEX_C),
         axilWriteSlave      => mAxilWriteSlaves (TIM_TRG_INDEX_C),
         -- EVR Ports
         evrClk              => appTimingClk,
         evrRst              => appTimingRst,
         evrBus              => timingBus,
         -- Trigger and Sync Port
         trigOut             => appTimingTrig,
         evrModeSel          => appTimingMode
      );


      appTimingClk <= timingRecClkLoc;
      appTimingRst <= timingRecRstLoc;

      timingRecClk <= timingRecClkLoc;
      timingRecRst <= timingRecRstLoc;

      timingTrig   <= appTimingTrig;

      U_RXCLK_RST : entity work.RstSync
         generic map (
            TPD_G            => TPD_G,
            IN_POLARITY_G    => '0'
         )
         port map (
            clk              => timingRecClkLoc,
            asyncRst         => timingRxStatus.resetDone,
            syncRst          => timingRecRstLoc
         );

      timingTxUsrRst <= not timingTxStatus.resetDone and timingTxUsrRstEnb;

      U_IBUF_GTX : IBUFDS_GTE2
         generic map (
            CLKRCV_TRST      => true, -- ug476
            CLKCM_CFG        => true, -- ug476
            CLKSWING_CFG     => "11"  -- ug476
         )
         port map (
            I                => timingRefClkP,
            IB               => timingRefClkN,
            CEB              => '0',
            O                => timingRefClk,
            ODIV2            => open
         );

   end generate;

   timingTxStat <= timingTxStatus;
   timingRxStat <= timingRxStatus;

   locIrqs(0)   <= timingClkSel;
   locIrqs(1)   <= timingRxStatus.locked;

   -- should probably be edge-triggered both ways...
   U_IRQ : entity work.AppEdgeIrqCtrl
      generic map (
         NUM_IRQS_G => NUM_LOC_IRQS_C
      )
      port map (
         clk        => clk,
         rst        => rst,
         irqEnb     => writeRegsLoc(IRQ_CTL_IDX_C)(NUM_LOC_IRQS_C - 1 downto 0),
         irqOut     => irqOut(0),
         irqPend    => readRegsLoc(IRQ_STA_IDX_C) (NUM_LOC_IRQS_C - 1 downto 0),
         -- irqIn is synchronized into 'clk' domain
         irqIn      => locIrqs
      );

end mapping;
