def mkPinMap():
  pinMap = dict()
  # default properties for IO_ pins
  dfltIoProps  = { "IOSTANDARD": "LVCMOS18" }
  dfltMgtProps = { "IO_BUFFER_TYPE" : "NONE" }
  pinMap["pllClkPin"]              = { "name"  : "IO_L11P_T1_SRCC_15", "props" : {} }
  pinMap["lan9254ClkPin"]          = { "name"  : "IO_L12P_T1_MRCC_15", "props" : {} }
  pinMap["lan9254Pins[0]"]         = { "name"  : "IO_L8N_T1_AD10N_15", "props" : {} }
  # pull-down the wait/ack into 'wait' state in case the EEPROM is not yet set up
  # correctly for using the push-pull driver with WAIT_ACK enabled (see Lan9254Hbi.vhd;
  # the datasheet incorrectly describes the lsbits in reg. 150).
  pinMap["lan9254Pins[0]"]["props"]["PULLDOWN"] = "TRUE"
  pinMap["lan9254Pins[1]"]         = { "name"  : "IO_L9N_T1_DQS_AD3N_15", "props" : {} }
  pinMap["lan9254Pins[2]"]         = { "name"  : "IO_L10N_T1_AD11N_15", "props" : {} }
  pinMap["lan9254Pins[3]"]         = { "name"  : "IO_L13N_T2_MRCC_15", "props" : {} }
  pinMap["lan9254Pins[4]"]         = { "name"  : "IO_L15P_T2_DQS_15", "props" : {} }
  pinMap["lan9254Pins[5]"]         = { "name"  : "IO_L15N_T2_DQS_ADV_B_15", "props" : {} }
  pinMap["lan9254Pins[6]"]         = { "name"  : "IO_L16P_T2_A28_15", "props" : {} }
  pinMap["lan9254Pins[7]"]         = { "name"  : "IO_L16N_T2_A27_15", "props" : {} }
  pinMap["lan9254Pins[8]"]         = { "name"  : "IO_L18P_T2_A24_15", "props" : {} }
  pinMap["lan9254Pins[9]"]         = { "name"  : "IO_L18N_T2_A23_15", "props" : {} }
  pinMap["lan9254Pins[10]"]        = { "name"  : "IO_L14N_T2_SRCC_15", "props" : {} }
  pinMap["lan9254Pins[11]"]        = { "name"  : "IO_L13P_T2_MRCC_15", "props" : {} }
  pinMap["lan9254Pins[12]"]        = { "name"  : "IO_L17N_T2_A25_15", "props" : {} }
  pinMap["lan9254Pins[13]"]        = { "name"  : "IO_L17P_T2_A26_15", "props" : {} }
  pinMap["lan9254Pins[14]"]        = { "name"  : "IO_L24N_T3_RS0_15", "props" : {} }
  pinMap["lan9254Pins[15]"]        = { "name"  : "IO_L14P_T2_SRCC_15", "props" : {} }
  pinMap["lan9254Pins[16]"]        = { "name"  : "IO_L19N_T3_A21_VREF_15", "props" : {} }
  pinMap["lan9254Pins[17]"]        = { "name"  : "IO_L24P_T3_RS1_15", "props" : {} }
  pinMap["lan9254Pins[18]"]        = { "name"  : "IO_L19P_T3_A22_15", "props" : {} }
  pinMap["lan9254Pins[19]"]        = { "name"  : "IO_L23N_T3_FWE_B_15", "props" : {} }
  pinMap["lan9254Pins[20]"]        = { "name"  : "IO_L20N_T3_A19_15", "props" : {} }
  pinMap["lan9254Pins[21]"]        = { "name"  : "IO_L2N_T0_D03_14", "props" : {} }
  pinMap["lan9254Pins[22]"]        = { "name"  : "IO_L23P_T3_FOE_B_15", "props" : {} }
  pinMap["lan9254Pins[23]"]        = { "name"  : "IO_L3N_T0_DQS_EMCCLK_14", "props" : {} }
  pinMap["lan9254Pins[24]"]        = { "name"  : "IO_L8P_T1_D11_14", "props" : {} }
  pinMap["lan9254Pins[25]"]        = { "name"  : "IO_L4P_T0_D04_14", "props" : {} }
  pinMap["lan9254Pins[26]"]        = { "name"  : "IO_L4N_T0_D05_14", "props" : {} }
  pinMap["lan9254Pins[27]"]        = { "name"  : "IO_L7N_T1_D10_14", "props" : {} }
  pinMap["lan9254Pins[28]"]        = { "name"  : "IO_L7P_T1_D09_14", "props" : {} }
  pinMap["lan9254Pins[29]"]        = { "name"  : "IO_L10P_T1_D14_14", "props" : {} }
  pinMap["lan9254Pins[30]"]        = { "name"  : "IO_L6N_T0_D08_VREF_14", "props" : {} }
  pinMap["lan9254Pins[31]"]        = { "name"  : "IO_L9P_T1_DQS_14", "props" : {} }
  pinMap["lan9254Pins[32]"]        = { "name"  : "IO_L8N_T1_D12_14", "props" : {} }
  pinMap["lan9254Pins[33]"]        = { "name"  : "IO_L10N_T1_D15_14", "props" : {} }
  pinMap["lan9254Pins[34]"]        = { "name"  : "IO_L11P_T1_SRCC_14", "props" : {} }
  pinMap["lan9254Pins[35]"]        = { "name"  : "IO_L9N_T1_DQS_D13_14", "props" : {} }
  pinMap["lan9254Pins[36]"]        = { "name"  : "IO_L15P_T2_DQS_RDWR_B_14", "props" : {} }
  pinMap["lan9254Pins[37]"]        = { "name"  : "IO_L12N_T1_MRCC_14", "props" : {} }
  pinMap["lan9254Pins[38]"]        = { "name"  : "IO_L11N_T1_SRCC_14", "props" : {} }
  pinMap["lan9254Pins[39]"]        = { "name"  : "IO_L14P_T2_SRCC_14", "props" : {} }
  pinMap["lan9254Pins[40]"]        = { "name"  : "IO_L15N_T2_DQS_DOUT_CSO_B_14", "props" : {} }
  pinMap["lan9254Pins[41]"]        = { "name"  : "IO_L14N_T2_SRCC_14", "props" : {} }
  pinMap["lan9254Pins[42]"]        = { "name"  : "IO_L16P_T2_CSI_B_14", "props" : {} }
  pinMap["lan9254Pins[43]"]        = { "name"  : "IO_L16N_T2_A15_D31_14", "props" : {} }
  pinMap["gpioDatPins[0]"]         = { "name"  : "IO_L18N_T2_A11_D27_14", "props" : {} }
  pinMap["gpioDatPins[1]"]         = { "name"  : "IO_L18P_T2_A12_D28_14", "props" : {} }
  pinMap["gpioDatPins[2]"]         = { "name"  : "IO_L17P_T2_A14_D30_14", "props" : {} }
  pinMap["gpioDirPins[0]"]         = { "name"  : "IO_L13N_T2_MRCC_14", "props" : {} }
  pinMap["gpioDirPins[1]"]         = { "name"  : "IO_L17N_T2_A13_D29_14", "props" : {} }
  pinMap["gpioDirPins[2]"]         = { "name"  : "IO_L20N_T3_A07_D23_14", "props" : {} }
  pinMap["ledPins[0]"]             = { "name"  : "IO_L3P_T0_DQS_34", "props" : {} }
  pinMap["ledPins[1]"]             = { "name"  : "IO_L3N_T0_DQS_34", "props" : {} }
  pinMap["ledPins[2]"]             = { "name"  : "IO_L12P_T1_MRCC_34", "props" : {} }
  pinMap["ledPins[3]"]             = { "name"  : "IO_L18P_T2_34", "props" : {} }
  pinMap["ledPins[4]"]             = { "name"  : "IO_L18N_T2_34", "props" : {} }
  pinMap["ledPins[5]"]             = { "name"  : "IO_25_34", "props" : {} }
  pinMap["ledPins[6]"]             = { "name"  : "IO_L20N_T3_34", "props" : {} }
  pinMap["ledPins[7]"]             = { "name"  : "IO_L23N_T3_34", "props" : {} }
  pinMap["ledPins[8]"]             = { "name"  : "IO_L20P_T3_34", "props" : {} }
  pinMap["pofInpPins[0]"]          = { "name"  : "IO_L5N_T0_34", "props" : {} }
  pinMap["pofInpPins[1]"]          = { "name"  : "IO_L10P_T1_34", "props" : {} }
  pinMap["pofOutPins[0]"]          = { "name"  : "IO_L4P_T0_34", "props" : {} }
  pinMap["pofOutPins[1]"]          = { "name"  : "IO_L4N_T0_34", "props" : {} }
  pinMap["pwrCyclePin"]            = { "name"  : "IO_L16P_T2_34", "props" : {} }
  pinMap["i2cSdaPins[0]"]          = { "name"  : "IO_L23P_T3_A03_D19_14", "props" : {} }
  pinMap["i2cSdaPins[1]"]          = { "name"  : "IO_L8P_T1_AD10P_15", "props" : {} }
  pinMap["i2cSclPins[0]"]          = { "name"  : "IO_L21P_T3_DQS_14", "props" : {} }
  pinMap["i2cSclPins[1]"]          = { "name"  : "IO_L4N_T0_15", "props" : {} }
  pinMap["eepWPPin"]               = { "name"  : "IO_25_14", "props" : {} }
  pinMap["eepSz32kPin"]            = { "name"  : "IO_L22P_T3_A05_D21_14", "props" : {} }
  pinMap["i2cISObPin"]             = { "name"  : "IO_L23N_T3_A02_D18_14", "props" : {} }
  pinMap["jumper7Pin"]             = { "name"  : "IO_L22N_T3_A04_D20_14", "props" : {} }
  pinMap["jumper7Pin"]["props"]["PULLUP"] = "TRUE"
  pinMap["jumper8Pin"]             = { "name"  : "IO_L21N_T3_DQS_A06_D22_14", "props" : {} }
  pinMap["jumper8Pin"]["props"]["PULLUP"] = "TRUE"
  pinMap["sfpLosPins[0]"]          = { "name"  : "IO_L5P_T0_AD9P_15", "props" : {} }
  pinMap["sfpPresentbPins[0]"]     = { "name"  : "IO_L2N_T0_AD8N_15", "props" : {} }
  pinMap["sfpTxFaultPins[0]"]      = { "name"  : "IO_L5N_T0_AD9N_15", "props" : {} }
  pinMap["sfpTxEnPins[0]"]         = { "name"  : "IO_L3N_T0_DQS_AD1N_15", "props" : {} }
  # pinMap["spiSclkPin"]  must use STARTUPE2 to drive this pin
  pinMap["spiMosiPin"]             = { "name"  : "IO_L1P_T0_D00_MOSI_14", "props" : {} }
  pinMap["spiCselPin"]             = { "name"  : "IO_L6P_T0_FCS_B_14",    "props" : {} }
  pinMap["spiMisoPin"]             = { "name"  : "IO_L1N_T0_D01_DIN_14",       "props" : {} }
  pinMap["mgtRxPPins[0]"]          = { "name"  : "MGTPRXP0_216", "props" : {} }
  pinMap["mgtRxPPins[1]"]          = { "name"  : "MGTPRXP1_216", "props" : {} }
  pinMap["mgtRxPPins[2]"]          = { "name"  : "MGTPRXP2_216", "props" : {} }
  pinMap["mgtRxPPins[3]"]          = { "name"  : "MGTPRXP3_216", "props" : {} }
  pinMap["mgtRxNPins[0]"]          = { "name"  : "MGTPRXN0_216", "props" : {} }
  pinMap["mgtRxNPins[1]"]          = { "name"  : "MGTPRXN1_216", "props" : {} }
  pinMap["mgtRxNPins[2]"]          = { "name"  : "MGTPRXN2_216", "props" : {} }
  pinMap["mgtRxNPins[3]"]          = { "name"  : "MGTPRXN3_216", "props" : {} }
  pinMap["mgtTxPPins[0]"]          = { "name"  : "MGTPTXP0_216", "props" : {} }
  pinMap["mgtTxPPins[1]"]          = { "name"  : "MGTPTXP1_216", "props" : {} }
  pinMap["mgtTxPPins[2]"]          = { "name"  : "MGTPTXP2_216", "props" : {} }
  pinMap["mgtTxPPins[3]"]          = { "name"  : "MGTPTXP3_216", "props" : {} }
  pinMap["mgtTxNPins[0]"]          = { "name"  : "MGTPTXN0_216", "props" : {} }
  pinMap["mgtTxNPins[1]"]          = { "name"  : "MGTPTXN1_216", "props" : {} }
  pinMap["mgtTxNPins[2]"]          = { "name"  : "MGTPTXN2_216", "props" : {} }
  pinMap["mgtTxNPins[3]"]          = { "name"  : "MGTPTXN3_216", "props" : {} }
  pinMap["mgtRefClkPPins[0]"]      = { "name"  : "MGTREFCLK0P_216", "props" : {} }
  pinMap["mgtRefClkPPins[1]"]      = { "name"  : "MGTREFCLK1P_216", "props" : {} }
  pinMap["mgtRefClkNPins[0]"]      = { "name"  : "MGTREFCLK0N_216", "props" : {} }
  pinMap["mgtRefClkNPins[1]"]      = { "name"  : "MGTREFCLK1N_216", "props" : {} }
  revMap = dict()
  for i in pinMap.items():
    nam = i[1]["name"]
    prp = i[1]["props"]
    if   nam[:3] == "IO_":
      dfltProps = dfltIoProps
    elif nam[:4] == "MGTP":
      dfltProps = dfltMgtProps
    else:
      dfltProps = {}
    for k in dfltProps.items():
      try:
        prp[k[0]]
      except KeyError:
        prp[k[0]] = k[1]
    revMap[nam]=dict()
    revMap[nam]["port"]=i[0]
    revMap[nam]["props"]=prp
  return revMap 

mp=mkPinMap()
