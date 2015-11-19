----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    16:49:31 11/19/2015 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIDController is
	Port ( 	proportionalGain : in integer range 0 to 10;
				integralGain: in integer range 0 to 10;
				derivativeGain: in integer range 0 to 10;
				setpoint: in integer range 0 to 100;
				sensorFeedbackValue : in integer range 0 to 100;
				controlOutput : out integer range 0 to 100
		);
end PIDController;

architecture Behavioral of PIDController is

begin


end Behavioral;

