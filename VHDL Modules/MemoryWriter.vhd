--------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
--
-- Create Date: 11/19/15   
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:

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
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemoryWriter is
	Port ( clk_i : in std_logic;
          rst_i : in std_logic;
		    adr_o : out std_logic_vector(31 downto 0);
          dat_i : in std_logic_vector(31 downto 0);
          dat_o : out std_logic_vector(31 downto 0);
          ack_i : in std_logic;
          cyc_o : out std_logic;
          stb_o : out std_logic;
          we_o  : out std_logic;
			 currentTemperature: in integer range 0 to 100;
			 desiredTemperature : in integer range 0 to 100;
			 fanSpeedPercent : in integer range 0 to 100
			 );
end MemoryWriter;

architecture Behavioral of MemoryWriter is
	signal code, ascii, volume : std_logic_vector(7 downto 0);
	signal shift, ctrl, alt : std_logic;
	signal req : std_logic;

	signal scan_line : integer range 0 to 11;
	signal pixelnum : integer range 0 to 7;

	signal buffer_base : std_logic_vector(31 downto 0):=(others=>'0');
	signal rst_p : std_logic;
	signal txtcolor : std_logic_vector(3 downto 0):="1111"; -- white
	signal bgcolor : std_logic_vector(3 downto 0):="0001"; -- blue
	signal pixels : std_logic_vector(7 downto 0);

	type StateType is (initialzeMemoryState, writeIntialMemoryState, startState, 
		waitForKeyBoardInterrupt, readKeyboardData,writePixelToMemory, getPixelData, enterState);
	signal state : StateType := initialzeMemoryState;
	signal memoryInitilizationComplete : std_logic:='0';
	signal row, column, line : integer range 0 to 100:=0;

begin

	rst_p <= not rst_i;

--	 the lookup table maps the ascii code to the pixels for that particular character.  
--	 The line input determines which of the 12 lines of the character we want.  The
--	 lookup table is implemented with the builtin registered BRAM, so the output is
--	 available only at the next clock cycle
	lut : entity work.char8x12_lookup_table
		port map( clk => clk_i, reset => rst_p, ascii => ascii, line => line, pixels => pixels );
	
--	 convert the scancode signal given the shift, ctrl, and alt flags into
--	 an eight bit ASCII signal.
	s2a : entity work.scancode2ascii
		port map ( scancode => code,
						ascii => ascii,
						shift => shift,
						ctrl => ctrl,
						alt => alt );


	process( clk_i, rst_i, state)
		variable extended, keyup : std_logic;
		variable shift_l_down, ctrl_l_down, alt_l_down : std_logic; 
		variable shift_r_down, ctrl_r_down, alt_r_down : std_logic;
		variable next_state : StateType;
		variable scancode : std_logic_vector(7 downto 0);
		variable isBackspace: std_logic:='0';
	begin
		if ( rst_i = '0' ) then
			state <= initialzeMemoryState;
			column <= 0;
			line <= 0;
			row <= 0;
			stb_o<='0';
			cyc_o<='0';
			we_o <='0';
			shift_l_down := '0';
			ctrl_l_down := '0';
			alt_l_down := '0';
			shift_r_down := '0';
			ctrl_r_down := '0';
			alt_r_down := '0';
			keyup := '0';
			extended := '0';
			isBackspace:='0';
		elsif ( clk_i'event and clk_i='1' ) then
			case state is
				when initialzeMemoryState=>
					cyc_o<='1';
					stb_o<='0';
					we_o <='0';
					state<= writeIntialMemoryState;
					line <= line + 1;
					if(line = 11) then
						line <= 0;
						column <= column + 1;
						if(column = 79) then
							column <= 0;
							row<=row + 1;
							if(row = 39) then
								row <= 0;
								state<=startState;
								column <= 0;
								line <= 0;
								row <= 0;
							end if;
						end if;
					end if;
				when writeIntialMemoryState=>
					stb_o<='1';
					we_o <='1';
					adr_o <= buffer_base + (row*80*12 + column + 80*line)*4;
					dat_o <= bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor;
					if(ack_i='1') then
						state<= initialzeMemoryState;
					end if;
				when startState=>
					column <= 0;
					line <= 0;
					row <= 0;
					state<=waitForKeyBoardInterrupt;
				when waitForKeyBoardInterrupt=>
					cyc_o<='0';
					stb_o<='0';
					--if(irq_i='1') then
						state<=readKeyboardData;
					--end if;
				when readKeyboardData=>
					stb_o<='1';
					we_o <='0';
					adr_o <= x"40000000";
					cyc_o<='1';
					if ( ack_i ='1' ) then
					next_state :=waitForKeyBoardInterrupt;
					scancode := dat_i(7 downto 0);
					if ( scancode = X"F0" ) then
						keyup := '1';
					elsif ( scancode = X"E0" ) then
						extended := '1';
					else
						if ( keyup = '1' ) then
							if ( scancode = X"59" ) then 
								shift_r_down := '0';
							elsif ( scancode = X"14" and extended = '1' ) then 
								ctrl_r_down := '0';
							elsif ( scancode = X"11" and extended = '1' ) then 
								alt_r_down := '0';
							elsif ( scancode = X"12" ) then
								shift_l_down := '0';
							elsif ( scancode = X"14" ) then 
								ctrl_l_down := '0';
							elsif ( scancode = X"11" ) then 
								alt_l_down := '0';
							end if;
						elsif ( extended = '1' ) then
							if ( scancode = X"14" ) then
								ctrl_r_down := '1';
							elsif ( scancode = X"11" ) then 
								alt_r_down := '1';
							end if;
						elsif ( scancode = X"12" ) then
							shift_l_down := '1';
						elsif ( scancode = X"14") then
							ctrl_l_down := '1';
						elsif ( scancode = X"11") then
							alt_l_down := '1';
						elsif ( scancode = X"59" ) then
							shift_r_down := '1';
						else
							if(scancode=x"5A") then
								next_state := enterState;
							elsif(scancode=x"66") then
								isBackspace:='1';
								next_state := writePixelToMemory;
							else
								next_state := writePixelToMemory;
							end if;
						end if;

						keyup := '0';
						extended := '0';
					end if;
					-- transfer variables to signals
					state <= next_state;
					code <= scancode;
					shift <= shift_l_down or shift_r_down;
					ctrl <= ctrl_l_down or ctrl_r_down;
					alt <= alt_l_down or alt_r_down;
				end if;
				when getPixelData=>
					line <= line + 1;
						if(line >= 11) then
							state<=waitForKeyBoardInterrupt;
							if(isBackspace='1') then
								column<= column-1;
								isBackspace:='0';
							else
								column <= column + 1;
							end if;
							line <= 0;
							if(column>=79) then
								row <= row + 1;
								column <=0;
								if(row >= 39) then
									row<= 0;
								end if;
							end if;
						else
							state<=writePixelToMemory;
						end if;
				when writePixelToMemory=>
					stb_o<='1';
					we_o <='1';
					cyc_o<='1';
					if(isBackspace='1') then
						adr_o <= buffer_base + (row*80*12 + (column-1) + 80*line)*4;
						dat_o <= bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor&bgcolor;
					else
						adr_o <= buffer_base + (row*80*12 + column + 80*line)*4;
						if(pixels(0)='1')then dat_o(3 downto 0) <= txtcolor;else dat_o(3 downto 0) <= bgcolor;end if;
						if(pixels(1)='1')then dat_o(7 downto 4) <= txtcolor;else dat_o(7 downto 4) <= bgcolor;end if;
						if(pixels(2)='1')then dat_o(11 downto 8) <= txtcolor;else dat_o(11 downto 8) <= bgcolor;end if;
						if(pixels(3)='1')then dat_o(15 downto 12) <= txtcolor;else dat_o(15 downto 12) <= bgcolor;end if;
						if(pixels(4)='1')then dat_o(19 downto 16) <= txtcolor;else dat_o(19 downto 16) <= bgcolor;end if;
						if(pixels(5)='1')then dat_o(23 downto 20) <= txtcolor;else dat_o(23 downto 20) <= bgcolor;end if;
						if(pixels(6)='1')then dat_o(27 downto 24) <= txtcolor;else dat_o(27 downto 24) <= bgcolor;end if;
						if(pixels(7)='1')then dat_o(31 downto 28) <= txtcolor;else dat_o(31 downto 28) <= bgcolor;end if;
					end if;
					if(ack_i='1') then
						state<=getPixelData;
					end if;
			when enterState=>
				row <= row + 1;
				column <= 0;
				state<=waitForKeyBoardInterrupt;
			end case;
		end if;
	end process;
	
end Behavioral;
