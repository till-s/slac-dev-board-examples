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

# doesn't seem to work :-(
#set_property IO_BUFFER_TYPE none [getPorts {uartTx}]
#set_property IO_BUFFER_TYPE none [getPorts {uartRx}]
#set_property IO_BUFFER_TYPE none [getPorts {sysClkIn}]
#set_property IO_BUFFER_TYPE none [getPorts {sysARstIn}]

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

## SFP MGT (Quad 111)
set_property PACKAGE_PIN W4      [get_ports {timingTxP}]
set_property PACKAGE_PIN W3      [get_ports {timingTxN}]
set_property PACKAGE_PIN Y6      [get_ports {timingRxP}]
set_property PACKAGE_PIN Y5      [get_ports {timingRxN}]
## MGTREFCLK1 (Quad 110) -- Si5324
set_property PACKAGE_PIN AC8     [get_ports {timingRefClkP}]
set_property PACKAGE_PIN AC7     [get_ports {timingRefClkN}]
## FMC_LPC_GBTCLK0_M2C_C_P/N
set_property PACKAGE_PIN U8      [get_ports {diffInpP[0]}]
set_property PACKAGE_PIN U7      [get_ports {diffInpN[0]}]
#
# FMC_LPC_DP0_C2M_P/N
#set_property PACKAGE_PIN AB2     [get_ports {timingTxP}]
#set_property PACKAGE_PIN AB1     [get_ports {timingTxN}]
## FMC_LPC_DP0_M2C_P/N
#set_property PACKAGE_PIN AC4     [get_ports {timingRxP}]
#set_property PACKAGE_PIN AC3     [get_ports {timingRxN}]

set_property PACKAGE_PIN AA18    [get_ports {enableSFP}]
set_property IOSTANDARD LVCMOS25 [get_ports {enableSFP}]

# MGTREFCLK1 (Quad 110) -- Si5324
#set_property PACKAGE_PIN AC8     [get_ports {diffInpP[0]}]
#set_property PACKAGE_PIN AC7     [get_ports {diffInpN[0]}]
#FMC_LPC_GBTCLK0_M2C_C_P/N
#set_property PACKAGE_PIN U8      [get_ports {timingRefClkP}]
#set_property PACKAGE_PIN U7      [get_ports {timingRefClkN}]


create_clock -name timingRefClk -period 5.3846 [get_ports {timingRefClkP}]
create_clock -name si5344Clk    -period 5.3846 [get_ports {diffInpP[0]}]
create_clock -name timingTxClk  -period 5.385  [get_pins -hier -regexp {.*/GEN_TIMING.U_TimingGtx/.*/TXOUTCLK$}]
create_clock -name timingRxClk  -period 5.385  [get_pins -hier -regexp {.*/GEN_TIMING.U_TimingGtx/.*/RXOUTCLK$}]


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

#PMOD
#         Pin   Pin Name                 Memory Byte Group  Bank  VCCAUX Group  Super Logic Region  I/O Type  No-Connect
# PMOD1_0 AJ21  IO_L3P_T0_DQS_11         0                  11    NA            NA                  HR        NA
# PMOD1_1 AK21  IO_L3N_T0_DQS_11         0                  11    NA            NA                  HR        NA
# PMOD1_2 AB21  IO_L19P_T3_11            3                  11    NA            NA                  HR        NA
# PMOD1_3 AB16  IO_L24N_T3_10            3                  10    NA            NA                  HR        NA
# PMOD1_4 Y20   IO_L6P_T0_9              0                  9     NA            NA                  HR        NA
# PMOD1_5 AA20  IO_L6N_T0_VREF_9         0                  9     NA            NA                  HR        NA
# PMOD1_6 AC18  IO_L11P_T1_SRCC_9        1                  9     NA            NA                  HR        NA
# PMOD1_7 AC19  IO_L11N_T1_SRCC_9        1                  9     NA            NA                  HR        NA

#FMC_LPC_LA04_P/N
set_property PACKAGE_PIN AJ15 [get_ports {diffOutP[0]}]
set_property IOSTANDARD LVDS_25  [get_ports {diffOutP[0]}]
set_property PACKAGE_PIN AK15 [get_ports {diffOutN[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {diffOutN[0]}]

#FMC_LPC_LA07_P/N
set_property PACKAGE_PIN AA15 [get_ports {diffOutP[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {diffOutP[1]}]
set_property PACKAGE_PIN AA14 [get_ports {diffOutN[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {diffOutN[1]}]

#PMOD
#set_property PACKAGE_PIN AB21    [get_ports {trigSE[0]}]
#SMA
set_property PACKAGE_PIN AD18    [get_ports {trigSE[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {trigSE[0]}]
set_property IOB TRUE            [get_ports {trigSE[0]}]

set_property PACKAGE_PIN AD19    [get_ports {trigSE[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {trigSE[1]}]
set_property IOB TRUE            [get_ports {trigSE[1]}]


# FMC_LPC_LA24_P/N
set_property PACKAGE_PIN AF30 [get_ports {timingRecClkP}]
set_property IOSTANDARD LVDS_25 [get_ports {timingRecClkP}]
set_property PACKAGE_PIN AG30 [get_ports {timingRecClkN}]
set_property IOSTANDARD LVDS_25 [get_ports {timingRecClkN}]

# BOGUS FMC_LPC_LA26, FMC_LPC_LA27
set_property PACKAGE_PIN AJ30 [get_ports {uartTx}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartTx}]
set_property PACKAGE_PIN AK30 [get_ports {uartRx}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartRx}]
set_property PACKAGE_PIN AJ28 [get_ports {sysClkIn}]
set_property IOSTANDARD LVCMOS25 [get_ports {sysClkIn}]
set_property PACKAGE_PIN AJ29 [get_ports {sysARstIn}]
set_property IOSTANDARD LVCMOS25 [get_ports {sysARstIn}]
