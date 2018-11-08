--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Wed Nov  7 23:13:53 2018
--Host        : rdsrv222 running 64-bit Red Hat Enterprise Linux Server release 6.10 (Santiago)
--Command     : generate_target ila_axi4_bd_wrapper.bd
--Design      : ila_axi4_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ila_axi4_bd_wrapper is
  port (
    axi4_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_aruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_buser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_rid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_ruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_wlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_wuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axiClk : in STD_LOGIC;
    axiRstN : in STD_LOGIC
  );
end ila_axi4_bd_wrapper;

architecture STRUCTURE of ila_axi4_bd_wrapper is
  component ila_axi4_bd is
  port (
    axiClk : in STD_LOGIC;
    axiRstN : in STD_LOGIC;
    axi4_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_aruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_arvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi4_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi4_awuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_awvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_buser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_rid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    axi4_ruser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi4_wlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi4_wuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi4_wvalid : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component ila_axi4_bd;
begin
ila_axi4_bd_i: component ila_axi4_bd
     port map (
      axi4_araddr(31 downto 0) => axi4_araddr(31 downto 0),
      axi4_arburst(1 downto 0) => axi4_arburst(1 downto 0),
      axi4_arcache(3 downto 0) => axi4_arcache(3 downto 0),
      axi4_arid(0) => axi4_arid(0),
      axi4_arlen(7 downto 0) => axi4_arlen(7 downto 0),
      axi4_arlock(0) => axi4_arlock(0),
      axi4_arprot(2 downto 0) => axi4_arprot(2 downto 0),
      axi4_arqos(3 downto 0) => axi4_arqos(3 downto 0),
      axi4_arready(0) => axi4_arready(0),
      axi4_arregion(3 downto 0) => axi4_arregion(3 downto 0),
      axi4_arsize(2 downto 0) => axi4_arsize(2 downto 0),
      axi4_aruser(0) => axi4_aruser(0),
      axi4_arvalid(0) => axi4_arvalid(0),
      axi4_awaddr(31 downto 0) => axi4_awaddr(31 downto 0),
      axi4_awburst(1 downto 0) => axi4_awburst(1 downto 0),
      axi4_awcache(3 downto 0) => axi4_awcache(3 downto 0),
      axi4_awid(0) => axi4_awid(0),
      axi4_awlen(7 downto 0) => axi4_awlen(7 downto 0),
      axi4_awlock(0) => axi4_awlock(0),
      axi4_awprot(2 downto 0) => axi4_awprot(2 downto 0),
      axi4_awqos(3 downto 0) => axi4_awqos(3 downto 0),
      axi4_awready(0) => axi4_awready(0),
      axi4_awregion(3 downto 0) => axi4_awregion(3 downto 0),
      axi4_awsize(2 downto 0) => axi4_awsize(2 downto 0),
      axi4_awuser(0) => axi4_awuser(0),
      axi4_awvalid(0) => axi4_awvalid(0),
      axi4_bid(0) => axi4_bid(0),
      axi4_bready(0) => axi4_bready(0),
      axi4_bresp(1 downto 0) => axi4_bresp(1 downto 0),
      axi4_buser(0) => axi4_buser(0),
      axi4_bvalid(0) => axi4_bvalid(0),
      axi4_rdata(31 downto 0) => axi4_rdata(31 downto 0),
      axi4_rid(0) => axi4_rid(0),
      axi4_rlast(0) => axi4_rlast(0),
      axi4_rready(0) => axi4_rready(0),
      axi4_rresp(1 downto 0) => axi4_rresp(1 downto 0),
      axi4_ruser(0) => axi4_ruser(0),
      axi4_rvalid(0) => axi4_rvalid(0),
      axi4_wdata(31 downto 0) => axi4_wdata(31 downto 0),
      axi4_wlast(0) => axi4_wlast(0),
      axi4_wready(0) => axi4_wready(0),
      axi4_wstrb(3 downto 0) => axi4_wstrb(3 downto 0),
      axi4_wuser(0) => axi4_wuser(0),
      axi4_wvalid(0) => axi4_wvalid(0),
      axiClk => axiClk,
      axiRstN => axiRstN
    );
end STRUCTURE;
