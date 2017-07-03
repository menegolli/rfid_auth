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
		data_out 			=> data_out_local,	--in order to filter (needed?)
		--uart_clock_out 		=> my_uart_clock_out,
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

	--process (my_uart_clock_out, reset)
	---- process defining CURRENT state
	--begin
	--	if (reset = '0') then
	--		current_state <= IDLE;
	--	elsif (my_uart_clock_out='0' and my_uart_clock_out'event) then
	--		current_state <= next_state;
	--	end if;
	--end process;

	process (current_state, next_state, enable_reader, tc_char, data_out_local)
	--process defining NEXT state
	begin

		--tag_read := (others(others =>'0'));		--intializing variable storing the tag being read

		--data_out <= (others =>'0');		--??
		data_debug <= data_out_local;
		case current_state is
			when IDLE =>
				--data_out_contr <= (others =>'0');
				--if (enable_reader = '1') then	-- OR it has to be unrelated to the enable signal?
					if (tc_char = '1') then
						next_state <= READ_TAG;
					else
						next_state <= IDLE;
					end if;
				--else
				--	next_state <= IDLE;
				--end if ;

			when READ_TAG =>
				next_state <= DONE;
				--data_out_contr <= data_out_local(9 downto 2);		--data output only when data is good --- ONLY INTERESTING BITS --- CHECK

			when DONE =>
				--data_out_contr <= (others =>'0');
				if (tc_char = '1') then
					next_state <= DONE;
				else
					next_state <= IDLE;
				end if;

			when others =>
				next_state <= IDLE;
		end case;
	end process;
	--uart_clock_out <= my_uart_clock_out;
	data_out_contr <= data_out_local(9 downto 2);		--data output only when data is good --- ONLY INTERESTING BITS --- CHECK
	tc_char_out <= tc_char;
end architecture struct;
