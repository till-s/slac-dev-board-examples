puts "USER SOURCES script"
set_property top EcEvrProto [current_fileset]

set_property generic {"FOO=BOO"} -objects [current_fileset]
