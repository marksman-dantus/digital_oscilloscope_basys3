library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port (
        clk         : in  STD_LOGIC;       
        reset       : in  STD_LOGIC;
        
        vga_hsync   : out STD_LOGIC;      
        vga_vsync   : out STD_LOGIC;       
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);  
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);  
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);  
        
        pixel_x     : out STD_LOGIC_VECTOR(9 downto 0);  
        pixel_y     : out STD_LOGIC_VECTOR(9 downto 0);  
        pixel_active: out STD_LOGIC        
    );
end vga_controller;

architecture Behavioral of vga_controller is
    signal clk_count : unsigned(1 downto 0) := (others => '0');
    signal pixel_clk : STD_LOGIC := '0';
    
    constant H_DISPLAY : integer := 640;   
    constant H_FRONT_PORCH : integer := 16;  
    constant H_SYNC_PULSE : integer := 96;   
    constant H_BACK_PORCH : integer := 48;   
    constant H_TOTAL : integer := H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; 
    
    constant V_DISPLAY : integer := 480;     
    constant V_FRONT_PORCH : integer := 10;  
    constant V_SYNC_PULSE : integer := 2;    
    constant V_BACK_PORCH : integer := 33;   
    constant V_TOTAL : integer := V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; 
    
    signal h_count : unsigned(9 downto 0) := (others => '0');
    signal v_count : unsigned(9 downto 0) := (others => '0');
    
    signal h_sync, v_sync : STD_LOGIC := '0';
    signal video_active : STD_LOGIC := '0';
    
    signal pixel_x_reg : unsigned(9 downto 0) := (others => '0');
    signal pixel_y_reg : unsigned(9 downto 0) := (others => '0');
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_count <= (others => '0');
                pixel_clk <= '0';
            else
                if clk_count = 3 then
                    clk_count <= (others => '0');
                    pixel_clk <= '1';
                else
                    clk_count <= clk_count + 1;
                    pixel_clk <= '0';
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                h_count <= (others => '0');
                v_count <= (others => '0');
            elsif pixel_clk = '1' then
                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');
                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
            end if;
        end if;
    end process;
    
    h_sync <= '0' when (h_count >= H_DISPLAY + H_FRONT_PORCH) and 
                       (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE) else '1';
    
    v_sync <= '0' when (v_count >= V_DISPLAY + V_FRONT_PORCH) and
                       (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE) else '1';
    
    video_active <= '1' when (h_count < H_DISPLAY) and (v_count < V_DISPLAY) else '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            if pixel_clk = '1' then
                if h_count < H_DISPLAY then
                    pixel_x_reg <= h_count;
                end if;
                
                if v_count < V_DISPLAY then
                    pixel_y_reg <= v_count;
                end if;
            end if;
        end if;
    end process;
    
    vga_hsync <= h_sync;
    vga_vsync <= v_sync;
    pixel_active <= video_active;
    pixel_x <= std_logic_vector(pixel_x_reg);
    pixel_y <= std_logic_vector(pixel_y_reg);
    
end Behavioral;