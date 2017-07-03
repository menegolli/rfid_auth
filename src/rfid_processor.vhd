library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--to perform casting	-- CHECK
use ieee.numeric_std.all;

entity rfid_processor is
	port(
		clk 						: IN STD_LOGIC;
		reset_n 				: IN STD_LOGIC;
		addr_read				: OUT std_logic_vector(1 downto 0);
		tc_char_in			: IN std_logic;
		uart_data 			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		pwm_en					: OUT std_logic;
		led_idle				: OUT std_logic;
		led_grant				: OUT std_logic;
		led_denied			: OUT std_logic;
		tag_mem_out			: IN std_logic_vector(7 downto 0);
		sine_mem_enable : OUT std_logic
	);
end entity rfid_processor;

architecture arch of rfid_processor is
	--states for the fsm
	type state is (
		RESETTING,
		IDLE,
		STORE,
		DONE_STORE_ONE,
		DONE_STORE_FOUR,
		CHECK_TAG,
		ACCESS_GRANTED,
		ACCESS_DENIED
		);

	type state_check is (
		RESETTING,
		IDLE,
		CHECK_ONE,
		DONE_CHECK_GRANT,
		DONE_CHECK_DENY
		);

	signal current_state, next_state: state;
	signal current_state_check, next_state_check : state_check;

	signal RD1, WR: std_logic;

	signal ADD_WR, ADD_RD1: std_logic_vector(1 downto 0);
	signal rf_out: std_logic_vector(7 downto 0);

	signal index: std_logic_vector(1 downto 0);
	signal index_reset : std_logic;
	signal index_tc : std_logic;

	signal index_check: std_logic_vector(1 downto 0);
	signal index_check_cnt_enable : std_logic;
	signal index_check_reset : std_logic;
	signal index_check_tc : std_logic;

	signal check_ok : std_logic;
	signal enable_check_proc : std_logic;

	signal check_ended :std_logic;
	signal check_grant :std_logic;

	signal next_check			    : std_logic;
	signal next_check_fut     : std_logic;
	signal continue_check     : std_logic;
	signal already_pressed    : std_logic;
	signal check_button_set   : std_logic;
	signal check_button_reset : std_logic;

	component register_file is
		generic(
			N			: integer :=	8;		--bit parallelism
			N_REG		: integer :=	2		--log of number of registers
		);
		port (
			CLK				:	IN std_logic;
			RESET			:	IN std_logic;
			RD1				:	IN std_logic;
			WR				:	IN std_logic;
			ADD_WR			:	IN std_logic_vector(N_REG-1 downto 0);
			ADD_RD1			:	IN std_logic_vector(N_REG-1 downto 0);
			DATAIN			:	IN std_logic_vector(N-1 downto 0);
			OUT1			:	OUT std_logic_vector(N-1 downto 0)
		);
	end component;

	component countern is
		generic(
			n : integer:=16
			);
		port (
			clock, reset 	: in std_logic;
			enable			: in std_logic;
			end_val			: in std_logic_vector(n-1 downto 0);
			cnt_out			: out std_logic_vector(n-1 downto 0);
			tc 				: out std_logic
		);
	end component;

begin

	addr_read <= index_check;
	ADD_RD1 <= index_check;
	ADD_WR <= index;

	rf: register_file
	generic map(
		N => 8,
		N_REG => 2
	)
	port map(
		CLK			=> clk,
		RESET		=> reset_n,	--or "clear" signal?
		RD1			=> RD1,
		WR			=> WR,
		ADD_WR		=> ADD_WR,
		ADD_RD1		=> ADD_RD1,
		DATAIN		=> uart_data, --already 8 bits
		OUT1		=> rf_out
		);

	cnt_index : countern
	generic map(
		n=>2
	)
	port map(
		clock		=> clk,
		reset 		=> index_reset,
		enable 		=> WR,
		end_val		=> "11",
		cnt_out		=> index,
		tc 			=> index_tc
	);

	cnt_index_check : countern
	generic map(
		n=>2
	)
	port map(
		clock 		=> clk,
		enable 		=> RD1,
		reset 		=> index_check_reset,
		end_val		=> "11",
		cnt_out		=> index_check,
		tc 			=> index_check_tc
	);

	state_proc:process (clk, reset_n)
	-- process defining CURRENT state
	begin
		if (reset_n = '0') then
			current_state <= RESETTING;
		elsif (clk='1' and clk'event) then
			current_state <= next_state;
		end if;
	end process;

	my_proc: process (current_state, tc_char_in, index_tc, index, check_ended, check_grant)
	begin
		case current_state is
			when RESETTING =>
				index_reset <='0';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				next_state <= IDLE;

			when IDLE =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '1';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				if (tc_char_in = '1') then
					next_state <= STORE;
				else
					next_state <= IDLE;
				end if;

			when STORE =>
				index_reset <='1';
				WR <= '1';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				if (index = "11" and index_tc ='1') then
					next_state <= DONE_STORE_FOUR;
				else
					next_state <= DONE_STORE_ONE;
				end if;


			when DONE_STORE_ONE =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				next_state <= IDLE;

			when DONE_STORE_FOUR =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				next_state <= CHECK_TAG;

			when CHECK_TAG =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='1';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				if (check_ended = '1') then
					if (check_grant = '1') then
						next_state <= ACCESS_GRANTED;
					else
						next_state <= ACCESS_DENIED;
					end if;
				else
					next_state <= CHECK_TAG;
				end if ;

			when ACCESS_GRANTED =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '1';
				led_idle <= '0';
				led_grant <= '1';
				led_denied <= '0';
				sine_mem_enable <= '0';
				next_state <= ACCESS_GRANTED;

			when ACCESS_DENIED =>
				index_reset <='1';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '1';
				sine_mem_enable <= '1';
				next_state <= ACCESS_DENIED;

			when others =>
				index_reset <='0';
				WR <= '0';
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';
				sine_mem_enable <= '0';
				next_state <= IDLE;
		end case;
	end process;

	check_state_proc: process (clk, reset_n)
	-- process defining CURRENT state
	begin
		if (reset_n = '0') then
			current_state_check <= RESETTING;
		elsif (clk='1' and clk'event) then
			current_state_check <= next_state_check;
		end if;
	end process;


	check_proc: process(current_state_check, enable_check_proc, index_check_tc, check_ok, next_check)
	begin
		case( current_state_check ) is
			when RESETTING =>
				check_ended <= '0';
				check_grant <= '0';
				index_check_cnt_enable <='0';
				index_check_reset <='0';
				RD1 <= '0';
				next_state_check <= IDLE;

			when IDLE =>
				check_ended <= '0';
				check_grant <= '0';
				index_check_cnt_enable <='0';
				index_check_reset <='1';
				RD1 <= '0';
				if enable_check_proc ='1' then
					next_state_check <= CHECK_ONE;
				else
					next_state_check <= IDLE;
				end if;

			when CHECK_ONE =>
				check_ended <= '0';
				check_grant <= '0';
				index_check_cnt_enable <='1';
				index_check_reset <='1';
				RD1 <= '1';
				if check_ok = '0' then
					next_state_check <= DONE_CHECK_DENY;
				else
					if index_check_tc = '1' then
						next_state_check <= DONE_CHECK_GRANT;
					else
						next_state_check <= CHECK_ONE;
					end if;
				end if;

			when DONE_CHECK_GRANT =>
				check_ended <= '1';
				check_grant <= '1';
				index_check_cnt_enable <='0';
				index_check_reset <='1';
				RD1 <= '0';
				next_state_check <= DONE_CHECK_GRANT;

			when DONE_CHECK_DENY =>
				check_ended <= '1';
				check_grant <= '0';
				index_check_cnt_enable <='0';
				index_check_reset <='1';
				RD1 <= '0';
				next_state_check <= DONE_CHECK_DENY;

			when others =>
				check_ended <= '0';
				check_grant <= '0';
				index_check_cnt_enable <='0';
				index_check_reset <='0';
				RD1 <= '0';
				next_state_check <= IDLE;
		end case ;
	end process;

	comp_p : process (clk, reset_n, enable_check_proc)
	begin
		if reset_n = '0' then
			check_ok <= '0';
		elsif enable_check_proc = '1' then
			if clk'event and clk='0' then
				if (tag_mem_out = rf_out) then
					check_ok <= '1';
				else
					check_ok <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture ; -- arch
