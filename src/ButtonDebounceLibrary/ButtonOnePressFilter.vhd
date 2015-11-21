----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    17:28:26 09/10/2015 
-- Design Name: 
-- Module Name:    ButtonOnePressFilter - Behavioral 
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

entity ButtonOnePressFilter is
	port( clk : in std_logic;
			reset: in std_logic;
			buttonInput : in std_logic;
			filteredButtonOutput: out std_logic
	);
end ButtonOnePressFilter;

architecture Behavioral of ButtonOnePressFilter is
	type StateType is (startState, onePressState, noPressAfterPressState);
	signal state : StateType;
	signal debouncedButton : std_logic;
begin
	
	buttonDebouncer : entity work.ButtonDebouncer
		port map(
			clk=> clk,
			rawButtonInput=> buttonInput,
			filteredButtonOutput=> debouncedButton
		);
		
	filteredButtonOutput <= '1' when state = onePressState else '0';
	
	process(clk, reset) begin
		if(reset = '0') then
			state <=startState;
		elsif(clk'event and clk='1') then
			case state is
				when startState => 
					if(debouncedButton='1') then
						state <= onePressState;
					end if;
				when onePressState =>
					if(debouncedButton='1') then
						state <= noPressAfterPressState;
					else
						state <= startState;
					end if;
				when noPressAfterPressState =>
					if(debouncedButton ='0') then
						state <= startState;
					end if;
				when others =>
					state <= startState;
			end case;					
		end if;
	end process;
end Behavioral;

