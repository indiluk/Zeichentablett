library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of input_logic is
  constant A2 : std_logic := '0';     -- A2/A1/A0 .... X:0/0/1; Y:1/0/1
  constant A1 : std_logic := '0';
  constant A0 : std_logic := '1';
  constant A2_2 : std_logic := '1';     -- A2/A1/A0 .... X:0/0/1; Y:1/0/1
  constant A1_2 : std_logic := '0';
  constant A0_2 : std_logic := '1';
  constant ADC_MODE : std_logic := '1'; -- 8 bit conversion
  constant SER_DFR : std_logic := '0';  -- differntial mode
  constant PD1 : std_logic := '1';  -- PENIRQ enabled, device permanently powered up
  constant PD0 : std_logic := '0';   -- PENIRQ enabled, device permanently powered up

  type INPUT_LOGIC_STATE_TYPE is
    (
      IDLE,
      BEGIN_START, 
      BEGIN_A2, 
      BEGIN_A1,
      BEGIN_A0,
      BEGIN_MODE,
      BEGIN_SER_DFR,
      BEGIN_PD1,
      BEGIN_PD0,
      CHECK_BUSY_HIGH,
      WAIT_BUSY_LOW,
      GOTO_MIDDLE_OF_DATABIT,
      MIDDLE_OF_DATABIT,
      BEGIN_START_2, 
      BEGIN_A2_2, 
      BEGIN_A1_2,
      BEGIN_A0_2,
      BEGIN_MODE_2,
      BEGIN_SER_DFR_2,
      BEGIN_PD1_2,
      BEGIN_PD0_2,
      CHECK_BUSY_HIGH_2,
      WAIT_BUSY_LOW_2,
      GOTO_MIDDLE_OF_DATABIT_2,
      MIDDLE_OF_DATABIT_2,
      FINISHED
    );
  
  signal input_state, input_state_next : INPUT_LOGIC_STATE_TYPE;
  signal clk_cnt, clk_cnt_next : integer := 0;
  signal bit_cnt, bit_cnt_next : integer range 0 to (DATA_WIDTH-1);
  signal data_int,data_int_next : std_logic_vector((DATA_WIDTH-1) downto 0);
  
  begin
  next_state : process (input_state,clk_cnt,bit_cnt,data_int,input_logic_enable,busy,dout)
  begin
      input_state_next <= input_state;
      clk_cnt_next <= clk_cnt;
      bit_cnt_next <= bit_cnt;
      data_int_next <= data_int;
      vals_valid <= '0';
      xcoord <= "00000000";
      ycoord <= "00000000";
		din <= '0';

      case input_state is
        when IDLE =>
          if (input_logic_enable = '1') then
            input_state_next <= BEGIN_START;
            clk_cnt_next <= 0;
          end if;
        
        -- read x coord
        
        when BEGIN_START =>
          vals_valid <= '0';
          din <= '1';
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A2;
            clk_cnt_next <= 0;
          end if;
          

        when BEGIN_A2 =>
          din <= A2;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A1;
            clk_cnt_next <= 0;  
          end if;   
           
          
        when BEGIN_A1 =>
          din <= A1;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A0;
            clk_cnt_next <= 0;
          end if;   
          

        when BEGIN_A0 =>
          din <= A0;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_MODE;
            clk_cnt_next <= 0;
          end if;   
          
          
        when BEGIN_MODE =>
          din <= ADC_MODE;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_SER_DFR;
            clk_cnt_next <= 0;
          end if;
          
          
        when BEGIN_SER_DFR =>
          din <= SER_DFR;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_PD1;
            clk_cnt_next <= 0;
          end if;
          
          
        when BEGIN_PD1 =>
          din <= PD1;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_PD0;
            clk_cnt_next <= 0; 
          end if;  
                           
        
        when BEGIN_PD0 =>
          din <= PD0;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= CHECK_BUSY_HIGH;
            clk_cnt_next <= 0; 
          end if;     
          
          
        when CHECK_BUSY_HIGH =>
          if (busy = '1') then
            input_state_next <= WAIT_BUSY_LOW;
          end if;    
          
        when WAIT_BUSY_LOW =>
          if (busy = '0') then
            input_state_next <= GOTO_MIDDLE_OF_DATABIT;
          end if;   
          clk_cnt_next <= 0;
          bit_cnt_next <= 0;
          
        when GOTO_MIDDLE_OF_DATABIT =>
          if (clk_cnt = CLK_DIVISOR/2) then
            input_state_next <= MIDDLE_OF_DATABIT;
          end if;  
          
        when MIDDLE_OF_DATABIT =>
          data_int_next <= dout & data_int(7 downto 1);
          if(bit_cnt < 7) then
            input_state_next <= GOTO_MIDDLE_OF_DATABIT;
          elsif(bit_cnt = 7 ) then
            input_state_next <= BEGIN_START_2;
          end if;
          clk_cnt_next <= 0;
          if(bit_cnt < 7) then
            bit_cnt_next <= bit_cnt + 1;
          end if;
          
        
        -- read y coord
        when BEGIN_START_2 =>
          xcoord <= data_int;
          din <= '1';
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A2_2;
            clk_cnt_next <= 0;
          end if;
          

        when BEGIN_A2_2 =>
          data_int_next <= "00000000";
          din <= A2_2;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A1_2;
            clk_cnt_next <= 0;  
          end if;   
           
          
        when BEGIN_A1_2 =>
          din <= A1_2;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_A0_2;
            clk_cnt_next <= 0;
          end if;   
          

        when BEGIN_A0_2 =>
          din <= A0_2;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_MODE_2;
            clk_cnt_next <= 0;
          end if;   
          
          
        when BEGIN_MODE_2 =>
          din <= ADC_MODE;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_SER_DFR_2;
            clk_cnt_next <= 0;
          end if;
          
          
        when BEGIN_SER_DFR_2 =>
          din <= SER_DFR;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_PD1_2;
            clk_cnt_next <= 0;
          end if;
          
          
        when BEGIN_PD1_2 =>
          din <= PD1;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= BEGIN_PD0_2;
            clk_cnt_next <= 0; 
          end if;  
                           
        
        when BEGIN_PD0_2 =>
          din <= PD0;
          if (clk_cnt = CLK_DIVISOR) then
            input_state_next <= CHECK_BUSY_HIGH_2;
            clk_cnt_next <= 0; 
          end if;     
          
          
        when CHECK_BUSY_HIGH_2 =>
          if (busy = '1') then
            input_state_next <= WAIT_BUSY_LOW_2;
          end if;    
          
        when WAIT_BUSY_LOW_2 =>
          if (busy = '0') then
            input_state_next <= GOTO_MIDDLE_OF_DATABIT_2;
          end if;   
          clk_cnt_next <= 0;
          bit_cnt_next <= 0;
          
        when GOTO_MIDDLE_OF_DATABIT_2 =>
          if (clk_cnt = CLK_DIVISOR/2) then
            input_state_next <= MIDDLE_OF_DATABIT_2;
          end if;  
          
        when MIDDLE_OF_DATABIT_2 =>
          data_int_next <= dout & data_int(7 downto 1);
          if(bit_cnt < 7) then
            input_state_next <= GOTO_MIDDLE_OF_DATABIT_2;
          elsif(bit_cnt = 7 ) then
            input_state_next <= FINISHED;
          end if;
          clk_cnt_next <= 0;
          if(bit_cnt < 7) then
            bit_cnt_next <= bit_cnt + 1;
          end if;
        
        when FINISHED =>
          ycoord <= data_int;
          vals_valid <= '1';
        
        
      end case;
  end process next_state;
  
  
  
  sync : process(clk, res_n)
  begin
    if res_n = '0' then
      input_state <= IDLE;
      clk_cnt <= 0;
    elsif rising_edge(clk) then
      input_state <= input_state_next;
      clk_cnt <= clk_cnt_next + 1;
    		bit_cnt <= bit_cnt_next;
		  data_int <= data_int_next;
    end if;
  end process sync;

  
end architecture beh;