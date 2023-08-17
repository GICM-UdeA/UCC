----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo & Johny Jaramillo
-- 
-- Create Date: 25.11.2020 16:36:09
-- Design Name: 
-- Module Name: time_window - behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 3
-- Description: count window manager module, in a large time window
--  			there are N short time window in which the current detectors counts 
-- 				are sent
--				
--				N = large_tw_counter / short_tw_counter  

-- Dependencies: 
-- 
-- Revision: 25.11.2020 11:13:45
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;

entity time_window is
Port ( 
        CLK 				 : in STD_LOGIC; -- UCC system clock
        rst 		  		 : in std_logic; -- reset signal
        
        large_tw_counter_max    : in STD_LOGIC_VECTOR(31 downto 0); -- counter equivalent to large time window
        short_tw_counter_max : in STD_LOGIC_VECTOR(31 downto 0); -- counter equivalent to short time window
        
        large_tw_active	 	 : out STD_LOGIC; -- signal to enable the counters 
        send_data 			 : out STD_LOGIC; -- signal to enable send a data package 
        
        Do_time_windows	 	 : in STD_LOGIC; -- do flag (connect to do_time_window pin from UCC_controler)
        Done_time_windows	 : out STD_LOGIC -- done flag 
      );
end entity time_window;


architecture behavioral of time_window is

	--signals
	signal counter_large_w: integer := 0; -- large window counter 
	signal counter_short_w: integer := 0; -- short window counter 

	signal large_tw_counter_max_int: integer := 0; -- end large window indicator
	signal short_tw_counter_max_int: integer := 0; -- end short window indicator

	--STATE MACHINE
	type time_window_states is (S0,S1,S2);
	signal tw_state : time_window_states := S0;

begin

	large_tw_counter_max_int <= CONV_INTEGER(unsigned(large_tw_counter_max));
	short_tw_counter_max_int <= CONV_INTEGER(unsigned(short_tw_counter_max));

	main:Process(CLK,rst)
	
	begin
		if rst = '1' then
			tw_state <= S0;

		elsif rising_edge(CLK) then
		  
		  case tw_state is	
			   when S0 =>
					Done_time_windows<= '0';
					counter_large_w <= 0;
					counter_short_w <= 0;
					large_tw_active <= '0';
					send_data <= '0';

					if Do_time_windows = '1' then
						tw_state <=S1;
					end if;
			   
			   when S1 =>
			   		-- if the large window is finished stop
					if (counter_large_w >= large_tw_counter_max_int) then
					    counter_large_w <= 0;
					    large_tw_active <= '0';
						tw_state <= S2;
					else 
						large_tw_active <= '1';
						counter_large_w <= counter_large_w + 1;
						
						-- if the short window is finished send the counts
						if (counter_short_w >= short_tw_counter_max_int-1) then 
							send_data <= '1';
							counter_short_w <= 0;
						else
							counter_short_w <= counter_short_w + 1;
							send_data <= '0';
									
						end if;

					end if;

				when S2 =>
					Done_time_windows<= '1';
					if(Do_time_windows = '0')then 
						tw_state <=S0;
					end if;
					
				when others =>
					tw_state <= S0;
			
			end case;
		end if;
	end process;
	
end architecture behavioral;