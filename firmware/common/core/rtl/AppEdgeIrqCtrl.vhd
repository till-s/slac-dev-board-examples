library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     work.StdRtlPkg.all;

entity AppEdgeIrqCtrl is
   generic (
      NUM_IRQS_G : natural := 1;
      IS_SYNC_G  : boolean := false
   );
   port (
      clk        : in  sl;
      rst        : in  sl;
      irqOut     : out sl;
      irqEnb     : in  slv(NUM_IRQS_G - 1 downto 0); -- irq masked and cleared while de-asserted
      -- lines to be watched; are synchronized into 'clk' domain
      irqIn      : in  slv(NUM_IRQS_G - 1 downto 0);
      irqPend    : out slv(NUM_IRQS_G - 1 downto 0)
   );
end entity AppEdgeIrqCtrl;

architecture Impl of AppEdgeIrqCtrl is

   type RegType is record
      pend  : slv(NUM_IRQS_G - 1 downto 0);
      irqIn : slv(NUM_IRQS_G - 1 downto 0);
      irqOut: sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      pend   => (others => '0'),
      irqIn  => (others => '0'),
      irqOut => '0'
   );

   signal   r   : RegType := REG_INIT_C;
   signal   rin : RegType;

   signal   irqIn_i : slv(NUM_IRQS_G - 1 downto 0);

begin

   GEN_SYNC : if ( IS_SYNC_G ) generate
      irqIn_i <= irqIn;
   end generate;

   GEN_ASYNC : if ( not IS_SYNC_G ) generate

   U_SYNC : entity work.SynchronizerVector
      generic map (
         WIDTH_G  => NUM_IRQS_G
      )
      port map (
         clk      => clk,
         rst      => rst,
         dataIn   => irqIn,
         dataOut  => irqIn_i
      );

   end generate;

   P_COMB : process(r, irqIn_i, irqEnb, rst) is
      variable v : RegType;
   begin

      v := r;

      v.pend := irqEnb and (r.pend or (irqIn_i xor r.irqIn) );

      if ( r.pend /= slv(to_unsigned(0, r.pend'length)) ) then
         v.irqOut := '1';
      else
         v.irqOut := '0';
      end if;

      if ( rst = '1' ) then
         v := REG_INIT_C;
      end if;

      v.irqIn := irqIn_i;

      rin <= v;

   end process P_COMB;

   P_SEQ : process( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         r <= rin;
      end if; 
   end process P_SEQ;

   irqOut  <= r.irqOut;
   irqPend <= r.pend;

end architecture Impl;
