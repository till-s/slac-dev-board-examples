-- top-level (pin agnostic)
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

library unisim;
use     unisim.vcomponents.all;

use     work.EcEvrBspPkg.all;
use     work.EcEvrProtoPkg.all;

entity TE0715Top is
  -- WARNING: vivado 2021.1 crashed w/o indication what went wrong if
  --          a generic w/o default is not set by the tool!
  generic (
    GIT_HASH_G               : std_logic_vector(31 downto 0) := (others => '0');
    NUM_LED_G                : natural := 9;
    NUM_POF_G                : natural := 0;
    NUM_GPIO_G               : natural := 3;
    NUM_SFP_G                : natural := 1;
    NUM_MGT_G                : natural := 4;
    NUM_REFCLK_G             : natural := 2;
    PLL_CLK_FREQ_G           : real    := 0.0E6;
    SYS_CLK_FREQ_G           : real    := 50.0E6;
    LAN9254_CLK_FREQ_G       : real    := 50.0E6;
    MGT_USED_IDX_G           : natural := 1;
    MGT_REF_CLK_USED_IDX_G   : natural := 1
  );
  port (
    DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba            : inout STD_LOGIC_VECTOR (  2 downto 0 );
    DDR_cas_n         : inout STD_LOGIC;
    DDR_ck_n          : inout STD_LOGIC;
    DDR_ck_p          : inout STD_LOGIC;
    DDR_cke           : inout STD_LOGIC;
    DDR_cs_n          : inout STD_LOGIC;
    DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt           : inout STD_LOGIC;
    DDR_ras_n         : inout STD_LOGIC;
    DDR_reset_n       : inout STD_LOGIC;
    DDR_we_n          : inout STD_LOGIC;
    FIXED_IO_ddr_vrn  : inout STD_LOGIC;
    FIXED_IO_ddr_vrp  : inout STD_LOGIC;
    FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk   : inout STD_LOGIC;
    FIXED_IO_ps_porb  : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;

    -- LAN9254 chip interface
    lan9254Pins              : inout std_logic_vector(43 downto 0);

    -- FT240X FIFO interface
--    fifoPins                 : inout FT240FifoIOType;

    -- LEDs
    ledPins                  : inout std_logic_vector(NUM_LED_G - 1 downto 0);

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
end entity TE0715Top;

architecture Impl of TE0715Top is

  signal sysClk, sysRst      : std_logic;

begin

  U_EcEvr : entity work.EcevrProto
  generic map (
    GIT_HASH_G               => GIT_HASH_G,
    NUM_LED_G                => NUM_LED_G,
    NUM_POF_G                => NUM_POF_G,
    NUM_GPIO_G               => NUM_GPIO_G,
    NUM_SFP_G                => NUM_SFP_G,
    NUM_MGT_G                => NUM_MGT_G,
    NUM_REFCLK_G             => NUM_REFCLK_G,
    PLL_CLK_FREQ_G           => PLL_CLK_FREQ_G,
    SYS_CLK_FREQ_G           => SYS_CLK_FREQ_G,
    LAN9254_CLK_FREQ_G       => LAN9254_CLK_FREQ_G,
    MGT_USED_IDX_G           => MGT_USED_IDX_G,
    MGT_REF_CLK_USED_IDX_G   => MGT_REF_CLK_USED_IDX_G,
    I2C_CLK_PRG_ENABLE_G     => '0'
  )
  port map (
    -- external clocks
    -- aux-clock from reference clock generator
    pllClkPin                => '0',
    -- from LAN9254 (used to clock fpga logic)
    lan9254ClkPin            => sysClk,

    -- LAN9254 chip interface
    lan9254Pins              => lan9254Pins,

    -- FT240X FIFO interface
--    fifoPins                 : inout FT240FifoIOType;

    -- LEDs
    ledPins                  => ledPins,

    -- Various IO
    pofInpPins               => open,
    pofOutPins               => open,

    gpioDatPins              => gpioDatPins,
    gpioDirPins              => gpioDirPins,

    pwrCyclePin              => pwrCyclePin,

    i2cSdaPins               => i2cSdaPins,
    i2cSclPins               => i2cSclPins,

    eepWPPin                 => eepWPPin,
    eepSz32kPin              => eepSz32kPin,

    i2cISObPin               => i2cISObPin,

    jumper7Pin               => jumper7Pin,
    jumper8Pin               => jumper8Pin,

    spiMosiPin               => open,
    spiCselPin               => open,
    spiMisoPin               => '1',

    sfpLosPins               => sfpLosPins,
    sfpPresentbPins          => sfpPresentbPins,
    sfpTxFaultPins           => sfpTxFaultPins,
    sfpTxEnPins              => sfpTxEnPins,

    mgtRxPPins               => mgtRxPPins,
    mgtRxNPins               => mgtRxNPins,
    mgtTxPPins               => mgtTxPPins,
    mgtTxNPins               => mgtTxNPins,

    mgtRefClkPPins           => mgtRefClkPPins,
    mgtRefClkNPins           => mgtRefClkNPins
  );

  U_PS7 : entity work.Ps7Wrapper
  port map (
    DDR_addr          => DDR_addr,
    DDR_ba            => DDR_ba,
    DDR_cas_n         => DDR_cas_n,
    DDR_ck_n          => DDR_ck_n,
    DDR_ck_p          => DDR_ck_p,
    DDR_cke           => DDR_cke,
    DDR_cs_n          => DDR_cs_n,
    DDR_dm            => DDR_dm,
    DDR_dq            => DDR_dq,
    DDR_dqs_n         => DDR_dqs_n,
    DDR_dqs_p         => DDR_dqs_p,
    DDR_odt           => DDR_odt,
    DDR_ras_n         => DDR_ras_n,
    DDR_reset_n       => DDR_reset_n,
    DDR_we_n          => DDR_we_n,
    FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
    FIXED_IO_mio      => FIXED_IO_mio,
    FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
    sysClk            => sysClk
  );

end architecture Impl;
