set_property CFGBVS GND [current_design]
#where value1 is either VCCO or GND

set_property CONFIG_VOLTAGE 1.8 [current_design]
#where value2 is the voltage provided to configuration bank 0


set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
#set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 32'h00240000 [current_design]
#set_property BITSTREAM.CONFIG.NEXT_CONFIG_REBOOT ENABLE [current_design]