-- top-level (pin agnostic)
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.ESCBasicTypesPkg.all;
use     work.Lan9254Pkg.all;
use     work.Lan9254ESCPkg.all;
use     work.ESCFoEPkg.all;
use     work.Udp2BusPkg.all;
use     work.EcEvrBspPkg.all;
use     work.FoE2SpiPkg.all;

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
    SYS_CLK_FREQ_G           : real;
    EEP_WR_WAIT_G            : natural := 1000000
  );
  port (
    -- external clocks
    -- aux-clock from reference clock generator
    pllClk                   : in    std_logic := '0';
    -- from LAN9254 (used to clock fpga logic)
    lan9254Clk               : in    std_logic := '0';

    sysClk                   : out   std_logic;
    sysRst                   : out   std_logic;
    -- external request; don't create a loop
    -- from sysRst -> sysRstReq!
    sysRstReq                : in    std_logic := '0';

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

    spiMst                   : out   BspSpiMstType := BSP_SPI_MST_INIT_C;
    spiSub                   : in    BspSpiSubType;

    mgtRxP                   : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtRxN                   : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxP                   : out   std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxN                   : out   std_logic_vector(NUM_MGT_G - 1 downto 0);

    testDone                 : out   std_logic := '1'
  );
end entity EcEvrProtoTop;

architecture Impl of EcEvrProtoTop is

  constant TIMG_RST_CNT_C : natural   := 100;

  -- debounce of sys-reset
  constant SYS_RST_DEBT_C : real      := 0.01;
  -- min-time lan9254 RST# must be asserted
  constant LAN_RST_TIME_C : real      := 0.0005;
  -- wait until lan9254 comes on-line
  constant LAN_RST_WAIT_C : real      := 0.01;

  constant SYS_RST_DEBC_C : natural   := natural( SYS_RST_DEBT_C * SYS_CLK_FREQ_G ) - 1;
  constant LAN_RST_ASSC_C : natural   := natural( LAN_RST_TIME_C * SYS_CLK_FREQ_G ) - 1;
  constant LAN_RST_WAIC_C : natural   := natural( LAN_RST_WAIT_C * SYS_CLK_FREQ_G ) - 1;

  constant NUM_BUS_SUBS_C : natural   := 2;
  constant SUB_IDX_DRP_C  : natural   := 0;
  constant SUB_IDX_LOC_C  : natural   := 1;

  constant NUM_SUBSUBS_C  : natural   := 2;
  constant SS_IDX_LOC_C   : natural   := 0;
  constant SS_IDX_ICAP_C  : natural   := 1;

  constant SPI_FILE_MAP_C : FlashFileArray := (
    0 => (
            id      => x"42", -- 'B'
            begAddr => x"000000",
            endAddr => x"21FFFF"
         ),
    1 => (
            id      => x"54", -- 'T'
            begAddr => x"FE0000",
            endAddr => x"FFFFFF"
         ),
    2 => ( -- catch-all entry must be last!
            id      => FOE_FILE_NAME_WILDCARD_C,
            begAddr => x"220000",
            endAddr => x"43FFFF"
         )
  );

  signal sysClkLoc        : std_logic;
  signal sysRstLoc        : std_logic := '1';
  signal lanRstAssertCnt  : natural range 0 to LAN_RST_ASSC_C := LAN_RST_ASSC_C;
  signal lanRstWaitCnt    : natural range 0 to LAN_RST_WAIC_C := LAN_RST_WAIC_C;
  signal lan9254RstbOut   : std_logic := '0';
  signal lan9254RstbInp   : std_logic;

  signal jumperDebCnt     : natural range 0 to SYS_RST_DEBC_C := SYS_RST_DEBC_C;
  signal jumperRst        : std_logic;

  signal mgtRstCnt        : natural range 0 to TIMG_RST_CNT_C := TIMG_RST_CNT_C;

  signal ledsLoc          : std_logic_vector(leds'range)      := (others => '0');
  signal pdoLeds          : std_logic_vector(2 downto 0)      := (others => '0');
  signal tstLeds          : std_logic_vector(2 downto 0)      := (others => '0');
  signal mgtLeds          : std_logic_vector(2 downto 0)      := (others => '0');

  signal tstLedPw         : std_logic_vector(23 downto 0);

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

  signal busLocReqs       : Udp2BusReqArray(NUM_SUBSUBS_C - 1 downto 0)  := (others => UDP2BUSREQ_INIT_C);
  signal busLocReps       : Udp2BusRepArray(NUM_SUBSUBS_C - 1 downto 0)  := (others => UDP2BUSREP_ERROR_C);
  signal spiMstLoc        : BspSpiMstType  := BSP_SPI_MST_INIT_C;

  signal file0WP          : std_logic      := '0';

  signal busReqLoc        : Udp2BusReqType;
  signal busRepLoc        : Udp2BusRepType := UDP2BUSREP_ERROR_C;

  signal mgtLoopback      : std_logic_vector(2 downto 0);
  signal mgtRxControl     : std_logic_vector(1 downto 0);
  signal mgtTxControl     : std_logic_vector(1 downto 0);
  signal mgtTxStatus      : std_logic_vector(7 downto 0);
  signal mgtRxStatus      : std_logic_vector(7 downto 0);

  signal rxPDOMst         : Lan9254PDOMstType;

begin

  -- abbreviations
  busReqLoc                  <= busLocReqs( SS_IDX_LOC_C );
  busLocReps( SS_IDX_LOC_C ) <= busRepLoc;

  -- ATM we have not connected an MMCM
  assert ( SYS_CLK_FREQ_G = LAN9254_CLK_FREQ_G )
    report ("differen SYS_CLK_FREQ_G requires an MMCM")
    severity failure;

  sysClkLoc      <= lan9254Clk;

  sysClk         <= sysClkLoc;
  sysRst         <= sysRstLoc;

  jumperRst      <= '1' when jumperDebCnt    > 0 else '0';
  lan9254RstbOut <= '0' when lanRstAssertCnt > 0 else '1';

  P_RESET    : process( jumperDebCnt, lanRstWaitCnt, lanRstAssertCnt, sysRstReq ) is
  begin
    jumperRst      <= '0';
    sysRstLoc      <= sysRstReq;
    lan9254RstbOut <= '1';

    if ( lanRstAssertCnt > 0 ) then
      lan9254RstbOut <= '0';
    end if;

    if ( jumperDebCnt    > 0 ) then
      jumperRst <= '1';
    end if;

    if ( lanRstWaitCnt   > 0 ) then
      sysRstLoc      <= '1';
    end if;
  end process P_RESET;

  P_FPGA_RST : process ( sysClkLoc ) is
  begin
    if ( rising_edge( sysClkLoc ) ) then
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
      sysClk          => sysClkLoc,
      sysRst          => sysRstLoc,

      imageSel        => HBI16M,

      fpga_i          => lan9254_i,
      fpga_o          => lan9254_o,
      fpga_t          => lan9254_t,

      -- SPI image
      spiMst          => BSP_SPI_MST_INIT_C,
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
      CLK_FREQ_G        => SYS_CLK_FREQ_G,
      GIT_HASH_G        => GIT_HASH_G,
      SPI_FILE_MAP_G    => SPI_FILE_MAP_C,
      EEP_I2C_ADDR_G    => x"50",
      EEP_I2C_MUX_SEL_G => std_logic_vector( to_unsigned( EEP_I2C_IDX_C, 4 ) ),
      GEN_HBI_ILA_G     => false,
      GEN_ESC_ILA_G     => true,
      GEN_EOE_ILA_G     => true,
      GEN_FOE_ILA_G     => true,
      GEN_U2B_ILA_G     => false,
      GEN_CNF_ILA_G     => true,
      GEN_I2C_ILA_G     => false,
      GEN_EEP_ILA_G     => false,
      NUM_BUS_SUBS_G    => NUM_BUS_SUBS_C
    )
    port map (
      sysClk            => sysClkLoc,
      sysRst            => sysRstLoc,

      escRst            => sysRstLoc, -- in     std_logic := '0';
      eepRst            => sysRstLoc, -- in     std_logic := '0';
      hbiRst            => open,      -- in     std_logic := '0';

      lan9254_hbiOb     => lan9254HbiOb,
      lan9254_hbiIb     => lan9254HbiIb,

      extHbiSel         => open, -- in     std_logic         := '0';
      extHbiReq         => open, -- in     Lan9254ReqType    := LAN9254REQ_INIT_C;
      extHbiRep         => open, -- out    Lan9254RepType;

      busReqs           => busReqs,
      busReps           => busReps,

      rxPDOMst          => rxPDOMst, -- out    Lan9254PDOMstType;
      rxPDORdy          => open,     -- in     std_logic := '1';

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

      spiMst            => spiMstLoc,
      spiSub            => spiSub,
      file0WP           => file0WP,

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
        clk              => sysClkLoc,
        rst              => sysRstLoc,

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
        sysClk           => sysClkLoc, -- in  std_logic;
        sysRst           => sysRstLoc, -- in  std_logic;

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

        pllLocked        => mgtLeds(1), -- in  std_logic := '0';
        pllRefClkLost    => mgtLeds(0), -- in  std_logic := '0';

        pllRst           => open, -- out std_logic;

        -- ref clock for internal common block (WITH_COMMON_G = true)
        gtRefClk         => mgtRefClk, -- in  std_logic := '0';
        gtRefClkDiv2     => open, -- in  std_logic := '0';-- Unused in GTHE3, but used in GTHE4

        -- Rx ports
        rxControl        => mgtRxControl, -- in  std_logic_vector(1 downto 0) := (others => '0');
        rxStatus         => mgtRxStatus, -- out std_logic_vector(7 downto 0);
        rxUsrClkActive   => open, -- in  std_logic := '1';
        rxCdrStable      => open, -- out std_logic;
        rxUsrClk         => mgtRxRecClk,  -- in  std_logic;
        rxData           => mgtRxData,    -- out std_logic_vector(15 downto 0);
        rxDataK          => mgtRxDataK,   -- out std_logic_vector(1 downto 0);
        rxDispErr        => mgtRxDispErr, -- out std_logic_vector(1 downto 0);
        rxDecErr         => mgtRxDecErr,  -- out std_logic_vector(1 downto 0);
        rxOutClk         => mgtRxRecClk, -- out std_logic;

        -- Tx Ports
        txControl        => mgtTxControl, -- in  std_logic_vector(1 downto 0) := (others => '0');
        txStatus         => mgtTxStatus, -- out std_logic_vector(7 downto 0);
        txUsrClk         => mgtTxUsrClk, -- in  std_logic;
        txUsrClkActive   => open, -- in  std_logic := '1';
        txData           => mgtTxData,  -- in  std_logic_vector(15 downto 0);
        txDataK          => mgtTxDataK, -- in  std_logic_vector(1 downto 0);
        txOutClk         => mgtTxUsrClk, -- out std_logic;

        -- Loopback
        loopback         => mgtLoopback -- in std_logic_vector(2 downto 0) := (others => '0')
      );

    mgtLeds(2) <= '0';

  end block B_MGT;

  B_LOC_REGS : block is

    constant NUM_REGS_C : natural := 4;

    type StateType is (IDLE);

    type RegType is record
      state      : StateType;
      rep        : Udp2BusRepType;
      regs       : Slv32Array(0 to NUM_REGS_C - 1);
    end record RegType;

    constant REG_INIT_C : RegType := (
      state      => IDLE,
      rep        => UDP2BUSREP_INIT_C,
      -- initialize individual registers here
      regs       => (others => (others => '0'))
    );

    signal r   : RegType := REG_INIT_C;
    signal rin : RegType;

  begin

     U_BUSMUX : entity work.Udp2BusMux
       generic map (
         ADDR_MSB_G => 8,
         ADDR_LSB_G => 6,
         NUM_SUBS_G => NUM_SUBSUBS_C
       )
       port map (
         clk        => sysClkLoc,
         rst        => sysRstLoc,

         reqIb      => busReqs( SUB_IDX_LOC_C downto SUB_IDX_LOC_C ),
         repIb      => busReps( SUB_IDX_LOC_C downto SUB_IDX_LOC_C ),

         reqOb      => busLocReqs,
         repOb      => busLocReps
       );

     P_COMB : process ( r, busReqLoc,
       mgtRxStatus, mgtTxStatus,
       sfpPresentb, sfpTxFault, sfpLos
     ) is
       variable v : RegType;
       variable a : unsigned(7 downto 0);
     begin
      v   := r;
      a   := unsigned( busReqLoc.dwaddr( 7 downto 0 ) );

      if ( ( busReqLoc.valid and r.rep.valid ) = '1' ) then
        v.rep.valid := '0';
      end if;

      case ( r.state ) is
        when IDLE =>
          if ( ( not r.rep.valid and busReqLoc.valid ) = '1' ) then
            if    ( a >= NUM_REGS_C ) then
              v.rep := UDP2BUSREP_ERROR_C;
            else
              v.rep.berr  := '0';
              v.rep.valid := '1';
              if ( busReqLoc.rdnwr = '1' ) then
                v.rep.rdata := r.regs( to_integer(a) );
              else
                for i in busReqLoc.be'range loop
                  if ( busReqLoc.be(i) = '1' ) then
                    v.regs( to_integer(a) )(8*i + 7 downto 8*i) := busReqLoc.data(8*i+7 downto 8*i);
                  end if;
                end loop;
              end if;
            end if;
          end if;
      end case;

      -- read-only
      v.regs(1)(23 downto 0) := "00000" & sfpPresentb(0) & sfpTxFault(0) & sfpLos(0) &
                                mgtRxStatus &
                                mgtTxStatus;
      rin <= v;
    end process P_COMB;

    P_SEQ : process ( sysClkLoc ) is
    begin
      if ( rising_edge( sysClkLoc ) ) then
        if ( sysRstLoc = '1' ) then
          r <= REG_INIT_C;
        else
          r <= rin;
        end if;
      end if;
    end process P_SEQ;

    busRepLoc <= r.rep;

    mgtTxControl <= r.regs(0)( 1 downto  0);
    mgtRxControl <= r.regs(0)( 9 downto  8);
    mgtLoopback  <= r.regs(0)(18 downto 16);

    sfpTxEn(0)   <= r.regs(1)(          31);

    P_PWRCYCLE : process (r) is
    begin
      pwrCycle <= '0';
      if ( r.regs(2)(15 downto 0) = x"dead" ) then
        pwrCycle <= '1';
      end if;
    end process P_PWRCYCLE;

    tstLedPw <= r.regs(3)(tstLedPw'range);

    -- the ICAPE2 can be clocked up to 100MHz (70MHz -2le device @ 0.9V)
    U_ICAP : entity work.IcapE2Reg
      port map (
        clk    => sysClkLoc,
        rst    => sysRstLoc,
        addr   => busLocReqs(SS_IDX_ICAP_C).dwaddr(15 downto 0),
        rdnw   => busLocReqs(SS_IDX_ICAP_C).rdnwr,
        dInp   => busLocReqs(SS_IDX_ICAP_C).data,
        req    => busLocReqs(SS_IDX_ICAP_C).valid,

        dOut   => busLocReps(SS_IDX_ICAP_C).rdata,
        ack    => busLocReps(SS_IDX_ICAP_C).valid
      );

    busLocReps(SS_IDX_ICAP_C).berr <= '0';

  end block B_LOC_REGS;

  B_RXPDO : block is
  begin

    P_LED : process ( sysClkLoc ) is
    begin
      if ( rising_edge( sysClkLoc ) ) then
        if ( sysRstLoc = '1' ) then
          pdoLeds <= (others => '0');
        elsif ( ( rxPDOMst.valid = '1' ) ) then
          if ( unsigned( rxPDOMst.wrdAddr ) = 0 ) then
            if ( rxPDOMst.ben(0) = '1' ) then
              pdoLeds(0) <= rxPDOMst.data(0);
            end if;
            if ( rxPDOMst.ben(1) = '1' ) then
              pdoLeds(1) <= rxPDOMst.data(8);
            end if;
          elsif ( unsigned( rxPDOMst.wrdAddr ) = 1 ) then
            if ( rxPDOMst.ben(0) = '1' ) then
              pdoLeds(2) <= rxPDOMst.data(0);
            end if;
          end if;
        end if;
      end if;
    end process P_LED;

  end block B_RXPDO;

  G_PWM : for i in tstLeds'range generate
    U_PWM : entity work.PwmCore
      generic map (
        SYS_CLK_FREQ_G => SYS_CLK_FREQ_G
      )
      port map (
        clk            => sysClk,
        rst            => sysRst,
        pw             => unsigned( tstLedPw(8*i + 7 downto 8*i) ),
        pwmOut         => tstLeds(i)
      );
        
  end generate G_PWM;

  P_LEDS : process( spiMstLoc, pdoLeds, tstLeds, mgtLeds ) is
  begin
    ledsLoc                        <= (others => '0');
    ledsLoc(2 downto 0)            <= mgtLeds;
    ledsLoc(8)                     <= spiMstLoc.util(0) or pdoLeds(2) or tstLeds(2); --R
    ledsLoc(7)                     <= spiMstLoc.util(1) or pdoLeds(1) or tstLeds(1); --G
    ledsLoc(6)                     <=  '0'              or pdoLeds(0) or tstLeds(0); --B
  end process P_LEDS;

  leds   <= ledsLoc;
  spiMst <= spiMstLoc;

end architecture Impl;
