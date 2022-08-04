-- Mapping of FPGA pins to top-level ports

library ieee;
use     ieee.std_logic_1164.all;

use     work.EcEvrProtoPkg.all;

architecture Impl of EcEvrProto is
  attribute IO_BUFFER_TYPE : string;
  attribute PULLDOWN       : string;
  attribute PULLUP         : string;

  alias     lan9254Pins_0  : std_logic is IO_L8N_T1_AD10N_15;

  attribute PULLDOWN       of lan9254Pins_0             : signal is "TRUE";
  attribute PULLUP         of IO_L22N_T3_A04_D20_14     : signal is "TRUE";
  attribute PULLUP         of IO_L21N_T3_DQS_A06_D22_14 : signal is "TRUE";


  attribute IO_BUFFER_TYPE of MGTPRXP0_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXN0_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXP0_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXN0_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXP1_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXN1_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXP1_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXN1_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXP2_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXN2_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXP2_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXN2_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXP3_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPRXN3_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXP3_216 : signal is "NONE";
  attribute IO_BUFFER_TYPE of MGTPTXN3_216 : signal is "NONE";

   -- pull-down the wait/ack into 'wait' state in case the EEPROM is not yet set up
   -- correctly for using the push-pull driver with WAIT_ACK enabled (see Lan9254Hbi.vhd;
   -- the datasheet incorrectly describes the lsbits in reg. 150).
--   attribute PULLDOWN  of IO_L8N_T1_AD10N_15       : signal is "TRUE";

  -- jumper7/jumper8 need pull-ups
--  attribute PULLUP     of IO_L22N_T3_A04_D20_14    : signal is "TRUE";
--  attribute PULLUP     of IO_L21N_T3_DQS_A06_D22_14: signal is "TRUE";
 
begin
  U_Buf : entity work.EcEvrProtoBuf
    port map (
      -- external clocks
      -- aux-clock from reference clock generator
      pllClkPin                => IO_L11P_T1_SRCC_15,
      -- from LAN9254 (used to clock fpga logic)
      lan9254ClkPin            => IO_L12P_T1_MRCC_15,

      -- LAN9254 chip interface
      lan9254Pins( 0)          => IO_L8N_T1_AD10N_15,
      lan9254Pins( 1)          => IO_L9N_T1_DQS_AD3N_15,
      lan9254Pins( 2)          => IO_L10N_T1_AD11N_15,
      lan9254Pins( 3)          => IO_L13N_T2_MRCC_15,
      lan9254Pins( 4)          => IO_L15P_T2_DQS_15,
      lan9254Pins( 5)          => IO_L15N_T2_DQS_ADV_B_15,
      lan9254Pins( 6)          => IO_L16P_T2_A28_15,
      lan9254Pins( 7)          => IO_L16N_T2_A27_15,
      lan9254Pins( 8)          => IO_L18P_T2_A24_15,
      lan9254Pins( 9)          => IO_L18N_T2_A23_15,
      lan9254Pins(10)          => IO_L14N_T2_SRCC_15,
      lan9254Pins(11)          => IO_L13P_T2_MRCC_15,
      lan9254Pins(12)          => IO_L17N_T2_A25_15,
      lan9254Pins(13)          => IO_L17P_T2_A26_15,
      lan9254Pins(14)          => IO_L24N_T3_RS0_15,
      lan9254Pins(15)          => IO_L14P_T2_SRCC_15,
      lan9254Pins(16)          => IO_L19N_T3_A21_VREF_15,
      lan9254Pins(17)          => IO_L24P_T3_RS1_15,
      lan9254Pins(18)          => IO_L19P_T3_A22_15,
      lan9254Pins(19)          => IO_L23N_T3_FWE_B_15,
      lan9254Pins(20)          => IO_L20N_T3_A19_15,
      lan9254Pins(21)          => IO_L2N_T0_D03_14,
      lan9254Pins(22)          => IO_L23P_T3_FOE_B_15,
      lan9254Pins(23)          => IO_L3N_T0_DQS_EMCCLK_14,
      lan9254Pins(24)          => IO_L8P_T1_D11_14,
      lan9254Pins(25)          => IO_L4P_T0_D04_14,
      lan9254Pins(26)          => IO_L4N_T0_D05_14,
      lan9254Pins(27)          => IO_L7N_T1_D10_14,
      lan9254Pins(28)          => IO_L7P_T1_D09_14,
      lan9254Pins(29)          => IO_L10P_T1_D14_14,
      lan9254Pins(30)          => IO_L6N_T0_D08_VREF_14,
      lan9254Pins(31)          => IO_L9P_T1_DQS_14,
      lan9254Pins(32)          => IO_L8N_T1_D12_14,
      lan9254Pins(33)          => IO_L10N_T1_D15_14,
      lan9254Pins(34)          => IO_L11P_T1_SRCC_14,
      lan9254Pins(35)          => IO_L9N_T1_DQS_D13_14,
      lan9254Pins(36)          => IO_L15P_T2_DQS_RDWR_B_14,
      lan9254Pins(37)          => IO_L12N_T1_MRCC_14,
      lan9254Pins(38)          => IO_L11N_T1_SRCC_14,
      lan9254Pins(39)          => IO_L14P_T2_SRCC_14,
      lan9254Pins(40)          => IO_L15N_T2_DQS_DOUT_CSO_B_14,
      lan9254Pins(41)          => IO_L14N_T2_SRCC_14,
      lan9254Pins(42)          => IO_L16P_T2_CSI_B_14,
      lan9254Pins(43)          => IO_L16N_T2_A15_D31_14,
      -- FT240X FIFO interface
--      fifoPins                 => 

      gpioDatPins(0)           => IO_L18N_T2_A11_D27_14,
      gpioDatPins(1)           => IO_L18P_T2_A12_D28_14,
      gpioDatPins(2)           => IO_L17P_T2_A14_D30_14,

      gpioDirPins(0)           => IO_L13N_T2_MRCC_14,
      gpioDirPins(1)           => IO_L17N_T2_A13_D29_14,
      gpioDirPins(2)           => IO_L20N_T3_A07_D23_14,

      -- LEDs
      ledPins(0)               => IO_L3P_T0_DQS_34,
      ledPins(1)               => IO_L3N_T0_DQS_34,
      ledPins(2)               => IO_L12P_T1_MRCC_34,
      ledPins(3)               => IO_L18P_T2_34,
      ledPins(4)               => IO_L18N_T2_34, 
      ledPins(5)               => IO_25_34,
      ledPins(6)               => IO_L20N_T3_34,
      ledPins(7)               => IO_L23N_T3_34,
      ledPins(8)               => IO_L20P_T3_34,

      -- POF
      pofInpPins(0)            => IO_L5N_T0_34,
      pofInpPins(1)            => IO_L10P_T1_34,

      pofOutPins(0)            => IO_L4P_T0_34,
      pofOutPins(1)            => IO_L4N_T0_34,

      pwrCyclePin              => IO_L16P_T2_34,

      i2cSdaPins(0)            => IO_L23P_T3_A03_D19_14,
      i2cSdaPins(1)            => IO_L8P_T1_AD10P_15,

      i2cSclPins(0)            => IO_L21P_T3_DQS_14,
      i2cSclPins(1)            => IO_L4N_T0_15,

      eepWPPin                 => IO_25_14,
      eepSz32kPin              => IO_L22P_T3_A05_D21_14,

      i2cISObPin               => IO_L23N_T3_A02_D18_14,

      jumper7Pin               => IO_L22N_T3_A04_D20_14,
      jumper8Pin               => IO_L21N_T3_DQS_A06_D22_14,

      sfpLosPins(0)            => IO_L5P_T0_AD9P_15,
      sfpPresentbPins(0)       => IO_L2N_T0_AD8N_15,
      sfpTxFaultPins(0)        => IO_L5N_T0_AD9N_15,
      sfpTxEnPins(0)           => IO_L3N_T0_DQS_AD1N_15,

      mgtRxPPins(0)            => MGTPRXP0_216,
      mgtRxPPins(1)            => MGTPRXP1_216,
      mgtRxPPins(2)            => MGTPRXP2_216,
      mgtRxPPins(3)            => MGTPRXP3_216,

      mgtRxNPins(0)            => MGTPRXN0_216,
      mgtRxNPins(1)            => MGTPRXN1_216,
      mgtRxNPins(2)            => MGTPRXN2_216,
      mgtRxNPins(3)            => MGTPRXN3_216,

      mgtTxPPins(0)            => MGTPTXP0_216,
      mgtTxPPins(1)            => MGTPTXP1_216,
      mgtTxPPins(2)            => MGTPTXP2_216,
      mgtTxPPins(3)            => MGTPTXP3_216,

      mgtTxNPins(0)            => MGTPTXN0_216,
      mgtTxNPins(1)            => MGTPTXN1_216,
      mgtTxNPins(2)            => MGTPTXN2_216,
      mgtTxNPins(3)            => MGTPTXN3_216,

      mgtRefClkPPins(0)        => MGTREFCLK0P_216,
      mgtRefClkPPins(1)        => MGTREFCLK1P_216,

      mgtRefClkNPins(0)        => MGTREFCLK0N_216,
      mgtRefClkNPins(1)        => MGTREFCLK1N_216
      
    );
end architecture Impl;
