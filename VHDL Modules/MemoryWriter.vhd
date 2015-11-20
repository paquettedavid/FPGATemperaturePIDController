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
	signal ascii : std_logic_vector(7 downto 0);
	signal pixelnum : integer range 0 to 7;

	signal buffer_base : std_logic_vector(31 downto 0):=(others=>'0');
	signal rst_p : std_logic;
	signal txtcolor : std_logic_vector(3 downto 0):="1111"; -- white
	signal bgcolor : std_logic_vector(3 downto 0):="0001"; -- blue
	signal pixels : std_logic_vector(7 downto 0);

	type StateType is (initialzeMemoryState, writeIntialMemoryState, startState, 
		writePixelToMemory, getPixelData);
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
		
	process( clk_i, rst_i, state)
	begin
		if ( rst_i = '0' ) then
			state <= initialzeMemoryState;
			column <= 0;
			line <= 0;
			row <= 0;
			stb_o<='0';
			cyc_o<='0';
			we_o <='0';
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
					stb_o<='0';
					cyc_o<='0';
				when getPixelData=>
					line <= line + 1;
						if(line >= 11) then
							--state<=waitForKeyBoardInterrupt;
								column <= column + 1;
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
					adr_o <= buffer_base + (row*80*12 + column + 80*line)*4;
					if(pixels(0)='1')then dat_o(3 downto 0) <= txtcolor;else dat_o(3 downto 0) <= bgcolor;end if;
					if(pixels(1)='1')then dat_o(7 downto 4) <= txtcolor;else dat_o(7 downto 4) <= bgcolor;end if;
					if(pixels(2)='1')then dat_o(11 downto 8) <= txtcolor;else dat_o(11 downto 8) <= bgcolor;end if;
					if(pixels(3)='1')then dat_o(15 downto 12) <= txtcolor;else dat_o(15 downto 12) <= bgcolor;end if;
					if(pixels(4)='1')then dat_o(19 downto 16) <= txtcolor;else dat_o(19 downto 16) <= bgcolor;end if;
					if(pixels(5)='1')then dat_o(23 downto 20) <= txtcolor;else dat_o(23 downto 20) <= bgcolor;end if;
					if(pixels(6)='1')then dat_o(27 downto 24) <= txtcolor;else dat_o(27 downto 24) <= bgcolor;end if;
					if(pixels(7)='1')then dat_o(31 downto 28) <= txtcolor;else dat_o(31 downto 28) <= bgcolor;end if;
					if(ack_i='1') then
						state<=getPixelData;
					end if;
			end case;
		end if;
	end process;
	
end Behavioral;
