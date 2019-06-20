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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.TimingPkg.all;

entity TimingGtCoreWrapperAdv is
   generic (
      TPD_G            : time    := 1 ns;
      WITH_COMMON_G    : boolean := true;
      AXIL_CLK_FREQ_G  : real    := 156.25E6;
      AXIL_BASE_ADDR_G : slv(31 downto 0)
   );
   port (
      -- AXI-Lite Port
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;

      stableClk        : in  sl;

      -- GTP FPGA IO
      gtRxP            : in  sl;
      gtRxN            : in  sl;
      gtTxP            : out sl;
      gtTxN            : out sl;

      -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
      gtRxPllSel       : in slv(1 downto 0) := "00";
      gtTxPllSel       : in slv(1 downto 0) := "00";

      -- signals for external common block (WITH_COMMON_G = false)
      pllOutClk        : in  slv(1 downto 0) := "00";
      pllOutRefClk     : in  slv(1 downto 0) := "00";

      pllLocked        : in  sl := '0';
      pllRefClkLost    : in  sl := '0';

      pllRst           : out sl;

      -- ref clock for internal common block (WITH_COMMON_G = true)
      gtRefClk         : in  sl := '0';
      gtRefClkDiv2     : in  sl := '0';-- Unused in GTHE3, but used in GTHE4

      -- Rx ports
      rxControl        : in  TimingPhyControlType;
      rxStatus         : out TimingPhyStatusType;
      rxUsrClkActive   : in  sl := '1';
      rxCdrStable      : out sl;
      rxUsrClk         : in  sl;
      rxData           : out slv(15 downto 0);
      rxDataK          : out slv(1 downto 0);
      rxDispErr        : out slv(1 downto 0);
      rxDecErr         : out slv(1 downto 0);
      rxOutClk         : out sl;

      -- Tx Ports
      txControl        : in  TimingPhyControlType;
      txStatus         : out TimingPhyStatusType;
      txUsrClk         : in  sl;
      txUsrClkActive   : in  sl := '1';
      txData           : in  slv(15 downto 0);
      txDataK          : in  slv(1 downto 0);
      txOutClk         : out sl;

      -- Loopback
      loopback         : in slv(2 downto 0));
end entity TimingGtCoreWrapperAdv;

architecture rtl of TimingGtCoreWrapperAdv is

begin

   U_TimingGt : entity work.TimingGtCoreWrapper
      generic map (
         TPD_G              => TPD_G,
         WITH_COMMON_G      => WITH_COMMON_G,
         AXIL_CLK_FREQ_G    => AXIL_CLK_FREQ_G,
         AXIL_BASE_ADDR_G   => AXIL_BASE_ADDR_G
      )
      port map (
         axilClk            => axilClk,
         axilRst            => axilRst,

         axilReadMaster     => axilReadMaster,
         axilReadSlave      => axilReadSlave,
         axilWriteMaster    => axilWriteMaster,
         axilWriteSlave     => axilWriteSlave,

         stableClk          => stableClk,

         gtRefClk           => gtRefClk,
         gtRefClkDiv2       => gtRefClkDiv2,

         -- Clock PLL selection: bit 1: rx/txoutclk, bit 0: rx/tx data path
         gtRxPllSel         => gtRxPllSel,
         gtTxPllSel         => gtTxPllSel,

         -- signals for external common block (WITH_COMMON_G = false)
         pllOutClk          => pllOutClk,
         pllOutRefClk       => pllOutRefClk,

         pllLocked          => pllLocked,
         pllRefClkLost      => pllRefClkLost,

         pllRst             => pllRst,


         gtRxP              => gtRxP,
         gtRxN              => gtRxN,

         gtTxP              => gtTxP,
         gtTxN              => gtTxN,

         rxControl          => rxControl,
         rxStatus           => rxStatus,
         rxUsrClk           => rxUsrClk,
         rxData             => rxData,
         rxDataK            => rxDataK,
         rxDispErr          => rxDispErr,
         rxDecErr           => rxDecErr,
         rxOutClk           => rxOutClk,

         txControl          => txControl,
         txStatus           => txStatus,
         txUsrClk           => txUsrClk,
         txUsrClkActive     => txUsrClkActive,
         txData             => txData,
         txDataK            => txDataK,
         txOutClk           => txOutClk,
         loopback           => loopback
      );
end architecture rtl;
