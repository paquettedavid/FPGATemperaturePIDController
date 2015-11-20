--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    16:26:59 08/03/05
-- Design Name:    
-- Module Name:    vga - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--				This module implements a 8-bit 640x480 VGA controller that reads from a buffer in SRAM.
--
--				There are two main processes to control the hsync and vsync: pixel_count_process which keeps
--				track of which pixel we are displaying and line_count_process which keeps track of the scanline.
--				The hsync and vsync signals are generated with concurrent statements based on the pixel_count and
--				line_count.
--
--				The reads from the video buffer are done in three different ways depending on the setting of
--				the line_buffer_method and bram_buffer_method constants.  The three implementations are 
--				line buffer method, bram buffer method, and word buffer method.
--
--				The line buffer method is selected by setting line_buffer_method to 1 and setting
--				bram_buffer_method to 0.  In this method, the line_read process reads a scanline of data from
--				memory and stores it in a bank of registers.  The read is started while the horizontal display
--				is not active, i.e. during the hsync and porch portions of the scan.  During the active display
--				portion, the display data can then be read from the registers.
--
--				The bram buffer method is selected by setting line_buffer_method to 1 and setting
--				bram_buffer_method to 1.  This method is similar to the line buffer method except that the scanline
--				is stored in the FPGA's built-in BRAM instead of in registers.  This saves valuable flip-flop space.
--
--				The word_buffer method is selected by setting line_buffer_method to 0.  In this method, the
--				video buffer reading is merged into the pixel_count_process.  Instead of reading a whole line ahead
--				of time, we just read one word or 8 pixels ahead of time.  This method uses much fewer flip-flop
--				resources, and doesnt require the use of BRAM.  The disadvantage is that no other module can write
--				to the memory during the entire active video cycle
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 			0.02 - Changed to support 8-bit VGA on Nexys2 (11/03/10)
-- 			0.03 - Changed to support VGA on Nexys4 (11/03/15)
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity wb_vga640x480 is
	Port ( clk_i : in std_logic;
          rst_i : in std_logic;
		    adr_o : out std_logic_vector(31 downto 0);
          dat_i : in std_logic_vector(31 downto 0);
          dat_o : out std_logic_vector(31 downto 0);
          ack_i : in std_logic;
          cyc_o : out std_logic;
          stb_o : out std_logic;
          we_o  : out std_logic;
    		 red : out std_logic_vector(3 downto 0);
          green : out std_logic_vector(3 downto 0);
          blue : out std_logic_vector(3 downto 0);
          hsync : out std_logic;
          vsync : out std_logic
			);
end wb_vga640x480;

architecture Behavioral of wb_vga640x480 is
	signal pixel_clk : std_logic;
	signal line_count : integer range 0 to 521;
	signal pixel_count : integer range 0 to 800;
	signal hsync_internal : std_logic;
	signal display_valid, hdisplay_valid, vdisplay_valid : std_logic;
	signal buffer_base : std_logic_vector(31 downto 0);

-- 640x480 requires 25MHz pixel clock
	constant VISIBLE_LINES_PER_FRAME : integer := 480;
	constant LINES_PER_FRAME : integer := 521;
	constant VSYNC_FRONT_PORCH : integer := 10;
	constant VSYNC_WIDTH : integer := 2;
	constant VSYNC_BACK_PORCH : integer := 29;

	constant VISIBLE_PIXELS_PER_LINE : integer := 640;
	constant PIXELS_PER_LINE : integer := 800;
	constant HSYNC_FRONT_PORCH : integer := 16;
	constant HSYNC_WIDTH : integer := 96;
	constant HSYNC_BACK_PORCH : integer := 48;

-- 800x600
--	constant VISIBLE_LINES_PER_FRAME : integer := 600;
--	constant LINES_PER_FRAME : integer := 628;
--	constant VSYNC_FRONT_PORCH : integer := 1;
--	constant VSYNC_WIDTH : integer := 4;
--	constant VSYNC_BACK_PORCH : integer := 23;

--	constant VISIBLE_PIXELS_PER_LINE : integer := 800;
--	constant PIXELS_PER_LINE : integer := 1056;
--	constant HSYNC_FRONT_PORCH : integer := 40;
--	constant HSYNC_WIDTH : integer := 128;
--	constant HSYNC_BACK_PORCH : integer := 88;

-- 1280x1024 requires 108MHZ pixel clock
--constant VISIBLE_LINES_PER_FRAME : integer := 1024;
--constant LINES_PER_FRAME : integer := 1066;
--constant VSYNC_FRONT_PORCH : integer := 1;
--constant VSYNC_WIDTH : integer := 3;
--constant VSYNC_BACK_PORCH : integer := 38;
--
--constant VISIBLE_PIXELS_PER_LINE : integer := 1280;
--constant PIXELS_PER_LINE : integer := 1688;
--constant HSYNC_FRONT_PORCH : integer := 48;
--constant HSYNC_WIDTH : integer := 112;
--constant HSYNC_BACK_PORCH : integer := 248;

	constant TOP_VISIBLE_LINE : integer := VSYNC_FRONT_PORCH + VSYNC_WIDTH + VSYNC_BACK_PORCH;
	constant BOTTOM_VISIBLE_LINE : integer := TOP_VISIBLE_LINE + VISIBLE_LINES_PER_FRAME - 1;
	constant LEFT_VISIBLE_PIXEL : integer := HSYNC_FRONT_PORCH + HSYNC_WIDTH + HSYNC_BACK_PORCH;
	constant RIGHT_VISIBLE_PIXEL : integer := LEFT_VISIBLE_PIXEL + VISIBLE_PIXELS_PER_LINE - 1;

	constant BITS_PER_PIXEL : integer := 4;
	constant PIXELS_PER_WORD : integer := 8;

	type state_type is (WAIT4ACK, EXTRAWAIT, WAIT4NEXT);
	signal state : state_type;
	signal word_count : integer range 0 to VISIBLE_PIXELS_PER_LINE/PIXELS_PER_WORD-1;

	signal pixel : std_logic_vector(BITS_PER_PIXEL-1 downto 0);
	signal pixnum : integer range 0 to PIXELS_PER_WORD-1;
	signal offset : integer range 0 to VISIBLE_PIXELS_PER_LINE;
	signal pixels2 : std_logic_vector(BITS_PER_PIXEL*PIXELS_PER_WORD-1 downto 0);
	signal pixel_data : std_logic_vector(BITS_PER_PIXEL*PIXELS_PER_WORD-1 downto 0);

	signal bram_dia, bram_doa, bram_dib, bram_dob : std_logic_vector( 31 downto 0 );
	signal bram_dipa, bram_dipb : std_logic_vector( 3 downto 0 );
	signal bram_addra, bram_addrb : std_logic_vector( 8 downto 0 );
	signal bram_ena, bram_enb, bram_wea, bram_web : std_logic;

	type regArray is array(0 to VISIBLE_PIXELS_PER_LINE/PIXELS_PER_WORD-1) of std_logic_vector(BITS_PER_PIXEL*PIXELS_PER_WORD-1 downto 0);
	signal line_buffer : regArray;

  	signal pdata, rcount : std_logic_vector(7 downto 0);

	constant line_buffer_method : integer := 1;
	constant bram_buffer_method : integer := 0;

	signal rst_p : std_logic;
begin

	rst_p <= not rst_i;

	clk_divider : entity work.clock_divider
		generic map ( divisor => 2 )
		port map ( clk_in => clk_i, reset => rst_i, clk_out => pixel_clk );

	gen0: if ( line_buffer_method = 0 ) generate
		pixel_count_process: process( pixel_clk, rst_i )
			variable pixels1 : std_logic_vector(BITS_PER_PIXEL*PIXELS_PER_WORD-1 downto 0);
		begin
			if ( rst_i = '0' ) then
				pixel_count <= 0;
				state <= EXTRAWAIT;
				word_count <= 0;
			elsif ( pixel_clk'event and pixel_clk='1' ) then
			
				if ( pixel_count >= (LEFT_VISIBLE_PIXEL-PIXELS_PER_WORD) and pixel_count <= (RIGHT_VISIBLE_PIXEL-PIXELS_PER_WORD) ) then
					-- each memory word contains eight 4-bit pixels
					-- read the memory word PIXELS_PER_WORD pixel clocks before you need it and store it in pixels1

					if ( vdisplay_valid = '1' ) then 
						if ( state=EXTRAWAIT ) then
							word_count <= (offset + PIXELS_PER_WORD)/PIXELS_PER_WORD;
							state <= WAIT4ACK;
						elsif ( state=WAIT4ACK and ack_i='1' ) then
							pixels1 := pixel_data;
							state <= WAIT4NEXT;
						elsif ( state=WAIT4NEXT and (pixel_count mod PIXELS_PER_WORD)=(PIXELS_PER_WORD-1) ) then
							pixels2 <= pixels1;
							state <= EXTRAWAIT;
						end if;
					end if;

					pixel_count <= pixel_count + 1;
				elsif ( pixel_count = PIXELS_PER_LINE-1 ) then
					pixel_count <= 0;
				else
					pixel_count <= pixel_count + 1;
				end if;

			end if;
		end process;

		stb_o <= not hsync_internal and vdisplay_valid;
		cyc_o <= not hsync_internal and vdisplay_valid;
	end generate;

	gen1: if ( line_buffer_method = 1 ) generate

		-- the following process reads an entire line into the BRAM buffer
		line_read: process( clk_i, rst_i )
		begin
			if ( rst_i = '0' ) then
				state <= WAIT4ACK;
				word_count <= 0;
			elsif ( clk_i'event and clk_i='1' ) then

				case state is
				when WAIT4ACK =>
					if ( ack_i = '1' ) then
						if ( bram_buffer_method = 1 ) then
							state <= EXTRAWAIT;
							-- setup registered address and data for BRAM
							bram_addrb <= conv_std_logic_vector(word_count,9);
							bram_dib <= pixel_data;
						else
							line_buffer(word_count) <= pixel_data;
							word_count <= word_count + 1;
							if ( word_count = (VISIBLE_PIXELS_PER_LINE/PIXELS_PER_WORD)-1) then
								state <= WAIT4NEXT;
							else
								state <= WAIT4ACK;
							end if;
						end if;
					end if;

				-- this EXTRAWAIT state is necessary because the BRAM is clocked, 
				-- so the data will only be written to the BRAM one clock cycle later
				when EXTRAWAIT =>
						word_count <= word_count + 1;
						if ( word_count = (VISIBLE_PIXELS_PER_LINE/PIXELS_PER_WORD)-1) then
							state <= WAIT4NEXT;
						else
							state <= WAIT4ACK;
						end if;

				when WAIT4NEXT =>
					-- start at pixel count 1, so that the line count will have been set by then
					if ( pixel_count = 1 ) then
						state <= WAIT4ACK;
						word_count <= 0;
					end if;

			  	end case;
			end if;
		end process;

		pixel_count_process: process( pixel_clk, rst_i )
		begin
			if ( rst_i = '0' ) then
				pixel_count <= 0;
			elsif ( pixel_clk'event and pixel_clk='1' ) then
			
				if ( pixel_count = PIXELS_PER_LINE-1 ) then
					pixel_count <= 0;
				else
					pixel_count <= pixel_count + 1;
				end if;

			end if;
		end process;

		gen2: if ( bram_buffer_method = 1 ) generate
			bram : RAMB16_S36_S36
				port map ( DOA => bram_doa, DOB => bram_dob, ADDRA => bram_addra, ADDRB => bram_addrb,
							  CLKA => clk_i, CLKB => clk_i, DIA => bram_dia, DIPA => bram_dipa, DIB => bram_dib, DIPB => bram_dipb,
							  ENA => bram_ena, ENB => bram_enb, SSRA => rst_p, SSRB => rst_p,
							  WEA => bram_wea, WEB => bram_web );
			-- grab offset+1 because the BRAM is clocked, so the data we want to put in the pixels2 is the next
			-- pixel to display
			-- read from port A of the BRAM
			bram_addra <= conv_std_logic_vector((offset+1)/PIXELS_PER_WORD,9);
			bram_ena <= '1';
			bram_wea <= '0';
			bram_dia <= (others => '0');
			bram_dipa <= (others => '0');
			pixels2 <= bram_doa(BITS_PER_PIXEL*PIXELS_PER_WORD-1 downto 0);
			-- write to port B of the BRAM
			bram_enb <= '1';
			bram_web <= '1';
	  	end generate;

		gen3: if ( bram_buffer_method = 0 ) generate
			pixels2 <= line_buffer(offset/PIXELS_PER_WORD);
	  	end generate;

	stb_o <= '0' when state = WAIT4NEXT or line_count<TOP_VISIBLE_LINE else '1';
	cyc_o <= '0' when state = WAIT4NEXT or line_count<TOP_VISIBLE_LINE else '1';

	end generate;

	buffer_base <= X"00000000";
	adr_o <= buffer_base + ((line_count-TOP_VISIBLE_LINE)*VISIBLE_PIXELS_PER_LINE/PIXELS_PER_WORD + word_count)*4;
	we_o <= '0';

   pixel_data <= dat_i;

	offset <= pixel_count-LEFT_VISIBLE_PIXEL;
	pixnum <= offset mod PIXELS_PER_WORD;
	pixel <= pixels2(BITS_PER_PIXEL*pixnum+BITS_PER_PIXEL-1 downto BITS_PER_PIXEL*pixnum);

	vdisplay_valid <= '1' when (line_count >= TOP_VISIBLE_LINE and line_count <= BOTTOM_VISIBLE_LINE) else '0';
	hdisplay_valid <= '1' when (pixel_count >= LEFT_VISIBLE_PIXEL and pixel_count <= RIGHT_VISIBLE_PIXEL) else '0';
	display_valid <= hdisplay_valid and vdisplay_valid;
-- red <= pixel(7 downto 5) when display_valid = '1' else "000";
--	green <= pixel(4 downto 2) when display_valid = '1' else "000";
--	blue <= pixel(1 downto 0) when display_valid = '1' else "00";
	red <= pixel(3 downto 2) & "00" when display_valid = '1' else "0000";
	green <= pixel(1) & "000" when display_valid = '1' else "0000";
	blue <= pixel(0) & "000" when display_valid = '1' else "0000";

	hsync_internal <= '0' when pixel_count>=HSYNC_FRONT_PORCH and pixel_count < HSYNC_FRONT_PORCH+HSYNC_WIDTH else '1';
	hsync <= hsync_internal;

	line_count_process: process( pixel_clk, rst_i )
	begin
		if ( rst_i = '0' ) then
			line_count <= 0;
		elsif ( pixel_clk'event and pixel_clk='1' ) then
			if ( pixel_count = 0) then
				if ( line_count = LINES_PER_FRAME-1 ) then
					line_count <= 0;
				else
					line_count <= line_count + 1;
				end if;
			end if;
		end if;
	end process;

	vsync <= '0' when (line_count >= VSYNC_FRONT_PORCH and line_count < VSYNC_FRONT_PORCH+VSYNC_WIDTH) else '1';

end Behavioral;
