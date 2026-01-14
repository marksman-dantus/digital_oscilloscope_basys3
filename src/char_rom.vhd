library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity char_rom is
    Port (
        clk         : in  STD_LOGIC;                     -- Sistem saati
        char_addr   : in  STD_LOGIC_VECTOR(7 downto 0);  -- ASCII karakter kodu (0-127)
        row         : in  STD_LOGIC_VECTOR(3 downto 0);  -- Karakter içindeki satır (0-15)
        col         : in  STD_LOGIC_VECTOR(2 downto 0);  -- Karakter içindeki sütun (0-7)
        char_pixel  : out STD_LOGIC                      -- Piksel değeri (0: arka plan, 1: ön plan)
    );
end char_rom;

architecture Behavioral of char_rom is
    -- Karakter ROM belleği: 8x16 boyutunda 128 karakter (ASCII)
    -- Her karakter 8x16 piksel matris şeklinde, satır başına 8 bit (1 byte)
    type rom_type is array(0 to 127, 0 to 15) of std_logic_vector(7 downto 0);
    
    -- ROM içeriğini başlatmak için fonksiyon kullanımı
    function init_rom return rom_type is
        variable temp_rom : rom_type;
    begin
        -- Varsayılan olarak tüm karakterleri boş olarak ayarla
        for i in 0 to 127 loop
            for j in 0 to 15 loop
                temp_rom(i, j) := "00000000";
            end loop;
        end loop;
        
        -- ASCII 32: Boşluk (Space)
        -- Zaten varsayılan olarak "00000000" değeri atanmış durumda
        
        -- ASCII 48-57: Rakamlar (0-9)
        -- ASCII 48: 0
        temp_rom(48, 0) := "00111100";
        temp_rom(48, 1) := "01100110";
        temp_rom(48, 2) := "01101110";
        temp_rom(48, 3) := "01110110";
        temp_rom(48, 4) := "01100110";
        temp_rom(48, 5) := "01100110";
        temp_rom(48, 6) := "01100110";
        temp_rom(48, 7) := "01100110";
        temp_rom(48, 8) := "01100110";
        temp_rom(48, 9) := "01100110";
        temp_rom(48, 10) := "01100110";
        temp_rom(48, 11) := "01100110";
        temp_rom(48, 12) := "00111100";
        
        -- ASCII 49: 1
        temp_rom(49, 0) := "00011000";
        temp_rom(49, 1) := "00111000";
        temp_rom(49, 2) := "01111000";
        temp_rom(49, 3) := "00011000";
        temp_rom(49, 4) := "00011000";
        temp_rom(49, 5) := "00011000";
        temp_rom(49, 6) := "00011000";
        temp_rom(49, 7) := "00011000";
        temp_rom(49, 8) := "00011000";
        temp_rom(49, 9) := "00011000";
        temp_rom(49, 10) := "00011000";
        temp_rom(49, 11) := "00011000";
        temp_rom(49, 12) := "01111110";
        
        -- ASCII 50: 2
        temp_rom(50, 0) := "00111100";
        temp_rom(50, 1) := "01100110";
        temp_rom(50, 2) := "01100110";
        temp_rom(50, 3) := "00000110";
        temp_rom(50, 4) := "00001100";
        temp_rom(50, 5) := "00011000";
        temp_rom(50, 6) := "00110000";
        temp_rom(50, 7) := "01100000";
        temp_rom(50, 8) := "01100000";
        temp_rom(50, 9) := "01100000";
        temp_rom(50, 10) := "01100000";
        temp_rom(50, 11) := "01100110";
        temp_rom(50, 12) := "01111110";
        
        -- ASCII 51: 3
        temp_rom(51, 0) := "00111100";
        temp_rom(51, 1) := "01100110";
        temp_rom(51, 2) := "01100110";
        temp_rom(51, 3) := "00000110";
        temp_rom(51, 4) := "00000110";
        temp_rom(51, 5) := "00011100";
        temp_rom(51, 6) := "00000110";
        temp_rom(51, 7) := "00000110";
        temp_rom(51, 8) := "00000110";
        temp_rom(51, 9) := "00000110";
        temp_rom(51, 10) := "00000110";
        temp_rom(51, 11) := "01100110";
        temp_rom(51, 12) := "00111100";
        
        -- ASCII 52: 4
        temp_rom(52, 0) := "00001110";
        temp_rom(52, 1) := "00011110";
        temp_rom(52, 2) := "00110110";
        temp_rom(52, 3) := "01100110";
        temp_rom(52, 4) := "01100110";
        temp_rom(52, 5) := "01100110";
        temp_rom(52, 6) := "01100110";
        temp_rom(52, 7) := "01111110";
        temp_rom(52, 8) := "00000110";
        temp_rom(52, 9) := "00000110";
        temp_rom(52, 10) := "00000110";
        temp_rom(52, 11) := "00000110";
        temp_rom(52, 12) := "00000110";
        
        -- ASCII 53: 5
        temp_rom(53, 0) := "01111110";
        temp_rom(53, 1) := "01100000";
        temp_rom(53, 2) := "01100000";
        temp_rom(53, 3) := "01100000";
        temp_rom(53, 4) := "01100000";
        temp_rom(53, 5) := "01111100";
        temp_rom(53, 6) := "01100110";
        temp_rom(53, 7) := "00000110";
        temp_rom(53, 8) := "00000110";
        temp_rom(53, 9) := "00000110";
        temp_rom(53, 10) := "00000110";
        temp_rom(53, 11) := "01100110";
        temp_rom(53, 12) := "00111100";
        
        -- ASCII 54: 6
        temp_rom(54, 0) := "00111100";
        temp_rom(54, 1) := "01100110";
        temp_rom(54, 2) := "01100110";
        temp_rom(54, 3) := "01100000";
        temp_rom(54, 4) := "01100000";
        temp_rom(54, 5) := "01111100";
        temp_rom(54, 6) := "01100110";
        temp_rom(54, 7) := "01100110";
        temp_rom(54, 8) := "01100110";
        temp_rom(54, 9) := "01100110";
        temp_rom(54, 10) := "01100110";
        temp_rom(54, 11) := "01100110";
        temp_rom(54, 12) := "00111100";
        
        -- ASCII 55: 7
        temp_rom(55, 0) := "01111110";
        temp_rom(55, 1) := "01100110";
        temp_rom(55, 2) := "01100110";
        temp_rom(55, 3) := "00000110";
        temp_rom(55, 4) := "00000110";
        temp_rom(55, 5) := "00001100";
        temp_rom(55, 6) := "00011000";
        temp_rom(55, 7) := "00110000";
        temp_rom(55, 8) := "00110000";
        temp_rom(55, 9) := "00110000";
        temp_rom(55, 10) := "00110000";
        temp_rom(55, 11) := "00110000";
        temp_rom(55, 12) := "00110000";
        
        -- ASCII 56: 8
        temp_rom(56, 0) := "00111100";
        temp_rom(56, 1) := "01100110";
        temp_rom(56, 2) := "01100110";
        temp_rom(56, 3) := "01100110";
        temp_rom(56, 4) := "01100110";
        temp_rom(56, 5) := "00111100";
        temp_rom(56, 6) := "01100110";
        temp_rom(56, 7) := "01100110";
        temp_rom(56, 8) := "01100110";
        temp_rom(56, 9) := "01100110";
        temp_rom(56, 10) := "01100110";
        temp_rom(56, 11) := "01100110";
        temp_rom(56, 12) := "00111100";
        
        -- ASCII 57: 9
        temp_rom(57, 0) := "00111100";
        temp_rom(57, 1) := "01100110";
        temp_rom(57, 2) := "01100110";
        temp_rom(57, 3) := "01100110";
        temp_rom(57, 4) := "01100110";
        temp_rom(57, 5) := "01100110";
        temp_rom(57, 6) := "00111110";
        temp_rom(57, 7) := "00000110";
        temp_rom(57, 8) := "00000110";
        temp_rom(57, 9) := "00000110";
        temp_rom(57, 10) := "00000110";
        temp_rom(57, 11) := "01100110";
        temp_rom(57, 12) := "00111100";
        
        -- ASCII 65-90: Büyük harfler (A-Z) 
        -- ASCII 65: A
        temp_rom(65, 0) := "00111100";
        temp_rom(65, 1) := "01100110";
        temp_rom(65, 2) := "01100110";
        temp_rom(65, 3) := "01100110";
        temp_rom(65, 4) := "01100110";
        temp_rom(65, 5) := "01111110";
        temp_rom(65, 6) := "01100110";
        temp_rom(65, 7) := "01100110";
        temp_rom(65, 8) := "01100110";
        temp_rom(65, 9) := "01100110";
        temp_rom(65, 10) := "01100110";
        temp_rom(65, 11) := "01100110";
        temp_rom(65, 12) := "01100110";
        
        -- ASCII 66: B
        temp_rom(66, 0) := "01111100";
        temp_rom(66, 1) := "01100110";
        temp_rom(66, 2) := "01100110";
        temp_rom(66, 3) := "01100110";
        temp_rom(66, 4) := "01100110";
        temp_rom(66, 5) := "01111100";
        temp_rom(66, 6) := "01100110";
        temp_rom(66, 7) := "01100110";
        temp_rom(66, 8) := "01100110";
        temp_rom(66, 9) := "01100110";
        temp_rom(66, 10) := "01100110";
        temp_rom(66, 11) := "01100110";
        temp_rom(66, 12) := "01111100";
        
        -- ASCII 67: C
        temp_rom(67, 0) := "00111100";
        temp_rom(67, 1) := "01100110";
        temp_rom(67, 2) := "01100110";
        temp_rom(67, 3) := "01100000";
        temp_rom(67, 4) := "01100000";
        temp_rom(67, 5) := "01100000";
        temp_rom(67, 6) := "01100000";
        temp_rom(67, 7) := "01100000";
        temp_rom(67, 8) := "01100000";
        temp_rom(67, 9) := "01100000";
        temp_rom(67, 10) := "01100110";
        temp_rom(67, 11) := "01100110";
        temp_rom(67, 12) := "00111100";
        
        -- ASCII 68: D
        temp_rom(68, 0) := "01111100";
        temp_rom(68, 1) := "01100110";
        temp_rom(68, 2) := "01100110";
        temp_rom(68, 3) := "01100110";
        temp_rom(68, 4) := "01100110";
        temp_rom(68, 5) := "01100110";
        temp_rom(68, 6) := "01100110";
        temp_rom(68, 7) := "01100110";
        temp_rom(68, 8) := "01100110";
        temp_rom(68, 9) := "01100110";
        temp_rom(68, 10) := "01100110";
        temp_rom(68, 11) := "01100110";
        temp_rom(68, 12) := "01111100";
        
        -- ASCII 69: E
        temp_rom(69, 0) := "01111110";
        temp_rom(69, 1) := "01100000";
        temp_rom(69, 2) := "01100000";
        temp_rom(69, 3) := "01100000";
        temp_rom(69, 4) := "01100000";
        temp_rom(69, 5) := "01111100";
        temp_rom(69, 6) := "01100000";
        temp_rom(69, 7) := "01100000";
        temp_rom(69, 8) := "01100000";
        temp_rom(69, 9) := "01100000";
        temp_rom(69, 10) := "01100000";
        temp_rom(69, 11) := "01100000";
        temp_rom(69, 12) := "01111110";
        
        -- ASCII 70: F
        temp_rom(70, 0) := "01111110";
        temp_rom(70, 1) := "01100000";
        temp_rom(70, 2) := "01100000";
        temp_rom(70, 3) := "01100000";
        temp_rom(70, 4) := "01100000";
        temp_rom(70, 5) := "01111100";
        temp_rom(70, 6) := "01100000";
        temp_rom(70, 7) := "01100000";
        temp_rom(70, 8) := "01100000";
        temp_rom(70, 9) := "01100000";
        temp_rom(70, 10) := "01100000";
        temp_rom(70, 11) := "01100000";
        temp_rom(70, 12) := "01100000";
        
        -- ASCII 71: G
        temp_rom(71, 0) := "00111100";
        temp_rom(71, 1) := "01100110";
        temp_rom(71, 2) := "01100110";
        temp_rom(71, 3) := "01100000";
        temp_rom(71, 4) := "01100000";
        temp_rom(71, 5) := "01100000";
        temp_rom(71, 6) := "01101110";
        temp_rom(71, 7) := "01100110";
        temp_rom(71, 8) := "01100110";
        temp_rom(71, 9) := "01100110";
        temp_rom(71, 10) := "01100110";
        temp_rom(71, 11) := "01100110";
        temp_rom(71, 12) := "00111100";
        
        -- ASCII 72: H
        temp_rom(72, 0) := "01100110";
        temp_rom(72, 1) := "01100110";
        temp_rom(72, 2) := "01100110";
        temp_rom(72, 3) := "01100110";
        temp_rom(72, 4) := "01100110";
        temp_rom(72, 5) := "01111110";
        temp_rom(72, 6) := "01100110";
        temp_rom(72, 7) := "01100110";
        temp_rom(72, 8) := "01100110";
        temp_rom(72, 9) := "01100110";
        temp_rom(72, 10) := "01100110";
        temp_rom(72, 11) := "01100110";
        temp_rom(72, 12) := "01100110";
        
        -- ASCII 73: I
        temp_rom(73, 0) := "01111110";
        temp_rom(73, 1) := "00011000";
        temp_rom(73, 2) := "00011000";
        temp_rom(73, 3) := "00011000";
        temp_rom(73, 4) := "00011000";
        temp_rom(73, 5) := "00011000";
        temp_rom(73, 6) := "00011000";
        temp_rom(73, 7) := "00011000";
        temp_rom(73, 8) := "00011000";
        temp_rom(73, 9) := "00011000";
        temp_rom(73, 10) := "00011000";
        temp_rom(73, 11) := "00011000";
        temp_rom(73, 12) := "01111110";
        
        -- ASCII 78: N
        temp_rom(78, 0) := "01100110";
        temp_rom(78, 1) := "01100110";
        temp_rom(78, 2) := "01110110";
        temp_rom(78, 3) := "01110110";
        temp_rom(78, 4) := "01111110";
        temp_rom(78, 5) := "01111110";
        temp_rom(78, 6) := "01101110";
        temp_rom(78, 7) := "01101110";
        temp_rom(78, 8) := "01100110";
        temp_rom(78, 9) := "01100110";
        temp_rom(78, 10) := "01100110";
        temp_rom(78, 11) := "01100110";
        temp_rom(78, 12) := "01100110";
        
        -- ASCII 79: O
        temp_rom(79, 0) := "00111100";
        temp_rom(79, 1) := "01100110";
        temp_rom(79, 2) := "01100110";
        temp_rom(79, 3) := "01100110";
        temp_rom(79, 4) := "01100110";
        temp_rom(79, 5) := "01100110";
        temp_rom(79, 6) := "01100110";
        temp_rom(79, 7) := "01100110";
        temp_rom(79, 8) := "01100110";
        temp_rom(79, 9) := "01100110";
        temp_rom(79, 10) := "01100110";
        temp_rom(79, 11) := "01100110";
        temp_rom(79, 12) := "00111100";
        
        -- ASCII 80: P
        temp_rom(80, 0) := "01111100";
        temp_rom(80, 1) := "01100110";
        temp_rom(80, 2) := "01100110";
        temp_rom(80, 3) := "01100110";
        temp_rom(80, 4) := "01100110";
        temp_rom(80, 5) := "01100110";
        temp_rom(80, 6) := "01111100";
        temp_rom(80, 7) := "01100000";
        temp_rom(80, 8) := "01100000";
        temp_rom(80, 9) := "01100000";
        temp_rom(80, 10) := "01100000";
        temp_rom(80, 11) := "01100000";
        temp_rom(80, 12) := "01100000";
        
        -- ASCII 82: R
        temp_rom(82, 0) := "01111100";
        temp_rom(82, 1) := "01100110";
        temp_rom(82, 2) := "01100110";
        temp_rom(82, 3) := "01100110";
        temp_rom(82, 4) := "01100110";
        temp_rom(82, 5) := "01111100";
        temp_rom(82, 6) := "01111000";
        temp_rom(82, 7) := "01101100";
        temp_rom(82, 8) := "01100110";
        temp_rom(82, 9) := "01100110";
        temp_rom(82, 10) := "01100110";
        temp_rom(82, 11) := "01100110";
        temp_rom(82, 12) := "01100110";
        
        -- ASCII 83: S
        temp_rom(83, 0) := "00111100";
        temp_rom(83, 1) := "01100110";
        temp_rom(83, 2) := "01100110";
        temp_rom(83, 3) := "01100000";
        temp_rom(83, 4) := "01100000";
        temp_rom(83, 5) := "00111100";
        temp_rom(83, 6) := "00000110";
        temp_rom(83, 7) := "00000110";
        temp_rom(83, 8) := "00000110";
        temp_rom(83, 9) := "00000110";
        temp_rom(83, 10) := "01100110";
        temp_rom(83, 11) := "01100110";
        temp_rom(83, 12) := "00111100";
        
        -- ASCII 84: T
        temp_rom(84, 0) := "01111110";
        temp_rom(84, 1) := "00011000";
        temp_rom(84, 2) := "00011000";
        temp_rom(84, 3) := "00011000";
        temp_rom(84, 4) := "00011000";
        temp_rom(84, 5) := "00011000";
        temp_rom(84, 6) := "00011000";
        temp_rom(84, 7) := "00011000";
        temp_rom(84, 8) := "00011000";
        temp_rom(84, 9) := "00011000";
        temp_rom(84, 10) := "00011000";
        temp_rom(84, 11) := "00011000";
        temp_rom(84, 12) := "00011000";
        
        -- ASCII 85: U
        temp_rom(85, 0) := "01100110";
        temp_rom(85, 1) := "01100110";
        temp_rom(85, 2) := "01100110";
        temp_rom(85, 3) := "01100110";
        temp_rom(85, 4) := "01100110";
        temp_rom(85, 5) := "01100110";
        temp_rom(85, 6) := "01100110";
        temp_rom(85, 7) := "01100110";
        temp_rom(85, 8) := "01100110";
        temp_rom(85, 9) := "01100110";
        temp_rom(85, 10) := "01100110";
        temp_rom(85, 11) := "01100110";
        temp_rom(85, 12) := "00111100";
        
        -- ASCII 86: V
        temp_rom(86, 0) := "01100110";
        temp_rom(86, 1) := "01100110";
        temp_rom(86, 2) := "01100110";
        temp_rom(86, 3) := "01100110";
        temp_rom(86, 4) := "01100110";
        temp_rom(86, 5) := "01100110";
        temp_rom(86, 6) := "01100110";
        temp_rom(86, 7) := "01100110";
        temp_rom(86, 8) := "01100110";
        temp_rom(86, 9) := "01100110";
        temp_rom(86, 10) := "00111100";
        temp_rom(86, 11) := "00111100";
        temp_rom(86, 12) := "00011000";
        
        -- ASCII 97-122: Küçük harfler (a-z), gerekli olanlar
        -- ASCII 97: a
        temp_rom(97, 4) := "00111100";
        temp_rom(97, 5) := "00000110";
        temp_rom(97, 6) := "00111110";
        temp_rom(97, 7) := "01100110";
        temp_rom(97, 8) := "01100110";
        temp_rom(97, 9) := "01100110";
        temp_rom(97, 10) := "01100110";
        temp_rom(97, 11) := "00111110";
        
        -- ASCII 100: d
        temp_rom(100, 0) := "00000110";
        temp_rom(100, 1) := "00000110";
        temp_rom(100, 2) := "00000110";
        temp_rom(100, 3) := "00000110";
        temp_rom(100, 4) := "00111110";
        temp_rom(100, 5) := "01100110";
        temp_rom(100, 6) := "01100110";
        temp_rom(100, 7) := "01100110";
        temp_rom(100, 8) := "01100110";
        temp_rom(100, 9) := "01100110";
        temp_rom(100, 10) := "01100110";
        temp_rom(100, 11) := "00111110";
        
        -- ASCII 103: g
        temp_rom(103, 4) := "00111110";
        temp_rom(103, 5) := "01100110";
        temp_rom(103, 6) := "01100110";
        temp_rom(103, 7) := "01100110";
        temp_rom(103, 8) := "01100110";
        temp_rom(103, 9) := "01100110";
        temp_rom(103, 10) := "00111110";
        temp_rom(103, 11) := "00000110";
        temp_rom(103, 12) := "00000110";
        temp_rom(103, 13) := "01100110";
        temp_rom(103, 14) := "00111100";
        
        -- ASCII 105: i
        temp_rom(105, 0) := "00011000";
        temp_rom(105, 1) := "00011000";
        temp_rom(105, 3) := "00111000";
        temp_rom(105, 4) := "00011000";
        temp_rom(105, 5) := "00011000";
        temp_rom(105, 6) := "00011000";
        temp_rom(105, 7) := "00011000";
        temp_rom(105, 8) := "00011000";
        temp_rom(105, 9) := "00011000";
        temp_rom(105, 10) := "00011000";
        temp_rom(105, 11) := "01111110";
        
        -- ASCII 109: m
        temp_rom(109, 4) := "01101100";
        temp_rom(109, 5) := "01111110";
        temp_rom(109, 6) := "01100110";
        temp_rom(109, 7) := "01100110";
        temp_rom(109, 8) := "01100110";
        temp_rom(109, 9) := "01100110";
        temp_rom(109, 10) := "01100110";
        temp_rom(109, 11) := "01100110";
        
        -- ASCII 114: r
        temp_rom(114, 4) := "01111100";
        temp_rom(114, 5) := "01100110";
        temp_rom(114, 6) := "01100110";
        temp_rom(114, 7) := "01100000";
        temp_rom(114, 8) := "01100000";
        temp_rom(114, 9) := "01100000";
        temp_rom(114, 10) := "01100000";
        temp_rom(114, 11) := "01100000";
        
        -- ASCII 115: s
        temp_rom(115, 4) := "00111110";
        temp_rom(115, 5) := "01100000";
        temp_rom(115, 6) := "01100000";
        temp_rom(115, 7) := "00111100";
        temp_rom(115, 8) := "00000110";
        temp_rom(115, 9) := "00000110";
        temp_rom(115, 10) := "01100110";
        temp_rom(115, 11) := "00111100";
        
        -- ASCII 116: t
        temp_rom(116, 0) := "00011000";
        temp_rom(116, 1) := "00011000";
        temp_rom(116, 2) := "00011000";
        temp_rom(116, 3) := "01111110";
        temp_rom(116, 4) := "00011000";
        temp_rom(116, 5) := "00011000";
        temp_rom(116, 6) := "00011000";
        temp_rom(116, 7) := "00011000";
        temp_rom(116, 8) := "00011000";
        temp_rom(116, 9) := "00011000";
        temp_rom(116, 10) := "00011000";
        temp_rom(116, 11) := "00001110";
        
        -- ASCII 117: u
        temp_rom(117, 4) := "01100110";
        temp_rom(117, 5) := "01100110";
        temp_rom(117, 6) := "01100110";
        temp_rom(117, 7) := "01100110";
        temp_rom(117, 8) := "01100110";
        temp_rom(117, 9) := "01100110";
        temp_rom(117, 10) := "01100110";
        temp_rom(117, 11) := "00111110";
        
        -- ASCII 118: v
        temp_rom(118, 4) := "01100110";
        temp_rom(118, 5) := "01100110";
        temp_rom(118, 6) := "01100110";
        temp_rom(118, 7) := "01100110";
        temp_rom(118, 8) := "01100110";
        temp_rom(118, 9) := "01100110";
        temp_rom(118, 10) := "00111100";
        temp_rom(118, 11) := "00011000";
        
        -- ASCII 58: İki Nokta (:)
        temp_rom(58, 3) := "00011000";
        temp_rom(58, 4) := "00011000";
        temp_rom(58, 10) := "00011000";
        temp_rom(58, 11) := "00011000";
        
        -- ASCII 46: Nokta (.)
        temp_rom(46, 11) := "00011000";
        temp_rom(46, 12) := "00011000";
        
        -- ASCII 47: Eğik Çizgi (/)
        temp_rom(47, 0) := "00000110";
        temp_rom(47, 1) := "00000110";
        temp_rom(47, 2) := "00001100";
        temp_rom(47, 3) := "00001100";
        temp_rom(47, 4) := "00011000";
        temp_rom(47, 5) := "00011000";
        temp_rom(47, 6) := "00110000";
        temp_rom(47, 7) := "00110000";
        temp_rom(47, 8) := "01100000";
        temp_rom(47, 9) := "01100000";
        temp_rom(47, 10) := "01000000";
        temp_rom(47, 11) := "01000000";
        
        -- ASCII 63: Soru İşareti (?)
        temp_rom(63, 0) := "00111100";
        temp_rom(63, 1) := "01100110";
        temp_rom(63, 2) := "01100110";
        temp_rom(63, 3) := "00000110";
        temp_rom(63, 4) := "00001100";
        temp_rom(63, 5) := "00011000";
        temp_rom(63, 6) := "00110000";
        temp_rom(63, 7) := "00110000";
        temp_rom(63, 8) := "00110000";
        temp_rom(63, 10) := "00110000";
        temp_rom(63, 11) := "00110000";
        
        return temp_rom;
    end function;
    
    -- ROM belleğini fonksiyon ile başlat
    constant CHAR_ROM : rom_type := init_rom;
    
    signal char_code : integer range 0 to 127;
    signal row_idx   : integer range 0 to 15;
    signal col_idx   : integer range 0 to 7;
    signal rom_data  : std_logic_vector(7 downto 0);
    
begin
    -- ASCII karakter kodunu tamsayıya dönüştür
    char_code <= to_integer(unsigned(char_addr));
    row_idx   <= to_integer(unsigned(row));
    col_idx   <= to_integer(unsigned(col));
    
    process(clk)
    begin
        if rising_edge(clk) then
            -- ROM'dan ilgili karakter ve satırın verisini oku
            rom_data <= CHAR_ROM(char_code, row_idx);
            
            -- İlgili sütunun piksel değerini çıkışa ver
            -- (MSB first - col=0 en soldaki piksel)
            char_pixel <= rom_data(7 - col_idx);
        end if;
    end process;
    
end Behavioral;