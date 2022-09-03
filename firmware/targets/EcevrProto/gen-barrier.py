#!/usr/bin/env python3
import io

# See: Xilinx XAPP1247
# generate a 'barrier' image which arms the configuration
# watchdog using a very small timeout. This can be stored
# *after* a bitstream. If the bitstream is corrupted then
# the FPGA will eventually encounter this image and reboot
# to a fallback configuration
wrds = [
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0xffffffff,
  0x000000bb,  # bus-width auto detect word 1 (probably not needed for SPI)
  0x11220044,  # bus-width auto-detect word 2
  0xffffffff,
  0xffffffff,
  0xaa995566,  # SYNC
  0x20000000,  # NOP
  0x20000000,  # NOP
  0x20000000,  # NOP
  0x30022001,  # write type1 to watchdog register
  0x40000020,  # config watchdog, timeout = 0x20
  0x20000000,  # NOP
  0x20000000,  # NOP
  0x30008001,  # write type1 to cmd register
  0x0000000d,  # DESYNC
  0x20000000,  # NOP
  0x20000000   # NOP
]

ba = bytearray()
for w in wrds:
  # output in 
  for i in range(4):
    ba.append( (w >> 24) & 0xff );
    w <<= 8;

with io.open("Barrier.bin","xb") as f:
  f.write( ba )
