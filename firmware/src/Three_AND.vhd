----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo 
-- 
-- Create Date: 5.11.2020 10:34:13
-- Design Name: 
-- Module Name: Three_AND - Behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 1
-- Description: Auxiliary module to do triple detector coincidence 

-- Dependencies: 
-- 
-- Revision: 5.11.2020 10:47:10
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Three_AND is
    Port ( signal1  : in STD_LOGIC;
           signal2  : in STD_LOGIC;
           signal3  : in STD_LOGIC;
           
           signal123: out STD_LOGIC
           );
end Three_AND;

architecture Behavioral of Three_AND is

begin
    signal123 <= signal1 and signal2 and signal3;
    
end Behavioral;
