--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    17:23:04 08/15/05
-- Design Name:    
-- Module Name:    scancode2ascii - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description: Convert PS/2 scancodes to ASCII given the shift, ctrl, and alt flags
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity scancode2ascii is
    Port ( scancode : in std_logic_vector(7 downto 0);
           ascii : out std_logic_vector(7 downto 0);
			  shift, ctrl, alt : in std_logic
			 );
end scancode2ascii;

architecture Behavioral of scancode2ascii is
	signal data : std_logic_vector(7 downto 0);
	signal code : std_logic_vector(11 downto 0);
begin

	-- make a 9-bit code that combines the shift and scancode
	code <= "000" & shift & scancode;
	
	with code select
		data <=  X"60" when X"00E", -- '
					X"7E" when X"10E", -- ~
					X"31" when X"016", -- 1
					X"32" when X"01E", -- 2
					X"33" when X"026", -- 3
					X"34" when X"025", -- 4
					X"35" when X"02E", -- 5
					X"36" when X"036", -- 6
					X"37" when X"03D", -- 7
					X"38" when X"03E", -- 8
					X"39" when X"046", -- 9
					X"30" when X"045", -- 0
					X"2D" when X"04E", -- -
					X"3D" when X"055", -- =
					X"08" when X"066", -- bs
					X"09" when X"00D", -- ht
					X"71" when X"015", -- q
					X"77" when X"01D", -- w
					X"65" when X"024", -- e
					X"72" when X"02D", -- r
					X"74" when X"02C", -- t
					X"79" when X"035", -- y
					X"75" when X"03C", -- u
					X"69" when X"043", -- i
					X"6F" when X"044", -- o
					X"70" when X"04D", -- p
					X"5B" when X"054", -- [
					X"5D" when X"05B", -- ]
					X"5C" when X"05D", -- \
					X"61" when X"01C", -- a
					X"73" when X"01B", -- s
					X"64" when X"023", -- d
					X"66" when X"02B", -- f
					X"67" when X"034", -- g
					X"68" when X"033", -- h
					X"6A" when X"03B", -- j
					X"6B" when X"042", -- k
					X"6C" when X"04B", -- l
					X"3B" when X"04C", -- ;
					X"27" when X"052", -- '
					X"0D" when X"05A", -- cr
					X"7A" when X"01A", -- z
					X"78" when X"022", -- x
					X"63" when X"021", -- c
					X"76" when X"02A", -- v
					X"62" when X"032", -- b
					X"6E" when X"031", -- n
					X"6D" when X"03A", -- m
					X"2C" when X"041", -- ,
					X"2E" when X"049", -- .
					X"2F" when X"04A", -- /
					X"21" when X"116", -- !
					X"40" when X"11E", -- @
					X"23" when X"126", -- #
					X"24" when X"125", -- $
					X"25" when X"12E", -- %
					X"5E" when X"136", -- ^
					X"26" when X"13D", -- &
					X"2A" when X"13E", -- *
					X"28" when X"146", -- (
					X"29" when X"145", -- )
					X"5F" when X"14E", -- _
					X"2B" when X"155", -- +
					X"51" when X"115", -- Q
					X"57" when X"11D", -- W
					X"45" when X"124", -- E
					X"52" when X"12D", -- R
					X"54" when X"12C", -- T
					X"59" when X"135", -- Y
					X"55" when X"13C", -- U
					X"49" when X"143", -- I
					X"4F" when X"144", -- O
					X"50" when X"14D", -- P
					X"7B" when X"154", -- {
					X"7D" when X"15B", -- }
					X"7C" when X"15D", -- |
					X"41" when X"11C", -- A
					X"53" when X"11B", -- S
					X"44" when X"123", -- D
					X"46" when X"12B", -- F
					X"47" when X"134", -- G
					X"48" when X"133", -- H
					X"4A" when X"13B", -- J
					X"4B" when X"142", -- K
					X"4C" when X"14B", -- L
					X"3A" when X"14C", -- :
					X"22" when X"152", -- "
					X"0D" when X"15A", -- cr
					X"5A" when X"11A", -- Z
					X"58" when X"122", -- X
					X"43" when X"121", -- C
					X"56" when X"12A", -- V
					X"42" when X"132", -- B
					X"4E" when X"131", -- N
					X"4D" when X"13A", -- M
					X"3C" when X"141", -- <
					X"3E" when X"149", -- >
					X"3F" when X"14A", -- ?
					X"31" when X"069", -- KP1
					X"32" when X"072", -- KP2
					X"33" when X"07A", -- KP3
					X"34" when X"06B", -- KP4
					X"35" when X"073", -- KP5
					X"36" when X"074", -- KP6
					X"37" when X"06C", -- KP7
					X"38" when X"075", -- KP8
					X"39" when X"07D", -- KP9
					X"30" when X"070", -- KP0
					X"2A" when X"07C", -- KP*
					X"2D" when X"07B", -- KP-
					X"2B" when X"079", -- KP+
					X"2E" when X"071", -- KP.
					X"00" when others;

	-- ctrl key zeroes out bits 5 and 6
	-- alt key sets the 7th bit
	ascii(4 downto 0) <= data(4 downto 0);
	ascii(6 downto 5) <= "00" when ctrl='1' else data(6 downto 5);
	ascii(7) <= alt;

end Behavioral;
