library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_decoder is
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
end display_decoder;

architecture Behavioral of display_decoder is
    signal dp_internal : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    signal is_mv       : STD_LOGIC := '0';
    signal is_v        : STD_LOGIC := '0';
    signal is_us       : STD_LOGIC := '0';
    signal is_ms       : STD_LOGIC := '0';
    
    signal display_value : unsigned(11 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                digit3 <= "0000";
                digit2 <= "0000";
                digit1 <= "0000";
                digit0 <= "0000";
                dp_internal <= "0000";
                is_mv <= '0';
                is_v <= '0';
                is_us <= '0';
                is_ms <= '0';
            else
                case active_control is
                    when "000" =>  
                        display_value <= unsigned(trigger_level);
                   
                        if unsigned(trigger_level) < 1000 then
                            is_mv <= '1';
                            is_v <= '0';
                            is_us <= '0';
                            is_ms <= '0';
                        else
                            is_mv <= '0';
                            is_v <= '1';
                            is_us <= '0';
                            is_ms <= '0';
                        end if;
                        
                    when "001" =>  
                        case to_integer(unsigned(volts_per_div)) is
                            when 0 to 3 =>  -- 0.05V, 0.1V, 0.2V, 0.5V
                                is_mv <= '1';
                                is_v <= '0';
                                is_us <= '0';
                                is_ms <= '0';
                                case to_integer(unsigned(volts_per_div)) is
                                    when 0 => display_value <= to_unsigned(50, 12);
                                    when 1 => display_value <= to_unsigned(100, 12);
                                    when 2 => display_value <= to_unsigned(200, 12);
                                    when 3 => display_value <= to_unsigned(500, 12);
                                    when others => display_value <= to_unsigned(0, 12);
                                end case;
                            when 4 to 7 =>  -- 1V, 2V, 5V, 10V
                                is_mv <= '0';
                                is_v <= '1';
                                is_us <= '0';
                                is_ms <= '0';
                                case to_integer(unsigned(volts_per_div)) is
                                    when 4 => display_value <= to_unsigned(1, 12);
                                    when 5 => display_value <= to_unsigned(2, 12);
                                    when 6 => display_value <= to_unsigned(5, 12);
                                    when 7 => display_value <= to_unsigned(10, 12);
                                    when others => display_value <= to_unsigned(0, 12);
                                end case;
                            when others =>
                                display_value <= to_unsigned(0, 12);
                        end case;
                        
                    when "010" =>  
                        case to_integer(unsigned(time_per_div)) is
                            when 0 to 3 =>  -- 1us, 2us, 5us, 10us
                                is_mv <= '0';
                                is_v <= '0';
                                is_us <= '1';
                                is_ms <= '0';
                                case to_integer(unsigned(time_per_div)) is
                                    when 0 => display_value <= to_unsigned(1, 12);
                                    when 1 => display_value <= to_unsigned(2, 12);
                                    when 2 => display_value <= to_unsigned(5, 12);
                                    when 3 => display_value <= to_unsigned(10, 12);
                                    when others => display_value <= to_unsigned(0, 12);
                                end case;
                            when 4 to 7 =>  -- 20us, 50us, 100us, 200us
                                is_mv <= '0';
                                is_v <= '0';
                                is_us <= '1';
                                is_ms <= '0';
                                case to_integer(unsigned(time_per_div)) is
                                    when 4 => display_value <= to_unsigned(20, 12);
                                    when 5 => display_value <= to_unsigned(50, 12);
                                    when 6 => display_value <= to_unsigned(100, 12);
                                    when 7 => display_value <= to_unsigned(200, 12);
                                    when others => display_value <= to_unsigned(0, 12);
                                end case;
                            when 8 to 11 =>  -- 500us, 1ms, 2ms, 5ms
                                if to_integer(unsigned(time_per_div)) = 8 then
                                    is_mv <= '0';
                                    is_v <= '0';
                                    is_us <= '1';
                                    is_ms <= '0';
                                    display_value <= to_unsigned(500, 12);
                                else
                                    is_mv <= '0';
                                    is_v <= '0';
                                    is_us <= '0';
                                    is_ms <= '1';
                                    case to_integer(unsigned(time_per_div)) is
                                        when 9 => display_value <= to_unsigned(1, 12);
                                        when 10 => display_value <= to_unsigned(2, 12);
                                        when 11 => display_value <= to_unsigned(5, 12);
                                        when others => display_value <= to_unsigned(0, 12);
                                    end case;
                                end if;
                            when 12 to 15 =>  -- 10ms, 20ms, 50ms, 100ms
                                is_mv <= '0';
                                is_v <= '0';
                                is_us <= '0';
                                is_ms <= '1';
                                case to_integer(unsigned(time_per_div)) is
                                    when 12 => display_value <= to_unsigned(10, 12);
                                    when 13 => display_value <= to_unsigned(20, 12);
                                    when 14 => display_value <= to_unsigned(50, 12);
                                    when 15 => display_value <= to_unsigned(100, 12);
                                    when others => display_value <= to_unsigned(0, 12);
                                end case;
                            when others =>
                                display_value <= to_unsigned(0, 12);
                        end case;
                        
                    when others =>
                        display_value <= to_unsigned(0, 12);
                        is_mv <= '0';
                        is_v <= '0';
                        is_us <= '0';
                        is_ms <= '0';
                end case;
                
                if display_value < 10 then
                    digit3 <= "0000";
                    digit2 <= "0000"; 
                    digit1 <= "0000"; 
                    digit0 <= std_logic_vector(display_value(3 downto 0));
                elsif display_value < 100 then
                    digit3 <= "0000";  
                    digit2 <= "0000"; 
                    digit1 <= "000" & std_logic_vector(display_value(4 downto 4)); 
                    digit0 <= std_logic_vector(display_value(3 downto 0));  
                elsif display_value < 1000 then
                    digit3 <= "0000";  
                    digit2 <= "00" & std_logic_vector(display_value(6 downto 5));  
                    digit1 <= "000" & std_logic_vector(display_value(4 downto 4));  
                    digit0 <= std_logic_vector(display_value(3 downto 0));  
                else
                    digit3 <= "000" & std_logic_vector(display_value(7 downto 7)); 
                    digit2 <= "00" & std_logic_vector(display_value(6 downto 5));  
                    digit1 <= "000" & std_logic_vector(display_value(4 downto 4));  
                    digit0 <= std_logic_vector(display_value(3 downto 0)); 
                end if;
                
                
                dp_internal <= is_mv & is_v & is_us & is_ms;
            end if;
        end if;
    end process;
    
    dp <= dp_internal;
end Behavioral;