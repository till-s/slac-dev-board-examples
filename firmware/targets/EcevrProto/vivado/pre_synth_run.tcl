puts "USER PRE_SYNTH_RUN script"

set origin_dir [file dirname [info script]]

# apparently utils_1 fileset is not set up from where we are called
#source [get_files -of_objects [get_filesets utils_1] {*/appCheckAndTouchGitHashFile.tcl}]
source "${origin_dir}/../tcl/appCheckAndTouchGitHashFile.tcl"

set git_hash [appCheckAndTouchGitHashFile "${origin_dir}/../hdl/AppGitHashPkg.vhd"]

set genericArgList [get_property generic [current_fileset]]
lappend genericArgList "GIT_HASH_G=32'h${git_hash}"

set_property generic ${genericArgList} [current_fileset]
