----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo
-- 
-- Create Date: 27.11.2020 16:04:15
-- Design Name: 
-- Module Name: signal_simulator - behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 1
-- Description: period signal generator y, will be in state '1' during x 
--              cycles and at '0' during y-x cycles

-- Dependencies: 
-- 
-- Revision: 27.11.2020 16:04:15
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity signal_simulator is
  port (
        clk         : in std_logic; -- clock system
        rst         : in std_logic; -- reset signal 
        enable      : in std_logic; -- enable flag
        
        y_cycles    : in std_logic_vector(31 downto 0); -- signal period 
        x_cycles    : in std_logic_vector(31 downto 0); -- pulse duration

        Signal_out  : out std_logic -- simulated signal
  ) ;

end entity ; -- signal_simulator

architecture behavioral of signal_simulator is
    
    signal count : integer := 0;
    signal Pulse : std_logic := '0';

    signal count_max_y : integer;
    signal count_max_x : integer;

begin

    count_max_y <= CONV_INTEGER(unsigned(y_cycles));
    count_max_x <= CONV_INTEGER(unsigned(x_cycles));

    Signal_out <= Pulse;

    main : process(clk, rst)
    begin
        if (rst = '1') then
            count <= 0;
            Pulse <= '0';

        elsif rising_edge(clk) then
            
            if enable ='1' then
                count <= count + 1;
                
                if (count < count_max_y) then
                    if (count < count_max_x) then
                    Pulse <= '1';
                    else
                        Pulse <= '0';
                    end if; 
                else
                    count <= 0;
                end if;
                
            end if;
        end if;
    end process ; -- main
    
end architecture behavioral;