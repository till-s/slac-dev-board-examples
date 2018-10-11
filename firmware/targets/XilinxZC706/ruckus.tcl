# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../

if { [llength [get_ips processing_system7_0]] == 0 } {
    create_ip -name processing_system7 -vendor xilinx.com -library ip -module_name processing_system7_0
    set_property -dict [list CONFIG.preset {ZC706}] [get_ips processing_system7_0]

    set_property -dict [list \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_NUM_F2P_INTR_INPUTS {16} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {32}\
] [get_ips processing_system7_0]
}

#if { [llength [get_ips ProcSysReset]] == 0 } {
#	create_ip -name proc_sys_reset -vendor xilinx.com -library ip -module_name ProcSysReset
#}

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/"
loadConstraints -dir "$::DIR_PATH/hdl/"

set_property PROCESSING_ORDER LATE    [get_files "$::DIR_PATH/hdl/clock_groups.xdc"]
set_property USED_IN {implementation} [get_files "$::DIR_PATH/hdl/clock_groups.xdc"]
