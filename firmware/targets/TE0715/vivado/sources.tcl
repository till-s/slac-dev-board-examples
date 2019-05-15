# Override default of 'top' property (top-level entity)
set_property top TE0715 [current_fileset]

set genericArgList [get_property generic [current_fileset]]

if { [info exists ::env(IBERT_IMAGE)] == 1 } {
	lappend genericArgList "IBERT_G=$::env(IBERT_IMAGE)"
}

set_property generic ${genericArgList} -objects [current_fileset]
