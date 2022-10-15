library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_both_twice is
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32;    
    pilot_length_type_w : positive := 11;
    shift_time : positive := 2       
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
 --   ctrl_i: in std_logic_vector(1 downto 0);
    dmrs_cnt_i: in std_logic_vector(pilot_length_type_w -1 downto 0);

    en_shift2_i: in std_logic;
  
    shift_twice_end_o: out std_logic;

    shreg0_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg0_o: out std_logic_vector(cInit_w-1 downto 0);    
    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end shift_both_twice;

architecture rtl of shift_both_twice is

  signal shreg0_s: std_logic_vector (cInit_w-1 downto 0);
  signal shreg1_s: std_logic_vector (cInit_w-1 downto 0);

  signal cnt: integer range 0 to 2;
  signal sh2_start_flag: std_logic_vector(1 downto 0);
  signal shift2_end_s: std_logic;

begin
 process(clk)

            begin
              if(rising_edge(clk)) then
                if(rst = '0' ) then
                  shreg0_s <= (others => '0');
                  shreg1_s <= (others => '0');
                  shift2_end_s <= '0';
                else
                  if(cnt = shift_time) then
                    shift2_end_s <= '1';
                  else
                    shift2_end_s <= '0';
                  end if;
                  
                  if (en_shift2_i = '1') then
                  case sh2_start_flag is
                    when "00" => -- load data from last sub block
                      shreg0_s <= shreg0_i;           
                      shreg1_s <= shreg1_i;

                   when "01" =>
                      if cnt < shift_time  then
                        shreg0_s(cInit_w-1) <= '0';
                        shreg0_s(cInit_w-2) <= shreg0_s(3) xor shreg0_s(0); -- test pre-shift reg0 1600    
                        shreg0_s(cInit_w-3 downto 0) <= shreg0_s(cInit_w-2 downto 1);
                      
                        shreg1_s(cInit_w-1) <= '0';
                        shreg1_s(cInit_w-2) <= shreg1_s(3) xor shreg1_s(2) xor shreg1_s(1) xor shreg1_s(0); --shreg1                   
                        shreg1_s(cInit_w-3 downto 0) <= shreg1_s(cInit_w-2 downto 1);
                      end if;
                   when "10" =>
                      shreg0_s <= shreg0_s;                                                            
                      shreg1_s <= shreg1_s;                                                              
                   when others =>
                      shreg0_s <= (others => '0');
                      shreg1_s <= (others => '0');                  
                  end case;   
                 end if;              
                end if;
              end if;                            
            end process;
          
            process(clk)
            begin
              if(rising_edge(clk))then
                if(en_shift2_i = '1')then
                  sh2_start_flag <= "01";--shifting
                else
                  if(dmrs_cnt_i = "00000000000")then
                    sh2_start_flag <= "00"; -- load data from last sub block
                  else
                    sh2_start_flag <= "10"; -- keep
                  end if;              
                end if;
              end if;
            end process;

            process(clk)
            begin 
              if(rising_edge(clk))then
                if(rst = '0')then
                  cnt <= 0;
                else 
                  if sh2_start_flag = "01" then
                       if(cnt < shift_time)then
                         cnt <= cnt +1;
                       end if;
                  else
                    cnt <= 0;
                  end if;                 
                end if;
              end if;
            end process;
    shreg0_o <= shreg0_s;
    shreg1_o <= shreg1_s;  
    shift_twice_end_o <= shift2_end_s;    
end rtl;
           
          