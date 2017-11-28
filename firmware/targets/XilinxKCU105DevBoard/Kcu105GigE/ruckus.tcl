# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../../

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/"

if { "$::env(USE_RJ45_ETH)" == "true" } {
   loadConstraints -path "$::DIR_PATH/hdl/Kcu105GigE_SGMII.xdc"
} else {
   loadConstraints -path "$::DIR_PATH/hdl/Kcu105GigE_GTH.xdc"
}
loadConstraints -path "$::DIR_PATH/hdl/Kcu105GigE.xdc"
