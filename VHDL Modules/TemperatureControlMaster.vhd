--------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
--
-- Create Date:    15:59:15 11/19/15
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

entity TemperatureControlMaster is
	Port ( clk_i : in std_logic;
          rst_i : in std_logic;
		    adr_o : out std_logic_vector(31 downto 0);
          dat_i : in std_logic_vector(31 downto 0);
          dat_o : out std_logic_vector(31 downto 0);
          ack_i : in std_logic;
          cyc_o : out std_logic;
          stb_o : out std_logic;
          we_o  : out std_logic
		);
end TemperatureControlMaster;

architecture Behavioral of TemperatureControlMaster is
	signal currentTemperature : integer range 0 to 100:=45;
	signal desiredTemperature : integer range 0 to 100:=37;
	signal fanSpeedPercent : integer range 0 to 100:=23;
	
	signal pidProportionalGain : integer range 0 to 10:=1;
	signal pidIntegralGain: integer range 0 to 10:=1;
	signal pidDerivativeGain: integer range 0 to 10:=1;
begin

	pidController : entity work.PIDController
		port map( proportionalGain=>pidProportionalGain,
				integralGain=>pidIntegralGain,
				derivativeGain=>pidDerivativeGain,
				setpoint=>desiredTemperatur,
				sensorFeedbackValue=>currentTemperature,
				controlOutput =>fanSpeedPercent );
				
	memoryWriter : entity work.MemoryWriter
		port map ( clk_i => clk_i, rst_i => rst_i , 
		  adr_o => adr_o, dat_i => dat_i, dat_o => dat_o,
		  ack_i => ack_i, cyc_o => cyc_o, stb_o => stb_o, 
		  we_o => we_o, currentTemperature=> currentTemperature,
		  desiredTemperature=> desiredTemperature,
		  fanSpeedPercent=> fanSpeedPercent
		);
			
	temperatureSetPointControl : entity work.TemperatureSetpointControl
		port map(selectedTemperature=>desiredTemperature);
		
	temperatureSensor : entity work.TemperatureSensorInterface
		port map (temperatureCelcius=>currentTemperature);
		
	dcFanInterface: entity work.dcFanInterface
		port map(fanSpeed=>fanSpeedPercent);

end Behavioral;
