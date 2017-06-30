library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity shift_reg12 is
port (
		uart_clock 		: in std_logic;
		reset 			: in std_logic;
		clear 			: in std_logic;
		shift_enable 	: in std_logic;
		rx_line 		: in std_logic;
		data_out 		: out std_logic_vector(11 downto 0)
);
end entity shift_reg12;

architecture rtl of shift_reg12 is
	signal sr: std_logic_vector(11 downto 0);

begin
	process (uart_clock, reset, clear)
		begin
			if (reset = '0' or clear = '0') then
				sr <= (others => '0');
			elsif (uart_clock='1' and uart_clock'event) then
				if (shift_enable = '1') then
					sr(11 downto 1) <= sr(10 downto 0);
					sr(0) <= rx_line;
				end if;
			end if;
	end process;
	data_out <= sr;
end architecture rtl;
