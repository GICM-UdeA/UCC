----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2019 18:49:17
-- Design Name: 
-- Module Name: counter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
Port (
      CLK100MHZ: in STD_LOGIC;
      rst: in std_logic;
      
      entrada:in STD_LOGIC;
      num_cuentas: out integer;  
      
      win_on: in STD_LOGIC;
      --borrar: in STD_LOGIC;
      
      Do_coun_coin: in STD_LOGIC;
      Done_coun_coin : out STD_LOGIC
   );
end counter;

architecture Behavioral of counter is
-- signal
signal count: integer :=0;

begin

main:process(rst,Do_coun_coin,Win_ON,entrada,count)
begin

	
	if ( (Win_ON = '1') and (Do_coun_coin = '1') and (rising_edge(entrada))) then
      count <= count + 1;
	end if;
	
	if (Do_coun_coin = '0' ) then
      count <= 0;
      Done_coun_coin <= '0'; 
      num_cuentas <= 0;
	
   elsif (Win_ON = '0') then
      num_cuentas <= count;
      Done_coun_coin <= '1';
	end if;
	
end process;

end Behavioral;


--main:Process(CLK100MHZ,rst)
--begin
--	if (rst = '1' or Do_coun_coin = '0') then
--	    count <= 0;
--	    num_cuentas <= 0;
--	    Done_coun_coin <= '0';
--	   elsif (rising_edge(entrada) and Win_ON = '1') then
--	       count <= count + 1;
--		   Done_coun_coin <= '0';
--		 else 

--	end if;
			
--				when S1 =>
--				 if(rising_edge(entrada)) then
--				     if Win_ON = '1' then
--				        count <= count + 1;
--				        est_coun_coin  <= S1;
--				        Done_coun_coin <= '0';
--				      else
--				        num_cuentas <= count;
--				        Done_coun_coin <= '1';
--				        est_coun_coin  <= S2;
--				     end if;
--				 end if;

--				 when S2 =>
--				    if Do_coun_coin = '0' then
--				        est_coun_coin <= S0;
--				    end if;				 

--				when others =>
--				 est_coun_coin <= S0;
--			end case;
--	end if;
--end process;

--main:Process(CLK100MHZ,rst)
--begin
--	if rst = '1' then
--		est_coun_coin <= S0;
--		elsif rising_edge(CLK100MHZ) then
--			case est_coun_coin is

--			   when S0 =>
--					 count <= 0;
--					 num_cuentas <= 0;
--					 Done_coun_coin <= '0';
--				 if (Do_coun_coin = '1' and Win_ON = '1')then
--				    est_coun_coin <= S1;
--				 end if;

--				when S1 =>
--				 if(rising_edge(entrada)) then
--				     if Win_ON = '1' then
--				        count <= count + 1;
--				        est_coun_coin  <= S1;
--				        Done_coun_coin <= '0';
--				      else
--				        num_cuentas <= count;
--				        Done_coun_coin <= '1';
--				        est_coun_coin  <= S2;
--				     end if;
--				 end if;

--				 when S2 =>
--				    if Do_coun_coin = '0' then
--				        est_coun_coin <= S0;
--				    end if;				 

--				when others =>
--				 est_coun_coin <= S0;
--			end case;
--	end if;
--end process;



--main2:Process(CLK100MHZ,rst)
--begin
--    if((rising_edge(entrada)) and (Win_ON = '1')) then
--        count <= count + 1;
--        est_coun_coin  <= S1;
--        Done_coun_coin <= '0';
--      elsif ((Do_coun_coin = '0') and (Win_ON = '0')) then
--        num_cuentas <= count;
--        Done_coun_coin <= '1';
--        est_coun_coin  <= S2;
--    end if;

--end process;




