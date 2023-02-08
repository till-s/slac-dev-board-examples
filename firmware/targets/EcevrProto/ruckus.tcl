# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../

# Generate IP
if { [llength [get_ips Ila_256]] == 0 } {
	source $::env(PROJ_DIR)/tcl/genIla256.tcl
}

if { [llength [get_ips TimingGtp]] == 0 } {
	source $::env(PROJ_DIR)/tcl/genTimingGtp.tcl
}

# Load local source Code and constraints
foreach f {
  EcEvrProto.vhd
  EcEvrProtoPkg.vhd
  EcEvrProtoTop.vhd
  gtp/TimingGtp_common.vhd
  gtp/TimingGtp_cpll_railing.vhd
  gtp/TimingGtpPkg.vhd
  gtp/TimingGtpWrapper.vhd
} {
  loadSource    -path "$::DIR_PATH/hdl/$f"
}

loadConstraints -path "$::DIR_PATH/hdl/EcEvrProto-misc.xdc"
loadConstraints -path "$::DIR_PATH/hdl/EcEvrProto-io.xdc"
loadConstraints -path "$::DIR_PATH/hdl/EcEvrProto-clocks.xdc"
loadConstraints -path "$::DIR_PATH/hdl/EcEvrProto-clock_groups.xdc"
loadConstraints -path "$::DIR_PATH/hdl/EcEvrProto-io_timing.xdc"

# some submodule ruckus.tcl's already set the strategy
# (too late for our properties.tcl).
# Override here...
set_property STRATEGY Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

#set_property PROCESSING_ORDER LATE    [get_files "$::DIR_PATH/hdl/clock_groups.xdc"]
#set_property USED_IN {implementation} [get_files "$::DIR_PATH/hdl/clock_groups.xdc"]
