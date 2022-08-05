-------------------------------------------------------------------------------
-- File       : TimingGtpCoreWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for GTP Core
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 Timing Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 Timing Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity TimingGtCoreWrapper is
   generic (
      WITH_COMMON_G : boolean := true
   );
   port (
      -- AXI-Lite Port
      sysClk           : in  std_logic;
      sysRst           : in  std_logic;

      -- DRP Port
      drpAddr          : in  std_logic_vector( 8 downto 0) := (others => '0');
      drpDi            : in  std_logic_vector(15 downto 0) := (others => '0');
      drpEn            : in  std_logic := '0';
      drpWe            : in  std_logic := '0';
      drpDo            : out std_logic_vector(15 downto 0);
      drpRdy           : out std_logic;
      -- GTP FPGA IO
      gtRxP            : in  std_logic;
      gtRxN            : in  std_logic;
      gtTxP            : out std_logic;
      gtTxN            : out std_logic;

      -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
      gtRxPllSel       : in std_logic_vector(1 downto 0) := "00";
      gtTxPllSel       : in std_logic_vector(1 downto 0) := "00";

      -- signals for external common block (WITH_COMMON_G = false)
      pllOutClk        : in  std_logic_vector(1 downto 0) := "00";
      pllOutRefClk     : in  std_logic_vector(1 downto 0) := "00";

      pllLocked        : in  std_logic := '0';
      pllRefClkLost    : in  std_logic := '0';

      pllRst           : out std_logic;

      -- ref clock for internal common block (WITH_COMMON_G = true)
      gtRefClk         : in  std_logic := '0';
      gtRefClkDiv2     : in  std_logic := '0';-- Unused in GTHE3, but used in GTHE4

      -- Rx ports
      rxControl        : in  std_logic_vector(1 downto 0) := (others => '0');
      rxStatus         : out std_logic_vector(7 downto 0);
      rxUsrClkActive   : in  std_logic := '1';
      rxCdrStable      : out std_logic;
      rxUsrClk         : in  std_logic;
      rxData           : out std_logic_vector(15 downto 0);
      rxDataK          : out std_logic_vector(1 downto 0);
      rxDispErr        : out std_logic_vector(1 downto 0);
      rxDecErr         : out std_logic_vector(1 downto 0);
      rxOutClk         : out std_logic;

      -- Tx Ports
      txControl        : in  std_logic_vector(1 downto 0) := (others => '0');
      txStatus         : out std_logic_vector(7 downto 0);
      txUsrClk         : in  std_logic;
      txUsrClkActive   : in  std_logic := '1';
      txData           : in  std_logic_vector(15 downto 0);
      txDataK          : in  std_logic_vector(1 downto 0);
      txOutClk         : out std_logic;

      -- Loopback
      loopback         : in std_logic_vector(2 downto 0) := (others => '0')
   );
end entity TimingGtCoreWrapper;

architecture rtl of TimingGtCoreWrapper is

   component TimingGtp
      port (
         SYSCLK_IN : in STD_LOGIC;
         SOFT_RESET_TX_IN : in STD_LOGIC;
         SOFT_RESET_RX_IN : in STD_LOGIC;
         DONT_RESET_ON_DATA_ERROR_IN : in STD_LOGIC;
         GT0_DRP_BUSY_OUT : out STD_LOGIC;
         GT0_TX_FSM_RESET_DONE_OUT : out STD_LOGIC;
         GT0_RX_FSM_RESET_DONE_OUT : out STD_LOGIC;
         GT0_DATA_VALID_IN : in STD_LOGIC;
         gt0_drpaddr_in : in STD_LOGIC_VECTOR ( 8 downto 0 );
         gt0_drpclk_in : in STD_LOGIC;
         gt0_drpdi_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
         gt0_drpdo_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
         gt0_drpen_in : in STD_LOGIC;
         gt0_drprdy_out : out STD_LOGIC;
         gt0_drpwe_in : in STD_LOGIC;
         gt0_rxsysclksel_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_txsysclksel_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_loopback_in : in STD_LOGIC_VECTOR ( 2 downto 0 );
         gt0_eyescanreset_in : in STD_LOGIC;
         gt0_rxuserrdy_in : in STD_LOGIC;
         gt0_eyescandataerror_out : out STD_LOGIC;
         gt0_eyescantrigger_in : in STD_LOGIC;
         gt0_rxdata_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
         gt0_rxusrclk_in : in STD_LOGIC;
         gt0_rxusrclk2_in : in STD_LOGIC;
         gt0_rxcharisk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_rxdisperr_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_rxnotintable_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_gtprxn_in : in STD_LOGIC;
         gt0_gtprxp_in : in STD_LOGIC;
         gt0_rxphmonitor_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
         gt0_rxphslipmonitor_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
         gt0_dmonitorout_out : out STD_LOGIC_VECTOR ( 14 downto 0 );
         gt0_rxlpmhfhold_in : in STD_LOGIC;
         gt0_rxlpmlfhold_in : in STD_LOGIC;
         gt0_rxoutclk_out : out STD_LOGIC;
         gt0_rxoutclkfabric_out : out STD_LOGIC;
         gt0_gtrxreset_in : in STD_LOGIC;
         gt0_rxlpmreset_in : in STD_LOGIC;
         gt0_rxpolarity_in : in STD_LOGIC;
         gt0_rxresetdone_out : out STD_LOGIC;
         gt0_gttxreset_in : in STD_LOGIC;
         gt0_txuserrdy_in : in STD_LOGIC;
         gt0_txdata_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
         gt0_txusrclk_in : in STD_LOGIC;
         gt0_txusrclk2_in : in STD_LOGIC;
         gt0_txcharisk_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
         gt0_gtptxn_out : out STD_LOGIC;
         gt0_gtptxp_out : out STD_LOGIC;
         gt0_txoutclk_out : out STD_LOGIC;
         gt0_txoutclkfabric_out : out STD_LOGIC;
         gt0_txoutclkpcs_out : out STD_LOGIC;
         gt0_txresetdone_out : out STD_LOGIC;
         gt0_txpolarity_in : in STD_LOGIC;
         GT0_PLL0OUTCLK_IN : in STD_LOGIC;
         GT0_PLL0OUTREFCLK_IN : in STD_LOGIC;
         GT0_PLL0RESET_OUT : out STD_LOGIC;
         GT0_PLL0LOCK_IN : in STD_LOGIC;
         GT0_PLL0REFCLKLOST_IN : in STD_LOGIC;
         GT0_PLL1OUTCLK_IN : in STD_LOGIC;
         GT0_PLL1OUTREFCLK_IN : in STD_LOGIC
      );
   end component TimingGtp;

   signal rxCtrl0Out       : std_logic_vector(15 downto 0);
   signal rxCtrl1Out       : std_logic_vector(15 downto 0);
   signal rxCtrl3Out       : std_logic_vector(7 downto 0);
   signal txoutclk_out     : std_logic;
   signal txoutclkb        : std_logic;
   signal rxoutclk_out     : std_logic;
   signal rxoutclkb        : std_logic;

   signal drpClk           : std_logic;
   signal drpRst           : std_logic;
   signal rxRst            : std_logic;
   signal rxrstdone        : std_logic;
   signal txrstdone        : std_logic;
   signal bypasserr        : std_logic := '0';

   signal plloutclk_i      : std_logic_vector(1 downto 0);
   signal plloutrefclk_i   : std_logic_vector(1 downto 0);

   signal pll0_reset_i     : std_logic;
   signal pll0_pd_i        : std_logic;

   signal pll_rail_reset_i : std_logic;
   signal pll_reset_i      : std_logic;
   signal pllRst_i         : std_logic;
   signal pll_locked_i     : std_logic;
   signal pll_refclklost_i : std_logic;

   signal rxDecErr_i       : std_logic_vector(1 downto 0);
   signal rxDispErr_i      : std_logic_vector(1 downto 0);

   constant USE_SURF_C : boolean := false;

begin

   rxStatus(0)          <= rxrstdone;
   rxStatus(7 downto 6) <= rxDispErr_i;
   rxStatus(5 downto 4) <= rxDecErr_i;
   rxStatus(3 downto 2) <= (others => '0');

   txStatus(0)    <= txrstdone;
   txStatus(txStatus'left downto 1) <= (others => '0');

   rxCdrStable    <= rxrstdone; -- CDR locked not routed out by wizard

   drpClk <= sysClk;
   drpRst <= sysRst;

   U_TimingGtpCore : component TimingGtp
      port map (
         sysclk_in                       =>      sysClk,
         soft_reset_tx_in                =>      txControl(0),
         soft_reset_rx_in                =>      rxRst,
         dont_reset_on_data_error_in     =>      '0',
         gt0_drp_busy_out                =>      open,
         gt0_tx_fsm_reset_done_out       =>      txrstdone,
         gt0_rx_fsm_reset_done_out       =>      rxrstdone,
         gt0_data_valid_in               =>      '1',
 
         --_____________________________________________________________________
         --_____________________________________________________________________
         --GT0  (X1Y0)
         ---------------------------- Channel - DRP Ports  --------------------------
         gt0_drpaddr_in                  =>      drpAddr,
         gt0_drpclk_in                   =>      drpClk,
         gt0_drpdi_in                    =>      drpDi,
         gt0_drpdo_out                   =>      drpDo,
         gt0_drpen_in                    =>      drpEn,
         gt0_drprdy_out                  =>      drpRdy,
         gt0_drpwe_in                    =>      drpWe,
         --------------------------- Selection of reference PLL ---------------------
         gt0_rxsysclksel_in              =>      gtRxPllSel,
         gt0_txsysclksel_in              =>      gtTxPllSel,
         --------------------------- Digital Monitor Ports --------------------------
         gt0_dmonitorout_out             =>      open,
         ------------------------------- Loopback Ports -----------------------------
         gt0_loopback_in                 =>      loopback,
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
         --------------------- Receive Ports - RX Equalizer Ports -------------------
         gt0_rxlpmhfhold_in               =>      '0',
         gt0_rxlpmlfhold_in               =>      '0',

         --------------- Receive Ports - RX Fabric Output Control Ports -------------
         gt0_rxoutclk_out                =>      rxoutclk_out,
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
         ------------------ Transmit Ports - TX Data Path interface -----------------
         gt0_txdata_in                   =>      txData,
         ---------------- Transmit Ports - TX Driver and OOB signaling --------------
         gt0_gtptxn_out                  =>      gtTxN,
         gt0_gtptxp_out                  =>      gtTxP,
         ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
         gt0_txoutclk_out                =>      txoutclk_out,
         gt0_txoutclkfabric_out          =>      open,
         gt0_txoutclkpcs_out             =>      open,
         --------------------- Transmit Ports - TX Gearbox Ports --------------------
         gt0_txcharisk_in                =>      txDataK,
         ------------- Transmit Ports - TX Initialization and Reset Ports -----------
         gt0_txresetdone_out             =>      open,

         gt0_rxpolarity_in               =>      rxControl(1),
         gt0_txpolarity_in               =>      txControl(1),
 
         gt0_pll0outclk_in               =>      plloutclk_i   (0),
         gt0_pll0outrefclk_in            =>      plloutrefclk_i(0),
         gt0_pll1outclk_in               =>      plloutclk_i   (1),
         gt0_pll1outrefclk_in            =>      plloutrefclk_i(1),

         GT0_PLL0RESET_OUT               =>      pll_reset_i,
         GT0_PLL0LOCK_IN                 =>      pll_locked_i,
         GT0_PLL0REFCLKLOST_IN           =>      pll_refclklost_i
      );
  

   TIMING_TXCLK_BUFG : BUFG
      port map (
         I       => txoutclk_out,
         O       => txoutclkb);

   TIMING_RECCLK_BUFG : BUFG
      port map (
         I       => rxoutclk_out,
         O       => rxoutclkb);

   txOutClk <= txoutclkb;
   rxOutClk <= rxoutclkb;

   pllRst_i <= pll_reset_i or txControl(0);

   GEN_COMMON_BLK : if ( WITH_COMMON_G ) generate

   cpll_railing_pll0_q0_clk1_refclk_i : entity work.TimingGtp_cpll_railing
      generic map (
         USE_BUFG       => 0
      )
      port map (
         cpll_reset_out => pll_rail_reset_i,
         cpll_pd_out    => pll0_pd_i,
         refclk_out     => open,
         refclk_in      => gtRefClk
      );

   pll0_reset_i <= pll_rail_reset_i or pllRst_i;

   GEN_COM : if ( not USE_SURF_C ) generate
   
   TIMING_COMMON_TMP : entity work.TimingGtp_common
      port map (
         DRPADDR_COMMON_IN    => x"00",
         DRPCLK_COMMON_IN     => drpClk,
         DRPDI_COMMON_IN      => x"0000",
         DRPDO_COMMON_OUT     => open,
         DRPEN_COMMON_IN      => '0',
         DRPRDY_COMMON_OUT    => open,
         DRPWE_COMMON_IN      => '0',
         PLL0OUTCLK_OUT       => plloutclk_i   (0),
         PLL0OUTREFCLK_OUT    => plloutrefclk_i(0),
         PLL0LOCK_OUT         => pll_locked_i,
         PLL0LOCKDETCLK_IN    => sysClk,
         PLL0REFCLKLOST_OUT   => pll_refclklost_i,
         PLL0RESET_IN         => pll0_reset_i,
         PLL0REFCLKSEL_IN     => "010",
         PLL0PD_IN            => pll0_pd_i,
         PLL1OUTCLK_OUT       => plloutclk_i   (1),
         PLL1OUTREFCLK_OUT    => plloutrefclk_i(1),
         GTREFCLK1_IN         => gtRefClk,
         GTREFCLK0_IN         => '0'
      );
   end generate;

   end generate;

   GEN_NO_COMMON_BLK : if ( not WITH_COMMON_G ) generate
      plloutclk_i      <= pllOutClk;
      plloutrefclk_i   <= pllOutRefClk;

      pll_locked_i     <= pllLocked;
      pll_refclklost_i <= pllRefClkLost;
   end generate;

   pllRst    <= pllRst_i;
   rxDecErr  <= rxDecErr_i;
   rxDispErr <= rxDispErr_i;

end architecture rtl;
