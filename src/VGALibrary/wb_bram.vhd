--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    16:26:59 11/03/15
-- Design Name:    
-- Module Name:    wb_bram - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--				This module implements a wishbone interface to BRAM
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity wb_bram is
	Port ( clk_i : in std_logic;
          rst_i : in std_logic;
		    adr_i : in std_logic_vector(31 downto 0);
          dat_i : in std_logic_vector(31 downto 0);
          dat_o : out std_logic_vector(31 downto 0);
          ack_o : out std_logic;
          stb_i : in std_logic;
          we_i  : in std_logic
--			 leds_o : out std_logic_vector(15 downto 0)
			);
end wb_bram;

architecture Behavioral of wb_bram is
	type state_type is (START, WAIT1, WAIT2, ACK);
	signal state : state_type;
	
	constant num_brams : integer := 128;
	constant num_bram_addr_bits : integer := 7;

	type bramdata_array is array(0 to num_brams-1) of std_logic_vector(31 downto 0);
	signal bram_do : bramdata_array;
	signal bram_di : std_logic_vector(31 downto 0);
	signal bram_dip : std_logic_vector( 3 downto 0 );
	signal bram_addr: std_logic_vector(15 downto 0 );
	signal bram_we : std_logic;
	signal bram_we_vector : std_logic_vector(3 downto 0);
	signal bram_en : std_logic_vector(num_brams-1 downto 0);
	signal bram_select : std_logic_vector(num_bram_addr_bits-1 downto 0);
	
	signal bram_data_out : std_logic_vector(31 downto 0);
	signal data_reg : std_logic_vector(31 downto 0);
		
	signal bram_enable : std_logic;

	signal rst_p : std_logic;
begin

	rst_p <= not rst_i;

	bram_we_vector <= (others => bram_we);
	
	gen1 : for i in 0 to num_brams-1 generate
		bram : RAMB16_S36
			port map ( DO => bram_do(i), ADDR => bram_addr(8 downto 0),
						  CLK => clk_i, DI => bram_di, DIP => bram_dip,
							  EN => bram_en(i), SSR => rst_p,
							  WE => bram_we );
--		bram_inst : BRAM_SINGLE_MACRO
--		generic map(
--			BRAM_SIZE => "36Kb",
--			DEVICE => "7SERIES",
--			DO_REG => 1,
--			WRITE_WIDTH => 32,
--			READ_WIDTH => 32
--			)
--			port map(
--			DO => bram_do(i),
--			DI => bram_di,
--			ADDR => bram_addr,
--			WE => bram_we,
--			CLK => clk_i,
--			RST => rst_p,
--			EN => bram_en(i)
--			);
--		RAMB36E1_inst : RAMB36E1
--		generic map(
--			-- READ_WIDTH_A/B, WRITE_WIDTH_A/B: Read/write width per port
--			READ_WIDTH_A => 36,                                                               -- 0-72
--			WRITE_WIDTH_A => 36                                                         -- 0-36
--		)
--		port map (
--			ADDRARDADDR => bram_addr,		-- 16-bit input: A port address/Read address
--			ADDRBWRADDR => X"0000",			-- 16-bit input: B port address/Write address
--			CLKARDCLK => clk_i,        	-- 1-bit input: A port clock/Read clock
--			CLKBWRCLK => '0',	         	-- 1-bit input: B port clock/Write clock
--			DIADI => bram_di,             -- 32-bit input: A port data/LSB data
--			DIBDI => X"00000000",         -- 32-bit input: B port data/LSB data
--			DIPADIP => bram_dip,          -- 4-bit input: A port parity/LSB parity
--			DIPBDIP => "0000",          	-- 4-bit input: B port parity/LSB parity
--			ENARDEN => bram_en(i),     	-- 1-bit input: A port enable/Read enable
--			ENBWREN => '0',	   		  	-- 1-bit input: B port enable/Write enable
--			INJECTDBITERR => '0',
--			INJECTSBITERR => '0',
--			RSTRAMARSTRAM => rst_p,			-- 1-bit input: A port set/reset
--			RSTREGARSTREG => rst_p,
--			RSTRAMB => '0',
--			RSTREGB => '0',
--			WEA => bram_we_vector,			-- 4-bit input: A port write enable
--			WEBWE => "00000000",				-- 8-bit input: B port write enable
--			DOADO => bram_do(i),  			-- 32-bit output: A port data/LSB data
--			CASCADEINA => '0',				-- 1-bit input: A port cascade
--			CASCADEINB => '0',				-- 1-bit input: B port cascade
--         REGCEAREGCE => '0',
--         REGCEB => '0'
--		);
	end generate;
	
	process(bram_select,bram_do)
	begin
		case bram_select is
      when "0000000" =>
         bram_data_out <= bram_do(0);
         bram_en(num_brams-1 downto 1) <= (others => '0');
         bram_en(0) <= bram_enable;

      when "0000001" =>
         bram_data_out <= bram_do(1);
         bram_en(num_brams-1 downto 2) <= (others => '0');
         bram_en(1) <= bram_enable;
         bram_en(0 downto 0) <= (others => '0');

      when "0000010" =>
         bram_data_out <= bram_do(2);
         bram_en(num_brams-1 downto 3) <= (others => '0');
         bram_en(2) <= bram_enable;
         bram_en(1 downto 0) <= (others => '0');

      when "0000011" =>
         bram_data_out <= bram_do(3);
         bram_en(num_brams-1 downto 4) <= (others => '0');
         bram_en(3) <= bram_enable;
         bram_en(2 downto 0) <= (others => '0');

      when "0000100" =>
         bram_data_out <= bram_do(4);
         bram_en(num_brams-1 downto 5) <= (others => '0');
         bram_en(4) <= bram_enable;
         bram_en(3 downto 0) <= (others => '0');

      when "0000101" =>
         bram_data_out <= bram_do(5);
         bram_en(num_brams-1 downto 6) <= (others => '0');
         bram_en(5) <= bram_enable;
         bram_en(4 downto 0) <= (others => '0');

      when "0000110" =>
         bram_data_out <= bram_do(6);
         bram_en(num_brams-1 downto 7) <= (others => '0');
         bram_en(6) <= bram_enable;
         bram_en(5 downto 0) <= (others => '0');

      when "0000111" =>
         bram_data_out <= bram_do(7);
         bram_en(num_brams-1 downto 8) <= (others => '0');
         bram_en(7) <= bram_enable;
         bram_en(6 downto 0) <= (others => '0');

      when "0001000" =>
         bram_data_out <= bram_do(8);
         bram_en(num_brams-1 downto 9) <= (others => '0');
         bram_en(8) <= bram_enable;
         bram_en(7 downto 0) <= (others => '0');

      when "0001001" =>
         bram_data_out <= bram_do(9);
         bram_en(num_brams-1 downto 10) <= (others => '0');
         bram_en(9) <= bram_enable;
         bram_en(8 downto 0) <= (others => '0');

      when "0001010" =>
         bram_data_out <= bram_do(10);
         bram_en(num_brams-1 downto 11) <= (others => '0');
         bram_en(10) <= bram_enable;
         bram_en(9 downto 0) <= (others => '0');

      when "0001011" =>
         bram_data_out <= bram_do(11);
         bram_en(num_brams-1 downto 12) <= (others => '0');
         bram_en(11) <= bram_enable;
         bram_en(10 downto 0) <= (others => '0');

      when "0001100" =>
         bram_data_out <= bram_do(12);
         bram_en(num_brams-1 downto 13) <= (others => '0');
         bram_en(12) <= bram_enable;
         bram_en(11 downto 0) <= (others => '0');

      when "0001101" =>
         bram_data_out <= bram_do(13);
         bram_en(num_brams-1 downto 14) <= (others => '0');
         bram_en(13) <= bram_enable;
         bram_en(12 downto 0) <= (others => '0');

      when "0001110" =>
         bram_data_out <= bram_do(14);
         bram_en(num_brams-1 downto 15) <= (others => '0');
         bram_en(14) <= bram_enable;
         bram_en(13 downto 0) <= (others => '0');

      when "0001111" =>
         bram_data_out <= bram_do(15);
         bram_en(num_brams-1 downto 16) <= (others => '0');
         bram_en(15) <= bram_enable;
         bram_en(14 downto 0) <= (others => '0');

      when "0010000" =>
         bram_data_out <= bram_do(16);
         bram_en(num_brams-1 downto 17) <= (others => '0');
         bram_en(16) <= bram_enable;
         bram_en(15 downto 0) <= (others => '0');

      when "0010001" =>
         bram_data_out <= bram_do(17);
         bram_en(num_brams-1 downto 18) <= (others => '0');
         bram_en(17) <= bram_enable;
         bram_en(16 downto 0) <= (others => '0');

      when "0010010" =>
         bram_data_out <= bram_do(18);
         bram_en(num_brams-1 downto 19) <= (others => '0');
         bram_en(18) <= bram_enable;
         bram_en(17 downto 0) <= (others => '0');

      when "0010011" =>
         bram_data_out <= bram_do(19);
         bram_en(num_brams-1 downto 20) <= (others => '0');
         bram_en(19) <= bram_enable;
         bram_en(18 downto 0) <= (others => '0');

      when "0010100" =>
         bram_data_out <= bram_do(20);
         bram_en(num_brams-1 downto 21) <= (others => '0');
         bram_en(20) <= bram_enable;
         bram_en(19 downto 0) <= (others => '0');

      when "0010101" =>
         bram_data_out <= bram_do(21);
         bram_en(num_brams-1 downto 22) <= (others => '0');
         bram_en(21) <= bram_enable;
         bram_en(20 downto 0) <= (others => '0');

      when "0010110" =>
         bram_data_out <= bram_do(22);
         bram_en(num_brams-1 downto 23) <= (others => '0');
         bram_en(22) <= bram_enable;
         bram_en(21 downto 0) <= (others => '0');

      when "0010111" =>
         bram_data_out <= bram_do(23);
         bram_en(num_brams-1 downto 24) <= (others => '0');
         bram_en(23) <= bram_enable;
         bram_en(22 downto 0) <= (others => '0');

      when "0011000" =>
         bram_data_out <= bram_do(24);
         bram_en(num_brams-1 downto 25) <= (others => '0');
         bram_en(24) <= bram_enable;
         bram_en(23 downto 0) <= (others => '0');

      when "0011001" =>
         bram_data_out <= bram_do(25);
         bram_en(num_brams-1 downto 26) <= (others => '0');
         bram_en(25) <= bram_enable;
         bram_en(24 downto 0) <= (others => '0');

      when "0011010" =>
         bram_data_out <= bram_do(26);
         bram_en(num_brams-1 downto 27) <= (others => '0');
         bram_en(26) <= bram_enable;
         bram_en(25 downto 0) <= (others => '0');

      when "0011011" =>
         bram_data_out <= bram_do(27);
         bram_en(num_brams-1 downto 28) <= (others => '0');
         bram_en(27) <= bram_enable;
         bram_en(26 downto 0) <= (others => '0');

      when "0011100" =>
         bram_data_out <= bram_do(28);
         bram_en(num_brams-1 downto 29) <= (others => '0');
         bram_en(28) <= bram_enable;
         bram_en(27 downto 0) <= (others => '0');

      when "0011101" =>
         bram_data_out <= bram_do(29);
         bram_en(num_brams-1 downto 30) <= (others => '0');
         bram_en(29) <= bram_enable;
         bram_en(28 downto 0) <= (others => '0');

      when "0011110" =>
         bram_data_out <= bram_do(30);
         bram_en(num_brams-1 downto 31) <= (others => '0');
         bram_en(30) <= bram_enable;
         bram_en(29 downto 0) <= (others => '0');

      when "0011111" =>
         bram_data_out <= bram_do(31);
         bram_en(num_brams-1 downto 32) <= (others => '0');
         bram_en(31) <= bram_enable;
         bram_en(30 downto 0) <= (others => '0');

      when "0100000" =>
         bram_data_out <= bram_do(32);
         bram_en(num_brams-1 downto 33) <= (others => '0');
         bram_en(32) <= bram_enable;
         bram_en(31 downto 0) <= (others => '0');

      when "0100001" =>
         bram_data_out <= bram_do(33);
         bram_en(num_brams-1 downto 34) <= (others => '0');
         bram_en(33) <= bram_enable;
         bram_en(32 downto 0) <= (others => '0');

      when "0100010" =>
         bram_data_out <= bram_do(34);
         bram_en(num_brams-1 downto 35) <= (others => '0');
         bram_en(34) <= bram_enable;
         bram_en(33 downto 0) <= (others => '0');

      when "0100011" =>
         bram_data_out <= bram_do(35);
         bram_en(num_brams-1 downto 36) <= (others => '0');
         bram_en(35) <= bram_enable;
         bram_en(34 downto 0) <= (others => '0');

      when "0100100" =>
         bram_data_out <= bram_do(36);
         bram_en(num_brams-1 downto 37) <= (others => '0');
         bram_en(36) <= bram_enable;
         bram_en(35 downto 0) <= (others => '0');

      when "0100101" =>
         bram_data_out <= bram_do(37);
         bram_en(num_brams-1 downto 38) <= (others => '0');
         bram_en(37) <= bram_enable;
         bram_en(36 downto 0) <= (others => '0');

      when "0100110" =>
         bram_data_out <= bram_do(38);
         bram_en(num_brams-1 downto 39) <= (others => '0');
         bram_en(38) <= bram_enable;
         bram_en(37 downto 0) <= (others => '0');

      when "0100111" =>
         bram_data_out <= bram_do(39);
         bram_en(num_brams-1 downto 40) <= (others => '0');
         bram_en(39) <= bram_enable;
         bram_en(38 downto 0) <= (others => '0');

      when "0101000" =>
         bram_data_out <= bram_do(40);
         bram_en(num_brams-1 downto 41) <= (others => '0');
         bram_en(40) <= bram_enable;
         bram_en(39 downto 0) <= (others => '0');

      when "0101001" =>
         bram_data_out <= bram_do(41);
         bram_en(num_brams-1 downto 42) <= (others => '0');
         bram_en(41) <= bram_enable;
         bram_en(40 downto 0) <= (others => '0');

      when "0101010" =>
         bram_data_out <= bram_do(42);
         bram_en(num_brams-1 downto 43) <= (others => '0');
         bram_en(42) <= bram_enable;
         bram_en(41 downto 0) <= (others => '0');

      when "0101011" =>
         bram_data_out <= bram_do(43);
         bram_en(num_brams-1 downto 44) <= (others => '0');
         bram_en(43) <= bram_enable;
         bram_en(42 downto 0) <= (others => '0');

      when "0101100" =>
         bram_data_out <= bram_do(44);
         bram_en(num_brams-1 downto 45) <= (others => '0');
         bram_en(44) <= bram_enable;
         bram_en(43 downto 0) <= (others => '0');

      when "0101101" =>
         bram_data_out <= bram_do(45);
         bram_en(num_brams-1 downto 46) <= (others => '0');
         bram_en(45) <= bram_enable;
         bram_en(44 downto 0) <= (others => '0');

      when "0101110" =>
         bram_data_out <= bram_do(46);
         bram_en(num_brams-1 downto 47) <= (others => '0');
         bram_en(46) <= bram_enable;
         bram_en(45 downto 0) <= (others => '0');

      when "0101111" =>
         bram_data_out <= bram_do(47);
         bram_en(num_brams-1 downto 48) <= (others => '0');
         bram_en(47) <= bram_enable;
         bram_en(46 downto 0) <= (others => '0');

      when "0110000" =>
         bram_data_out <= bram_do(48);
         bram_en(num_brams-1 downto 49) <= (others => '0');
         bram_en(48) <= bram_enable;
         bram_en(47 downto 0) <= (others => '0');

      when "0110001" =>
         bram_data_out <= bram_do(49);
         bram_en(num_brams-1 downto 50) <= (others => '0');
         bram_en(49) <= bram_enable;
         bram_en(48 downto 0) <= (others => '0');

      when "0110010" =>
         bram_data_out <= bram_do(50);
         bram_en(num_brams-1 downto 51) <= (others => '0');
         bram_en(50) <= bram_enable;
         bram_en(49 downto 0) <= (others => '0');

      when "0110011" =>
         bram_data_out <= bram_do(51);
         bram_en(num_brams-1 downto 52) <= (others => '0');
         bram_en(51) <= bram_enable;
         bram_en(50 downto 0) <= (others => '0');

      when "0110100" =>
         bram_data_out <= bram_do(52);
         bram_en(num_brams-1 downto 53) <= (others => '0');
         bram_en(52) <= bram_enable;
         bram_en(51 downto 0) <= (others => '0');

      when "0110101" =>
         bram_data_out <= bram_do(53);
         bram_en(num_brams-1 downto 54) <= (others => '0');
         bram_en(53) <= bram_enable;
         bram_en(52 downto 0) <= (others => '0');

      when "0110110" =>
         bram_data_out <= bram_do(54);
         bram_en(num_brams-1 downto 55) <= (others => '0');
         bram_en(54) <= bram_enable;
         bram_en(53 downto 0) <= (others => '0');

      when "0110111" =>
         bram_data_out <= bram_do(55);
         bram_en(num_brams-1 downto 56) <= (others => '0');
         bram_en(55) <= bram_enable;
         bram_en(54 downto 0) <= (others => '0');

      when "0111000" =>
         bram_data_out <= bram_do(56);
         bram_en(num_brams-1 downto 57) <= (others => '0');
         bram_en(56) <= bram_enable;
         bram_en(55 downto 0) <= (others => '0');

      when "0111001" =>
         bram_data_out <= bram_do(57);
         bram_en(num_brams-1 downto 58) <= (others => '0');
         bram_en(57) <= bram_enable;
         bram_en(56 downto 0) <= (others => '0');

      when "0111010" =>
         bram_data_out <= bram_do(58);
         bram_en(num_brams-1 downto 59) <= (others => '0');
         bram_en(58) <= bram_enable;
         bram_en(57 downto 0) <= (others => '0');

      when "0111011" =>
         bram_data_out <= bram_do(59);
         bram_en(num_brams-1 downto 60) <= (others => '0');
         bram_en(59) <= bram_enable;
         bram_en(58 downto 0) <= (others => '0');

      when "0111100" =>
         bram_data_out <= bram_do(60);
         bram_en(num_brams-1 downto 61) <= (others => '0');
         bram_en(60) <= bram_enable;
         bram_en(59 downto 0) <= (others => '0');

      when "0111101" =>
         bram_data_out <= bram_do(61);
         bram_en(num_brams-1 downto 62) <= (others => '0');
         bram_en(61) <= bram_enable;
         bram_en(60 downto 0) <= (others => '0');

      when "0111110" =>
         bram_data_out <= bram_do(62);
         bram_en(num_brams-1 downto 63) <= (others => '0');
         bram_en(62) <= bram_enable;
         bram_en(61 downto 0) <= (others => '0');

      when "0111111" =>
         bram_data_out <= bram_do(63);
         bram_en(num_brams-1 downto 64) <= (others => '0');
         bram_en(63) <= bram_enable;
         bram_en(62 downto 0) <= (others => '0');

      when "1000000" =>
         bram_data_out <= bram_do(64);
         bram_en(num_brams-1 downto 65) <= (others => '0');
         bram_en(64) <= bram_enable;
         bram_en(63 downto 0) <= (others => '0');

      when "1000001" =>
         bram_data_out <= bram_do(65);
         bram_en(num_brams-1 downto 66) <= (others => '0');
         bram_en(65) <= bram_enable;
         bram_en(64 downto 0) <= (others => '0');

      when "1000010" =>
         bram_data_out <= bram_do(66);
         bram_en(num_brams-1 downto 67) <= (others => '0');
         bram_en(66) <= bram_enable;
         bram_en(65 downto 0) <= (others => '0');

      when "1000011" =>
         bram_data_out <= bram_do(67);
         bram_en(num_brams-1 downto 68) <= (others => '0');
         bram_en(67) <= bram_enable;
         bram_en(66 downto 0) <= (others => '0');

      when "1000100" =>
         bram_data_out <= bram_do(68);
         bram_en(num_brams-1 downto 69) <= (others => '0');
         bram_en(68) <= bram_enable;
         bram_en(67 downto 0) <= (others => '0');

      when "1000101" =>
         bram_data_out <= bram_do(69);
         bram_en(num_brams-1 downto 70) <= (others => '0');
         bram_en(69) <= bram_enable;
         bram_en(68 downto 0) <= (others => '0');

      when "1000110" =>
         bram_data_out <= bram_do(70);
         bram_en(num_brams-1 downto 71) <= (others => '0');
         bram_en(70) <= bram_enable;
         bram_en(69 downto 0) <= (others => '0');

      when "1000111" =>
         bram_data_out <= bram_do(71);
         bram_en(num_brams-1 downto 72) <= (others => '0');
         bram_en(71) <= bram_enable;
         bram_en(70 downto 0) <= (others => '0');

      when "1001000" =>
         bram_data_out <= bram_do(72);
         bram_en(num_brams-1 downto 73) <= (others => '0');
         bram_en(72) <= bram_enable;
         bram_en(71 downto 0) <= (others => '0');

      when "1001001" =>
         bram_data_out <= bram_do(73);
         bram_en(num_brams-1 downto 74) <= (others => '0');
         bram_en(73) <= bram_enable;
         bram_en(72 downto 0) <= (others => '0');

      when "1001010" =>
         bram_data_out <= bram_do(74);
         bram_en(num_brams-1 downto 75) <= (others => '0');
         bram_en(74) <= bram_enable;
         bram_en(73 downto 0) <= (others => '0');

      when "1001011" =>
         bram_data_out <= bram_do(75);
         bram_en(num_brams-1 downto 76) <= (others => '0');
         bram_en(75) <= bram_enable;
         bram_en(74 downto 0) <= (others => '0');

      when "1001100" =>
         bram_data_out <= bram_do(76);
         bram_en(num_brams-1 downto 77) <= (others => '0');
         bram_en(76) <= bram_enable;
         bram_en(75 downto 0) <= (others => '0');

      when "1001101" =>
         bram_data_out <= bram_do(77);
         bram_en(num_brams-1 downto 78) <= (others => '0');
         bram_en(77) <= bram_enable;
         bram_en(76 downto 0) <= (others => '0');

      when "1001110" =>
         bram_data_out <= bram_do(78);
         bram_en(num_brams-1 downto 79) <= (others => '0');
         bram_en(78) <= bram_enable;
         bram_en(77 downto 0) <= (others => '0');

      when "1001111" =>
         bram_data_out <= bram_do(79);
         bram_en(num_brams-1 downto 80) <= (others => '0');
         bram_en(79) <= bram_enable;
         bram_en(78 downto 0) <= (others => '0');

      when "1010000" =>
         bram_data_out <= bram_do(80);
         bram_en(num_brams-1 downto 81) <= (others => '0');
         bram_en(80) <= bram_enable;
         bram_en(79 downto 0) <= (others => '0');

      when "1010001" =>
         bram_data_out <= bram_do(81);
         bram_en(num_brams-1 downto 82) <= (others => '0');
         bram_en(81) <= bram_enable;
         bram_en(80 downto 0) <= (others => '0');

      when "1010010" =>
         bram_data_out <= bram_do(82);
         bram_en(num_brams-1 downto 83) <= (others => '0');
         bram_en(82) <= bram_enable;
         bram_en(81 downto 0) <= (others => '0');

      when "1010011" =>
         bram_data_out <= bram_do(83);
         bram_en(num_brams-1 downto 84) <= (others => '0');
         bram_en(83) <= bram_enable;
         bram_en(82 downto 0) <= (others => '0');

      when "1010100" =>
         bram_data_out <= bram_do(84);
         bram_en(num_brams-1 downto 85) <= (others => '0');
         bram_en(84) <= bram_enable;
         bram_en(83 downto 0) <= (others => '0');

      when "1010101" =>
         bram_data_out <= bram_do(85);
         bram_en(num_brams-1 downto 86) <= (others => '0');
         bram_en(85) <= bram_enable;
         bram_en(84 downto 0) <= (others => '0');

      when "1010110" =>
         bram_data_out <= bram_do(86);
         bram_en(num_brams-1 downto 87) <= (others => '0');
         bram_en(86) <= bram_enable;
         bram_en(85 downto 0) <= (others => '0');

      when "1010111" =>
         bram_data_out <= bram_do(87);
         bram_en(num_brams-1 downto 88) <= (others => '0');
         bram_en(87) <= bram_enable;
         bram_en(86 downto 0) <= (others => '0');

      when "1011000" =>
         bram_data_out <= bram_do(88);
         bram_en(num_brams-1 downto 89) <= (others => '0');
         bram_en(88) <= bram_enable;
         bram_en(87 downto 0) <= (others => '0');

      when "1011001" =>
         bram_data_out <= bram_do(89);
         bram_en(num_brams-1 downto 90) <= (others => '0');
         bram_en(89) <= bram_enable;
         bram_en(88 downto 0) <= (others => '0');

      when "1011010" =>
         bram_data_out <= bram_do(90);
         bram_en(num_brams-1 downto 91) <= (others => '0');
         bram_en(90) <= bram_enable;
         bram_en(89 downto 0) <= (others => '0');

      when "1011011" =>
         bram_data_out <= bram_do(91);
         bram_en(num_brams-1 downto 92) <= (others => '0');
         bram_en(91) <= bram_enable;
         bram_en(90 downto 0) <= (others => '0');

      when "1011100" =>
         bram_data_out <= bram_do(92);
         bram_en(num_brams-1 downto 93) <= (others => '0');
         bram_en(92) <= bram_enable;
         bram_en(91 downto 0) <= (others => '0');

      when "1011101" =>
         bram_data_out <= bram_do(93);
         bram_en(num_brams-1 downto 94) <= (others => '0');
         bram_en(93) <= bram_enable;
         bram_en(92 downto 0) <= (others => '0');

      when "1011110" =>
         bram_data_out <= bram_do(94);
         bram_en(num_brams-1 downto 95) <= (others => '0');
         bram_en(94) <= bram_enable;
         bram_en(93 downto 0) <= (others => '0');

      when "1011111" =>
         bram_data_out <= bram_do(95);
         bram_en(num_brams-1 downto 96) <= (others => '0');
         bram_en(95) <= bram_enable;
         bram_en(94 downto 0) <= (others => '0');

      when "1100000" =>
         bram_data_out <= bram_do(96);
         bram_en(num_brams-1 downto 97) <= (others => '0');
         bram_en(96) <= bram_enable;
         bram_en(95 downto 0) <= (others => '0');

      when "1100001" =>
         bram_data_out <= bram_do(97);
         bram_en(num_brams-1 downto 98) <= (others => '0');
         bram_en(97) <= bram_enable;
         bram_en(96 downto 0) <= (others => '0');

      when "1100010" =>
         bram_data_out <= bram_do(98);
         bram_en(num_brams-1 downto 99) <= (others => '0');
         bram_en(98) <= bram_enable;
         bram_en(97 downto 0) <= (others => '0');

      when "1100011" =>
         bram_data_out <= bram_do(99);
         bram_en(num_brams-1 downto 100) <= (others => '0');
         bram_en(99) <= bram_enable;
         bram_en(98 downto 0) <= (others => '0');

      when "1100100" =>
         bram_data_out <= bram_do(100);
         bram_en(num_brams-1 downto 101) <= (others => '0');
         bram_en(100) <= bram_enable;
         bram_en(99 downto 0) <= (others => '0');

      when "1100101" =>
         bram_data_out <= bram_do(101);
         bram_en(num_brams-1 downto 102) <= (others => '0');
         bram_en(101) <= bram_enable;
         bram_en(100 downto 0) <= (others => '0');

      when "1100110" =>
         bram_data_out <= bram_do(102);
         bram_en(num_brams-1 downto 103) <= (others => '0');
         bram_en(102) <= bram_enable;
         bram_en(101 downto 0) <= (others => '0');

      when "1100111" =>
         bram_data_out <= bram_do(103);
         bram_en(num_brams-1 downto 104) <= (others => '0');
         bram_en(103) <= bram_enable;
         bram_en(102 downto 0) <= (others => '0');

      when "1101000" =>
         bram_data_out <= bram_do(104);
         bram_en(num_brams-1 downto 105) <= (others => '0');
         bram_en(104) <= bram_enable;
         bram_en(103 downto 0) <= (others => '0');

      when "1101001" =>
         bram_data_out <= bram_do(105);
         bram_en(num_brams-1 downto 106) <= (others => '0');
         bram_en(105) <= bram_enable;
         bram_en(104 downto 0) <= (others => '0');

      when "1101010" =>
         bram_data_out <= bram_do(106);
         bram_en(num_brams-1 downto 107) <= (others => '0');
         bram_en(106) <= bram_enable;
         bram_en(105 downto 0) <= (others => '0');

      when "1101011" =>
         bram_data_out <= bram_do(107);
         bram_en(num_brams-1 downto 108) <= (others => '0');
         bram_en(107) <= bram_enable;
         bram_en(106 downto 0) <= (others => '0');

      when "1101100" =>
         bram_data_out <= bram_do(108);
         bram_en(num_brams-1 downto 109) <= (others => '0');
         bram_en(108) <= bram_enable;
         bram_en(107 downto 0) <= (others => '0');

      when "1101101" =>
         bram_data_out <= bram_do(109);
         bram_en(num_brams-1 downto 110) <= (others => '0');
         bram_en(109) <= bram_enable;
         bram_en(108 downto 0) <= (others => '0');

      when "1101110" =>
         bram_data_out <= bram_do(110);
         bram_en(num_brams-1 downto 111) <= (others => '0');
         bram_en(110) <= bram_enable;
         bram_en(109 downto 0) <= (others => '0');

      when "1101111" =>
         bram_data_out <= bram_do(111);
         bram_en(num_brams-1 downto 112) <= (others => '0');
         bram_en(111) <= bram_enable;
         bram_en(110 downto 0) <= (others => '0');

      when "1110000" =>
         bram_data_out <= bram_do(112);
         bram_en(num_brams-1 downto 113) <= (others => '0');
         bram_en(112) <= bram_enable;
         bram_en(111 downto 0) <= (others => '0');

      when "1110001" =>
         bram_data_out <= bram_do(113);
         bram_en(num_brams-1 downto 114) <= (others => '0');
         bram_en(113) <= bram_enable;
         bram_en(112 downto 0) <= (others => '0');

      when "1110010" =>
         bram_data_out <= bram_do(114);
         bram_en(num_brams-1 downto 115) <= (others => '0');
         bram_en(114) <= bram_enable;
         bram_en(113 downto 0) <= (others => '0');

      when "1110011" =>
         bram_data_out <= bram_do(115);
         bram_en(num_brams-1 downto 116) <= (others => '0');
         bram_en(115) <= bram_enable;
         bram_en(114 downto 0) <= (others => '0');

      when "1110100" =>
         bram_data_out <= bram_do(116);
         bram_en(num_brams-1 downto 117) <= (others => '0');
         bram_en(116) <= bram_enable;
         bram_en(115 downto 0) <= (others => '0');

      when "1110101" =>
         bram_data_out <= bram_do(117);
         bram_en(num_brams-1 downto 118) <= (others => '0');
         bram_en(117) <= bram_enable;
         bram_en(116 downto 0) <= (others => '0');

      when "1110110" =>
         bram_data_out <= bram_do(118);
         bram_en(num_brams-1 downto 119) <= (others => '0');
         bram_en(118) <= bram_enable;
         bram_en(117 downto 0) <= (others => '0');

      when "1110111" =>
         bram_data_out <= bram_do(119);
         bram_en(num_brams-1 downto 120) <= (others => '0');
         bram_en(119) <= bram_enable;
         bram_en(118 downto 0) <= (others => '0');

      when "1111000" =>
         bram_data_out <= bram_do(120);
         bram_en(num_brams-1 downto 121) <= (others => '0');
         bram_en(120) <= bram_enable;
         bram_en(119 downto 0) <= (others => '0');

      when "1111001" =>
         bram_data_out <= bram_do(121);
         bram_en(num_brams-1 downto 122) <= (others => '0');
         bram_en(121) <= bram_enable;
         bram_en(120 downto 0) <= (others => '0');

      when "1111010" =>
         bram_data_out <= bram_do(122);
         bram_en(num_brams-1 downto 123) <= (others => '0');
         bram_en(122) <= bram_enable;
         bram_en(121 downto 0) <= (others => '0');

      when "1111011" =>
         bram_data_out <= bram_do(123);
         bram_en(num_brams-1 downto 124) <= (others => '0');
         bram_en(123) <= bram_enable;
         bram_en(122 downto 0) <= (others => '0');

      when "1111100" =>
         bram_data_out <= bram_do(124);
         bram_en(num_brams-1 downto 125) <= (others => '0');
         bram_en(124) <= bram_enable;
         bram_en(123 downto 0) <= (others => '0');

      when "1111101" =>
         bram_data_out <= bram_do(125);
         bram_en(num_brams-1 downto 126) <= (others => '0');
         bram_en(125) <= bram_enable;
         bram_en(124 downto 0) <= (others => '0');

      when "1111110" =>
         bram_data_out <= bram_do(126);
         bram_en(num_brams-1 downto 127) <= (others => '0');
         bram_en(126) <= bram_enable;
         bram_en(125 downto 0) <= (others => '0');

      when "1111111" =>
         bram_en(num_brams-1 downto 128) <= (others => '0');
         bram_en(127) <= bram_enable;
         bram_en(126 downto 0) <= (others => '0');

      when others =>
         bram_data_out <= bram_do(0);
         bram_en(num_brams-1 downto 0) <= (others => '0');

		end case;
	end process;

	process(clk_i,rst_i)
	begin
		if (rst_i='0' ) then
			state <= START;
		elsif (clk_i'event and clk_i='1') then
			case state is
			when START =>
				if ( stb_i='1' ) then
					state <= WAIT1;
					bram_di <= dat_i;
					bram_addr <= "0000000" & adr_i(10 downto 2);
					bram_we <= we_i;
					bram_select <= adr_i(17 downto 11);
					bram_enable <= '1';
				end if;

			when WAIT1 =>
				state <= WAIT2;
			
			when WAIT2 =>
				if (we_i ='0') then
					data_reg <= bram_data_out;
				end if;
				state <= ACK;
			
			when ACK =>
				bram_enable <= '0';
				state <= START;
			
			end case;
		end if;
	end process;

	dat_o <= data_reg;
	ack_o <= '1' when STATE = ACK else '0';

--	leds_o(7 downto 0) <= adr_i(15 downto 8);
--	leds_o(15 downto 8) <= dat_i(23 downto 16);

end Behavioral;
