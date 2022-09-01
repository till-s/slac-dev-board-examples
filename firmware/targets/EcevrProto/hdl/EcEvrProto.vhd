-- top-level (pin agnostic)
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

library unisim;
use     unisim.vcomponents.all;

use     work.EcEvrBspPkg.all;
use     work.EcEvrProtoPkg.all;

entity EcEvrProto is
  generic (
    GIT_HASH_G               : std_logic_vector(31 downto 0);
    NUM_LED_G                : natural := 9;
    NUM_POF_G                : natural := 2;
    NUM_GPIO_G               : natural := 3;
    NUM_SFP_G                : natural := 1;
    NUM_MGT_G                : natural := 4;
    NUM_REFCLK_G             : natural := 2;
    PLL_CLK_FREQ_G           : real    := 25.0E6;
    SYS_CLK_FREQ_G           : real    := 25.0E6;
    LAN9254_CLK_FREQ_G       : real    := 25.0E6
  );
  port (
    -- external clocks
    -- aux-clock from reference clock generator
    pllClkPin                : inout std_logic;
    -- from LAN9254 (used to clock fpga logic)
    lan9254ClkPin            : inout std_logic;

    -- LAN9254 chip interface
    lan9254Pins              : inout std_logic_vector(43 downto 0);

    -- FT240X FIFO interface
--    fifoPins                 : inout FT240FifoIOType;

    -- LEDs
    ledPins                  : inout std_logic_vector(NUM_LED_G - 1 downto 0);

    -- Various IO
    pofInpPins               : inout std_logic_vector(NUM_POF_G - 1 downto 0);
    pofOutPins               : inout std_logic_vector(NUM_POF_G - 1 downto 0);

    gpioDatPins              : inout std_logic_vector(NUM_GPIO_G - 1 downto 0);
    gpioDirPins              : inout std_logic_vector(NUM_GPIO_G - 1 downto 0);

    pwrCyclePin              : inout std_logic;

    i2cSdaPins               : inout std_logic_vector(NUM_I2C_C - 1 downto 0);
    i2cSclPins               : inout std_logic_vector(NUM_I2C_C - 1 downto 0);

    eepWPPin                 : inout std_logic;
    eepSz32kPin              : inout std_logic;

    i2cISObPin               : inout std_logic;

    jumper7Pin               : inout std_logic;
    jumper8Pin               : inout std_logic;

    spiMosiPin               : inout std_logic;
    spiCselPin               : inout std_logic;
    spiMisoPin               : inout std_logic;

    sfpLosPins               : inout std_logic_vector(NUM_SFP_G - 1 downto 0);
    sfpPresentbPins          : inout std_logic_vector(NUM_SFP_G - 1 downto 0);
    sfpTxFaultPins           : inout std_logic_vector(NUM_SFP_G - 1 downto 0);
    sfpTxEnPins              : inout std_logic_vector(NUM_SFP_G - 1 downto 0);

    mgtRxPPins               : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtRxNPins               : in    std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxPPins               : out   std_logic_vector(NUM_MGT_G - 1 downto 0);
    mgtTxNPins               : out   std_logic_vector(NUM_MGT_G - 1 downto 0);

    mgtRefClkPPins           : in    std_logic_vector(NUM_REFCLK_G - 1 downto 0);
    mgtRefClkNPins           : in    std_logic_vector(NUM_REFCLK_G - 1 downto 0)
  );
  -- PULLUP/PULLDOWN are set in XDC
end entity EcEvrProto;

architecture Impl of EcEvrProto is

  constant NUM_USED_MGT_C : natural := 1;

  constant MGT_USED_IDX_C : natural := 1;

  signal pllClkInp     : std_logic;
  signal pllClk        : std_logic;
  signal lan9254ClkInp : std_logic;
  signal lan9254Clk    : std_logic;

  signal leds          : std_logic_vector(ledPins'range);
  signal pofInp        : std_logic_vector(pofInpPins'range);
  signal pofOut        : std_logic_vector(pofOutPins'range);
  signal pwrCycle      : std_logic;
  signal i2cSclInp     : std_logic_vector(i2cSclPins'range);
  signal i2cSclOut     : std_logic_vector(i2cSclPins'range);
  signal i2cSdaInp     : std_logic_vector(i2cSdaPins'range);
  signal i2cSdaOut     : std_logic_vector(i2cSdaPins'range);
  signal eepWP         : std_logic;
  signal eepSz32k      : std_logic;
  signal i2cISObInp    : std_logic;
  signal i2cISObOut    : std_logic;
  signal jumper7       : std_logic;
  signal jumper8       : std_logic;

  signal spiMstOut     : BspSpiMstType := BSP_SPI_MST_INIT_C;
  signal spiSubInp     : BspSpiSubType;

  signal lan9254_i     : std_logic_vector(lan9254Pins'range);
  signal lan9254_o     : std_logic_vector(lan9254Pins'range);
  signal lan9254_t     : std_logic_vector(lan9254Pins'range);

  signal mgtRefClk     : std_logic_vector(NUM_REFCLK_G - 1 downto 0);
  signal mgtRxP        : std_logic_vector(NUM_USED_MGT_C - 1 downto 0);
  signal mgtRxN        : std_logic_vector(NUM_USED_MGT_C - 1 downto 0);
  signal mgtTxP        : std_logic_vector(NUM_USED_MGT_C - 1 downto 0);
  signal mgtTxN        : std_logic_vector(NUM_USED_MGT_C - 1 downto 0);

  signal sfpLos        : std_logic_vector(NUM_SFP_G - 1 downto 0);
  signal sfpPresentb   : std_logic_vector(NUM_SFP_G - 1 downto 0);
  signal sfpTxFault    : std_logic_vector(NUM_SFP_G - 1 downto 0);
  signal sfpTxEn       : std_logic_vector(NUM_SFP_G - 1 downto 0) := (others => '1');

  signal sysClk        : std_logic;
  signal sysRstReq     : std_logic;

begin

  U_IOBUF_CLK_PLL : IOBUF
    port map ( IO => pllClkPin, T => '1', I => '0', O => pllClkInp );

  U_BUFG_CLK_PLL : BUFG
    port map (
      I  => pllClkInp,
      O  => pllClk
    );

  U_IOBUF_LAN9254CLK_PLL : IOBUF
    port map ( IO => lan9254ClkPin, T => '1', I => '0', O => lan9254ClkInp );

  U_BUFG_CLK_LAN9254 : BUFG
    port map (
      I  => lan9254ClkInp,
      O  => lan9254Clk
    );

  G_BUF_CLK_MGT: for i in mgtRefClkPPins'range generate
    U_IBUFDS : component IBUFDS_GTE2
      generic map (
         CLKRCV_TRST      => true, -- ug482
         CLKCM_CFG        => true, -- ug482
         CLKSWING_CFG     => "11"  -- ug482
      )
      port map (
         I                => mgtRefClkPPins(i),
         IB               => mgtRefClkNPins(i),
         CEB              => '0',
         O                => mgtRefClk(i),
         ODIV2            => open
      );
  end generate G_BUF_CLK_MGT;

  G_BUF_LED : for i in ledPins'range generate
    U_IOBUF_LED : IOBUF
      port map ( IO => ledPins(i), T => '0', I => leds(i), O => open );
  end generate G_BUF_LED;

  G_BUF_POF_INP : for i in pofInpPins'range generate
    U_IOBUF_POF_INP : IOBUF
      port map ( IO => pofInpPins(i), T => '1', I => '0',     O => pofInp(i) );
  end generate G_BUF_POF_INP;

  G_BUF_POF_OUT : for i in pofOutPins'range generate
    U_IOBUF_POF_OUT : IOBUF
      port map ( IO => pofOutPins(i), T => '0', I => pofOut(i), O => open );
  end generate G_BUF_POF_OUT;

  U_IOBUF_PWR_CYCLE : IOBUF
      port map ( IO => pwrCyclePin, T => '0', I => pwrCycle, O => open );

  G_BUF_I2C : for i in i2cSdaPins'range generate
    U_IOBUF_I2C_SCL : IOBUF
      port map ( IO => i2cSclPins(i), T => i2cSclOut(i), I => '0', O => i2cSclInp(i) );
    U_IOBUF_I2C_SDA : IOBUF
      port map ( IO => i2cSdaPins(i), T => i2cSdaOut(i), I => '0', O => i2cSdaInp(i) );
  end generate G_BUF_I2C;

  U_IOBUF_EEP_WP : IOBUF
      port map ( IO => eepWPPin,      T => '0',          I => eepWp, O => open );

  U_IOBUF_EEP_SIZE : IOBUF
      port map ( IO => eepSz32kPin,   T => '1',          I => '0', O => eepSz32k );

  U_IOBUF_I2C_ISO: IOBUF
      port map ( IO => i2cISObPin,    T => i2cISObOut,   I => '0', O => i2cISObInp );

  U_IOBUF_J7 : IOBUF
      port map ( IO => jumper7Pin,    T => '1',          I => '0', O => jumper7 );

  U_IOBUF_J8 : IOBUF
      port map ( IO => jumper8Pin,    T => '1',          I => '0', O => jumper8 );

  G_BUF_SFP : for i in NUM_SFP_G - 1 downto 0 generate
    U_IOBUF_Los      : IOBUF port map ( T => '1', IO => sfpLosPins( i ),      O => sfpLos( i ),      I => '0' );
    U_IOBUF_Presentb : IOBUF port map ( T => '1', IO => sfpPresentbPins( i ), O => sfpPresentb( i ), I => '0' );
    U_IOBUF_TxFault  : IOBUF port map ( T => '1', IO => sfpTxFaultPins( i ),  O => sfpTxFault( i ),  I => '0' );

    U_IOBUF_TxEn     : IOBUF port map ( T => '0', IO => sfpTxEnPins( i ),     I => sfpTxEn( i ),     O => open );
  end generate G_BUF_SFP;

  G_LAN9254_IOBUF : for i in lan9254Pins'range generate
    U_BUF : IOBUF
      port map ( IO => lan9254Pins(i), T => lan9254_t(i), I => lan9254_o(i), O => lan9254_i(i) );
  end generate G_LAN9254_IOBUF;

  U_MGT_IBUFN : IBUF port map ( I => mgtRxNPins( MGT_USED_IDX_C ), O => mgtRxN(0) );

  U_MGT_IBUFP : IBUF port map ( I => mgtRxPPins( MGT_USED_IDX_C ), O => mgtRxP(0) );

  U_MGT_OBUFN : OBUF port map ( O => mgtTxNPins( MGT_USED_IDX_C ), I => mgtTxN(0) );

  U_MGT_OBUFP : OBUF port map ( O => mgtTxPPins( MGT_USED_IDX_C ), I => mgtTxP(0) );


  B_STARTUP : block is
    -- STARTUPE2 apparently (this is not documented but I looked at the simulation)
    -- does not immediately pass user clock pulses (caused SPI erase faults!)
    -- but needs a few cycles. Hold off sysRst until this is complete.

    signal    usrCclk        : std_logic;

    -- assume sysClk to be < 200MHz so prescaling by 4 is certainly acceptable
    -- for the STARTUPE2.

    -- 2 bits prescaler, a count of 8 pulses... 2 bit for the reset state
    subtype StartupCntType is unsigned(1 + 2 + 3 - 1 downto 0);

    signal  startupInitCnt : StartupCntType := (
      StartupCntType'left => '1',  -- hold in reset initially
      others => '0'
    );

  begin

    P_STARTUP_CLK : process ( sysClk ) is
    begin
      if ( rising_edge( sysClk ) ) then
        if ( startupInitCnt /= 0 ) then
           startupInitCnt <= startupInitCnt + 1;
        end if;
      end if;
    end process P_STARTUP_CLK;

    sysRstReq <= startupInitCnt( startupInitCnt'left );
    -- we assume the SPI clock is initially low but by using XOR
    -- we don't really care.
    usrCclk   <= startupInitCnt(1) xor spiMstOut.sclk;

    U_STARTUPE2: STARTUPE2
      generic map (
        PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
        SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation.
      )
      port map (
        CFGCLK     => open, -- 1-bit output: Configuration main clock output
        CFGMCLK    => open, -- 1-bit output: Configuration internal oscillator clock output
        EOS        => open, -- 1-bit output: Active high output signal indicating the End Of Startup.
        PREQ       => open, -- 1-bit output: PROGRAM request to fabric output
        CLK        => '0',  -- 1-bit input: User start-up clock input
        GSR        => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
        GTS        => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
        KEYCLEARB  => '1',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
        PACK       => '0',  -- 1-bit input: PROGRAM acknowledge input
        USRCCLKO   => usrCclk, -- 1-bit input: User CCLK input
        USRCCLKTS  => '0',  -- 1-bit input: User CCLK 3-state enable input
        USRDONEO   => '1',  -- 1-bit input: User DONE pin output control
        USRDONETS  => '0'   -- 1-bit input: User DONE 3-state enable output
      );

  end block B_STARTUP;

  U_IOBUF_SPI_CSEL : IOBUF
    port map ( IO => spiCselPin, O => open,           I => spiMstOut.csel, T => '0' );
  U_IOBUF_SPI_MOSI : IOBUF
    port map ( IO => spiMosiPin, O => open,           I => spiMstOut.mosi, T => '0' );
  U_IOBUF_SPI_MISO : IOBUF
    port map ( IO => spiMisoPin, O => spiSubInp.miso, I => '0',            T => '1' );


  U_Top : entity work.EcEvrProtoTop
    generic map (
      GIT_HASH_G               => GIT_HASH_G(GIT_HASH_G'left downto GIT_HASH_G'left - 32 + 1),
      NUM_LED_G                => NUM_LED_G,
      NUM_POF_G                => NUM_POF_G,
      NUM_GPIO_G               => NUM_GPIO_G,
      NUM_SFP_G                => NUM_SFP_G,
      NUM_MGT_G                => NUM_USED_MGT_C,
      PLL_CLK_FREQ_G           => PLL_CLK_FREQ_G,
      LAN9254_CLK_FREQ_G       => LAN9254_CLK_FREQ_G,
      SYS_CLK_FREQ_G           => SYS_CLK_FREQ_G
    )
    port map (
      pllClk                   => pllClk,

      lan9254Clk               => lan9254Clk,

      mgtRefClk                => mgtRefClk,

      sysClk                   => sysClk,
      sysRst                   => open,
      sysRstReq                => sysRstReq,

      leds                     => leds,
      pofInp                   => pofInp,
      pofOut                   => pofOut,
      pwrCycle                 => pwrCycle,
      i2cSclInp                => i2cSclInp,
      i2cSclOut                => i2cSclOut,
      i2cSdaInp                => i2cSdaInp,
      i2cSdaOut                => i2cSdaOut,
      eepWP                    => eepWP,
      eepSz32k                 => eepSz32k,
      i2cISObInp               => i2cISObInp,
      i2cISObOut               => i2cISObOut,
      jumper7                  => jumper7,
      jumper8                  => jumper8,
      sfpLos                   => sfpLos,
      sfpPresentb              => sfpPresentb,
      sfpTxFault               => sfpTxFault,
      sfpTxEn                  => sfpTxEn,
      spiMst                   => spiMstOut,
      spiSub                   => spiSubInp,
      lan9254_i                => lan9254_i,
      lan9254_o                => lan9254_o,
      lan9254_t                => lan9254_t,
      mgtRxN                   => mgtRxN,
      mgtRxP                   => mgtRxP,
      mgtTxN                   => mgtTxN,
      mgtTxP                   => mgtTxP
    );

end architecture Impl;
