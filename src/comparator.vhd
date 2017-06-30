library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity comparator is
	GENERIC (NBIT : integer := 4);
	port 	  (A, B : IN std_logic_vector(NBIT - 1 downto 0);
				Y	  : OUT std_logic );
end comparator;

architecture bhv of comparator is 

	begin
		compare:process (A,B)
		begin
			if A < B then
				Y <= '0';
			else
				Y <= '1';
			end if;
		end process;
end bhv;