library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tester is
end tester;

architecture behavior of tester is

	--component uart_peripheral 
	--port (
	--clock, reset: in std_logic;
	--uart_line: in std_logic; 
	--divisor: in std_logic_vector(15 downto 0); 
	--bits_per_data: in std_logic_vector(3 downto 0);
	--data_out: out std_logic_vector(11 downto 0); 
	--uart_clock_out: out std_logic;
	--status: out std_logic 
	--);
	--end component; 
	
	component rfid_auth is
		port (
			clock, reset_n	: in std_logic;
			uart_line		: in std_logic;
			enable_reader	: in std_logic;							--assign to switch to enable the reading from the RFID tag reader
			data_out 		: out std_logic_vector(7 downto 0);
			--data_debug_out	: out std_logic_vector(11 downto 0);	--keep for debug purposes
			--status_bit		: out std_logic;
			--pwm_out 		: out std_logic;
			red_pwm_out 		: out std_logic;
			green_pwm_out 		: out std_logic;
			blue_pwm_out 		: out std_logic;
			led_idle		: out std_logic;
			led_grant		: out std_logic;
			led_denied		: out std_logic
			--uart_clock_out	: out std_logic 						--keep for debug purposes
		);
	end component;
	
	component signal_generator 
		Generic(
			Ts : time :=20 ns
		);
		PORT(
			clk: out std_logic;
			rstn:out std_logic;
			uart_line:out std_logic
		);
	end component;

  
	signal clock, reset, uart_line, uart_clock, status: std_logic;
	--signal divisor: std_logic_vector(15 downto 0);
	--signal bits_per_data: std_logic_vector(3 downto 0);
	
	signal data_out: std_logic_vector(7 downto 0);
	signal data_debug_out: std_logic_vector(11 downto 0);

	signal enable_reader: std_logic;
	--signal pwm_out : std_logic;
	signal red_pwm_out : std_logic;
	signal green_pwm_out : std_logic;
	signal blue_pwm_out : std_logic;
	signal led_grant : std_logic;
	signal led_denied : std_logic;
	signal led_idle : std_logic;


BEGIN

	enable_reader <= '1';

	--divisor <= "0000000011011000";	--216
	--bits_per_data <= "1011";		--11 bits per character

	GEN: signal_generator
		GENERIC MAP (
			TS=>(20 ns)
		)
		PORT MAP(
			clk 		=> clock,
			rstn 		=> reset,
			uart_line	=> uart_line
		);
  
	rfid_a: rfid_auth
		port map(
			clock	 		=> clock,
			reset_n 		=> reset,
			uart_line		=> uart_line,
			enable_reader	=> enable_reader,
			data_out 		=> data_out,
			--data_debug_out	=> data_debug_out,	--keep for debug purposes
			--status_bit		=> status,
			--pwm_out			=> pwm_out,
			red_pwm_out 	=> red_pwm_out,
			green_pwm_out	=> green_pwm_out,
			blue_pwm_out 	=> blue_pwm_out,
			led_idle		=> led_idle,
			led_grant		=> led_grant,
			led_denied		=> led_denied
			--uart_clock_out	=> uart_clock
		);


	--uart: uart_peripheral
	--PORT MAP(
	--	clock,
	--	reset,
	--	uart_line,
	--	divisor,
	--	bits_per_data,
	--	data_out,
	--	uart_clock,
	--	status
	--);
  
end behavior;