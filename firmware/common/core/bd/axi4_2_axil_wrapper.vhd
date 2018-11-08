--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Wed Nov  7 23:13:30 2018
--Host        : rdsrv222 running 64-bit Red Hat Enterprise Linux Server release 6.10 (Santiago)
--Command     : generate_target axi4_2_axil_wrapper.bd
--Design      : axi4_2_axil_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity axi4_2_axil_wrapper is
  port (
    axi4_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arready : out STD_LOGIC;
    axi4_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arvalid : in STD_LOGIC;
    axi4_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awready : out STD_LOGIC;
    axi4_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awvalid : in STD_LOGIC;
    axi4_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_bready : in STD_LOGIC;
    axi4_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_bvalid : out STD_LOGIC;
    axi4_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_rid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_rlast : out STD_LOGIC;
    axi4_rready : in STD_LOGIC;
    axi4_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_rvalid : out STD_LOGIC;
    axi4_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_wlast : in STD_LOGIC;
    axi4_wready : out STD_LOGIC;
    axi4_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_wvalid : in STD_LOGIC;
    axiClk : in STD_LOGIC;
    axiRstN : in STD_LOGIC;
    axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    axil_arready : in STD_LOGIC;
    axil_arvalid : out STD_LOGIC;
    axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    axil_awready : in STD_LOGIC;
    axil_awvalid : out STD_LOGIC;
    axil_bready : out STD_LOGIC;
    axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axil_bvalid : in STD_LOGIC;
    axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_rready : out STD_LOGIC;
    axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axil_rvalid : in STD_LOGIC;
    axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_wready : in STD_LOGIC;
    axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    axil_wvalid : out STD_LOGIC
  );
end axi4_2_axil_wrapper;

architecture STRUCTURE of axi4_2_axil_wrapper is
  component axi4_2_axil is
  port (
    axiClk : in STD_LOGIC;
    axiRstN : in STD_LOGIC;
    axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    axil_awvalid : out STD_LOGIC;
    axil_awready : in STD_LOGIC;
    axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    axil_wvalid : out STD_LOGIC;
    axil_wready : in STD_LOGIC;
    axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axil_bvalid : in STD_LOGIC;
    axil_bready : out STD_LOGIC;
    axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    axil_arvalid : out STD_LOGIC;
    axil_arready : in STD_LOGIC;
    axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axil_rvalid : in STD_LOGIC;
    axil_rready : out STD_LOGIC;
    axi4_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awvalid : in STD_LOGIC;
    axi4_awready : out STD_LOGIC;
    axi4_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_wlast : in STD_LOGIC;
    axi4_wvalid : in STD_LOGIC;
    axi4_wready : out STD_LOGIC;
    axi4_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_bvalid : out STD_LOGIC;
    axi4_bready : in STD_LOGIC;
    axi4_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arvalid : in STD_LOGIC;
    axi4_arready : out STD_LOGIC;
    axi4_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_rlast : out STD_LOGIC;
    axi4_rvalid : out STD_LOGIC;
    axi4_rready : in STD_LOGIC;
    axi4_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    axi4_rid : out STD_LOGIC_VECTOR ( 11 downto 0 )
  );
  end component axi4_2_axil;
begin
axi4_2_axil_i: component axi4_2_axil
     port map (
      axi4_araddr(31 downto 0) => axi4_araddr(31 downto 0),
      axi4_arburst(1 downto 0) => axi4_arburst(1 downto 0),
      axi4_arcache(3 downto 0) => axi4_arcache(3 downto 0),
      axi4_arid(11 downto 0) => axi4_arid(11 downto 0),
      axi4_arlen(7 downto 0) => axi4_arlen(7 downto 0),
      axi4_arlock(0) => axi4_arlock(0),
      axi4_arprot(2 downto 0) => axi4_arprot(2 downto 0),
      axi4_arqos(3 downto 0) => axi4_arqos(3 downto 0),
      axi4_arready => axi4_arready,
      axi4_arregion(3 downto 0) => axi4_arregion(3 downto 0),
      axi4_arsize(2 downto 0) => axi4_arsize(2 downto 0),
      axi4_arvalid => axi4_arvalid,
      axi4_awaddr(31 downto 0) => axi4_awaddr(31 downto 0),
      axi4_awburst(1 downto 0) => axi4_awburst(1 downto 0),
      axi4_awcache(3 downto 0) => axi4_awcache(3 downto 0),
      axi4_awid(11 downto 0) => axi4_awid(11 downto 0),
      axi4_awlen(7 downto 0) => axi4_awlen(7 downto 0),
      axi4_awlock(0) => axi4_awlock(0),
      axi4_awprot(2 downto 0) => axi4_awprot(2 downto 0),
      axi4_awqos(3 downto 0) => axi4_awqos(3 downto 0),
      axi4_awready => axi4_awready,
      axi4_awregion(3 downto 0) => axi4_awregion(3 downto 0),
      axi4_awsize(2 downto 0) => axi4_awsize(2 downto 0),
      axi4_awvalid => axi4_awvalid,
      axi4_bid(11 downto 0) => axi4_bid(11 downto 0),
      axi4_bready => axi4_bready,
      axi4_bresp(1 downto 0) => axi4_bresp(1 downto 0),
      axi4_bvalid => axi4_bvalid,
      axi4_rdata(31 downto 0) => axi4_rdata(31 downto 0),
      axi4_rid(11 downto 0) => axi4_rid(11 downto 0),
      axi4_rlast => axi4_rlast,
      axi4_rready => axi4_rready,
      axi4_rresp(1 downto 0) => axi4_rresp(1 downto 0),
      axi4_rvalid => axi4_rvalid,
      axi4_wdata(31 downto 0) => axi4_wdata(31 downto 0),
      axi4_wlast => axi4_wlast,
      axi4_wready => axi4_wready,
      axi4_wstrb(3 downto 0) => axi4_wstrb(3 downto 0),
      axi4_wvalid => axi4_wvalid,
      axiClk => axiClk,
      axiRstN => axiRstN,
      axil_araddr(31 downto 0) => axil_araddr(31 downto 0),
      axil_arprot(2 downto 0) => axil_arprot(2 downto 0),
      axil_arready => axil_arready,
      axil_arvalid => axil_arvalid,
      axil_awaddr(31 downto 0) => axil_awaddr(31 downto 0),
      axil_awprot(2 downto 0) => axil_awprot(2 downto 0),
      axil_awready => axil_awready,
      axil_awvalid => axil_awvalid,
      axil_bready => axil_bready,
      axil_bresp(1 downto 0) => axil_bresp(1 downto 0),
      axil_bvalid => axil_bvalid,
      axil_rdata(31 downto 0) => axil_rdata(31 downto 0),
      axil_rready => axil_rready,
      axil_rresp(1 downto 0) => axil_rresp(1 downto 0),
      axil_rvalid => axil_rvalid,
      axil_wdata(31 downto 0) => axil_wdata(31 downto 0),
      axil_wready => axil_wready,
      axil_wstrb(3 downto 0) => axil_wstrb(3 downto 0),
      axil_wvalid => axil_wvalid
    );
end STRUCTURE;
