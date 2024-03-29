----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Simone Gabrielli
-- 
-- Create Date: 01.03.2021 16:14:15
-- Design Name: 
-- Module Name: project_reti_logiche
-- Project Name: project_reti_logiche
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

component equalizer is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;
           i_data : in std_logic_vector(7 downto 0);
           r_max_load : in STD_LOGIC;
           r_min_load : in STD_LOGIC;
           r_currpixel_load : in STD_LOGIC;
           r_newpixel_load : in STD_LOGIC;
           o_greaterthanmax : out STD_LOGIC;
           o_smallerthanmin : out STD_LOGIC;
           o_newpixel : out std_logic_vector(7 downto 0));
end component;

component address_calculator is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;
           i_data : in std_logic_vector(7 downto 0);
           r_ncols_load : in STD_LOGIC;
           r_nrows_load : in STD_LOGIC;
           r_ncells_load : in STD_LOGIC;
           r_counter_load : in STD_LOGIC;
           ctrl1 : in STD_LOGIC;
           ctrl2 : in STD_LOGIC;
           o_endcount : out STD_LOGIC;
           o_addr : out std_logic_vector(15 downto 0));
end component;

signal reset_datapath : STD_LOGIC;
signal dummy_reset : STD_LOGIC;
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
signal endcount : STD_LOGIC;
signal greaterthanmax : STD_LOGIC;
signal smallerthanmin : STD_LOGIC;
signal datapath_addr : STD_LOGIC_VECTOR(15 downto 0);
signal o_newpixel : STD_LOGIC_VECTOR(7 downto 0);

type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18);
signal cur_state, next_state : S;

begin
    equalizer0 : equalizer port map(
        i_clk => i_clk,
        i_rst => reset_datapath,
        i_data => i_data,
        r_max_load => r_max_load,
        r_min_load => r_min_load,
        r_currpixel_load => r_currpixel_load,
        r_newpixel_load => r_newpixel_load,
        o_greaterthanmax => greaterthanmax,
        o_smallerthanmin => smallerthanmin,
        o_newpixel => o_newpixel
    );
    
    address_calculator0 : address_calculator port map(
        i_clk => i_clk,
        i_rst => reset_datapath,
        i_data => i_data,
        r_ncols_load => r_ncols_load,
        r_nrows_load => r_nrows_load,
        r_ncells_load => r_ncells_load,
        r_counter_load => r_counter_load,
        ctrl1 => ctrl1,
        ctrl2 => ctrl2,
        o_endcount => endcount,
        o_addr => datapath_addr
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, endcount, greaterthanmax, smallerthanmin)
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
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                if endcount = '1' then
                    next_state <= S10;
                else
                    next_state <= S6;
                end if;
            when S6 =>
                next_state <= S7;
            when S7 =>
                if greaterthanmax = '0' and smallerthanmin = '0' then -- CurrentPX minore del Max e maggiore del Min
                    next_state <= S5;
                elsif greaterthanmax = '1' and smallerthanmin = '0' then -- CurrentPX maggiore del max e maggiore del Min
                    next_state <= S9;
                else -- CurrentPX minore del Min
                    next_state <= S8;
                end if;
            when S8 =>
                if greaterthanmax = '1' then
                    next_state <= S9;
                else 
                    next_state <= S5;
                end if;
            when S9 =>
                next_state <= S5;
            when S10 =>
                next_state <= S11;
            when S11 =>
                if endcount = '1' then
                    next_state <= S17;
                else
                    next_state <= S12;
                end if;
            when S12 =>
                next_state <= S13;
            when S13 =>
                next_state <= S14;
            when S14 =>
                next_state <= S15;
            when S15 =>
                next_state <= S16;
            when S16 =>
            if endcount = '1' then
                next_state <= S17;
            else 
                next_state <= S12;
            end if;
            when S17 =>
                if i_start = '0' then
                    next_state <= S18;
                else
                    next_state <= S17;
                end if;
            when S18 =>
                next_state <= S0;
            when others =>
        end case;
    end process;
    
    process(cur_state, datapath_addr, o_newpixel)
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
        o_address <= (others => '0');
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        o_data <= (others => '0');
        dummy_reset <= '0';
        case cur_state is
            when S0 => -- waiting for start
            when S1 => -- read columns
                o_address <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
            when S2 => -- load columns and read rows
                r_ncols_load <= '1';
                o_address <= "0000000000000001";
                o_en <= '1';
                o_we <= '0';
            when S3 => -- load rows
                r_nrows_load <= '1';
            when S4 => -- calculate total num of cells
                r_ncells_load <= '1';
            when S5 => -- read current pixel (to find max and min)
                ctrl2 <= '0';
                o_address <= datapath_addr;
                o_en <= '1';
                o_we <= '0';
            when S6 =>-- load current pixel and counter++
                r_currpixel_load <= '1';
                r_counter_load <= '1';
                ctrl1 <= '1';
            when S7 => -- check if current pixel is smaller than min or greater than max
            when S8 => -- current pixel < min
                r_min_load <= '1';
            when S9 => -- current pixel > min
                r_max_load <= '1';
            when S10 =>  -- reset counter
                r_counter_load <= '1';
                ctrl1 <= '0';
            when S11 => -- check if all the pixels have been equalized
            when S12 => -- read current pixel (to equalize)
                ctrl2 <= '0';
                o_address <= datapath_addr;
                o_en <= '1';
                o_we <= '0';
            when S13 => -- load current pixel
                r_currpixel_load <= '1';
            when S14 => -- load equalized pixel on register_newpixel
                r_newpixel_load <= '1';
                ctrl2 <= '1';
            when S15 => -- write equalized pixel
                ctrl1 <= '1';
                ctrl2 <= '1';
                r_counter_load <= '1';
                o_address <= datapath_addr;
                o_data <= o_newpixel;
                o_en <= '1';
                o_we <= '1';
            when S16 => -- waiting for counter update
            when S17 => -- waiting for new start signal
                o_done <= '1';
            when S18 => -- new start signal recived: reset and wait for next image 
                ctrl1 <= '1';
                dummy_reset <= '1';
            when others =>
        end case;
    end process;
    
    reset_datapath <= i_rst OR dummy_reset;
    
end Behavioral;


-- equalizer


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity equalizer is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;
           i_data : in std_logic_vector(7 downto 0);
           r_max_load : in STD_LOGIC;
           r_min_load : in STD_LOGIC;
           r_currpixel_load : in STD_LOGIC;
           r_newpixel_load : in STD_LOGIC;
           o_greaterthanmax : out STD_LOGIC;
           o_smallerthanmin : out STD_LOGIC;
           o_newpixel : out std_logic_vector(7 downto 0));
end equalizer;



architecture Behavioral of equalizer is
signal o_r_max : STD_LOGIC_VECTOR (7 downto 0);
signal o_r_min : STD_LOGIC_VECTOR (7 downto 0);
signal o_r_currpixel : STD_LOGIC_VECTOR (7 downto 0);
signal o_r_newpixel : STD_LOGIC_VECTOR (7 downto 0);
signal shift_level : UNSIGNED(2 downto 0);
signal delta_value : STD_LOGIC_VECTOR(7 downto 0);
signal diff : STD_LOGIC_VECTOR(7 downto 0);
signal temp_pixel : STD_LOGIC_VECTOR(15 downto 0);
signal new_pixel_value : STD_LOGIC_VECTOR(7 downto 0);
signal log2 : STD_LOGIC_VECTOR(2 downto 0);

begin    
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_max <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_max_load = '1') then
                 o_r_max <= o_r_currpixel;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_min <= (others => '1');
        elsif rising_edge(i_clk) then
            if(r_min_load = '1') then
                 o_r_min <= o_r_currpixel;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_currpixel <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_currpixel_load = '1') then
                 o_r_currpixel <= i_data;
            end if;
        end if;
    end process;
    
    delta_value <= std_logic_vector(unsigned(o_r_max) - unsigned(o_r_min) + 1); 
    
    process(delta_value)
    begin
        if unsigned(delta_value) < 2 then
            log2 <= "000";
        elsif unsigned(delta_value) < 4 then
            log2 <= "001";
        elsif unsigned(delta_value) < 8 then
            log2 <= "010";
        elsif unsigned(delta_value) < 16 then
            log2 <= "011";
        elsif unsigned(delta_value) < 32 then
            log2 <= "100";
        elsif unsigned(delta_value) < 64 then
            log2 <= "101";
        elsif unsigned(delta_value) < 128 then
            log2 <= "110";
        else
            log2 <= "111";
        end if;
    end process;

    shift_level <= 8 - unsigned(log2); 
    diff <= std_logic_vector(unsigned(o_r_currpixel) - unsigned(o_r_min));
    
    temp_pixel <= std_logic_vector(shift_left(unsigned("00000000" & diff), TO_INTEGER(unsigned(shift_level)))); --provvisorio  

    process(temp_pixel)
        begin
            if unsigned(temp_pixel) < 255 then
                new_pixel_value <= std_logic_vector(temp_pixel(7 downto 0));
            else
                new_pixel_value <= (others => '1');
            end if;
    end process;
    
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_newpixel <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_newpixel_load = '1') then
                o_r_newpixel <= new_pixel_value;
            end if;
        end if;
    end process;

    o_newpixel <= o_r_newpixel;
    
    process(o_r_currpixel, o_r_min)
        begin
            if unsigned(o_r_currpixel) < unsigned(o_r_min) then
                o_smallerthanmin <= '1';
            else
                o_smallerthanmin <= '0';
            end if;
    end process;
    
    process(o_r_currpixel, o_r_max)
        begin
            if unsigned(o_r_currpixel) > unsigned(o_r_max) then
                o_greaterthanmax <= '1';
            else
                o_greaterthanmax <= '0';
            end if;
    end process;

end Behavioral;



-- address_calculator


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity address_calculator is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;
           i_data : in std_logic_vector(7 downto 0);
           r_ncols_load : in STD_LOGIC;
           r_nrows_load : in STD_LOGIC;
           r_ncells_load : in STD_LOGIC;
           r_counter_load : in STD_LOGIC;
           ctrl1 : in STD_LOGIC;
           ctrl2 : in STD_LOGIC;
           o_endcount : out STD_LOGIC;
           o_addr : out std_logic_vector(15 downto 0));
end address_calculator;


architecture Behavioral of address_calculator is
signal o_r_ncols : STD_LOGIC_VECTOR (7 downto 0);
signal o_r_nrows : STD_LOGIC_VECTOR (7 downto 0);
signal o_r_ncells : STD_LOGIC_VECTOR (15 downto 0);
signal o_r_counter : STD_LOGIC_VECTOR (15 downto 0);
signal rowsxcols : STD_LOGIC_VECTOR (15 downto 0);
signal newcounter : STD_LOGIC_VECTOR (15 downto 0);
signal mux2 : STD_LOGIC_VECTOR(15 downto 0);
signal address_read : STD_LOGIC_VECTOR(15 downto 0);
signal address_write : STD_LOGIC_VECTOR(15 downto 0);

begin    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_ncols <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_ncols_load = '1') then
                 o_r_ncols <= i_data;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_nrows <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_nrows_load = '1') then
                 o_r_nrows <= i_data;
            end if;
        end if;
    end process;
    
    rowsxcols <= std_logic_vector(unsigned(o_r_ncols) * unsigned(o_r_nrows));
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_ncells <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_ncells_load = '1') then
                 o_r_ncells <= rowsxcols;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r_counter <= (others => '0');
        elsif rising_edge(i_clk) then
            if(r_counter_load = '1') then
                 o_r_counter <= mux2;
            end if;
        end if;
    end process;
    
    newcounter <= std_logic_vector(unsigned(o_r_counter) + 1); 
    
    with ctrl1 select
        mux2 <= (others => '0') when '0',
                 newcounter when '1',
                "XXXXXXXXXXXXXXXX" when others;
           
    with ctrl2 select
        o_addr <= address_read when '0',
                  address_write when '1',
                 "XXXXXXXXXXXXXXXX" when others;       
                      
    address_read <= std_logic_vector((unsigned(o_r_counter)) + 2); --verifica num bit
    address_write <= std_logic_vector(((unsigned(o_r_ncells)) + unsigned(address_read))); --verifica num bit
    
    o_endcount <= '1' when (unsigned(o_r_counter) >= unsigned(o_r_ncells)) else '0'; 
    
end Behavioral;