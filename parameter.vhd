library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pre_para is
  generic(
    PRB_t_w : positive := 9;
    pilot_length_type_w : positive := 11;
    numDmrsSymbols_w: positive := 2;
    dmrsAddPos_t_w : positive := 2;
    DMRS_IN_PRB : integer :=6
    
  );
  
  port(
    clk: in std_logic;
    rst: in std_logic;

    en_para_i: in std_logic;
    para_end_o: out std_logic;    

    dynamic_control_startPRB_i: in std_logic_vector(PRB_t_w-1 downto 0);
    dynamic_control_numPRBs_i: in std_logic_vector(PRB_t_w-1 downto 0);
    dmrsAddPos_i: in std_logic_vector(dmrsAddPos_t_w-1 downto 0);

    skip_sequence_length_o: out std_logic_vector(pilot_length_type_w-1 downto 0);
    dmrs_end_value_o: out std_logic_vector(pilot_length_type_w-1 downto 0);
    numDmrsSymbols_o: out std_logic_vector(numDmrsSymbols_w-1 downto 0)
  
  );
end pre_para;


architecture rtl of pre_para is
--prepare pararmeter for later processï¼ parameters includes 
--skip_sequence_length_o for skip sub-block
--dmrs_end_value_o for the whole loop times 
--numDmrsSymbols_o for loop times
constant dmrs_samples_in_PRB: integer := DMRS_IN_PRB;
constant mul_w: integer:=  PRB_t_w + PRB_t_w;

signal numDmrsSymbols_s: unsigned(numDmrsSymbols_w-1 downto 0);

signal dmrs_samples_in_PRB_i_s: unsigned(PRB_t_w-1 downto 0);
signal d2_i_s: unsigned(PRB_t_w-1 downto 0);

signal startPRB_i_s: unsigned(PRB_t_w-1 downto 0);
signal numPRBs_i_s: unsigned(PRB_t_w-1 downto 0);

signal dmrs_samples_in_PRB_p1_s: unsigned(PRB_t_w-1 downto 0);
signal d2_p1_s: unsigned(PRB_t_w-1 downto 0);
signal startPRB_p1_s: unsigned(PRB_t_w-1 downto 0);
signal numPRBs_p1_s: unsigned(PRB_t_w-1 downto 0);

signal dmrs_samples_in_PRB_p2_s: unsigned(PRB_t_w-1 downto 0);
signal d2_p2_s: unsigned(PRB_t_w-1 downto 0);

signal startPRB_p2_s: unsigned(PRB_t_w-1 downto 0);
signal numPRBs_p2_s: unsigned(PRB_t_w-1 downto 0);

signal skip_sequence_length_s: unsigned(pilot_length_type_w-1 downto 0);
signal dmrs_end_value_s: unsigned(pilot_length_type_w-1 downto 0);

signal skip_sequence_length_o_s: unsigned(pilot_length_type_w-1 downto 0);
signal dmrs_end_value_o_s: unsigned(pilot_length_type_w-1 downto 0);


begin

  process(clk)
    begin 
      if(rising_edge (clk)) then
        if(rst = '0') then
          startPRB_i_s <= (others =>'0');
          numPRBs_i_s <= (others => '0'); 
          dmrs_samples_in_PRB_i_s <=(others => '0');
          d2_i_s <=(others => '0');
        

          para_end_o <= '0';        
        else
          if(en_para_i = '1') then
            startPRB_i_s <= unsigned(dynamic_control_startPRB_i);
            numPRBs_i_s <= unsigned(dynamic_control_numPRBs_i);
            dmrs_samples_in_PRB_i_s <= to_unsigned(dmrs_samples_in_PRB, dmrs_samples_in_PRB_i_s'length);
            d2_i_s <= to_unsigned(dmrs_samples_in_PRB, dmrs_samples_in_PRB_i_s'length);

            if to_integer(skip_sequence_length_o_s) = 0 AND to_integer(dmrs_end_value_o_s)= 0 then
              para_end_o <= '0';
            else
              para_end_o <= '1';
            end if;
           else
             para_end_o <= '0';
         end if;
       end if;
     end if;
   end process;
 
       startPRB_p1_s <= startPRB_i_s  when rising_edge (clk);
       numPRBs_p1_s <= numPRBs_i_s when rising_edge (clk);
       dmrs_samples_in_PRB_p1_s <= dmrs_samples_in_PRB_i_s when rising_edge (clk);
       d2_p1_s <= d2_i_s when rising_edge (clk);

       startPRB_p2_s <= startPRB_p1_s when rising_edge (clk);
       numPRBs_p2_s <= numPRBs_p1_s when rising_edge (clk);
       dmrs_samples_in_PRB_p2_s <= dmrs_samples_in_PRB_p1_s when rising_edge (clk);
       d2_p2_s <= d2_p1_s when rising_edge (clk);

       skip_sequence_length_s <= resize((dmrs_samples_in_PRB_p2_s * startPRB_p2_s),11);
       dmrs_end_value_s <= resize((d2_p2_s * numPRBs_p2_s),11); 
          
  process(clk)
    begin
      if rising_edge(clk) then         
         skip_sequence_length_o_s <= skip_sequence_length_s;
         dmrs_end_value_o_s <= dmrs_end_value_s;            

      end if;              
  end process;

  skip_sequence_length_o <= std_logic_vector(skip_sequence_length_o_s);
  dmrs_end_value_o <= std_logic_vector(dmrs_end_value_o_s);


  process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst = '0') then
          numDmrsSymbols_s <= (others => '0');
        else
        
          case to_integer(unsigned(dmrsAddPos_i)) is
            when 2 => numDmrsSymbols_s <= "10";
            when others => numDmrsSymbols_s <= "01";
          end case;
          
        end if;
      end if;
  end process;
  numDmrsSymbols_o <= std_logic_vector(numDmrsSymbols_s);
end rtl;
 

      
          
        