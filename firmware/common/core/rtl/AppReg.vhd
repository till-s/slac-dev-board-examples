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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.TimingPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AppReg is
   generic (
      TPD_G            : time             := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      XIL_DEVICE_G     : string           := "7SERIES";
      AXIL_BASE_ADDR_G : slv(31 downto 0) := x"00000000";
      USE_SLOWCLK_G    : boolean          := false;
      NUM_TRIGS_G      : natural          := 8;
      FIFO_DEPTH_G     : natural          := 0;
      GEN_TIMING_G     : boolean          := true);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- AXI-Lite interface
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      -- PBRS Interface
      pbrsTxMaster    : out AxiStreamMasterType;
      pbrsTxSlave     : in  AxiStreamSlaveType;
      pbrsRxMaster    : in  AxiStreamMasterType;
      pbrsRxSlave     : out AxiStreamSlaveType;
      -- MB Interface
      mbTxMaster      : out AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      mbTxSlave       : in  AxiStreamSlaveType;
      mbRxMaster      : in  AxiStreamMasterType;
      mbRxSlave       : out AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- ADC Ports
      vPIn            : in  sl;
      vNIn            : in  sl;
      -- Timing
      timingRefClkP   : in  sl := '0';
      timingRefClkN   : in  sl := '1';
      timingRecClk    : out sl;
      timingRecRst    : out sl;
      timingRxP       : in  sl := '0';
      timingRxN       : in  sl := '1';
      timingTxP       : out sl;
      timingTxN       : out sl;
      timingTrig      : out TimingTrigType;
      -- IRQ
      irqOut          : out slv(7 downto 0)    := (others => '0'));
end AppReg;

architecture mapping of AppReg is

   constant AXIL_CLK_FREQ_C    : real := 50.0E6;
   constant CLK_PERIOD_C       : real := 1.0/AXIL_CLK_FREQ_C;

   constant SHARED_MEM_WIDTH_C : positive                           := 10;
   constant IRQ_ADDR_C         : slv(SHARED_MEM_WIDTH_C-1 downto 0) := (others => '1');

   constant NUM_AXI_MASTERS_C : natural := 10;

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

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) :=
      genAxiLiteConfig( NUM_AXI_MASTERS_C, AXIL_BASE_ADDR_G, 24, 20 );


   signal mAxilWriteMaster : AxiLiteWriteMasterType;
   signal mAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal mAxilReadMaster  : AxiLiteReadMasterType;
   signal mAxilReadSlave   : AxiLiteReadSlaveType;

   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := ( others => AXI_LITE_WRITE_SLAVE_INIT_C );
   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0)  := ( others => AXI_LITE_READ_SLAVE_INIT_C );

   signal axiWrValid : sl;
   signal axiWrAddr  : slv(SHARED_MEM_WIDTH_C-1 downto 0);

   signal irqReq     : slv(7 downto 0);
   signal irqCount   : slv(27 downto 0);

   signal irq        : sl := '0';

   signal rstN       : sl;

   signal timingRefClk      : sl := '0';
   signal timingRecClkLoc   : sl := '0';
   signal timingRecRstLoc   : sl := '1';
   signal timingTxUsrClk    : sl := '0';
   signal timingTxUsrRst    : sl := '1';
   signal timingCdrStable   : sl;
   signal timingLoopback    : slv(2 downto 0) := "000";
   signal timingClkSel      : sl;
   signal timingLoopbackSel : slv(2 downto 0) := "000";

   signal timingTxPhy       : TimingPhyType;
   signal timingTxPhyLoc    : TimingPhyType;
   signal timingRxPhy       : TimingRxType;
   signal timingRxControl   : TimingPhyControlType;
   signal timingRxStatus    : TimingPhyStatusType := TIMING_PHY_STATUS_INIT_C;
   signal timingTxStatus    : TimingPhyStatusType := TIMING_PHY_STATUS_INIT_C;
   signal timingTxRstAsync  : sl;

   signal timingBus         : TimingBusType;
   signal appTimingMode     : sl;
   signal appTimingTrig     : TimingTrigType;

   signal appTimingClk      : sl;
   signal appTimingRst      : sl;


   constant GEN_MB_C : boolean := false and FIFO_DEPTH_G = 0;

begin

   rstN <= not rst;

   GEN_MB : if ( GEN_MB_C ) generate

   U_CPU : entity work.MicroblazeBasicCoreWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Master AXI-Lite Interface: [0x00000000:0x7FFFFFFF]
         mAxilWriteMaster => mAxilWriteMaster,
         mAxilWriteSlave  => mAxilWriteSlave,
         mAxilReadMaster  => mAxilReadMaster,
         mAxilReadSlave   => mAxilReadSlave,
         -- Streaming
         mAxisMaster      => mbTxMaster,
         mAxisSlave       => mbTxSlave,
         -- IRQ
         interrupt        => irqReq,
         -- Clock and Reset
         clk              => clk,
         rst              => rst);

   process (clk)
   begin
      if rising_edge(clk) then
         irqReq <= (others => '0') after TPD_G;
         if rst = '1' then
            irqCount <= (others => '0') after TPD_G;
         else
            -- IRQ[0]
            if irqCount = x"9502f90" then
               irqReq(0) <= '1'             after TPD_G;
               irqCount  <= (others => '0') after TPD_G;
            else
               irqCount <= irqCount + 1 after TPD_G;
            end if;
            -- IRQ[1]
            if (axiWrValid = '1') and (axiWrAddr = IRQ_ADDR_C) then
               irqReq(1) <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   end generate;

   NOT_GEN_MB : if ( not GEN_MB_C and FIFO_DEPTH_G = 0 ) generate
      mAxilWriteMaster <= AXI_LITE_WRITE_MASTER_INIT_C;
      mAxilReadMaster  <= AXI_LITE_READ_MASTER_INIT_C;
   end generate;

   ---------------------------
   -- AXI-Lite Crossbar Module
   ---------------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteMasters(1) => mAxilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiWriteSlaves(1)  => mAxilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadMasters(1)  => mAxilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         sAxiReadSlaves(1)   => mAxilReadSlave,
         mAxiWriteMasters    => mAxilWriteMasters,
         mAxiWriteSlaves     => mAxilWriteSlaves,
         mAxiReadMasters     => mAxilReadMasters,
         mAxiReadSlaves      => mAxilReadSlaves,
         axiClk              => clk,
         axiClkRst           => rst);

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
         mAxisClk       => clk,
         mAxisRst       => rst,
         axiClk         => clk,
         axiRst         => rst,
         axiReadMaster  => mAxilReadMasters(PRBS_RX_INDEX_C),
         axiReadSlave   => mAxilReadSlaves(PRBS_RX_INDEX_C),
         axiWriteMaster => mAxilWriteMasters(PRBS_RX_INDEX_C),
         axiWriteSlave  => mAxilWriteSlaves(PRBS_RX_INDEX_C));

   GEN_FIFO : if ( FIFO_DEPTH_G > 0 ) generate

   U_AxiStreamFifo : entity work.AxilFifoWrapper
      generic map (
         FIFO_DEPTH_G => FIFO_DEPTH_G
      )
      port map (
         ACLK               => clk,
         ARESETn            => rstN,

         axiStreamMasterOb  => mbTxMaster,
         axiStreamSlaveOb   => mbTxSlave,
         axiStreamMasterIb  => mbRxMaster,
         axiStreamSlaveIb   => mbRxSlave,

         irq                => irqOut(0),

         AXI_S_ACLK         => clk,
         AXI_S_ARESETn      => rstN,

         axiLiteReadMaster  => mAxilReadMasters(FIFO_INDEX_C),
         axiLiteReadSlave   => mAxilReadSlaves(FIFO_INDEX_C),
         axiLiteWriteMaster => mAxilWriteMasters(FIFO_INDEX_C),
         axiLiteWriteSlave  => mAxilWriteSlaves(FIFO_INDEX_C)
      );

   end generate;

   NOT_GEN_FIFO : if ( FIFO_DEPTH_G = 0 ) generate
      mAxilReadSlaves(FIFO_INDEX_C).arready  <= '1';
      mAxilWriteSlaves(FIFO_INDEX_C).awready <= '1';
      mAxilWriteSlaves(FIFO_INDEX_C).wready  <= '1';
   end generate;

   GEN_TIMING : if ( GEN_TIMING_G ) generate

   U_TimingGtx : entity work.TimingGtxCoreWrapper
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
         txUsrClkActive     => '1',
         txData             => timingTxPhyLoc.data,
         txDataK            => timingTxPhyLoc.dataK,
         txOutClk           => timingTxUsrClk,
         loopback           => timingLoopbackSel
      );

   P_TIMING_PHY : process( timingTxPhy, timingRxControl ) is
      variable v : TimingPhyType;
   begin
      v                  := timingTxPhy;
      v.control.reset    := timingTxPhy.control.reset or timingRxControl.bufferByRst; -- hack!

      timingTxPhyLoc     <= v;
   end process P_TIMING_PHY;


   U_TimingCore : entity work.TimingCore
      generic map (
         TPD_G               => TPD_G,
         STREAM_L1_G         => false,
         AXIL_RINGB_G        => false,
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
         gtTxReset           => open, -- not useful; if the TX is reset the TPGMini regs dont' work
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
         axilWriteSlave      => mAxilWriteSlaves (TIM_COR_INDEX_C)

--         ibEthMsgMaster      => ibTimingEthMaster,
--         ibEthMsgSlave       => ibTimingEthSlave,

--         obEthMsgMaster      => obTimingEthMaster,
--         obEthMsgSlave       => obTimingEthSlave
      );

   U_EvrV2 : entity work.EvrV2CoreTriggers
      generic map (
         TPD_G               => TPD_G,
         NCHANNELS_G         => NUM_TRIGS_G, -- event selectors
         NTRIGGERS_G         => NUM_TRIGS_G,
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

      U_TXCLK_RST : entity work.RstSync
         generic map (
            TPD_G            => TPD_G,
            IN_POLARITY_G    => '0'
         )
         port map (
            clk              => timingTxUsrClk,
            asyncRst         => timingTxStatus.resetDone,
            syncRst          => timingTxUsrRst
         );

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

end mapping;
