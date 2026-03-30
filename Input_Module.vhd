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
        clk            : in  STD_LOGIC;
        reset_n        : in  STD_LOGIC;

        btn_normal_n   : in  STD_LOGIC;
        btn_priority_n : in  STD_LOGIC;
        btn_skip_n     : in  STD_LOGIC;

        normal_req     : out STD_LOGIC;
        priority_req   : out STD_LOGIC;
        skip_req       : out STD_LOGIC
    );
end Input_module;

architecture Behavioral of Input_module is

    signal reset : STD_LOGIC;

    signal btn_normal_i   : STD_LOGIC;
    signal btn_priority_i : STD_LOGIC;
    signal btn_skip_i     : STD_LOGIC;

    
    constant DEBOUNCE_CYCLES : natural := (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

   
    signal count_norm : unsigned(20 downto 0) := (others => '0');
    signal count_prio : unsigned(20 downto 0) := (others => '0');
    signal count_skip : unsigned(20 downto 0) := (others => '0');

    signal clean_norm : STD_LOGIC := '0';
    signal clean_prio : STD_LOGIC := '0';
    signal clean_skip : STD_LOGIC := '0';

    signal prev_norm  : STD_LOGIC := '0';
    signal prev_prio  : STD_LOGIC := '0';
    signal prev_skip  : STD_LOGIC := '0';

    signal sync_norm_0, sync_norm_1 : STD_LOGIC := '0';
    signal sync_prio_0, sync_prio_1 : STD_LOGIC := '0';
    signal sync_skip_0, sync_skip_1 : STD_LOGIC := '0';

begin

    reset          <= not reset_n;
    btn_normal_i   <= not btn_normal_n;
    btn_priority_i <= not btn_priority_n;
    btn_skip_i     <= not btn_skip_n;

    process(clk)
    begin
        if rising_edge(clk) then

            -- synchronous reset
            if reset = '1' then
                count_norm <= (others => '0');
                count_prio <= (others => '0');
                count_skip <= (others => '0');

                clean_norm <= '0';
                clean_prio <= '0';
                clean_skip <= '0';

                prev_norm <= '0';
                prev_prio <= '0';
                prev_skip <= '0';

                sync_norm_0 <= '0';
                sync_norm_1 <= '0';
                sync_prio_0 <= '0';
                sync_prio_1 <= '0';
                sync_skip_0 <= '0';
                sync_skip_1 <= '0';

                normal_req   <= '0';
                priority_req <= '0';
                skip_req     <= '0';

            else
  
                normal_req   <= '0';
                priority_req <= '0';
                skip_req     <= '0';

               
                sync_norm_0 <= btn_normal_i;
                sync_norm_1 <= sync_norm_0;

                sync_prio_0 <= btn_priority_i;
                sync_prio_1 <= sync_prio_0;

                sync_skip_0 <= btn_skip_i;
                sync_skip_1 <= sync_skip_0;

       
                if sync_norm_1 = clean_norm then
                    count_norm <= (others => '0');
                else
                    if to_integer(count_norm) >= DEBOUNCE_CYCLES then
                        clean_norm <= sync_norm_1;
                        count_norm <= (others => '0');
                    else
                        count_norm <= count_norm + 1;
                    end if;
                end if;

 
                if sync_prio_1 = clean_prio then
                    count_prio <= (others => '0');
                else
                    if to_integer(count_prio) >= DEBOUNCE_CYCLES then
                        clean_prio <= sync_prio_1;
                        count_prio <= (others => '0');
                    else
                        count_prio <= count_prio + 1;
                    end if;
                end if;


                if sync_skip_1 = clean_skip then
                    count_skip <= (others => '0');
                else
                    if to_integer(count_skip) >= DEBOUNCE_CYCLES then
                        clean_skip <= sync_skip_1;
                        count_skip <= (others => '0');
                    else
                        count_skip <= count_skip + 1;
                    end if;
                end if;

                if (clean_norm = '1' and prev_norm = '0') then
                    normal_req <= '1';
                end if;

                if (clean_prio = '1' and prev_prio = '0') then
                    priority_req <= '1';
                end if;

                if (clean_skip = '1' and prev_skip = '0') then
                    skip_req <= '1';
                end if;

                prev_norm <= clean_norm;
                prev_prio <= clean_prio;
                prev_skip <= clean_skip;
            end if;
        end if;
    end process;

end Behavioral;
