library ieee;
use     ieee.std_logic_1164.all;
use     work.StdRtlPkg.all;
use     work.TimingPkg.all;

package TimingConnectorPkg is

   type TimingWireIbType is record
      refClk         : sl;
      rxP            : sl;
      rxN            : sl;
      -- GTP signals (must use external common block)
      rxPllSel       : slv(1 downto 0);
      txPllSel       : slv(1 downto 0);
      pllClk         : slv(1 downto 0);
      pllRefClk      : slv(1 downto 0);
      pllLocked      : sl;
      refClkLost     : sl;
   end record TimingWireIbType;

   constant TIMING_WIRE_IB_INIT_C : TimingWireIbType := (
      refClk         => '0',
      rxP            => '0',
      rxN            => '1',
      rxPllSel       => "00",
      txPllSel       => "00",
      pllClk         => "00",
      pllRefClk      => "00",
      pllLocked      => '0',
      refClkLost     => '0'
   );

   type TimingWireObType is record
      recClk         : sl;
      recRst         : sl;
      txP            : sl;
      txN            : sl;
      trig           : TimingTrigType;
      txStat         : TimingPhyStatusType;
      rxStat         : TimingPhyStatusType;
      txClk          : sl;
      -- GTP signals (must use external common block)
      pllRst         : sl;
   end record TimingWireObType;

   constant TIMING_WIRE_OB_INIT_C : TimingWireObType := (
      recClk         => '0',
      recRst         => '0',
      txP            => '0',
      txN            => '1',
      trig           => TIMING_TRIG_INIT_C,
      txStat         => TIMING_PHY_STATUS_INIT_C,
      rxStat         => TIMING_PHY_STATUS_INIT_C,
      txClk          => '0',
      -- GTP signals (must use external common block)
      pllRst         => '0'
   );
end package TimingConnectorPkg;
