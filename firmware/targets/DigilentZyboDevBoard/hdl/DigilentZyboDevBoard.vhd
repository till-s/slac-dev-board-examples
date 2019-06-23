-------------------------------------------------------------------------------
-- File       : DigilentZyboDevBoard.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2017-02-16
-------------------------------------------------------------------------------
-- Description: Example using 1000BASE-SX Protocol
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Example Project Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DigilentZyboDevBoard is
   generic (
      TPD_G         : time    := 1 ns;
      BUILD_INFO_G  : BuildInfoType;
      SIM_SPEEDUP_G : boolean := false;
      SIMULATION_G  : boolean := false;
      XVC_EN_G      : boolean := false;
      GEN_SYS_C     : natural := 0);
   port (
      DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
      DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
      DDR_cas_n         : inout STD_LOGIC;
      DDR_ck_n          : inout STD_LOGIC;
      DDR_ck_p          : inout STD_LOGIC;
      DDR_cke           : inout STD_LOGIC;
      DDR_cs_n          : inout STD_LOGIC;
      DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
      DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
      DDR_odt           : inout STD_LOGIC;
      DDR_ras_n         : inout STD_LOGIC;
      DDR_reset_n       : inout STD_LOGIC;
      DDR_we_n          : inout STD_LOGIC;
      FIXED_IO_ddr_vrn  : inout STD_LOGIC;
      FIXED_IO_ddr_vrp  : inout STD_LOGIC;
      FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
      FIXED_IO_ps_clk   : inout STD_LOGIC;
      FIXED_IO_ps_porb  : inout STD_LOGIC;
      FIXED_IO_ps_srstb : inout STD_LOGIC;
      btn               : in    STD_LOGIC_VECTOR ( 3 downto 0 );
      iic_scl_io        : inout STD_LOGIC;
      iic_sda_io        : inout STD_LOGIC;
      led               : out   STD_LOGIC_VECTOR ( 3 downto 0 );
      sw                : in    STD_LOGIC_VECTOR ( 3 downto 0 );
      pmodE             : inout STD_LOGIC_VECTOR ( 7 downto 0 )
   );
end DigilentZyboDevBoard;

architecture top_level of DigilentZyboDevBoard is

  constant NUM_IRQS_C  : natural          := 16;
  constant CLK_FREQ_C  : real             := 100.0E6;
component system_ps_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    M_AXI_GP0_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_arid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_arlen : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_arlock : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_arready : in STD_LOGIC;
    M_AXI_GP0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_arvalid : out STD_LOGIC;
    M_AXI_GP0_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_awid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_awlen : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_awlock : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_awready : in STD_LOGIC;
    M_AXI_GP0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_awvalid : out STD_LOGIC;
    M_AXI_GP0_bid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_bready : out STD_LOGIC;
    M_AXI_GP0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_bvalid : in STD_LOGIC;
    M_AXI_GP0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_rid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_rlast : in STD_LOGIC;
    M_AXI_GP0_rready : out STD_LOGIC;
    M_AXI_GP0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_rvalid : in STD_LOGIC;
    M_AXI_GP0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_wid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_wlast : out STD_LOGIC;
    M_AXI_GP0_wready : in STD_LOGIC;
    M_AXI_GP0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_wvalid : out STD_LOGIC;
    axiClk : out STD_LOGIC;
    axiRstN : out STD_LOGIC;
    iic_scl_io : inout STD_LOGIC;
    iic_sda_io : inout STD_LOGIC
  );
end component system_ps_wrapper;
component system_wrapper is
  port (
    AXIL_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIL_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIL_arready : in STD_LOGIC;
    AXIL_arvalid : out STD_LOGIC;
    AXIL_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIL_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIL_awready : in STD_LOGIC;
    AXIL_awvalid : out STD_LOGIC;
    AXIL_bready : out STD_LOGIC;
    AXIL_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIL_bvalid : in STD_LOGIC;
    AXIL_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIL_rready : out STD_LOGIC;
    AXIL_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIL_rvalid : in STD_LOGIC;
    AXIL_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIL_wready : in STD_LOGIC;
    AXIL_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    AXIL_wvalid : out STD_LOGIC;
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    axiClk : out STD_LOGIC;
    axiRstN : out STD_LOGIC;
    iic_scl_io : inout STD_LOGIC;
    iic_sda_io : inout STD_LOGIC
  );
end component system_wrapper;
  component ProcessingSystem is
  port (
    ENET0_PTP_DELAY_REQ_RX : OUT STD_LOGIC;
    ENET0_PTP_DELAY_REQ_TX : OUT STD_LOGIC;
    ENET0_PTP_PDELAY_REQ_RX : OUT STD_LOGIC;
    ENET0_PTP_PDELAY_REQ_TX : OUT STD_LOGIC;
    ENET0_PTP_PDELAY_RESP_RX : OUT STD_LOGIC;
    ENET0_PTP_PDELAY_RESP_TX : OUT STD_LOGIC;
    ENET0_PTP_SYNC_FRAME_RX : OUT STD_LOGIC;
    ENET0_PTP_SYNC_FRAME_TX : OUT STD_LOGIC;
    ENET0_SOF_RX : OUT STD_LOGIC;
    ENET0_SOF_TX : OUT STD_LOGIC;
    GPIO_I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    GPIO_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    GPIO_T : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    I2C0_SDA_I : IN STD_LOGIC;
    I2C0_SDA_O : OUT STD_LOGIC;
    I2C0_SDA_T : OUT STD_LOGIC;
    I2C0_SCL_I : IN STD_LOGIC;
    I2C0_SCL_O : OUT STD_LOGIC;
    I2C0_SCL_T : OUT STD_LOGIC;
    SDIO0_WP : IN STD_LOGIC;
    USB0_PORT_INDCTL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    USB0_VBUS_PWRSELECT : OUT STD_LOGIC;
    USB0_VBUS_PWRFAULT : IN STD_LOGIC;
    M_AXI_GP0_ARVALID : OUT STD_LOGIC;
    M_AXI_GP0_AWVALID : OUT STD_LOGIC;
    M_AXI_GP0_BREADY : OUT STD_LOGIC;
    M_AXI_GP0_RREADY : OUT STD_LOGIC;
    M_AXI_GP0_WLAST : OUT STD_LOGIC;
    M_AXI_GP0_WVALID : OUT STD_LOGIC;
    M_AXI_GP0_ARID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    M_AXI_GP0_AWID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    M_AXI_GP0_WID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    M_AXI_GP0_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_GP0_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_GP0_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_GP0_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_GP0_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_GP0_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_GP0_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_GP0_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_ARLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_AWLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_GP0_ACLK : IN STD_LOGIC;
    M_AXI_GP0_ARREADY : IN STD_LOGIC;
    M_AXI_GP0_AWREADY : IN STD_LOGIC;
    M_AXI_GP0_BVALID : IN STD_LOGIC;
    M_AXI_GP0_RLAST : IN STD_LOGIC;
    M_AXI_GP0_RVALID : IN STD_LOGIC;
    M_AXI_GP0_WREADY : IN STD_LOGIC;
    M_AXI_GP0_BID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    M_AXI_GP0_RID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    M_AXI_GP0_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_GP0_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    IRQ_F2P : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    FCLK_CLK0 : OUT STD_LOGIC;
    FCLK_RESET0_N : OUT STD_LOGIC;
    MIO : INOUT STD_LOGIC_VECTOR(53 DOWNTO 0);
    DDR_CAS_n : INOUT STD_LOGIC;
    DDR_CKE : INOUT STD_LOGIC;
    DDR_Clk_n : INOUT STD_LOGIC;
    DDR_Clk : INOUT STD_LOGIC;
    DDR_CS_n : INOUT STD_LOGIC;
    DDR_DRSTB : INOUT STD_LOGIC;
    DDR_ODT : INOUT STD_LOGIC;
    DDR_RAS_n : INOUT STD_LOGIC;
    DDR_WEB : INOUT STD_LOGIC;
    DDR_BankAddr : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    DDR_Addr : INOUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    DDR_VRN : INOUT STD_LOGIC;
    DDR_VRP : INOUT STD_LOGIC;
    DDR_DM : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    DDR_DQ : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DDR_DQS_n : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    DDR_DQS : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    PS_SRSTB : INOUT STD_LOGIC;
    PS_CLK : INOUT STD_LOGIC;
    PS_PORB : INOUT STD_LOGIC
  );
  end component ProcessingSystem;

   constant AXIS_SIZE_C : positive         := 1;

   constant AXIS_WIDTH_C    : positive     := 4;
   constant FIFO_DEPTH_C    : natural      := 0;

   signal   sysClk          : sl;
   signal   sysRst          : sl;
   signal   sysRstN         : sl;

   signal   appIrqs         : slv(7 downto 0) := (others => '0');

   constant IRQ_MAX_C       : natural := ite( NUM_IRQS_C > 8, 8, NUM_IRQS_C );

   signal   gpioI, gpioO, gpioT : slv(31 downto 0);

   signal   iicSclI, iicSclO, iicSclT : sl;
   signal   iicSdaI, iicSdaO, iicSdaT : sl;


   signal   cpuIrqs         : slv(NUM_IRQS_C - 1 downto 0) := (others => '0');

   signal   axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal   axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal   axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal   axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;

   signal   axiWriteMaster  : AxiWriteMasterType     := AXI_WRITE_MASTER_INIT_C;
   signal   axiReadMaster   : AxiReadMasterType      := AXI_READ_MASTER_INIT_C;
   signal   axiWriteSlave   : AxiWriteSlaveType      := AXI_WRITE_SLAVE_INIT_C;
   signal   axiReadSlave    : AxiReadSlaveType       := AXI_READ_SLAVE_INIT_C;

   signal   cnt             : unsigned(25 downto 0) := (others => '0');
   
   constant GEN_I_C   : boolean := false;
   
begin

   gpioI  <= (others => '0');
  

   sysRst <= not sysRstN;

   G_IICBUF : if ( GEN_SYS_C = 0 ) generate 
   U_Scl : component IOBUF
      port map (
         IO => iic_scl_io,
         I  => iicSclO,
         O  => iicSclI,
         T  => iicSclT
      );

   U_Sda : component IOBUF
      port map (
         IO => iic_sda_io,
         I  => iicSdaO,
         O  => iicSdaI,
         T  => iicSdaT
      );
   end generate;
   
   GEN_SYS_1 : if (GEN_SYS_C = 1) generate
   U_Sys : component system_wrapper
      port map (
         DDR_addr(14 downto 0)         => DDR_addr(14 downto 0),
         DDR_ba(2 downto 0)            => DDR_ba(2 downto 0),
         DDR_cas_n                     => DDR_cas_n,
         DDR_cke                       => DDR_cke,
         DDR_cs_n                      => DDR_cs_n,
         DDR_ck_p                      => DDR_ck_p,
         DDR_ck_n                      => DDR_ck_n,
         DDR_dm(3 downto 0)            => DDR_dm(3 downto 0),
         DDR_dq(31 downto 0)           => DDR_dq(31 downto 0),
         DDR_dqs_p(3 downto 0)         => DDR_dqs_p(3 downto 0),
         DDR_dqs_n(3 downto 0)         => DDR_dqs_n(3 downto 0),
         DDR_reset_n                   => DDR_reset_n,
         DDR_odt                       => DDR_odt,
         DDR_ras_n                     => DDR_ras_n,
         FIXED_IO_ddr_vrn              => FIXED_IO_ddr_vrn,
         FIXED_IO_ddr_vrp              => FIXED_IO_ddr_vrp,
         DDR_we_n                      => DDR_we_n,
         axiClk                        => sysClk,
         axiRstN                       => sysRstN,
         iic_scl_io                    => iic_scl_io,
         iic_sda_io                    => iic_sda_io,
         -- IRQ_F2P                       => cpuIrqs,
         FIXED_IO_mio                  => FIXED_IO_mio,
         AXIL_ARADDR(31 downto 0) => axilReadMaster.araddr(31 downto 0),
         AXIL_ARPROT(2 downto 0)  => axilReadMaster.arprot,
         AXIL_ARREADY             => axilReadSlave.arready,
         AXIL_ARVALID             => axilReadMaster.arvalid,
         AXIL_AWADDR              => axilWriteMaster.awaddr(31 downto 0),
         AXIL_AWPROT(2 downto 0)  => axilWriteMaster.awprot,
         AXIL_AWREADY             => axilWriteSlave.awready,
         AXIL_AWVALID             => axilWriteMaster.awvalid,
         AXIL_BREADY              => axilWriteMaster.bready,
         AXIL_BRESP(1 downto 0)   => axilWriteSlave.bresp,
         AXIL_BVALID              => axilWriteSlave.bvalid,
         AXIL_RDATA(31 downto 0)  => axilReadSlave.rdata(31 downto 0),
         AXIL_RREADY              => axilReadMaster.rready,
         AXIL_RRESP(1 downto 0)   => axilReadSlave.rresp,
         AXIL_RVALID              => axilReadSlave.rvalid,
         AXIL_WDATA(31 downto 0)  => axilWriteMaster.wdata(31 downto 0),
         AXIL_WREADY              => axilWriteSlave.wready,
         AXIL_WSTRB(3 downto 0)   => axilWriteMaster.wstrb(3 downto 0),
         AXIL_WVALID              => axilWriteMaster.wvalid,
         FIXED_IO_PS_CLK          => FIXED_IO_ps_clk,
         FIXED_IO_PS_PORB         => FIXED_IO_ps_porb,
         FIXED_IO_PS_SRSTB        => FIXED_IO_ps_srstb
      );
   end generate;
   
   NO_GEN_SYS : if ( GEN_SYS_C = 0 ) generate
     U_Sys : component ProcessingSystem
      port map (
         DDR_Addr(14 downto 0)         => DDR_addr(14 downto 0),
         DDR_BankAddr(2 downto 0)      => DDR_ba(2 downto 0),
         DDR_CAS_n                     => DDR_cas_n,
         DDR_CKE                       => DDR_cke,
         DDR_CS_n                      => DDR_cs_n,
         DDR_Clk                       => DDR_ck_p,
         DDR_Clk_n                     => DDR_ck_n,
         DDR_DM(3 downto 0)            => DDR_dm(3 downto 0),
         DDR_DQ(31 downto 0)           => DDR_dq(31 downto 0),
         DDR_DQS(3 downto 0)           => DDR_dqs_p(3 downto 0),
         DDR_DQS_n(3 downto 0)         => DDR_dqs_n(3 downto 0),
         DDR_DRSTB                     => DDR_reset_n,
         DDR_ODT                       => DDR_odt,
         DDR_RAS_n                     => DDR_ras_n,
         DDR_VRN                       => FIXED_IO_ddr_vrn,
         DDR_VRP                       => FIXED_IO_ddr_vrp,
         DDR_WEB                       => DDR_we_n,
         ENET0_PTP_DELAY_REQ_RX        => open,
         ENET0_PTP_DELAY_REQ_TX        => open,
         ENET0_PTP_PDELAY_REQ_RX       => open,
         ENET0_PTP_PDELAY_REQ_TX       => open,
         ENET0_PTP_PDELAY_RESP_RX      => open,
         ENET0_PTP_PDELAY_RESP_TX      => open,
         ENET0_PTP_SYNC_FRAME_RX       => open,
         ENET0_PTP_SYNC_FRAME_TX       => open,
         ENET0_SOF_RX                  => open,
         ENET0_SOF_TX                  => open,
         FCLK_CLK0                     => sysClk,
         FCLK_RESET0_N                 => sysRstN,
         GPIO_I(31 downto 0)           => gpioI,
         GPIO_O(31 downto 0)           => gpioO,
         GPIO_T(31 downto 0)           => gpioT,
         I2C0_SCL_I                    => iicSclI,
         I2C0_SCL_O                    => iicSclO,
         I2C0_SCL_T                    => iicSclT,
         I2C0_SDA_I                    => iicSdaI,
         I2C0_SDA_O                    => iicSdaO,
         I2C0_SDA_T                    => iicSdaT,
         IRQ_F2P                       => cpuIrqs,
         MIO(53 downto 0)              => FIXED_IO_mio,
         M_AXI_GP0_ACLK                => sysClk,
         M_AXI_GP0_ARADDR(31 downto 0) => axiReadMaster.araddr(31 downto 0),
         M_AXI_GP0_ARBURST(1 downto 0) => axiReadMaster.arburst,
         M_AXI_GP0_ARCACHE(3 downto 0) => axiReadMaster.arcache,
         M_AXI_GP0_ARID(11 downto 0)   => axiReadMaster.arid(11 downto 0),
         M_AXI_GP0_ARLEN(3 downto 0)   => axiReadMaster.arlen(3 downto 0),
         M_AXI_GP0_ARLOCK(1 downto 0)  => axiReadMaster.arlock,
         M_AXI_GP0_ARPROT(2 downto 0)  => axiReadMaster.arprot,
         M_AXI_GP0_ARQOS(3 downto 0)   => axiReadMaster.arqos,
         M_AXI_GP0_ARREADY             => axiReadSlave.arready,
         M_AXI_GP0_ARSIZE(2 downto 0)  => axiReadMaster.arsize,
         M_AXI_GP0_ARVALID             => axiReadMaster.arvalid,
         M_AXI_GP0_AWADDR(31 downto 0) => axiWriteMaster.awaddr(31 downto 0),
         M_AXI_GP0_AWBURST(1 downto 0) => axiWriteMaster.awburst,
         M_AXI_GP0_AWCACHE(3 downto 0) => axiWriteMaster.awcache,
         M_AXI_GP0_AWID(11 downto 0)   => axiWriteMaster.awid(11 downto 0),
         M_AXI_GP0_AWLEN(3 downto 0)   => axiWriteMaster.awlen(3 downto 0),
         M_AXI_GP0_AWLOCK(1 downto 0)  => axiWriteMaster.awlock,
         M_AXI_GP0_AWPROT(2 downto 0)  => axiWriteMaster.awprot,
         M_AXI_GP0_AWQOS(3 downto 0)   => axiWriteMaster.awqos,
         M_AXI_GP0_AWREADY             => axiWriteSlave.awready,
         M_AXI_GP0_AWSIZE(2 downto 0)  => axiWriteMaster.awsize,
         M_AXI_GP0_AWVALID             => axiWriteMaster.awvalid,
         M_AXI_GP0_BID(11 downto 0)    => axiWriteSlave.bid(11 downto 0),
         M_AXI_GP0_BREADY              => axiWriteMaster.bready,
         M_AXI_GP0_BRESP(1 downto 0)   => axiWriteSlave.bresp,
         M_AXI_GP0_BVALID              => axiWriteSlave.bvalid,
         M_AXI_GP0_RDATA(31 downto 0)  => axiReadSlave.rdata(31 downto 0),
         M_AXI_GP0_RID(11 downto 0)    => axiReadSlave.rid(11 downto 0),
         M_AXI_GP0_RLAST               => axiReadSlave.rlast,
         M_AXI_GP0_RREADY              => axiReadMaster.rready,
         M_AXI_GP0_RRESP(1 downto 0)   => axiReadSlave.rresp,
         M_AXI_GP0_RVALID              => axiReadSlave.rvalid,
         M_AXI_GP0_WDATA(31 downto 0)  => axiWriteMaster.wdata(31 downto 0),
         M_AXI_GP0_WID(11 downto 0)    => axiWriteMaster.wid(11 downto 0),
         M_AXI_GP0_WLAST               => axiWriteMaster.wlast,
         M_AXI_GP0_WREADY              => axiWriteSlave.wready,
         M_AXI_GP0_WSTRB(3 downto 0)   => axiWriteMaster.wstrb(3 downto 0),
         M_AXI_GP0_WVALID              => axiWriteMaster.wvalid,
         PS_CLK                        => FIXED_IO_ps_clk,
         PS_PORB                       => FIXED_IO_ps_porb,
         PS_SRSTB                      => FIXED_IO_ps_srstb,
         SDIO0_WP                      => '0',
         USB0_PORT_INDCTL              => open,
         USB0_VBUS_PWRFAULT            => '0',
         USB0_VBUS_PWRSELECT           => open
      );
      
   end generate;
      
   GEN_INTERCONN : if ( GEN_I_C and (GEN_SYS_C = 2) ) generate
      U_A2A : entity work.Axi4ToAxilSurfWrapper
         port map (
            axiClk                     => sysClk,
            axiRst                     => sysRst,

            axiReadMaster              => axiReadMaster,
            axiReadSlave               => axiReadSlave,
            axiWriteMaster             => axiWriteMaster,
            axiWriteSlave              => axiWriteSlave,

            axilReadMaster             => axilReadMaster,
            axilReadSlave              => axilReadSlave,
            axilWriteMaster            => axilWriteMaster,
            axilWriteSlave             => axilWriteSlave
        );
   end generate;
   
   GEN_BOTH : if ( GEN_SYS_C = 2 ) generate
       U_Sys : entity work.system_ps_wrapper
      port map (
         DDR_Addr(14 downto 0)         => DDR_addr(14 downto 0),
         DDR_BA(2 downto 0)            => DDR_ba(2 downto 0),
         DDR_CAS_n                     => DDR_cas_n,
         DDR_CKE                       => DDR_cke,
         DDR_CS_n                      => DDR_cs_n,
         DDR_Ck_p                      => DDR_ck_p,
         DDR_Ck_n                      => DDR_ck_n,
         DDR_DM(3 downto 0)            => DDR_dm(3 downto 0),
         DDR_DQ(31 downto 0)           => DDR_dq(31 downto 0),
         DDR_DQS_p(3 downto 0)         => DDR_dqs_p(3 downto 0),
         DDR_DQS_n(3 downto 0)         => DDR_dqs_n(3 downto 0),
         DDR_reset_n                   => DDR_reset_n,
         DDR_ODT                       => DDR_odt,
         DDR_RAS_n                     => DDR_ras_n,
         FIXED_IO_ddr_vrn              => FIXED_IO_ddr_vrn,
         FIXED_IO_ddr_vrp              => FIXED_IO_ddr_vrp,
         DDR_WE_n                      => DDR_we_n,
         axiClk                        => sysClk,
         axiRstN                       => sysRstN,
         M_AXI_GP0_ARADDR(31 downto 0) => axiReadMaster.araddr(31 downto 0),
         M_AXI_GP0_ARBURST(1 downto 0) => axiReadMaster.arburst,
         M_AXI_GP0_ARCACHE(3 downto 0) => axiReadMaster.arcache,
         M_AXI_GP0_ARID(11 downto 0)   => axiReadMaster.arid(11 downto 0),
         M_AXI_GP0_ARLEN(3 downto 0)   => axiReadMaster.arlen(3 downto 0),
         M_AXI_GP0_ARLOCK(1 downto 0)  => axiReadMaster.arlock,
         M_AXI_GP0_ARPROT(2 downto 0)  => axiReadMaster.arprot,
         M_AXI_GP0_ARQOS(3 downto 0)   => axiReadMaster.arqos,
         M_AXI_GP0_ARREADY             => axiReadSlave.arready,
         M_AXI_GP0_ARSIZE(2 downto 0)  => axiReadMaster.arsize,
         M_AXI_GP0_ARVALID             => axiReadMaster.arvalid,
         M_AXI_GP0_AWADDR(31 downto 0) => axiWriteMaster.awaddr(31 downto 0),
         M_AXI_GP0_AWBURST(1 downto 0) => axiWriteMaster.awburst,
         M_AXI_GP0_AWCACHE(3 downto 0) => axiWriteMaster.awcache,
         M_AXI_GP0_AWID(11 downto 0)   => axiWriteMaster.awid(11 downto 0),
         M_AXI_GP0_AWLEN(3 downto 0)   => axiWriteMaster.awlen(3 downto 0),
         M_AXI_GP0_AWLOCK(1 downto 0)  => axiWriteMaster.awlock,
         M_AXI_GP0_AWPROT(2 downto 0)  => axiWriteMaster.awprot,
         M_AXI_GP0_AWQOS(3 downto 0)   => axiWriteMaster.awqos,
         M_AXI_GP0_AWREADY             => axiWriteSlave.awready,
         M_AXI_GP0_AWSIZE(2 downto 0)  => axiWriteMaster.awsize,
         M_AXI_GP0_AWVALID             => axiWriteMaster.awvalid,
         M_AXI_GP0_BID(11 downto 0)    => axiWriteSlave.bid(11 downto 0),
         M_AXI_GP0_BREADY              => axiWriteMaster.bready,
         M_AXI_GP0_BRESP(1 downto 0)   => axiWriteSlave.bresp,
         M_AXI_GP0_BVALID              => axiWriteSlave.bvalid,
         M_AXI_GP0_RDATA(31 downto 0)  => axiReadSlave.rdata(31 downto 0),
         M_AXI_GP0_RID(11 downto 0)    => axiReadSlave.rid(11 downto 0),
         M_AXI_GP0_RLAST               => axiReadSlave.rlast,
         M_AXI_GP0_RREADY              => axiReadMaster.rready,
         M_AXI_GP0_RRESP(1 downto 0)   => axiReadSlave.rresp,
         M_AXI_GP0_RVALID              => axiReadSlave.rvalid,
         M_AXI_GP0_WDATA(31 downto 0)  => axiWriteMaster.wdata(31 downto 0),
         M_AXI_GP0_WID(11 downto 0)    => axiWriteMaster.wid(11 downto 0),
         M_AXI_GP0_WLAST               => axiWriteMaster.wlast,
         M_AXI_GP0_WREADY              => axiWriteSlave.wready,
         M_AXI_GP0_WSTRB(3 downto 0)   => axiWriteMaster.wstrb(3 downto 0),
         M_AXI_GP0_WVALID              => axiWriteMaster.wvalid,
         FIXED_IO_PS_CLK               => FIXED_IO_ps_clk,
         FIXED_IO_PS_PORB              => FIXED_IO_ps_porb,
         FIXED_IO_PS_SRSTB             => FIXED_IO_ps_srstb,
         iic_scl_io                    => iic_scl_io,
         iic_sda_io                    => iic_sda_io
   );
      
   end generate;
   
   GEN_A2A : if ( not GEN_I_C ) generate
   U_A2A : entity work.AxiToAxiLite
      generic map (
         TPD_G => TPD_G
      )
      port map (
         axiClk               => sysClk,
         axiClkRst            => sysRst,
         
         axiReadMaster        => axiReadMaster,
         axiReadSlave         => axiReadSlave,
         axiWriteMaster       => axiWriteMaster,
         axiWriteSlave        => axiWriteSlave,
         axilReadMaster       => axilReadMaster,
         axilReadSlave        => axilReadSlave,
         axilWriteMaster      => axilWriteMaster,
         axilWriteSlave       => axilWriteSlave
      );
   end generate;

   -------------------
   -- AXI-Lite Modules
   -------------------
   U_Reg : entity work.AppCore
      generic map (
         TPD_G                => TPD_G,
         BUILD_INFO_G         => BUILD_INFO_G,
         XIL_DEVICE_G         => "7SERIES",
         AXIL_BASE_ADDR_G     => x"40000000",
         APP_TYPE_G           => "NONE", -- no ethernet
         AXIL_CLK_FREQUENCY_G => CLK_FREQ_C,
         TPGMINI_G            => false,
         GEN_TIMING_G         => false
      )
      port map (
         -- Clock and Reset
         clk                  => sysClk,
         rst                  => sysRst,
         -- AXI-Lite interface
         sAxilWriteMaster     => axilWriteMaster,
         sAxilWriteSlave      => axilWriteSlave,
         sAxilReadMaster      => axilReadMaster,
         sAxilReadSlave       => axilReadSlave,
         -- ADC Ports
         vPIn                 => '0',
         vNIn                 => '1',
         irqOut               => appIrqs
      );

--   GEN_HACK_1 : if (true) generate
--      U_EMPTY : entity work.AxiLiteRegs
--         generic map (
--            TPD_G           => TPD_G,
--            NUM_WRITE_REG_G => 32,
--            NUM_READ_REG_G  => 32
--         )
--         port map (
--            axiClk          => sysClk,
--            axiClkRst       => sysRst,
--            axiReadMaster   => axilReadMaster,
--            axiReadSlave    => axilReadSlave,
--            axiWriteMaster  => axilWriteMaster,
--            axiWriteSlave   => axilWriteSlave,
--            writeRegister   => open,
--            readRegister    => (others => x"dead_beef")
--         );
--   end generate;

   cpuIrqs(IRQ_MAX_C - 1 downto 0) <= appIrqs(IRQ_MAX_C - 1 downto 0);

   P_CNT : process (sysClk) is
   begin
      if ( rising_edge( sysClk ) ) then
         cnt <= cnt + 1;
      end if;
   end process P_CNT;

   ----------------
   -- Misc. Signals
   ----------------
   led(3) <= '0';
   led(2) <= '0';
   led(1) <= '0';
   led(0) <= cnt(25);

end top_level;
