----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    17:02:39 11/19/2015 
-- Design Name: 
-- Module Name:    TemperatureSetpointControl - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TemperatureSetpointControl is
	Port(clk_i : in std_logic;
			rst_i : in std_logic;
			incrementButton : in std_logic;
			decrementButton : in std_logic;
			selectedTemperature : out integer range 0 to 100);
end TemperatureSetpointControl;

architecture Behavioral of TemperatureSetpointControl is
	signal setpoint : integer range 0 to 100:=37;
	signal decrementSetpoint, incrementSetpoint : std_logic:='0';
begin

	selectedTemperature<=setpoint;

	incrementSetpointButtonFilter : entity work.ButtonOnePressFilter
		port map(
			clk=>clk_i,
			reset=>rst_i,
			buttonInput=>incrementButton,
			filteredButtonOutput=>incrementSetpoint );
			
	decrememntSetpointButtonFilter : entity work.ButtonOnePressFilter
			port map(
				clk=>clk_i,
				reset=>rst_i,
				buttonInput=>decrementButton,
				filteredButtonOutput=>decrementSetpoint );
	
	process (clk_i, rst_i)
	begin
		if(rst_i='0') then
			--
		elsif (clk_i'event and clk_i = '1') then
			if(decrementSetpoint='1') then
				setpoint<= setpoint - 1;
			end if;
			if(incrementSetpoint='1') then
				setpoint <= setpoint + 1;
			end if;
		end if;
	end process;
end Behavioral;

