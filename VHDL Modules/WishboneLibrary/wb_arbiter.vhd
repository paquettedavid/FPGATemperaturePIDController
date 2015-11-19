----------------------------------------------------------------------
-- Module name:     ARB0001a.VHD
--
-- Description:     A four level, round-robin arbiter.  For more infor-
--                  mation, please refer to the WISHBONE Public Domain
--                  Library Technical Reference Manual.
--
-- History:         Project complete:           SEP 14, 2001
--                                              WD Peterson
--                                              Silicore Corporation
--
--						  modified for use in ECE280	SEP 18, 2006
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
-- Entity declaration.
----------------------------------------------------------------------

entity wb_arbiter is
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

end entity wb_arbiter;


----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture ARB0001a1 of wb_arbiter is


    ------------------------------------------------------------------
    -- Define internal signals.
    ------------------------------------------------------------------

    signal  BEG:        std_logic;
    signal  EDGE:       std_logic;
    signal  LGNT:       std_logic_vector( 1 downto 0 );
    signal  LGNT0:      std_logic;
    signal  LGNT1:      std_logic;
    signal  LGNT2:      std_logic;
    signal  LGNT3:      std_logic;
    signal  LCOMCYC:    std_logic;
    signal  LASMAS:     std_logic;
    signal  LMAS0:      std_logic;
    signal  LMAS1:      std_logic;
	 signal  RST:			std_logic;

begin

	RST <= not nRST;

    ------------------------------------------------------------------
    -- Arbitration logic (registered output).
    ------------------------------------------------------------------

    ARBITER_REGISTERS: process( CLK )
    begin                                     

        if( rising_edge( CLK ) ) then

            LGNT0 <= ( not(RST) and not(LCOMCYC) and not(LMAS1) and not(LMAS0) and not(CYC3) and not(CYC2) and not(CYC1) and     CYC0  )
                  or ( not(RST) and not(LCOMCYC) and not(LMAS1) and     LMAS0  and not(CYC3) and not(CYC2)               and     CYC0  )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and not(LMAS0) and not(CYC3)                             and     CYC0  )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and     LMAS0                                            and     CYC0  )
                  or ( not(RST) and     LCOMCYC  and LGNT0 );

            LGNT1 <= ( not(RST) and not(LCOMCYC) and not(LMAS1) and not(LMAS0)                             and     CYC1                )
                  or ( not(RST) and not(LCOMCYC) and not(LMAS1) and     LMAS0  and not(CYC3) and not(CYC2) and     CYC1  and not(CYC0) )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and not(LMAS0) and not(CYC3)               and     CYC1  and not(CYC0) )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and     LMAS0                              and     CYC1  and not(CYC0) )
                  or ( not(RST) and     LCOMCYC  and LGNT1 );

            LGNT2 <= ( not(RST) and not(LCOMCYC) and not(LMAS1) and not(LMAS0)               and     CYC2  and not(CYC1)               )
                  or ( not(RST) and not(LCOMCYC) and not(LMAS1) and     LMAS0                and     CYC2                              )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and not(LMAS0) and not(CYC3) and     CYC2  and not(CYC1) and not(CYC0) )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and     LMAS0                and     CYC2  and not(CYC1) and not(CYC0) )
                  or ( not(RST) and     LCOMCYC  and LGNT2 );

            LGNT3 <= ( not(RST) and not(LCOMCYC) and not(LMAS1) and not(LMAS0) and     CYC3  and not(CYC2) and not(CYC1)               )
                  or ( not(RST) and not(LCOMCYC) and not(LMAS1) and     LMAS0  and     CYC3  and not(CYC2)                             )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and not(LMAS0) and     CYC3                                            )
                  or ( not(RST) and not(LCOMCYC) and     LMAS1  and     LMAS0  and     CYC3  and not(CYC2) and not(CYC1) and not(CYC0) )
                  or ( not(RST) and     LCOMCYC  and LGNT3 );

        end if;

    end process ARBITER_REGISTERS;


    ------------------------------------------------------------------
    -- LASMAS state machine.
    ------------------------------------------------------------------

    BEG_LOGIC: process( CYC3, CYC2, CYC1, CYC0, LCOMCYC )
    begin                                     

        BEG <= ( CYC3 or CYC2 or CYC1 or CYC0 ) and not( LCOMCYC );

    end process BEG_LOGIC;


    LASMAS_STATE_MACHINE: process( CLK )
    begin                                     

        if( rising_edge( CLK ) ) then

            LASMAS <= ( BEG and not( EDGE ) and not( LASMAS ) );

            EDGE   <= ( BEG and not( EDGE ) and      LASMAS   ) 
                   or ( BEG and      EDGE   and not( LASMAS ) );

        end if;

    end process LASMAS_STATE_MACHINE;


    ------------------------------------------------------------------
    -- COMCYC logic.
    ------------------------------------------------------------------

    COMCYC_LOGIC: process( CYC3, CYC2, CYC1, CYC0, LGNT3, LGNT2, LGNT1, LGNT0 )
    begin                                     

        LCOMCYC <= ( CYC3 and LGNT3 )
                or ( CYC2 and LGNT2 )
                or ( CYC1 and LGNT1 )
                or ( CYC0 and LGNT0 );

    end process COMCYC_LOGIC;


    ------------------------------------------------------------------
    -- Encoder logic.
    ------------------------------------------------------------------

    ENCODER_LOGIC: process( LGNT3, LGNT2, LGNT1, LGNT0 )
    begin                                     

        LGNT(1) <=   LGNT3 or LGNT2;
        LGNT(0) <=   LGNT3 or LGNT1;

    end process ENCODER_LOGIC;


    ------------------------------------------------------------------
    -- LMAS register.
    ------------------------------------------------------------------

    LMAS_REGISTER: process( CLK )
    begin                                     

        if( rising_edge( CLK ) ) then

            if( RST = '1' ) then
                LMAS1 <= '0';
                LMAS0 <= '0';
            elsif( LASMAS = '1' ) then
                LMAS1 <= LGNT(1);
                LMAS0 <= LGNT(0);
            else
                LMAS1 <= LMAS1;
                LMAS0 <= LMAS0;
            end if;

        end if;

    end process LMAS_REGISTER;


    ------------------------------------------------------------------
    -- Make local signals visible outside of the entity.
    ------------------------------------------------------------------

    MAKE_VISIBLE: process( LCOMCYC, LGNT, LGNT0, LGNT1, LGNT2, LGNT3 )
    begin                                     

        COMCYC <= LCOMCYC;
        GNT(1) <= LGNT(1);
        GNT(0) <= LGNT(0);
        GNT3   <= LGNT3;
        GNT2   <= LGNT2;
        GNT1   <= LGNT1;
        GNT0   <= LGNT0;

    end process MAKE_VISIBLE;

end architecture ARB0001a1;
