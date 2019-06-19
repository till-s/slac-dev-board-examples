# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

#loadIpCore -path "$::DIR_PATH/ip/DebugBridgeJtag.xci"
#loadIpCore -path "$::DIR_PATH/ip/ila_0.xci"

#if { [llength [get_ips DebugBridgeJtag]] == 0 } {
#	create_ip -name debug_bridge -vendor xilinx.com -library ip -version 1.1 -module_name DebugBridgeJtag
#	create_ip -name debug_bridge -vendor xilinx.com -library ip -module_name DebugBridgeJtag
#	set_property -dict [list CONFIG.C_DEBUG_MODE {4}] [get_ips DebugBridgeJtag]
#}

if { [llength [get_ips Ila_256]] == 0 } {
	create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name Ila_256
	set_property -dict [list CONFIG.C_PROBE0_WIDTH {64} CONFIG.C_PROBE1_WIDTH {64} CONFIG.C_PROBE2_WIDTH {64} CONFIG.C_PROBE3_WIDTH {64} CONFIG.C_NUM_OF_PROBES {4} ] [get_ips Ila_256]
	set_property -dict [list CONFIG.C_TRIGOUT_EN {true} CONFIG.C_INPUT_PIPE_STAGES {1} CONFIG.C_TRIGIN_EN {true}] [get_ips Ila_256]

}

# Load Source Code
loadSource -path "$::DIR_PATH/rtl/AppCore.vhd"
loadSource -path "$::DIR_PATH/rtl/AppEdgeIrqCtrl.vhd"
loadSource -path "$::DIR_PATH/rtl/AppReg.vhd"
loadSource -path "$::DIR_PATH/rtl/EthPortMapping.vhd"
loadSource -path "$::DIR_PATH/rtl/Ila_256Pkg.vhd"
loadSource -path "$::DIR_PATH/rtl/TimingConnectorPkg.vhd"
if { [ regexp "XC7Z(015|012).*" [string toupper "$::env(PRJ_PART)"] ] } {
  loadSource -path "$::DIR_PATH/rtl/TimingGtpCoreWrapperAdv.vhd"
} else {
  loadSource -path "$::DIR_PATH/rtl/TimingGtCoreWrapperAdv.vhd"
}

# Load Block Designs and HDL Wrapper
#loadBlockDesign -dir "$::DIR_PATH/bd/"
#loadBlockDesign -path "$::DIR_PATH/bd/system_no_ila/system.bd" 
#loadSource      -dir  "$::DIR_PATH/bd/"


