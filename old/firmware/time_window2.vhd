----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2019 10:03:31
-- Design Name: 
-- Module Name: time_window - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_window is
Port ( 
        CLK: in STD_LOGIC;
        rst		  	: in std_logic;
        
        cycles_time      :in STD_LOGIC_VECTOR(31 downto 0);  -- es el entero que representa el numero de CICLOS DE RELOJ 
        cycles_scale     :in STD_LOGIC_VECTOR(31 downto 0); --es un entero que tepresenta el numero de veces que se repite el ciclo de tiempo
        
        TW_on	:out STD_LOGIC;
        
        Do_TW		: in STD_LOGIC;
        Done_TW 	: out STD_LOGIC
      );
end time_window;

architecture Behavioral of time_window is

-- signal
signal counter_time: integer := 0;
signal counter_scale: integer := 0;

signal cycles_time_int: integer := 0;
signal cycles_scale_int: integer := 0;


--STATE MACHINE
type estado_windows_time is (S0,S1,S2,S3);
signal est_windows_time:estado_windows_time:= S0;

begin

cycles_time_int <= CONV_INTEGER(unsigned(cycles_time));
cycles_scale_int <= CONV_INTEGER(unsigned(cycles_scale));

wt:Process(CLK,rst)
begin
	if rst = '1' then
		est_windows_time <= S0;
		elsif rising_edge(CLK) then
		  case est_windows_time is	
			   when S0 =>
					Done_TW <= '0';
					counter_time	<= 0;
					counter_scale	<= 0;
					TW_on  <= '0';

					if Do_TW = '1' then
						est_windows_time <=S1;
					end if;
			   
			   when S1 =>
					if (counter_scale >= cycles_scale_int) then
					    counter_scale	<= 0;
					    TW_on <= '0';
						est_windows_time <= S2;
					  else 
						TW_on <= '1';
						if(counter_time >= (cycles_time_int-1)) then   --Maybe I should put cycles_time_int-1???
						  counter_time   <= 0;
						  counter_scale <= counter_scale + 1;						
					     else
					      counter_time <= counter_time + 1;	
					    end if;
					end if;

				when S2 =>
					Done_TW <= '1';
					if(Do_TW = '0')then 
						est_windows_time <=S0;
					end if;
					
				when others =>
					est_windows_time <= S0;
		end case;
	end if;
end process;

end Behavioral;
