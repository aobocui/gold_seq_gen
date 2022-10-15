library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pre_shift_shreg1_t is
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32;    
    pilot_length_type_w : positive := 11;
    pre_shift_time : positive := 1600; 
    half_byte_type_w : positive := 4     
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
    en_pre_i:in std_logic;

    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    pre_shift_end_o: out std_logic;
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end pre_shift_shreg1_t;

architecture rtl of pre_shift_shreg1_t is

signal shreg1_s: std_logic_vector (cInit_w-1 downto 0);
signal shreg1_next_s: std_logic_vector(cInit_w-1 downto 0);
signal cnt: integer range 0 to 1600;
signal en_counter: std_logic;
signal start_shift_flag: std_logic;



begin
pre_shreg1: 

          process(clk)

            begin
              if(rising_edge(clk)) then
                if(rst = '0' ) then
                  shreg1_s <= (others => '0'); 
                  start_shift_flag <= '0';                            
                else
                  if(en_pre_i = '1')then
		              start_shift_flag <= '1';
                  case start_shift_flag is
                    when '0' =>             
                      shreg1_s <= shreg1_i;
                    when '1' =>
                      shreg1_s <= shreg1_next_s;                                       
                    when others =>        
                      shreg1_s <= (others => '0');
                  end case; 
                  else
 		              start_shift_flag <= '0'; 
                  end if;              
                end if;
              end if;                            
            end process;

--            start_shift_flag <= en_pre_i when rising_edge(clk);

--select the needed one for output
                      
            process(clk)
            begin 
              if(rising_edge(clk))then
                if(rst = '0')then

                  cnt <= 0;
                else 
                  if en_counter = '1' then

                       if(cnt < pre_shift_time)then
                         cnt <= cnt +1;
                       end if;

                  else
                    cnt <= 0;

                  end if;                 
                end if;
              end if;
            end process;

-- logic for next state

            process(clk)
            begin
              if(rising_edge(clk))then
                if(rst = '0')then
                  shreg1_next_s <= (others => '0');
                  pre_shift_end_o <= '0';
                  en_counter <= '0';
                else
                  if(cnt = pre_shift_time )then
                    pre_shift_end_o <= '1';
                  else
                    pre_shift_end_o <= '0';
                  end if;
                         
                  case start_shift_flag is
                   when '0' =>             
                      
                      shreg1_next_s <= shreg1_i;
                      en_counter <= '0';
                             
                    when '1' =>	--shifting;
                    en_counter <= '1';                    
                    if cnt < pre_shift_time then--for i_s in 0 to pre_shift_time - 1 loop
                      shreg1_next_s(cInit_w-1) <= '0';
     --                 shift1_next_s(cInit_w-2) <= shreg1_s(3) xor shreg1_s(2) xor shreg1_s(1) xor shreg1_s(0); --shreg1
                      shreg1_next_s(cInit_w-2) <= shreg1_next_s(3) xor shreg1_next_s(0); -- test pre-shift reg0 1600                     
                      shreg1_next_s(cInit_w-3 downto 0) <= shreg1_next_s(cInit_w-2 downto 1);
                    
                    end if;
                  when others =>
                     en_counter <= '0';
                end case;
                end if;
              end if;
            end process;
        
	        shreg1_o <= shreg1_s;

          
          
end rtl;
            
                  
                      
                    
                    
                
                  
    
