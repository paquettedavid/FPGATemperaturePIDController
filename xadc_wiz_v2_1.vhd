-- file: xadc_wiz_v2_1.vhd
-- (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
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
Library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity xadc_wiz_v2_1 is
    port (
          DADDR_IN            : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
          DCLK_IN             : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
          DEN_IN              : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
          DI_IN               : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
          DWE_IN              : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
          RESET_IN            : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
          BUSY_OUT            : out  STD_LOGIC;                        -- ADC Busy signal
          CHANNEL_OUT         : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
          DO_OUT              : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
          DRDY_OUT            : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
          EOC_OUT             : out  STD_LOGIC;                        -- End of Conversion Signal
          EOS_OUT             : out  STD_LOGIC;                        -- End of Sequence Signal
          JTAGBUSY_OUT        : out  STD_LOGIC;                        -- JTAG DRP transaction is in progress signal
          JTAGLOCKED_OUT      : out  STD_LOGIC;                        -- DRP port lock request has been made by JTAG
          JTAGMODIFIED_OUT    : out  STD_LOGIC;                        -- Indicates JTAG Write to the DRP has occurred
          ALARM_OUT          : out STD_LOGIC;                         -- OR'ed output of all the Alarms
          VP_IN               : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
          VN_IN               : in  STD_LOGIC
);
end xadc_wiz_v2_1;

architecture xilinx of xadc_wiz_v2_1 is

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of xilinx : architecture is "xadc_wiz_v2_1,xadc_wiz_v2_1,{component_name=xadc_wiz_v2_1,dclk_frequency=100,enable_busy=true,enable_convst=false,enable_convstclk=false,enable_dclk=true,enable_drp=true,enable_eoc=true,enable_eos=true,enable_vbram_alaram=false,enable_vccddro_alaram=false,enable_vccpaux_alaram=false,enable_Vccint_Alaram=false,enable_Vccaux_alaram=false,enable_vccpint_alaram=false,ot_alaram=false,user_temp_alaram=false,timing_mode=continuous,channel_averaging=None,sequencer_mode=off,startup_channel_selection=single_channel}";

  signal FLOAT_VCCAUX_ALARM : std_logic;
  signal FLOAT_VCCINT_ALARM : std_logic;
  signal FLOAT_USER_TEMP_ALARM : std_logic;
  signal FLOAT_VBRAM_ALARM : std_logic;
  signal FLOAT_MUXADDR : std_logic_vector (4 downto 0);
  signal aux_channel_p : std_logic_vector (15 downto 0);
  signal aux_channel_n : std_logic_vector (15 downto 0);
  signal alm_int : std_logic_vector (7 downto 0);
begin

        aux_channel_p(0) <= '0';
        aux_channel_n(0) <= '0';

        aux_channel_p(1) <= '0';
        aux_channel_n(1) <= '0';

        aux_channel_p(2) <= '0';
        aux_channel_n(2) <= '0';

        aux_channel_p(3) <= '0';
        aux_channel_n(3) <= '0';

        aux_channel_p(4) <= '0';
        aux_channel_n(4) <= '0';

        aux_channel_p(5) <= '0';
        aux_channel_n(5) <= '0';

        aux_channel_p(6) <= '0';
        aux_channel_n(6) <= '0';

        aux_channel_p(7) <= '0';
        aux_channel_n(7) <= '0';

        aux_channel_p(8) <= '0';
        aux_channel_n(8) <= '0';

        aux_channel_p(9) <= '0';
        aux_channel_n(9) <= '0';

        aux_channel_p(10) <= '0';
        aux_channel_n(10) <= '0';

        aux_channel_p(11) <= '0';
        aux_channel_n(11) <= '0';

        aux_channel_p(12) <= '0';
        aux_channel_n(12) <= '0';

        aux_channel_p(13) <= '0';
        aux_channel_n(13) <= '0';

        aux_channel_p(14) <= '0';
        aux_channel_n(14) <= '0';

        aux_channel_p(15) <= '0';
        aux_channel_n(15) <= '0';

       ALARM_OUT <= alm_int(7);

 XADC_INST : XADC
     generic map(
        INIT_40 => X"0000", -- config reg 0
        INIT_41 => X"3f0f", -- config reg 1
        INIT_42 => X"0400", -- config reg 2
        INIT_48 => X"0100", -- Sequencer channel selection
        INIT_49 => X"0000", -- Sequencer channel selection
        INIT_4A => X"0000", -- Sequencer Average selection
        INIT_4B => X"0000", -- Sequencer Average selection
        INIT_4C => X"0000", -- Sequencer Bipolar selection
        INIT_4D => X"0000", -- Sequencer Bipolar selection
        INIT_4E => X"0000", -- Sequencer Acq time selection
        INIT_4F => X"0000", -- Sequencer Acq time selection
        INIT_50 => X"b5ed", -- Temp alarm trigger
        INIT_51 => X"57e4", -- Vccint upper alarm limit
        INIT_52 => X"a147", -- Vccaux upper alarm limit
        INIT_53 => X"ca33",  -- Temp alarm OT upper
        INIT_54 => X"a93a", -- Temp alarm reset
        INIT_55 => X"52c6", -- Vccint lower alarm limit
        INIT_56 => X"9555", -- Vccaux lower alarm limit
        INIT_57 => X"ae4e",  -- Temp alarm OT reset
        INIT_58 => X"5999",  -- Vbram upper alarm limit
        INIT_5C => X"5111",  -- Vbram lower alarm limit
        SIM_DEVICE => "7SERIES",
        SIM_MONITOR_FILE => "design.txt"
        )

port map (
        CONVST              => '0',
        CONVSTCLK           => '0',
        DADDR(6 downto 0)   => DADDR_IN(6 downto 0),
        DCLK                => DCLK_IN,
        DEN                 => DEN_IN,
        DI(15 downto 0)     => DI_IN(15 downto 0),
        DWE                 => DWE_IN,
        RESET               => RESET_IN,
        VAUXN(15 downto 0)  => aux_channel_n(15 downto 0),
        VAUXP(15 downto 0)  => aux_channel_p(15 downto 0),
        ALM                 => alm_int,
        BUSY                => BUSY_OUT,
        CHANNEL(4 downto 0) => CHANNEL_OUT(4 downto 0),
        DO(15 downto 0)     => DO_OUT(15 downto 0),
        DRDY                => DRDY_OUT,
        EOC                 => EOC_OUT,
        EOS                 => EOS_OUT,
        JTAGBUSY            => JTAGBUSY_OUT,
        JTAGLOCKED          => JTAGLOCKED_OUT,
        JTAGMODIFIED        => JTAGMODIFIED_OUT,
        OT                  => open,
     
        MUXADDR             => FLOAT_MUXADDR,
        VN                  => VN_IN,
        VP                  => VP_IN
         );
end xilinx;

