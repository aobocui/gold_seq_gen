library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skip is
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32;    
    pilot_length_type_w : positive := 11
   -- pre_shift_time : positive := 1600; 
  
    
      
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
 --   ctrl_i: in std_logic_vector(1 downto 0);
    en_skip_i: in std_logic;
    skip_length_i: in std_logic_vector(pilot_length_type_w-1 downto 0);
  
    skip_end_o: out std_logic;
--    shreg0_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg0_o: out std_logic_vector(cInit_w-1 downto 0);    
    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end skip;

architecture rtl of skip is

  signal shreg0_s: std_logic_vector (cInit_w-1 downto 0);
  signal shreg1_s: std_logic_vector (cInit_w-1 downto 0);
  signal cnt: integer range 0 to 100; --the range depends on the input(given data), so I do not know what is the largest range should be
  signal pre_shift_time: integer;
  signal shift_start_flag: std_logic;
  signal skip_end_s: std_logic;
   
begin
pre_shreg1: process(clk)

            begin
              if(rising_edge(clk)) then
                if(rst = '0' ) then
                  shreg0_s <= (others => '0');
                  shreg1_s <= (others => '0');
                  shift_start_flag <= '0';   
                  skip_end_s <='0';              
                else
                  if(cnt = pre_shift_time )then
                    skip_end_s <= '1';
                  else
                    skip_end_s <= '0';
                  end if;
                
                  pre_shift_time <= to_integer(shift_left(unsigned(skip_length_i),1))-2;
                  
                  if(en_skip_i = '1')then
                    shift_start_flag <= '1';
                    case shift_start_flag is
                      when '0' =>
                        shreg0_s <= x"5E485840";
                        shreg1_s <= shreg1_i;
                      when '1' =>
                        if cnt < pre_shift_time then
                        shreg0_s(cInit_w-1) <= '0';
                        shreg0_s(cInit_w-2) <= shreg0_s(3) xor shreg0_s(0); -- test pre-shift reg0 1600    
                        shreg0_s(cInit_w-3 downto 0) <= shreg0_s(cInit_w-2 downto 1);
                      
                        shreg1_s(cInit_w-1) <= '0';
                        shreg1_s(cInit_w-2) <= shreg1_s(3) xor shreg1_s(2) xor shreg1_s(1) xor shreg1_s(0); --shreg1                   
                        shreg1_s(cInit_w-3 downto 0) <= shreg1_s(cInit_w-2 downto 1);
                        end if;
                      when others =>
                        shreg0_s <= (others => '0');
                        shreg1_s <= (others => '0');
                    end case;
                else
                  shift_start_flag <= '0';
                end if;                   
               end if;
              end if;                            
            end process;
            
--            shift_start_flag <= en_skip_i when rising_edge(clk);

            process(clk)
            begin 
              if(rising_edge(clk))then
                if(rst = '0')then
                  cnt <= 0;
                else 
                  if shift_start_flag = '1' then
                    if(cnt < pre_shift_time)then
                      cnt <= cnt + 1;                      
                    end if;
                  else
                    cnt <= 0;
                  end if;                 
                end if;
              end if;
            end process;

    shreg0_o <= shreg0_s;         
    shreg1_o <= shreg1_s;
    skip_end_o <= skip_end_s;
          
end rtl;
           