#!/usr/bin/env python3
import re
import io

fnam="xc7z015clg485pkg.txt"
fnam="xc7z030sbg485pkg.txt"

pinp=re.compile("^IO_((L?)([0-9]+)([PN]?))_.*((13)|(34)|(35))$")

banks = ('13', '34', '35')

vhd = False
xdc = True

std_dflt="LVCMOS18"

for l in io.open(fnam):
  w = l.split()
  if len(w) > 2:
    m = pinp.match(w[1])
    if not m is None:
      bank = m.group(5)
      if not bank in banks:
        continue
      pin  = w[0]
      nam  = m.group(3)
      PN   = m.group(4)
      if '13' == bank:
        std = 'LVCMOS33'
      else:
        std = 'LVCMOS18'
      if len(PN) > 0:
        PN = '_' + PN
      lbl = 'B{}_L{}{}'.format(bank, nam, PN)
      if xdc:
        print('## {}'.format(lbl))
        print('#')
        print('#set_property PACKAGE_PIN {:10s} [get_ports {{{}}}]'.format(pin, lbl))
        # if std is the default (= unset) then use 'std' else leave what was probably defined in HDL
        print('#set_property IOSTANDARD [ expr {{ [get_property IOSTANDARD [get_ports {{{}}}]] eq {{{}}} ? {{{}}} : [get_property IOSTANDARD [get_ports {{{}}}]] }} ]  [get_ports {{{}}}]'.format(lbl, std_dflt, std, lbl, lbl))
        print()
      if vhd:
        print("      {:10s} : inout std_logic := 'Z';".format(lbl))
