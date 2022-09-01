#!/usr/bin/env python3
import io
import regex as re
import sys
import getopt
import ecevr_pinmap
import math

class GenXdc:

  PAT = re.compile("^(IO_|MGT(REFCLK|PTX|PRX)|CCLK_).*")

  def __init__(self, pin_file, pin_map, sysClkFrq, prefix="EcEvrProto"):
    self.pin_file_     = pin_file
    self.pin_map_      = pin_map
    self.prefix_       = prefix
    self.xio_file_     = prefix + "-io.xdc"
    self.xtm_file_     = prefix + "-io_timing.xdc"
    self.notfound_     = pin_map.copy()
    self.sysClkFrq_    = sysClkFrq
    # SPI freq. must match generic in HDL!
    self.spiClkFrq_    = 12.5E6

  def genHdr(self):
    with io.open(self.xio_file_, "w") as x:
      x.write("## Automatically generated; do not modify\n")
      x.write("## Edit 'ecevr_pinmap.py' instead and run gen_xdc.py\n")
    with io.open(self.xtm_file_, "w") as t:
      t.write("## Automatically generated; do not modify\n")
      t.write("## Edit 'ecevr_pinmap.py' instead and run gen_xdc.py\n")

  def findAttr(self, name):
    rv = []
    for i in self.pin_map_.items():
      try:
        i[1]["attrs"][name]
        rv.append(i)
      except KeyError:
        pass
    return rv

  def findCtl(self, name):
    for i in self.findAttr("BusCtl"):
      if ( i[1]["attrs"]["BusCtl"] == name ):
        return i
    raise KeyError(name)

  def mkIoClk(self, it, nam):
      return "create_generated_clock -name {:s} -multiply_by 1 -source [all_fanin -flat -startpoints_only [get_ports {{{:s}}}]] [get_ports {{{:s}}}]\n".format(nam, it[1]["port"], it[1]["port"])

  def mkSetupRelaxHold(self, f, setup, hold, clk, port):
    # The HBI implementation already times signals we only need to constrain
    # for the 'ideal' case of a very high system clock frequency. The setup
    # constraints remain but the hold constraints can be relaxed because
    # the state machine already delayed for the min. hold time.
    # If the system clock is faster than the setup/hold times then this must
    # be revisited!

    # setup
    f.write("set_output_delay -add_delay -max {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
      setup,
      clk,
      port))
    # hold
    f.write("set_output_delay -add_delay -min {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
      - hold,
      clk,
      port))
    # 
    # relax hold-time
    f.write( "set_multicycle_path -hold 1 -through [get_ports {{{:s}}}] -to [get_clocks {:s}]\n".format(
      port,
      clk))

  def mkIoFalsePath(self, f, clk, portName):
    f.write("set_input_delay  0 -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(clk, portName))
    f.write("set_output_delay 0 -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(clk, portName))
    f.write("set_false_path -from [get_ports {{{:s}}}]\n".format(portName))
    f.write("set_false_path -to   [get_ports {{{:s}}}]\n".format(portName))

  def genIoTiming(self, dummyClk="pllClk"):
    ale = self.findCtl("ALE")
    wr  = self.findCtl("WR")
    rd  = self.findCtl("RD")
    alNam  = "lan9254HBI_ALE"
    wrNam  = "lan9254HBI_WR"
    rdNam  = "lan9254HBI_RD"
    
    with io.open(self.xtm_file_, "a") as t:
      t.write( self.mkIoClk( ale, alNam ) )
      t.write( self.mkIoClk( wr , wrNam ) )
      t.write( self.mkIoClk( rd , rdNam ) )

      # dummy output delays for 'clock-like' signals
      for i in [(ale, alNam), (wr, wrNam), (rd, rdNam)]:
        portName = i[0][1]["port"]
        t.write("set_output_delay 0 -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
          i[1],
          portName))
        t.write("set_false_path -to   [get_ports {{{:s}}}]\n".format(portName))

      # SPI interface timing
      spiClk = "usrCClk"
      spiMosiPort = "spiMosiPin"
      spiMisoPort = "spiMisoPin"
      spiCselPort = "spiCselPin"
      # W25Q128JW
      spiMosiSetup = 2.0 + 0.1 # add trace delay
      spiMosiHold  = 3.0
      spiCselSetup = 5.0 + 0.1 # add trace delay
      spiCselHold  = 5.0
      spiMisoDely  = 6.0 + 0.4 # add trace delay
      spiMisoHold  = 1.5

      halfPeriodCycles = int(math.ceil(self.sysClkFrq_/self.spiClkFrq_/2.0))

      t.write( "set_output_delay -clock [get_clocks {:s}] -max {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        spiMosiSetup,
        spiMosiPort))
      t.write( "set_output_delay -clock [get_clocks {:s}] -min {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        - spiMosiHold,
        spiMosiPort))

      # SPI clock is derived from sysClk, dividing by 2; we can relax the hold requirement
      # by shifting hold analysis by 1 sysClk cycle
      t.write( "set_multicycle_path -setup {:d} -through [get_ports {{{:s}}}] -to [get_clocks {:s}]\n".format(
        halfPeriodCycles,
        spiMosiPort,
        spiClk))
      t.write( "set_multicycle_path -hold {:d} -through [get_ports {{{:s}}}] -to [get_clocks {:s}]\n".format(
        2*halfPeriodCycles-1,
        spiMosiPort,
        spiClk))

      t.write( "set_output_delay -clock [get_clocks {:s}] -max {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        spiCselSetup,
        spiCselPort))
      t.write( "set_output_delay -clock [get_clocks {:s}] -min {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        - spiCselHold,
        spiCselPort))
      # SPI clock is derived from sysClk, dividing by 2; we can relax the hold requirement
      # by shifting hold analysis by 1 sysClk cycle
      t.write( "set_multicycle_path -setup {:d} -through [get_ports {{{:s}}}] -to [get_clocks {:s}]\n".format(
        halfPeriodCycles,
        spiCselPort,
        spiClk))
      t.write( "set_multicycle_path -hold {:d} -through [get_ports {{{:s}}}] -to [get_clocks {:s}]\n".format(
        2*halfPeriodCycles-1,
        spiCselPort,
        spiClk))

      t.write( "set_input_delay -clock [get_clocks {:s}] -max {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        spiMisoDely,
        spiMisoPort))
      t.write( "set_input_delay -clock [get_clocks {:s}] -min {:f} [get_ports {{{:s}}}]\n".format(
        spiClk,
        spiMisoHold,
        spiMisoPort))
      t.write( "set_multicycle_path -setup {:d} -through [get_ports {{{:s}}}] -from [get_clocks {:s}]\n".format(
        halfPeriodCycles,
        spiMisoPort,
        spiClk))

      t.write( "set_multicycle_path -hold {:d} -through [get_ports {{{:s}}}] -from [get_clocks {:s}]\n".format(
        2*halfPeriodCycles-1,
        spiMisoPort,
        spiClk))

          
      for i in self.pin_map_.items():
        pinDesc  = i[1]
        portName = pinDesc["port"]
        # asynchronous pins
        try:
          if pinDesc["attrs"]["asynIO"]:
            t.write("\n")
            self.mkIoFalsePath( t, dummyClk, portName )
        except KeyError:
          pass

        wrDataSetup = 10.2 # including trace delay
        wrDataHold  =  0.1
        addrSetup   = 10.2 # including trace delay
        addrHold    =  5.0 

        dataSetup   =  0.0 + 0.2 # include trace delay
        dataHold    =  0.0

        # ADBus output delay
        try:
          # is this an address bus pin
          pinDesc["attrs"]["ADBus"]

          # write-data
          self.mkSetupRelaxHold( t, wrDataSetup, wrDataHold, wrNam, portName ) 
          # address setup
          self.mkSetupRelaxHold( t, addrSetup,   addrHold,   alNam, portName )

          t.write("set_input_delay -add_delay -max {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
             dataSetup,
             rdNam,
             portName))
          t.write("set_input_delay -add_delay -min {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
             dataHold,
             rdNam,
             portName))
        except KeyError:
          pass

        # Chip-select
        i = self.findCtl("CS")
        cselSetup = 0.0
        cselHold  = 0.0
        longTime  = 100.0
        # CS setup relevant for ALE
        # hold time irrelevant since CS is held until WR deasserts
        t.write("set_output_delay -add_delay -max {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
          cselSetup,
          alNam,
          i[1]["port"]))
        t.write("set_output_delay -add_delay -min {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
          longTime,
          alNam,
          i[1]["port"]))
        # CS hold defined by WR, setup irrelevant
        self.mkSetupRelaxHold( t, -longTime, cselHold, wrNam, i[1]["port"] )

        # Byte-enables are set with AL, i.e., way out of phase with RD/WR and may be relaxed
        for n in ["BEHi", "BELo"]:
          i = self.findCtl(n)
          t.write("set_output_delay -max {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
            -longTime,
            wrNam,
            i[1]["port"]))
          t.write("set_output_delay -min {:f} -clock [get_clocks {{{:s}}}] [get_ports {{{:s}}}]\n".format(
            longTime,
            wrNam,
            i[1]["port"]))
        
        # Wait-Ack is an asynchronous signal that we synchronize into our clock domain
        # and then use internally
        i = self.findCtl("WaitAck")
        self.mkIoFalsePath(t, dummyClk, i[1]["port"]) 
    
  def genIo(self, dummyClk="pllClk"):
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
            x.write("set_property {:16s} {:12s} [get_ports {{{:s}}}]\n".format("PACKAGE_PIN", wrds[0], portName))
            for p in pinDesc["props"].items():
              x.write("set_property {:16s} {:12s} [get_ports {{{:s}}}]\n".format(p[0], p[1], portName))
            x.write("\n")
            del( self.notfound_[wrds[1]] )
          except KeyError as e:
            pass
    self.warnNotfound()

  def warnNotfound(self):
    if ( len(self.notfound_) > 0 ):
      print("WARNING - some pin mappings could not be establishsed")
      print("          maybe their names are misspelled in ecevr_pinmap.py?")
      for k in self.notfound_.keys():
         print(k)

  def genFtr(self):
    pass

if __name__ == "__main__":
  opts, args = getopt.getopt(sys.argv[1:],"hf:")
  sysClkFrq  = None
  for o in opts:
    if ( o[0] == "-h" ):
      print("Usage: {} -f sysClockFreq [-h] filename".format(sys.argv[0]))
      print("    -h          : this message")
      sys.exit(0)
    elif ( o[0] == "-f" ):
      sysClkFrq = float(o[1])
    else:
      raise RuntimeError("Unknown option {}".format(o[0]))
  if len(args) < 1:
    raise RuntimeError("Missing pin filename arg")
  if ( sysClkFrq is None ):
    raise RuntimeError("Need '-f sysClkFreq' argument; frequency must match clock.xdc/top HDL!");
  gen = GenXdc( args[0], ecevr_pinmap.mkPinMap(), sysClkFrq )
  gen.genHdr() 
  gen.genIo()
  gen.genIoTiming()
  gen.genFtr() 
