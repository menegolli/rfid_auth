library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity rfid_auth is
	port (
		clock, reset_n	: in std_logic;
		uart_line		: in std_logic;
		enable_reader	: in std_logic;							--assign to switch to enable the reading from the RFID tag reader
		data_out 		: out std_logic_vector(7 downto 0);
		--data_debug_out	: out std_logic_vector(11 downto 0);	--keep for debug purposes
		--status_bit		: out std_logic;
		pwm_out 		: out std_logic;
		--red_pwm_out 		: out std_logic;
		--green_pwm_out 		: out std_logic;
		--blue_pwm_out 		: out std_logic;
		led_idle		: out std_logic;
		led_grant		: out std_logic;
		led_denied		: out std_logic;
		--uart_clock_out	: out std_logic 						--keep for debug purposes
		check_button		: in std_logic;
		check_ok_out 	: out std_logic
	);
end entity rfid_auth;

architecture struct of rfid_auth is
	
	component rfid_processor is
		port (
			clk 				: IN STD_LOGIC;
			reset_n 			: IN STD_LOGIC;
			--bits_per_data 		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			--divisor 			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			status 				: IN STD_LOGIC;
			addr_read			: OUT std_logic_vector(1 downto 0);
			enable_mem			: OUT std_logic;
			tc_char_in			: IN std_logic;
			uart_data 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data_out 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			pwm_en				: OUT std_logic;
			led_idle			: OUT std_logic;
			led_grant			: OUT std_logic;
			led_denied			: OUT std_logic;	
			check_ok_out		: OUT std_logic;
			check_button		: in std_logic;		
			tag_mem_out			: in std_logic_vector(7 downto 0)
		);
	end component;
	
	component uart_controller is
		port (
			clock 			: in std_logic;
			reset 			: in std_logic;
			uart_line 		: in std_logic;
			enable_reader	: in std_logic;
			divisor 		: in std_logic_vector(15 downto 0);
			bits_per_data 	: in std_logic_vector(3 downto 0);
			data_out_contr	: out std_logic_vector(7 downto 0);
			data_debug		: out std_logic_vector(11 downto 0);
			uart_clock_out 	: out std_logic;
			status 			: out std_logic;
			tc_char_out		: out std_logic 	--signalling the reading of a character
		);
	end component;

	component tag_mem is
		port (
			clk			: in std_logic;
			addr		: in std_logic_vector(1 downto 0);
			enable_mem	: in std_logic;
			tag_mem_out	: out std_logic_vector(7 downto 0)
		);
	end component;

	component pwm is
		GENERIC(
			n : integer := 16
		);
		port(
			clk_sys	: IN std_logic;
			enable 		: IN std_logic;
			reset 		: IN std_logic; 
			--dc 			: IN std_logic_vector(n-1 downto 0);
			end_val 	: IN std_logic_vector (n - 1 downto 0);
			pwm_out 	: OUT std_logic
		);
	end component;



	signal divisor			: std_logic_vector(15 downto 0);		--can hardcode here?
	signal bits_per_data	: std_logic_vector(3 downto 0);			--can hardcode here?
	signal data 			: std_logic_vector(7 downto 0);		
	signal data_debug		: std_logic_vector(11 downto 0);
	signal status 			: std_logic;
	signal uart_clock 		: std_logic;
	--signal enable_reader	: std_logic;
	signal tc_char			: std_logic;
	signal enable_mem		: std_logic;
	signal addr_read		: std_logic_vector(1 downto 0);
	signal tag_mem_out		: std_logic_vector(7 downto 0);
	--signal pwm_clk 			: std_logic;
	--signal pwm_out			: std_logic;
	signal pwm_en 			: std_logic;
	
begin
	--put here in order to perform test
	--divisor <= "0000000011011000";	--216 for 115200 as baud rate for 50 Mhz clock
	divisor <= "0000101000101011"; --2603 for 9600 as baud rate
	bits_per_data <= "1011";		--11 bits per character
	
	--------
	rfid_p: rfid_processor
	port map (
		clk 			=> clock,
		reset_n 		=> reset_n,
		--bits_per_data 	=> bits_per_data,
		--divisor 		=> divisor,
		status 			=> status,
		addr_read		=> addr_read,
		enable_mem		=> enable_mem,
		tc_char_in		=> tc_char,
		uart_data 		=> data,
		data_out 		=> data_out,
		pwm_en			=> pwm_en,
		led_idle		=> led_idle,
		led_grant		=> led_grant,
		led_denied		=> led_denied,
		check_ok_out	=> check_ok_out,
		check_button 	=> check_button,
		tag_mem_out		=> tag_mem_out
	);

	uart_contr: uart_controller
	port map (
		clock 				=> clock,
		reset	 			=> reset_n,
		uart_line 			=> uart_line,
		enable_reader		=> enable_reader,
		divisor 			=> divisor,
		bits_per_data 		=> bits_per_data,
		data_out_contr 		=> data,
		data_debug			=> data_debug,
		uart_clock_out 		=> uart_clock,
		status 				=> status,
		tc_char_out			=> tc_char
	);

	memory_tag: tag_mem
	port map (
		clk 			=> clock,
		addr 			=> addr_read,
		enable_mem		=> enable_mem,
		tag_mem_out 	=> tag_mem_out
	);
	

	my_pwm: pwm
	generic map(
		n => 16
	)
	port map(
		clk_sys		=> clock,
		enable 		=> pwm_en,
		reset 		=> reset_n,
		--pwm_en 		=> pwm_en,
		--dc 			=> "0000000001000000",--64
		--dc 			=> "0000000000001000",--8
		--end_val 	=> "0000000010000000",--128
		end_val 	=> "0000000000100000",--32
		pwm_out 	=> pwm_out
	);
	--red_pwm: pwm
	--generic map(
	--	n => 16
	--)
	--port map(
	--	clk_sys		=> clock,
	--	enable 		=> pwm_en,
	--	reset 		=> reset_n,
	--	--pwm_en 		=> pwm_en,
	--	--dc 			=> "0000000001000000",--64
	--	--dc 			=> "0000000000001000",--8
	--	--end_val 	=> "0000000010000000",--128
	--	end_val 	=> "0000000000100000",--32
	--	pwm_out 	=> red_pwm_out
	--);

	--green_pwm: pwm
	--generic map(
	--	n => 16
	--)
	--port map(
	--	clk_sys		=> clock,
	--	enable 		=> pwm_en,
	--	reset 		=> reset_n,
	--	--pwm_en 		=> pwm_en,
	--	--dc 			=> "0000000001000000",--64
	--	--dc 			=> "0000000000001000",--8
	--	--end_val 	=> "0000000010000000",--128
	--	end_val 	=> "0000000001000000",--64
	--	pwm_out 	=> green_pwm_out
	--);

	--blue_pwm: pwm
	--generic map(
	--	n => 16
	--)
	--port map(
	--	clk_sys		=> clock,
	--	enable 		=> pwm_en,
	--	reset 		=> reset_n,
	--	--pwm_en 		=> pwm_en,
	--	--dc 			=> "0000000001000000",--64
	--	--dc 			=> "0000000000001000",--8
	--	end_val 	=> "0000000010000000",--128
	--	pwm_out 	=> blue_pwm_out
	--);
	
	--uart_bits 		<= data;
	--status_bit 		<= status;

	--data_out 		<= data;
	
	--uart_clock_out <= uart_clock;
end architecture struct;