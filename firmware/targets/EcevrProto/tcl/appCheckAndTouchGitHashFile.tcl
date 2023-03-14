proc getGitHash {} {
  if { [exec sh -c {git update-index && git diff-index --quiet HEAD; echo $?}] != 0 } {
    set git_hash {00000000}
    puts "GIT NOT CLEAN - not providing a hash"
  } else {
    set git_hash "[exec git rev-parse --short=8 HEAD]"
  }
  return "${git_hash}"
}

proc appCheckAndTouchGitHashFile { fn } {

  set git_hash [getGitHash]

  if { ! [file exists "${fn}"] || ( [exec sh -c "grep -q '${git_hash}' '${fn}'; echo \$?"] != 0 ) } {
    set fp [open "${fn}" w+]
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

  return "${git_hash}"
}
