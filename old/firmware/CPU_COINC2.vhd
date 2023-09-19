--modificaci�n de COM_DIV para volverlo cpu


--Este programa recibe un string con formato "com NUMERO(14)", y devuelve 3 variables de salida (numero, comando,tiempo)
--con flags tipicas Do_UCC_SING, y Done_UCC_SING (Banderas de control).
-- ojo si se cambia n_bits, se debe cambiar el 24 proviente de 3caracteres por 8 bits cada uno,  en la definici�n de la se�al
-- estar atento al  orden de las variables a llevar a rx y tx.

--JohnyJaramillo
--22/09/2019

--Revisado
---- Daniel Estrada
---- 19/09/2023 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity UCC_SING is
	Generic ( N_bits : integer := 112);---14 bytes
	Port ( 
		CLK100MHZ: in STD_LOGIC;
		rst: in std_logic;

		UART_TXD_IN : in STD_LOGIC;
		UART_RXD_OUT : out STD_LOGIC;

		signal1:in STD_LOGIC;		--puertos de entrada FPGA
		signal2:in STD_LOGIC;
		signal3:in STD_LOGIC;
		signal4:OUT STD_LOGIC;

		----visualizacion en puertos de FPGA
		led0:out STD_LOGIC; 	--TW
		led1:out STD_LOGIC;	--DO_UCC --signal1
		--led2:out STD_LOGIC;	--signal2
		--led3:out STD_LOGIC;	--signal3
		--led4:out STD_LOGIC;	--signal4
		--led5:out STD_LOGIC;	--1Y2
		--led6:out STD_LOGIC;	--2Y4
		--led7:out STD_LOGIC;	--1Y4
		--led8:out STD_LOGIC;	--2Y3
		--led9:out STD_LOGIC;	--1Y2Y3
		--led10:out STD_LOGIC;	--1Y2Y4

		--led_ventana_UCC_SING: out STD_LOGIC;
		--coincidencia_UCC_SING: out STD_LOGIC;

		Do_UCC_SING : in STD_LOGIC;
		Done_UCC_SING : out STD_LOGIC
);

end UCC_SING;


architecture Behavioral of UCC_SING is

--componentes a ser usados en el programa principal
--Super_Uart= Protocolo para leer tramas (enviar y recibir) con tama�o de N_bits 
component Super_Uart is

	Generic ( N_bits : integer := 112);  ---14 bytes
	Port ( 
		CLK100MHZ :  in STD_LOGIC;
		rst: 	    in std_logic;
			
		UART_TXD_IN : in STD_LOGIC;
		UART_RXD_OUT :out STD_LOGIC;
			
		Do_tx_string :in STD_LOGIC;
		Done_tx_string:out STD_LOGIC;
		Do_rx_string :in STD_LOGIC;
		Done_rx_string :out STD_LOGIC;
			
		Super_string_rx :out std_logic_vector((N_bits-1) downto 0);
		Super_string_tx :in std_logic_vector((N_bits-1) downto 0)
			);
end component;

--Contador de eventos individuales
component counter is
		Port ( 
			CLK100MHZ	: in STD_LOGIC;
			rst		  	: in std_logic;
					
			entrada:in STD_LOGIC;
			num_cuentas: out integer;  
			
			win_on: in STD_LOGIC;
			--borrar: in STD_LOGIC;
			
			Do_coun_coin: in STD_LOGIC;
			Done_coun_coin : out STD_LOGIC
			);
end component;

component time_window is
        Port ( 
            CLK	: in STD_LOGIC;
            rst		  	: in std_logic;
            
            cycles_time      :in STD_LOGIC_VECTOR(31 downto 0);  -- es el entero que representa el numero de CICLOS DE RELOJ 
            cycles_scale      :in STD_LOGIC_VECTOR(31 downto 0); --es un entero que tepresenta el numero de veces que se repite el ciclo de tiempo
            
            TW_on 	:out STD_LOGIC;
            
            Do_TW		: in STD_LOGIC;
			Done_TW 	: out STD_LOGIC
		);
end component;



-- se�ales ha ser usadas en el programa principal
--SIGNALS
signal Do_tx_string   : std_logic := '0';
signal Done_tx_string : std_logic := '0';

signal Do_rx_string   : std_logic := '0';
signal Done_rx_string : std_logic := '0';

signal Super_string_rx :std_logic_vector((N_bits-1) downto 0);
signal Super_string_tx :std_logic_vector((N_bits-1) downto 0);

signal Super_string_tx_test :std_logic_vector((N_bits-1) downto 0);





--Salida modulo
signal Comand :  STD_LOGIC_VECTOR(31 downto 0);   -- ojo 31 proviende de 4 caracteres por 8 bits cada uno, si se cambia n_bits esto se debe cambiar
signal Number :  STD_LOGIC_VECTOR(71 downto 0);
signal Tiempo :  STD_LOGIC_VECTOR(7 downto 0);

signal command_aux : STD_LOGIC_VECTOR(31 downto 0);

signal data_aux :  STD_LOGIC_VECTOR(71 downto 0);

signal i: integer := 0;
signal i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11: integer := 0;

--STATE MACHINE
type estado_UCC_SING is (S0,S1,S2,S3,S4,S5,S6,S7,S3_1,S3_2,S3_3,S4_1,S4_2,S4_3,S4_4,S4_5,S4_6,S4_7,S4_8,S4_9,S4_10,S4_11,S4_12,S4_13,S4_14,S4_15,S4_16,S4_17,S4_18,S4_19,S4_20,S4_21,S4_22,S4_23,S4_24,S4_25,S4_26,S4_27,S4_28,S4_29,S4_30,S4_31, S4_311,S4_32,S4_33,S4_34,S4_35,S4_36,S4_37,S4_38,S4_39,S4_40);
signal est_UCC_SING:estado_UCC_SING:= S0;

-- 
signal signal_1 : std_logic :='0';
signal signal_2 : std_logic :='0';
signal signal_3 : std_logic :='0';
signal signal_4 : std_logic :='0';

-- 
signal D_as_1 : std_logic :='0';
signal D_as_2 : std_logic :='0';
signal D_as_3 : std_logic :='0';

signal D_as_12 : std_logic :='0';
signal D_as_13 : std_logic :='0';

signal D_as_123 : std_logic :='0';


signal D_s_1 : std_logic :='0';
signal D_s_2 : std_logic :='0';
signal D_s_3 : std_logic :='0';

signal D_s_12 : std_logic :='0';
signal D_s_13 : std_logic :='0';
signal D_s_23 : std_logic :='0';

signal D_s_123 : std_logic :='0';
---------------------------------------

Signal entrada1        : std_logic :='0';
Signal win_on1         : std_logic :='0';
Signal Do_coun_coin1   : std_logic :='0';
Signal Done_coun_coin1 : std_logic :='0';
Signal num_cuentas1    : Integer   :=0;

Signal entrada2        : std_logic :='0';
Signal win_on2         : std_logic :='0';
Signal Do_coun_coin2   : std_logic :='0';
Signal Done_coun_coin2 : std_logic :='0';
Signal num_cuentas2    : Integer   :=0;

Signal entrada3        : std_logic :='0';
Signal win_on3         : std_logic :='0';
Signal Do_coun_coin3   : std_logic :='0';
Signal Done_coun_coin3 : std_logic :='0';
Signal num_cuentas3    : Integer   :=0;

Signal entrada4        : std_logic :='0';
Signal win_on4         : std_logic :='0';
Signal Do_coun_coin4   : std_logic :='0';
Signal Done_coun_coin4 : std_logic :='0';
Signal num_cuentas4    : Integer   :=0;

Signal entrada5        : std_logic :='0';
Signal win_on5         : std_logic :='0';
Signal Do_coun_coin5   : std_logic :='0';
Signal Done_coun_coin5 : std_logic :='0';
Signal num_cuentas5    : Integer   :=0;

Signal entrada6        : std_logic :='0';
Signal win_on6         : std_logic :='0';
Signal Do_coun_coin6   : std_logic :='0';
Signal Done_coun_coin6 : std_logic :='0';
Signal num_cuentas6    : Integer   :=0;

Signal entrada7        : std_logic :='0';
Signal win_on7         : std_logic :='0';
Signal Do_coun_coin7   : std_logic :='0';
Signal Done_coun_coin7 : std_logic :='0';
Signal num_cuentas7    : Integer   :=0;

Signal win_on_counter  : std_logic :='0';
Signal Do_counter      : std_logic :='0';
Signal Done_counter    : std_logic :='0';


Signal cuentas_D1    : Integer   :=0;
Signal cuentas_D2    : Integer   :=0;
Signal cuentas_D3    : Integer   :=0;

Signal cuentas_D12   : Integer   :=0;
Signal cuentas_D13   : Integer   :=0;
Signal cuentas_D23   : Integer   :=0;

Signal cuentas_D123  : Integer   :=0;


---time_window
Signal ciclos_tiempo   : STD_LOGIC_VECTOR(31 downto 0);     --1000ms = 1s ### ACA
Signal escala          : STD_LOGIC_VECTOR(31 downto 0);   ---en milisegundos ### ACA
Signal win_on_wt       : std_logic :='0';        
Signal Do_windows_time : std_logic :='0';
Signal Done_windows_time : std_logic :='0';


--CONVERT INTEGER TO VECTOR
signal conv_vec :  STD_LOGIC_VECTOR( (N_bits-41) downto 0);
signal conv_int   : Integer :=0;--- variable para convertir de entero a vector

---------------------------------------------------------------------------
begin


---------- IMPPLEMENTACION -----------------
--todos los subprogramas o componentes usados en la implementacion son finalizados con 
--Done_windows_time la cual permite visualizar cuando la ventana de tiempo ha terminado

SU : Super_Uart
port map (
        CLK100MHZ		=>	CLK100MHZ,
        rst				=>	rst,
        
        UART_TXD_IN		=> UART_TXD_IN,
        UART_RXD_OUT	=> UART_RXD_OUT,
        
        Do_tx_string	=> Do_tx_string,
        Done_tx_string	=> Done_tx_string,
        
        Do_rx_string	=> Do_rx_string,
        Done_rx_string 	=> Done_rx_string,
        
        Super_string_rx =>	Super_string_rx,
        Super_string_tx	=>	Super_string_tx
);

WT:time_window
Port map ( 
        CLK			=>	CLK100MHZ,
        rst					=>	rst,
        
        cycles_time		=>	ciclos_tiempo,
        cycles_scale				=>	escala,

        TW_on              =>	win_on_wt,
        
        Do_TW     =>	Do_windows_time,
        Done_TW   =>	Done_windows_time
	);

Contador1 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada1,
        num_cuentas			=>	num_cuentas1,
        
        win_on			    =>	win_on1,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin1
);

Contador2 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada2,
        num_cuentas			=>	num_cuentas2,
        
        win_on			    =>	win_on2,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin2
);

Contador3 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada3,
        num_cuentas			=>	num_cuentas3,
        
        win_on			    =>	win_on3,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin3
);

Contador4 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada4,
        num_cuentas			=>	num_cuentas4,
        
        win_on			    =>	win_on4,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin4
);

Contador5 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada5,
        num_cuentas			=>	num_cuentas5,
        
        win_on			    =>	win_on5,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin5
);

Contador6 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada6,
        num_cuentas			=>	num_cuentas6,
        
        win_on			    =>	win_on6,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin6
);

Contador7 : counter
port map (
        CLK100MHZ			=>	CLK100MHZ,
        rst					=>	rst,
        
        entrada			    =>	entrada7,
        num_cuentas			=>	num_cuentas7,
        
        win_on			    =>	win_on7,
        
        Do_coun_coin	    =>	Do_counter,
        Done_coun_coin		=>	Done_coun_coin7
);


------------



--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


---CONEXIONS----
--de las entradas directamente a las se�ales
signal_1 <= signal1;
signal_2 <= signal2;
signal_3 <= signal3;
signal4  <= win_on_wt;

entrada1 <= D_s_1;
entrada2 <= D_s_2;
entrada3 <= D_s_3;
entrada4 <= D_s_12;
entrada5 <= D_s_13;
entrada6 <= D_s_23;
entrada7 <= D_s_123;

--Do_coun_coin1 <= Do_counter;
--Do_coun_coin2 <= Do_counter;
--Do_coun_coin3 <= Do_counter;
--Do_coun_coin4 <= Do_counter;
--Do_coun_coin5 <= Do_counter;
--Do_coun_coin6 <= Do_counter;
--Do_coun_coin7 <= Do_counter;

win_on1 <= win_on_counter;
win_on2 <= win_on_counter;
win_on3 <= win_on_counter;
win_on4 <= win_on_counter;
win_on5 <= win_on_counter;
win_on6 <= win_on_counter;
win_on7 <= win_on_counter;

Done_counter <= (Done_coun_coin1 or Done_coun_coin2 or Done_coun_coin3 or Done_coun_coin4 or Done_coun_coin5 or Done_coun_coin6 or Done_coun_coin7);



win_on_counter <= win_on_wt;

led0 <= win_on_wt;
signal_4 <= win_on_wt;
led1 <= Do_UCC_SING;
conv_vec <= CONV_STD_LOGIC_VECTOR(conv_int,(N_bits-40));  -- ojo tal vez debamos hacer la conversion solo de 3 4 o 5 bytes And add Zeros because this number is too big






--Coincidencias asincronas

--D_as_1 <= signal_1;
--D_as_2 <= signal_2;
--D_as_3 <= signal_3;

--D_as_12 <= (signal_1 and signal_2);
--D_as_13 <= (signal_1 and signal_3);
--D_as_23 <= (signal_2 and signal_3);
--D_as_123 <= (signal_1 and signal_2 and signal_3);

--Coincidencias sincronas
Coincidencias_Sync:Process(CLK100MHZ,rst)
begin
	if rst = '1' then
		elsif rising_edge(CLK100MHZ) then
            D_s_1 <= signal_1;
            D_s_2 <= signal_2;
            D_s_3 <= signal_3;
            
            D_s_12 <= (signal_1 and signal_2);
            D_s_13 <= (signal_1 and signal_3);
            D_s_23 <= (signal_2 and signal_3);
            
            D_s_123 <= (signal_1 and signal_2 and signal_3);		
	end if;
end process;
		




---------------INICIO DEL PROGRAMA PRINCIPAL------------------------------------------
main:Process(CLK100MHZ,rst)
begin
	if rst = '1' then
		est_UCC_SING <= S0;
		elsif rising_edge(CLK100MHZ) then

		case est_UCC_SING is
			
			when S0 =>
				Do_rx_string	 <= '0';
				Do_tx_string	 <= '0';
				Done_UCC_SING <= '0';
				Do_windows_time <= '0'; -- resetea el componente WT
				Do_counter <= '0'; -- resetea el componente contador1
							
				if Do_UCC_SING = '1' then
				est_UCC_SING <=S1;
				end if;
			
				when S1 =>
					Do_rx_string <= '1';
					est_UCC_SING <= S2;
				
				when S2 =>
				if Done_rx_string = '1' then
					Do_rx_string <= '0';
					est_UCC_SING <= S3;
				end if;
				
				when S3 => --estado de division del string recibido
				Comand <= Super_string_rx( (N_bits-1) downto (N_bits-32));
--				 Tiempo <= Super_string_rx( (N_bits-33) downto (N_bits-40));
				Number <= Super_string_rx( (N_bits-41) downto 0 );	
				est_UCC_SING <= S3_1;

				when S3_1 => --estado de division de number guardado en Number
				i <= ((CONV_INTEGER(Number(7  downto 0))-48)*1)+
					((CONV_INTEGER(Number(15 downto 8))-48)*10)+
					((CONV_INTEGER(Number(23 downto 16))-48)*100)+
					((CONV_INTEGER(Number(31 downto 24))-48)*1000)+
					((CONV_INTEGER(Number(39 downto 32))-48)*10000)+
					((CONV_INTEGER(Number(47 downto 40))-48)*100000)+
					((CONV_INTEGER(Number(55 downto 48))-48)*1000000)+
					((CONV_INTEGER(Number(63 downto 56))-48)*10000000)+
					((CONV_INTEGER(Number(71 downto 64))-48)*100000000);
				est_UCC_SING <= S3_2;

            when S3_2 => --SELECCION POR COMANDOS
			case comand is
				----Estados de prueba de los submodulos
				
				when x"57547431" => --WTt1   --adicionalmente el led0 prendera por el tiempo de la ventana y una vez finalizado el tiempo de la ventana enviara : WTok#999999999
					escala <= CONV_STD_LOGIC_VECTOR(100000, 32); -- con esta escala tenemos 10^5 * 10 ns = 1 ms
					ciclos_tiempo <=  CONV_STD_LOGIC_VECTOR(1000, 32);   --1000 ciclos tiempo significan 1 segundo con escala = 1ms 
					Do_windows_time <= '1'; --activa el componente WT
					if (Done_windows_time = '1') then
						est_UCC_SING <= S4_1;
					end if;       

				--esta funci�n recibe el elemento i de la entrada serial y espere en WT i*1 ms, es decir si i es 2000 entonces esperar� 2 segundos, el led 0 prendera 2 segundos y todo esto nos sirve para probar WT pero tambien la rutina de la conversion de entero a std logic     
				when x"57547432" => --WTt2   --adicionalmente el led0 prendera por el tiempo de la ventana y una vez finalizado el tiempo de la ventana enviara : WTok#999999999
					escala <=  CONV_STD_LOGIC_VECTOR(100000, 32); -- con esta escala tenemos 10^5 * 10 ns = 1 ms
					ciclos_tiempo <= CONV_STD_LOGIC_VECTOR(i, 32);   --1000 ciclos tiempo significan 1 segundo con escala = 1ms 
					Do_windows_time <= '1'; --activa el componente WT
					if (Done_windows_time = '1') then
						conv_int <= i;
						est_UCC_SING <= S4_2;
					end if;		
					
				when x"434F4E31" => --CON1    se probara contador 1 conectado a la entrada 1 con una ventana de tiempo de 1 segundo, es decir que si conetamos una se��l de 1 Khz en la entrada 1 la respuesta por el uart deber� ser C10k#{1000 convertido a un vector de 72 bits}
					Do_windows_time <= '1'; --activa el componente WT 		
					Do_counter<= '1'; --activa todos los contadores automaticamente conectados a las senales D1 D2 D3 D12 D13 D23 D123
					if ((Done_counter = '1' and Done_windows_time = '1'))then  ---cuando los contadores y la ventana de tiempo termine 
						conv_int   <=  num_cuentas1;
						est_UCC_SING <= S4_3;
					end if;  

			--Estados de configutaci�n decoincidencias     

			--configuraci�n del tiempo en Mili segundos
				when x"5449456D" => --TIEm
					escala <= CONV_STD_LOGIC_VECTOR(100000, 32); -- con esta escala tenemos 10^5 * 10 ns = 1 ms
					ciclos_tiempo <= CONV_STD_LOGIC_VECTOR(i,32);   --1000 ciclos tiempo significan 1 segundo con escala = 1ms 
					conv_int <= i;
					command_aux <= x"546D4F4B"; --TmOK
					est_UCC_SING <= S4_4;

				--configuraci�n del tiempo en segundos
				when x"54494573" => --TIEs
					escala <= CONV_STD_LOGIC_VECTOR(100000000, 32); -- con esta escala tenemos 10^8 * 10 ns = 1000000000 ns = 1 s     ojo quizas debamos declarar esto en unsigned o integer long
					ciclos_tiempo <= CONV_STD_LOGIC_VECTOR(i, 32);   --1000 ciclos tiempo significan 1 segundo con escala = 1 ms
					conv_int <= i;
					command_aux <= x"54734F4B"; --TsOK
					est_UCC_SING <= S4_4;

				--configuraci�n del tiempo en micro segundos
				when x"54494575" => --TIEu
					escala <= CONV_STD_LOGIC_VECTOR(100, 32); -- con esta escala tenemos 10^2 * 10 ns = 1000 ns = 1 us
					ciclos_tiempo <= CONV_STD_LOGIC_VECTOR(i, 32);   --1000 ciclos tiempo significan 1 segundo con escala = 1 ms	
					conv_int <= i;	
					command_aux <= x"54754F4B"; --TuOK		   
					est_UCC_SING <= S4_4;

				--configuraci�n del tiempo en decenas de nano segundos
				when x"5449456E" => --TIEn
					escala <= CONV_STD_LOGIC_VECTOR(1, 32); -- con esta escala tenemos 10^0 * 10 ns = 10 ns
					ciclos_tiempo <= CONV_STD_LOGIC_VECTOR(i, 32);   --100 ciclos tiempo significan 1 us  # SE PUEDE TENER MENOS DE 10NS ?
					conv_int <= i;
					command_aux <= x"546E4F4B"; --TnOK
					est_UCC_SING <= S4_4;

					--configuracion de los estados de correr coincidencias en las ventanas de tiempo determinadas o preconfiguradas   si no se configura automaticamente estara en 1 segundo
				when x"52554E31" => --RUN1   
					Do_windows_time <= '1'; --activa el componente WT 		
					Do_counter<= '1'; --activa todos los contadores automaticamente conectados a las senales D1 D2 D3 D12 D13 D23 D123
					if ((Done_counter = '1' and Done_windows_time = '1'))then  ---cuando los contadores y la ventana de tiempo termine 
						cuentas_D1   <=  num_cuentas1;
						cuentas_D2   <=  num_cuentas2;
						cuentas_D3   <=  num_cuentas3;
						cuentas_D12  <=  num_cuentas4;
						cuentas_D13  <=  num_cuentas5;
						cuentas_D23  <=  num_cuentas6;
						cuentas_D123 <=  num_cuentas7;
						est_UCC_SING <= S4_5;
					end if;  

				--configuracion de los estados para obtener los datos de las coincidencias en las ventanas de tiempo determinadas o preconfiguradas
				when x"47455431" => --GET1   
						est_UCC_SING <= S4_6;			        				        

				when others =>
					est_UCC_SING <= S4;
				end case;

				when S4_1 => --este estado configurara el envio con la palabra WTok#999999999
				Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= x"57546F6B"; --WTok
				Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
				Super_string_tx_test( (N_bits-41) downto     0			) <= x"393939393939393939"; --999999999
				Do_windows_time <= '0'; -- resetea el componente WT
				est_UCC_SING <= S5;	

				when S4_2 => --este estado configurara el envio con la palabra WTok# {i}
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= x"57546F6B"; --WTok
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --i convertido a std_logic_vector
					Do_windows_time <= '0'; -- resetea el componente WT
					est_UCC_SING <= S5;				 

				--when S4_311 =>
				--	Do_windows_time <= '1'; --activa el componente WT 		
				--  Do_coun_coin1<= '1'; --activa el componente contador 1
				--  if (Done_coun_coin1 = '1') then --if ((Done_coun_coin1 = '1' and Done_windows_time = '1'))then 
				--  	conv_int <= num_cuentas1; --le mandamos la salida del numero de cuentas a conv_int, y automaticamente conv_int se convierte a std_logic_vector llamado conv_ve
				--  end if;       
				--	est_UCC_SING <= S4_3;

				when S4_3 => --este estado configurara el envio con la palabra C1ok# {num_cuentas1} y al final resetea WT y contador1
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= x"43316F6B"; --C1ok
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --num_cuentas1 convertido a std_logic_vector
					Do_windows_time <= '0'; -- resetea el componente WT
					Do_counter <= '0'; -- resetea el componente contador1
					est_UCC_SING <= S5;

				when S4_4 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; --
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S5; 
				
				when S4_5 => --este estado configurara el envio con la palabra R1ok# {9999999999} y al final resetea WT y contador1
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= x"52314F4B"; --R1OK
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= x"393939393939393939"; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					Do_windows_time <= '0'; -- resetea el componente WT
					Do_counter <= '0'; -- resetea el componente contador1
					est_UCC_SING <= S5;  	
				
			--Enviar D1 
				when S4_6 =>
					command_aux <= x"44315F5F"; --D1__
					conv_int    <= cuentas_D1;
					est_UCC_SING <= S4_7;

				when S4_7 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_8;

				when S4_8 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_9;	

				when S4_9 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_10;
					end if;

			--Enviar D2 
				when S4_10 =>
					command_aux <= x"44325F5F"; --D2__
					conv_int    <= cuentas_D2;
					est_UCC_SING <= S4_11;

				when S4_11 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_12;

				when S4_12 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_13;	

				when S4_13 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_14;
					end if;	

			--Enviar D3 
				when S4_14 =>
					command_aux <= x"44335F5F"; --D3__
					conv_int    <= cuentas_D3;
					est_UCC_SING <= S4_15;

				when S4_15 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_16;

				when S4_16 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_17;	

				when S4_17 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_18;
					end if;				 			 

			--Enviar D12 
				when S4_18 =>
					command_aux <= x"4431325F"; --D12_
					conv_int    <= cuentas_D12;
					est_UCC_SING <= S4_19;

				when S4_19 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_20;

				when S4_20 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_21;	

				when S4_21 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_22;
				end if;				 

			--Enviar D13 
				when S4_22 =>
					command_aux <= x"4431335F"; --D13__
					conv_int    <= cuentas_D13;
					est_UCC_SING <= S4_23;

				when S4_23 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_24;

				when S4_24 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_25;	

				when S4_25 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_26;
					end if;

				--Enviar D23 
				when S4_26 =>
					command_aux <= x"4432335F"; --D23_
					conv_int    <= cuentas_D23;
					est_UCC_SING <= S4_27;

				when S4_27 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_28;

				when S4_28 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_29;	

				when S4_29 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S4_30;
					end if;

				--Enviar D123 
				when S4_30 =>
					command_aux <= x"44313233"; --D123
					conv_int    <= cuentas_D123;
					est_UCC_SING <= S4_31;

				when S4_31 => 
					Super_string_tx_test( (N_bits-1)  downto (N_bits-32) ) <= command_aux; 
					Super_string_tx_test( (N_bits-33) downto (N_bits-40))  <= x"23" ; --hast
					Super_string_tx_test( (N_bits-41) downto     0			) <= conv_vec; --numero enviado por serial convertido a entero i  y traducido a std_logic_vector conv_vector
					est_UCC_SING <= S4_32;

				when S4_32 =>
					Super_string_tx <= Super_string_tx_test;
					Do_tx_string <= '1';
					est_UCC_SING <= S4_33;	

				when S4_33 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S7; -- LE CAMBIE EL ESTADO POR S7, ANTES ESTABA S4_7
				end if;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++				
				when S5 =>
				Super_string_tx <= Super_string_tx_test;
				Do_tx_string <= '1';
				est_UCC_SING <= S6;	

				when S6 =>
					if Done_tx_string = '1' then
						Do_tx_string <= '0';
						est_UCC_SING <= S7;
					end if;			 
				
				when S7 =>
					Done_UCC_SING <= '1';
					-- if(Do_CPU = '0')then 
					est_UCC_SING <=S0;
					--end if;

				when others =>
					est_UCC_SING <= S0;
		end case;
	end if;
end process;

end Behavioral;		
