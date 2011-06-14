----------------------------------------------------------------------------------
-- Engineer:     Lukas Aumair                                                   --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  Hardwaremodellierung                                                         --
-- Module Name:  vga_buffer                                                           --
-- Project Name: zeichentablett                                                         --
-- Description:  vga_buffer - Entity                                          --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity vga_buffer is
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
end entity vga_buffer;

--- EOF ---
