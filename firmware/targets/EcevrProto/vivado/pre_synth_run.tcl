puts "USER PRE_SYNTH_RUN script"

source [get_files */appCheckAndTouchGitHashFile.tcl]

appCheckAndTouchGitHashFile [get_files */AppGitHashPkg.vhd]

set genericArgList [get_property generic -objects [current_fileset]]
lappend genericArgList "GIT_HASH_G=32'h${git_hash}"

set_property generic ${genericArgList} -objects [current_fileset]
