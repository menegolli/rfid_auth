library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity pwm is
	GENERIC(
		n : integer := 16
	);
	port(
		clk_sys		: IN std_logic;
		enable 		: IN std_logic;
		reset 		: IN std_logic;
		dc 				: in std_logic_vector(n-1 downto 0);
		divisor 	: IN std_logic_vector (n - 1 downto 0);
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

	--signal cnt_out : std_logic_vector (n - 1 downto 0) := (others => '0');
	signal cnt_out : std_logic_vector (n - 1 downto 0);
	signal tc : std_logic;
	signal pwm_clk : std_logic;
	signal pwm_cnt : std_logic_vector(n -1 downto 0);
	signal tc_dc : std_logic;
begin

	clock_divisor: countern
	generic map (
		n => n -- determine which value to apply
	)
	port map(
		clock 		=> clk_sys,
		reset 		=> reset,
		enable 		=> enable,
		end_val 	=> divisor,
		cnt_out 	=> cnt_out,
		tc 				=> tc
	);

	pwm_clk_p :process (reset, tc)
	begin
		if reset = '0' then
			pwm_clk <= '0';
		elsif (tc'event and tc = '1') then
			pwm_clk <= not pwm_clk;
		end if;
	end process;

	count_pwm: countern
	generic map (
		n => n -- determine which value to apply
	)
	port map(
		clock 		=> pwm_clk,
		reset 		=> reset,
		enable 		=> enable,
		end_val 	=> (others => '1'),
		cnt_out 	=> pwm_cnt,
		tc 				=> tc_dc
	);

	pwm_out_p : process(reset, dc, pwm_cnt)
	begin
		if reset = '0' then
			pwm_out <= '0';
		else
			if unsigned(pwm_cnt) > unsigned(dc) then
				pwm_out <= '0';
			else
				pwm_out <= '1';
			end if;
		end if;
	end process;
end architecture pwm_arch;
