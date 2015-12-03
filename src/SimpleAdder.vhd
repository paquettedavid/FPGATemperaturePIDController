----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    16:49:31 12/03/2015 
-- Design Name: 
-- Module Name:    PIDController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimpleAdder is
	Port ( 
			reset : in std_logic;
			clk : in std_logic;
			output : out std_logic
		);
end SimpleAdder;

architecture Behavioral of SimpleAdder is
	signal count1 : std_logic_vector(127 downto 0):=(others=>'0');
	signal count2 : std_logic_vector(127 downto 0):=(others=>'0');
	signal count3 : std_logic_vector(127 downto 0):=(others=>'0');
	signal count4 : std_logic_vector(127 downto 0):=(others=>'0');
	signal o : std_logic:='0';

begin
	output <= o;
	process(clk, reset)
	begin
		if(reset='0') then
			count1 <= (others=>'0');
			count2 <= (others=>'0');
			count3 <= (others=>'0');
			count4 <= (others=>'0');
		elsif(clk'event and clk='1') then
			count1 <= count1(123 downto 0) * x"3" + 1;
			count2 <= count2(123 downto 0) * x"3" + 1;
			count3 <= count3(123 downto 0) * x"3" + 1;
			count4 <= count4(123 downto 0) * x"3" + 1;
			count1 <= count2 + count3 + count4;
			if(count1>x"7FFFFFC7FFFFFFFFFFFFFFC") then
				o<=not o;
			end if;
			if(count1>x"7FFFFFFFFFFFFFFC7FFFFFFFFFFFFFFC" or count2>x"7FFFFFFFFFFFFFFC7FFFFFFFFFFFFFFD" or count3>x"7FFFFFFFFFFFFFFC7FFFFFFFFFFFFFFB" or count4>x"7FFFFFFFFFFFFFFC7FFFFFFFFFFFFFFC") then

				o<=not o;
			end if;
		end if;
	end process;
end Behavioral;

