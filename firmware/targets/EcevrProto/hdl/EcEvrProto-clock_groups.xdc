set_clock_groups -async -group [get_clocks -include_generated_clocks pllClk]
set_clock_groups -async -group [get_clocks -include_generated_clocks lan9254Clk]
set_clock_groups -async -group [get_clocks -include_generated_clocks mgtRefClk]
