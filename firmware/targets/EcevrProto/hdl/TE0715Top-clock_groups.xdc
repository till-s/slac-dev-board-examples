# This is still required for the PSI Evr!
set_clock_groups -async -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -async -group [get_clocks -include_generated_clocks mgtRefClk]

