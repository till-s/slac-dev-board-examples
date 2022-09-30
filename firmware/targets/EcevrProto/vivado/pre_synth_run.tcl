puts "USER PRE_SYNTH_RUN script"

if { [exec sh -c {test -z "`git status -s -uno`"; echo $?}] == 1 } {
  set git_hash {00000000}
  puts "GIT NOT CLEAN - not providing a hash"
} else {
  set git_hash "[exec git rev-parse --short=8 HEAD]"
}
puts ${git_hash}

set genericArgList {}
lappend genericArgList "GIT_HASH_G=32'h${git_hash}"

set_property generic ${genericArgList} -objects [current_fileset]
