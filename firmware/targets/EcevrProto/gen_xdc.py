#!/usr/bin/env python3
import io
import regex as re
import sys
import getopt
import ecevr_pinmap

class GenXdc:

  PAT = re.compile("^(IO_|MGT(REFCLK|PTX|PRX)).*")

  def __init__(self, pin_file, pin_map, prefix="EcEvrProto"):
    self.pin_file_ = pin_file
    self.pin_map_  = pin_map
    self.prefix_   = prefix
    self.xio_file_ = prefix + "-io.xdc"

  def genHdr(self):
    with io.open(self.xio_file_, "w") as x:
      x.write("## Automatically generated; do not modify\n")
      x.write("## Edit 'ecevr_pinmap.py' instead and run gen_xdc.py\n")

  def genIo(self):
    with io.open(self.pin_file_, "r") as g, \
         io.open(self.xio_file_, "a") as x:
      for l in g:
        wrds = l.split()
        if 0 == len(wrds) or '#' == wrds[0][0]:
          continue
        m = self.PAT.match(wrds[1])
        if not m is None:
          try:
            pinDesc  = self.pin_map_[wrds[1]]
            portName = pinDesc["port"]
            x.write("# {:s}\n".format(wrds[1]))
            x.write("set_property {:16s} {:12s} [get_ports {:s}]\n".format("PACKAGE_PIN", wrds[0], portName))
            for p in pinDesc["props"].items():
              x.write("set_property {:16s} {:12s} [get_ports {:s}]\n".format(p[0], p[1], portName))
            x.write("\n")
          except KeyError as e:
            pass

  def genFtr(self):
    pass

if __name__ == "__main__":
  opts, args = getopt.getopt(sys.argv[1:],"h")
  for o in opts:
    if ( o[0] == "-h" ):
      print("Usage: {} [-h] filename".format(sys.argv[0]))
      print("    -h          : this message")
      sys.exit(0)
    else:
      raise RuntimeError("Unknown option {}".format(o[0]))
  if len(args) < 1:
    raise RuntimeError("Missing pin filename arg")
  gen = GenXdc( args[0], ecevr_pinmap.mkPinMap() )
  gen.genHdr() 
  gen.genIo()
  gen.genFtr() 
