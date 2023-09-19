----------------------------------------------------------------------------------
-- Autors: Daniel Estrada Acevedo & Johny Jaramillo
-- 
-- Create Date: 25.11.2020 15:40:45
-- Design Name: 
-- Module Name: UCC_controler - Behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 3
-- Description: control module, clears the counters and starts the time window
-- 
-- Dependencies: 
-- 
-- Revision: 26.11.2020 00:09:18
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UCC_controler is
    Port ( CLK                : in STD_LOGIC; -- UCC system clock
           rst                : in STD_LOGIC; -- reset signal

           Do_UCC_controler   : in STD_LOGIC; -- do flag
           Done_UCC_controler : out STD_LOGIC; -- done flag
   
           clear_counts       : out STD_LOGIC; -- signal to reset the counter 
           
           do_time_windows    : out STD_LOGIC; -- signal to activate the time windows
           done_time_windows  : in STD_LOGIC -- time window end indicator (connect to Done_time_window pin from time_window)
           );
end UCC_controler;

architecture Behavioral of UCC_controler is
    
  type control_state is (S0, S1, S2, S3);
  signal state : control_state := S0;

begin

  main : process(CLK, rst)

  begin
    
    if (rst = '1') then
      state <= S0;

    elsif (rising_edge(CLK)) then
      
      case (state) is
        when S0 =>
          clear_counts       <= '1';
          do_time_windows    <= '0';
          Done_UCC_controler <= '0';

          if (Do_UCC_controler = '1') then
            state <= S1;
          end if;

        when S1 =>
          clear_counts <= '0';
          do_time_windows <= '1';
          state <= S2;
          
        when S2 => 
          if (done_time_windows = '1') then
            do_time_windows <= '0';
            state <= S3;

          end if;

        when S3 => 
          Done_UCC_controler <= '1';
          if (Do_UCC_controler = '0') then
            state <= S0;
          end if;

      end case;
    
    end if;
  end process ; -- main


end Behavioral;
