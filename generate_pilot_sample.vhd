library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generate_pilot_sample is
  generic(
    cInit_w: positive := 32;
    pilot_type_w: positive := 2
  );
  
  port(
    clk: in std_logic;
    rst: in std_logic;
    shreg0_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    pilot_sample_o: out std_logic_vector(pilot_type_w-1 downto 0);
    
    en_gene_i: in std_logic;

    gene_end_o: out std_logic
  );
  
end generate_pilot_sample;

architecture rtl of generate_pilot_sample is
 -- signal gene_end_s_s: std_logic;
begin
  process(clk)
  begin
    if(rising_edge(clk))then
      if(rst = '0')then
        pilot_sample_o <= "00";
        gene_end_o <= '0';
    --    gene_end_s_s <= '0';
      else
        if (en_gene_i = '1') then          
            pilot_sample_o(0) <= shreg0_i(0) xor shreg1_i(0);
            pilot_sample_o(1) <= shreg0_i(1) xor shreg1_i(1);
            gene_end_o <= '1';
        else
--            pilot_sample_o <= (others => '0');
            gene_end_o <='0';
        end if;
      end if;
    end if;
  end process;
end rtl;