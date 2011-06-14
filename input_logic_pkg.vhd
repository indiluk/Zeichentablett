library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------
package input_logic_pkg is

  --------------------------------------------------------------------
  --                          COMPONENT                             --
  --------------------------------------------------------------------
  
  -- serial connection of flip-flops to avoid latching of metastable inputs at
  -- the analog/digital interface
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
      
      xcoord : out std_logic_vector (71 downto 0);
      ycoord : out std_logic_vector (7 downto 0);
      vals_valid : out std_logic
    );
  end component input_logic;
end package input_logic_pkg;

--- EOF ---
