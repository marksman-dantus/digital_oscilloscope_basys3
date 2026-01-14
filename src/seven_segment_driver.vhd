library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_driver is
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
end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    signal counter      : unsigned(16 downto 0) := (others => '0');
    signal digit_select : STD_LOGIC_VECTOR(1 downto 0);
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);
    signal current_dp   : STD_LOGIC;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    digit_select <= STD_LOGIC_VECTOR(counter(16 downto 15));
    
    process(digit_select, digit0, digit1, digit2, digit3, dp)
    begin
        case digit_select is
            when "00" =>
                current_digit <= digit0;
                current_dp <= dp(0);
                an <= "1110";
            when "01" =>
                current_digit <= digit1;
                current_dp <= dp(1);
                an <= "1101";
            when "10" =>
                current_digit <= digit2;
                current_dp <= dp(2);
                an <= "1011";
            when others =>
                current_digit <= digit3;
                current_dp <= dp(3);
                an <= "0111";
        end case;
    end process;
    
    process(current_digit)
    begin
        case current_digit is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when "1111" => seg <= "0001110"; -- F
            when others => seg <= "1111111"; -- All off
        end case;
    end process;
    
    dp_out <= not current_dp;
    
end Behavioral;