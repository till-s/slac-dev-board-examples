create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name Ila_256
set_property -dict [list \
        CONFIG.C_DATA_DEPTH     {1024} \
        CONFIG.C_TRIGIN_EN      {TRUE} \
        CONFIG.C_TRIGOUT_EN     {TRUE} \
        CONFIG.C_INPUT_PIPE_STAGES {2} \
        CONFIG.C_EN_STRG_QUAL      {1} \
        CONFIG.C_NUM_OF_PROBES     {4} \
        CONFIG.C_PROBE0_WIDTH     {64} \
        CONFIG.C_PROBE1_WIDTH     {64} \
        CONFIG.C_PROBE2_WIDTH     {64} \
        CONFIG.C_PROBE3_WIDTH     {64}
] [get_ips Ila_256]


