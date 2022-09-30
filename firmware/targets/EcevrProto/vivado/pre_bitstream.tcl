puts "USER PRE_BITSTREAM script"

if { [exec sh -c {test -z "`git status -s -uno`"; echo $?}] == 1 } {
  set git_hash {0000_0000}
  puts "GIT NOT CLEAN - not providing a hash"
} else {
  set git_hash "[exec git rev-parse --short=8 HEAD]"
}
puts ${git_hash}

set_property BITSTREAM.CONFIG.USERID "0x${git_hash}" [current_design]
