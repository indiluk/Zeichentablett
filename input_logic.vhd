----------------------------------------------------------------------------------
-- Engineer:     Lukas Aumair                                                   --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  Hardwaremodellierung                                                         --
-- Module Name:  input_logic                                                           --
-- Project Name: zeichentablett                                                         --
-- Description:  input_logic - Entity                                          --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity input_logic is
  generic
  (
    -- reset value of the output signal
    RESET_VALUE : std_logic := '0';
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
end entity input_logic;

--- EOF ---
