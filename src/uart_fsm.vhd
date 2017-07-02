library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_fsm is
	port (
		clock 			: in std_logic;
		reset 			: in std_logic;
		uart_line 		: in std_logic;
		enable_reader	: in std_logic;
		tc_char 		: in std_logic;
		enable_cnt 		: out std_logic;
		reset_cnt		: out std_logic;
		shift_enable	: out std_logic;
		shift_reset		: out std_logic;
		waiting			: out std_logic 		--outside seen as STATUS
	);
end entity uart_fsm;


architecture rtl of uart_fsm is

	type state is (UART_IDLE, CLEAR_CLOCK, UART_DATA, AFTER_TX);
	signal current_state, next_state: state;
	--signal MY_ERROR: std_logic;

begin

	process (clock, reset)
	-- process defining CURRENT state
	begin
		if (reset = '0') then
			current_state <= UART_IDLE;
			--current_state <= CLEAR_CLOCK;
		--elsif (rising_edge(clock)) then
		elsif (clock = '1' and clock'event) then
			current_state <= next_state;
		end if;
	end process;

	process (current_state, next_state, enable_reader, uart_line, tc_char)
	--process defining NEXT state
	begin

		case current_state is

			when UART_IDLE =>
				enable_cnt <= '0';
				--reset_cnt <= '1';
				reset_cnt <= '0';
				shift_enable <= '0'; 
				shift_reset <= '0'; 
				waiting <= '1';

				if (enable_reader = '1' and uart_line = '0') then --reader enabled and start bit
					next_state <= CLEAR_CLOCK;
				else
					next_state <= UART_IDLE;
				end if ;

			when CLEAR_CLOCK =>
				enable_cnt <= '0';
				reset_cnt <= '0';
				shift_enable <= '0';
				shift_reset <= '0'; 
				waiting <= '0';

				next_state <= UART_DATA;

			when UART_DATA =>
				enable_cnt <= '1';
				reset_cnt <= '1';
				shift_enable <= '1';
				shift_reset <= '1'; 
				waiting <= '0';
				--MY_ERROR <= '0';
				if (tc_char = '0') then		--terminal count for the transmission of a character
					next_state <= UART_DATA;
				else
					next_state <= AFTER_TX;
				end if;


			when AFTER_TX =>
				enable_cnt <= '0';
				reset_cnt <= '0';
				shift_enable <= '0';
				shift_reset <= '1'; 
				waiting <= '0';
			
				next_state <= UART_IDLE;
				

			when others =>
				enable_cnt <= '0';
				--reset_cnt <= '1';
				reset_cnt <= '0';
				shift_enable <= '0';
				shift_reset <= '1'; 
				waiting <= '0';
				
				next_state <= UART_IDLE;

		end case;
	end process;
end architecture rtl;