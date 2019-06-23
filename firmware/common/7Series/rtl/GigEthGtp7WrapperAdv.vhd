-------------------------------------------------------------------------------
-- File       : GigEthGtp7WrapperAdv.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Gtp7 Wrapper for 1000BASE-X Ethernet
-- Note: This module supports up to a MGT QUAD of 1GigE interfaces
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EthMacPkg.all;
use work.GigEthPkg.all;

library unisim;
use unisim.vcomponents.all;

entity GigEthGtp7WrapperAdv is
   generic (
      TPD_G                : time                             := 1 ns;
      NUM_LANE_G           : natural range 1 to 4             := 1;
      PAUSE_EN_G           : boolean                          := true;
      PAUSE_512BITS_G      : positive                         := 8;
      -- Clocking Configurations
      USE_GTREFCLK_G       : boolean                          := false;  --  FALSE: gtClkP/N,  TRUE: gtRefClk
      CLKIN_PERIOD_G       : real                             := 8.0;
      DIVCLK_DIVIDE_G      : positive                         := 1;
      CLKFBOUT_MULT_F_G    : real                             := 8.0;
      CLKOUT0_DIVIDE_F_G   : real                             := 8.0;
      PLL0_REFCLK_SEL_G    : bit_vector(2 downto 0)           := "001";
      PLL1_REFCLK_SEL_G    : bit_vector(2 downto 0)           := "010";
      -- PLL1 configuration
      PLL1_FBDIV_IN_G      : natural;
      PLL1_FBDIV_45_IN_G   : natural;
      PLL1_REFCLK_DIV_IN_G : natural                          := 1;
      -- AXI-Lite Configurations
      EN_AXI_REG_G         : boolean                          := false;
      -- AXI Streaming Configurations
      AXIS_CONFIG_G        : AxiStreamConfigArray(3 downto 0) := (others => AXI_STREAM_CONFIG_INIT_C));
   port (
      -- Local Configurations
      localMac            : in  Slv48Array(NUM_LANE_G-1 downto 0)              := (others => MAC_ADDR_INIT_C);
      -- Streaming DMA Interface 
      dmaClk              : in  slv(NUM_LANE_G-1 downto 0);
      dmaRst              : in  slv(NUM_LANE_G-1 downto 0);
      dmaIbMasters        : out AxiStreamMasterArray(NUM_LANE_G-1 downto 0);
      dmaIbSlaves         : in  AxiStreamSlaveArray(NUM_LANE_G-1 downto 0);
      dmaObMasters        : in  AxiStreamMasterArray(NUM_LANE_G-1 downto 0);
      dmaObSlaves         : out AxiStreamSlaveArray(NUM_LANE_G-1 downto 0);
      -- Slave AXI-Lite Interface 
      axiLiteClk          : in  slv(NUM_LANE_G-1 downto 0)                     := (others => '0');
      axiLiteRst          : in  slv(NUM_LANE_G-1 downto 0)                     := (others => '0');
      axiLiteReadMasters  : in  AxiLiteReadMasterArray(NUM_LANE_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
      axiLiteReadSlaves   : out AxiLiteReadSlaveArray(NUM_LANE_G-1 downto 0);
      axiLiteWriteMasters : in  AxiLiteWriteMasterArray(NUM_LANE_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
      axiLiteWriteSlaves  : out AxiLiteWriteSlaveArray(NUM_LANE_G-1 downto 0);
      -- Misc. Signals
      extRst              : in  sl;
      phyClk              : out sl;
      phyRst              : out sl;
      phyReady            : out slv(NUM_LANE_G-1 downto 0);
      sigDet              : in  slv(NUM_LANE_G-1 downto 0)                     := (others => '1');
      mmcmLocked          : out sl;
      -- MGT Clock Port (156.25 MHz or 312.5 MHz)
      gtRefClk            : in  slv(1 downto 0)                                := "00";
      gtRefClkBufg        : in  slv(1 downto 0)                                := "00";
      gtClkP              : in  slv(1 downto 0)                                := "11";
      gtClkN              : in  slv(1 downto 0)                                := "00";
      -- QPLL
      qpllOutClk          : out slv(1 downto 0);
      qpllOutRefClk       : out slv(1 downto 0);
      qpllLock            : out slv(1 downto 0);
      qpllRefClkLost      : out slv(1 downto 0);
      qpllResetOut        : out slv(1 downto 0);
      qpllPDOut           : out slv(1 downto 0);
      qpllReset           : in  slv(1 downto 0) := "10";
      -- Switch Polarity of TxN/TxP, RxN/RxP
      gtTxPolarity        : in  slv(NUM_LANE_G-1 downto 0)                     := (others => '0');
      gtRxPolarity        : in  slv(NUM_LANE_G-1 downto 0)                     := (others => '0');
      -- MGT Ports
      gtTxP               : out slv(NUM_LANE_G-1 downto 0);
      gtTxN               : out slv(NUM_LANE_G-1 downto 0);
      gtRxP               : in  slv(NUM_LANE_G-1 downto 0);
      gtRxN               : in  slv(NUM_LANE_G-1 downto 0));
end GigEthGtp7WrapperAdv;

architecture mapping of GigEthGtp7WrapperAdv is

   constant PLL0_REFCLK_IDX_C : natural := ite( PLL0_REFCLK_SEL_G = "001", 0, 1 );
   constant PLL1_REFCLK_IDX_C : natural := ite( PLL1_REFCLK_SEL_G = "001", 0, 1 );

   signal refClk           : slv(1 downto 0);
   signal refClkFixed      : slv(1 downto 0);
   signal refClkBufg       : slv(1 downto 0);
   signal refRst           : slv(1 downto 0);
   signal sysClk125        : sl;
   signal sysRst125        : sl;
   signal sysClk62         : sl;
   signal sysRst62         : sl;

   signal qPllOutClkLoc    : slv(1 downto 0);
   signal qPllOutRefClkLoc : slv(1 downto 0);
   signal qPllLockLoc      : slv(1 downto 0);
   signal qPllRefClkLostLoc: slv(1 downto 0);
   signal qpllRst          : slv(NUM_LANE_G-1 downto 0);
   signal qpllResetLoc     : slv(1 downto 0);

   signal qpllPD           : slv(1 downto 0) := "11";
   signal qpllPwrUpRst     : slv(1 downto 0) := "00";

begin

   assert ( (PLL0_REFCLK_SEL_G = "001") or (PLL0_REFCLK_SEL_G = "010") ) severity failure;
   assert ( (PLL1_REFCLK_SEL_G = "001") or (PLL1_REFCLK_SEL_G = "010") ) severity failure;

   phyClk <= sysClk125;
   phyRst <= sysRst125;

   qpllOutClk     <= qpllOutClkLoc;
   qpllOutRefClk  <= qpllOutRefClkLoc;
   qpllLock       <= qpllLockLoc;
   qpllRefClkLost <= qpllRefClkLostLoc;

   -----------------------------
   -- Select the Reference Clock
   -----------------------------
   GEN_IBUFDS : for i in 0 to 1 generate

   signal gtClk     : sl;
   signal gtClkBufg : sl;

   signal pd : unsigned(7 downto 0) := (others => '1');

   begin

   P_PWR_UP : process( refClkBufg(i) ) is
   begin
      if ( rising_edge( refClkBufg(i) ) ) then
         if ( pd /= to_unsigned( 0, pd'length ) ) then
            pd <= pd - 1;
         end if;
         if    ( pd = to_unsigned( 16, pd'length ) ) then
            qpllPD(i)       <= '0';
         elsif ( pd = to_unsigned(  4, pd'length ) ) then
            qpllPwrUpRst(i) <= '1';
         elsif ( pd = to_unsigned(  0, pd'length ) ) then
            qpllPwrUpRst(i) <= '0';
         end if;
      end if;
   end process P_PWR_UP;

   GEN_IBUFDS : if ( not USE_GTREFCLK_G ) generate

   IBUFDS_GTE2_Inst : IBUFDS_GTE2
      port map (
         I     => gtClkP(i),
         IB    => gtClkN(i),
         CEB   => '0',
         ODIV2 => open,
         O     => gtClk);

   BUFG_Inst : BUFG
      port map (
         I => gtClk,
         O => gtClkBufg);

   end generate;

   refClkBufg(i) <= gtClkBufg when(USE_GTREFCLK_G = false) else gtRefClkBufg(i);
   refClk    (i) <= gtClk     when(USE_GTREFCLK_G = false) else gtRefClk    (i);

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => extRst,
         clk    => refClkBufg(i),
         rstOut => refRst(i));

   end generate;

   -- We could use the TXOUTCLK here but it's not routed out of the GigEthGtp7...
   -- NOTE: MMCM must use the same refclk as the PLL0 since we always use PLL0
   --       to drive the Ethernet GTP...

   ----------------
   -- Clock Manager
   ----------------
   U_MMCM : entity work.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => false,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 2,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => CLKIN_PERIOD_G,
         DIVCLK_DIVIDE_G    => DIVCLK_DIVIDE_G,
         CLKFBOUT_MULT_F_G  => CLKFBOUT_MULT_F_G,
         CLKOUT0_DIVIDE_F_G => CLKOUT0_DIVIDE_F_G,
         CLKOUT1_DIVIDE_G   => integer(2.0*CLKOUT0_DIVIDE_F_G))
      port map(
         clkIn     => refClkBufg(PLL0_REFCLK_IDX_C),
         rstIn     => refRst    (PLL0_REFCLK_IDX_C),
         locked    => mmcmLocked,
         clkOut(0) => sysClk125,
         clkOut(1) => sysClk62,
         rstOut(0) => sysRst125,
         rstOut(1) => sysRst62);

   -- Gtp7QuadPll muxes the reference clocks around in weird ways (second
   -- two rows of table):
   --     PLL0_REFCLK_SEL_G PLL1_REFCLK_SEL_G
   --     "001"             "001"               gtRefClk(0) routed to both PLLs
   --     "001"             "010"               gtRefClk(0) to PLL0, (1) to PLL1
   --     "010"             "001"           !!  gtRefCLk(0) to PLL0, (1) to PLL1  !!
   --     "010"             "010"           !!  gtRefCLk(0) both PLLs             !!
   --

   -- Restore the original routing

   P_FIX_REFCLK : process ( refClk ) is
   begin
      case ( PLL0_REFCLK_SEL_G & PLL1_REFCLK_SEL_G ) is
         when "010010" | "010001" =>
            refClkFixed(0) <= refClk(1);
            refClkFixed(1) <= refClk(0);
         when others =>
            refClkFixed    <= refClk;
      end case;
  end process P_FIX_REFCLK;

   -----------
   -- Quad PLL 
   -----------
   U_Gtp7QuadPll : entity work.Gtp7QuadPll
      generic map (
         TPD_G                => TPD_G,
         PLL0_REFCLK_SEL_G    => PLL0_REFCLK_SEL_G,
         PLL0_FBDIV_IN_G      => 4,
         PLL0_FBDIV_45_IN_G   => 5,
         PLL0_REFCLK_DIV_IN_G => 1,

         PLL1_REFCLK_SEL_G    => PLL1_REFCLK_SEL_G,
         PLL1_FBDIV_IN_G      => PLL1_FBDIV_IN_G,
         PLL1_FBDIV_45_IN_G   => PLL1_FBDIV_45_IN_G,
         PLL1_REFCLK_DIV_IN_G => PLL1_REFCLK_DIV_IN_G,

         EN_DRP_G             => false
      )
      port map (
         qPllRefClk        => refClkFixed,
         qPllOutClk        => qPllOutClkLoc,
         qPllOutRefClk     => qPllOutRefClkLoc,
         qPllLock          => qPllLockLoc,
         qPllLockDetClk(0) => sysClk125,
         qPllLockDetClk(1) => sysClk125,
         qPllRefClkLost    => qPllRefClkLostLoc,
         qPllPowerDown(0)  => qpllPD(PLL0_REFCLK_IDX_C),
         qPllPowerDown(1)  => qpllPD(PLL1_REFCLK_IDX_C),
         qPllReset         => qpllResetLoc);

   -- Once the QPLL is locked, prevent the 
   -- IP cores from accidentally reseting each other
   qpllResetLoc(0) <= sysRst125 or (uOr(qpllRst) and not(qPllLockLoc(0))) or qpllReset(0) or qpllPwrUpRst(PLL0_REFCLK_IDX_C);
   qpllResetLoc(1) <= qpllReset(1) or qpllPwrUpRst(PLL1_REFCLK_IDX_C);

   qpllResetOut    <= qpllResetLoc;
   qpllPDOut       <= qpllPD;

   --------------
   -- GigE Module 
   --------------
   GEN_LANE :
   for i in 0 to NUM_LANE_G-1 generate
      signal qpll1Rst : sl;
   begin

      U_GigEthGtp7 : entity work.GigEthGtp7
         generic map (
            TPD_G           => TPD_G,
            PAUSE_EN_G      => PAUSE_EN_G,
            PAUSE_512BITS_G => PAUSE_512BITS_G,
            -- AXI-Lite Configurations
            EN_AXI_REG_G    => EN_AXI_REG_G,
            -- AXI Streaming Configurations
            AXIS_CONFIG_G   => AXIS_CONFIG_G(i))
         port map (
            -- Local Configurations
            localMac           => localMac(i),
            -- Streaming DMA Interface 
            dmaClk             => dmaClk(i),
            dmaRst             => dmaRst(i),
            dmaIbMaster        => dmaIbMasters(i),
            dmaIbSlave         => dmaIbSlaves(i),
            dmaObMaster        => dmaObMasters(i),
            dmaObSlave         => dmaObSlaves(i),
            -- Slave AXI-Lite Interface 
            axiLiteClk         => axiLiteClk(i),
            axiLiteRst         => axiLiteRst(i),
            axiLiteReadMaster  => axiLiteReadMasters(i),
            axiLiteReadSlave   => axiLiteReadSlaves(i),
            axiLiteWriteMaster => axiLiteWriteMasters(i),
            axiLiteWriteSlave  => axiLiteWriteSlaves(i),
            -- PHY + MAC signals
            sysClk62           => sysClk62,
            sysClk125          => sysClk125,
            sysRst125          => sysRst125,
            extRst             => refRst(PLL0_REFCLK_IDX_C),
            phyReady           => phyReady(i),
            sigDet             => sigDet(i),
            -- Quad PLL Interface
            qPllOutClk         => qPllOutClkLoc,
            qPllOutRefClk      => qPllOutRefClkLoc,
            qPllLock           => qPllLockLoc,
            qPllRefClkLost     => qPllRefClkLostLoc,
            qPllReset(0)       => qpllRst(i),
            qPllReset(1)       => qpll1Rst,
            -- Switch Polarity of TxN/TxP, RxN/RxP
            gtTxPolarity       => gtTxPolarity(i),
            gtRxPolarity       => gtRxPolarity(i),
            -- MGT Ports
            gtTxP              => gtTxP(i),
            gtTxN              => gtTxN(i),
            gtRxP              => gtRxP(i),
            gtRxN              => gtRxN(i));

   end generate GEN_LANE;

end mapping;
