-------------------------------------------------------------------------------
-- File       : IlaAxilSurfWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2017-02-16
-------------------------------------------------------------------------------
-- Description: Wrapper to connect an ILA to AXIL in SURF format
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity IlaAxilSurfWrapper is
   generic (
      RESET_ACT_LOW_G : boolean         := false;
      AXI_REGION_G    : slv(3 downto 0) := "0000"
   );
   port (
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType:= AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : in  AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_INIT_C;
      axilReadMaster  : in  AxiLiteReadMasterType := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : in  AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_INIT_C
   );
end entity IlaAxilSurfWrapper;

architecture Mapping of IlaAxilSurfWrapper is

   signal rst       : sl;

begin

   GEN_RSTB : if (RESET_ACT_LOW_G) generate
      rst <= axilRst;
   end generate;

   GEN_RST  : if (not RESET_ACT_LOW_G) generate
      rst <= not axilRst;
   end generate;

   U_Ila_Axil : entity work.ila_axi4_bd_wrapper
      port map (
         axiClk                      => axilClk,
         axiRstN                     => rst,
         axi4_araddr                 => axilReadMaster.araddr(31 downto 0),
         axi4_arburst                => "00",
         axi4_arcache                => "0000",
         axi4_arid                   => "0",
         axi4_arlen                  => x"00",
         axi4_arlock                 => "0",
         axi4_arprot                 => axilReadMaster.arprot(2 downto 0),
         axi4_arqos                  => "0000",
         axi4_arready(0)             => axilReadSlave.arready,
         axi4_arregion               => AXI_REGION_G,
         axi4_arsize                 => "000",
         axi4_arvalid(0)             => axilReadMaster.arvalid,
         axi4_aruser(0)              => '0',

         axi4_awaddr                 => axilWriteMaster.awaddr( 31 downto 0 ),
         axi4_awburst                => "00",
         axi4_awcache                => "0000",
         axi4_awid                   => "0",
         axi4_awlen                  => x"00",
         axi4_awlock                 => "0",
         axi4_awprot                 => axilWriteMaster.awprot( 2 downto 0 ),
         axi4_awqos                  => "0000",
         axi4_awready(0)             => axilWriteSlave.awready,
         axi4_awregion               => AXI_REGION_G,
         axi4_awsize                 => "000",
         axi4_awvalid(0)             => axilWriteMaster.awvalid,
         axi4_awuser(0)              => '0',


         axi4_bid                    => "0",
         axi4_bready(0)              => axilWriteMaster.bready,
         axi4_bresp                  => axilWriteSlave.bresp( 1 downto 0 ),
         axi4_bvalid(0)              => axilWriteSlave.bvalid,
         axi4_buser(0)               => '0',

         axi4_rdata                  => axilReadSlave.rdata( 31 downto 0 ),
         axi4_rid                    => "0",
         axi4_rlast(0)               => '0',
         axi4_rready(0)              => axilReadMaster.rready,
         axi4_rresp                  => axilReadSlave.rresp( 1 downto 0 ),
         axi4_rvalid(0)              => axilReadSlave.rvalid,
         axi4_ruser(0)               => '0',

         axi4_wdata                  => axilWriteMaster.wdata( 31 downto 0 ),
         axi4_wlast(0)               => '0',
         axi4_wready(0)              => axilWriteSlave.wready,
         axi4_wstrb                  => axilWriteMaster.wstrb( 3 downto 0 ),
         axi4_wvalid(0)              => axilWriteMaster.wvalid,
         axi4_wuser(0)               => '0'
      );
end architecture Mapping;
