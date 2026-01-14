library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity oscilloscope_features is
    Port ( 
        clk           : in  STD_LOGIC;                     
        reset         : in  STD_LOGIC;                     
        
        btn_up        : in  STD_LOGIC;                     
        btn_down      : in  STD_LOGIC;                     
        btn_left      : in  STD_LOGIC;                     
        btn_right     : in  STD_LOGIC;                     
        btn_center    : in  STD_LOGIC;                     
        
        sw            : in  STD_LOGIC_VECTOR(15 downto 0); 
        
        adc_valid_in  : in  STD_LOGIC;                     
        run_mode      : out STD_LOGIC;                     
        
        trigger_level : out STD_LOGIC_VECTOR(11 downto 0); 
        vertical_pos  : out STD_LOGIC_VECTOR(9 downto 0); 
        horizontal_scale : out STD_LOGIC_VECTOR(3 downto 0); 
        volts_per_div : out STD_LOGIC_VECTOR(3 downto 0);  
        time_per_div  : out STD_LOGIC_VECTOR(3 downto 0);  
        
        -- Durum çıkışları
        status        : out STD_LOGIC_VECTOR(3 downto 0);  
        active_control : out STD_LOGIC_VECTOR(2 downto 0);  
        
        -- Auto trigger girişi
        auto_trig_in   : in  STD_LOGIC_VECTOR(11 downto 0) 
    );
end oscilloscope_features;

architecture Behavioral of oscilloscope_features is
    signal btn_up_debounced     : STD_LOGIC := '0';
    signal btn_down_debounced   : STD_LOGIC := '0';
    signal btn_left_debounced   : STD_LOGIC := '0';
    signal btn_right_debounced  : STD_LOGIC := '0';
    signal btn_center_debounced : STD_LOGIC := '0';
    
    signal btn_up_prev     : STD_LOGIC := '0';
    signal btn_down_prev   : STD_LOGIC := '0';
    signal btn_left_prev   : STD_LOGIC := '0';
    signal btn_right_prev  : STD_LOGIC := '0';
    signal btn_center_prev : STD_LOGIC := '0';
    
    signal btn_up_pulse     : STD_LOGIC := '0';
    signal btn_down_pulse   : STD_LOGIC := '0';
    signal btn_left_pulse   : STD_LOGIC := '0';
    signal btn_right_pulse  : STD_LOGIC := '0';
    signal btn_center_pulse : STD_LOGIC := '0';
    
    type debounce_array is array (4 downto 0) of unsigned(19 downto 0);
    signal debounce_counter : debounce_array := (others => (others => '0'));
    
    type mode_type is (MODE_NORMAL, MODE_TRIGGER, MODE_VPOS, MODE_HSCALE, MODE_VOLTS_DIV, MODE_TIME_DIV);
    signal current_mode : mode_type := MODE_NORMAL;
    
    signal trigger_level_reg : unsigned(11 downto 0) := X"800"; 
    signal vertical_pos_reg  : unsigned(9 downto 0) := "0111100000"; 
    signal horiz_scale_reg   : unsigned(3 downto 0) := "0001";
    signal volts_per_div_reg : unsigned(3 downto 0) := "0100"; 
    signal time_per_div_reg  : unsigned(3 downto 0) := "0110"; 
    signal run_mode_reg      : STD_LOGIC := '1'; 
    
    signal status_reg : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    signal active_control_reg : STD_LOGIC_VECTOR(2 downto 0) := "000";
    
    signal auto_trigger_counter : unsigned(19 downto 0) := (others => '0');
    signal auto_mode_active : STD_LOGIC := '0'; 
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                for i in 0 to 4 loop
                    debounce_counter(i) <= (others => '0');
                end loop;
                
                btn_up_debounced <= '0';
                btn_down_debounced <= '0';
                btn_left_debounced <= '0';
                btn_right_debounced <= '0';
                btn_center_debounced <= '0';
            else
                if btn_up = '1' then
                    if debounce_counter(0) < 999999 then 
                        debounce_counter(0) <= debounce_counter(0) + 1;
                    else
                        btn_up_debounced <= '1';
                    end if;
                else
                    debounce_counter(0) <= (others => '0');
                    btn_up_debounced <= '0';
                end if;
                
                if btn_down = '1' then
                    if debounce_counter(1) < 999999 then
                        debounce_counter(1) <= debounce_counter(1) + 1;
                    else
                        btn_down_debounced <= '1';
                    end if;
                else
                    debounce_counter(1) <= (others => '0');
                    btn_down_debounced <= '0';
                end if;
                
                if btn_left = '1' then
                    if debounce_counter(2) < 999999 then
                        debounce_counter(2) <= debounce_counter(2) + 1;
                    else
                        btn_left_debounced <= '1';
                    end if;
                else
                    debounce_counter(2) <= (others => '0');
                    btn_left_debounced <= '0';
                end if;
                
                if btn_right = '1' then
                    if debounce_counter(3) < 999999 then
                        debounce_counter(3) <= debounce_counter(3) + 1;
                    else
                        btn_right_debounced <= '1';
                    end if;
                else
                    debounce_counter(3) <= (others => '0');
                    btn_right_debounced <= '0';
                end if;
                
                if btn_center = '1' then
                    if debounce_counter(4) < 999999 then
                        debounce_counter(4) <= debounce_counter(4) + 1;
                    else
                        btn_center_debounced <= '1';
                    end if;
                else
                    debounce_counter(4) <= (others => '0');
                    btn_center_debounced <= '0';
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            btn_up_prev <= btn_up_debounced;
            btn_down_prev <= btn_down_debounced;
            btn_left_prev <= btn_left_debounced;
            btn_right_prev <= btn_right_debounced;
            btn_center_prev <= btn_center_debounced;
            
            btn_up_pulse <= btn_up_debounced and not btn_up_prev;
            btn_down_pulse <= btn_down_debounced and not btn_down_prev;
            btn_left_pulse <= btn_left_debounced and not btn_left_prev;
            btn_right_pulse <= btn_right_debounced and not btn_right_prev;
            btn_center_pulse <= btn_center_debounced and not btn_center_prev;
        end if;
    end process;
    
    process(clk)
    variable next_trigger_level : unsigned(11 downto 0); 
begin
    if rising_edge(clk) then
        if reset = '1' then
            current_mode <= MODE_NORMAL;
            trigger_level_reg <= X"800"; 
            vertical_pos_reg <= to_unsigned(240, 10); 
            horiz_scale_reg <= "0001"; 
            volts_per_div_reg <= "0100"; 
            time_per_div_reg <= "0110"; 
            run_mode_reg <= '1'; 
            status_reg <= "0000";
            active_control_reg <= "000"; 
            auto_trigger_counter <= (others => '0');
            auto_mode_active <= '0';
        else
            auto_mode_active <= sw(12);
            
            run_mode_reg <= not sw(0); 
            
            next_trigger_level := trigger_level_reg;
            
            if auto_mode_active = '1' then
                if auto_trigger_counter < 1000 then
                    auto_trigger_counter <= auto_trigger_counter + 1;
                else
                    auto_trigger_counter <= (others => '0');
                    next_trigger_level := unsigned(auto_trig_in);
                end if;
            else
                auto_trigger_counter <= (others => '0');
                
                if btn_center_pulse = '1' then
                    case current_mode is
                        when MODE_NORMAL =>
                            current_mode <= MODE_TRIGGER;
                            status_reg <= "0001"; 
                            active_control_reg <= "000"; 
                        when MODE_TRIGGER =>
                            current_mode <= MODE_VPOS;
                            status_reg <= "0010"; 
                            active_control_reg <= "001"; 
                        when MODE_VPOS =>
                            current_mode <= MODE_VOLTS_DIV;
                            status_reg <= "0100";
                            active_control_reg <= "011"; 
                        when MODE_HSCALE =>
                            current_mode <= MODE_VOLTS_DIV;
                            status_reg <= "0100"; 
                            active_control_reg <= "011"; 
                        when MODE_VOLTS_DIV =>
                            current_mode <= MODE_TIME_DIV;
                            status_reg <= "0101";
                            active_control_reg <= "100";
                        when MODE_TIME_DIV =>
                            current_mode <= MODE_NORMAL;
                            status_reg <= "0000";
                            active_control_reg <= "000";
                    end case;
                end if;
                
                case current_mode is
                    when MODE_NORMAL =>
                        
                    when MODE_TRIGGER =>
                        if btn_up_pulse = '1' then
                            if next_trigger_level < 4000 then  
                                next_trigger_level := next_trigger_level + 50; 
                            end if;
                        elsif btn_down_pulse = '1' then
                            if next_trigger_level > 50 then  
                                next_trigger_level := next_trigger_level - 50; 
                            end if;
                        end if;
                        
                    when MODE_VPOS =>
                        if btn_up_pulse = '1' then
                            if vertical_pos_reg > 20 then  
                                vertical_pos_reg <= vertical_pos_reg - 5;
                            end if;
                        elsif btn_down_pulse = '1' then
                            if vertical_pos_reg < 460 then 
                                vertical_pos_reg <= vertical_pos_reg + 5; 
                            end if;
                        end if;
                        
                    when MODE_HSCALE =>
                        
                        
                    when MODE_VOLTS_DIV =>
                        if btn_up_pulse = '1' then
                            if volts_per_div_reg < 7 then  
                                volts_per_div_reg <= volts_per_div_reg + 1;
                            end if;
                        elsif btn_down_pulse = '1' then
                            if volts_per_div_reg > 0 then  
                                volts_per_div_reg <= volts_per_div_reg - 1;
                            end if;
                        end if;
                        
                    when MODE_TIME_DIV =>
                        if btn_right_pulse = '1' then
                            if time_per_div_reg < 15 then 
                                time_per_div_reg <= time_per_div_reg + 1;
                            end if;
                        elsif btn_left_pulse = '1' then
                            if time_per_div_reg > 0 then  
                                time_per_div_reg <= time_per_div_reg - 1;
                            end if;
                        end if;
                end case;
            end if;
            
            trigger_level_reg <= next_trigger_level;
        end if;
    end if;
end process;
    
    trigger_level <= std_logic_vector(trigger_level_reg);
    vertical_pos <= std_logic_vector(vertical_pos_reg);
    horizontal_scale <= std_logic_vector(horiz_scale_reg);
    volts_per_div <= std_logic_vector(volts_per_div_reg);
    time_per_div <= std_logic_vector(time_per_div_reg);
    run_mode <= run_mode_reg;
    status <= status_reg;
    active_control <= active_control_reg;
    
end Behavioral;