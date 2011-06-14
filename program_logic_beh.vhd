library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of program_logic is
  
  
  begin
    
  sync : process(clk, res_n)
  begin
    if res_n = '0' then
      debug_lamp <= '0';
    elsif rising_edge(clk) then
      debug_lamp <= '1';
    end if;
  end process sync;
  
end architecture beh;
