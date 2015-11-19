--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    15:59:15 11/01/06
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
begin

pidController : entity work.PIDController;
dcFanInterface: entity work.dcFanInterface;
memoryWriter : entity work.MemoryWriter;
pwmControl : entity work.PWMControl;
temperatureSetPointControl : entity work.TemperatureSetpointControl;

end Behavioral;
