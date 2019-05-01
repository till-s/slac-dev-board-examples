-------------------------------------------------------------------------------
-- File       : DigilentZyboDevBoard.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2017-02-16
-------------------------------------------------------------------------------
-- Description: ILA Wrapper for Axi-4
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
use work.AxiPkg.all;

entity IlaAxi4SurfWrapper is
   generic (
      RESET_ACT_LOW_G : boolean         := false;
      AXI_REGION_G    : slv(3 downto 0) := "0000"
   );
   port (
      axiClk          : in  sl;
      axiRst          : in  sl;
      axiWriteMaster  : in  AxiWriteMasterType     := AXI_WRITE_MASTER_INIT_C;
      axiWriteSlave   : in  AxiWriteSlaveType      := AXI_WRITE_SLAVE_INIT_C;
      axiReadMaster   : in  AxiReadMasterType      := AXI_READ_MASTER_INIT_C;
      axiReadSlave    : in  AxiReadSlaveType       := AXI_READ_SLAVE_INIT_C
   );
end entity IlaAxi4SurfWrapper;

architecture Mapping of IlaAxi4SurfWrapper is

   signal rst : sl;

begin

   GEN_RSTB : if (RESET_ACT_LOW_G) generate
      rst <= axiRst;
   end generate;

   GEN_RST  : if (not RESET_ACT_LOW_G) generate
      rst <= not axiRst;
   end generate;


   U_Ila_Axi4 : entity work.ila_axi4_bd_wrapper
      port map (
         axiClk                      => axiClk,
         axiRstN                     => rst,
         axi4_araddr                 => axiReadMaster.araddr(31 downto 0),
         axi4_arburst                => axiReadMaster.arburst,
         axi4_arcache                => axiReadMaster.arcache,
         axi4_arid                   => axiReadMaster.arid(0 downto 0),
         axi4_arlen                  => axiReadMaster.arlen(7 downto 0),
         axi4_arlock                 => axiReadMaster.arlock(0 downto 0),
         axi4_arprot                 => axiReadMaster.arprot(2 downto 0),
         axi4_arqos                  => axiReadMaster.arqos(3 downto 0),
         axi4_arready(0)             => axiReadSlave.arready,
         axi4_arregion               => AXI_REGION_G,
         axi4_arsize                 => axiReadMaster.arsize( 2 downto 0 ),
         axi4_arvalid(0)             => axiReadMaster.arvalid,
         axi4_aruser(0)              => '0',

         axi4_awaddr                 => axiWriteMaster.awaddr( 31 downto 0 ),
         axi4_awburst                => axiWriteMaster.awburst ( 1 downto 0 ),
         axi4_awcache                => axiWritemaster.awcache( 3 downto 0 ),
         axi4_awid                   => axiWritemaster.awid(0 to 0 ),
         axi4_awlen                  => axiWriteMaster.awlen ( 7 downto 0 ),
         axi4_awlock                 => axiWriteMaster.awlock( 0 to 0 ),
         axi4_awprot                 => axiWritemaster.awprot( 2 downto 0 ),
         axi4_awqos                  => axiWriteMaster.awqos( 3 downto 0 ),
         axi4_awready(0)             => axiWriteSlave.awready,
         axi4_awregion               => AXI_REGION_G,
         axi4_awsize                 => axiWriteMaster.awsize( 2 downto 0 ),
         axi4_awvalid(0)             => axiWriteMaster.awvalid,
         axi4_awuser(0)              => '0',


         axi4_bid                    => axiWriteSlave.bid(0 to 0 ),
         axi4_bready(0)              => axiWriteMaster.bready,
         axi4_bresp                  => axiWriteSlave.bresp( 1 downto 0 ),
         axi4_bvalid(0)              => axiWriteSlave.bvalid,
         axi4_buser(0)               => '0',

         axi4_rdata                  => axiReadSlave.rdata( 31 downto 0 ),
         axi4_rid                    => axiReadSlave.rid(0 downto 0 ),
         axi4_rlast(0)               => axiReadSlave.rlast,
         axi4_rready(0)              => axiReadMaster.rready,
         axi4_rresp                  => axiReadSlave.rresp( 1 downto 0 ),
         axi4_rvalid(0)              => axiReadSlave.rvalid,
         axi4_ruser(0)               => '0',

         axi4_wdata                  => axiWriteMaster.wdata( 31 downto 0 ),
         axi4_wlast(0)               => axiWriteMaster.wlast,
         axi4_wready(0)              => axiWriteSlave.wready,
         axi4_wstrb                  => axiWriteMaster.wstrb( 3 downto 0 ),
         axi4_wvalid(0)              => axiWriteMaster.wvalid,
         axi4_wuser(0)               => '0'
      );
end architecture Mapping;
