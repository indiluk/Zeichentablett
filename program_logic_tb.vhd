library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity program_logic_tb is
end entity program_logic_tb;

architecture sim of program_logic_tb is
  
  constant CLK_PERIOD : time := 20 ns;
  constant CLK_FREQ : integer := 50000000;
  
  component program_logic is
  
  generic
  (
    CLK_FREQ : integer;
    -- reset value of the output signal
    RESET_VALUE : std_logic;
    H_PIXEL : integer;
    V_PIXEL : integer;
    R_DATA_WIDTH : integer;
    G_DATA_WIDTH : integer;
    B_DATA_WIDTH : integer
  );
  port
  (
    clk : in std_logic;
    res_n : in std_logic;
    
    b_color : in std_logic;
    b_mode : in std_logic;
    b_reset : in std_logic;
    
    xcoord : in std_logic_vector (7 downto 0);
    ycoord : in std_logic_vector (7 downto 0);
    vals_valid : in std_logic;
    
    debug_lamp : out std_logic;
    
    wr : in std_logic;
    h_addr : in integer range 0 to H_PIXEL - 1;
    v_addr : in integer range 0 to V_PIXEL - 1;
    color_data : in std_logic_vector(R_DATA_WIDTH + G_DATA_WIDTH + B_DATA_WIDTH - 1 downto 0)
  );
  end component program_logic;
  
  
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  signal stop : boolean := false;
  
  signal sync_data_color, sync_data_mode, sync_data_reset, debug_lamp, ram_wr2, vals_valid : std_logic := '0';
  
  signal vga_h_addr, vga_v_addr : integer := 0;
  signal vga_wr : std_logic := '0';
  signal vga_color_data : std_logic_vector ( 3 * COLOR_BIT_WIDTH - 1 downto 0);
  
  signal xcoord, ycoord : std_logic_vector (7 downto 0) := "00000000";
  
begin
  
  uut : program_logic
    generic map (
      CLK_FREQ => SYS_CLK_FREQ,
      RESET_VALUE => RESET_VALUE,
      H_PIXEL => HORIZONTAL_PIXEL,
      V_PIXEL => VERTICAL_PIXEL,
      R_DATA_WIDTH => COLOR_BIT_WIDTH,
      G_DATA_WIDTH => COLOR_BIT_WIDTH,
      B_DATA_WIDTH => COLOR_BIT_WIDTH
    )
    port map (
      clk => clk,
      res_n => res_n,
      b_color => sync_data_color,
      b_mode => sync_data_mode,
      b_reset => sync_data_reset,
      xcoord => xcoord,
      ycoord => ycoord,
      vals_valid => vals_valid,
      debug_lamp => debug_lamp,
      h_addr => vga_h_addr,
      v_addr => vga_v_addr,
      color_data => vga_color_data,
      wr => vga_wr
    );
  
  
  process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    if stop = true then
      wait;
    end if;
    wait for CLK_PERIOD/2;
  end process;
  
  process
  begin
    res_n <= '0';
    wait for 104167 ns;
    res_n <= '1';
    wait for 5000000 ns;
    
    stop <= true;
    wait;
  end process; 
  

end architecture sim;
