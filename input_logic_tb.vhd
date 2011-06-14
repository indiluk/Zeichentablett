library ieee;
use ieee.std_logic_1164.all;

entity input_logic_tb is
end entity input_logic_tb;

architecture sim of input_logic_tb is
  
  constant CLK_PERIOD : time := 20 ns;
  constant CLK_FREQ : integer := 50000000;
  
  component input_logic is
  generic 
  (
    -- reset value of the output signal
    RESET_VALUE : std_logic := '0';
    CLK_DIVISOR : integer
  );
  port
  (
    clk   : in std_logic;
    res_n : in std_logic;
    
    color : in std_logic;
    mode : in std_logic;
    reset : in std_logic;
    penirq : in std_logic;
    busy : in std_logic;
    dout : in std_logic;
    enable : in std_logic;
    
    xcoord : out std_logic_vector (7 downto 0);
    ycoord : out std_logic_vector (7 downto 0);
    vals_valid : out std_logic;

    cs : out std_logic;
    din : out std_logic
  );
  end component input_logic;
  
  
  signal clk : std_logic := '0';
  signal res_n : std_logic := '0';
  
  signal color : std_logic := '0';
  signal mode : std_logic := '0';
  signal reset : std_logic := '0';
  signal penirq : std_logic := '0';
  signal busy : std_logic := '0';
  signal dout : std_logic := '0';
  signal enable : std_logic := '0';
    
  signal xcoord : std_logic_vector (7 downto 0) := (others => '0');
  signal ycoord : std_logic_vector (7 downto 0) := (others => '0');
  signal vals_valid : std_logic := '0';

  signal cs : std_logic := '0';
  signal din : std_logic := '0';
  
  signal stop : boolean := false;
  
begin
  
  uut : input_logic
    generic map
    (
       -- reset value of the output signal
      RESET_VALUE => '0',
      CLK_DIVISOR => 10000
      --CLK_DIVISOR => (CLK_FREQ/BAUDRATE),

    )
    port map
    (
      clk => clk,
      res_n => res_n,
    
      color => color,
      mode => mode,
      reset => reset,
      penirq => penirq,
      busy => busy,
      dout => dout,
      enable => enable,
    
      xcoord => xcoord,
      ycoord => ycoord,
      vals_valid => vals_valid,
    
      cs => cs,
      din => din
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
    res_n <= '1';
    wait for 104167 ns;
    res_n <= '0';
    wait for 104167 ns;
    res_n <= '1';
    wait for 104167 ns;
    enable <= '1';
    wait for 5000000 ns;
    
    stop <= true;
    wait;
  end process; 
  

end architecture sim;
