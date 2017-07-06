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
		pwm_out 		: out std_logic;
		red_pwm_out 	: out std_logic;
		green_pwm_out 	: out std_logic;
		blue_pwm_out 	: out std_logic;
		led_idle		: out std_logic;
		led_grant		: out std_logic;
		led_denied		: out std_logic
	);
end entity rfid_auth;

architecture struct of rfid_auth is
	signal divisor			: std_logic_vector(15 downto 0);		--can hardcode here?
	signal bits_per_data	: std_logic_vector(3 downto 0);			--can hardcode here?
	signal data 			: std_logic_vector(7 downto 0);
	signal data_debug		: std_logic_vector(11 downto 0);
	signal tc_char			: std_logic;
	signal addr_read		: std_logic_vector(1 downto 0);
	signal tag_mem_out		: std_logic_vector(7 downto 0);
	signal sine_mem_out		: std_logic_vector(7 downto 0);
	signal sine_cnt_out		: std_logic_vector(7 downto 0);
	signal sine_addr			: std_logic_vector(7 downto 0);
	--signal pwm_clk 			: std_logic;
	--signal pwm_out			: std_logic;
	signal sine_mem_en  	: std_logic;
	signal pwm_en 				: std_logic;
	signal dc_ctrl_clk		: std_logic;
	signal sine_clk				: std_logic;
	signal pwm_dc_cnt_out	: std_logic_vector(15 downto 0);
	signal dc_cnt_out			: std_logic_vector(15 downto 0);
	signal tc_pwm_dc			: std_logic;
	signal tc_dc					: std_logic;
	signal sine_tc				: std_logic;
	signal sine_addr_tc		: std_logic;

	component rfid_processor is
		port (
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
			tc_char_out		: out std_logic 	--signalling the reading of a character
		);
	end component;

	component tag_mem is
		port (
			addr		: in std_logic_vector(1 downto 0);
			tag_mem_out	: out std_logic_vector(7 downto 0)
		);
	end component;

	component sine_mem is
		port (
			enable_mem		: std_logic;
			addr					: in std_logic_vector(7 downto 0);
			sine_mem_out 	: out std_logic_vector(7 downto 0)
		);
	end component;

	component pwm is
		GENERIC(
			n : integer := 16
		);
		port(
			clk_sys		: IN std_logic;
			enable 		: IN std_logic;
			reset 		: IN std_logic;
			dc 				: in std_logic_vector(n-1 downto 0);
			end_val		: IN std_logic_vector(n-1 downto 0);
			pwm_out 	: OUT std_logic
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

begin
	--put here in order to perform test
	--divisor <= "0000000011011000";	--216 for 115200 as baud rate for 50 Mhz clock
	divisor <= "0000101000101011"; --2603 for 9600 as baud rate
	bits_per_data <= "1011";		--11 bits per character
	data_out <= sine_mem_out;

	--------
	rfid_p: rfid_processor
	port map (
		clk 			=> clock,
		reset_n 		=> reset_n,
		addr_read		=> addr_read,
		tc_char_in		=> tc_char,
		uart_data 		=> data,
		pwm_en			=> pwm_en,
		led_idle		=> led_idle,
		led_grant		=> led_grant,
		led_denied		=> led_denied,
		tag_mem_out		=> tag_mem_out,
		sine_mem_enable => sine_mem_en
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
		tc_char_out			=> tc_char
	);

	memory_tag: tag_mem
	port map (
		addr 			=> addr_read,
		tag_mem_out 	=> tag_mem_out
	);

	samples_mem: sine_mem
	port map (
		enable_mem 		=> sine_mem_en,
		addr 					=> sine_addr,
		sine_mem_out 	=> sine_mem_out
	);


	my_pwm: pwm
	generic map(
		n => 16
	)
	port map(
		clk_sys		=> clock,
		enable 		=> pwm_en,
		reset 		=> reset_n,
		dc				=> "1000000000000000",
		end_val 	=> (others => '1'),
		pwm_out 	=> pwm_out
	);

	red_pwm: pwm
	generic map(
		n => 16
	)
	port map(
		clk_sys		=> clock,
		enable 		=> pwm_en,
		reset 		=> reset_n,
		dc				=> dc_cnt_out,
		end_val 	=> "1000000000000000",
		pwm_out 	=> red_pwm_out
	);

	green_pwm: pwm
	generic map(
		n => 16
	)
	port map(
		clk_sys		=> clock,
		enable 		=> pwm_en,
		reset 		=> reset_n,
		dc				=> dc_cnt_out,
		end_val 	=> "1000000000000000",
		pwm_out 	=> green_pwm_out
	);

	blue_pwm: pwm
	generic map(
		n => 16
	)
	port map(
		clk_sys		=> clock,
		enable 		=> pwm_en,
		reset 		=> reset_n,
		dc				=> dc_cnt_out,
		end_val 	=> (others => '1'),
		pwm_out 	=> blue_pwm_out
	);

	pwm_dc_cnt : countern
	generic map (
		n => 16 -- determine which value to apply
	)
	port map(
		clock 		=> clock,
		reset 		=> reset_n,
		enable 		=> pwm_en,
		end_val 	=> "0000000001000000", --64
		cnt_out 	=> pwm_dc_cnt_out,
		tc 				=> tc_pwm_dc
	);

	dc_ctrl_clk_p : process(reset_n, tc_pwm_dc)
	begin
		if reset_n = '0' then
			dc_ctrl_clk <= '0';
		elsif (tc_pwm_dc'event and tc_pwm_dc = '1') then
			dc_ctrl_clk <= not dc_ctrl_clk;
		end if;
	end process;

	dc_cnt : countern
	generic map (
		n => 16 -- determine which value to apply
	)
	port map(
		clock 		=> dc_ctrl_clk,
		reset 		=> reset_n,
		enable 		=> pwm_en,
		end_val 	=> "1000000000000000",
		cnt_out 	=> dc_cnt_out,
		tc 				=> tc_dc
	);

	sine_clock_gen : countern
	generic map (
		n => 8 -- determine which value to apply
	)
	port map(
		clock 		=> clock,
		reset 		=> reset_n,
		enable 		=> sine_mem_en,
		end_val 	=> "11011110", --222 (une sample every 8.9 us)
		cnt_out 	=> sine_cnt_out,
		tc 				=> sine_tc
	);

	sine_clk_p : process(reset_n, sine_tc)
	begin
		if reset_n = '0' then
			sine_clk <= '0';
		elsif (sine_tc'event and sine_tc = '1') then
			sine_clk <= not sine_clk;
		end if;
	end process;

	sine_addr_c : countern
	generic map (
		n => 8 -- determine which value to apply
	)
	port map(
		clock 		=> sine_clk,
		reset 		=> reset_n,
		enable 		=> sine_mem_en,
		end_val 	=> (others => '1'),
		cnt_out 	=> sine_addr,
		tc 				=> sine_addr_tc
	);



end architecture struct;
