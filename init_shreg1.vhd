library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity init_shreg1 is
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32   
      
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
    cnt_sym_o: out std_logic_vector(numDmrsSymbols_w-1 downto 0);

    numDmrsSymbols_i: in std_logic_vector(numDmrsSymbols_w-1 downto 0);
    dmrsCinit0_i: in std_logic_vector(cInit_w-1 downto 0);
    dmrsCinit1_i: in std_logic_vector(cInit_w-1 downto 0);
    dmrsCinit2_i: in std_logic_vector(cInit_w-1 downto 0);
   
    en_init1_i: in std_logic;
    init1_end_o: out std_logic; -- one time init1 end
    init1_ready_o: out std_logic; -- the whole process end or not
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)
  );
  
end init_shreg1;

architecture rtl of init_shreg1 is
  signal numDmrsSymbols_s: unsigned(numDmrsSymbols_w-1 downto 0);
  signal cnt_s: unsigned(numDmrsSymbols_w-1 downto 0);
  signal dmrsCinit0_s: std_logic_vector(cInit_w-1 downto 0);
  signal dmrsCinit1_s: std_logic_vector(cInit_w-1 downto 0);
  signal dmrsCinit2_s: std_logic_vector(cInit_w-1 downto 0);
  signal init1_end_s: std_logic;
  signal init1_end_ss:std_logic;
begin
  numDmrsSymbols_s <= unsigned(numDmrsSymbols_i);

  
  process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst = '0' ) then
          shreg1_o <= (others => '0' );
--          cnt_s <= "00" ; 
	  init1_end_s <= '0';       
          init1_end_ss <= '0';
          
        else
          if(en_init1_i = '1') then
            
            if cnt_s < numDmrsSymbols_s then                           
              case to_integer(cnt_s) is
                when 0 => shreg1_o <= dmrsCinit0_i;
                when 1 => shreg1_o <= dmrsCinit1_i;
                when 2 => shreg1_o <= dmrsCinit2_i;
                when others => null;                   
              end case;
              init1_end_s <= '1';               
            else
              init1_end_s <= '0';
            end if; 
            init1_end_ss <= init1_end_s;
          else
            init1_end_s <= '0';   
            init1_end_ss <= '0';
          end if;
        end if;
      end if;
  end process;

  process(clk)
  begin
    if(rising_edge(clk))then
      if(rst = '0')then
        cnt_s <= "00" ; 
      else
        if(en_init1_i = '1' AND init1_end_ss = '1') then
          cnt_s <= cnt_s + 1;
        elsif cnt_s = numDmrsSymbols_s  then
          cnt_s <= (others => '0');
        else
          cnt_s <= cnt_s;
        end if;
      end if;
    end if;
 end process;

  process(clk)
  begin
	if(rising_edge(clk))then
    if(rst = '0')then
      init1_ready_o <= '0';
    else
      if(en_init1_i = '1') then
        if cnt_s < (numDmrsSymbols_s + 1)  then
          init1_ready_o <= '1';
        else
          init1_ready_o <= '0';
        end if;
      end if;
    end if;
	 end if;
 end process;

  cnt_sym_o <= std_logic_vector(cnt_s);
  init1_end_o <= init1_end_s;
  
end rtl;
            
                  
                      
                    
                    
                
                  
    
