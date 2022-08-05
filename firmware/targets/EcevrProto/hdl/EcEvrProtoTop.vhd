-- top-level (pin agnostic)
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.Lan9254Pkg.all;
use     work.Lan9254ESCPkg.all;
use     work.Udp2BusPkg.all;
use     work.EcEvrBspPkg.all;

entity EcEvrProtoTop is
  generic (
    GIT_HASH_G               : std_logic_vector(31 downto 0);
    NUM_LED_G                : natural;
    NUM_POF_G                : natural;
    NUM_GPIO_G               : natural;
    NUM_SFP_G                : natural;
    NUM_MGT_G                : natural;
    PLL_CLK_FREQ_G           : real;
    LAN9254_CLK_FREQ_G       : real;
    EEP_WR_WAIT_G            : natural := 1000000
  );
  port (
    -- external clocks
    -- aux-clock from reference clock generator
    pllClk                   : in    std_logic := '0';
    -- from LAN9254 (used to clock fpga logic)
    lan9254Clk               : in    std_logic := '0';

    mgtRefClk                : in    std_logic := '0';

    -- LEDs
    leds                     : out   std_logic_vector(NUM_LED_G - 1 downto 0) := (others => '0');

    -- POF
    pofInp                   : in    std_logic_vector(NUM_POF_G - 1 downto 0) := (others => '0');
    pofOut                   : out   std_logic_vector(NUM_POF_G - 1 downto 0);

    -- Power-Cycle
    pwrCycle                 : out   std_logic := '0';

    -- Various IO
    eepWP                    : out   std_logic := '0';
    eepSz32k                 : in    std_logic := '0';
    i2cISObInp               : in    std_logic := '0';
    i2cISObOut               : out   std_logic := '1';
    jumper7                  : in    std_logic := '0';
    jumper8                  : in    std_logic := '0';

    -- lan9254
    lan9254_i                : in    std_logic_vector(43 downto 0);
    lan9254_o                : out   std_logic_vector(43 downto 0);
    lan9254_t                : out   std_logic_vector(43 downto 0);

    -- I2C
    i2cSclInp                : in    std_logic_vector(NUM_I2C_C - 1 downto 0) := (others => '1');
    i2cSclOut                : out   std_logic_vector(NUM_I2C_C - 1 downto 0) := (others => '1');
    i2cSdaInp                : in    std_logic_vector(NUM_I2C_C - 1 downto 0) := (others => '1');
    i2cSdaOut                : out   std_logic_vector(NUM_I2C_C - 1 downto 0) := (others => '1');

    sfpLos                   : in    std_logic_vector(NUM_SFP_G - 1 downto 0) := (others => '1');
    sfpPresentb              : in    std_logic_vector(NUM_SFP_G - 1 downto 0) := (others => '1');
    sfpTxFault               : in    std_logic_vector(NUM_SFP_G - 1 downto 0) := (others => '1');
    sfpTxEn                  : out   std_logic_vector(NUM_SFP_G - 1 downto 0) := (others => '0');

    mgtRxP                   : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtRxN                   : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxP                   : out   std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxN                   : out   std_logic_vector(NUM_MGT_G - 1 downto 0);

    testDone                 : out   std_logic := '1'
  );
end entity EcEvrProtoTop;

architecture Impl of EcEvrProtoTop is
  constant TIMG_RST_CNT_C : natural   := 100;
  constant SYS_CLK_FREQ_C : real      := LAN9254_CLK_FREQ_G;

  -- debounce of sys-reset
  constant SYS_RST_DEBT_C : real      := 0.01;
  -- min-time lan9254 RST# must be asserted
  constant LAN_RST_TIME_C : real      := 0.0005;
  -- wait until lan9254 comes on-line
  constant LAN_RST_WAIT_C : real      := 0.01;

  constant SYS_RST_DEBC_C : natural   := natural( SYS_RST_DEBT_C * SYS_CLK_FREQ_C ) - 1;
  constant LAN_RST_ASSC_C : natural   := natural( LAN_RST_TIME_C * SYS_CLK_FREQ_C ) - 1;
  constant LAN_RST_WAIC_C : natural   := natural( LAN_RST_WAIT_C * SYS_CLK_FREQ_C ) - 1;

  constant NUM_BUS_SUBS_C : natural   := 1;
  constant SUB_IDX_DRP_C  : natural   := 0;

  signal sysClk           : std_logic;
  signal sysRst           : std_logic := '1';
  signal lanRstAssertCnt  : natural range 0 to LAN_RST_ASSC_C := LAN_RST_ASSC_C;
  signal lanRstWaitCnt    : natural range 0 to LAN_RST_WAIC_C := LAN_RST_WAIC_C;
  signal lan9254RstbOut   : std_logic := '0';
  signal lan9254RstbInp   : std_logic;

  signal jumperDebCnt     : natural range 0 to SYS_RST_DEBC_C := SYS_RST_DEBC_C;
  signal jumperRst        : std_logic;

  signal mgtRstCnt        : natural range 0 to TIMG_RST_CNT_C := TIMG_RST_CNT_C;

  signal ledsLoc          : std_logic_vector(leds'range);

  signal lan9254HbiOb     : Lan9254HBIOutType;
  signal lan9254HbiIb     : Lan9254HBIInpType;
  signal lan9254Irq       : std_logic;

  signal ecLatch          : std_logic_vector(EC_NUM_LATCH_INP_C - 1 downto 0);
  signal ecSync           : std_logic_vector(EC_NUM_SYNC_OUT_C  - 1 downto 0);

  signal mgtRxData        : std_logic_vector(15 downto 0) := (others => '0');
  signal mgtRxDataK       : std_logic_vector( 1 downto 0) := (others => '0');

  signal mgtTxData        : std_logic_vector(15 downto 0) := x"AABC";
  signal mgtTxDataK       : std_logic_vector( 1 downto 0) := "01";

  signal mgtTxUsrClk      : std_logic;
  signal mgtRxRecClk      : std_logic;
  signal mgtRxRecRst      : std_logic := '1';

  signal mgtRxDispErr     : std_logic_vector(1 downto 0);
  signal mgtRxDecErr      : std_logic_vector(1 downto 0);

  signal busReqs          : Udp2BusReqArray(NUM_BUS_SUBS_C - 1 downto 0) := (others => UDP2BUSREQ_INIT_C);
  signal busReps          : Udp2BusRepArray(NUM_BUS_SUBS_C - 1 downto 0) := (others => UDP2BUSREP_ERROR_C);

begin

  sysClk <= lan9254Clk;

  jumperRst      <= '1' when jumperDebCnt    > 0 else '0';
  sysRst         <= '1' when lanRstWaitCnt   > 0 else '0';
  lan9254RstbOut <= '0' when lanRstAssertCnt > 0 else '1';

  P_FPGA_RST : process (sysClk) is
  begin
    if ( rising_edge( sysClk ) ) then
      if ( lan9254RstbInp = '0' ) then
        lanRstWaitCnt <= LAN_RST_WAIC_C;
      elsif ( lanRstWaitCnt > 0 ) then
        lanRstWaitCnt <= lanRstWaitCnt - 1;
      end if;

      -- debounce jumper
      if ( jumper8 = '1' ) then
        jumperDebCnt   <= SYS_RST_DEBC_C;
      elsif ( jumperDebCnt > 0 ) then
        jumperDebCnt <= jumperDebCnt - 1;
      end if;

      if ( jumperRst = '1' ) then
        lanRstAssertCnt <= LAN_RST_ASSC_C;
      elsif ( lanRstAssertCnt > 0 ) then
        lanRstAssertCnt <= lanRstAssertCnt - 1;
      end if;
    end if;
  end process P_FPGA_RST;

  P_TIMG_RST : process (mgtRxRecClk) is
  begin
    if ( rising_edge( mgtRxRecClk ) ) then
      if ( mgtRstCnt = 0 ) then
        mgtRxRecRst <= '0';
      else
        mgtRstCnt <= mgtRstCnt - 1;
      end if;
    end if;
  end process P_TIMG_RST;

  U_MAP  : entity work.EcEvrBoardMap
    port map (
      sysClk          => sysClk,
      sysRst          => sysRst,

      imageSel        => HBI16M,

      fpga_i          => lan9254_i,
      fpga_o          => lan9254_o,
      fpga_t          => lan9254_t,

      -- SPI image
      spiMst          => BSP_SPI_INIT_C,
      -- provides readback of sck/sdo/scs from digital io
      spiSub          => open, -- out BspSpiType;

      -- GPIO direction must match setup in EEPROM!
      gpio_i          => open, -- out std_logic_vector(31 downto 0);
      gpio_o          => open, -- in  std_logic_vector(31 downto 0) := (others => '0');
      gpio_t          => open, -- in  std_logic_vector(31 downto 0) := (others => '1');

      -- DIGIO signals
      dioSOF          => open, -- out std_logic;
      dioEOF          => open, -- out std_logic;
      dioWdState      => open, -- out std_logic;
      dioLatchIn      => open, -- in  std_logic := '0';
      dioOeExt        => open, -- in  std_logic := '1';
      dioWdTrig       => open, -- out std_logic;
      dioOutValid     => open, -- out std_logic;

      lan9254_hbiOb   => lan9254HbiOb,
      lan9254_hbiIb   => lan9254HbiIb,
      lan9254_irq     => lan9254Irq,
      lan9254RstbInp  => lan9254RstbOut, -- in  std_logic := '1';
      lan9254RstbOut  => lan9254RstbInp, -- out std_logic;

      ec_SYNC         => ecSync,
      ec_LATCH        => ecLatch
    );


  U_MAIN : entity work.EcEvrWrapper
    generic map (
      CLK_FREQ_G        => SYS_CLK_FREQ_C,
      GIT_HASH_G        => GIT_HASH_G,
      EEP_I2C_ADDR_G    => x"50",
      EEP_I2C_MUX_SEL_G => std_logic_vector( to_unsigned( EEP_I2C_IDX_C, 4 ) ),
      GEN_HBI_ILA_G     => false,
      GEN_ESC_ILA_G     => true,
      GEN_EOE_ILA_G     => false,
      GEN_U2B_ILA_G     => true,
      GEN_CNF_ILA_G     => true,
      GEN_I2C_ILA_G     => true,
      GEN_EEP_ILA_G     => false,
      NUM_BUS_SUBS_G    => NUM_BUS_SUBS_C
    )
    port map (
      sysClk            => sysClk,
      sysRst            => sysRst,

      escRst            => sysRst, -- in     std_logic := '0';
      eepRst            => sysRst, -- in     std_logic := '0';
      hbiRst            => open,   -- in     std_logic := '0';

      lan9254_hbiOb     => lan9254HbiOb,
      lan9254_hbiIb     => lan9254HbiIb,

      extHbiSel         => open, -- in     std_logic         := '0';
      extHbiReq         => open, -- in     Lan9254ReqType    := LAN9254REQ_INIT_C;
      extHbiRep         => open, -- out    Lan9254RepType;

      busReqs           => busReqs,
      busReps           => busReps,

      rxPDOMst          => open, -- out    Lan9254PDOMstType;
      rxPDORdy          => open, -- in     std_logic := '1';

      i2cAddr2BMode     => eepSz32k,

      i2c_scl_o         => open, -- out    std_logic_vector(NUM_I2C_G  - 1 downto 0);
      i2c_scl_t         => i2cSclOut,
      i2c_scl_i         => i2cSclInp,
      i2c_sda_o         => open, -- out    std_logic_vector(NUM_I2C_G  - 1 downto 0);
      i2c_sda_t         => i2cSdaOut,
      i2c_sda_i         => i2cSdaInp,

      ec_latch_o        => ecLatch,
      ec_sync_i         => ecSync,

      lan9254_irq       => lan9254Irq,

      testFailed        => open, -- out    std_logic_vector( 4 downto 0);
      escStats          => open, -- out    StatCounterArray(21 downto 0);
      escState          => open, -- out    ESCStateType;
      escDebug          => open, -- out    std_logic_vector(23 downto 0);
      eepEmulActive     => open, -- out    std_logic;

      timingMGTStatus   => open, -- in     std_logic_vector(31 downto 0) := (others => '0');

      timingRecClk      => mgtRxRecClk,
      timingRecRst      => mgtRxRecRst,

      timingRxData      => mgtRxData,
      timingDataK       => mgtRxDataK,
      evrEventsAdj      => open  --: out    std_logic_vector( 3 downto 0)
    );

  B_MGT : block is
    signal drpEn         : std_logic := '0';
    signal drpWe         : std_logic := '0';
    signal drpRdy        : std_logic := '0';
    signal drpAddr       : std_logic_vector(15 downto 0) := (others => '0');
    signal drpDin        : std_logic_vector(15 downto 0) := (others => '0');
    signal drpDou        : std_logic_vector(15 downto 0) := (others => '0');

  begin

    U_DRP : entity work.Bus2DRP
      generic map (
        GEN_ILA_G        => false
      )
      port map (
        clk              => sysClk,
        rst              => sysRst,

        req              => busReqs(SUB_IDX_DRP_C),
        rep              => busReps(SUB_IDX_DRP_C),

        drpAddr          => drpAddr,
        drpEn            => drpEn,
        drpWe            => drpWe,
        drpRdy           => drpRdy,
        drpDou           => drpDou,
        drpDin           => drpDin
      );

    U_MGT : entity work.TimingGtCoreWrapper
      port map (
        sysClk           => sysClk, -- in  std_logic;
        sysRst           => sysRst, -- in  std_logic;

        -- DRP
        drpAddr          => drpAddr(8 downto 0),
        drpDi            => drpDin,
        drpEn            => drpEn,
        drpWe            => drpWe,
        drpDo            => drpDou,
        drpRdy           => drpRdy,

        -- GTP FPGA IO
        gtRxP            => mgtRxP(0),
        gtRxN            => mgtRxN(0),
        gtTxP            => mgtTxP(0),
        gtTxN            => mgtTxN(0),

        -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
        gtRxPllSel       => "00", -- in std_logic_vector(1 downto 0) := "00";
        gtTxPllSel       => "00", -- in std_logic_vector(1 downto 0) := "00";

        -- signals for external common block (WITH_COMMON_G = false)
        pllOutClk        => open, -- in  std_logic_vector(1 downto 0) := "00";
        pllOutRefClk     => open, -- in  std_logic_vector(1 downto 0) := "00";

        pllLocked        => open, -- in  std_logic := '0';
        pllRefClkLost    => open, -- in  std_logic := '0';

        pllRst           => open, -- out std_logic;

        -- ref clock for internal common block (WITH_COMMON_G = true)
        gtRefClk         => mgtRefClk, -- in  std_logic := '0';
        gtRefClkDiv2     => open, -- in  std_logic := '0';-- Unused in GTHE3, but used in GTHE4

        -- Rx ports
        rxControl        => open, -- in  std_logic_vector(1 downto 0) := (others => '0');
        rxStatus         => open, -- out std_logic_vector(7 downto 0);
        rxUsrClkActive   => open, -- in  std_logic := '1';
        rxCdrStable      => open, -- out std_logic;
        rxUsrClk         => mgtRxRecClk,  -- in  std_logic;
        rxData           => mgtRxData,    -- out std_logic_vector(15 downto 0);
        rxDataK          => mgtRxDataK,   -- out std_logic_vector(1 downto 0);
        rxDispErr        => mgtRxDispErr, -- out std_logic_vector(1 downto 0);
        rxDecErr         => mgtRxDecErr,  -- out std_logic_vector(1 downto 0);
        rxOutClk         => mgtRxRecClk, -- out std_logic;

        -- Tx Ports
        txControl        => open, -- in  std_logic_vector(1 downto 0) := (others => '0');
        txStatus         => open, -- out std_logic_vector(7 downto 0);
        txUsrClk         => mgtTxUsrClk, -- in  std_logic;
        txUsrClkActive   => open, -- in  std_logic := '1';
        txData           => mgtTxData,  -- in  std_logic_vector(15 downto 0);
        txDataK          => mgtTxDataK, -- in  std_logic_vector(1 downto 0);
        txOutClk         => mgtTxUsrClk, -- out std_logic;

        -- Loopback
        loopback         => open -- in std_logic_vector(2 downto 0) := (others => '0')
      );

  end block B_MGT;
   
end architecture Impl;
