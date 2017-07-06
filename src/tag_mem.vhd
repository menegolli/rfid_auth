library ieee;
use ieee.std_logic_1164.all;

entity tag_mem is
	port (
		addr		: in std_logic_vector(1 downto 0);
		tag_mem_out : out std_logic_vector(7 downto 0)
	);
end entity tag_mem;

architecture tag_mem_arch of tag_mem is
	type mem is array ( 0 to 3 ) of std_logic_vector(7 downto 0);

	constant tag_char : mem := (
		0  => "10101111",
		1  => "10011010",
		2  => "10110101",
		3  => "01101010"
	);


begin
	process(addr)
	begin
				case addr is
					when "00" => tag_mem_out <= tag_char(0);
					when "01" => tag_mem_out <= tag_char(1);
					when "10" => tag_mem_out <= tag_char(2);
					when "11" => tag_mem_out <= tag_char(3);
					when others => tag_mem_out <= "00000000";
				end case;
	end process;
end architecture tag_mem_arch;
