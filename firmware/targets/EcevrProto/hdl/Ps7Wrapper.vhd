library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity Ps7Wrapper is
   port (
      DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
      DDR_ba            : inout STD_LOGIC_VECTOR (  2 downto 0 );
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

      sysClk            : out   std_logic;
      sysRst            : out   std_logic
   );
end entity Ps7Wrapper;

architecture Impl of Ps7Wrapper is

   component processing_system7_0
      PORT (
         SPI0_SCLK_I : in STD_LOGIC;
         SPI0_SCLK_O : out STD_LOGIC;
         SPI0_SCLK_T : out STD_LOGIC;
         SPI0_MOSI_I : in STD_LOGIC;
         SPI0_MOSI_O : out STD_LOGIC;
         SPI0_MOSI_T : out STD_LOGIC;
         SPI0_MISO_I : in STD_LOGIC;
         SPI0_MISO_O : out STD_LOGIC;
         SPI0_MISO_T : out STD_LOGIC;
         SPI0_SS_I : in STD_LOGIC;
         SPI0_SS_O : out STD_LOGIC;
         SPI0_SS1_O : out STD_LOGIC;
         SPI0_SS2_O : out STD_LOGIC;
         SPI0_SS_T : out STD_LOGIC;
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
         FCLK_RESET1_N : OUT STD_LOGIC;
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
   END component processing_system7_0;
   
   signal sysRstN   : std_logic;
   signal sysClkLoc : std_logic;

begin

   sysRst <= not sysRstN;
   sysClk <= sysClkLoc;

   U_Ps7 : component processing_system7_0
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
         FCLK_CLK0                     => sysClkLoc,
         FCLK_RESET0_N                 => sysRstN,
         FCLK_RESET1_N                 => open,
         IRQ_F2P                       => (others => '0'),
         MIO(53 downto 0)              => FIXED_IO_mio,
         M_AXI_GP0_ACLK                => sysClkLoc,
         M_AXI_GP0_ARADDR(31 downto 0) => open,
         M_AXI_GP0_ARBURST(1 downto 0) => open,
         M_AXI_GP0_ARCACHE(3 downto 0) => open,
         M_AXI_GP0_ARID(11 downto 0)   => open,
         M_AXI_GP0_ARLEN(3 downto 0)   => open,
         M_AXI_GP0_ARLOCK(1 downto 0)  => open,
         M_AXI_GP0_ARPROT(2 downto 0)  => open,
         M_AXI_GP0_ARQOS(3 downto 0)   => open,
         M_AXI_GP0_ARREADY             => '1',
         M_AXI_GP0_ARSIZE(2 downto 0)  => open,
         M_AXI_GP0_ARVALID             => open,
         M_AXI_GP0_AWADDR(31 downto 0) => open,
         M_AXI_GP0_AWBURST(1 downto 0) => open,
         M_AXI_GP0_AWCACHE(3 downto 0) => open,
         M_AXI_GP0_AWID(11 downto 0)   => open,
         M_AXI_GP0_AWLEN(3 downto 0)   => open,
         M_AXI_GP0_AWLOCK(1 downto 0)  => open,
         M_AXI_GP0_AWPROT(2 downto 0)  => open,
         M_AXI_GP0_AWQOS(3 downto 0)   => open,
         M_AXI_GP0_AWREADY             => '1',
         M_AXI_GP0_AWSIZE(2 downto 0)  => open,
         M_AXI_GP0_AWVALID             => open,
         M_AXI_GP0_BID(11 downto 0)    => (others => '0'),
         M_AXI_GP0_BREADY              => open,
         M_AXI_GP0_BRESP(1 downto 0)   => "11",
         M_AXI_GP0_BVALID              => '0',
         M_AXI_GP0_RDATA(31 downto 0)  => x"0000_0000",
         M_AXI_GP0_RID(11 downto 0)    => (others => '0'),
         M_AXI_GP0_RLAST               => '1',
         M_AXI_GP0_RREADY              => open,
         M_AXI_GP0_RRESP(1 downto 0)   => "11",
         M_AXI_GP0_RVALID              => '0',
         M_AXI_GP0_WDATA(31 downto 0)  => open,
         M_AXI_GP0_WID(11 downto 0)    => open,
         M_AXI_GP0_WLAST               => open,
         M_AXI_GP0_WREADY              => '1',
         M_AXI_GP0_WSTRB(3 downto 0)   => open,
         M_AXI_GP0_WVALID              => open,
         PS_CLK                        => FIXED_IO_ps_clk,
         PS_PORB                       => FIXED_IO_ps_porb,
         PS_SRSTB                      => FIXED_IO_ps_srstb,
         USB0_PORT_INDCTL              => open,
         USB0_VBUS_PWRFAULT            => '0',
         USB0_VBUS_PWRSELECT           => open,
         SPI0_SCLK_I                   => '0',
         SPI0_SCLK_O                   => open,
         SPI0_SCLK_T                   => open,
         SPI0_MOSI_I                   => '0',
         SPI0_MOSI_O                   => open,
         SPI0_MOSI_T                   => open,
         SPI0_MISO_I                   => '0',
         SPI0_MISO_O                   => open,
         SPI0_MISO_T                   => open,
         SPI0_SS_I                     => '1',
         SPI0_SS_O                     => open,
         SPI0_SS1_O                    => open,
         SPI0_SS2_O                    => open,
         SPI0_SS_T                     => open
      );
end architecture Impl;
