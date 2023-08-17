----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo 
-- 
-- Create Date: 23.10.2020 22:43:47
-- Design Name: 
-- Module Name: counter - Behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 8
-- Description: asynchronous counter with enable flag and reset signal
-- 
-- Dependencies: 
-- 
-- Revision: 25.11.2020 21:47:13
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;

entity counter is
  Port (
      rst           : in STD_LOGIC;  -- signal to clear counter (connect to clear_counts pin from time_window module)
      enb           : in STD_LOGIC;  -- enable flag (connect to large_tw_active pin from time_window module)
      
      signal_in     : in STD_LOGIC;  -- detector pulses
      number_counts : out STD_LOGIC_VECTOR(31 downto 0) -- number of counts     
   );
end counter;

architecture Behavioral of counter is

signal counter: integer := 0;

begin

  number_counts <= CONV_STD_LOGIC_VECTOR(counter,32);

  main:process(rst, enb, signal_in)
  begin
    
    if ( enb = '1' and rising_edge(signal_in) ) then
       counter <= counter + 1;
    end if;
    
    if ( rst = '1' ) then
      counter <= 0;
    end if;
    
  end process;

end Behavioral;

