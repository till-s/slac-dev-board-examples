proc mkNormFlist { patl } {
  global origin_dir

  set rv [list]

  foreach f $patl {
    lappend rv [file normalize "${origin_dir}/../$f"]
  }

  return $rv
}

set files [list \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCBasicTypesPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/IPAddrConfigPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/DeviceDna7.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/AddressGenerator.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254Pkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Udp2BusPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/Bus2DRP.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/Bus2I2cStreamIF.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/Bus2SpiFlashIF.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/EEPROMContentPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/EEEmulPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254ESCPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/IlaWrappersPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EvrTxPDOPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_array_pkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_math_pkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/Evr320ConfigPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EEPROMConfigPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EEPROMConfigurator.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCMbxPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/StrmFrameBuf.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCEoERx.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCEoETx.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCFoEPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCFoE.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCRxMbxMux.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCSmRx.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCTxMbxBuf.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCTxMbxErr.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCTxMbxMux.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/ESCTxPDO.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EcEvrBspPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/SynchronizerBit.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/SynchronizerVec.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EcEvrBoardMap.vhd"] \
  [file normalize "${origin_dir}/../hdl/EcEvrProtoPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/FoE2SpiPkg.vhd"] \
  [file normalize "${origin_dir}/../hdl/gtp/TimingGtpPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/MicroUDPPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254Hbi.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Udp2BusMux.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254UdpBusPkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254ESC.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/MicroUDPRx.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/IPV4ChkSum.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/MicroUDPTx.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/MicroUDPIPMux.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Udp2Bus.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/StrmFifoSync.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254ESCWrapper.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_logic_pkg.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_sdp_ram.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_pulse_cc.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_async_fifo.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_simple_cc.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_status_cc.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_clk_meas.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EvrTxPDO.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/I2cProgrammer.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/StrmMux.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_bit_cc.vhd"] \
  [file normalize "${origin_dir}/../submodules/psi_common/hdl/psi_common_i2c_master.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/PsiI2cStreamIF.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/I2cWrapper.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/SpiBitShifter.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/FoE2Spi.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/SpiMonitor.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EcEvrWrapper.vhd"] \
  [file normalize "${origin_dir}/../hdl/gtp/TimingGtp_cpll_railing.vhd"] \
  [file normalize "${origin_dir}/../hdl/gtp/TimingGtp_common.vhd"] \
  [file normalize "${origin_dir}/../hdl/gtp/TimingGtpWrapper.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/IcapE2Reg.vhd"] \
  [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/PwmCore.vhd"] \
  [file normalize "${origin_dir}/../hdl/EcEvrProtoTop.vhd"] \
  [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Lan9254HbiImpl.vhd"] \
  [file normalize "${origin_dir}/../hdl/EcEvrProto.vhd"] \
]
add_files -norecurse -fileset [get_filesets sources_1] $files

#set evr_flavor "OPENEVR"
# Retrieve EVR flavor from generics
foreach pv [get_property generic [get_filesets sources_1]] {
  if { [regexp -expanded {(^EVR_FLAVOR_G=)(.*)} "$pv" m0 m1 m2] } {
    set _evr_flavor_ "$m2"
  }
}

if { ! [ string equal "${_evr_flavor_}" "OPENEVR" ] && ! [string equal "${_evr_flavor_}" "PSI" ] } {
	error "UNKNOWN EVR"
}

set _top_mod_ "[get_property top [get_filesets sources_1]]"


if { [string equal "${_evr_flavor_}" "OPENEVR"] } {
  set files [list \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/transceiver_pkg.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/evr_dc.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/evr_pkg.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/databuf_rx_dc.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/average.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/buf_bsram_inferred.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/delay_adjust.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/delay_measure_wnd.vhd"] \
   [file normalize "${origin_dir}/../submodules/mrf-openevr/vhdl/transceiver_dc.vhd"] \
   [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/OpenEvrUdp2BusWrapper.vhd"] \
   [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/EcEvrPulseGen.vhd"] \
   [file normalize "${origin_dir}/../submodules/lan9254-rtl-esc/hdl/Bus2BusAsync.vhd"] \
  ]
  add_files -norecurse -fileset [get_filesets sources_1] $files
}

if { [string equal "${_evr_flavor_}" "PSI"] } {
  set files [list \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/pulse_shaper_dly_cfg.vhd"] \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/evr320_pkg.vhd"] \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/evr320_dpram.vhd"] \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/evr320_buffer.vhd"] \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/evr320_timestamp.vhd"] \
    [file normalize "${origin_dir}/../submodules/evr320/hdl/evr320_decoder.vhd"] \
    [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/evr320_udp2bus.vhd"] \
    [file normalize "${origin_dir}/../submodules/ecevr-core/hdl/evr320_udp2bus_wrapper.vhd"] \
  ]
  add_files -norecurse -fileset [get_filesets sources_1] $files
}

source "${origin_dir}/../tcl/genIla256.tcl"
source "${origin_dir}/../tcl/genTimingGtp.tcl"

if { [ string equal "$_top_mod_" "TE0715Top" ] } {
  set files [list \
   [file normalize "${origin_dir}/../hdl/TE0715Top.vhd"] \
   [file normalize "${origin_dir}/../hdl/Ps7Wrapper.vhd"] \
  ]
  add_files -norecurse -fileset [get_filesets sources_1] $files

  source "${origin_dir}/../tcl/genPS7.tcl"

}

set fpat [list \
  "hdl/${_top_mod_}-clocks.xdc" \
]
if { [ string equal "$_evr_flavor_" "PSI" ] } {
  lappend fpat "hdl/${_top_mod_}-clock_groups.xdc"
}
lappend fpat "hdl/${_top_mod_}-io.xdc"

set files [mkNormFlist $fpat]
add_files -norecurse -fileset [get_filesets constrs_1] $files

set fpat [list \
  "hdl/${_top_mod_}-io_timing.xdc" \
]

if { [string equal "${_evr_flavor_}" "OPENEVR"] } {
  lappend fpat "submodules/mrf-openevr/vhdl/false_paths.xdc"
}

lappend fpat "hdl/EcEvrProto-false_paths.xdc"
lappend fpat "hdl/EcEvrProto-misc.xdc"
lappend fpat "hdl/dbg.xdc"

set files [mkNormFlist $fpat]

add_files -norecurse -fileset [get_filesets constrs_1] $files
foreach f $fpat {
  set_property used_in_synthesis false [get_files "*/$f"]
}

set fpat [list \
  "submodules/lan9254-rtl-esc/hdl/SynchronizerBit.xdc" \
  "submodules/lan9254-rtl-esc/hdl/SynchronizerVec.xdc" \
  "submodules/lan9254-rtl-esc/hdl/Bus2BusAsync.xdc" \
  "submodules/ecevr-core/hdl/EvrTxPDO.xdc" \
  "submodules/ecevr-core/hdl/EcEvrWrapper.xdc" \
]
set files [mkNormFlist $fpat]
add_files -norecurse -fileset [get_filesets constrs_1] $files
foreach f $fpat {
  set_property used_in_synthesis false [get_files "*/$f"]
  set_property SCOPED_TO_REF "[file rootname [file tail $f]]" [get_files "*/$f"]
}

set files [list \
  [file normalize "${origin_dir}/../tcl/genIla256.tcl"]\
  [file normalize "${origin_dir}/../tcl/genProject.tcl"] \
  [file normalize "${origin_dir}/../tcl/genPS7.tcl"] \
  [file normalize "${origin_dir}/../tcl/genTimingGtp.tcl"] \
  [file normalize "${origin_dir}/../tcl/sources.tcl"] \
  [file normalize "${origin_dir}/../tcl/appCheckAndTouchGitHashFile.tcl"] \
  [file normalize "${origin_dir}/../vivado/pre_synth_run.tcl"] \
  [file normalize "${origin_dir}/../vivado/pre_bitstream.tcl"] \
]
add_files -norecurse -fileset [get_filesets utils_1] $files

source "${origin_dir}/../tcl/appCheckAndTouchGitHashFile.tcl"
appCheckAndTouchGitHashFile "${origin_dir}/../hdl/AppGitHashPkg.vhd"

add_files -norecurse -fileset [get_filesets sources_1] [list [file normalize "${origin_dir}/../hdl/AppGitHashPkg.vhd"]]
