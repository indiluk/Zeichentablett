----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of vga_buffer is
  
  constant T_HBP : integer := 216;
  constant T_HFP : integer := 40;
  constant T_EP : integer := 800;
  
  constant T_VBP : integer := 35;
  constant T_VFP : integer := 10;
  
  constant COLOR_BIT_WIDTH : integer := 3 * COLOR_DATA_WIDTH;
  
  type VGA_STATE_TYPE is
    (
      INIT_VGA,
      VGA_EXECUTE
    );
    
  type HSYNC_STATE_TYPE is
    (
      HSYNC_START,
      HSYNC_PULLHIGH,
      HSYNC_EXECUTE,
      HSYNC_FRONTPORCH
    );
    
  type VSYNC_STATE_TYPE is
    (
      VSYNC_START,
      VSYNC_PULLHIGH,
      VSYNC_EXECUTE,
      VSYNC_FRONTPORCH
    );
  
  signal clk_cnt, clk_cnt_next : integer := 0;
  
  signal vga_state, vga_state_next : VGA_STATE_TYPE := INIT_VGA;
  
  signal hsync_state, hsync_state_next : HSYNC_STATE_TYPE := HSYNC_START;
  signal hsync_ctr, hsync_ctr_next : integer := 0;
  
  signal vsync_state, vsync_state_next : VSYNC_STATE_TYPE := VSYNC_START;
  signal vsync_ctr, vsync_ctr_next : integer := 0;
  
begin

    vga_proc : process(clk,vga_state,hsync_state,vsync_state,clk_cnt,hsync_ctr,vsync_ctr,rdata1)
    
    begin
      
      vga_state_next <= vga_state;
      hsync_state_next <= hsync_state;
      vsync_state_next <= vsync_state;
      clk_cnt_next <= clk_cnt;
      hsync_ctr_next <= hsync_ctr;
      vsync_ctr_next <= vsync_ctr;
      rd1 <= '0';
		hsync <= '0';
		vsync <= '0';
		den <= '0';
		r <= (others => '0');
		g <= (others => '0');
		b <= (others => '0');
		raddr1 <= (others => '0');
      
      case vga_state is
        
        when INIT_VGA =>
          
          hsync <= '1';
          vsync <= '1';
          den <= '0';
          
          vga_state_next <= VGA_EXECUTE;
          
          hsync_state_next <= HSYNC_START;
          vsync_state_next <= VSYNC_START;
          
        when VGA_EXECUTE =>
          -- PULL VSYNC HIGH --
          case vsync_state is
            
            when VSYNC_START =>
              vsync_state_next <= VSYNC_PULLHIGH;
              clk_cnt_next <= 0;
              den <= '0';
              vsync_ctr_next <= 0;
              
            when VSYNC_PULLHIGH =>
              vsync <= '1';
              
              if (clk_cnt = T_VBP) then
                vsync_state_next <= VSYNC_EXECUTE;
                hsync_state_next <= HSYNC_START;
                clk_cnt_next <= 0;
              end if;
              
            when VSYNC_EXECUTE =>
              
              case hsync_state is
                
                when HSYNC_START =>
                  hsync_state_next <= HSYNC_PULLHIGH;
                  clk_cnt_next <= 0;
                  
                when HSYNC_PULLHIGH =>
                  hsync <= '1';
                  if (clk_cnt = T_HBP) then
                    hsync_state_next <= HSYNC_EXECUTE;
                    clk_cnt_next <= 0;
                    hsync_ctr_next <= 0;
                  end if;
                  
                when HSYNC_EXECUTE =>
                  den <= '1';
                  
                  rd1 <= '1';
                  raddr1 <= std_logic_vector( to_unsigned( vsync_ctr * V_PIXEL + clk_cnt , RAM_DATA_WIDTH ) );
                  
                  -- OUTPUT BUFFER TO RGB --
						      r <= rdata1( COLOR_DATA_WIDTH * 3 - 1 downto COLOR_DATA_WIDTH * 2 );
						      g <= rdata1( COLOR_DATA_WIDTH * 2 - 1 downto COLOR_DATA_WIDTH );
						      b <= rdata1( COLOR_DATA_WIDTH - 1 downto 0 );
						      
                  if (clk_cnt = T_EP) then
                    hsync_state_next <= HSYNC_FRONTPORCH;
                    clk_cnt_next <= 0;
                  end if;
                  
                when HSYNC_FRONTPORCH =>
                  den <= '0';
                  if (clk_cnt = T_HFP) then
                    vsync_state_next <= VSYNC_FRONTPORCH;
                    clk_cnt_next <= 0;
                  end if;
                
              end case;
              
            when VSYNC_FRONTPORCH =>
              
              if (clk_cnt = T_VFP) then
                
                if(vsync_ctr < V_PIXEL) then
                  vsync_ctr_next <= vsync_ctr + 1;
                else
                  vsync_ctr_next <= 0;
                end if;
                
                vsync_state_next <= VSYNC_START;
                
              end if;            
            
          end case;
        
      end case;
      
    end process vga_proc;
    
    
    vga_sync : process(clk, res_n,vga_state_next,hsync_state_next,hsync_ctr_next,vsync_state_next,vsync_ctr_next,clk_cnt_next)
  
    begin
    
      if res_n = '0' then
        
        vga_state <= INIT_VGA;
        hsync_state <= HSYNC_START;
        vsync_state <= VSYNC_START;
        hsync_ctr <= 0;
        vsync_ctr <= 0;
        clk_cnt <= 0;
        nclk <= '0';
      
      elsif rising_edge(clk) then
        
        vga_state <= vga_state_next;
        
        hsync_state <= hsync_state_next;
        hsync_ctr <= hsync_ctr_next;
        vsync_state <= vsync_state_next;
        vsync_ctr <= vsync_ctr_next;
        
        clk_cnt <= clk_cnt_next + 1;
        
        nclk <= clk;
        
      end if;
    
    end process vga_sync;
  
  
  
end architecture beh;

--- EOF ---