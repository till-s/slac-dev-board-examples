library ieee;
use     ieee.std_logic_1164.all;

package EcEvrProtoPkg is

  type FT240FifoIOType is record
    WR:    std_logic;
    RDb:   std_logic;
    SIWU:  std_logic;
    DAT:   std_logic_vector(7 downto 0);
    CBUS5: std_logic;
    CBUS6: std_logic;
    RXE:   std_logic;
    TXF:   std_logic;
  end record FT240FifoIOType;

end package EcEvrProtoPkg;
