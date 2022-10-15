library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_t is
    generic(
    PRB_t_w : positive := 9;
    dmrsAddPos_t_w : positive := 2;
    numDmrsSymbols_w: positive := 2;
    pilot_length_type_w: positive := 11;
    pilot_type_w: positive := 2;
    cInit_w: positive := 32;
    complex_w: positive := 17;
    antennaPort_w: positive := 4    
  );
  
  port(
    clk_i: in std_logic;
    rst_i: in std_logic;
   
    system_ready_i: in std_logic;

    dynamic_control_startPRB_i: in std_logic_vector(PRB_t_w-1 downto 0);
    dynamic_control_numPRBs_i: in std_logic_vector(PRB_t_w-1 downto 0);
    dmrsAddPos_i: in std_logic_vector(dmrsAddPos_t_w-1 downto 0);

    dmrsCinit0_i: in std_logic_vector(cInit_w-1 downto 0);
    dmrsCinit1_i: in std_logic_vector(cInit_w-1 downto 0);
    dmrsCinit2_i: in std_logic_vector(cInit_w-1 downto 0);
    antennaPort_i: in std_logic_vector(antennaPort_w-1 downto 0);
	 
	 port0_r_o: out std_logic_vector(complex_w-1 downto 0);
	 port0_i_o: out std_logic_vector(complex_w-1 downto 0);
	 port1_r_o: out std_logic_vector(complex_w-1 downto 0);
	 port1_i_o: out std_logic_vector(complex_w-1 downto 0)
  );
end top_level_t;

architecture rtl of top_level_t is

  signal clk: std_logic;
  signal rst: std_logic;

  signal cnt_sym_s: std_logic_vector(numDmrsSymbols_w-1 downto 0);
  signal dmrs_cnt_s: std_logic_vector(pilot_length_type_w -1 downto 0);
  signal system_ready_s: std_logic;

  signal dmrsCinit0_s: std_logic_vector(cInit_w-1 downto 0);
  signal dmrsCinit1_s: std_logic_vector(cInit_w-1 downto 0);
  signal dmrsCinit2_s: std_logic_vector(cInit_w-1 downto 0);
  signal antennaPort_s: std_logic_vector(antennaPort_w-1 downto 0);

  signal en_para_s: std_logic;
  signal para_end_s: std_logic;
  signal dmrs_end_value_s: std_logic_vector(pilot_length_type_w-1 downto 0);
  signal skip_sequence_length_s: std_logic_vector(pilot_length_type_w-1 downto 0);
  signal numDmrsSymbols_s: std_logic_vector(numDmrsSymbols_w-1 downto 0);

  signal en_init1_s: std_logic;
  signal init1_end_s: std_logic;
  signal init1_ready_s: std_logic;
  signal shreg1_init1_s:std_logic_vector(cInit_w-1 downto 0);
  
 -- signal ctrl_pre_s: std_logic;

  signal en_pre_s: std_logic;
  signal pre_shift_end_s: std_logic;
  signal shreg1_pre_s: std_logic_vector(cInit_w-1 downto 0);
  
 -- signal ctrl_skip_s: std_logic_vector(1 downto 0);
  signal en_skip_s: std_logic;
  signal skip_end_s: std_logic;
  signal shreg0_skip_s: std_logic_vector(cInit_w-1 downto 0);
  signal shreg1_skip_s: std_logic_vector(cInit_w-1 downto 0);
  
 -- signal ctrl_shift2_s: std_logic_vector(1 downto 0);
  signal en_shift2_s: std_logic;
  signal shift_twice_end_s: std_logic;
  signal shreg0_shift2_s: std_logic_vector(cInit_w-1 downto 0);
  signal shreg1_shift2_s: std_logic_vector(cInit_w-1 downto 0);
  
  signal en_gene_s: std_logic;
  signal gene_end_s: std_logic;
  signal pilot_sample_s: std_logic_vector(pilot_type_w-1 downto 0);
  
  signal en_rom_s: std_logic;
  signal rom_end_s: std_logic;
  
  signal port0_r_s: std_logic_vector(complex_w-1 downto 0);
  signal port0_i_s: std_logic_vector(complex_w-1 downto 0);
  signal port1_r_s: std_logic_vector(complex_w-1 downto 0);
  signal port1_i_s: std_logic_vector(complex_w-1 downto 0);

component pre_para
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
end component;

component init_shreg1
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
end component;

component pre_shift_shreg1_t
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
  --  ctrl_i: in std_logic;
    en_pre_i: in std_logic;

    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    pre_shift_end_o: out std_logic;
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end component;

component skip
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32;    
    pilot_length_type_w : positive := 11
   -- pre_shift_time : positive := 1600; 
        
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
--    ctrl_i: in std_logic_vector(1 downto 0);
    en_skip_i:in std_logic;
    skip_length_i: in std_logic_vector(pilot_length_type_w-1 downto 0);
    skip_end_o: out std_logic;
--    shreg0_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg0_o: out std_logic_vector(cInit_w-1 downto 0);    
    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end component;


component shift_both_twice
  generic(
    numDmrsSymbols_w: positive := 2;
    cInit_w: positive := 32;    
    pilot_length_type_w : positive := 11;
    shift_time : positive := 2       
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
    dmrs_cnt_i: in std_logic_vector(pilot_length_type_w -1 downto 0);

 --   ctrl_i: in std_logic_vector(1 downto 0);
    en_shift2_i: in std_logic;
    shift_twice_end_o: out std_logic;

    shreg0_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg0_o: out std_logic_vector(cInit_w-1 downto 0);    
    shreg1_i: in std_logic_vector(cInit_w-1 downto 0);
    shreg1_o: out std_logic_vector(cInit_w-1 downto 0)  
  );
  
end component;

component generate_pilot_sample
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
end component;

component ROM521
  generic(
    addr_width: integer:= 3; 
    antennaPort_w: positive := 4;
    pilot_type_w: positive := 2; 
    data_w :integer:=34;
    complex_w: positive := 17 -- each element has 17 bits --data_width
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
    antennaPort_i: in std_logic_vector(antennaPort_w-1 downto 0);
    pilot_sample_i: in std_logic_vector(pilot_type_w-1 downto 0); -- address in
    
    -- control signal
    
    rom_end_o: out std_logic;
    en_rom_i: in std_logic;     
      
    -- output sequence
    m_axis_pilot_port0_r_o: out std_logic_vector(complex_w-1 downto 0); --data out1
    m_axis_pilot_port0_i_o: out std_logic_vector(complex_w-1 downto 0); -- data out2
    m_axis_pilot_port1_r_o: out std_logic_vector(complex_w-1 downto 0); --data out1
    m_axis_pilot_port1_i_o: out std_logic_vector(complex_w-1 downto 0) -- data out2
    );
end component;
    

component ctrl_state
    generic(
    pilot_length_type_w: positive := 11;
    pilot_type_w: positive := 2;
    cInit_w: positive := 32;
    complex_w: positive := 17;
    antennaPort_w: positive := 4    
  );
  port(
    clk: in std_logic;
    rst: in std_logic;
    dmrs_cnt_o: out std_logic_vector(pilot_length_type_w-1 downto 0);

    system_ready_i: in std_logic;
    dmrs_end_i: in std_logic_vector(pilot_length_type_w-1 downto 0);
    
    en_para_o: out std_logic; -- enable parameter
    para_end_i: in std_logic;
        
    en_init1_o: out std_logic; -- enable initialize register1
    init1_end_i: in std_logic;
    init1_ready_i: in std_logic;
    
--    ctrl_pre_o: out std_logic; -- pre_shift_register1 load data 
    en_pre_o: out std_logic;   
    pre_shift_end_i: in std_logic; -- get the information of pre shift finish and change into the state of skip
    
 --   ctrl_skip_o: out std_logic_vector(1 downto 0); -- skip try to load data but only load successful when receive the ready signal from pre_shift(pre_shift_end_i)    
    en_skip_o: out std_logic;
    skip_end_i: in std_logic;
    
 --   ctrl_shift2_o: out std_logic_vector(1 downto 0);
    en_shift2_o: out std_logic;   
    shift_twice_end_i: in std_logic;
    
    en_gene_o: out std_logic;    
    gene_end_i: in std_logic;
    
    en_rom_o: out std_logic;    
    rom_end_i: in std_logic
 
  );
end component;


-- The component declarations appear in the architecture declarative part. declarations are coded before the design

-- Instantiation: The instance labels identify two specific instances of the components, and are mandatory

-- Port maps

-- Association: Signals in an architecture are associated with ports on a component using a port map. In effect, aport map makes an electrical connection between
-- 'pieces of wire' in an architecture(signals) and pins on a components(ports). The same signal may be associated with several ports-
-- this is the way to define interconnections between components
begin
  clk <= clk_i;
  rst <= rst_i;
  antennaPort_s <= antennaPort_i;
  dmrsCinit0_s <= dmrsCinit0_i;
  dmrsCinit1_s <= dmrsCinit1_i;
  dmrsCinit2_s <= dmrsCinit2_i;
  system_ready_s <= system_ready_i;
  
  port0_r_o <= port0_r_s;
  port0_i_o <= port0_i_s;
  port1_r_o <= port1_r_s;
  port1_i_o <= port1_i_s;

  u1: pre_para
  generic map(
    PRB_t_w => 9,
    pilot_length_type_w => 11,
    numDmrsSymbols_w => 2,
    dmrsAddPos_t_w => 2,
    DMRS_IN_PRB => 6 
  )
  port map(
    clk => clk,
    rst => rst,

    en_para_i => en_para_s,
    para_end_o => para_end_s,
    
 -- how about the input from the register bank
 
    dynamic_control_startPRB_i => dynamic_control_startPRB_i,
    dynamic_control_numPRBs_i => dynamic_control_numPRBs_i,
    dmrsAddPos_i => dmrsAddPos_i,
    
    skip_sequence_length_o => skip_sequence_length_s,
    dmrs_end_value_o => dmrs_end_value_s,
    numDmrsSymbols_o =>numDmrsSymbols_s
  );
  
  u2: init_shreg1
    generic map (
    numDmrsSymbols_w => 2,
    cInit_w => 32   
      )
  port map(
    clk => clk,
    rst => rst,
    cnt_sym_o => cnt_sym_s,
    numDmrsSymbols_i => numDmrsSymbols_s,
    
--    dmrsCinit0_i: in std_logic_vector(cInit_w-1 downto 0);
--    dmrsCinit1_i: in std_logic_vector(cInit_w-1 downto 0);
--    dmrsCinit2_i: in std_logic_vector(cInit_w-1 downto 0);
    dmrsCinit0_i => dmrsCinit0_s,
    dmrsCinit1_i => dmrsCinit1_s,
    dmrsCinit2_i => dmrsCinit2_s,
    
    en_init1_i => en_init1_s,
    init1_end_o => init1_end_s,
    init1_ready_o => init1_ready_s, -- the whole process end or not
    shreg1_o => shreg1_init1_s
  );
  
  u3: pre_shift_shreg1_t
    generic map(
    numDmrsSymbols_w => 2,
    cInit_w => 32,    
    pilot_length_type_w => 11,
    pre_shift_time => 1600,
    half_byte_type_w => 4     
  )
  port map(
    clk => clk,
    rst => rst,
    en_pre_i => en_pre_s,
    shreg1_i => shreg1_init1_s,
    pre_shift_end_o => pre_shift_end_s,
    shreg1_o => shreg1_pre_s  
  );
  
  u4: skip
  generic map(
    numDmrsSymbols_w => 2,
    cInit_w => 32,    
    pilot_length_type_w => 11       
  )
  port map(
    clk => clk,
    rst => rst,
    en_skip_i => en_skip_s,
    skip_length_i => skip_sequence_length_s,

    skip_end_o => skip_end_s,
    
    shreg0_o => shreg0_skip_s,   
    shreg1_i => shreg1_pre_s,
    shreg1_o => shreg1_skip_s 
  );
  
  u5: shift_both_twice
  generic map(
    numDmrsSymbols_w => 2,
    cInit_w => 32,
    pilot_length_type_w => 11,
    shift_time => 2       
  )
  port map(
    clk => clk,
    rst => rst,
    dmrs_cnt_i => dmrs_cnt_s,
    en_shift2_i => en_shift2_s,
    shift_twice_end_o => shift_twice_end_s,

    shreg0_i => shreg0_skip_s,
    shreg0_o => shreg0_shift2_s,    
    shreg1_i => shreg1_skip_s,
    shreg1_o => shreg1_shift2_s  
  ); 
  
  u6: generate_pilot_sample
  generic map(
    cInit_w => 32,
    pilot_type_w => 2
  )
  
  port map (
    clk => clk,
    rst => rst,
    shreg0_i => shreg0_shift2_s,
    shreg1_i => shreg1_shift2_s,
    pilot_sample_o => pilot_sample_s,    
    en_gene_i => en_gene_s,
    gene_end_o => gene_end_s
  );
  
  
  u7: ROM521
  generic map(
    addr_width => 3, -- store 2 element
    antennaPort_w => 4,
    pilot_type_w => 2,
    data_w => 34,
    complex_w => 17 -- each element has 17 bits --data_width
  )
  port map(
    clk => clk,
    rst => rst,
    antennaPort_i => antennaPort_s,
    pilot_sample_i => pilot_sample_s,
    
    -- control signal
    
    rom_end_o => rom_end_s,
    en_rom_i => en_rom_s,       
      
    -- output sequence
    m_axis_pilot_port0_r_o => port0_r_s,
    m_axis_pilot_port0_i_o => port0_i_s,
    m_axis_pilot_port1_r_o => port1_r_s,
    m_axis_pilot_port1_i_o => port1_i_s
    ); 
    
   
   u8: ctrl_state
    generic map(
    pilot_length_type_w => 11,
    pilot_type_w => 2,
    cInit_w => 32,
    complex_w => 17,
    antennaPort_w => 4    
  )
  port map(
    clk => clk,
    rst => rst,
    dmrs_cnt_o => dmrs_cnt_s,
    system_ready_i => system_ready_s,
    dmrs_end_i => dmrs_end_value_s,
    en_para_o => en_para_s, -- enable parameter
    para_end_i => para_end_s,
        
    en_init1_o => en_init1_s, -- enable initialize register1
    init1_end_i => init1_end_s,
    init1_ready_i => init1_ready_s,
    
  --  ctrl_pre_o => ctrl_pre_s, -- pre_shift_register1 load data 
    en_pre_o => en_pre_s,   
    pre_shift_end_i => pre_shift_end_s, -- get the information of pre shift finish and change into the state of skip
    
 --   ctrl_skip_o => ctrl_skip_s, -- skip try to load data but only load successful when receive the ready signal from pre_shift(pre_shift_end_i) 
    en_skip_o => en_skip_s,   
    skip_end_i => skip_end_s,
    
--    ctrl_shift2_o => ctrl_shift2_s, 
    en_shift2_o => en_shift2_s,  
    shift_twice_end_i => shift_twice_end_s,
    
    en_gene_o => en_gene_s,    
    gene_end_i => gene_end_s,
    
    en_rom_o => en_rom_s,   
    rom_end_i => rom_end_s
  );



end rtl;