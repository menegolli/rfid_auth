library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--to perform casting	-- CHECK
use ieee.numeric_std.all;

entity rfid_processor is
	port(
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
		tag_mem_out			: in std_logic_vector(7 downto 0)
	);
end entity rfid_processor;

architecture arch of rfid_processor is

	--type tag is array (15 DOWNTO 0) of STD_LOGIC_VECTOR(7 DOWNTO 0);	--define the type for the tag

	--states for the fsm
	type state is (
		RESETTING,
		IDLE,
		STORE,
		DONE_STORE_ONE,
		CHECK_TAG,
		ACCESS_GRANTED,
		ACCESS_DENIED,
		CHECK_ONE,
		--DONE_CHECK,
		DONE_CHECK_ONE,
		DONE_STORE_FOUR,
		DONE_CHECK_GRANT,
		DONE_CHECK_DENY,
		LED_DEBUG
		);



	signal current_state, next_state: state;
	signal current_state_check, next_state_check : state;

	signal RD1, WR: std_logic;

	signal ADD_WR, ADD_RD1: std_logic_vector(1 downto 0);
	signal rf_out: std_logic_vector(7 downto 0);

	--variable tag_read: tag;				--stores the tag
	constant tag_size: integer := 15;	-- OR 16??? the tag is made by 16 8-bit characters
	signal index: std_logic_vector(1 downto 0);
	signal index_cnt_enable : std_logic;
	signal index_reset : std_logic;
	signal index_tc : std_logic;
	--signal my_index : integer:=0;
	signal index_check: std_logic_vector(1 downto 0);
	signal index_check_cnt_enable : std_logic;
	signal index_check_reset : std_logic;
	signal index_check_tc : std_logic;

	signal check_ok : std_logic;
	signal enable_check_proc : std_logic;

	signal check_ended :std_logic;
	signal all_16 : std_logic;
	
	signal tc_char_in_edge : std_logic;
	signal tc_char_in_edge_set : std_logic;
	signal tc_char_in_edge_reset : std_logic;

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
			OUT1			:	OUT std_logic_vector(N-1 downto 0);
			OUT2			:	OUT std_logic_vector(N-1 downto 0)
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

	addr_read <= ADD_RD1;
	enable_mem <=RD1;
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
		OUT1		=> rf_out,
		OUT2		=> data_out
		);

	cnt_index : countern
	generic map(
		n=>2
	)
	port map(
		--clock		=> tc_char_in,
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
		--clock		=> index_check_cnt_enable,
		clock 		=> clk,
		enable 		=> RD1,
		reset 		=> index_check_reset,
		end_val		=> "11",
		cnt_out		=> index_check,
		tc 			=> index_check_tc
	);

	--fd_index : fd_generic
	--generic map (
	--	nBit => 4
	--)
	--port map(
	--	D     => index,
	--	CK    => WR,
	--	EN    => WR,
	--	RESET => reset_n,
	--	Q     => ADD_WR
	--);

	--fd_index_check : fd_generic
	--generic map (
	--	nBit => 4
	--)
	--port map(
	--	D     => index_check,
	--	CK    => RD1,
	--	EN    => RD1,
	--	RESET => reset_n,
	--	Q     => ADD_RD1
	--);

	state_proc:process (clk, reset_n)
	-- process defining CURRENT state
	begin
		if (reset_n = '0') then
			current_state <= RESETTING;
		elsif (clk='1' and clk'event) then
			current_state <= next_state;
		end if;
	end process;




	my_proc: process (current_state, next_state, tc_char_in, index_tc, check_ended, all_16)
	
	begin

		case current_state is
			when RESETTING =>
				index_cnt_enable <='0';
				index_reset <='0';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='0';

				--ADD_RD1 <= (others =>'0');
				--RD1 <= '0';
				WR <= '0';
				--enable_mem <= '0';

				next_state <= IDLE;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';



			when IDLE =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');
				--RD1 <= '0';
				WR <= '0';
				--enable_mem <= '0';

				if (tc_char_in = '1') then
					next_state <= STORE;
				else
					next_state <= IDLE;
				end if;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '1';
				led_grant <= '0';
				led_denied <= '0';



			when STORE =>
				index_cnt_enable <='1';
				index_reset <='1';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				
				tc_char_in_edge_reset <= '1';
				WR <= '1';
				--ADD_RD1 <= (others =>'0');
				--RD1 <= '0';
				--enable_mem <= '0';
				if (index = "11" and index_tc ='1') then
					next_state <= DONE_STORE_FOUR;
				else
					next_state <= DONE_STORE_ONE;
				end if;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';


			when DONE_STORE_ONE =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');

				WR <= '0';
				--RD1 <= '0';
				enable_check_proc <='0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';

				--enable_mem <='0';
				
				--if (tc_char_in = '1') then
				--	next_state <= DONE_STORE_ONE;
				--else


					--if (index = tag_size) then -- CHECK IF TAG SIZE HAS TO BE 16 AT THIS POINT
					--if (index_tc ='1' and index = "1111") then
					--if (index_tc = '1') then
					--if (tc_char_in = '1') then
						--next_state <= DONE_STORE_ONE;
						--next_state <= DONE_STORE_SIXTEEN;
						--ADD_RD1 <= index_check;
						
					--else
						next_state <= IDLE;
					--end if;
				pwm_en <= '0';

				--end if;

			when DONE_STORE_FOUR =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				WR <= '0';
				--if (index_tc = '0') then
				--	next_state <= DONE_STORE_SIXTEEN;
				--else
					next_state <= CHECK_TAG;
				--end if;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';


			when CHECK_TAG =>
				index_cnt_enable <='0';
				index_reset <='1';
				--index_check_reset <='1';
				tc_char_in_edge_reset <= '0';

				--RD1 <='1';

				WR <= '0';
				--enable_mem <='1'; --CHECK IF SIGNAL HAS TO BE PULLED UP BEFORE

				enable_check_proc <='1';

				if (check_ended = '1') then
					if (check_ok = '1') then
						next_state <= ACCESS_GRANTED;
					else
						next_state <= ACCESS_DENIED;
					end if;
				else
					next_state <= CHECK_TAG;
				end if ;
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';


			when ACCESS_GRANTED =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');

				WR <= '0';
				--RD1 <='0';
				--enable_mem <='0';

				if (index_check >= tag_size) then
					next_state <= ACCESS_GRANTED;
					--next_state <= LED_DEBUG;
				else
					next_state <= ACCESS_GRANTED;
				end if ;

				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '1';
				led_denied <= '0';



			when ACCESS_DENIED =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');

				WR <= '0';
				--RD1 <='0';
				--enable_mem <='0';
				pwm_en <= '0';
				if (index_check >= tag_size) then
					--next_state <= RESETTING;
					next_state <= ACCESS_DENIED;
				else
					next_state <= ACCESS_DENIED;
				end if ;
				enable_check_proc <='1';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '1';


			when LED_DEBUG =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');
				--RD1 <='0';
				WR <= '0';
				--enable_mem <='0';

				next_state <= LED_DEBUG;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';


			when others =>
				index_cnt_enable <='0';
				index_reset <='1';
				tc_char_in_edge_reset <= '0';
				--index_check_cnt_enable <='0';
				--index_check_reset <='1';

				--ADD_RD1 <= (others =>'0');
				--RD1 <='0';
				WR <= '0';
				--enable_mem <='0';

				next_state <= RESETTING;
				enable_check_proc <='0';
				pwm_en <= '0';
				led_idle <= '0';
				led_grant <= '0';
				led_denied <= '0';

				
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


	check_proc: process (check_ok,current_state_check, next_state_check,
		enable_check_proc, index_check_tc, rf_out, tag_mem_out)
	--variable ok_var: std_logic;
	begin
		--check_ok <='0';
		--if (tag_mem_out = rf_out) then
		--	check_ok <='1';
		--else
		--	check_ok <='0';
		--end if;



		if enable_check_proc ='1' then

			case( current_state_check ) is
			
				when RESETTING =>
					check_ended <= '0';
					next_state_check <= CHECK_ONE;
					index_check_cnt_enable <='0';
					index_check_reset <='0';
					RD1 <= '0';
					all_16 <= '0';

				when CHECK_ONE =>
					check_ended <= '0';
					index_check_cnt_enable <= '1';
					index_check_reset <= '1';
					RD1 <= '1';
					all_16 <= '0';
					next_state_check <= CHECK_ONE;

					if index_check_tc = '1' then
						if check_ok = '1' then
							next_state_check <= DONE_CHECK_GRANT;
						else
							next_state_check <= DONE_CHECK_DENY;
						end if;
					else
						if check_ok = '0' then
							next_state_check <= DONE_CHECK_DENY;
						end if;
					end if;

				when DONE_CHECK_GRANT =>	

					check_ended <= '1';
					index_check_cnt_enable <= '0';
					index_check_reset <= '1';
					next_state_check <= RESETTING;
					RD1 <= '0';

					all_16 <= '1';
				
			

				when DONE_CHECK_DENY =>	

					check_ended <= '1';
					index_check_cnt_enable <= '0';
					index_check_reset <= '1';
					next_state_check <= RESETTING;
					RD1 <= '0';
					all_16 <= '0';
				
				when others =>
					next_state_check <= RESETTING;
					check_ended <= '0';
					index_check_cnt_enable <='0';
					index_check_reset <='0';
					RD1 <= '0';
					all_16 <= '0';


			end case ;
		end if;
	end process;


	--comp_p :process (clk,tag_mem_out, rf_out)
	comp_p :process (tag_mem_out, rf_out)
	begin
		--if clk'event and clk='0' then 
			if (tag_mem_out = rf_out) then
				check_ok <= '1';
			else
				check_ok <= '0';
			end if;
		--end if;
	end process;
	
	-- tc_char_in_edge_p : process (tc_char_in_edge_set, tc_char_in_edge_reset)
	-- begin
		-- if tc_char_in_edge_reset = '1' then
			-- tc_char_in_edge <= '0';
		-- elsif tc_char_in_edge_set = '1' then
			-- tc_char_in_edge <= '1';
		-- end if;
	-- end process;
	
	-- tc_char_in_edge_set_p : process(tc_char_in)
	-- begin
	-- tc_char_in_edge_set <= '0';
	-- if tc_char_in'event and tc_char_in = '1' then
		-- tc_char_in_edge_set <= '1';
	-- end if;
	-- end process;

end architecture ; -- arch