puts "USER PRE_BITSTREAM script"

# apparently utils_1 fileset is not set up from where we are called
#source [get_files -of_objects [get_filesets utils_1] {*/appCheckAndTouchGitHashFile.tcl}]

set origin_dir [file dirname [info script]]
source "${origin_dir}/../tcl/appCheckAndTouchGitHashFile.tcl"


set git_hash [getGitHash]
puts ${git_hash}

set_property BITSTREAM.CONFIG.USERID "0x${git_hash}" [current_design]
