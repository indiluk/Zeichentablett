library ieee;
use ieee.std_logic_1164.all;
use work.vga_buffer_pkg.all;
use work.testbench_util_pkg.all;
use work.constants.all;

entity vga_buffer_tb is
end entity vga_buffer_tb;

architecture sim of vga_buffer_tb is

  signal sys_clk, sys_res_n, tb_buffer_pos, tb_buffer_val, tb_hsync, tb_vsync, tb_den : std_logic;
  signal tb_r, tb_g, tb_b : std_logic_vector(7 downto 0);
  signal raddr1 : std_logic_vector(RAM_DATA_WIDTH - 1 downto 0);
  signal rdata1 : std_logic_vector(( 3 * COLOR_BIT_WIDTH ) - 1 downto 0);
  signal rd1 : std_logic;
  signal stop : boolean := false;
  
  component vga_buffer is
  generic
  (
    CLK_FREQ : integer;
    -- reset value of the output signal
    RESET_VALUE : std_logic;
    H_PIXEL : integer;
    V_PIXEL : integer;
    RAM_DATA_WIDTH : integer;
    COLOR_DATA_WIDTH : integer
  );
  port
  (
    clk   : in std_logic;
    res_n : in std_logic;
    
    nclk  : out std_logic;
    
    raddr1 : out std_logic_vector( RAM_DATA_WIDTH - 1 downto 0);
    rdata1 : in std_logic_vector( ( 3 * COLOR_DATA_WIDTH ) - 1 downto 0);
    rd1    : out std_logic;
    
    hsync : out std_logic;
    vsync : out std_logic;
    r : out std_logic_vector(7 downto 0);
    g : out std_logic_vector(7 downto 0);
    b : out std_logic_vector(7 downto 0);
    den : out std_logic
  );
  end component vga_buffer;

begin
  uut : vga_buffer
    generic map
    (
      CLK_FREQ => VGA_CLK_FREQ,
      RESET_VALUE => RESET_VALUE,
      H_PIXEL => HORIZONTAL_PIXEL,
      V_PIXEL => VERTICAL_PIXEL,
      RAM_DATA_WIDTH => RAM_DATA_WIDTH,
      COLOR_DATA_WIDTH => COLOR_BIT_WIDTH
    )
    port map
    (
      clk => sys_clk,
      res_n => sys_res_n,
      raddr1 => raddr1,
      rdata1 => rdata1,
      rd1 => rd1,
      hsync => tb_hsync,
      vsync => tb_vsync,
      r => tb_r,
      g => tb_g,
      b => tb_b,
      den => tb_den
    );

  process
  begin
    sys_clk <= '0';
    wait for 1 sec/VGA_CLK_FREQ;
    sys_clk <= '1';
    if stop = true then
      wait;
    end if;
    wait for 1 sec/VGA_CLK_FREQ;
  end process;

  process
  begin
    sys_res_n <= '0';
    wait_cycle(sys_clk, 100);
    
    sys_res_n <= '1';
    -- wait_cycle(sys_clk, 5);
    -- rows(0) <= '0';
   
    -- wait_cycle(sys_clk, 10000000);
        
    -- stop <= true;
    wait;
  end process;
end architecture sim;

