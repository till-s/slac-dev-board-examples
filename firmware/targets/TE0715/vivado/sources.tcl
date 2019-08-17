# Override default of 'top' property (top-level entity)
set_property top TE0715 [current_fileset]

set genericArgList [get_property generic [current_fileset]]

lappend genericArgList "IMAGE_TYPE_G=$::env(IMAGE_TYPE)"

set_property generic ${genericArgList} -objects [current_fileset]
