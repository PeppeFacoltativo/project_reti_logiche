----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2021 16:14:15
-- Design Name: 
-- Module Name: project_reti_logiche - lambda
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

component datapath is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;
           i_start : in std_logic;
           i_data : in std_logic_vector(7 downto 0);
           o_addr : out std_logic_vector(15 downto 0);
           r_max_load : in STD_LOGIC;
           r_min_load : in STD_LOGIC;
           r_ncols_load : in STD_LOGIC;
           r_nrows_load : in STD_LOGIC;
           r_ncells_load : in STD_LOGIC;
           r_currpixel_load : in STD_LOGIC;
           r_newpixel_load : in STD_LOGIC;
           r_counter_load : in STD_LOGIC;
           ctrl1 : in STD_LOGIC;
           ctrl2 : in STD_LOGIC;
           ctrl3 : in STD_LOGIC;
           o_endcount : out STD_LOGIC;
           o_greaterthanmax : out STD_LOGIC;
           o_smallerthanmin : out STD_LOGIC);
end component;

signal r_max_load : STD_LOGIC;
signal r_min_load : STD_LOGIC;
signal r_ncols_load : STD_LOGIC;
signal r_nrows_load : STD_LOGIC;
signal r_ncells_load : STD_LOGIC;
signal r_currpixel_load : STD_LOGIC;
signal r_newpixel_load : STD_LOGIC;
signal r_counter_load : STD_LOGIC;
signal ctrl1 : STD_LOGIC;
signal ctrl2 : STD_LOGIC;
signal ctrl3 : STD_LOGIC;
signal o_endcount : STD_LOGIC;
signal o_greaterthanmax : STD_LOGIC;
signal o_smallerthanmin : STD_LOGIC;
signal o_addr : STD_LOGIC_VECTOR(15 downto 0);

type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15);
signal cur_state, next_state : S;

begin
    DATAPATH0 : datapath port map(
        i_clk,
        i_rst,
        i_start,
        i_data,
        o_addr,
        r_max_load,
        r_min_load,
        r_ncols_load,
        r_nrows_load,
        r_ncells_load,
        r_currpixel_load,
        r_newpixel_load,
        r_counter_load,
        ctrl1,
        ctrl2,
        ctrl3,
        o_endcount,
        o_greaterthanmax,
        o_smallerthanmin
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_endcount, o_greaterthanmax, o_smallerthanmin)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                if o_endcount = '1' then
                    next_state <= S8;
                else
                    next_state <= S3;
                end if;
            when S4 =>
                if o_greaterthanmax = '0' and o_smallerthanmin = '0' then -- CurrentPX minore del Max e maggiore del Min
                    next_state <= S7;
                elsif o_greaterthanmax = '1' and o_smallerthanmin = '0' then -- CurrentPX maggiore del max e maggiore del Min
                    next_state <= S6;
                else -- CurrentPX minore del Min
                    next_state <= S5;
                end if;
            when S5 =>
                if o_greaterthanmax = '1' then
                    next_state <= S6;
                else 
                    next_state <= S7;
                end if;
            when S6 =>
                next_state <= S7;
            when S7 =>
                next_state <= S3;
            when S8 =>
                if o_endcount = '1' then
                    next_state <= S13;
                else
                    next_state <= S9;
                end if;
            when S9 =>
                next_state <= S10;
            when S10 =>
                next_state <= S11;
            when S11 =>
                next_state <= S12;
            when S7 =>
            if o_endcount = '1' then
                next_state <= S13;
            else 
                next_state <= S9;
            end if;
            when S13 =>
                if i_start = '0' then
                    next_state <= S14;
                end if;
            when S14 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
    begin
        r_max_load <= '0';
        r_min_load <= '0';
        r_ncols_load <= '0';
        r_nrows_load <= '0';
        r_ncells_load <= '0';
        r_currpixel_load <= '0';
        r_newpixel_load <= '0';
        r_counter_load <= '0';
        ctrl1 <= '0';
        ctrl2 <= '0';
        ctrl3 <= '0';
        o_address <= "0000000000000000";
        o_addr <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        o_greaterthanmax <= '0';
        o_smallerthanmin <= '0';
        case cur_state is
            when S0 =>
                ctrl1 <= '0';
            when S1 => -- load columns
                o_address <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                r_ncols_load <= '1';
            when S2 =>
                o_address <= "0000000000000001";
                o_en <= '1';
                o_we <= '0';
                r_nrows_load <= '1';
            when S3 =>
                r_ncells_load <= '1';
            when S4 =>
                r_currpixel_load <= '1';
                o_address <= o_addr;
                o_en <= '1';
                o_we <= '0';
            when S5 =>
                r_min_load <= '1';
            when S6 =>
                r_max_load <= '1';
            when S7 =>
                r_counter_load <= '1';
                ctrl2 <= '1';
            when S8 =>
                r_counter_load <= '1';
                ctrl2 <= '0';
            when S9 =>
                r_currpixel_load <= '1';
                ctrl3 <= '0';
                o_address <= o_addr;
                o_en <= '1';
                o_we <= '0';
            when S10 =>
                r_newpixel_load <= '1';
            when S11 =>
                ctrl2 <= '1';
                ctrl3 <= '1';
                r_counter_load <= '1';
                o_address <= o_addr;
                o_en <= '1';
                o_we <= '1';
            when S12 => -- Serve?
            when S13 =>
                o_done <= '1';
            when S14 =>
                o_done <= '0';
                ctrl1 <= '1';
        end case;
    end process;
    
end Behavioral;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r2_sel : in STD_LOGIC;
           r3_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (15 downto 0);
signal sum : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg2 : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg3 : STD_LOGIC_VECTOR(7 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
begin
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    sum <= ("00000000" & o_reg1) + o_reg2;
    
    with r2_sel select
        mux_reg2 <= "0000000000000000" when '0',
                    sum when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= mux_reg2;
            end if;
        end if;
    end process;
    
    with d_sel select
        o_data <= o_reg2(7 downto 0) when '0',
                  o_reg2(15 downto 8) when '1',
                  "XXXXXXXX" when others;
    
    with r3_sel select
        mux_reg3 <= i_data when '0',
                    sub when '1',
                    "XXXXXXXX" when others;
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= mux_reg3;
            end if;
        end if;
    end process;
    
    sub <= o_reg3 - "00000001";
    
    o_end <= '1' when (o_reg3 = "00000000") else '0';

end Behavioral;