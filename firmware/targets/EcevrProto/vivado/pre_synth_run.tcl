puts "USER PRE_SYNTH_RUN script"

proc get_files { pat } {
  return "/afs/psi.ch/group/8211/till/vhdl/EcevrProto-openevr/firmware/targets/EcevrProto/vivado/pre_synth_run.tcl|"
}

if { [exec sh -c {git update-index && git diff-index --quiet HEAD; echo $?}] != 0 } {
  set git_hash {00000000}
  puts "GIT NOT CLEAN - not providing a hash"
} else {
  set git_hash "[exec git rev-parse --short=8 HEAD]"
}

set git_hash_fnam "[file normalize [file dirname [get_files */tcl/pre_synth_run.tcl]]/../hdl/GitHash.vhd]"
if { ! [file exists "${git_hash_fnam}"] || ( [exec sh -c "grep -q '${git_hash}' '${git_hash_fnam}'; echo \$?"] != 0 ) } {
  set fp [open "${git_hash_fnam}" w+]
  puts $fp "-- AUTOMATICALLY GENERATED; DO NOT EDIT"
  puts $fp "library ieee;"
  puts $fp "use     ieee.std_logic_1164.all;"
  puts $fp "package AppGitHashPkg is"
  puts $fp "   constant APP_GIT_HASH_C : std_logic_vector(31 downto 0) :="
  # put on its own line for easy extraction...
  puts $fp "       x\"${git_hash}\""
  puts $fp "   ;"
  puts $fp "end package AppGitHashPkg;"
  close $fp
}
puts ${git_hash}

#set genericArgList [get_property generic -objects [current_fileset]]
#lappend genericArgList "GIT_HASH_G=32'h${git_hash}"

#set_property generic ${genericArgList} -objects [current_fileset]
