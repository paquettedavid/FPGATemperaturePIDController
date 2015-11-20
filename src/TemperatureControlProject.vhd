--------------------------------------------------------------------------------
-- Company: 
-- Engineer: David Paquette
--
-- Create Date:    15:54:03 11/19/15
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
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

entity TemperatureControlProject is
    Port (
    		 VGA_R  : out std_logic_vector(3 downto 0);
    		 VGA_G  : out std_logic_vector(3 downto 0);
    		 VGA_B  : out std_logic_vector(3 downto 0);
          VGA_HS : out std_logic;
          VGA_VS : out std_logic;
			 uart_rxd_out : out std_logic;
			 uart_txd_in :  in std_logic;

			CPU_RESETN : in std_logic;
			CLK100MHZ : in std_logic
			);
end TemperatureControlProject;

architecture Behavioral of TemperatureControlProject is
	-- Wishbone signals
     		  signal ACK_I_M:    std_logic_vector(3 downto 0);
    		  signal ACK_O_S:     std_logic_vector(3 downto 0);
    		  signal ADR_O_M0:    std_logic_vector( 31 downto 0 );
    		  signal ADR_O_M1:    std_logic_vector( 31 downto 0 );
    		  signal ADR_O_M2:    std_logic_vector( 31 downto 0 );
    		  signal ADR_O_M3:    std_logic_vector( 31 downto 0 );
    		  signal ADR_I_S:	    std_logic_vector( 31 downto 0 );
   		  signal CYC_O_M:     std_logic_vector(3 downto 0);
    		  signal DAT_O_M0:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_M1:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_M2:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_M3:    std_logic_vector( 31 downto 0 );
    		  signal DWR:  		 std_logic_vector( 31 downto 0 );
    		  signal DAT_O_S0:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_S1:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_S2:    std_logic_vector( 31 downto 0 );
    		  signal DAT_O_S3:    std_logic_vector( 31 downto 0 );
    		  signal DRD:  		 std_logic_vector( 31 downto 0 );
			  signal IRQ_O_S:		 std_logic_vector(3 downto 0);
			  signal IRQ_I_M:		 std_logic;
			  signal IRQV_I_M:	 std_logic_vector(1 downto 0);
			  signal STB_I_S:		 std_logic_vector(3 downto 0);
			  signal STB_O_M:		 std_logic_vector(3 downto 0);
			  signal	WE_O_M:		 std_logic_vector(3 downto 0);
			  signal	WE:		 std_logic;

	signal ascii_data_available : std_logic;
	signal ascii_data : std_logic_vector(7 downto 0);

	constant buffer_base : std_logic_vector(31 downto 0) := (others => '0');

	signal sys_clk, sys_rst : std_logic;
	signal clk200	 : std_logic;




begin

 	sys_rst <= cpu_resetn;


	clock200_inst : entity work.clk200
		port map ( clk_in1 => clk100mhz, clk_out1 => sys_clk, clk_out2 => clk200 ); 

	wb_intercon : entity work.wb_intercon
		port map ( clk => sys_clk, rst => sys_rst,
     		   	  ack_i_m => ACK_I_M, ack_o_s => ack_o_s,
					  adr_o_m0 => adr_o_m0,	adr_o_m1 => adr_o_m1, adr_o_m2 => adr_o_m2, adr_o_m3 => adr_o_m3,
					  dat_o_m0 => dat_o_m0,	dat_o_m1 => dat_o_m1, dat_o_m2 => dat_o_m2, dat_o_m3 => dat_o_m3,
					  dat_o_s0 => dat_o_s0, dat_o_s1 => dat_o_s1, dat_o_s2 => dat_o_s2, dat_o_s3 => dat_o_s3,
					  adr_i_s => adr_i_s, drd => drd, dwr => dwr, 
					  irq_o_s => irq_o_s, irq_i_m => irq_i_m, irqv_i_m => irqv_i_m,
					  cyc_o_m => cyc_o_m, stb_o_m => stb_o_m, stb_i_s => stb_i_s, we_o_m => we_o_m, we => we );
		
	temperatureControlMaster : entity work.TemperatureControlMaster
		port map ( clk_i => sys_clk, rst_i => sys_rst, 
					  adr_o => adr_o_m0, dat_i => drd, dat_o => dat_o_m0,
					  ack_i => ack_i_m(0), cyc_o => cyc_o_m(0), stb_o => stb_o_m(0), 
					  we_o => we_o_m(0), tx_in=>uart_txd_in, rx_out=>uart_rxd_out);

	vga : entity work.wb_vga640x480 
		port map ( clk_i => sys_clk, rst_i => sys_rst, 
					  adr_o => adr_o_m1, dat_i => drd, dat_o => dat_o_m1,
					  ack_i => ack_i_m(1), cyc_o => cyc_o_m(1), stb_o => stb_o_m(1), 
					  we_o => we_o_m(1),
 					  red => vga_r, green => vga_g, blue => vga_b, hsync => vga_hs, vsync => vga_vs);

	wb_bram : entity work.wb_bram
		port map ( clk_i => sys_clk, rst_i => sys_rst, 
					  adr_i => adr_i_s, dat_i => dwr, dat_o => dat_o_s0,
					  ack_o => ack_o_s(0), stb_i => stb_i_s(0), we_i => we );

	
	cyc_o_m(3) <= '0';
	cyc_o_m(2) <= '0';
	
	
end Behavioral;
