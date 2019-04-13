-------------------------------------------------------------------------------
-- File       : Axi4ToAxilSurfWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2017-02-16
-------------------------------------------------------------------------------
-- Description: Top Level Entity
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;

entity Axi4ToAxilSurfWrapper is
   generic (
      RESET_ACT_LOW_G : boolean := false;
      AXI_REGION_G    : slv(3 downto 0) := "0000";
      ALEN_W_G        : natural := 8
   );
   port (
      axiClk          : in  sl;
      axiRst          : in  sl;
      axiWriteMaster  : in  AxiWriteMasterType     := AXI_WRITE_MASTER_INIT_C;
      axiWriteSlave   : out AxiWriteSlaveType      := AXI_WRITE_SLAVE_INIT_C;
      axiReadMaster   : in  AxiReadMasterType      := AXI_READ_MASTER_INIT_C;
      axiReadSlave    : out AxiReadSlaveType       := AXI_READ_SLAVE_INIT_C;

      axilWriteMaster : out AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : in  AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
      axilReadMaster  : out AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : in  AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C
   );
end Axi4ToAxilSurfWrapper;

architecture Mapping of Axi4ToAxilSurfWrapper is

   signal   rst            : sl;

   constant ALOCK_W_C : natural := ite( ALEN_W_G = 4, 2, 1 );

begin

   GEN_RSTB : if (RESET_ACT_LOW_G) generate
      rst <= axiRst;
   end generate;

   GEN_RST  : if (not RESET_ACT_LOW_G) generate
      rst <= not axiRst;
   end generate;

   U_Axi4ToAxil : entity work.axi4_2_axil_wrapper
      port map (
         axiClk                      => axiClk,
         axiRstN                     => rst,
         axi4_araddr                 => axiReadMaster.araddr(31 downto 0),
         axi4_arburst                => axiReadMaster.arburst,
         axi4_arcache                => axiReadMaster.arcache,
         axi4_arid                   => axiReadMaster.arid(11 downto 0),
         axi4_arlen                  => axiReadMaster.arlen(ALEN_W_G - 1 downto 0),
         axi4_arlock                 => axiReadMaster.arlock(ALOCK_W_C - 1 downto 0),
         axi4_arprot                 => axiReadMaster.arprot(2 downto 0),
         axi4_arqos                  => axiReadMaster.arqos(3 downto 0),
         axi4_arready                => axiReadSlave.arready,
         axi4_arregion               => AXI_REGION_G,
         axi4_arsize                 => axiReadMaster.arsize( 2 downto 0 ),
         axi4_arvalid                => axiReadMaster.arvalid,

         axi4_awaddr                 => axiWriteMaster.awaddr( 31 downto 0 ),
         axi4_awburst                => axiWriteMaster.awburst ( 1 downto 0 ),
         axi4_awcache                => axiWritemaster.awcache( 3 downto 0 ),
         axi4_awid                   => axiWritemaster.awid(11 to 0 ),
         axi4_awlen                  => axiWriteMaster.awlen (ALEN_W_G - 1 downto 0 ),
         axi4_awlock                 => axiWriteMaster.awlock(ALOCK_W_C - 1 downto 0 ),
         axi4_awprot                 => axiWritemaster.awprot( 2 downto 0 ),
         axi4_awqos                  => axiWriteMaster.awqos( 3 downto 0 ),
         axi4_awready                => axiWriteSlave.awready,
         axi4_awregion               => AXI_REGION_G,
         axi4_awsize                 => axiWriteMaster.awsize( 2 downto 0 ),
         axi4_awvalid                => axiWriteMaster.awvalid,

         axi4_bid                    => axiWriteSlave.bid(11 to 0 ),
         axi4_bready                 => axiWriteMaster.bready,
         axi4_bresp                  => axiWriteSlave.bresp( 1 downto 0 ),
         axi4_bvalid                 => axiWriteSlave.bvalid,

         axi4_rdata                  => axiReadSlave.rdata( 31 downto 0 ),
         axi4_rid                    => axiReadSlave.rid(11 downto 0 ),
         axi4_rlast                  => axiReadSlave.rlast,
         axi4_rready                 => axiReadMaster.rready,
         axi4_rresp                  => axiReadSlave.rresp( 1 downto 0 ),
         axi4_rvalid                 => axiReadSlave.rvalid,

         axi4_wdata                  => axiWriteMaster.wdata( 31 downto 0 ),
         axi4_wlast                  => axiWriteMaster.wlast,
         axi4_wready                 => axiWriteSlave.wready,
         axi4_wstrb                  => axiWriteMaster.wstrb( 3 downto 0 ),
         axi4_wvalid                 => axiWriteMaster.wvalid,
      --   axi4_wid                    => axiWriteMaster.wid( 11 downto 0 ),

         axil_araddr                 => axilReadMaster.araddr,
         axil_arprot                 => axilReadMaster.arprot,
         axil_arready                => axilReadSlave.arready,
         axil_arvalid                => axilReadMaster.arvalid,
         axil_awaddr                 => axilWriteMaster.awaddr,
         axil_awprot                 => axilWriteMaster.awprot,
         axil_awready                => axilWriteSlave.awready,
         axil_awvalid                => axilWriteMaster.awvalid,
         axil_bready                 => axilWriteMaster.bready,
         axil_bresp                  => axilWriteSlave.bresp,
         axil_bvalid                 => axilWriteSlave.bvalid,
         axil_rdata                  => axilReadSlave.rdata,
         axil_rready                 => axilReadMaster.rready,
         axil_rresp                  => axilReadSlave.rresp,
         axil_rvalid                 => axilReadSlave.rvalid,
         axil_wdata                  => axilWriteMaster.wdata,
         axil_wready                 => axilWriteSlave.wready,
         axil_wstrb                  => axilWriteMaster.wstrb,
         axil_wvalid                 => axilWriteMaster.wvalid
      );
end Mapping;
