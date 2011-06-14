library ieee;
use ieee.std_logic_1164.all;

package constants is
  
  constant SYS_CLK_FREQ : integer := 50000000;
  constant VGA_CLK_FREQ : integer := 33200000;
  
  constant RESET_VALUE  : std_logic := '1';
  constant SYNC_STAGES  : integer := 3;
  
  constant CLK_DIVISOR : integer := 1234; -- tbd
  constant ADC_DATA_WIDTH : integer := 8;
  
  constant HORIZONTAL_PIXEL : integer := 800;
  constant VERTICAL_PIXEL : integer := 450;
  constant RAM_DATA_WIDTH : integer := 16;
  constant COLOR_BIT_WIDTH : integer := 8;
  
end package;