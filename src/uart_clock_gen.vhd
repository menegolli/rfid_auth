library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_clock_gen is
	port (
		clock 		: in std_logic;
		reset		: in std_logic;
		clear		: in std_logic;
		end_val		: in std_logic_vector(15 downto 0);
		uart_clock 	: out std_logic
	);
end entity uart_clock_gen;

architecture rtl of uart_clock_gen is

	component counter16 is
		port(
			clock 		: in std_logic;
			reset		: in std_logic;
			clear		: in std_logic;
			end_val 	: in std_logic_vector(15 downto 0);
			tc 			: out std_logic
		);
	end component counter16;

	signal tc, uart_ck_int: std_logic;

begin

	c16: counter16 port map (clock, reset, clear, end_val, tc);
	uart_clock <= uart_ck_int;
	
	process (tc, reset, clear)
	--process (tc, clear)
	begin
		if (reset = '0' or clear = '0') then 
			uart_ck_int <= '0';
		--els
		--if (clear = '0') then
			--uart_ck_int <= '0';
		elsif (tc = '1' and tc'event) then
			uart_ck_int <= not uart_ck_int;
		end if;
	end process;
	
end architecture rtl;