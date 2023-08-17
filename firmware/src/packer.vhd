----------------------------------------------------------------------------------
-- Autor: Daniel Estrada Acevedo 
-- 
-- Create Date: 14.11.2020 00:00:13
-- Design Name: 
-- Module Name: packer - behavioral
-- Project Name: UCC_V2
-- Target Devices: 
-- Tool Versions: 1
-- Description: Auxiliary module to packer the detectors' counts in a single signal

-- Dependencies: 
-- 
-- Revision: 25.11.2020 21:47:13
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity packer is
  port (
		number_countsD1   : in std_logic_vector(31 downto 0);  -- individual detector 1 count
		number_countsD2   : in std_logic_vector(31 downto 0);  -- individual detector 2 count
		number_countsD3   : in std_logic_vector(31 downto 0);  -- individual detector 3 count
		number_countsD12  : in std_logic_vector(31 downto 0);  -- double count coincidence
		number_countsD13  : in std_logic_vector(31 downto 0);  -- double count coincidence
		number_countsD23  : in std_logic_vector(31 downto 0);  -- double count coincidence
		number_countsD123 : in std_logic_vector(31 downto 0);  -- triple count coincidence

        data_out 		  : out std_logic_vector(255 downto 0) -- pack of counts 
    );

end entity ; -- packer

architecture behavioral of packer is

begin

	data_out <= "000000000000000000000000" & "01000000" & number_countsD123 & number_countsD23 & number_countsD13 &
                 number_countsD12 & number_countsD3 & number_countsD2 & number_countsD1 ;

end architecture behavioral;