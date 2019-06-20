# Override default of 'top' property (top-level entity)
set_property top TE0715 [current_fileset]

set genericArgList [get_property generic [current_fileset]]

lappend genericArgList "PRJ_VARIANT_G=$::env(IMAGE_VARIANT)"
lappend genericArgList "PRJ_PART_G=$::env(PRJ_PART)"

set_property generic ${genericArgList} -objects [current_fileset]
