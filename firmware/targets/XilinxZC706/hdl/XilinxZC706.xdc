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
#GPIO DIP(0)
set_property PACKAGE_PIN AB17    [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sw[0]}]

#GPIO DIP(1)
set_property PACKAGE_PIN AC16    [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sw[1]}]

#GPIO DIP(2)
set_property PACKAGE_PIN AC17    [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sw[2]}]

#GPIO DIP(3)
set_property PACKAGE_PIN AJ13    [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sw[3]}]

##Buttons
#BTN left
set_property PACKAGE_PIN AK25    [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {btn[0]}]

#BTN center (note UG954, fig 1-26 is wrong; showing VADJ)
set_property PACKAGE_PIN K15     [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {btn[1]}]

#BTN right
set_property PACKAGE_PIN R27     [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {btn[2]}]

#GTN PL reset
set_property PACKAGE_PIN A8      [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {btn[3]}]

##LEDs
#LED left
set_property PACKAGE_PIN Y21     [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[0]}]

#LED center
set_property PACKAGE_PIN G2      [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]

#LED right
set_property PACKAGE_PIN W21     [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[2]}]

#LED_0
set_property PACKAGE_PIN A17     [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]

#SFP MGT (Quad 111)
set_property PACKAGE_PIN W4      [get_ports {timingTxP}]
set_property PACKAGE_PIN W3      [get_ports {timingTxN}]
set_property PACKAGE_PIN Y6      [get_ports {timingRxP}]
set_property PACKAGE_PIN Y5      [get_ports {timingRxN}]

set_property PACKAGE_PIN AA18    [get_ports {enableSFP}]
set_property IOSTANDARD LVCMOS25 [get_ports {enableSFP}]

# MGTREFCLK1 (Quad 110) -- Si5324
set_property PACKAGE_PIN AC8     [get_ports {timingRefClkP}]
set_property PACKAGE_PIN AC7     [get_ports {timingRefClkN}]

create_clock -name timingRefClk -period 5.3846 [get_ports {timingRefClkP}]

## Audio Codec/external EEPROM IIC bus
#IO_L13P_T2_MRCC_34
#set_property PACKAGE_PIN N18 [get_ports iic_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports iic_scl_io]

#IO_L23P_T3_34
#set_property PACKAGE_PIN N17 [get_ports iic_sda_io]
#set_property IOSTANDARD LVCMOS33 [get_ports iic_sda_io]

# I2C tri-state
#set_property PULLUP true [get_ports iic_scl_io]
#set_property PULLUP true [get_ports iic_sda_io]


#set_property OFFCHIP_TERM NONE [get_ports iic_scl_io]
#set_property OFFCHIP_TERM NONE [get_ports iic_sda_io]

