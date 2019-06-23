
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

set topLevel [get_property top [current_fileset]]

if { [file exists $::env(IMPL_DIR)/${topLevel}.bit] == 1 } {
file copy -force $::env(IMPL_DIR)/${topLevel}.bit $::env(IMPL_DIR)/$::env(PROJECT).bit
}
if { [file exists $::env(IMPL_DIR)/${topLevel}.bin] == 1 } {
file copy -force $::env(IMPL_DIR)/${topLevel}.bin $::env(IMPL_DIR)/$::env(PROJECT).bin
}
