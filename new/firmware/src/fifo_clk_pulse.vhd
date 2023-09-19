----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo
-- 
-- Create Date: 27.11.2020 12:07:15
-- Design Name: 
-- Module Name: fifo_clk_pulse - behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 1
-- Description: synchronous module that generates a clock pulse for writing the fifo 

-- Dependencies: 
-- 
-- Revision: 27.11.2020 12:07:15
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fifo_clk_pulse is
  port (
        CLK         : in std_logic;  -- UCC system clock
        rst         : in std_logic;  -- reset signal 

        do          : in std_logic; -- do send flag (connect to send_data pin from time_window)

        fifo_clk_o  : out std_logic -- fifo clock required signal 

        );
end entity ; -- fifo_clk_pulse

architecture behavioral of fifo_clk_pulse is

    type sender_state is (S0, S1);
    signal state : sender_state := S0;

begin

    main : process(CLK, rst)    
    begin
        if (rising_edge(CLK)) then
            
            case state is
                when S0 =>
                    fifo_clk_o <= '0';
                    if (do_send = '1') then
                        state <= S1;
                    end if;

                when S1 =>
                    fifo_clk_o <= '1';
                    state <= S0;

            end case;
        end if;
    end process ; -- main
    
end architecture behavioral;

