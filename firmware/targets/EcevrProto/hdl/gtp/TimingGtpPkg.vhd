library ieee;
use     ieee.std_logic_1164.all;

package TimingGtpPkg is

   component TimingGtp is
      Port ( 
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
         gt0_rxmcommaalignen_in : in STD_LOGIC;
         gt0_rxpcommaalignen_in : in STD_LOGIC;
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
         gt0_txbufstatus_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
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
         GT0_PLL1RESET_OUT : out STD_LOGIC;
         GT0_PLL1LOCK_IN : in STD_LOGIC;
         GT0_PLL1REFCLKLOST_IN : in STD_LOGIC;
         GT0_PLL1OUTCLK_IN : in STD_LOGIC;
         GT0_PLL1OUTREFCLK_IN : in STD_LOGIC
      );
   end component TimingGtp;

   type PllRefClkSelArray is array (natural range 1 downto 0) of std_logic_vector(2 downto 0);

   constant PLLREFCLK_SEL_REF0_C : std_logic_vector(2 downto 0) := "001";
   constant PLLREFCLK_SEL_REF1_C : std_logic_vector(2 downto 0) := "010";

   type MgtControlType is record
      rxPllReset          : std_logic;
      rxReset             : std_logic;
      rxPolarityInvert    : std_logic;
      rxCommaAlignDisable : std_logic;
      txPllReset          : std_logic;
      txReset             : std_logic;
      txPolarityInvert    : std_logic;
      txLoopback          : std_logic_vector(2 downto 0);
   end record MgtControlType;

   constant MGT_CONTROL_INIT_C : MgtControlType := (
      rxPllReset          => '0',
      rxReset             => '0',
      rxPolarityInvert    => '0',
      rxCommaAlignDisable => '0',
      txPllReset          => '0',
      txReset             => '0',
      txPolarityInvert    => '0',
      txLoopback          => (others => '0')
   );

   type MgtStatusType is record
      rxResetDone         : std_logic;
      rxDispError         : std_logic_vector(1 downto 0);
      rxNotIntable        : std_logic_vector(1 downto 0);
      rxPllRefClkLost     : std_logic;
      rxPllLocked         : std_logic;
      txResetDone         : std_logic;
      txPllRefClkLost     : std_logic;
      txPllLocked         : std_logic;
      txBufStatus         : std_logic_vector(1 downto 0);
   end record MgtStatusType;

   constant MGT_STATUS_INIT_C : MgtStatusType := (
      rxResetDone         => '0',
      rxDispError         => (others => '0'),
      rxNotIntable        => (others => '0'),
      rxPllRefClkLost     => '0',
      rxPllLocked         => '0',
      txResetDone         => '0',
      txPllRefClkLost     => '0',
      txPllLocked         => '0',
      txBufStatus         => (others => '0')
   );

end package TimingGtpPkg;
