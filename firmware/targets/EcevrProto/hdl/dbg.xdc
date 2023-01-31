create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list U_Top/B_MGT.U_MGT/rxOutClk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[0]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[1]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[2]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[3]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[4]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[5]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[6]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[7]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[8]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[9]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[10]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[11]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[12]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[13]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[14]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_charisk[0]} {U_Top/U_MAIN/G_PSI_EVR.U_EVR/evr320_decoder_inst/i_mgt_rx_charisk[1]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets lan9254Clk]
