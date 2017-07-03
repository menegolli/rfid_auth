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
		dc 				: IN std_logic_vector(n-1 downto 0);
		end_val		: IN std_logic_vector(n-1 downto 0);
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
	signal pwm_cnt : std_logic_vector(n -1 downto 0);
	signal tc_dc : std_logic;
begin
	count_pwm: countern
	generic map (
		n => n -- determine which value to apply
	)
	port map(
		clock 		=> clk_sys,
		reset 		=> reset,
		enable 		=> enable,
		end_val 	=> end_val,
		cnt_out 	=> pwm_cnt,
		tc 				=> tc_dc
	);

	pwm_out_p : process(reset, enable, dc, pwm_cnt)
	begin
		if reset = '0' then
			pwm_out <= '0';
		elsif enable = '1' then
			if unsigned(pwm_cnt) > unsigned(dc) then
				pwm_out <= '0';
			else
				pwm_out <= '1';
			end if;
		else
			pwm_out <= '0';
		end if;
	end process;
end architecture pwm_arch;
