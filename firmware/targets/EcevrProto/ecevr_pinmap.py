import re

class PinMap:

  def __init__(self):
    super().__init__()

  def pinFileName(self):
    raise RuntimeError("PinMap: pinFileName() must be overridden by subclass")

  def boardName(self):
    raise RuntimeError("PinMap: boardName() must be overridden by subclass")

  def getDefaultProps(self, nam):
    dfltProps = {}
    if   nam[:3] == "IO_":
      dfltProps = { "IOSTANDARD": "LVCMOS18" }
      if ( nam[-3:] == "_13" ):
        dfltProps = { "IOSTANDARD": "LVCMOS33" }
    elif re.match("^MGT[PX][RT]X.*", nam):
      dfltProps = { "IO_BUFFER_TYPE" : "NONE" }
    return dfltProps

  def getMap(self):
    raise RuntimeError("PinMap: getMap() must be overriden by subclass")

  def mkPinMap(self):
    revMap = dict()
    for i in self.getMap().items():
      nam = i[1]["name"]
      if nam is None:
        # erased pin
        continue
      prp = i[1]["props"]
      att = i[1]["attrs"]
      dfltProps = self.getDefaultProps( nam )
      for k in dfltProps.items():
        try:
          prp[k[0]]
        except KeyError:
          prp[k[0]] = k[1]
      revMap[nam]=dict()
      revMap[nam]["port"]=i[0]
      revMap[nam]["props"]=prp
      revMap[nam]["attrs"]=att
    return revMap 

  @staticmethod
  def remap(oldMap, newMap):
    for x in oldMap.items():
      try:
        oldMap[x[0]]["name"] = newMap[x[0]]
      except KeyError as e:
        print("Warning: {} not found in new map!".format(x[0]))
        

class EcEvrProtoPinMap(PinMap):

  def __init__(self):
    super().__init__()

  def boardName(self):
    return "EcEvrProto"

  def pinFileName(self):
    return "xc7a35tcsg325pkg.txt"

  def getMap(self):
    pinMap = dict()
    # default properties for IO_ pins
    lst = pinMap["pllClkPin"]              = { "name"  : "IO_L11P_T1_SRCC_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254ClkPin"]          = { "name"  : "IO_L12P_T1_MRCC_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[0]"]         = { "name"  : "IO_L8N_T1_AD10N_15", "props" : {}, "attrs" : {} }
    # pull-down the wait/ack into 'wait' state in case the EEPROM is not yet set up
    # correctly for using the push-pull driver with WAIT_ACK enabled (see Lan9254Hbi.vhd;
    # the datasheet incorrectly describes the lsbits in reg. 150).
    lst["props"]["PULLDOWN"] = "TRUE"
    lst["attrs"]["BusCtl"] = "WaitAck"
    lst = pinMap["lan9254Pins[1]"]         = { "name"  : "IO_L9N_T1_DQS_AD3N_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["lan9254Pins[2]"]         = { "name"  : "IO_L10N_T1_AD11N_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[3]"]         = { "name"  : "IO_L13N_T2_MRCC_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[4]"]         = { "name"  : "IO_L15P_T2_DQS_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[5]"]         = { "name"  : "IO_L15N_T2_DQS_ADV_B_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[6]"]         = { "name"  : "IO_L16P_T2_A28_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[7]"]         = { "name"  : "IO_L16N_T2_A27_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[8]"]         = { "name"  : "IO_L18P_T2_A24_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[9]"]         = { "name"  : "IO_L18N_T2_A23_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[10]"]        = { "name"  : "IO_L14N_T2_SRCC_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[11]"]        = { "name"  : "IO_L13P_T2_MRCC_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["lan9254Pins[12]"]        = { "name"  : "IO_L17N_T2_A25_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[13]"]        = { "name"  : "IO_L17P_T2_A26_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[14]"]        = { "name"  : "IO_L24N_T3_RS0_15", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[15]"]        = { "name"  : "IO_L14P_T2_SRCC_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[16]"]        = { "name"  : "IO_L19N_T3_A21_VREF_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[17]"]        = { "name"  : "IO_L24P_T3_RS1_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[18]"]        = { "name"  : "IO_L19P_T3_A22_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[19]"]        = { "name"  : "IO_L23N_T3_FWE_B_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "ALE"
    lst = pinMap["lan9254Pins[20]"]        = { "name"  : "IO_L20N_T3_A19_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "BELo"
    lst = pinMap["lan9254Pins[21]"]        = { "name"  : "IO_L2N_T0_D03_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "BEHi"
    lst = pinMap["lan9254Pins[22]"]        = { "name"  : "IO_L23P_T3_FOE_B_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "CS"
    lst = pinMap["lan9254Pins[23]"]        = { "name"  : "IO_L3N_T0_DQS_EMCCLK_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[24]"]        = { "name"  : "IO_L8P_T1_D11_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "WR"
    lst = pinMap["lan9254Pins[25]"]        = { "name"  : "IO_L4P_T0_D04_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["BusCtl"] = "RD"
    lst = pinMap["lan9254Pins[26]"]        = { "name"  : "IO_L4N_T0_D05_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[27]"]        = { "name"  : "IO_L7N_T1_D10_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[28]"]        = { "name"  : "IO_L7P_T1_D09_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[29]"]        = { "name"  : "IO_L10P_T1_D14_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["lan9254Pins[30]"]        = { "name"  : "IO_L6N_T0_D08_VREF_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[31]"]        = { "name"  : "IO_L9P_T1_DQS_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[32]"]        = { "name"  : "IO_L8N_T1_D12_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[33]"]        = { "name"  : "IO_L10N_T1_D15_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[34]"]        = { "name"  : "IO_L11P_T1_SRCC_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[35]"]        = { "name"  : "IO_L9N_T1_DQS_D13_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[36]"]        = { "name"  : "IO_L15P_T2_DQS_RDWR_B_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[37]"]        = { "name"  : "IO_L12N_T1_MRCC_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Hi"
    lst = pinMap["lan9254Pins[38]"]        = { "name"  : "IO_L11N_T1_SRCC_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["lan9254Pins[39]"]        = { "name"  : "IO_L14P_T2_SRCC_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[40]"]        = { "name"  : "IO_L15N_T2_DQS_DOUT_CSO_B_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["ADBus"] = "Lo"
    lst = pinMap["lan9254Pins[41]"]        = { "name"  : "IO_L14N_T2_SRCC_14", "props" : {}, "attrs" : {} }
    lst = pinMap["lan9254Pins[42]"]        = { "name"  : "IO_L16P_T2_CSI_B_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["lan9254Pins[43]"]        = { "name"  : "IO_L16N_T2_A15_D31_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["gpioDatPins[0]"]         = { "name"  : "IO_L18N_T2_A11_D27_14", "props" : {}, "attrs" : {} }
    lst = pinMap["gpioDatPins[1]"]         = { "name"  : "IO_L18P_T2_A12_D28_14", "props" : {}, "attrs" : {} }
    lst = pinMap["gpioDatPins[2]"]         = { "name"  : "IO_L17P_T2_A14_D30_14", "props" : {}, "attrs" : {} }
    lst = pinMap["gpioDirPins[0]"]         = { "name"  : "IO_L13N_T2_MRCC_14", "props" : {}, "attrs" : {} }
    lst = pinMap["gpioDirPins[1]"]         = { "name"  : "IO_L17N_T2_A13_D29_14", "props" : {}, "attrs" : {} }
    lst = pinMap["gpioDirPins[2]"]         = { "name"  : "IO_L20N_T3_A07_D23_14", "props" : {}, "attrs" : {} }
    lst = pinMap["ledPins[0]"]             = { "name"  : "IO_L3P_T0_DQS_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[1]"]             = { "name"  : "IO_L3N_T0_DQS_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[2]"]             = { "name"  : "IO_L12P_T1_MRCC_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[3]"]             = { "name"  : "IO_L18P_T2_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[4]"]             = { "name"  : "IO_L18N_T2_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[5]"]             = { "name"  : "IO_25_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[6]"]             = { "name"  : "IO_L20N_T3_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[7]"]             = { "name"  : "IO_L23N_T3_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["ledPins[8]"]             = { "name"  : "IO_L20P_T3_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["pofInpPins[0]"]          = { "name"  : "IO_L5N_T0_34", "props" : {}, "attrs" : {} }
    lst = pinMap["pofInpPins[1]"]          = { "name"  : "IO_L10P_T1_34", "props" : {}, "attrs" : {} }
    lst = pinMap["pofOutPins[0]"]          = { "name"  : "IO_L4P_T0_34", "props" : {}, "attrs" : {} }
    lst = pinMap["pofOutPins[1]"]          = { "name"  : "IO_L4N_T0_34", "props" : {}, "attrs" : {} }
    lst = pinMap["pwrCyclePin"]            = { "name"  : "IO_L16P_T2_34", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["i2cSdaPins[0]"]          = { "name"  : "IO_L23P_T3_A03_D19_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["i2cSdaPins[1]"]          = { "name"  : "IO_L8P_T1_AD10P_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["i2cSclPins[0]"]          = { "name"  : "IO_L21P_T3_DQS_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["i2cSclPins[1]"]          = { "name"  : "IO_L4N_T0_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["eepWPPin"]               = { "name"  : "IO_25_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["eepSz32kPin"]            = { "name"  : "IO_L22P_T3_A05_D21_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["i2cISObPin"]             = { "name"  : "IO_L23N_T3_A02_D18_14", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["jumper7Pin"]             = { "name"  : "IO_L22N_T3_A04_D20_14", "props" : {}, "attrs" : {} }
    lst["props"]["PULLUP"] = "TRUE"
    lst["attrs"]["asynIO"] = True
    lst = pinMap["jumper8Pin"]             = { "name"  : "IO_L21N_T3_DQS_A06_D22_14", "props" : {}, "attrs" : {} }
    lst["props"]["PULLUP"] = "TRUE"
    lst["attrs"]["asynIO"] = True
    lst = pinMap["sfpLosPins[0]"]          = { "name"  : "IO_L5P_T0_AD9P_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["sfpPresentbPins[0]"]     = { "name"  : "IO_L2N_T0_AD8N_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["sfpTxFaultPins[0]"]      = { "name"  : "IO_L5N_T0_AD9N_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    lst = pinMap["sfpTxEnPins[0]"]         = { "name"  : "IO_L3N_T0_DQS_AD1N_15", "props" : {}, "attrs" : {} }
    lst["attrs"]["asynIO"] = True
    # pinMap["spiSclkPin"]  must use STARTUPE2 to drive this pin
    lst = pinMap["spiMosiPin"]             = { "name"  : "IO_L1P_T0_D00_MOSI_14", "props" : {}, "attrs" : {} }
    lst = pinMap["spiCselPin"]             = { "name"  : "IO_L6P_T0_FCS_B_14",    "props" : {}, "attrs" : {} }
    lst = pinMap["spiMisoPin"]             = { "name"  : "IO_L1N_T0_D01_DIN_14",       "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxPPins[0]"]          = { "name"  : "MGTPRXP0_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxPPins[1]"]          = { "name"  : "MGTPRXP1_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxPPins[2]"]          = { "name"  : "MGTPRXP2_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxPPins[3]"]          = { "name"  : "MGTPRXP3_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxNPins[0]"]          = { "name"  : "MGTPRXN0_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxNPins[1]"]          = { "name"  : "MGTPRXN1_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxNPins[2]"]          = { "name"  : "MGTPRXN2_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRxNPins[3]"]          = { "name"  : "MGTPRXN3_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxPPins[0]"]          = { "name"  : "MGTPTXP0_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxPPins[1]"]          = { "name"  : "MGTPTXP1_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxPPins[2]"]          = { "name"  : "MGTPTXP2_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxPPins[3]"]          = { "name"  : "MGTPTXP3_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxNPins[0]"]          = { "name"  : "MGTPTXN0_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxNPins[1]"]          = { "name"  : "MGTPTXN1_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxNPins[2]"]          = { "name"  : "MGTPTXN2_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtTxNPins[3]"]          = { "name"  : "MGTPTXN3_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRefClkPPins[0]"]      = { "name"  : "MGTREFCLK0P_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRefClkPPins[1]"]      = { "name"  : "MGTREFCLK1P_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRefClkNPins[0]"]      = { "name"  : "MGTREFCLK0N_216", "props" : {}, "attrs" : {} }
    lst = pinMap["mgtRefClkNPins[1]"]      = { "name"  : "MGTREFCLK1N_216", "props" : {}, "attrs" : {} }
    return pinMap

class EcEvrDevBoardPinMap(EcEvrProtoPinMap):

  z15Pins = {
    "lan9254Pins[0]"              : "IO_L15N_T2_DQS_34",
    "lan9254Pins[1]"              : "IO_L15P_T2_DQS_34",
    "lan9254Pins[2]"              : "IO_L18N_T2_34",
    "lan9254Pins[3]"              : "IO_L2P_T0_34",
    "lan9254Pins[4]"              : "IO_L2N_T0_34",
    "lan9254Pins[5]"              : "IO_L12P_T1_MRCC_34",
    "lan9254Pins[6]"              : "IO_L6N_T0_VREF_34",
    "lan9254Pins[7]"              : "IO_L6P_T0_34",
    "lan9254Pins[8]"              : "IO_L8P_T1_34",
    "lan9254Pins[9]"              : "IO_L16P_T2_35",
    "lan9254Pins[10]"             : "IO_L16N_T2_35",
    "lan9254Pins[11]"             : "IO_L7N_T1_34",
    "lan9254Pins[12]"             : "IO_L18N_T2_AD13N_35",
    "lan9254Pins[13]"             : "IO_L18P_T2_AD13P_35",
    "lan9254Pins[14]"             : "IO_L21P_T3_DQS_AD14P_35",
    "lan9254Pins[15]"             : "IO_L15N_T2_DQS_AD12N_35",
    "lan9254Pins[16]"             : "IO_L15P_T2_DQS_AD12P_35",
    "lan9254Pins[17]"             : "IO_L8P_T1_AD10P_35",
    "lan9254Pins[18]"             : "IO_L13P_T2_MRCC_35",
    "lan9254Pins[19]"             : "IO_L13N_T2_MRCC_35",
    "lan9254Pins[20]"             : "IO_L11N_T1_SRCC_35",
    "lan9254Pins[21]"             : "IO_L14P_T2_AD4P_SRCC_35",
    "lan9254Pins[22]"             : "IO_L14N_T2_AD4N_SRCC_35",
    "lan9254Pins[23]"             : "IO_L3N_T0_DQS_AD1N_35",
    "lan9254Pins[24]"             : "IO_L12P_T1_MRCC_35",
    "lan9254Pins[25]"             : "IO_L12N_T1_MRCC_35",
    "lan9254Pins[26]"             : "IO_L7N_T1_AD2N_35",
    "lan9254Pins[27]"             : "IO_L23N_T3_35",
    "lan9254Pins[28]"             : "IO_L23P_T3_35",
    "lan9254Pins[29]"             : "IO_L4P_T0_35",
    "lan9254Pins[30]"             : "IO_L2N_T0_AD8N_35",
    "lan9254Pins[31]"             : "IO_L2P_T0_AD8P_35",
    "lan9254Pins[32]"             : "IO_L5N_T0_AD9N_35",
    "lan9254Pins[33]"             : "IO_L17P_T2_AD5P_35",
    "lan9254Pins[34]"             : "IO_L17N_T2_AD5N_35",
    "lan9254Pins[35]"             : "IO_L6N_T0_VREF_35",
    "lan9254Pins[36]"             : "IO_L24P_T3_AD15P_35",
    "lan9254Pins[37]"             : "IO_L24N_T3_AD15N_35",
    "lan9254Pins[38]"             : "IO_0_35",
    "lan9254Pins[39]"             : "IO_L9N_T1_DQS_AD3N_35",
    "lan9254Pins[40]"             : "IO_L9P_T1_DQS_AD3P_35",
    "lan9254Pins[41]"             : "IO_L22N_T3_AD7N_35",
    "lan9254Pins[42]"             : "IO_L22P_T3_AD7P_35",
    "lan9254Pins[43]"             : "IO_L10N_T1_AD11N_35",
    "gpioDatPins[0]"              : "IO_L10P_T1_AD11P_35",
    "gpioDatPins[1]"              : "IO_L20P_T3_AD6P_35",
    "gpioDatPins[2]"              : "IO_L17P_T2_34",
    "gpioDirPins[0]"              : "IO_L20N_T3_AD6N_35",
    "gpioDirPins[1]"              : "IO_25_35",
    "gpioDirPins[2]"              : "IO_L17N_T2_34",
    "ledPins[0]"                  : "IO_L15N_T2_DQS_13",
    "ledPins[1]"                  : "IO_L15P_T2_DQS_13",
    "ledPins[2]"                  : "IO_L20P_T3_13",
    "ledPins[3]"                  : "IO_L20N_T3_13",
    "ledPins[4]"                  : "IO_L21P_T3_DQS_13",
    "ledPins[5]"                  : "IO_L21N_T3_DQS_13",
    "ledPins[6]"                  : "IO_L3P_T0_DQS_13",
    "ledPins[7]"                  : "IO_L3N_T0_DQS_13",
    "ledPins[8]"                  : "IO_L5N_T0_13",
    "i2cSdaPins[0]"               : "IO_L18P_T2_13",
    "i2cSdaPins[1]"               : "IO_L11P_T1_SRCC_34",
    "i2cSclPins[0]"               : "IO_L18N_T2_13",
    "i2cSclPins[1]"               : "IO_L11N_T1_SRCC_34",
    "eepWPPin"                    : "IO_L18P_T2_34",
    "eepSz32kPin"                 : "IO_L12N_T1_MRCC_34",
    "i2cISObPin"                  : "IO_L8N_T1_34",
    "jumper7Pin"                  : "IO_L7P_T1_34",
    "jumper8Pin"                  : "IO_L21N_T3_DQS_AD14N_35",
    "pwrCyclePin"                 : "IO_L8N_T1_AD10N_35",
    "sfpTxEnPins[0]"              : "IO_L6N_T0_VREF_13",
    "sfpTxFaultPins[0]"           : "IO_L6P_T0_13",
    "sfpLosPins[0]"               : "IO_L4N_T0_13",
    "sfpPresentbPins[0]"          : "IO_L4P_T0_13",
    "mgtRxPPins[0]"               : "MGTPRXP0_112",
    "mgtTxPPins[0]"               : "MGTPTXP0_112",
    "mgtRxNPins[0]"               : "MGTPRXN0_112",
    "mgtTxNPins[0]"               : "MGTPTXN0_112",
    "mgtRxPPins[1]"               : "MGTPRXP1_112",
    "mgtTxPPins[1]"               : "MGTPTXP1_112",
    "mgtRxNPins[1]"               : "MGTPRXN1_112",
    "mgtTxNPins[1]"               : "MGTPTXN1_112",
    "mgtRxPPins[2]"               : "MGTPRXP2_112",
    "mgtTxPPins[2]"               : "MGTPTXP2_112",
    "mgtRxNPins[2]"               : "MGTPRXN2_112",
    "mgtTxNPins[2]"               : "MGTPTXN2_112",
    "mgtRxPPins[3]"               : "MGTPRXP3_112",
    "mgtTxPPins[3]"               : "MGTPTXP3_112",
    "mgtRxNPins[3]"               : "MGTPRXN3_112",
    "mgtTxNPins[3]"               : "MGTPTXN3_112",
    "mgtRefClkPPins[0]"           : "MGTREFCLK0P_112",
    "mgtRefClkNPins[0]"           : "MGTREFCLK0N_112",
    "mgtRefClkPPins[1]"           : "MGTREFCLK1P_112",
    "mgtRefClkNPins[1]"           : "MGTREFCLK1N_112",
    "pllClkPin"                   : None,
    "lan9254ClkPin"               : None,
    "pofInpPins[0]"               : None,
    "pofInpPins[1]"               : None,
    "pofOutPins[0]"               : None,
    "pofOutPins[1]"               : None,
    "spiMosiPin"                  : None,
    "spiCselPin"                  : None,
    "spiMisoPin"                  : None
  }

  z30Pins = {
    "lan9254Pins[0]"              : "IO_L15N_T2_DQS_34",
    "lan9254Pins[1]"              : "IO_L15P_T2_DQS_34",
    "lan9254Pins[2]"              : "IO_L18N_T2_34",
    "lan9254Pins[3]"              : "IO_L2P_T0_34",
    "lan9254Pins[4]"              : "IO_L2N_T0_34",
    "lan9254Pins[5]"              : "IO_L12P_T1_MRCC_34",
    "lan9254Pins[6]"              : "IO_L6N_T0_VREF_34",
    "lan9254Pins[7]"              : "IO_L6P_T0_34",
    "lan9254Pins[8]"              : "IO_L8P_T1_34",
    "lan9254Pins[9]"              : "IO_L16P_T2_35",
    "lan9254Pins[10]"             : "IO_L16N_T2_35",
    "lan9254Pins[11]"             : "IO_L7N_T1_34",
    "lan9254Pins[12]"             : "IO_L18N_T2_AD13N_35",
    "lan9254Pins[13]"             : "IO_L18P_T2_AD13P_35",
    "lan9254Pins[14]"             : "IO_L21P_T3_DQS_AD14P_35",
    "lan9254Pins[15]"             : "IO_L15N_T2_DQS_AD12N_35",
    "lan9254Pins[16]"             : "IO_L15P_T2_DQS_AD12P_35",
    "lan9254Pins[17]"             : "IO_L8P_T1_AD10P_35",
    "lan9254Pins[18]"             : "IO_L13P_T2_MRCC_35",
    "lan9254Pins[19]"             : "IO_L13N_T2_MRCC_35",
    "lan9254Pins[20]"             : "IO_L11N_T1_SRCC_35",
    "lan9254Pins[21]"             : "IO_L14P_T2_AD4P_SRCC_35",
    "lan9254Pins[22]"             : "IO_L14N_T2_AD4N_SRCC_35",
    "lan9254Pins[23]"             : "IO_L3N_T0_DQS_AD1N_35",
    "lan9254Pins[24]"             : "IO_L12P_T1_MRCC_35",
    "lan9254Pins[25]"             : "IO_L12N_T1_MRCC_35",
    "lan9254Pins[26]"             : "IO_L7N_T1_AD2N_35",
    "lan9254Pins[27]"             : "IO_L23N_T3_35",
    "lan9254Pins[28]"             : "IO_L23P_T3_35",
    "lan9254Pins[29]"             : "IO_L4P_T0_35",
    "lan9254Pins[30]"             : "IO_L2N_T0_AD8N_35",
    "lan9254Pins[31]"             : "IO_L2P_T0_AD8P_35",
    "lan9254Pins[32]"             : "IO_L5N_T0_AD9N_35",
    "lan9254Pins[33]"             : "IO_L17P_T2_AD5P_35",
    "lan9254Pins[34]"             : "IO_L17N_T2_AD5N_35",
    "lan9254Pins[35]"             : "IO_L6N_T0_VREF_35",
    "lan9254Pins[36]"             : "IO_L24P_T3_AD15P_35",
    "lan9254Pins[37]"             : "IO_L24N_T3_AD15N_35",
    "lan9254Pins[38]"             : "IO_0_VRN_35",
    "lan9254Pins[39]"             : "IO_L9N_T1_DQS_AD3N_35",
    "lan9254Pins[40]"             : "IO_L9P_T1_DQS_AD3P_35",
    "lan9254Pins[41]"             : "IO_L22N_T3_AD7N_35",
    "lan9254Pins[42]"             : "IO_L22P_T3_AD7P_35",
    "lan9254Pins[43]"             : "IO_L10N_T1_AD11N_35",
    "gpioDatPins[0]"              : "IO_L10P_T1_AD11P_35",
    "gpioDatPins[1]"              : "IO_L20P_T3_AD6P_35",
    "gpioDatPins[2]"              : "IO_L17P_T2_34",
    "gpioDirPins[0]"              : "IO_L20N_T3_AD6N_35",
    "gpioDirPins[1]"              : "IO_25_VRP_35",
    "gpioDirPins[2]"              : "IO_L17N_T2_34",
    "ledPins[0]"                  : "IO_L15N_T2_DQS_13",
    "ledPins[1]"                  : "IO_L15P_T2_DQS_13",
    "ledPins[2]"                  : "IO_L20P_T3_13",
    "ledPins[3]"                  : "IO_L20N_T3_13",
    "ledPins[4]"                  : "IO_L21P_T3_DQS_13",
    "ledPins[5]"                  : "IO_L21N_T3_DQS_13",
    "ledPins[6]"                  : "IO_L3P_T0_DQS_13",
    "ledPins[7]"                  : "IO_L3N_T0_DQS_13",
    "ledPins[8]"                  : "IO_L5N_T0_13",
    "i2cSdaPins[0]"               : "IO_L18P_T2_13",
    "i2cSdaPins[1]"               : "IO_L11P_T1_SRCC_34",
    "i2cSclPins[0]"               : "IO_L18N_T2_13",
    "i2cSclPins[1]"               : "IO_L11N_T1_SRCC_34",
    "eepWPPin"                    : "IO_L18P_T2_34",
    "eepSz32kPin"                 : "IO_L12N_T1_MRCC_34",
    "i2cISObPin"                  : "IO_L8N_T1_34",
    "jumper7Pin"                  : "IO_L7P_T1_34",
    "jumper8Pin"                  : "IO_L21N_T3_DQS_AD14N_35",
    "pwrCyclePin"                 : "IO_L8N_T1_AD10N_35",
    "sfpTxEnPins[0]"              : "IO_L6N_T0_VREF_13",
    "sfpTxFaultPins[0]"           : "IO_L6P_T0_13",
    "sfpLosPins[0]"               : "IO_L4N_T0_13",
    "sfpPresentbPins[0]"          : "IO_L4P_T0_13",
    "mgtRxPPins[0]"               : "MGTXRXP0_112",
    "mgtTxPPins[0]"               : "MGTXTXP0_112",
    "mgtRxNPins[0]"               : "MGTXRXN0_112",
    "mgtTxNPins[0]"               : "MGTXTXN0_112",
    "mgtRxPPins[1]"               : "MGTXRXP1_112",
    "mgtTxPPins[1]"               : "MGTXTXP1_112",
    "mgtRxNPins[1]"               : "MGTXRXN1_112",
    "mgtTxNPins[1]"               : "MGTXTXN1_112",
    "mgtRxPPins[2]"               : "MGTXRXP2_112",
    "mgtTxPPins[2]"               : "MGTXTXP2_112",
    "mgtRxNPins[2]"               : "MGTXRXN2_112",
    "mgtTxNPins[2]"               : "MGTXTXN2_112",
    "mgtRxPPins[3]"               : "MGTXRXP3_112",
    "mgtTxPPins[3]"               : "MGTXTXP3_112",
    "mgtRxNPins[3]"               : "MGTXRXN3_112",
    "mgtTxNPins[3]"               : "MGTXTXN3_112",
    "mgtRefClkPPins[0]"           : "MGTREFCLK0P_112",
    "mgtRefClkNPins[0]"           : "MGTREFCLK0N_112",
    "mgtRefClkPPins[1]"           : "MGTREFCLK1P_112",
    "mgtRefClkNPins[1]"           : "MGTREFCLK1N_112",
    "pllClkPin"                   : None,
    "lan9254ClkPin"               : None,
    "pofInpPins[0]"               : None,
    "pofInpPins[1]"               : None,
    "pofOutPins[0]"               : None,
    "pofOutPins[1]"               : None,
    "spiMosiPin"                  : None,
    "spiCselPin"                  : None,
    "spiMisoPin"                  : None
  }

  def __init__(self, z15=True):
    super().__init__()
    self._z15 = z15

  @property
  def z15(self):
    return self._z15

  def boardName(self):
    return "EcEvrDevBoard"

  def pinFileName(self):
    if ( self.z15 ):
      return "xc7z015clg485pkg.txt"
    else:
      return "xc7z030sbg485pkg.txt"

  def getMap(self):
    smap = super().getMap()
    if self.z15:
      self.remap( smap, self.z15Pins )
    else:
      self.remap( smap, self.z30Pins )
    # some fixup; the eeprom size switch is not sensed
    # assume a 16k EEPROM
    # Could change in the HDL but not without changing
    # the respective port from inout to in. Don't want
    # to do that - maybe it's used to control the size
    # at some point...
    smap["eepSz32kPin"]["props"]["PULLDOWN"]="TRUE"
    return smap
