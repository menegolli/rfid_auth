library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pwm is
	GENERIC(
		n : integer := 16
	);
	port(
		clk_sys		: IN std_logic;
		enable 		: IN std_logic;
		reset 		: IN std_logic;
		--pwm_en		: IN std_logic;
		--dc 			: in std_logic_vector(n-1 downto 0);
		end_val 	: IN std_logic_vector (n - 1 downto 0);
		pwm_out 	: OUT std_logic
	);
end pwm;

architecture pwm_arch of pwm is 
	

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

	component uart_clock_gen is
		port (
			clock 		: in std_logic;
			reset		: in std_logic;
			clear		: in std_logic;
			end_val		: in std_logic_vector(15 downto 0);
			uart_clock 	: out std_logic
		);
	end component;
	
	--signal cnt_out : std_logic_vector (n - 1 downto 0) := (others => '0');
	signal cnt_out : std_logic_vector (n - 1 downto 0);
	signal tc : std_logic;
	signal pwm_clk : std_logic;
	signal dc : std_logic_vector(n-1 downto 0);
	signal tc_dc : std_logic;
begin
	

	comp_p :process (cnt_out, dc)
	---ENABLE???????
	begin
		--if clk'event and clk='0' then 
			if (cnt_out > dc) then
				pwm_out <= '1';
			else
				pwm_out <= '0';
			end if;
		--end if;
	end process;

	count: countern
	generic map (
		n => n -- determine which value to apply
	)
	port map(
		clock 		=> pwm_clk,
		reset 		=> reset,
		--reset 		=> not(tc),
		enable 		=> enable,
		end_val 	=> end_val,
		cnt_out 	=> cnt_out,
		tc 			=> tc
	);

	pwm_clk_gen: uart_clock_gen
	port map (
		clock 		=> clk_sys,
		reset		=> reset,
		clear		=> '1',
		end_val		=> "0000010000000000",--1024 as divider
		--end_val		=> "0000000100000000",-- as divider
		uart_clock 	=> pwm_clk
	);

	count_dc: countern
	generic map (
		n => n -- determine which value to apply
	)
	port map(
		--clock 		=> pwm_clk,
		clock 		=> clk_sys,
		reset 		=> reset,
		--reset 		=> not(tc),
		enable 		=> enable,
		end_val 	=> end_val,
		cnt_out 	=> dc,
		tc 			=> tc_dc
	);
end architecture pwm_arch;