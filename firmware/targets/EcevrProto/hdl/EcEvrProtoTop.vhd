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
use     work.IlaWrappersPkg.all;

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

  constant NUM_BUS_SUBS_C : natural   := 1;
  constant SUB_IDX_LOC_C  : natural   := 0;

  constant NUM_SUBSUBS_C  : natural   := 3;
  constant SS_IDX_LOC_C   : natural   := 0;
  constant SS_IDX_DRP_C   : natural   := 1;
  constant SS_IDX_ICAP_C  : natural   := 2;

  constant SPI_NORMAL_BOOT_FILE_ADDR_C : A24Type := x"220000";

  constant SPI_FILE_MAP_C : FlashFileArray := (
    0 => (
            id      => x"47", -- 'G' ('golden')
            begAddr => x"000000",
            endAddr => x"21FFFF",
            flags   => FLASH_FILE_FLAG_WP_C
         ),
    1 => (
            id      => x"42", -- 'B' ('barrier' following the standard/wildcard image)
            begAddr => x"440000",
            endAddr => x"44FFFF",
            flags   => FLASH_FILE_FLAG_WP_C
         ),
    2 => (
            id      => x"54", -- 'T' ('test')
            begAddr => x"FE0000",
            endAddr => x"FFFFFF",
            flags   => FLASH_FILE_FLAGS_NONE_C
         ),
    3 => ( -- catch-all entry must be last!
            id      => FOE_FILE_ID_WILDCARD_C,
            begAddr => SPI_NORMAL_BOOT_FILE_ADDR_C,
            endAddr => x"43FFFF",
            flags   => FLASH_FILE_FLAGS_NONE_C
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
  signal pdoLeds          : Slv08Array      (2 downto 0)      := (others => (others => '0'));
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

  signal busReqs          : Udp2BusReqArray(NUM_BUS_SUBS_C - 1 downto 0) := (others => UDP2BUSREQ_INIT_C);
  signal busReps          : Udp2BusRepArray(NUM_BUS_SUBS_C - 1 downto 0) := (others => UDP2BUSREP_ERROR_C);

  signal busLocReqs       : Udp2BusReqArray(NUM_SUBSUBS_C - 1 downto 0)  := (others => UDP2BUSREQ_INIT_C);
  signal busLocReps       : Udp2BusRepArray(NUM_SUBSUBS_C - 1 downto 0)  := (others => UDP2BUSREP_ERROR_C);
  signal spiMstLoc        : BspSpiMstType  := BSP_SPI_MST_INIT_C;

  signal icapReq          : Udp2BusReqType := UDP2BUSREQ_INIT_C;
  signal icapRep          : Udp2BusRepType := UDP2BUSREP_INIT_C;

  signal fileWP           : std_logic      := '0';

  signal busReqLoc        : Udp2BusReqType;
  signal busRepLoc        : Udp2BusRepType := UDP2BUSREP_ERROR_C;

  signal mgtRxControl     : std_logic_vector(15 downto 0);
  signal mgtTxControl     : std_logic_vector(15 downto 0);
  signal mgtTxStatus      : std_logic_vector(15 downto 0);
  signal mgtRxStatus      : std_logic_vector(15 downto 0);

  signal rxPDOMst         : Lan9254PDOMstType;

  signal dbgTrg           : std_logic;

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
      GEN_FOE_ILA_G     => false,
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
      fileWP            => fileWP,

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
    signal drpBsy        : std_logic;

  begin

    U_DRP : entity work.Bus2DRP
      generic map (
        GEN_ILA_G        => false
      )
      port map (
        clk              => sysClkLoc,
        rst              => sysRstLoc,

        req              => busLocReqs(SS_IDX_DRP_C),
        rep              => busLocReps(SS_IDX_DRP_C),

        drpAddr          => drpAddr,
        drpEn            => drpEn,
        drpWe            => drpWe,
        drpRdy           => drpRdy,
        drpDou           => drpDou,
        drpBsy           => drpBsy,
        drpDin           => drpDin
      );

    U_MGT : entity work.TimingMgtWrapper
      port map (
        sysClk           => sysClkLoc, -- in  std_logic;
        sysRst           => sysRstLoc, -- in  std_logic;

        -- drp
        drpBsy           => drpBsy,
        drpAddr          => drpAddr,
        drpDin           => drpDin,
        drpEn            => drpEn,
        drpWe            => drpWe,
        drpDou           => drpDou,
        drpRdy           => drpRdy,

        -- gtp fpga io
        gtRxP            => mgtRxP(0),
        gtRxN            => mgtRxN(0),
        gtTxP            => mgtTxP(0),
        gtTxN            => mgtTxN(0),

        -- clock pll selection:
        gtRxPllSel       => '0',
        gtTxPllSel       => '0',

        -- signals for external common block (with_common_g = false)
        pllOutClk        => open, -- in  std_logic_vector(1 downto 0) := "00";
        pllOutRefClk     => open, -- in  std_logic_vector(1 downto 0) := "00";

        pllLocked        => open, -- in  std_logic := '0';
        pllRefClkLost    => open, -- in  std_logic := '0';

        pllRst           => open, -- out std_logic;

        -- ref clock for internal common block (WITH_COMMON_G = true)
        gtRefClk(0)      => mgtRefClk, -- in  std_logic := '0';
        gtRefClk(1)      => '0',       -- in  std_logic := '0';-- Unused in GTHE3, but used in GTHE4

        -- Rx ports
        rxControl        => mgtRxControl, -- in  std_logic_vector(1 downto 0) := (others => '0');
        rxStatus         => mgtRxStatus, -- out std_logic_vector(7 downto 0);
        rxUsrClkActive   => open, -- in  std_logic := '1';
        rxUsrClk         => mgtRxRecClk,  -- in  std_logic;
        rxData           => mgtRxData,    -- out std_logic_vector(15 downto 0);
        rxDataK          => mgtRxDataK,   -- out std_logic_vector(1 downto 0);
        rxOutClk         => mgtRxRecClk, -- out std_logic;

        -- Tx Ports
        txControl        => mgtTxControl, -- in  std_logic_vector(1 downto 0) := (others => '0');
        txStatus         => mgtTxStatus, -- out std_logic_vector(7 downto 0);
        txUsrClk         => mgtTxUsrClk, -- in  std_logic;
        txUsrClkActive   => open, -- in  std_logic := '1';
        txData           => mgtTxData,  -- in  std_logic_vector(15 downto 0);
        txDataK          => mgtTxDataK, -- in  std_logic_vector(1 downto 0);
        txOutClk         => mgtTxUsrClk  -- out std_logic;
      );

    mgtLeds(2) <= '0';

  end block B_MGT;

  B_LOC_REGS : block is

    constant NUM_REGS_C : natural := 5;

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
         ADDR_MSB_G => 16,
         ADDR_LSB_G => 14,
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
      v.regs(1)              := mgtRxStatus & mgtTxStatus;
      v.regs(4)(23 downto 0) := "00000" & sfpPresentb(0) & sfpTxFault(0) & sfpLos(0) & x"0000";
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

    mgtTxControl <= r.regs(0)(15 downto  0);
    mgtRxControl <= r.regs(0)(31 downto 16);

    sfpTxEn(0)   <= r.regs(4)(          31);
    dbgTrg       <= r.regs(4)(          30);

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
        addr   => icapReq.dwaddr(15 downto 0),
        rdnw   => icapReq.rdnwr,
        dInp   => icapReq.data,
        req    => icapReq.valid,

        dOut   => icapRep.rdata,
        ack    => icapRep.valid
      );

    busLocReps(SS_IDX_ICAP_C).berr <= '0';

  end block B_LOC_REGS;

  B_ICAP_INIT : block is

    subtype DwAddrType is std_logic_vector(icapReq.dwaddr'range);

    function dwaddr(constant x : natural) return DwAddrType is
      variable v : DwAddrType;
    begin
      v := DwAddrType( to_unsigned( x, v'length ) );
      return v;
    end function dwaddr;

    constant ICAP_REG_BOOTSTS_C : DwAddrType := dwaddr(16#16#);
    constant ICAP_REG_WBSTAR_C  : DwAddrType := dwaddr(16#10#);
    constant ICAP_REG_TIMER_C   : DwAddrType := dwaddr(16#11#);
    constant ICAP_REG_CMD_C     : DwAddrType := dwaddr(16#04#);

    constant ICAP_TIMER_USR_MON_C : std_logic_vector(31 downto 0) := x"8000_0000";
    constant ICAP_TIMER_CFG_MON_C : std_logic_vector(31 downto 0) := x"4000_0000";
    constant ICAP_CMD_REBOOT_C    : std_logic_vector(31 downto 0) := x"0000_000F";

    type IcapProgType is record
      addr : DwAddrType;
      data : std_logic_vector(31 downto 0);
      rdnw : std_logic;
    end record IcapProgType;

    type IcapProgArray is array(integer range <>) of IcapProgType;

    -- set timer to some small timeout so that if the user file does not load
    -- the watchdog expires
    constant ICAP_PROG_C : IcapProgArray := (
     -1 => ( rdnw => '1', addr => ICAP_REG_BOOTSTS_C, data => x"0000_0000"                                              ),
      0 => ( rdnw => '1', addr => ICAP_REG_BOOTSTS_C, data => x"0000_0000"                                              ),
      1 => ( rdnw => '0', addr => ICAP_REG_WBSTAR_C , data => (x"00" & std_logic_vector( SPI_NORMAL_BOOT_FILE_ADDR_C) ) ),
      2 => ( rdnw => '1', addr => ICAP_REG_WBSTAR_C , data => (x"00" & std_logic_vector( SPI_NORMAL_BOOT_FILE_ADDR_C) ) ),
      3 => ( rdnw => '0', addr => ICAP_REG_TIMER_C  , data => (ICAP_TIMER_CFG_MON_C or x"0000_0100" )                   ), 
      4 => ( rdnw => '1', addr => ICAP_REG_TIMER_C  , data => (ICAP_TIMER_CFG_MON_C or x"0000_0100" )                   ), 
      5 => ( rdnw => '0', addr => ICAP_REG_CMD_C    , data => ICAP_CMD_REBOOT_C                                         ),
      6 => ( rdnw => '1', addr => ICAP_REG_CMD_C    , data => ICAP_CMD_REBOOT_C                                         )
    );

    type StateType is (IDLE, RUN);

    type RegType is record
      state     : StateType;
      valid     : std_logic;
      ltrg      : std_logic;
      ip        : integer range ICAP_PROG_C'range;
    end record RegType;

    constant REG_INIT_C : RegType := (
      state     => IDLE,
      valid     => '1',
      ltrg      => '0',
      ip        => ICAP_PROG_C'low
    );


    signal r       : RegType := REG_INIT_C;
    signal rin     : RegType;

  begin

    -- decide if we need to warm-boot

    P_ICAP_INIT_COMB : process ( r, busLocReqs, icapRep, jumper7, dbgTrg ) is
      variable v : RegType;
    begin
      v   := r;

      icapReq                         <= UDP2BUSREQ_INIT_C;
      icapReq.dwaddr                  <= ICAP_PROG_C( r.ip ).addr;
      icapReq.data                    <= ICAP_PROG_C( r.ip ).data;
      icapReq.be                      <= "1111";
      icapReq.rdnwr                   <= ICAP_PROG_C( r.ip ).rdnw;
      icapReq.valid                   <= r.valid;

      busLocReps(SS_IDX_ICAP_C)       <= icapRep;
      busLocReps(SS_IDX_ICAP_C).valid <= '0';

      v.ltrg := dbgTrg;

      case ( r.state ) is

        when IDLE =>
          -- hand over the bus
          icapReq                         <= busLocReqs(SS_IDX_ICAP_C);
          busLocReps(SS_IDX_ICAP_C).valid <= icapRep.valid;
          if ( ( (dbgTrg and not r.ltrg) = '1') and ( busLocReqs(SS_IDX_ICAP_C).valid = '0' ) ) then
             v.state := RUN;
             v.ip    := ICAP_PROG_C'low;
          end if;

        when RUN =>
          if ( icapRep.valid = '1' ) then
            if ( r.ip = ICAP_PROG_C'high ) then
              -- we probably never get here if the reboot is successful but if
              -- something goes wrong we might be able to recover...
              v.state := IDLE;
            else
              v.ip    := r.ip + 1;
              if ( r.ip = 0 ) then
                -- got the result of the readback
                if (    ( icapRep.berr     = '1' )  -- invalid readback
                     or ( jumper7          = '0' )  -- jumper7 = 0 prevents reboot
                     or ( icapRep.rdata(8) = '1' )  -- if this is already 2nd boot; don't attempt a 3rd
                ) then
                  v.state      := IDLE;
                end if;
              end if;
            end if;
          end if;
          
      end case;

      rin <= v;
    end process P_ICAP_INIT_COMB;

    P_ICAP_INIT_SEQ : process ( sysClkLoc ) is
    begin
       if ( rising_edge( sysClkLoc ) ) then
         if ( sysRstLoc = '1' ) then
           r <= REG_INIT_C;
         else
           r <= rin;
         end if;
       end if;
    end process P_ICAP_INIT_SEQ;

    G_REBOOT_ILA : if ( true ) generate
      U_ILA : component Ila_256
        port map (
            clk                  => sysClkLoc,
            probe0(29 downto  0) => std_logic_vector(icapReq.dwaddr),
            probe0(30          ) => icapReq.rdnwr,
            probe0(31          ) => icapReq.valid,
            probe0(63 downto 32) => icapReq.data,

            probe1(31 downto  0) => icapRep.rdata,
            probe1(32          ) => icapRep.valid,
            probe1(33 downto 33) => std_logic_vector( to_unsigned( StateType'pos( r.state ), 1 ) ),
            probe1(35 downto 34) => "00",
            probe1(39 downto 36) => std_logic_vector( to_unsigned( r.ip , 4 ) ),
            probe1(63 downto 40) => (others => '0'),

            probe2(63 downto  0) => (others => '0'),
            probe3(63 downto  0) => (others => '0')
        );
    end generate G_REBOOT_ILA;

  end block B_ICAP_INIT;

  B_RXPDO : block is
  begin

    P_LED : process ( sysClkLoc ) is
    begin
      if ( rising_edge( sysClkLoc ) ) then
        if ( ( sysRstLoc = '1' ) or ( rxPDOMst.escState /= OP ) ) then
          pdoLeds <= (others => (others => '0'));
        elsif ( ( rxPDOMst.valid = '1' ) ) then
          if ( unsigned( rxPDOMst.wrdAddr ) = 0 ) then
            if ( rxPDOMst.ben(0) = '1' ) then
              pdoLeds(0) <= rxPDOMst.data( 7 downto  0);
            end if;
            if ( rxPDOMst.ben(1) = '1' ) then
              pdoLeds(1) <= rxPDOMst.data(15 downto  8);
            end if;
          elsif ( unsigned( rxPDOMst.wrdAddr ) = 1 ) then
            if ( rxPDOMst.ben(0) = '1' ) then
              pdoLeds(2) <= rxPDOMst.data( 7 downto  0);
            end if;
          end if;
        end if;
      end if;
    end process P_LED;

  end block B_RXPDO;

  G_PWM : for i in tstLeds'range generate

    signal pwSat     : unsigned( 8 downto 0) := (others => '0');
    signal pwClipped : unsigned( 7 downto 0) := (others => '0');

  begin

    U_PWM : entity work.PwmCore
      generic map (
        SYS_CLK_FREQ_G => SYS_CLK_FREQ_G
      )
      port map (
        clk            => sysClkLoc,
        rst            => sysRstLoc,
        pw             => pwClipped,
        pwmOut         => tstLeds(i)
      );

    P_SAT : process( sysClkLoc ) is
    begin
      if ( rising_edge( sysClkLoc ) ) then
        if ( sysRstLoc = '1' ) then
          pwSat     <= (others => '0');
          pwClipped <= (others => '0');
        else
          pwSat <=   unsigned( '0' & tstLedPw(8*i + 7 downto 8*i) )
                   + unsigned( '0' & pdoLeds(i) );
          if ( pwSat(8) = '1' ) then
            pwClipped <= (others => '1');
          else
            pwClipped <= pwSat(7 downto 0);
          end if;
        end if;
      end if;
    end process P_SAT;
    
  end generate G_PWM;

  P_LEDS : process( spiMstLoc, pdoLeds, tstLeds, mgtLeds ) is
  begin
    ledsLoc                        <= (others => '0');
    ledsLoc(2 downto 0)            <= mgtLeds;
    ledsLoc(8)                     <= spiMstLoc.util(0) or tstLeds(2); --R
    ledsLoc(7)                     <= spiMstLoc.util(1) or tstLeds(1); --G
    ledsLoc(6)                     <=  '0'              or tstLeds(0); --B
  end process P_LEDS;

  leds   <= ledsLoc;
  spiMst <= spiMstLoc;

end architecture Impl;