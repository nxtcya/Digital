----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:28:41 03/30/2026 
-- Design Name: 
-- Module Name:    Input_module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Input_module is
    generic (
        CLK_FREQ_HZ : natural := 50000000; -- 50 MHz
        DEBOUNCE_MS : natural := 20        -- 20 ms
    );
    Port (
        clk             : in  STD_LOGIC;
        reset_n         : in  STD_LOGIC;

        
        btn_normal_n    : in  STD_LOGIC;
        btn_priority_n  : in  STD_LOGIC;
        btn_skip1_n     : in  STD_LOGIC;
        btn_skip2_n     : in  STD_LOGIC;
        btn_skip3_n     : in  STD_LOGIC;

       
        sw_counter1     : in  STD_LOGIC;
        sw_counter2     : in  STD_LOGIC;
        sw_counter3     : in  STD_LOGIC;

        
        normal_req      : out STD_LOGIC;
        priority_req    : out STD_LOGIC;
        skip1_req       : out STD_LOGIC;
        skip2_req       : out STD_LOGIC;
        skip3_req       : out STD_LOGIC;

        
        counter1_en     : out STD_LOGIC;
        counter2_en     : out STD_LOGIC;
        counter3_en     : out STD_LOGIC
    );
end Input_module;

architecture Behavioral of Input_module is

  
    function clog2(n : natural) return natural is
        variable i : natural := 0;
        variable v : natural := 1;
    begin
        while v < n loop
            v := v * 2;
            i := i + 1;
        end loop;
        return i;
    end function;

    constant DEBOUNCE_CYCLES : natural := (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
    constant CNT_WIDTH       : natural := clog2(DEBOUNCE_CYCLES + 1);

    signal reset : STD_LOGIC;

    signal btn_normal_i   : STD_LOGIC;
    signal btn_priority_i : STD_LOGIC;
    signal btn_skip1_i    : STD_LOGIC;
    signal btn_skip2_i    : STD_LOGIC;
    signal btn_skip3_i    : STD_LOGIC;

    signal sync_norm_0,  sync_norm_1  : STD_LOGIC := '0';
    signal sync_prio_0,  sync_prio_1  : STD_LOGIC := '0';
    signal sync_skip1_0, sync_skip1_1 : STD_LOGIC := '0';
    signal sync_skip2_0, sync_skip2_1 : STD_LOGIC := '0';
    signal sync_skip3_0, sync_skip3_1 : STD_LOGIC := '0';

   
    signal sync_sw1_0, sync_sw1_1 : STD_LOGIC := '0';
    signal sync_sw2_0, sync_sw2_1 : STD_LOGIC := '0';
    signal sync_sw3_0, sync_sw3_1 : STD_LOGIC := '0';

    
    signal count_norm  : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
    signal count_prio  : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
    signal count_skip1 : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
    signal count_skip2 : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');
    signal count_skip3 : unsigned(CNT_WIDTH-1 downto 0) := (others => '0');

   
    signal clean_norm  : STD_LOGIC := '0';
    signal clean_prio  : STD_LOGIC := '0';
    signal clean_skip1 : STD_LOGIC := '0';
    signal clean_skip2 : STD_LOGIC := '0';
    signal clean_skip3 : STD_LOGIC := '0';

    
    signal prev_norm  : STD_LOGIC := '0';
    signal prev_prio  : STD_LOGIC := '0';
    signal prev_skip1 : STD_LOGIC := '0';
    signal prev_skip2 : STD_LOGIC := '0';
    signal prev_skip3 : STD_LOGIC := '0';

begin


    reset          <= not reset_n;

    btn_normal_i   <= not btn_normal_n;
    btn_priority_i <= not btn_priority_n;
    btn_skip1_i    <= not btn_skip1_n;
    btn_skip2_i    <= not btn_skip2_n;
    btn_skip3_i    <= not btn_skip3_n;

  
    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                
                count_norm  <= (others => '0');
                count_prio  <= (others => '0');
                count_skip1 <= (others => '0');
                count_skip2 <= (others => '0');
                count_skip3 <= (others => '0');

                
                clean_norm  <= '0';
                clean_prio  <= '0';
                clean_skip1 <= '0';
                clean_skip2 <= '0';
                clean_skip3 <= '0';

            
                prev_norm  <= '0';
                prev_prio  <= '0';
                prev_skip1 <= '0';
                prev_skip2 <= '0';
                prev_skip3 <= '0';

               
                sync_norm_0  <= '0';
                sync_norm_1  <= '0';
                sync_prio_0  <= '0';
                sync_prio_1  <= '0';
                sync_skip1_0 <= '0';
                sync_skip1_1 <= '0';
                sync_skip2_0 <= '0';
                sync_skip2_1 <= '0';
                sync_skip3_0 <= '0';
                sync_skip3_1 <= '0';

               
                sync_sw1_0 <= '0';
                sync_sw1_1 <= '0';
                sync_sw2_0 <= '0';
                sync_sw2_1 <= '0';
                sync_sw3_0 <= '0';
                sync_sw3_1 <= '0';

            
                normal_req   <= '0';
                priority_req <= '0';
                skip1_req    <= '0';
                skip2_req    <= '0';
                skip3_req    <= '0';

                counter1_en  <= '0';
                counter2_en  <= '0';
                counter3_en  <= '0';

            else
             
                normal_req   <= '0';
                priority_req <= '0';
                skip1_req    <= '0';
                skip2_req    <= '0';
                skip3_req    <= '0';

     
                sync_norm_0  <= btn_normal_i;
                sync_norm_1  <= sync_norm_0;

                sync_prio_0  <= btn_priority_i;
                sync_prio_1  <= sync_prio_0;

                sync_skip1_0 <= btn_skip1_i;
                sync_skip1_1 <= sync_skip1_0;

                sync_skip2_0 <= btn_skip2_i;
                sync_skip2_1 <= sync_skip2_0;

                sync_skip3_0 <= btn_skip3_i;
                sync_skip3_1 <= sync_skip3_0;

                sync_sw1_0   <= sw_counter1;
                sync_sw1_1   <= sync_sw1_0;

                sync_sw2_0   <= sw_counter2;
                sync_sw2_1   <= sync_sw2_0;

                sync_sw3_0   <= sw_counter3;
                sync_sw3_1   <= sync_sw3_0;

         
                counter1_en <= sync_sw1_1;
                counter2_en <= sync_sw2_1;
                counter3_en <= sync_sw3_1;

    
                if sync_norm_1 = clean_norm then
                    count_norm <= (others => '0');
                else
                    if count_norm = to_unsigned(DEBOUNCE_CYCLES - 1, CNT_WIDTH) then
                        clean_norm <= sync_norm_1;
                        count_norm <= (others => '0');
                    else
                        count_norm <= count_norm + 1;
                    end if;
                end if;

                if sync_prio_1 = clean_prio then
                    count_prio <= (others => '0');
                else
                    if count_prio = to_unsigned(DEBOUNCE_CYCLES - 1, CNT_WIDTH) then
                        clean_prio <= sync_prio_1;
                        count_prio <= (others => '0');
                    else
                        count_prio <= count_prio + 1;
                    end if;
                end if;


                if sync_skip1_1 = clean_skip1 then
                    count_skip1 <= (others => '0');
                else
                    if count_skip1 = to_unsigned(DEBOUNCE_CYCLES - 1, CNT_WIDTH) then
                        clean_skip1 <= sync_skip1_1;
                        count_skip1 <= (others => '0');
                    else
                        count_skip1 <= count_skip1 + 1;
                    end if;
                end if;

                
             
                if sync_skip2_1 = clean_skip2 then
                    count_skip2 <= (others => '0');
                else
                    if count_skip2 = to_unsigned(DEBOUNCE_CYCLES - 1, CNT_WIDTH) then
                        clean_skip2 <= sync_skip2_1;
                        count_skip2 <= (others => '0');
                    else
                        count_skip2 <= count_skip2 + 1;
                    end if;
                end if;

           
                if sync_skip3_1 = clean_skip3 then
                    count_skip3 <= (others => '0');
                else
                    if count_skip3 = to_unsigned(DEBOUNCE_CYCLES - 1, CNT_WIDTH) then
                        clean_skip3 <= sync_skip3_1;
                        count_skip3 <= (others => '0');
                    else
                        count_skip3 <= count_skip3 + 1;
                    end if;
                end if;

       
                if (clean_norm = '1') and (prev_norm = '0') then
                    normal_req <= '1';
                end if;

                if (clean_prio = '1') and (prev_prio = '0') then
                    priority_req <= '1';
                end if;

                if (clean_skip1 = '1') and (prev_skip1 = '0') then
                    skip1_req <= '1';
                end if;

                if (clean_skip2 = '1') and (prev_skip2 = '0') then
                    skip2_req <= '1';
                end if;

                if (clean_skip3 = '1') and (prev_skip3 = '0') then
                    skip3_req <= '1';
                end if;

          
                prev_norm  <= clean_norm;
                prev_prio  <= clean_prio;
                prev_skip1 <= clean_skip1;
                prev_skip2 <= clean_skip2;
                prev_skip3 <= clean_skip3;
            end if;
        end if;
    end process;

end Behavioral;

