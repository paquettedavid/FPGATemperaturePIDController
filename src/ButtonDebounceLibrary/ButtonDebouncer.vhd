----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    17:22:33 09/10/2015 
-- Design Name: 
-- Module Name:    ButtonDebouncer - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ButtonDebouncer is
	port( clk : in std_logic;
			rawButtonInput : in std_logic;
			filteredButtonOutput: out std_logic
	);
			
end ButtonDebouncer;

architecture Behavioral of ButtonDebouncer is
begin
	process(clk) begin
		if(clk'event and clk='1') then
			filteredButtonOutput <= rawButtonInput;
		end if;
	end process;
end Behavioral;

