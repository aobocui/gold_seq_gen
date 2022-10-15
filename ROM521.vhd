library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM521 is
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
 end ROM521;
 
 architecture rtl of ROM521 is
  signal addr_port0: integer range 0 to 2**addr_width-1;
  signal addr_port1: integer range 0 to 2**addr_width-1;
  signal odd_s : std_logic;
  
  signal port0: std_logic_vector(data_w-1 downto 0);
  signal port1: std_logic_vector(data_w-1 downto 0);
  
  signal port0_r_s: std_logic_vector(complex_w-1 downto 0);
  signal port0_i_s: std_logic_vector(complex_w-1 downto 0);
  signal port1_r_s: std_logic_vector(complex_w-1 downto 0);
  signal port1_i_s: std_logic_vector(complex_w-1 downto 0);
  signal rom_end_s: std_logic;
  signal rom_end_ss: std_logic;
  signal rom_end_sss: std_logic;
  component romTem
    generic (
    		DATA_WIDTH : integer := 34;
        ADDR_WIDTH : integer := 3
    );
    port(
    	clk		: in std_logic;
      addr_a	: in integer range 0 to 2**ADDR_WIDTH-1;
      addr_b	: in integer range 0 to 2**ADDR_WIDTH-1;
      q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
      q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
    );
  end component;

Begin

--    addr_port0 <= to_integer(unsigned(pilot_sample_i));
--    addr_port1 <= to_integer(unsigned(pilot_sample_i));
    
    dmrs_rom: romTem
      generic map(
        DATA_WIDTH => data_w,
        ADDR_WIDTH => addr_width
        )
      port map(
        clk => clk,
        addr_a => addr_port0,
        addr_b => addr_port1,
        q_a => port0,
        q_b => port1
     
      );
  process(clk)
  begin
    if(rising_edge(clk)) then
      if(rst = '0') then
        odd_s <= '0';
      else
        if en_rom_i = '1' AND rom_end_sss = '1' then
          odd_s <= not odd_s;
        else
          odd_s <= odd_s;
        end if;
      end if;
    end if;
  end process;


    process(clk)  
    begin
      if rising_edge(clk) then
        if rst = '0' then
          rom_end_s <= '0';
          rom_end_ss <= '0';
          rom_end_sss <= '0';
        else
          if en_rom_i = '1' then         
            addr_port0 <= to_integer(unsigned(pilot_sample_i));
            case to_integer(unsigned(antennaPort_i)) is
              when 10 => 
                addr_port1 <= to_integer(unsigned(pilot_sample_i));
              when 12 =>
                if odd_s = '0' then
                   addr_port1 <= to_integer(unsigned(pilot_sample_i));
                else 
                   addr_port1 <= to_integer(unsigned(pilot_sample_i))+4;
                end if;
              when others =>
                addr_port1 <= 0;
            end case;
           rom_end_s <= '1';
           rom_end_ss <= rom_end_s;
           rom_end_sss <= rom_end_ss;
          else
            addr_port0 <= 0;
            addr_port1 <= 0;
	         rom_end_s <= '0';
            rom_end_ss <= rom_end_s;
            rom_end_sss <= rom_end_ss;
          end if;          
        end if;
      end if;
    end process;


            rom_end_o <= rom_end_ss;
            m_axis_pilot_port0_i_o <= port0(complex_w-1 downto 0);
            m_axis_pilot_port0_r_o <= port0(data_w-1 downto complex_w);
            m_axis_pilot_port1_i_o <= port1(complex_w-1 downto 0);
            m_axis_pilot_port1_r_o <= port1(data_w-1 downto complex_w);

    
end rtl;
      