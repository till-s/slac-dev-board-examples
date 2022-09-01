
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 3.6
--  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--  /   /         Filename : timinggtp_cpll_railing.vhd
-- /___/   /\      
-- \   \  /  \ 
--  \___\/\___\
--
--  Description : This module instantiates the modules required for
--                reset and initialisation of the Transceiver
--
-- Module TimingGtp_cpll_railing
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity TimingGtp_cpll_railing is
generic( USE_BUF       : string := "BUFH"
       );
   port  (
         cpll_reset_out : out std_logic;
         cpll_pd_out : out std_logic;
         refclk_out : out std_logic;
        
         refclk_in : in std_logic
          );
   end TimingGtp_cpll_railing;


architecture RTL of TimingGtp_cpll_railing is

--**************************** Signal Declarations ****************************

    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;

attribute equivalent_register_removal: string; 
signal cpllpd_wait    :   std_logic_vector(95 downto 0)  := x"FFFFFFFFFFFFFFFFFFFFFFFF";
signal cpllreset_wait :   std_logic_vector(127 downto 0) := x"000000000000000000000000000000FF";
attribute equivalent_register_removal of cpllpd_wait : signal is "no";
attribute equivalent_register_removal of cpllreset_wait : signal is "no";
signal    gtrefclk0_i      :std_logic ;
--******************************** Main Body of Code***************************
                       
begin                      

  assert USE_BUF = "BUFG" or USE_BUF = "BUFH" or USE_BUF = "NONE"
    report "Invalid choice for USE_BUF generic (BUFG, BUFH, NONE allowed)"
    severity failure;

    ---------------------------  Static signal Assignments ---------------------   

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';

  use_bufg_cpll:if(USE_BUF = "BUFG") generate
  refclk_buf : BUFG
  port map
   (O   => gtrefclk0_i,
    I   => refclk_in);

  end generate;

  use_bufh_cpll:if(USE_BUF = "BUFH") generate
  refclk_buf : BUFH
  port map
   (O   => gtrefclk0_i,
    I   => refclk_in);

  end generate;

  use_nobuf_cpll:if(USE_BUF = "NONE") generate
    gtrefclk0_i <= refclk_in;
  end generate;

    process( gtrefclk0_i )
    begin
        if(gtrefclk0_i'event and gtrefclk0_i = '1') then 
           cpllpd_wait <= cpllpd_wait(94 downto 0) & '0';
           cpllreset_wait <= cpllreset_wait(126 downto 0) & '0';
         end if;
    end process;

cpll_pd_out <= cpllpd_wait(95);
cpll_reset_out <= cpllreset_wait(127);
refclk_out <= gtrefclk0_i;


 end RTL;
