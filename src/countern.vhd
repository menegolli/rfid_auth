library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity countern is
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
end entity countern;

architecture rtl of countern is
	signal count: std_logic_vector(n-1 downto 0);
	signal tc_int :std_logic;
begin
	cnt_out <= count;
	tc <= tc_int;
	process (clock, reset,enable)
	begin
		if (reset = '0') then
			count <= (others => '0');
		elsif enable = '1' then
			if (clock = '1' and clock'event) then
				if tc_int ='1' then
					count <= (others => '0');
				else
					count <= count + '1';
				end if;
			end if;
		end if;
	end process;

	tc_process : process(end_val, count)
	begin
		tc_int <= '0';
		if (count = end_val) then
			tc_int <= '1';
		end if;

	end process;

end architecture rtl;
