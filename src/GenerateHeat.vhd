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

entity GenerateHeat is
	Port ( 
				reset : in std_logic;
				clk : in std_logic;
				output : out std_logic
		);
end GenerateHeat;

architecture Behavioral of GenerateHeat is
	signal result : std_logic_vector(3 downto 0) :=(others=>'0');
	signal o : std_logic:='0';
begin
		add0 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(0));
		add1 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(1));
		add2 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(2));
		add3 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(3));
--		add4 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(4));
--		add5 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(5));
--		add6 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(6));
--		add7 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(7));
--		add8 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(8));
--		add9 : entity work.SimpleAdder port map( clk => clk,reset => reset, output=>result(9));

	process(clk, result)
	begin
		if(clk='1' and clk'event) then
			if(result > 13 ) then
				o <=not o;
			end if;
		end if;
	end process;
	
	output <=o;
	
end Behavioral;

