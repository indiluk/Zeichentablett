library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity zeichentablett is
  port
  (
    
    sys_clk : in std_logic;
    LTM_NCLK : out std_logic;
    LTM_ADC_DCLK : out std_logic;
    res_n : in std_logic;
    
    b_color : in std_logic;
    b_mode : in std_logic;
    b_reset : in std_logic;
    
    LTM_ADC_PENIRQ_n : in std_logic;
    LTM_ADC_BUSY : in std_logic;
    LTM_ADC_DOUT : in std_logic;
    LTM_ADC_DIN : out std_logic;
    
    LTM_GREST : out std_logic;
    
    LTM_SCEN : out std_logic;
    LTM_SDA : inout std_logic;
    
    LTM_HD : out std_logic;
    LTM_VD : out std_logic;
    LTM_R : out std_logic_vector(7 downto 0);
    LTM_G : out std_logic_vector(7 downto 0);
    LTM_B : out std_logic_vector(7 downto 0);
    LTM_DEN : out std_logic;
    
    debug_lamp : out std_logic
    
  );
end entity zeichentablett;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture sim of zeichentablett is
  
  signal vga_clk : std_logic := '0';
  signal reset : std_logic := '0';
  
  signal sync_data_color, sync_data_mode, sync_data_reset, input_logic_enable, vals_valid : std_logic := '0';
  
  signal raddr1, waddr2 : std_logic_vector(RAM_DATA_WIDTH - 1 downto 0);
  signal rdata1, wdata2 : std_logic_vector(( 3 * COLOR_BIT_WIDTH ) - 1 downto 0);
  signal rd1, wr2 : std_logic;
  
  signal xcoord, ycoord : std_logic_vector (7 downto 0) := "00000000";
  
  component pll is
    port
		(
			inclk0		: in STD_LOGIC  := '0';
			c0		: out STD_LOGIC;
			c1		: out STD_LOGIC 
		);
  end component pll;
  
  component sync is
    generic
    (
      -- number of stages in the input synchronizer
      SYNC_STAGES : integer range 2 to integer'high;
      -- reset value of the output signal
      RESET_VALUE : std_logic
    );
    port
    (
      clk       : in std_logic;
      res_n     : in std_logic;
      
      data_in   : in std_logic;
      data_out  : out std_logic
    );
  end component sync;
  
  component input_logic is
    generic
    (
      -- reset value of the output signal
      RESET_VALUE : std_logic;
      CLK_DIVISOR : integer;
      DATA_WIDTH : integer
    );
    port
    (
      clk   : in std_logic;
      res_n : in std_logic;
    
      busy : in std_logic;
      dout : in std_logic;
      input_logic_enable : in std_logic;
      penirq : in std_logic;
      
      cs : out std_logic;
      din : out std_logic;
      
      xcoord : out std_logic_vector (7 downto 0);
      ycoord : out std_logic_vector (7 downto 0);
      vals_valid : out std_logic

    );
  end component input_logic;
  
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
  
  component program_logic is
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
      clk : in std_logic;
      res_n : in std_logic;
    
      b_color : in std_logic;
      b_mode : in std_logic;
      b_reset : in std_logic;
    
      xcoord : in std_logic_vector (7 downto 0);
      ycoord : in std_logic_vector (7 downto 0);
      vals_valid : in std_logic;
    
      debug_lamp : out std_logic;
    
      waddr2 : out std_logic_vector( RAM_DATA_WIDTH - 1 downto 0);
      wdata2 : out std_logic_vector( ( 3 * COLOR_DATA_WIDTH ) - 1 downto 0);
      wr2    : out std_logic
    );
  
  end component program_logic;
  
  component dp_ram_1c1r1w is
    generic
    (
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer
    );
    port
    (
      clk    : in std_logic;
    
      raddr1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      rdata1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      rd1    : in std_logic;
    
      waddr2 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wdata2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
      wr2    : in std_logic
    );
  end component dp_ram_1c1r1w;
  
  begin
    
  pll_inst : pll
    port map (
      inclk0 => sys_clk,
      c0 => vga_clk,
      c1 => LTM_ADC_DCLK
    );
    
  sync_color_button : sync
    generic map (
      SYNC_STAGES => SYNC_STAGES,
      RESET_VALUE => RESET_VALUE
    )
    port map (
      clk => sys_clk,
      res_n => res_n,
      data_in => b_color,
      data_out => sync_data_color
    );
    
  sync_mode_button : sync
    generic map (
      SYNC_STAGES => SYNC_STAGES,
      RESET_VALUE => RESET_VALUE
    )
    port map (
      clk => sys_clk,
      res_n => res_n,
      data_in => b_mode,
      data_out => sync_data_mode
    );
    
  sync_reset_button : sync
    generic map (
      SYNC_STAGES => SYNC_STAGES,
      RESET_VALUE => RESET_VALUE
    )
    port map (
      clk => sys_clk,
      res_n => res_n,
      data_in => b_reset,
      data_out => sync_data_reset
    );
    
  input_logic_inst : input_logic
    generic map (
      RESET_VALUE => RESET_VALUE,
      CLK_DIVISOR => CLK_DIVISOR,
      DATA_WIDTH => ADC_DATA_WIDTH
    )
    port map (
      clk => sys_clk,
      res_n => res_n,
      busy => LTM_ADC_BUSY,
      dout => LTM_ADC_DOUT,
      input_logic_enable => input_logic_enable,
      xcoord => xcoord,
      ycoord => ycoord,
      vals_valid => vals_valid,
      din => LTM_ADC_DIN,
      penirq => LTM_ADC_PENIRQ_n,
      cs => LTM_SCEN
    );
    
  vga_output : vga_buffer
    generic map (
        CLK_FREQ => VGA_CLK_FREQ,
        RESET_VALUE => RESET_VALUE,
        H_PIXEL => HORIZONTAL_PIXEL,
        V_PIXEL => VERTICAL_PIXEL,
        RAM_DATA_WIDTH => RAM_DATA_WIDTH,
        COLOR_DATA_WIDTH => COLOR_BIT_WIDTH
    )
    port map (
        clk => vga_clk,
        res_n => res_n,
        nclk => LTM_NCLK,
        raddr1 => raddr1,
        rdata1 => rdata1,
        rd1 => rd1,
        hsync => LTM_HD,
        vsync => LTM_VD,
        r => LTM_R,
        g => LTM_G,
        b => LTM_B,
        den => LTM_DEN
    );
      
  program_logic_inst : program_logic
    generic map (
      CLK_FREQ => SYS_CLK_FREQ,
      RESET_VALUE => RESET_VALUE,
      H_PIXEL => HORIZONTAL_PIXEL,
      V_PIXEL => VERTICAL_PIXEL,
      RAM_DATA_WIDTH => RAM_DATA_WIDTH,
      COLOR_DATA_WIDTH => COLOR_BIT_WIDTH
    )
    port map (
      clk => sys_clk,
      res_n => res_n,
      b_color => sync_data_color,
      b_mode => sync_data_mode,
      b_reset => sync_data_reset,
      xcoord => xcoord,
      ycoord => ycoord,
      vals_valid => vals_valid,
      debug_lamp => debug_lamp,
      waddr2 => waddr2,
      wdata2 => wdata2,
      wr2 => wr2
    );
    
  ram_inst : dp_ram_1c1r1w
    generic map (
       ADDR_WIDTH => RAM_DATA_WIDTH,
       DATA_WIDTH => ( 3 * COLOR_BIT_WIDTH )
    )
    port map (
      clk => sys_clk,
      raddr1 => raddr1,
      rdata1 => rdata1,
      rd1 => rd1,
      waddr2 => waddr2,
      wdata2 => wdata2,
      wr2 => wr2
    );
  
end architecture sim;

