--25/03/2017
--Medellin
--Universidad de Antioquia
----------------    Super_Uart   -------------------
--modulo serial el cual recive una cadena de string y su 
--tama�o puede ser modificado en N_bits, 
--de este mismo tama�o es el string enviado.
--se tiene dos se�ales de sincrinizacion para cada modulo 
--(Do_tx_string,Done_tx_string,Do_rx_string,Done_rx_string)
--el proceso Super_rx se le debe enviar un byte de mas 
-- N_bits / 8 = # caracteres
--baud : 9600

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;

entity Super_Uart is
	Generic ( N_bits : integer := 112);
	Port ( 
		CLK100MHZ : in STD_LOGIC;
		rst: in std_logic;
		UART_TXD_IN : in STD_LOGIC;
		UART_RXD_OUT : out STD_LOGIC;
		Do_tx_string : in STD_LOGIC;
		Done_tx_string : out STD_LOGIC;
		Super_string_tx :in std_logic_vector((N_bits-1) downto 0);

		Do_rx_string : in STD_LOGIC;
		Done_rx_string : out STD_LOGIC;
		Super_string_rx :out std_logic_vector((N_bits-1) downto 0)
		--			  sw : in STD_LOGIC;
		--           led : out STD_LOGIC
	);
end Super_Uart;

architecture Behavioral of Super_Uart is

component UARTReceiver is
    Generic ( baud : integer := 9600);
    Port ( UART_TXD_IN : in STD_LOGIC;
			CLK100MHZ : in STD_LOGIC;
			data_out : out STD_LOGIC_VECTOR (7 downto 0);
			data_ready : out STD_LOGIC);
end component;

component UARTTransmitter is
    Generic ( baud : integer := 9600);
    Port ( CLK100MHZ : in STD_LOGIC;
			UART_RXD_OUT : out STD_LOGIC;
			data_in : in STD_LOGIC_VECTOR (7 downto 0);
			uart_tx : in STD_LOGIC;
			uart_rdy : out STD_LOGIC);
end component;


--Signals Uart receiver
signal data_out : std_logic_vector(7 downto 0) := "00000000";
signal data_ready : std_logic := '0';

--Signals Uart Transmiter
signal data_in : std_logic_vector(7 downto 0) := "00000000";
signal uart_tx : std_logic := '0';
signal uart_rdy : std_logic := '0';

----Signals State_macghine_echo
--
--type estado_echo is (S0,S1);
--signal est_echo:estado_echo:= S0;

--Signals State_macghine_Super_tx

type estado_Super_tx is (S0,S1,S2,S3);
signal est_Super_tx:estado_Super_tx:= S0;

--Signals State_macghine_Super_rx

type estado_Super_rx is (S0,S1,S2,S3,S4);
signal est_Super_rx:estado_Super_rx:= S0;

--Signals Super_tx
--signal Do_tx_string   : std_logic := '0';
--signal Done_tx_string : std_logic := '0';
--signal N_bits : Integer := 128;
--signal Super_string_tx : std_logic_vector((N_bits-1) downto 0) := x"53414E544941474F53414E544941474F"; 
signal count_bits_tx : Integer := (N_bits-1); --se�al interna


--Signals Super_rx
--signal Do_rx_string   : std_logic := '0';
--signal Done_rx_string : std_logic := '0';
--signal Super_string_rx : std_logic_vector((N_bits-1) downto 0) := x"53414E544941474F53414E544941474F";
signal count_bits_rx : Integer := (N_bits-1); --se�al interna
signal byte_read: std_logic_vector(7 downto 0) := "00000000"; 



begin

--Super_string_tx <= Super_string_rx;

ur0 : UARTReceiver
port map (
    UART_TXD_IN => UART_TXD_IN,
    CLK100MHZ => CLK100MHZ,
    data_out => data_out,
    data_ready => data_ready
);


ut0 : UARTTransmitter
port map (
    CLK100MHZ => CLK100MHZ,
    UART_RXD_OUT => UART_RXD_OUT,
    data_in => data_in,
    uart_tx => uart_tx,
    uart_rdy => uart_rdy
);



--Echo:Process(CLK100MHZ,rst)
--begin
--	if rst = '1' then
--		est_echo <= S0;
--		elsif rising_edge(CLK100MHZ) then
--		  case est_echo is
--			
--			   when S0 =>
--				 uart_tx <= '0';
--				 data_in <= "00000000";				
--			    if(data_ready = '1') then
--				   data_in <= data_out;
--					est_echo <=S1;
--				 end if;
--			
--				when S1 =>	
--				 data_in <= data_in;
--				 if(uart_rdy = '1')then
--				   uart_tx <= '1';
--               est_echo <=S0;					
--				 end if;
--
--				 
--				when others =>
--				est_echo <= S0;
--		end case;
--	end if;
--end process;


Super_tx:Process(CLK100MHZ,rst)
begin
	if rst = '1' then
		est_Super_tx <= S0;
		elsif rising_edge(CLK100MHZ) then
			case est_Super_tx is
				when S0 =>
					Done_tx_string <= '0';
					if (Do_tx_string = '1') then
						est_Super_tx <= S1;
					end if;

				when S1 =>	
					uart_tx <= '0';
					data_in <= "00000000";
					if(count_bits_tx >= 7)then
						data_in <= Super_string_tx((count_bits_tx ) downto (count_bits_tx-7));
						count_bits_tx <= count_bits_tx - 8;
						est_Super_tx <= S2;
					else
						est_Super_tx <= S3; 
					end if;

--			   when S1 =>	
--       	    uart_tx <= '0';
--   			 data_in <= "00000000";
--				 if(count_bits_tx <= (N_bits-8))then
--				  data_in <= Super_string_tx((count_bits_tx + 7) downto (count_bits_tx));
--				  count_bits_tx <= count_bits_tx + 8;
--				  est_Super_tx <= S2;
--				 else
--				  est_Super_tx <= S3; 
--				 end if;

				when S2 =>	
					data_in <= data_in;
					if(uart_rdy = '1')then
						uart_tx <= '1';
						est_Super_tx <=S1;					
					end if;

				when S3 =>    --estado terminar 
					Done_tx_string <= '1';
					count_bits_tx <= (N_bits-1);
					if(Do_tx_string = '0')then 
						est_Super_tx <=S0;
					end if;

				when others =>
					est_Super_tx <= S0;
		end case;
	end if;

end process;

Super_rx:Process(CLK100MHZ,rst)
begin
	if rst = '1' then
		est_Super_rx <= S0;
		elsif rising_edge(CLK100MHZ) then
			case est_Super_rx is
				when S0 =>
					count_bits_rx <= (N_bits-1);
					Done_rx_string <= '0';
					if(Do_rx_string = '1') then
						est_Super_rx <=S1;
					end if;
			
				when S1 =>
					if(data_ready = '1') then
						byte_read <= data_out;
						est_Super_rx <=S2;
					end if;

				when S2 =>	
					if(count_bits_rx >= 7)then
						Super_string_rx((count_bits_rx) downto (count_bits_rx-7)) <= byte_read;	  
						count_bits_rx <= count_bits_rx - 8;
						est_Super_rx <= S3;
					else
						est_Super_rx <= S4; 
					end if;

				when S3 =>	
					if(data_ready = '0') then
						est_Super_rx <=S1;
					end if;

				when S4 =>    --estado terminar 
					Done_rx_string <= '1';
					count_bits_rx <= (N_bits-1);
					if(Do_rx_string = '0')then 
						est_Super_rx <=S0;
					end if;  

				when others =>
				est_Super_rx <= S0;
		end case;
	end if;
end process;


end Behavioral;