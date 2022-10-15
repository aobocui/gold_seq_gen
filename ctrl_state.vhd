library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_state is
  generic(
--    numDmrsSymbols_w: positive := 2;
    pilot_length_type_w: positive := 11;
    pilot_type_w: positive := 2;
    cInit_w: positive := 32;
    complex_w: positive := 17;
    antennaPort_w: positive := 4    
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
--    cnt_sym_i: in std_logic_vector(numDmrsSymbols_w-1 downto 0);

    dmrs_cnt_o: out std_logic_vector(pilot_length_type_w-1 downto 0);
    system_ready_i: in std_logic;
    
    dmrs_end_i: in std_logic_vector(pilot_length_type_w-1 downto 0);

    en_para_o: out std_logic; -- enable parameter
    para_end_i: in std_logic;
    
    
    en_init1_o: out std_logic; -- enable initialize register1
    init1_end_i: in std_logic;
    init1_ready_i: in std_logic;
    
 --   ctrl_pre_o: out std_logic; -- pre_shift_register1 load data 
    en_pre_o: out std_logic;   
    pre_shift_end_i: in std_logic; -- get the information of pre shift finish and change into the state of skip
    
 --   ctrl_skip_o: out std_logic_vector(1 downto 0); -- skip try to load data but only load successful when receive the ready signal from pre_shift(pre_shift_end_i)    
    en_skip_o: out std_logic;
    skip_end_i: in std_logic;
    
--    ctrl_shift2_o: out std_logic_vector(1 downto 0); 
    en_shift2_o: out std_logic;  
    shift_twice_end_i: in std_logic;
    
    en_gene_o: out std_logic;    
    gene_end_i: in std_logic;
    
    en_rom_o: out std_logic;    
    rom_end_i: in std_logic    
  );
end ctrl_state;

architecture rtl of ctrl_state is
  type stateType is (idle, para, init1,pre_shreg1, skip, shift2, gene_sample, rom);
  signal state_reg, state_next: stateType;
  signal dmrs_end_s: unsigned(pilot_length_type_w-1 downto 0);
  signal end_value_s: unsigned(pilot_length_type_w -1 downto 0);
  signal dmrs_cnt_s: unsigned(pilot_length_type_w -1 downto 0);
  signal init1_cnt_s: integer;
begin
  
  process(clk)
  begin 
    if(rising_edge(clk)) then
      if(rst = '0') then
        state_reg <= idle;
     
      else
        state_reg <= state_next;
      end if;
      
    end if;
  end process;
  
  -- next state logic: state_next
  -- this is combinational of the sequential design;
  -- which contains the logic for next-state;
  -- include all signals and inpit in sensitive-list except state_next
  
  process(state_reg,system_ready_i, para_end_i, init1_end_i, pre_shift_end_i,skip_end_i, shift_twice_end_i,gene_end_i,rom_end_i,init1_ready_i,dmrs_cnt_s,end_value_s)
  begin
--    state_next <= state_reg;    
    case state_reg is
      when idle =>
        
        if (system_ready_i = '1') then
          state_next <= para;
        else 
          state_next <= idle;
        end if;
        
      when para =>
        if(para_end_i = '1')then
          state_next <= init1;
        else
          state_next <= para;
        end if;
      when init1 => 
      
        if(init1_end_i <= '0')then
          state_next <= init1;
        else 
          state_next <= pre_shreg1;
        end if;
        
      when pre_shreg1 =>      
        if(pre_shift_end_i = '1')then
          state_next <= skip;
        else
          state_next <= pre_shreg1;
        end if;
        
      when skip =>     
        if(skip_end_i = '1')then
          state_next <= shift2;
        else
          state_next <= skip;
        end if;
        
      when shift2 =>    
        if(shift_twice_end_i = '1')then
          state_next <= gene_sample;
        else  
          state_next <= shift2;
        end if;
          
      when gene_sample =>      
        if(gene_end_i = '1')then
          state_next <= rom;
        else
          state_next <= gene_sample;
        end if;
        
      when rom =>
        if(rom_end_i = '1')then          
          if dmrs_cnt_s < to_integer(end_value_s) then
            state_next <= shift2;
          elsif (init1_ready_i = '1') then
            state_next <= init1;
          else
            state_next <= idle;
          end if;
        else
          state_next <= rom;
      end if;      
    end case;
  end process;

  process(clk)
  begin
    if(rising_edge(clk))then
      if(rst= '0') then
        dmrs_cnt_s <= (others => '0');
        end_value_s <= "11111111111";
        dmrs_end_s <= (others => '0');
      else
        case state_reg is
          when init1 => 
            dmrs_end_s <= unsigned(dmrs_end_i);
            dmrs_cnt_s <= (others => '0');
          when pre_shreg1 =>
            if(dmrs_end_s < end_value_s) then
              end_value_s <= dmrs_end_s;
            end if;  
          when shift2 =>
	    if shift_twice_end_i = '1' then
              dmrs_cnt_s <= dmrs_cnt_s + 1;
            end if;
          when others =>
            null;
          end case;
      end if;
    end if;
 end process;
  -- combination output logic
  -- this part contains the output of the design
  -- no if-else statement is used in this part
  -- include all signals and input in sensitive-list except state_next
  
  process(clk)
--process(state_reg)
  begin
    if(rising_edge(clk))then
    if(rst= '0')then
        en_para_o <= '0';
        en_init1_o <= '0';
        en_pre_o <= '0';
        en_skip_o <= '0';
        en_shift2_o <= '0';
        en_gene_o <= '0';
        en_rom_o <= '0';
   else
    case state_reg is
      when idle =>
        en_para_o <= '0';
        en_init1_o <= '0';
        en_pre_o <= '0';
        en_skip_o <= '0';
        en_shift2_o <= '0';
        en_gene_o <= '0';
        en_rom_o <= '0';
      when para => 
        en_para_o <= '1';    
   
      when init1 =>
        en_para_o <= '0';
        en_init1_o <= '1';
        en_rom_o <= '0';

      when pre_shreg1 =>
        en_init1_o <= '0';      
        en_pre_o <= '1';
      when skip =>
        en_pre_o <= '0';
        en_skip_o <= '1';       
      when shift2 =>
        en_skip_o <= '0';
        en_shift2_o <= '1';
        en_rom_o <= '0';
      when gene_sample =>
        en_shift2_o <= '0';
        en_gene_o <= '1';
        
      when rom =>
        en_gene_o <= '0';
        en_rom_o <= '1';
        
        
      end case; 
      end if;
     end if;
  end process;    
	      
dmrs_cnt_o <= std_logic_vector(dmrs_cnt_s);        
      
      
end rtl;    