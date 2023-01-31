library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use     unisim.vcomponents.all;

use work.TimingGtpPkg.all;

entity TimingMgtWrapper is
   generic (
      WITH_COMMON_G      : boolean    := true;
      COMMON_BUF_TYPE_G  : string     := "BUFH"; -- BUFG, BUFH

      -- A few settings determine the line rate (assuming 16bit external data width
      -- using 8/10bit encoding):
      --
      --    line_rate = 2 * pll_freq / outdiv
      --
      --    pll_freq  = reference_freq / REFCLK_DIV * FBDIV * FBDIV_45
      --
      -- Apparently the recommended range for pll_freq is 1.6..3.3 GHz
      --
      -- Thus, applications which need timing clocks from 119 .. 185.4 MHz
      -- would have to use the DRP port and reprogram the PLL and OUTDIV
      -- settings.
      
      -- used only with internal common block
      PLL0_FBDIV_G       : integer    := 4; -- legal: 1,2,3,4,5
      PLL0_FBDIV_45_G    : integer    := 5; -- legal: 4,5
      PLL0_REFCLK_DIV_G  : integer    := 1; -- legal: 1,2
      -- defaults for these based on wizard settings when only PLL0 was used
      PLL1_FBDIV_G       : integer    := 1; -- legal: 1,2,3,4,5
      PLL1_FBDIV_45_G    : integer    := 4; -- legal: 4,5
      PLL1_REFCLK_DIV_G  : integer    := 1; -- legal: 1,2
      RXOUT_DIV_G        : natural    := 2; -- legal: 1,2,4,8
      TXOUT_DIV_G        : natural    := 2  -- legal: 1,2,4,8
   );
   port (
      sysClk             : in  std_logic;
      sysRst             : in  std_logic;

      -- DRP
      drpAddr            : in  std_logic_vector(15 downto 0) := (others => '0');
      drpEn              : in  std_logic := '0';
      drpWe              : in  std_logic := '0';
      drpDin             : in  std_logic_vector(15 downto 0) := (others => '0');
      drpRdy             : out std_logic;
      drpDou             : out std_logic_vector(15 downto 0);
      drpBsy             : out std_logic;

      -- MGT serial interface
      gtRxP              : in  std_logic;
      gtRxN              : in  std_logic;
      gtTxP              : out std_logic;
      gtTxN              : out std_logic;

      -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
      gtRxPllSel         : in  std_logic := '0';
      gtTxPllSel         : in  std_logic := '0';

      -- signals for external common block (WITH_COMMON_G = false)
      pllOutClk          : in  std_logic_vector(1 downto 0) := (others => '0');
      pllOutRefClk       : in  std_logic_vector(1 downto 0) := (others => '0');
      pllLocked          : in  std_logic_vector(1 downto 0) := (others => '0');
      pllRefClkLost      : in  std_logic_vector(1 downto 0) := (others => '0');

      pllRst             : out std_logic_vector(1 downto 0);

      gtRefClk           : in  std_logic_vector(1 downto 0);
      pllRefClkSel       : in  PllRefClkSelArray := (others => PLLREFCLK_SEL_REF0_C);

      -- Receiver
      rxUsrClk           : in  std_logic;
      rxUsrClkActive     : in  std_logic := '1';
      rxData             : out std_logic_vector(15 downto 0);
      rxDataK            : out std_logic_vector( 1 downto 0);
      rxOutClk           : out std_logic;

      -- reference clock used by the receiver; ONLY DRIVEN if WITH_COMMON_G = TRUE
      rxRefClk           : out std_logic := '0';

      -- Transmitter
      txUsrClk           : in  std_logic;
      txUsrClkActive     : in  std_logic := '1';
      txData             : in  std_logic_vector(15 downto 0)            := (others => '0');
      txDataK            : in  std_logic_vector( 1 downto 0)            := (others => '0');
      txOutClk           : out std_logic;

      -- MGT control + status; different clock domains
      mgtControl         : in  MGTControlType := MGT_CONTROL_INIT_C;
      mgtStatus          : out MGTStatusType
   );
end entity TimingMgtWrapper;

architecture Impl of TimingMgtWrapper is

   type RateMapArray is array(natural range 1 to 8) of std_logic_vector(2 downto 0);

   constant RATE_MAP_C : RateMapArray := (
      1 => "001",
      2 => "010",
      4 => "011",
      8 => "100",
      others => "001" -- ILLEGAL
   );

   constant RXRATE_C : std_logic_vector(2 downto 0) := RATE_MAP_C(RXOUT_DIV_G);
   constant TXRATE_C : std_logic_vector(2 downto 0) := RATE_MAP_C(TXOUT_DIV_G);

   -- PLL note:
   -- the 'gtRxPllSel/gtTxPllSel' inputs set the mux which actually feeds the
   -- GTP transceiver with the respective PLL signals.
   -- The wizard is told which PLL to use for the RX and TX paths but that
   -- only determines the number of PLL reset signals that are generated and
   -- their naming. Note that, e.g., GT0_PLL0RESET_OUT is not in any way
   -- 'wired' to the PLL0 it is just the reset signal for whatever PLL feeds
   -- the transceiver - so we switch that based on the 'gtRxPllSel/gtTxPllSel'
   -- selection.

   -- Assume the wizard was configured for RX to use PLL1 and TX to use PLL0
   -- (this only affects the names of the ports; the TimingGtp wrapper does
   -- not really have a connection to the PLLs
   type   PllIndexType is (TXPLL, RXPLL);

   type   PllSignalArray is array (PllIndexType) of std_logic;

   function mapPll(signal r,t : in std_logic; signal x : in std_logic_vector(1 downto 0))
   return PllSignalArray is
      variable v : PllSignalArray;
   begin
      if ( r = '0' ) then
         v(RXPLL) := x(0);
      else
         v(RXPLL) := x(1);
      end if;
      if ( t = '0' ) then
         v(TXPLL) := x(0);
      else
         v(TXPLL) := x(1);
      end if;
      return v;
   end function mapPll;

   signal pllLocked_x       : PllSignalArray;
   signal pllRefClkLost_x   : PllSignalArray;
   signal pllRst_x          : PllSignalArray;

   signal pllOutClk_i       : std_logic_vector(1 downto 0);
   signal pllOutRefClk_i    : std_logic_vector(1 downto 0);

   -- remapped to actual PLL 0/1
   signal pllLocked_i       : std_logic_vector(1 downto 0);
   signal pllRefClkLost_i   : std_logic_vector(1 downto 0);
   signal pllRst_i          : std_logic_vector(1 downto 0);

   -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
   signal gtRxPllSel_i      : std_logic_vector(1 downto 0);
   signal gtTxPllSel_i      : std_logic_vector(1 downto 0);

   signal rxDispErr_i       : std_logic_vector(1 downto 0);
   signal rxDecErr_i        : std_logic_vector(1 downto 0);

   signal rxOutClk_i        : std_logic;
   signal txOutClk_i        : std_logic;

   signal rxOutClk_b        : std_logic;
   signal txOutClk_b        : std_logic;

   signal txRstDone         : std_logic;
   signal rxRstDone         : std_logic;

   signal drpClk            : std_logic;

   signal pllRefClk         : std_logic_vector(1 downto 0);
   signal pllRefClkBuf      : std_logic_vector(1 downto 0);

   signal txBufStatus       : std_logic_vector(1 downto 0);
   signal enCommaAlign      : std_logic := '1';

   signal softRxRst         : std_logic;
   signal softTxRst         : std_logic;

   signal loopbackMode      : std_logic_vector(2 downto 0);
   signal rxPolInvert       : std_logic;
   signal txPolInvert       : std_logic;
begin

   gtRxPllSel_i <= (gtRxPllSel & gtRxPllSel);
   gtTxPllSel_i <= (gtTxPllSel & gtTxPllSel);

   drpClk       <= sysClk;

   softRxRst    <= mgtControl.rxReset;
   rxPolInvert  <= mgtControl.rxPolarityInvert;
   enCommaAlign <= not mgtControl.rxCommaAlignDisable;
   loopbackMode <= mgtControl.txLoopback;

   softTxRst    <= mgtControl.txReset;
   txPolInvert  <= mgtControl.txPolarityInvert;

   U_TIMING_GTP : component TimingGtp
      port map (
         sysclk_in                       =>      sysClk,
         soft_reset_tx_in                =>      softTxRst,
         soft_reset_rx_in                =>      softRxRst,
         dont_reset_on_data_error_in     =>      '0',
         gt0_drp_busy_out                =>      drpBsy,
         gt0_tx_fsm_reset_done_out       =>      txRstDone,
         gt0_rx_fsm_reset_done_out       =>      rxRstDone,
         -- monitored by the rx startup FSP; purpose not clear, in particular
         -- how it is different from rxUsrRdy
         gt0_data_valid_in               =>      '1',

         --_____________________________________________________________________
         --_____________________________________________________________________
         --GT0  (X1Y0)
         ---------------------------- Channel - DRP Ports  --------------------------
         gt0_drpaddr_in                  =>      drpAddr(8 downto 0),
         gt0_drpclk_in                   =>      drpClk,
         gt0_drpdi_in                    =>      drpDin,
         gt0_drpdo_out                   =>      drpDou,
         gt0_drpen_in                    =>      drpEn,
         gt0_drprdy_out                  =>      drpRdy,
         gt0_drpwe_in                    =>      drpWe,
         --------------------------- Selection of reference PLL ---------------------
         gt0_rxsysclksel_in              =>      gtRxPllSel_i,
         gt0_txsysclksel_in              =>      gtTxPllSel_i,
         --------------------------- Digital Monitor Ports --------------------------
         gt0_dmonitorout_out             =>      open,
         ------------------------------- Loopback Ports -----------------------------
         gt0_loopback_in                 =>      loopbackMode,
         --------------- Receive Ports - Rate Control -------------------------------
         gt0_rxrate_in                   =>      RXRATE_C,
         --------------------- RX Initialization and Reset Ports --------------------
         gt0_eyescanreset_in             =>      '0',
         gt0_rxuserrdy_in                =>      '1',
         -------------------------- RX Margin Analysis Ports ------------------------
         gt0_eyescandataerror_out        =>      open,
         gt0_eyescantrigger_in           =>      '0',
         ------------------ Receive Ports - FPGA RX Interface Ports -----------------
         gt0_rxusrclk_in                 =>      rxUsrClk,
         gt0_rxusrclk2_in                =>      rxUsrClk,
         ------------------ Receive Ports - FPGA RX interface Ports -----------------
         gt0_rxdata_out                  =>      rxData,
         ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
         gt0_rxdisperr_out               =>      rxDispErr_i,
         gt0_rxnotintable_out            =>      rxDecErr_i,
         --------------------------- Receive Ports - RX AFE -------------------------
         gt0_gtprxp_in                   =>      gtRxP,
         ------------------------ Receive Ports - RX AFE Ports ----------------------
         gt0_gtprxn_in                   =>      gtRxN,
         ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
         gt0_rxphmonitor_out             =>      open,
         gt0_rxphslipmonitor_out         =>      open,
         gt0_rxmcommaalignen_in          =>      enCommaAlign,
         gt0_rxpcommaalignen_in          =>      enCommaAlign,
         --------------------- Receive Ports - RX Equalizer Ports -------------------
         gt0_rxlpmhfhold_in               =>      '0',
         gt0_rxlpmlfhold_in               =>      '0',

         --------------- Receive Ports - Rate Control -------------------------------
         gt0_rxratedone_out              =>      open,
         --------------- Receive Ports - RX Fabric Output Control Ports -------------
         gt0_rxoutclk_out                =>      rxOutClk_i,
         gt0_rxoutclkfabric_out          =>      open,
         ------------- Receive Ports - RX Initialization and Reset Ports ------------
         gt0_gtrxreset_in                =>      '0',
         gt0_rxlpmreset_in               =>      '0',
         ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
         gt0_rxcharisk_out               =>      rxDataK,
         -------------- Receive Ports -RX Initialization and Reset Ports ------------
         gt0_rxresetdone_out             =>      open,
         --------------------- TX Initialization and Reset Ports --------------------
         gt0_gttxreset_in                =>      '0',
         gt0_txuserrdy_in                =>      '1',
         ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
         gt0_txusrclk_in                 =>      txUsrClk,
         gt0_txusrclk2_in                =>      txUsrClk,
         --------------- Tramsmit Ports - Rate Control ------------------------------
         gt0_txrate_in                   =>      TXRATE_C,
         ------------------ Transmit Ports - TX Data Path interface -----------------
         gt0_txdata_in                   =>      txData,
         ---------------- Transmit Ports - TX Driver and OOB signaling --------------
         gt0_gtptxn_out                  =>      gtTxN,
         gt0_gtptxp_out                  =>      gtTxP,
         ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
         gt0_txoutclk_out                =>      txOutClk_i,
         gt0_txoutclkfabric_out          =>      open,
         gt0_txoutclkpcs_out             =>      open,
         --------------- Tramsmit Ports - Rate Control ------------------------------
         gt0_txratedone_out              =>      open,
         --------------------- Transmit Ports - TX Gearbox Ports --------------------
         gt0_txcharisk_in                =>      txDataK,
         gt0_txbufstatus_out             =>      txBufStatus,
         ------------- Transmit Ports - TX Initialization and Reset Ports -----------
         gt0_txresetdone_out             =>      open,

         gt0_rxpolarity_in               =>      rxPolInvert,
         gt0_txpolarity_in               =>      txPolInvert,

         -- these clock inputs must be wired from the respective PLLs
         gt0_pll0outclk_in               =>      pllOutClk_i   (0),
         gt0_pll0outrefclk_in            =>      pllOutRefClk_i(0),
         gt0_pll1outclk_in               =>      pllOutClk_i   (1),
         gt0_pll1outrefclk_in            =>      pllOutRefClk_i(1),

         -- assume we told the wizard that TX uses PLL0 and RX uses PLL1
         -- then we (or the user, for external common block) must
         -- connect the xxx_PLL0yyy signals to the TX PLL and the
         -- xxx_PLL1yyy signals to the RX PLL.

         GT0_PLL0RESET_OUT               =>      pllRst_x(TXPLL),
         GT0_PLL0LOCK_IN                 =>      pllLocked_x(TXPLL),
         GT0_PLL0REFCLKLOST_IN           =>      pllRefClkLost_x(TXPLL),

         GT0_PLL1RESET_OUT               =>      pllRst_x(RXPLL),
         GT0_PLL1LOCK_IN                 =>      pllLocked_x(RXPLL),
         GT0_PLL1REFCLKLOST_IN           =>      pllRefClkLost_x(RXPLL)
      );

   P_MAP_PLL_RST : process ( gtRxPllSel, gtTxPllSel, pllRst_x ) is
   begin
      pllRst_i <= (others => '1');
      if ( gtRxPllSel = '0' ) then
         pllRst_i(0) <= pllRst_x(RXPLL);
      else
         pllRst_i(1) <= pllRst_x(RXPLL);
      end if;
      if ( gtTxPllSel = '0' ) then
         pllRst_i(0) <= pllRst_x(TXPLL);
      else
         pllRst_i(1) <= pllRst_x(TXPLL);
      end if;
   end process P_MAP_PLL_RST;

   pllRefClkLost_x <= mapPll( gtRxPllSel, gtTxPllSel, pllRefClkLost_i );
   pllLocked_x     <= mapPll( gtRxPllSel, gtTxPllSel, pllLocked_i );

   U_BUF_TXCLK : component BUFG port map ( I => txOutClk_i, O => txOutClk_b );

   U_BUF_RXCLK : component BUFG port map ( I => rxOutClk_i, O => rxOutClk_b );

   G_COMMON : if ( WITH_COMMON_G ) generate
      signal pllInitRst : std_logic_vector(1 downto 0);
      signal pllInitPd  : std_logic_vector(1 downto 0);
      signal pllRstAny  : std_logic_vector(1 downto 0);
   begin

      P_MAP_REF : process ( pllRefClkSel, gtRefClk, gtRxPllSel, pllRefClkBuf ) is
      begin
         for i in pllRefClk'range loop
            if ( pllRefClkSel(i) = PLLREFCLK_SEL_REF1_C ) then
               pllRefClk(i) <= gtRefClk(1);
            else
               pllRefClk(i) <= gtRefClk(0);
            end if;
         end loop;
         if ( gtRxPllSel = '0' ) then
            rxRefClk <= pllRefClkBuf(0);
         else
            rxRefClk <= pllRefClkBuf(1);
         end if;
      end process P_MAP_REF;

      G_RAIL_RST : for i in pllInitRst'range generate
         U_INITIAL_RST : entity work.TimingGtp_cpll_railing
            generic map (
               USE_BUF => COMMON_BUF_TYPE_G
            )
            port map (
               cpll_reset_out => pllInitRst(i),
               cpll_pd_out    => pllInitPd(i),
               refclk_out     => pllRefClkBuf(i),
               refclk_in      => pllRefClk(i)
            );

         pllRstAny(i) <= pllInitRst(i) or pllRst_i(i);
      end generate G_RAIL_RST;

      U_GTP_COMMON : entity work.TimingGtp_common
         generic map (
            PLL0_FBDIV_IN        => PLL0_FBDIV_G,
            PLL0_FBDIV_45_IN     => PLL0_FBDIV_45_G,
            PLL0_REFCLK_DIV_IN   => PLL0_REFCLK_DIV_G,
            PLL1_FBDIV_IN        => PLL1_FBDIV_G,
            PLL1_FBDIV_45_IN     => PLL1_FBDIV_45_G,
            PLL1_REFCLK_DIV_IN   => PLL1_REFCLK_DIV_G
         )
         port map (
            DRPADDR_COMMON_IN    => x"00",
            DRPCLK_COMMON_IN     => drpClk,
            DRPDI_COMMON_IN      => x"0000",
            DRPDO_COMMON_OUT     => open,
            DRPEN_COMMON_IN      => '0',
            DRPRDY_COMMON_OUT    => open,
            DRPWE_COMMON_IN      => '0',

            PLL0OUTCLK_OUT       => pllOutClk_i(0),
            PLL0OUTREFCLK_OUT    => pllOutRefClk_i(0),
            PLL0LOCK_OUT         => pllLocked_i(0),
            PLL0LOCKDETCLK_IN    => sysClk,
            PLL0REFCLKLOST_OUT   => pllRefClkLost_i(0),
            PLL0RESET_IN         => pllRstAny(0),
            PLL0REFCLKSEL_IN     => pllRefClkSel(0),
            PLL0PD_IN            => pllInitPd(0),


            GTREFCLK1_IN         => gtRefClk(1),
            GTREFCLK0_IN         => gtRefClk(0),

            -- defaults for these based on wizard settings when only PLL0 was used
            PLL1OUTCLK_OUT       => pllOutClk_i(1),
            PLL1OUTREFCLK_OUT    => pllOutRefClk_i(1),
            PLL1LOCK_OUT         => pllLocked_i(1),
            PLL1LOCKDETCLK_IN    => sysClk,
            PLL1REFCLKLOST_OUT   => pllRefClkLost_i(1),
            PLL1RESET_IN         => pllRstAny(1),
            PLL1REFCLKSEL_IN     => pllRefClkSel(1),
            PLL1PD_IN            => pllInitPd(1)
         );


      pllRst           <= pllRstAny;

   end generate G_COMMON;

   G_NO_COMMON : if ( not WITH_COMMON_G ) generate
      pllOutRefClk_i   <= pllOutRefClk;
      pllOutClk_i      <= pllOutClk;
      pllLocked_i      <= pllLocked;
      pllRefClkLost_i  <= pllRefClkLost;
      pllRst           <= pllRst_i;
   end generate G_NO_COMMON;

   txOutClk                          <= txOutClk_b;
   rxOutClk                          <= rxOutClk_b;

   P_MGT_STATUS : process ( rxDispErr_i, rxDecErr_i, pllRefClkLost_x, pllLocked_x, rxRstDone, txBufStatus, txRstDone ) is
   begin
      mgtStatus                       <= MGT_STATUS_INIT_C;
      mgtStatus.rxDispError           <= rxDispErr_i;
      mgtStatus.rxNotIntable          <= rxDecErr_i;
      mgtStatus.rxPllRefClkLost       <= pllRefClkLost_x(RXPLL);
      mgtStatus.rxPllLocked           <= pllLocked_x(RXPLL);
      mgtStatus.rxResetDone           <= rxRstDone;

      mgtStatus.txBufStatus           <= txBufStatus;
      mgtStatus.txPllRefClkLost       <= pllRefClkLost_x(TXPLL);
      mgtStatus.txPllLocked           <= pllLocked_x(TXPLL);
      mgtStatus.txResetDone           <= txRstDone;
   end process P_MGT_STATUS;

end architecture Impl;
