----------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
-- 
-- Create Date:    16:50:06 11/19/2015 
-- Design Name: 
-- Module Name:    DCFanInterface - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DCFanInterface is
	Port(fanSpeed : in integer range 0 to 100;
			pwmPinOut: out std_logic;
			clk_i : in std_logic);
end DCFanInterface;

architecture Behavioral of DCFanInterface is
	signal cnt : std_logic_vector(6 downto 0);
	signal t : std_logic:='0';
begin
	--pwmPinOut <= '1';
	--pwmPinOut <= data(0);
	pwmPinOut <= t;
	
   process(clk_i)
   begin
      if rising_edge(clk_i) then
         cnt <= cnt + '1';
      end if;
   end process;
   
   process(fanSpeed, cnt)
   begin
      if unsigned(cnt) < fanSpeed then
         t <= '1';
      else
         t <= '0';
      end if;
   end process;
end Behavioral;

