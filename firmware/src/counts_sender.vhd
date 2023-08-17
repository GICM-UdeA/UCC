----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo & Johny Jaramillo
-- 
-- Create Date: 14.11.2020 00:20:17
-- Design Name: 
-- Module Name: count_sender - behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 2
-- Description: synchronous module that writes eight 32-bit data to comblock_fifo 
--              memory, it have a do flag to begin the process
-- 
-- Dependencies: 
-- 
-- Revision: 25.11.2020 21:47:13
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity counts_sender is
  port (
        CLK          : in std_logic;  -- UCC system clock
        rst          : in std_logic;  -- reset signal 

        do_send      : in std_logic; -- do send flag (connect to send_data pin from time_window)

        pack_data_in : in std_logic_vector(255 downto 0) ; -- pack of counts with structure @C123C23C13C12C3C2C1 (connect to data_out pin from packer)
        data_out     : out std_logic_vector(31 downto 0); -- individual count 

        fifo_clk_o   : out std_logic -- fifo clock required signal 

        );
end entity ; -- counts_sender

architecture behavioral of counts_sender is

    signal send_counter : integer := 8;

    type sender_state is (S0, S1, S2);
    signal state : sender_state := S0;

begin

    main : process(CLK, rst)
        
        variable index : integer := 0;
    
    begin
        if (rising_edge(CLK)) then
            
            case state is
                when S0 =>
                    send_counter <= 8;
                    fifo_clk_o <= '0';
                    index := 0;
                    if (do_send = '1') then
                        state <= S1;
                    end if;

                when S1 =>
                    if (send_counter > 0) then
                        fifo_clk_o <= '0';
                        data_out <= data_in(index + 31 downto index);
                        index := index + 32;
                        send_counter <= send_counter - 1;
                        state <= S2;
                    else
                        state <= S0;    
                        
                    end if; 

                when S2 => 
                    fifo_clk_o <= '1';
                    state <= S1;

            end case;
        end if;
    end process ; -- main
    
end architecture behavioral;

