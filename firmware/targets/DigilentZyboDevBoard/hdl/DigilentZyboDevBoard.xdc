##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
# I/O Port Mapping
#

##Switches
#IO_L19N_T3_VREF_35
set_property PACKAGE_PIN G15 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

#IO_L24P_T3_34
set_property PACKAGE_PIN P15 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

#IO_L4N_T0_34
set_property PACKAGE_PIN W13 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]

#IO_L9P_T1_DQS_34
set_property PACKAGE_PIN T16 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

##Buttons
#IO_L20N_T3_34
set_property PACKAGE_PIN R18 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

#IO_L24N_T3_34
set_property PACKAGE_PIN P16 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]

#IO_L18P_T2_34
set_property PACKAGE_PIN V16 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]

#IO_L7P_T1_34
set_property PACKAGE_PIN Y16 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]

##LEDs
#IO_L23P_T3_35
set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

#IO_L23N_T3_35
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

#IO_0_35
set_property PACKAGE_PIN G14 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

#IO_L3N_T0_DQS_AD1N_35
set_property PACKAGE_PIN D18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

## Audio Codec/external EEPROM IIC bus
#IO_L13P_T2_MRCC_34
set_property PACKAGE_PIN N18 [get_ports iic_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_scl_io]

#IO_L23P_T3_34
set_property PACKAGE_PIN N17 [get_ports iic_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_sda_io]

# I2C tri-state
set_property PULLUP true [get_ports iic_scl_io]
set_property PULLUP true [get_ports iic_sda_io]


set_property OFFCHIP_TERM NONE [get_ports iic_scl_io]
set_property OFFCHIP_TERM NONE [get_ports iic_sda_io]

#PMOD E (std)
set_property PACKAGE_PIN V12      [get_ports {pmodE[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[0]}]

set_property PACKAGE_PIN W16      [get_ports {pmodE[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[1]}]

set_property PACKAGE_PIN J15      [get_ports {pmodE[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[2]}]

set_property PACKAGE_PIN H15      [get_ports {pmodE[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[3]}]
set_property PULLUP      true     [get_ports {pmodE[3]}]

set_property PACKAGE_PIN V13      [get_ports {pmodE[4]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[4]}]

set_property PACKAGE_PIN U17      [get_ports {pmodE[5]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[5]}]

set_property PACKAGE_PIN T17      [get_ports {pmodE[6]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[6]}]

set_property PACKAGE_PIN Y17      [get_ports {pmodE[7]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {pmodE[7]}]
set_property PULLUP      true     [get_ports {pmodE[7]}]


# XADC (PMODA-4)
#set_property PACKAGE_PIN K14 [get_ports {vPIn}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vPIn}]

#set_property PACKAGE_PIN J14 [get_ports {vNIn}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vNIn}]
