library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity pulse_generator is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        enable      : in std_logic;
        
        cycles_max  : in std_logic_vector(31 downto 0); 
        signal_out  : out std_logic
    );
    
end entity pulse_generator;

architecture behavioral of pulse_generator is

    signal pulse : std_logic := '0';
    signal count : integer := 0;
    signal cycles_max_int : integer := 0;

begin

    cycles_max_int <= CONV_INTEGER(unsigned(cycles_max)); 
    signal_out <= pulse;
    
    pulse_g : process(clk, rst)
    begin
        if (rst = '1') then
            count <= 0;
            pulse <= '0';
        
        elsif rising_edge(clk) then
            
            if enable ='1' then
                count <= count + 1;
                if (count >= cycles_max_int) then
                    pulse <= not pulse;
                    count <= 0;
                end if;
            end if;
        end if;
    end process ; -- pulse_g

end architecture ; -- behavioral
