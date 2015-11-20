----------------------------------------------------------------------
-- Module name:     ICN0002a.VHD
--
-- Description:     WISHBONE 4 X 4 shared bus interconnection.  For
--                  more information, please refer to the WISHBONE
--                  Public Domain Library Technical Reference Manual.
--
-- History:         Project complete:           SEP 20, 2001
--                                              WD Peterson
--                                              Silicore Corporation
--
--                  Fix minor typos:            10 JUN 2003
--                                              WD Peterson
--                                              Silicore Corporation
--
--						  modified for use in ECE280	18 SEP 2006
--																John A. Chandy
--																University of Connecticut
--
-- Release:         Notice is hereby given that this document is not
--                  copyrighted, and has been placed into the public
--                  domain.  It may be freely copied and distributed
--                  by any means.
--
-- Disclaimer:      In no event shall Silicore Corporation be liable
--                  for incidental, consequential, indirect or special
--                  damages resulting from the use of this file.  The
--                  user assumes all responsibility for its use.
--
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Load the IEEE 1164 library and make it visible.
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------------
-- Entity declaration.  The input and output signals from the system
-- are declared here.
----------------------------------------------------------------------

entity wb_intercon is
	generic  (num_addr_bits : positive := 32; num_data_bits : positive := 32);
    port (
     		   ACK_I_M:    out std_logic_vector(3 downto 0);
    		   ACK_O_S:    in std_logic_vector(3 downto 0);
    		   ADR_O_M0:   in std_logic_vector( num_addr_bits-1 downto 0 );
    		   ADR_O_M1:   in std_logic_vector( num_addr_bits-1 downto 0 );
    		   ADR_O_M2:   in std_logic_vector( num_addr_bits-1 downto 0 );
    		   ADR_O_M3:   in std_logic_vector( num_addr_bits-1 downto 0 );
     		   ADR_I_S:    out std_logic_vector( num_addr_bits-1 downto 0 );
   		   CYC_O_M:    in std_logic_vector(3 downto 0);
    		   DAT_O_M0:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_M1:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_M2:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_M3:   in std_logic_vector( num_data_bits-1 downto 0 );
   		   DWR:   		out std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_S0:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_S1:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_S2:   in std_logic_vector( num_data_bits-1 downto 0 );
    		   DAT_O_S3:   in std_logic_vector( num_data_bits-1 downto 0 );
   		   DRD:   		out std_logic_vector( num_data_bits-1 downto 0 );
			   IRQ_O_S:		in std_logic_vector(3 downto 0) := "0000";
			   IRQ_I_M:		out std_logic;
			   IRQV_I_M:	out std_logic_vector(1 downto 0);
				STB_I_S:		out std_logic_vector(3 downto 0);
				STB_O_M:		in std_logic_vector(3 downto 0);
				WE_O_M:		in std_logic_vector(3 downto 0);
				WE:		   out std_logic;
    		   CLK:        in std_logic;
    		   RST:        in std_logic
        );

end entity wb_intercon;



----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture ICN0002a1 of wb_intercon is

    ------------------------------------------------------------------
    -- Define the Arbiter as an ARB0001a.  This is a four level
    -- round-robin arbiter.
    ------------------------------------------------------------------

    component wb_arbiter
    port(
            CLK:        in  std_logic;
            COMCYC:     out std_logic;
            CYC3:       in  std_logic;
            CYC2:       in  std_logic;
            CYC1:       in  std_logic;
            CYC0:       in  std_logic;
            GNT:        out std_logic_vector( 1 downto 0 );
            GNT3:       out std_logic;
            GNT2:       out std_logic;
            GNT1:       out std_logic;
            GNT0:       out std_logic;
            nRST:       in  std_logic
         );
    end component wb_arbiter;


    ------------------------------------------------------------------
    -- Define internal signals.
    ------------------------------------------------------------------

    signal  ACK:        std_logic;
    signal  ACMP0:      std_logic;
    signal  ACMP1:      std_logic;
    signal  ACMP2:      std_logic;
    signal  ACMP3:      std_logic;
    signal  ADR:		   std_logic_vector( num_addr_bits-1 downto 0 );
    signal  DAT_RD:	   std_logic_vector( num_data_bits-1 downto 0 );
    signal  CYC:        std_logic;
    signal  GNT:        std_logic_vector(  1 downto 0 );
    signal  GNT0:       std_logic;
    signal  GNT1:       std_logic;
    signal  GNT2:       std_logic;
    signal  GNT3:       std_logic;
    signal  STB:        std_logic;
	 signal	STB_S:		std_logic_vector(3 downto 0);


begin

    U08: component wb_arbiter
    port map(
                CLK     =>  CLK,
                COMCYC  =>  CYC,
                CYC3    =>  CYC_O_M(3),
                CYC2    =>  CYC_O_M(2),
                CYC1    =>  CYC_O_M(1),
                CYC0    =>  CYC_O_M(0),
                GNT     =>  GNT,
                GNT3    =>  GNT3,
                GNT2    =>  GNT2,
                GNT1    =>  GNT1,
                GNT0    =>  GNT0,
                nRST    =>  RST
             );


    ------------------------------------------------------------------
    -- Generate the address comparator and SLAVE decoders.
    ------------------------------------------------------------------

    ADR_CMP: process( ADR )
    begin

        ACMP3 <=      ADR(num_addr_bits-1)   and      ADR(num_addr_bits-2)  ;
        ACMP2 <=      ADR(num_addr_bits-1)   and not( ADR(num_addr_bits-2) );
        ACMP1 <= not( ADR(num_addr_bits-1) ) and      ADR(num_addr_bits-2)  ;
        ACMP0 <= not( ADR(num_addr_bits-1) ) and not( ADR(num_addr_bits-2) );

    end process ADR_CMP;


    ADR_DEC: process( ACMP3, ACMP2, ACMP1, ACMP0, CYC, STB )
    begin

        STB_S(3) <= CYC and STB and ACMP3;
        STB_S(2) <= CYC and STB and ACMP2;
        STB_S(1) <= CYC and STB and ACMP1;
        STB_S(0) <= CYC and STB and ACMP0;
        
    end process ADR_DEC;

	STB_I_S <= STB_S;

    ------------------------------------------------------------------
    -- Generate the ACK signals.
    ------------------------------------------------------------------

    ACK_GEN: process( ACK_O_S, STB_S )
    begin

        ACK <= (ACK_O_S(3) and STB_S(3)) or 
					(ACK_O_S(2) and STB_S(2)) or
					(ACK_O_S(1) and STB_S(1)) or
					(ACK_O_S(0) and STB_S(0));
        
    end process ACK_GEN;


    ACK_RCV: process( ACK, GNT3, GNT2, GNT1, GNT0 )
    begin

        ACK_I_M(3) <= ACK and GNT3;
        ACK_I_M(2) <= ACK and GNT2;
        ACK_I_M(1) <= ACK and GNT1;
        ACK_I_M(0) <= ACK and GNT0;

    end process ACK_RCV;


    ------------------------------------------------------------------
    -- Create the signal multiplexors.
    ------------------------------------------------------------------

    ADR_MUX: process( ADR_O_M3, ADR_O_M2, ADR_O_M1, ADR_O_M0, GNT )
    begin                                     

        case GNT is
            when B"00" =>  ADR <= ADR_O_M0;
            when B"01" =>  ADR <= ADR_O_M1;
            when B"10" =>  ADR <= ADR_O_M2;
            when others => ADR <= ADR_O_M3;
        end case;

    end process ADR_MUX;
	 ADR_I_S <= ADR;


    DRD_MUX: process( DAT_O_S3, DAT_O_S2, DAT_O_S1, DAT_O_S0, ADR )
	 	variable TOPADR : std_logic_vector(1 downto 0);
    begin                                     
		  TOPADR := ADR( num_addr_bits-1 downto num_addr_bits-2 );
        case TOPADR is
            when B"00" =>  DAT_RD <= DAT_O_S0;
            when B"01" =>  DAT_RD <= DAT_O_S1;
            when B"10" =>  DAT_RD <= DAT_O_S2;
            when others => DAT_RD <= DAT_O_S3;
        end case;
    end process DRD_MUX;

	 DRD <= DAT_RD;

    DWR_MUX: process( DAT_O_M3, DAT_O_M2, DAT_O_M1, DAT_O_M0, GNT )
    begin                                     

        case GNT is
            when B"00" =>  DWR <= DAT_O_M0;
            when B"01" =>  DWR <= DAT_O_M1;
            when B"10" =>  DWR <= DAT_O_M2;
            when others => DWR <= DAT_O_M3;
        end case;

    end process DWR_MUX;


    STB_MUX: process( STB_O_M, GNT )
    begin                                     

        case GNT is
            when B"00" =>  STB <= STB_O_M(0);
            when B"01" =>  STB <= STB_O_M(1);
            when B"10" =>  STB <= STB_O_M(2);
            when others => STB <= STB_O_M(3);
        end case;

    end process STB_MUX;


    WE_MUX: process( WE_O_M, GNT )
    begin                                     

        case GNT is
            when B"00" =>  WE <= WE_O_M(0);
            when B"01" =>  WE <= WE_O_M(1);
            when B"10" =>  WE <= WE_O_M(2);
            when others => WE <= WE_O_M(3);
        end case;

    end process WE_MUX;

    ------------------------------------------------------------------
    -- Generate the IRQ signals.
    ------------------------------------------------------------------

    IRQ_GEN: process( IRQ_O_S )
    begin

        IRQ_I_M <= IRQ_O_S(3) or IRQ_O_S(2) or IRQ_O_S(1) or IRQ_O_S(0);
        
    end process IRQ_GEN;


    IRQV: process( IRQ_O_S )
    begin

		  case IRQ_O_S is
				when B"0001" => IRQV_I_M <= "00";
				when B"0010" => IRQV_I_M <= "01";
				when B"0100" => IRQV_I_M <= "10";
				when B"1000" => IRQV_I_M <= "11";
				when others  => IRQV_I_M <= "00";
		  end case;

    end process IRQV;



end architecture ICN0002a1;

