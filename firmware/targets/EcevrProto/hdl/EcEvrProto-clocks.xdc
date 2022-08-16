create_clock -period 40.000 -name pllClk     [get_ports {pllClkPin}]
create_clock -period 40.000 -name lan9254Clk [get_ports {lan9254ClkPin}]
create_clock -period  5.400 -name mgtRefClk  [get_ports {mgtRefClkPPins[1]}]

set_clock_groups -async -group [get_clocks -include_generated_clocks pllClk]
set_clock_groups -async -group [get_clocks -include_generated_clocks lan9254Clk]
set_clock_groups -async -group [get_clocks -include_generated_clocks mgtRefClk]
