library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity text_generator is
    Port (
        clk              : in  STD_LOGIC;                     -- 100 MHz sistem saati
        pixel_x          : in  STD_LOGIC_VECTOR(9 downto 0);
        pixel_y          : in  STD_LOGIC_VECTOR(9 downto 0);
        trigger_level    : in  STD_LOGIC_VECTOR(11 downto 0);
        horizontal_scale : in  STD_LOGIC_VECTOR(3 downto 0);
        status           : in  STD_LOGIC_VECTOR(3 downto 0);
        run_mode         : in  STD_LOGIC;
        text_color       : out STD_LOGIC_VECTOR(11 downto 0) -- RGB renk
    );
end text_generator;

architecture Behavioral of text_generator is
    constant NUM_CHARS : integer := 16; -- Toplam 16 karakter tanımlı
    constant CHAR_ROWS : integer := 8;  -- Her karakter 8 satır
    constant ROM_SIZE  : integer := NUM_CHARS * CHAR_ROWS; -- 128 eleman

    type char_rom_type is array (0 to ROM_SIZE-1) of STD_LOGIC_VECTOR(7 downto 0);
    constant char_rom : char_rom_type := (
        -- '0' (0-7)
        X"3C", X"42", X"42", X"42", X"42", X"42", X"3C", X"00",
        -- '1' (8-15)
        X"18", X"38", X"18", X"18", X"18", X"18", X"7E", X"00",
        -- 'V' (16-23)
        X"42", X"42", X"42", X"42", X"24", X"24", X"18", X"00",
        -- '/' (24-31)
        X"02", X"04", X"08", X"10", X"20", X"40", X"80", X"00",
        -- 'd' (32-39)
        X"38", X"44", X"44", X"44", X"44", X"44", X"38", X"00",
        -- 'i' (40-47)
        X"00", X"10", X"10", X"10", X"10", X"10", X"10", X"00",
        -- 'v' (48-55)
        X"42", X"42", X"24", X"24", X"24", X"18", X"18", X"00",
        -- ':' (56-63)
        X"00", X"10", X"10", X"00", X"10", X"10", X"00", X"00",
        -- '.' (64-71)
        X"00", X"00", X"00", X"00", X"00", X"10", X"10", X"00",
        -- 'T' (72-79)
        X"7C", X"10", X"10", X"10", X"10", X"10", X"10", X"00",
        -- 'm' (80-87)
        X"00", X"00", X"66", X"5A", X"42", X"42", X"42", X"00",
        -- 's' (88-95)
        X"00", X"00", X"3C", X"40", X"3C", X"04", X"78", X"00",
        -- 'M' (96-103)
        X"42", X"66", X"5A", X"42", X"42", X"42", X"42", X"00",
        -- 'o' (104-111)
        X"00", X"00", X"3C", X"42", X"42", X"42", X"3C", X"00",
        -- 'N' (112-119)
        X"42", X"46", X"4A", X"52", X"62", X"42", X"42", X"00",
        -- 'r' (120-127)
        X"00", X"00", X"38", X"44", X"40", X"40", X"40", X"00"
    );

    type char_to_index is array (0 to 255) of integer range 0 to NUM_CHARS-1;
    constant character_map : char_to_index := (
        character'pos('0') => 0,
        character'pos('1') => 1,
        character'pos('V') => 2,
        character'pos('/') => 3,
        character'pos('d') => 4,
        character'pos('i') => 5,
        character'pos('v') => 6,
        character'pos(':') => 7,
        character'pos('.') => 8,
        character'pos('T') => 9,
        character'pos('m') => 10,
        character'pos('s') => 11,
        character'pos('M') => 12,
        character'pos('o') => 13,
        character'pos('N') => 14,
        character'pos('r') => 15,
        others              => 0
    );

    -- String uzunluklarını literal uzunluklarına uyacak şekilde 11 olarak güncelledik
    constant volt_div_str : string(1 to 11) := "V/div: 1.0V";
    constant time_div_str : string(1 to 11) := "T/div: 1ms ";
    constant mode_str     : string(1 to 11) := "Mode: Norm ";

begin
    process(clk)
        variable x_pos     : integer;
        variable y_pos     : integer;
        variable char_idx  : integer range 0 to NUM_CHARS-1;
        variable rom_idx   : integer range 0 to ROM_SIZE-1;
        variable char_row  : STD_LOGIC_VECTOR(7 downto 0);
        variable char_x    : integer;
        variable char_y    : integer;
        variable char_pos  : integer;
    begin
        if rising_edge(clk) then
            x_pos := to_integer(unsigned(pixel_x));
            y_pos := to_integer(unsigned(pixel_y));
            text_color <= X"000";
            -- Volt/div (sol üst)
            if y_pos >= 10 and y_pos < 18 and x_pos >= 10 and x_pos < 90 then
                char_x := (x_pos - 10) / 8;
                char_y := (y_pos - 10);
                if char_x < volt_div_str'length then
                    char_pos := character'pos(volt_div_str(char_x + 1));
                    char_idx := character_map(char_pos);
                    rom_idx  := char_idx * CHAR_ROWS + char_y;
                    if rom_idx < ROM_SIZE then
                        char_row := char_rom(rom_idx);
                        if char_row(7 - ((x_pos - 10) mod 8)) = '1' then
                            text_color <= X"FFF";
                        end if;
                    end if;
                end if;
            end if;
            -- Time/div (sağ üst)
            if y_pos >= 10 and y_pos < 18 and x_pos >= 550 and x_pos < 630 then
                char_x := (x_pos - 550) / 8;
                char_y := (y_pos - 10);
                if char_x < time_div_str'length then
                    char_pos := character'pos(time_div_str(char_x + 1));
                    char_idx := character_map(char_pos);
                    rom_idx  := char_idx * CHAR_ROWS + char_y;
                    if rom_idx < ROM_SIZE then
                        char_row := char_rom(rom_idx);
                        if char_row(7 - ((x_pos - 550) mod 8)) = '1' then
                            text_color <= X"FFF";
                        end if;
                    end if;
                end if;
            end if;
            -- Mode (sol alt)
            if y_pos >= 460 and y_pos < 468 and x_pos >= 10 and x_pos < 90 then
                char_x := (x_pos - 10) / 8;
                char_y := (y_pos - 460);
                if char_x < mode_str'length then
                    char_pos := character'pos(mode_str(char_x + 1));
                    char_idx := character_map(char_pos);
                    rom_idx  := char_idx * CHAR_ROWS + char_y;
                    if rom_idx < ROM_SIZE then
                        char_row := char_rom(rom_idx);
                        if char_row(7 - ((x_pos - 10) mod 8)) = '1' then
                            text_color <= X"FFF";
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
