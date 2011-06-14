library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity program_logic is
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
end entity program_logic;
