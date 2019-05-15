
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

set topLevel [get_property top [current_fileset]]

file copy -force $::env(IMPL_DIR)/${topLevel}.bit $::env(IMPL_DIR)/$::env(PROJECT).bit
