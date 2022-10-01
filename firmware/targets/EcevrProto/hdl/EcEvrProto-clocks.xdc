# System Clocks

create_clock -period 40.000 -name pllClk     [get_ports {pllClkPin}]
create_clock -period 40.000 -name lan9254Clk [get_ports {lan9254ClkPin}]
create_clock -period  8.00 -name mgtRefClk  [get_ports {mgtRefClkPPins[1]}]

# note that usrCClk we specify here is not the SCLK (which is generated
# by dividing by 2*prescale_dQuick Accessivisor). This has to be addressed with
# multicycle paths.
#
create_generated_clock -name usrCClk -source [get_pins {*/USRCCLKO}] -multiply_by 1 [get_pins {*/USRCCLKO}]

# Tusrcclko_min from datasheet:
# @1V: # Speed   -3         -2       -1
#             0.50/6.00 0.50/6.70 0.50/7.50
# @.9V #         -1L        -2L
#             0.50/7.50 0.50/7.50
# Add trace delay: 12mm, er = 4.3 -> 0.1ns
set_clock_latency -min 0.5 [get_clocks usrCClk]
set_clock_latency -max 7.6 [get_clocks usrCClk]
