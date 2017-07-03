library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_peripheral is
	port (
		clock 			: in std_logic;
		reset 			: in std_logic;
		uart_line 		: in std_logic;
		enable_reader	: in std_logic;
		divisor 		: in std_logic_vector(15 downto 0);
		bits_per_data 	: in std_logic_vector(3 downto 0);
		data_out		: out std_logic_vector(11 downto 0);
		tc_char			: out std_logic	-- signalling the reading of a character
	);
end entity uart_peripheral;

architecture struct of uart_peripheral is

	component uart_clock_gen is
		port (
			clock  		: in std_logic;
			reset		: in std_logic;
			clear		: in std_logic;
			end_val		: in std_logic_vector(15 downto 0);
			uart_clock 	: out std_logic
		);
	end component;

	component countern is
		generic(
		n : integer:=16
		);
		port (
			clock 			: in std_logic;
			reset 		 	: in std_logic;
			enable			: in std_logic;
			end_val			: in std_logic_vector(n-1 downto 0);
			cnt_out			: out std_logic_vector(n-1 downto 0);
			tc 				: out std_logic
		);
	end component;

	component uart_fsm is
		port (
			clock 			: in std_logic;
			reset 			: in std_logic;
			uart_line		: in std_logic;
			enable_reader	: in std_logic;
			tc_char 		: in std_logic;
			enable_cnt		: out std_logic;
			reset_cnt		: out std_logic;
			shift_enable	: out std_logic;
			shift_reset		: out std_logic
		);
	end component;

	component shift_reg12 is
		port (
			uart_clock 		: in std_logic;
			reset			: in std_logic;
			clear			: in std_logic;
			shift_enable 	: in std_logic;
			rx_line 		: in std_logic;
			data_out 		: out std_logic_vector(11 downto 0)
		);
	end component;

	signal uart_clock, tc_char_int, enable_cnt, reset_cnt, shift_enable, shift_reset: std_logic;		-- maybe I can remove some signals
	signal c4_out : std_logic_vector(3 downto 0);

begin

		ucg: uart_clock_gen
		--generates a clock based on the divisor
		port map(
			clock		=> clock,
			reset		=> reset,
			--reset 		=> reset_cnt,
			clear		=> reset_cnt,
			end_val		=> divisor,
			uart_clock 	=> uart_clock
		);

		c4: countern
		--1011=bits_per_data (11 bits). used to count the number of ticks in the trasmission of an 8-bit character
		generic map (4)
		port map(
			clock 			=> uart_clock,
			reset			=> reset_cnt,
			enable			=> enable_cnt,
			end_val			=> bits_per_data,
			cnt_out			=> c4_out,
			tc				=> tc_char_int
		);

		s12: shift_reg12
		-- constantly fills a 12 bit signal with the data received (one bit at time) from the uart line
		port map(
			uart_clock 		=> uart_clock,
			reset			=> reset,
			clear			=> shift_reset,
			shift_enable	=> shift_enable,
			rx_line			=> uart_line,
			data_out		=> data_out
		);

		fsm: uart_fsm
		-- governs the system
		port map(
			clock 				=> clock,
			reset				=> reset,
			uart_line			=> uart_line,
			enable_reader		=> enable_reader,
			tc_char 			=> tc_char_int,
			enable_cnt			=> enable_cnt,
			reset_cnt			=> reset_cnt,
			shift_enable		=> shift_enable,
			shift_reset			=> shift_reset
		);
	tc_char <= tc_char_int;
	--clear <= tc_char_int;
end architecture struct;
