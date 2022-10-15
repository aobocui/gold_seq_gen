-- Quartus Prime VHDL Template
-- Single-Port ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity romTem is

	generic 
	(
		DATA_WIDTH : integer := 34;
		ADDR_WIDTH : integer := 3
	);

	port 
	(
		clk		: in std_logic;
		addr_a	: in integer range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in integer range 0 to 2**ADDR_WIDTH - 1;
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end entity;

architecture rtl of romTem is

	-- Build a 2-D array type for the ROM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	function init_rom
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
	   
	   tmp(0) := "0010110101000001000101101010000010";
		tmp(1) := "0010110101000001010101101010000010";
		tmp(2) := "1010110101000001000101101010000010";
		tmp(3) := "1010110101000001010101101010000010";

	   tmp(4) := "0010110101000001000101101010000010";	
		tmp(5) := "0010110101000001011010010101111110";
		tmp(6) := "1101001010111111000101101010000010";
		tmp(7) := "1101001010111111011010010101111110";
 --               tmp(8) := "0000000000000000000000000000000000";
		
--		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
--			tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
--		end loop;


		return tmp;
	end init_rom;	 

	-- Declare the ROM signal and specify a default value.	Quartus Prime
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	signal rom : memory_t := init_rom;
begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		q_a <= rom(addr_a);
		q_b <= rom(addr_b);
	end if;
	end process;

end rtl;
