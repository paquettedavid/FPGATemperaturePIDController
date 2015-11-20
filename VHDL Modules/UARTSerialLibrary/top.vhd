
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
    port 
    (  
        -- General
        clk100mhz                :   in      std_logic;
        cpu_resetn              :   in      std_logic;    
        uart_rxd_out           :   out      std_logic;
        uart_txd_in           :   in     std_logic
		  );
end TOP;

architecture RTL of TOP is
	signal sys_rst : std_logic;
	signal sys_clk : std_logic;
    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------

    component LOOPBACK is
        port 
        (  
            -- General
            CLOCK                   :   in      std_logic;
            RESET                   :   in      std_logic;    
            RX                      :   in      std_logic;
            TX                      :   out     std_logic
				);
    end component LOOPBACK;
    
    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------

    signal tx, rx, rx_sync, reset, reset_sync,tx_sig : std_logic;
    
begin
   sys_rst <= cpu_resetn;
	sys_clk <= clk100mhz;
	tx_sig <= uart_txd_in;
    ----------------------------------------------------------------------------
    -- Loopback instantiation
    ----------------------------------------------------------------------------
    LOOPBACK_inst1 : LOOPBACK
    port map    (  
            -- General
            CLOCK       => sys_clk,
            RESET       => reset, 
            RX          => rx,
            TX          => tx
    );

		
    process (sys_clk, sys_rst)
    begin
			if(sys_rst='0') then
				reset <= '1'; -- the nexys4ddr is active low, so invert reset to use with this serial lib
        elsif (sys_clk'event and sys_clk = '1') then
            reset <='0';
				rx_sync <= tx_sig; -- the perspective of the tx and rx is reversed for the nexys
            rx   <= rx_sync;
            uart_rxd_out <= tx;
        end if;
    end process;
end RTL;