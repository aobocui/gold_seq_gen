library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level_t is
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
end tb_top_level_t;

architecture tb of tb_top_level_t is

    component top_level_t
        port (clk_i            : in std_logic;
              rst_i            : in std_logic;
              system_ready_i : in std_logic;

    	      dynamic_control_startPRB_i: in std_logic_vector(PRB_t_w-1 downto 0);
              dynamic_control_numPRBs_i: in std_logic_vector(PRB_t_w-1 downto 0);
              dmrsAddPos_i: in std_logic_vector(dmrsAddPos_t_w-1 downto 0);

              dmrsCinit0_i   : in std_logic_vector (cinit_w-1 downto 0);
              dmrsCinit1_i   : in std_logic_vector (cinit_w-1 downto 0);
              dmrsCinit2_i   : in std_logic_vector (cinit_w-1 downto 0);
              antennaPort_i  : in std_logic_vector (antennaport_w-1 downto 0));
    end component;

    signal clk            : std_logic;
    signal rst            : std_logic;
    signal system_ready_i : std_logic;

    signal dynamic_control_startPRB_i: std_logic_vector(PRB_t_w-1 downto 0);
    signal dynamic_control_numPRBs_i: std_logic_vector(PRB_t_w-1 downto 0);
    signal dmrsAddPos_i: std_logic_vector(dmrsAddPos_t_w-1 downto 0);

    signal dmrsCinit0_i   : std_logic_vector (cinit_w-1 downto 0);
    signal dmrsCinit1_i   : std_logic_vector (cinit_w-1 downto 0);
    signal dmrsCinit2_i   : std_logic_vector (cinit_w-1 downto 0);
    signal antennaPort_i  : std_logic_vector (antennaport_w-1 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : top_level_t
    port map (clk_i            => clk,
              rst_i            => rst,
              system_ready_i => system_ready_i,

              dynamic_control_startPRB_i => dynamic_control_startPRB_i,
              dynamic_control_numPRBs_i => dynamic_control_numPRBs_i,
              dmrsAddPos_i => dmrsAddPos_i,

              dmrsCinit0_i   => dmrsCinit0_i,
              dmrsCinit1_i   => dmrsCinit1_i,
              dmrsCinit2_i   => dmrsCinit2_i,
              antennaPort_i  => antennaPort_i);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        system_ready_i <= '0';
        dmrsCinit0_i <= (0 => '1', others => '0');
        dmrsCinit1_i <= (1 => '1',others => '0');
        dmrsCinit2_i <= (1 downto 0 => '1',others => '0');
        antennaPort_i <= (others => '0');

        dynamic_control_numPRBs_i <= (0 => '1', others => '0');
        dynamic_control_startPRB_i <= (0 => '1', others => '0') ;
        dmrsAddPos_i <= "10";

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '0';
        wait for 50 ns;
        rst <= '1';
        wait for 20 ns;
        system_ready_i <= '1';
        antennaPort_i <= x"C";

        -- EDIT Add stimuli here
        wait for 10000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;
end tb;