# mgtStatus read into status register
set_false_path -through [get_pins -of_objects [get_cells -hier -regex {([^/]*[/]){0,1}U_Top/B_LOC_REGS[.]r_reg[[]regs[]][[]1[]].*}] -filter {REF_PIN_NAME==D}]
