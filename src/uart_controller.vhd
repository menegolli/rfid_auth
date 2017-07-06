library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_controller is
	port (
		clock 			: in std_logic;
		reset 			: in std_logic;
		uart_line 		: in std_logic;
		enable_reader	: in std_logic;
		divisor 		: in std_logic_vector(15 downto 0);
		bits_per_data 	: in std_logic_vector(3 downto 0);
		data_out_contr	: out std_logic_vector(7 downto 0);
		data_debug		: out std_logic_vector(11 downto 0);
		tc_char_out		: out std_logic 	--signalling the reading of a character
	);
end entity uart_controller;


architecture struct of uart_controller is

	component uart_peripheral is
		port (
			clock 			: in std_logic;
			reset 			: in std_logic;
			uart_line 		: in std_logic;
			enable_reader	: in std_logic;
			divisor 		: in std_logic_vector(15 downto 0);
			bits_per_data 	: in std_logic_vector(3 downto 0);
			data_out 		: out std_logic_vector(11 downto 0);
			tc_char 		: out std_logic	-- signalling the reading of a character
		);
	end component;

	type state is (IDLE, DONE, READ_TAG);	--states for the fsm
	signal tc_char : std_logic;
	signal data_out_local : std_logic_vector(11 downto 0);
	signal current_state, next_state: state;

begin

	periph: uart_peripheral
	port map (
		clock 				=> clock,
		reset	 			=> reset,
		uart_line 			=> uart_line,
		enable_reader		=> enable_reader,
		divisor 			=> divisor,
		bits_per_data 		=> bits_per_data,
		data_out 			=> data_out_local,
		tc_char 			=> tc_char
	);


	process (clock, reset)
	-- process defining CURRENT state
	begin
		if (reset = '0') then
			current_state <= IDLE;
		elsif (clock='1' and clock'event) then
			current_state <= next_state;
		end if;
	end process;

	process (current_state, next_state, enable_reader, tc_char, data_out_local)
	begin

		data_debug <= data_out_local;
		case current_state is
			when IDLE =>

					if (tc_char = '1') then
						next_state <= READ_TAG;
					else
						next_state <= IDLE;
					end if;

			when READ_TAG =>
				next_state <= DONE;

			when DONE =>
				if (tc_char = '1') then
					next_state <= DONE;
				else
					next_state <= IDLE;
				end if;

			when others =>
				next_state <= IDLE;
		end case;
	end process;
	data_out_contr <= data_out_local(9 downto 2);		-- output only interesting bits
	tc_char_out <= tc_char;
end architecture struct;
