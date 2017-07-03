library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--use WORK.all;

entity register_file is
	generic(
		N		: integer :=	8;		--bit parallelism
		N_REG	: integer :=	4		--log of number of registers
	);

	port (
	CLK			:	IN std_logic;
	RESET		:	IN std_logic;
	RD1			:	IN std_logic;
--	RD2			:	IN std_logic;
	WR			:	IN std_logic;
	ADD_WR		:	IN std_logic_vector(N_REG-1 downto 0);
	ADD_RD1		:	IN std_logic_vector(N_REG-1 downto 0);
--	ADD_RD2		:	IN std_logic_vector(N_REG-1 downto 0);
	DATAIN		:	IN std_logic_vector(N-1 downto 0);
	OUT1		:	OUT std_logic_vector(N-1 downto 0)
	);
end register_file;

architecture A of register_file is

	-- suggested structures
	subtype	REG_ADDR is natural range 0 to ((2**N_REG)-1); -- using natural type
	type	REG_ARRAY is array(REG_ADDR) of std_logic_vector(N-1 downto 0);
	signal	REGISTERS : REG_ARRAY;


	begin
		--process(CLK, RESET)
		--process(CLK, RESET, RD1)
		process(reset, ADD_RD1, ADD_WR, RD1, WR, DATAIN)
		begin

			if (RESET='0') then			--asynch reset
				REGISTERS		<=	(others=>(others=>'0'));
				OUT1			<=	(others=>'0');
			--elsif(CLK='1' and CLK'event) then
			else
				if(WR='1') then
					REGISTERS(to_integer(unsigned((ADD_WR))))<=DATAIN;
				end if;
				if(RD1='1') then		--RD1
					OUT1	<=	REGISTERS(to_integer(unsigned((ADD_RD1))));
				end if;

			end if;

		end process;


end A;

----


configuration CFG_RF_BEH of register_file is
	for A
end for;
end configuration;
