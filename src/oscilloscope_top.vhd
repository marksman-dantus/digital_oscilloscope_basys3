library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity oscilloscope_top is
    Port ( 
        clk           : in  STD_LOGIC;                    
        reset         : in  STD_LOGIC;                     
        
        btn_up        : in  STD_LOGIC;                     
        btn_down      : in  STD_LOGIC;                    
        btn_left      : in  STD_LOGIC;                    
        btn_right     : in  STD_LOGIC;                     
        btn_center    : in  STD_LOGIC;                     
        sw            : in  STD_LOGIC_VECTOR(15 downto 0); 
  
        vauxp6        : in  STD_LOGIC;                     
        vauxn6        : in  STD_LOGIC;                   
        
        vga_hsync     : out STD_LOGIC;                     
        vga_vsync     : out STD_LOGIC;                     
        vga_red       : out STD_LOGIC_VECTOR(3 downto 0);  
        vga_green     : out STD_LOGIC_VECTOR(3 downto 0);  
        vga_blue      : out STD_LOGIC_VECTOR(3 downto 0);  
        
        led           : out STD_LOGIC_VECTOR(15 downto 0); 
        seg           : out STD_LOGIC_VECTOR(6 downto 0);  
        dp_out        : out STD_LOGIC;                     
        an            : out STD_LOGIC_VECTOR(3 downto 0)   
    );
end oscilloscope_top;

architecture Behavioral of oscilloscope_top is
 
    component xadc_module is
        Port ( 
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            vauxp6      : in  STD_LOGIC;
            vauxn6      : in  STD_LOGIC;
            adc_data    : out STD_LOGIC_VECTOR(11 downto 0);
            adc_valid   : out STD_LOGIC
        );
    end component;
    
    component vga_controller is
        Port (
            clk           : in  STD_LOGIC;
            reset         : in  STD_LOGIC;
            vga_hsync     : out STD_LOGIC;
            vga_vsync     : out STD_LOGIC;
            vga_red       : out STD_LOGIC_VECTOR(3 downto 0);
            vga_green     : out STD_LOGIC_VECTOR(3 downto 0);
            vga_blue      : out STD_LOGIC_VECTOR(3 downto 0);
            pixel_x       : out STD_LOGIC_VECTOR(9 downto 0);
            pixel_y       : out STD_LOGIC_VECTOR(9 downto 0);
            pixel_active  : out STD_LOGIC
        );
    end component;
    
    component block_ram is
        Generic (
            ADDR_WIDTH : integer := 10;
            DATA_WIDTH : integer := 12
        );
        Port (
            clk         : in  STD_LOGIC;
            write_en    : in  STD_LOGIC;
            write_addr  : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            write_data  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            read_addr   : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            read_data   : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component oscilloscope_features is
        Port ( 
            clk            : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            btn_up         : in  STD_LOGIC;
            btn_down       : in  STD_LOGIC;
            btn_left       : in  STD_LOGIC;
            btn_right      : in  STD_LOGIC;
            btn_center     : in  STD_LOGIC;
            sw             : in  STD_LOGIC_VECTOR(15 downto 0);
            adc_valid_in   : in  STD_LOGIC;
            run_mode       : out STD_LOGIC;
            trigger_level  : out STD_LOGIC_VECTOR(11 downto 0);
            vertical_pos   : out STD_LOGIC_VECTOR(9 downto 0);
            horizontal_scale : out STD_LOGIC_VECTOR(3 downto 0);
            volts_per_div  : out STD_LOGIC_VECTOR(3 downto 0);
            time_per_div   : out STD_LOGIC_VECTOR(3 downto 0);
            status         : out STD_LOGIC_VECTOR(3 downto 0);
            active_control : out STD_LOGIC_VECTOR(2 downto 0);
            auto_trig_in   : in  STD_LOGIC_VECTOR(11 downto 0)  
        );
    end component;
    
    component seven_segment_driver is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            digit3       : in  STD_LOGIC_VECTOR(3 downto 0);
            digit2       : in  STD_LOGIC_VECTOR(3 downto 0);
            digit1       : in  STD_LOGIC_VECTOR(3 downto 0);
            digit0       : in  STD_LOGIC_VECTOR(3 downto 0);
            dp           : in  STD_LOGIC_VECTOR(3 downto 0);
            seg          : out STD_LOGIC_VECTOR(6 downto 0);
            dp_out       : out STD_LOGIC;
            an           : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component display_decoder is
        Port ( 
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            active_control  : in  STD_LOGIC_VECTOR(2 downto 0);
            volts_per_div   : in  STD_LOGIC_VECTOR(3 downto 0);
            time_per_div    : in  STD_LOGIC_VECTOR(3 downto 0);
            trigger_level   : in  STD_LOGIC_VECTOR(11 downto 0);
            digit3          : out STD_LOGIC_VECTOR(3 downto 0);
            digit2          : out STD_LOGIC_VECTOR(3 downto 0);
            digit1          : out STD_LOGIC_VECTOR(3 downto 0);
            digit0          : out STD_LOGIC_VECTOR(3 downto 0);
            dp              : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component simple_text_display is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            pixel_x      : in  STD_LOGIC_VECTOR(9 downto 0);
            pixel_y      : in  STD_LOGIC_VECTOR(9 downto 0);
            text_enable  : in  STD_LOGIC;
            volts_per_div : in STD_LOGIC_VECTOR(3 downto 0);
            time_per_div : in STD_LOGIC_VECTOR(3 downto 0);
            trigger_level : in STD_LOGIC_VECTOR(11 downto 0);
            is_running   : in STD_LOGIC;
            draw_text    : out STD_LOGIC;
            text_rgb     : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    signal text_draw : STD_LOGIC;
    signal text_rgb : STD_LOGIC_VECTOR(11 downto 0);
    signal text_enable : STD_LOGIC := '1';

    
    constant RAM_ADDR_WIDTH : integer := 10;
    constant RAM_DATA_WIDTH : integer := 12;
    
    constant GRID_WIDTH_X : integer := 64;
    constant GRID_HEIGHT_Y : integer := 60;
    constant CENTER_X : integer := 320;
    constant CENTER_Y : integer := 240;
    
    constant TEXT_START_X : integer := 10;
    constant TEXT_START_Y : integer := 10;
    constant CHAR_WIDTH   : integer := 8;
    constant CHAR_HEIGHT  : integer := 16;
    
    constant COLOR_BACKGROUND : STD_LOGIC_VECTOR(11 downto 0) := X"111";
    constant COLOR_GRID       : STD_LOGIC_VECTOR(11 downto 0) := X"33F";
    constant COLOR_AXIS       : STD_LOGIC_VECTOR(11 downto 0) := X"77F";
    constant COLOR_WAVEFORM   : STD_LOGIC_VECTOR(11 downto 0) := X"0F0";
    constant COLOR_TRIGGER    : STD_LOGIC_VECTOR(11 downto 0) := X"F00";
    constant COLOR_TEXT       : STD_LOGIC_VECTOR(11 downto 0) := X"FFF";
    constant COLOR_TEXT_ACTIVE: STD_LOGIC_VECTOR(11 downto 0) := X"FF0";
    constant COLOR_UI_BG      : STD_LOGIC_VECTOR(11 downto 0) := X"222";
    
    constant TRIGGER_TIMEOUT : unsigned(23 downto 0) := to_unsigned(1000000, 24); -- 10ms at 100MHz
    constant AUTO_SCALE_INTERVAL : unsigned(23 downto 0) := to_unsigned(10000000, 24); -- 100ms at 100MHz
    constant AUTO_TRIG_INTERVAL : unsigned(23 downto 0) := to_unsigned(5000000, 24); -- 50ms at 100MHz
    
type volts_array is array(0 to 15) of unsigned(12 downto 0);
constant VOLTS_SCALE : volts_array := (
    to_unsigned(4095, 13),  -- 0: 0.05V/div
    to_unsigned(2048, 13),  -- 1: 0.1V/div 
    to_unsigned(1024, 13),  -- 2: 0.2V/div
    to_unsigned(410, 13),   -- 3: 0.5V/div
    to_unsigned(205, 13),   -- 4: 1V/div (standart ölçek)
    to_unsigned(102, 13),   -- 5: 2V/div
    to_unsigned(41, 13),    -- 6: 5V/div
    to_unsigned(20, 13),    -- 7: 10V/div 
    others => to_unsigned(205, 13)  -- Diğerleri standart 1V/div
);

type time_array is array(0 to 15) of unsigned(16 downto 0);
constant TIME_SCALE : time_array := (
    to_unsigned(10, 17),      -- 0: 1us/div 
    to_unsigned(20, 17),      -- 1: 2us/div
    to_unsigned(50, 17),      -- 2: 5us/div
    to_unsigned(100, 17),     -- 3: 10us/div
    to_unsigned(200, 17),     -- 4: 20us/div
    to_unsigned(500, 17),     -- 5: 50us/div
    to_unsigned(1000, 17),    -- 6: 100us/div
    to_unsigned(2000, 17),    -- 7: 200us/div
    to_unsigned(5000, 17),    -- 8: 500us/div
    to_unsigned(10000, 17),   -- 9: 1ms/div
    to_unsigned(20000, 17),   -- 10: 2ms/div
    to_unsigned(50000, 17),   -- 11: 5ms/div
    to_unsigned(100000, 17),  -- 12: 10ms/div
    to_unsigned(20000, 17),   -- 13: 20ms/div
    to_unsigned(50000, 17),   -- 14: 50ms/div
    to_unsigned(100000, 17)   -- 15: 100ms/div 
);

    --------------------------------------------------
    -- ADC ve Örnekleme İlgili Sinyaller
    --------------------------------------------------
    signal adc_data      : STD_LOGIC_VECTOR(11 downto 0);     
    signal adc_valid     : STD_LOGIC := '0';                  
    signal sample_counter : unsigned(19 downto 0) := (others => '0');  
    signal sample_enable  : STD_LOGIC := '0';                
    signal test_wave     : unsigned(11 downto 0) := (others => '0');  
    signal debug_counter : unsigned(23 downto 0) := (others => '0');  

    --------------------------------------------------
    -- VGA Controller Sinyalleri
    --------------------------------------------------
    signal pixel_x       : STD_LOGIC_VECTOR(9 downto 0);     
    signal pixel_y       : STD_LOGIC_VECTOR(9 downto 0);      
    signal pixel_active  : STD_LOGIC;                         
    signal osc_color     : STD_LOGIC_VECTOR(11 downto 0);     

    --------------------------------------------------
    -- RAM Sinyalleri
    --------------------------------------------------
    signal ram_write_en   : STD_LOGIC := '0';                 
    signal ram_write_addr : STD_LOGIC_VECTOR(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ram_write_data : STD_LOGIC_VECTOR(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_read_addr  : STD_LOGIC_VECTOR(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ram_read_data  : STD_LOGIC_VECTOR(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal write_ptr      : unsigned(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal read_ptr_base  : unsigned(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_count     : unsigned(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_written   : STD_LOGIC := '0';                 
    
    --------------------------------------------------
    -- Osiloskop Kontrol Sinyalleri
    --------------------------------------------------
    signal run_mode       : STD_LOGIC;                        
    signal trigger_level  : STD_LOGIC_VECTOR(11 downto 0);    
    signal vertical_pos   : STD_LOGIC_VECTOR(9 downto 0);     
    signal horizontal_scale : STD_LOGIC_VECTOR(3 downto 0);  
    signal volts_per_div  : STD_LOGIC_VECTOR(3 downto 0);     
    signal time_per_div   : STD_LOGIC_VECTOR(3 downto 0);    
    signal status         : STD_LOGIC_VECTOR(3 downto 0);    
    signal active_control : STD_LOGIC_VECTOR(2 downto 0);     
    signal trigger_armed   : STD_LOGIC := '0';               
    signal trigger_fired   : STD_LOGIC := '0';                
    signal force_trigger  : STD_LOGIC := '0';                 
    signal trigger_timeout_counter : unsigned(23 downto 0) := (others => '0');
    signal prev_sample     : STD_LOGIC_VECTOR(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal auto_trigger_level : std_logic_vector(11 downto 0) := (others => '0');
    
    --------------------------------------------------
    -- Dalga Formu Görüntüleme Sinyalleri
    --------------------------------------------------
    signal draw_waveform   : STD_LOGIC := '0';                
    type waveform_buffer_type is array(0 to 639) of unsigned(9 downto 0);
    signal waveform_buffer : waveform_buffer_type := (others => (others => '0'));  
    signal waveform_valid  : STD_LOGIC_VECTOR(639 downto 0) := (others => '0');    
    signal scaled_adc      : unsigned(9 downto 0);            
    signal scaled_trigger  : unsigned(9 downto 0);           
    signal display_offset  : unsigned(9 downto 0) := to_unsigned(240, 10);  
    
    --------------------------------------------------
    -- 7-Segment Display Sinyalleri
    --------------------------------------------------
    signal digit3_val      : STD_LOGIC_VECTOR(3 downto 0);    
    signal digit2_val      : STD_LOGIC_VECTOR(3 downto 0);   
    signal digit1_val      : STD_LOGIC_VECTOR(3 downto 0);    
    signal digit0_val      : STD_LOGIC_VECTOR(3 downto 0);    
    signal decimal_points  : STD_LOGIC_VECTOR(3 downto 0);   
    
    --------------------------------------------------
    -- Ölçekleme Sinyalleri
    --------------------------------------------------
    signal volts_scaling_factor : unsigned(15 downto 0);      
    signal time_scaling_factor  : unsigned(15 downto 0);     
    
    --------------------------------------------------
    -- Auto Scale Sinyalleri
    --------------------------------------------------
    signal peak_min_reset : std_logic := '0';                 
    signal auto_scale_active    : STD_LOGIC := '0';           
    signal auto_volts_div_new   : unsigned(3 downto 0) := "0100"; 

begin

--------------------------------------------------
    -- Component Instantiations
    --------------------------------------------------
    xadc_inst : xadc_module
        port map (
            clk      => clk,
            reset    => reset,
            vauxp6   => vauxp6,
            vauxn6   => vauxn6,
            adc_data => adc_data,
            adc_valid => adc_valid
        );
    
    vga_inst : vga_controller
        port map (
            clk          => clk,
            reset        => reset,
            vga_hsync    => vga_hsync,
            vga_vsync    => vga_vsync,
            vga_red      => vga_red,
            vga_green    => vga_green,
            vga_blue     => vga_blue,
            pixel_x      => pixel_x,
            pixel_y      => pixel_y,
            pixel_active => pixel_active
        );
    
    ram_inst : block_ram
        generic map (
            ADDR_WIDTH => RAM_ADDR_WIDTH,
            DATA_WIDTH => RAM_DATA_WIDTH
        )
        port map (
            clk        => clk,
            write_en   => ram_write_en,
            write_addr => ram_write_addr,
            write_data => ram_write_data,
            read_addr  => ram_read_addr,
            read_data  => ram_read_data
        );
    
    features_inst : oscilloscope_features
        port map (
            clk             => clk,
            reset           => reset,
            btn_up          => btn_up,
            btn_down        => btn_down,
            btn_left        => btn_left,
            btn_right       => btn_right,
            btn_center      => btn_center,
            sw              => sw,
            adc_valid_in    => adc_valid,
            run_mode        => run_mode,
            trigger_level   => trigger_level,
            auto_trig_in    => auto_trigger_level,
            vertical_pos    => vertical_pos,
            horizontal_scale => horizontal_scale,
            volts_per_div   => volts_per_div,
            time_per_div    => time_per_div,
            status          => status,
            active_control  => active_control
        );
    
    display_decoder_inst : display_decoder
        port map (
            clk             => clk,
            reset           => reset,
            active_control  => active_control,
            volts_per_div   => volts_per_div,
            time_per_div    => time_per_div,
            trigger_level   => trigger_level,
            digit3          => digit3_val,
            digit2          => digit2_val,
            digit1          => digit1_val,
            digit0          => digit0_val,
            dp              => decimal_points
        );

    seven_seg_inst : seven_segment_driver
        port map (
            clk          => clk,
            reset        => reset,
            digit3       => digit3_val,
            digit2       => digit2_val,
            digit1       => digit1_val,
            digit0       => digit0_val,
            dp           => decimal_points,
            seg          => seg,
            dp_out       => dp_out,
            an           => an
        );
        
    text_display_inst : simple_text_display
        port map (
            clk           => clk,
            reset         => reset,
            pixel_x       => pixel_x,
            pixel_y       => pixel_y,
            text_enable   => text_enable,
            volts_per_div => volts_per_div,
            time_per_div  => time_per_div,
            trigger_level => trigger_level,
            is_running    => run_mode,
            draw_text     => text_draw,
            text_rgb      => text_rgb
        );
    
    -- Debug LED outputs
    led(15) <= data_written;
    led(14) <= trigger_fired;
    led(13) <= trigger_armed;
    led(12) <= run_mode;
    led(11 downto 8) <= status;
    led(7 downto 4) <= adc_data(11 downto 8);
    led(3 downto 0) <= trigger_level(11 downto 8);
    
    volts_scaling_factor <= resize(VOLTS_SCALE(to_integer(unsigned(volts_per_div))), 16);
    time_scaling_factor <= resize(TIME_SCALE(to_integer(unsigned(time_per_div))), 16);
    
--------------------------------------------------
-- ADC Data Scaling Process
--------------------------------------------------
process(ram_read_data, volts_per_div)
    variable temp : unsigned(24 downto 0);
    variable scale_factor : unsigned(15 downto 0);
    variable screen_height : integer := 300; 
begin
    scale_factor := volts_scaling_factor;
    
    
    temp := resize(unsigned(ram_read_data) * screen_height, 25);
    
    if scale_factor > 0 then  -- Sıfıra bölmeyi önle
        temp := temp / scale_factor;
    else
        temp := (others => '0');
    end if;
    

    if temp > screen_height then
        scaled_adc <= to_unsigned(screen_height, 10);
    else
        scaled_adc <= resize(temp(9 downto 0), 10);
    end if;
end process;

--------------------------------------------------
-- Trigger Level Scaling Process
--------------------------------------------------
process(trigger_level, volts_per_div)
    variable temp : unsigned(24 downto 0);
    variable scale_factor : unsigned(15 downto 0);
    variable screen_height : integer := 300; 
begin
   
    scale_factor := volts_scaling_factor;
    
    temp := resize(unsigned(trigger_level) * screen_height, 25);
    
    if scale_factor > 0 then
        temp := temp / scale_factor;
    else
        temp := (others => '0');
    end if;
    
    if temp > screen_height then
        scaled_trigger <= to_unsigned(screen_height, 10);
    else
        scaled_trigger <= resize(temp(9 downto 0), 10);
    end if;
end process;

--------------------------------------------------
-- Test Wave Generation Process
--------------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            debug_counter <= (others => '0');
            test_wave <= (others => '0');
        else
            debug_counter <= debug_counter + 1;
            if debug_counter = 0 then
                if test_wave >= 4000 then
                    test_wave <= (others => '0');
                else
                    test_wave <= test_wave + 100;
                end if;
            end if;
        end if;
    end if;
end process;

--------------------------------------------------
-- Sampling and Data Storage Process
--------------------------------------------------
process(clk)
    variable actual_data : STD_LOGIC_VECTOR(11 downto 0);
    variable time_div_factor : unsigned(19 downto 0);
begin
    if rising_edge(clk) then
        if reset = '1' then
            sample_counter <= (others => '0');
            sample_enable <= '0';
            write_ptr <= (others => '0');
            read_ptr_base <= (others => '0');
            ram_write_en <= '0';
            trigger_armed <= '1';  
            trigger_fired <= '0';
            prev_sample <= (others => '0');
            data_written <= '0';
            data_count <= (others => '0');
            force_trigger <= '1';  
            trigger_timeout_counter <= TRIGGER_TIMEOUT - 10;  
        else
            sample_enable <= '0';
            ram_write_en <= '0';
            
            time_div_factor := resize(TIME_SCALE(to_integer(unsigned(time_per_div))), 20);
            
            if sample_counter >= time_div_factor then
                sample_counter <= (others => '0');
                sample_enable <= '1';
            else
                sample_counter <= sample_counter + 1;
            end if;
            
            
            if run_mode = '1' and trigger_armed = '1' and trigger_fired = '0' then
                if trigger_timeout_counter >= TRIGGER_TIMEOUT then
                    force_trigger <= '1';
                    trigger_timeout_counter <= (others => '0');
                else
                    trigger_timeout_counter <= trigger_timeout_counter + 1;
                end if;
            else
                trigger_timeout_counter <= (others => '0');
            end if;
            
            if sw(15) = '1' then
                actual_data := std_logic_vector(test_wave);
            else
                actual_data := adc_data;
            end if;
            
            if run_mode = '1' and sample_enable = '1' then
                -- Free-Run modu sw(13) ile kontrol edilir
                if sw(13) = '1' then
                    -- Her zaman tetikleme yapılsın
                    trigger_fired <= '1';
                    data_written <= '1';
                    ram_write_en <= '1';
                    ram_write_addr <= std_logic_vector(write_ptr);
                    ram_write_data <= actual_data;
                    if write_ptr = 2**RAM_ADDR_WIDTH - 1 then
                        write_ptr <= (others => '0');
                    else
                        write_ptr <= write_ptr + 1;
                    end if;
                    if data_count < 2**RAM_ADDR_WIDTH - 1 then
                        data_count <= data_count + 1;
                    end if;
                elsif trigger_armed = '0' and trigger_fired = '0' then
                    trigger_armed <= '1';
                    prev_sample <= actual_data;
                    data_count <= (others => '0');
                elsif trigger_armed = '1' and trigger_fired = '0' then
                    if (unsigned(prev_sample) < unsigned(trigger_level) and 
                        unsigned(actual_data) >= unsigned(trigger_level)) or
                       (unsigned(prev_sample) > unsigned(trigger_level) and 
                        unsigned(actual_data) <= unsigned(trigger_level)) or
                       force_trigger = '1' then
                        trigger_fired <= '1';
                        trigger_armed <= '0';
                        data_written <= '1';
                        force_trigger <= '0';
                        ram_write_en <= '1';
                        ram_write_addr <= std_logic_vector(write_ptr);
                        ram_write_data <= actual_data;
                        
                        if write_ptr = 2**RAM_ADDR_WIDTH - 1 then
                            write_ptr <= (others => '0');
                        else
                            write_ptr <= write_ptr + 1;
                        end if;
                        data_count <= data_count + 1;
                    else
                        prev_sample <= actual_data;
                    end if;
                elsif trigger_fired = '1' then
                    ram_write_en <= '1';
                    ram_write_addr <= std_logic_vector(write_ptr);
                    ram_write_data <= actual_data;
                    if write_ptr = 2**RAM_ADDR_WIDTH - 1 then
                        write_ptr <= (others => '0');
                    else
                        write_ptr <= write_ptr + 1;
                    end if;
                    if data_count < 2**RAM_ADDR_WIDTH - 1 then
                        data_count <= data_count + 1;
                    end if;
                    if data_count >= 2**RAM_ADDR_WIDTH - 1 then
                        trigger_fired <= '0';
                        trigger_armed <= '0';
                        read_ptr_base <= write_ptr;
                    end if;
                end if;
            end if;
            
            if run_mode = '0' then
                trigger_armed <= '0';
                trigger_fired <= '0';
                force_trigger <= '0';
            end if;
        end if;
    end if;
end process;


--------------------------------------------------
-- Waveform Calculation for VGA Display
--------------------------------------------------
process(clk)
    variable x_pos : integer range 0 to 639;
    variable ram_addr : unsigned(RAM_ADDR_WIDTH-1 downto 0);
    variable waveform_y : unsigned(9 downto 0);
begin
    if rising_edge(clk) then
        if reset = '1' then
            for i in 0 to 639 loop
                waveform_buffer(i) <= (others => '0');
                waveform_valid(i) <= '0';
            end loop;
        elsif pixel_y = "0000000000" and pixel_active = '1' then
            x_pos := to_integer(unsigned(pixel_x));
            if x_pos < 640 then
                ram_addr := (read_ptr_base - x_pos) mod 2**RAM_ADDR_WIDTH;
                ram_read_addr <= std_logic_vector(ram_addr);
                if data_written = '1' then
                    waveform_y := display_offset - scaled_adc + unsigned(vertical_pos);
                    if waveform_y > 479 then
                        waveform_y := to_unsigned(479, 10);
                    end if;
                    waveform_buffer(x_pos) <= waveform_y;
                    waveform_valid(x_pos) <= '1';
                else
                    waveform_valid(x_pos) <= '0';
                end if;
            end if;
        end if;
    end if;
end process;

--------------------------------------------------
-- VGA Color Selection and Text Display Process
--------------------------------------------------
process(clk)
    variable x_pos : integer range 0 to 639;
    variable y_pos : integer range 0 to 479;
    variable draw_grid : std_logic := '0';
    variable draw_axis : std_logic := '0';
begin
    if rising_edge(clk) then
        osc_color <= COLOR_BACKGROUND;
        if pixel_active = '1' then
            x_pos := to_integer(unsigned(pixel_x));
            y_pos := to_integer(unsigned(pixel_y));
            
            draw_grid := '0';
            draw_axis := '0';
            if (y_pos mod GRID_HEIGHT_Y) = 0 then 
                draw_grid := '1';
            end if;
            if (x_pos mod GRID_WIDTH_X) = 0 then
                draw_grid := '1';
            end if;
            if y_pos = (CENTER_Y / GRID_HEIGHT_Y) * GRID_HEIGHT_Y then
                draw_axis := '1';
            end if;
            if x_pos = (CENTER_X / GRID_WIDTH_X) * GRID_WIDTH_X then
                draw_axis := '1';
            end if;
            
            if y_pos = to_integer(display_offset - scaled_trigger + unsigned(vertical_pos)) then
                osc_color <= COLOR_TRIGGER;
            elsif draw_axis = '1' then
                osc_color <= COLOR_AXIS;
            elsif draw_grid = '1' then
                osc_color <= COLOR_GRID;
            elsif x_pos < 640 and waveform_valid(x_pos) = '1' then
                if y_pos = to_integer(waveform_buffer(x_pos)) then
                    osc_color <= COLOR_WAVEFORM;
                elsif x_pos > 0 and waveform_valid(x_pos-1) = '1' then
                    if ((y_pos > to_integer(waveform_buffer(x_pos)) and y_pos < to_integer(waveform_buffer(x_pos-1))) or
                        (y_pos < to_integer(waveform_buffer(x_pos)) and y_pos > to_integer(waveform_buffer(x_pos-1)))) then
                        osc_color <= COLOR_WAVEFORM;
                    end if;
                end if;
            end if;
            
            if (x_pos >= 640) or (y_pos < 20) then
                osc_color <= COLOR_UI_BG;
            end if;
            
            if text_draw = '1' then
                osc_color <= text_rgb;
            end if;
        end if;
        
        vga_red <= osc_color(11 downto 8);
        vga_green <= osc_color(7 downto 4);
        vga_blue <= osc_color(3 downto 0);
    end if;
end process;

--------------------------------------------------
-- Auto Scale Process (Düzeltilmiş)
--------------------------------------------------
process(clk)
    variable peak_value : unsigned(11 downto 0);
    variable min_value : unsigned(11 downto 0);
    variable auto_scale_counter : unsigned(23 downto 0);
    variable peak_to_peak : unsigned(11 downto 0);
    variable new_volts_div : unsigned(3 downto 0);
begin
    if rising_edge(clk) then
        if reset = '1' then
            peak_value := (others => '0');
            min_value := (others => '1');
            auto_scale_counter := (others => '0');
            auto_scale_active <= '0';
            auto_volts_div_new <= "0100"; -- 1V/div başlangıç
            new_volts_div := "0100";
        else
            -- Min/max değerleri takip et
            if adc_valid = '1' then
                if unsigned(adc_data) > peak_value then
                    peak_value := unsigned(adc_data);
                end if;
                
                if unsigned(adc_data) < min_value then
                    min_value := unsigned(adc_data);
                end if;
            end if;
            
            if sw(14) = '1' then
                auto_scale_counter := auto_scale_counter + 1;
                auto_scale_active <= '1';
                
                if auto_scale_counter = AUTO_SCALE_INTERVAL then
                    auto_scale_counter := (others => '0');
                    
                    if peak_value > min_value then
                        peak_to_peak := peak_value - min_value;
                        
                        if peak_to_peak < 100 then
                            new_volts_div := "0000"; -- 0.05V/div
                        elsif peak_to_peak < 200 then
                            new_volts_div := "0001"; -- 0.1V/div
                        elsif peak_to_peak < 500 then
                            new_volts_div := "0010"; -- 0.2V/div
                        elsif peak_to_peak < 1000 then
                            new_volts_div := "0011"; -- 0.5V/div
                        elsif peak_to_peak < 2000 then
                            new_volts_div := "0100"; -- 1V/div
                        elsif peak_to_peak < 5000 then
                            new_volts_div := "0101"; -- 2V/div
                        elsif peak_to_peak < 10000 then
                            new_volts_div := "0110"; -- 5V/div
                        else
                            new_volts_div := "0111"; -- 10V/div
                        end if;
                        
                        -- Volts/div değerini güncelle
                        auto_volts_div_new <= new_volts_div;
                    end if;
                    
                    -- Yeni ölçüm için değerleri sıfırla
                    peak_value := (others => '0');
                    min_value := (others => '1');
                end if;
            else
                auto_scale_active <= '0';
            end if;
        end if;
    end if;
end process;

--------------------------------------------------
-- Auto Trigger Process (Düzeltilmiş)
--------------------------------------------------
process(clk)
    variable peak_value : unsigned(11 downto 0) := (others => '0');
    variable min_value : unsigned(11 downto 0) := (others => '1');
    variable auto_trig_counter : unsigned(23 downto 0) := (others => '0');
    variable avg_value : unsigned(11 downto 0);
    variable range_value : unsigned(11 downto 0);
begin
    if rising_edge(clk) then
        if reset = '1' then
            peak_value := (others => '0');
            min_value := (others => '1');
            auto_trig_counter := (others => '0');
            auto_trigger_level <= (others => '0');
        else
            if adc_valid = '1' then
                if unsigned(adc_data) > peak_value then
                    peak_value := unsigned(adc_data);
                end if;
                
                if unsigned(adc_data) < min_value then
                    min_value := unsigned(adc_data);
                end if;
            end if;
            
            auto_trig_counter := auto_trig_counter + 1;
            
            if auto_trig_counter = AUTO_TRIG_INTERVAL then
                auto_trig_counter := (others => '0');
                
                if peak_value > min_value then
                    range_value := peak_value - min_value;
                    avg_value := min_value + (range_value/2);
                    
                    if sw(12) = '1' then
                        auto_trigger_level <=   std_logic_vector(avg_value);
                    end if;
                end if;
                
                peak_value := (others => '0');
                min_value := (others => '1');
            end if;
        end if;
    end if;
end process;

end Behavioral;