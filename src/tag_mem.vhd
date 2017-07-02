library ieee;
use ieee.std_logic_1164.all;

entity tag_mem is
	port (
		clk			: in std_logic;
		addr		: in std_logic_vector(1 downto 0);
		enable_mem	: in std_logic;
		tag_mem_out : out std_logic_vector(7 downto 0)
	);
end entity tag_mem;

architecture tag_mem_arch of tag_mem is
	type mem is array ( 0 to 3 ) of std_logic_vector(7 downto 0);

	--now they are reversed. LSB first.
	constant tag_char : mem := (
		0  => "10101111",
		1  => "10011010",
		2  => "10110101",
		3  => "01101010"
	);


	--11110101 -- reverse  10101111
	--01011001 -- reverse  10011010
	--10101101 -- reverse  10110101
	--01010110 -- reverse  01101010
begin
	--process (clk, addr, enable_mem)
	--process (addr, enable_mem)
	--process(enable_mem)
	process(addr)
	begin
		--if enable_mem = '1' then
			--if (clk = '1' and clk'event) then
				case addr is
					when "00" => tag_mem_out <= tag_char(0);
					when "01" => tag_mem_out <= tag_char(1);
					when "10" => tag_mem_out <= tag_char(2);
					when "11" => tag_mem_out <= tag_char(3);
					when others => tag_mem_out <= "00000000";
				end case;
			--end if;
		--end if;
	end process;
end architecture tag_mem_arch;


--F502 5902 AD02 5602
--01000110 ----reverse --- 01100010
--00110101 ----reverse --- 10101100
--00110000 ----reverse --- 00001100
--00110010 ----reverse --- 01001100
--00110101 ----reverse --- 10101100
--00111001 ----reverse --- 10011100
--00110000 ----reverse --- 00001100
--00110010 ----reverse --- 01001100
--01000001 ----reverse --- 10000010
--01000100 ----reverse --- 00100010
--00110000 ----reverse --- 00001100
--00110010 ----reverse --- 01001100
--00110101 ----reverse --- 10101100
--00110110 ----reverse --- 01101100
--00110000 ----reverse --- 00001100
--00110010 ----reverse --- 01001100