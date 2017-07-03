library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_generator is
	Generic(
		Ts : time := 20 ns
	);
-- 50 MHz clock
	PORT(
		clk: out std_logic;
		rstn:out std_logic;
		uart_line:out std_logic;
		check_button_s : out std_logic;
		check_button_r : out std_logic
	);
end signal_generator;


architecture behavior of signal_generator is

	signal clk_i: std_logic:='0';
	--constant DATA_DELAY : time := 8.68 us;
	constant DATA_DELAY : time := 104.16 us;

BEGIN

	clk_process: process
	begin
		clk_i <= not clk_i;
		clk<=clk_i;
		wait for Ts/2;
	end process clk_process;
--since we want 115200 baud with 50 MHz clock, the time of a bit is 8.68
	reset: process
	begin
		rstn<='0';
		wait for 2 us;
		rstn<='1';
		--wait;
		-- wait for 5 ms;
		-- rstn<='0';
		-- wait for 2 us;
		-- rstn <= '1';
		-- wait for 7 ms;
		-- rstn<='0';
		-- wait for 2 us;
		-- rstn <= '1';
		wait;

	end process reset;

	uart: process
	begin
		uart_line <='1';	-- standard configuration, line is HIGH
		check_button_s <= '1';
		check_button_r <= '1';

		--0
		wait for 50 us;
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		--wait for 30 us;
		wait for DATA_DELAY;
		--1
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;
		--2
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;
		--3
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		-- check tag mem out step by step
		-- step 1
		wait for 1 ms;
		check_button_s <= '0';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '0';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		-- step 2
		wait for 1 ms;
		check_button_s <= '0';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '0';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		-- step 3
		wait for 1 ms;
		check_button_s <= '0';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '0';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		-- step 4
		wait for 1 ms;
		check_button_s <= '0';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '0';

		wait for 1 ms;
		check_button_s <= '1';
		check_button_r <= '1';

		--wait for DATA_DELAY;

		------4 --- this should trigger ACCESS DENIED
		--uart_line<='0';		--start bit
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 1
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 2



		wait for 2 ms;

		--0
		wait for 50 us;
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		--wait for 30 us;
		wait for DATA_DELAY;
		--1
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;
		--2
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;
		--3
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		--wait for DATA_DELAY;

		------4 --- this should trigger ACCESS DENIED
		--uart_line<='0';		--start bit
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 1
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 2


		wait for 2 ms;

		--0
		wait for 50 us;
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		--wait for 30 us;
		wait for DATA_DELAY;
		--1
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;
		--2
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		--wait for DATA_DELAY;
		----3
		--uart_line<='0';		--start bit
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';
		--wait for DATA_DELAY;
		--uart_line<='0';
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 1
		--wait for DATA_DELAY;
		--uart_line<='1';		--stop bit 2

		wait for DATA_DELAY;

		----4 --- this should trigger ACCESS DENIED
		uart_line<='0';		--start bit
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='0';
		wait for DATA_DELAY;
		uart_line<='1';
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 1
		wait for DATA_DELAY;
		uart_line<='1';		--stop bit 2

		wait;
	end process uart;
end behavior;
