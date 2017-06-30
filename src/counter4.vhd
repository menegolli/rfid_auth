library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity counter4 is
	port (
		clock 		: in std_logic;
		reset		: in std_logic;
		clear		: in std_logic;
		end_val		: in std_logic_vector(3 downto 0);
		tc			: out std_logic
);
end entity counter4;

architecture rtl of counter4 is
begin

	process (clock, reset, clear)
	--process (clock, clear)
		variable count: std_logic_vector(3 downto 0) := (others => '0');
	begin
		if (reset = '0' or clear = '0') then
		--if (clear = '0') then
			count := (others => '0');
			tc <= '0';
		elsif (clock = '1' and clock'event) then
			if (count = end_val-1) then
			--if (count = end_val) then
				tc <= '1';
				count := (others => '0');
			else
				count := count + 1;
				tc <= '0';
			end if;
		end if;
	end process;

end architecture rtl;
