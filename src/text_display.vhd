library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity text_display is
    Port ( 
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        
        -- Pozisyon bilgisi
        pixel_x      : in  STD_LOGIC_VECTOR(9 downto 0);   -- Piksel X pozisyonu
        pixel_y      : in  STD_LOGIC_VECTOR(9 downto 0);   -- Piksel Y pozisyonu
        
        -- Parametreler
        trigger_level : in  STD_LOGIC_VECTOR(11 downto 0);  -- Tetikleme seviyesi
        vertical_scale : in  STD_LOGIC_VECTOR(3 downto 0);  -- Dikey ölçek
        time_scale   : in  STD_LOGIC_VECTOR(3 downto 0);   -- Zaman ölçeği
        running_mode : in  STD_LOGIC;                      -- Çalışma modu
        status       : in  STD_LOGIC_VECTOR(3 downto 0);   -- Durum bilgisi
        
        -- Çıkışlar
        text_on      : out STD_LOGIC;                      -- Text aktif
        text_rgb     : out STD_LOGIC_VECTOR(11 downto 0)   -- Text rengi
    );
end text_display;

architecture Behavioral of text_display is
    -- Karakter ROM bileşeni
    component character_rom is
        Port ( 
            clk        : in  STD_LOGIC;
            char_code  : in  STD_LOGIC_VECTOR(7 downto 0);
            char_x     : in  STD_LOGIC_VECTOR(2 downto 0);
            char_y     : in  STD_LOGIC_VECTOR(3 downto 0);
            char_pixel : out STD_LOGIC
        );
    end component;
    
    -- Karakter boyutları (8x16 piksel)
    constant CHAR_WIDTH : integer := 8;
    constant CHAR_HEIGHT : integer := 16;
    
    -- Metin alanları boyutları
    constant FIELD_WIDTH : integer := 10; -- Her metin alanı maks 10 karakter
    
    -- Metin alanları konumları (sol üst köşeden piksel)
    constant TRIG_TEXT_X : integer := 10;
    constant TRIG_TEXT_Y : integer := 10;
    
    constant VSCALE_TEXT_X : integer := 10;
    constant VSCALE_TEXT_Y : integer := 30;
    
    constant HSCALE_TEXT_X : integer := 10;
    constant HSCALE_TEXT_Y : integer := 50;
    
    constant STATUS_TEXT_X : integer := 400;
    constant STATUS_TEXT_Y : integer := 10;
    
    -- Metin dizilerinde ASCII kodları
    type text_array is array (0 to FIELD_WIDTH-1) of std_logic_vector(7 downto 0);
    
    -- Sabit metin etiketleri
    constant TRIG_LABEL : text_array := (
        X"54", X"52", X"49", X"47", X"3A", X"20", X"20", X"20", X"20", X"20" -- "TRIG:     "
    );
    
    constant VSCALE_LABEL : text_array := (
        X"56", X"2F", X"64", X"69", X"76", X"3A", X"20", X"20", X"20", X"20" -- "V/div:    "
    );
    
    constant HSCALE_LABEL : text_array := (
        X"54", X"2F", X"64", X"69", X"76", X"3A", X"20", X"20", X"20", X"20" -- "T/div:    "
    );
    
    constant MODE_LABELS : text_array := (
        X"4D", X"4F", X"44", X"45", X"3A", X"20", X"20", X"20", X"20", X"20" -- "MODE:     "
    );
    
    -- Değişken metinler için sayısal değerler
    signal trig_value_str : text_array;
    signal vscale_value_str : text_array;
    signal hscale_value_str : text_array;
    signal status_str : text_array;
    
    -- Metin pozisyon ve kontrol sinyalleri
    signal pix_x, pix_y : unsigned(9 downto 0);
    signal char_addr_x, char_addr_y : unsigned(9 downto 0);
    signal char_code : std_logic_vector(7 downto 0);
    signal char_x : std_logic_vector(2 downto 0);
    signal char_y : std_logic_vector(3 downto 0);
    signal char_pixel : std_logic;
    
    -- Metin görüntüleme alanları için kontrol sinyalleri
    signal on_trig_text, on_vscale_text, on_hscale_text, on_status_text : std_logic;
    signal rom_addr : unsigned(6 downto 0);
    
    -- Yardımcı fonksiyonlar
    -- Integer'dan Tetikleme seviyesi ASCII karakter dizisine dönüşüm
    function int_to_trig_ascii(value: unsigned(11 downto 0)) return text_array is
        variable result : text_array := (others => X"20"); -- Boşluk ile başlat
        variable int_val : integer;
        variable tmp : integer;
        variable digit : integer;
        variable voltage_mv : integer; -- milivolt cinsinden
    begin
        -- 12-bit ADC değerini milivolta dönüştür (0-4095 -> 0-3300mV)
        voltage_mv := to_integer((value * 3300) / 4096);
        
        -- Eğer 1V'dan büyükse, V.vv formatında göster
        if voltage_mv >= 1000 then
            -- Volt kısmı
            int_val := voltage_mv / 1000;
            
            -- Birinci digit (volt)
            result(6) := std_logic_vector(to_unsigned(48 + int_val, 8));
            
            -- Ondalık nokta
            result(7) := X"2E"; -- "."
            
            -- Ondalık kısım (ilk iki digit)
            tmp := (voltage_mv mod 1000) / 10; -- 10'lar basamağı için 10'a böl
            
            -- Ondalık ilk digit
            digit := tmp / 10;
            result(8) := std_logic_vector(to_unsigned(48 + digit, 8));
            
            -- Ondalık ikinci digit
            digit := tmp mod 10;
            result(9) := std_logic_vector(to_unsigned(48 + digit, 8));
            
            -- Birim
            result(5) := X"56"; -- "V"
        else
            -- mV cinsinden göster
            int_val := voltage_mv;
            
            -- 100'ler basamağı
            digit := int_val / 100;
            result(5) := std_logic_vector(to_unsigned(48 + digit, 8));
            
            -- 10'lar basamağı
            int_val := int_val mod 100;
            digit := int_val / 10;
            result(6) := std_logic_vector(to_unsigned(48 + digit, 8));
            
            -- 1'ler basamağı
            digit := int_val mod 10;
            result(7) := std_logic_vector(to_unsigned(48 + digit, 8));
            
            -- Birim
            result(8) := X"6D"; -- "m"
            result(9) := X"56"; -- "V"
        end if;
        
        return result;
    end function;
    
    -- Integer'dan Dikey Skala ASCII karakter dizisine dönüşüm
    function int_to_vscale_ascii(value: unsigned(3 downto 0)) return text_array is
        variable result : text_array := (others => X"20"); -- Boşluk ile başlat
        variable scale_value : integer;
    begin
        -- Ölçek değerini belirle (örnek: 1x, 2x, 5x, 10x...)
        -- Burada basit bir hesaplama yapılıyor, gerçek uygulamada daha karmaşık olabilir
        scale_value := to_integer(value);
        
        case scale_value is
            when 1 =>
                result(6) := X"35"; -- "5"
                result(7) := X"30"; -- "0"
                result(8) := X"6D"; -- "m"
                result(9) := X"56"; -- "V"
            when 2 =>
                result(6) := X"31"; -- "1"
                result(7) := X"30"; -- "0"
                result(8) := X"6D"; -- "m"
                result(9) := X"56"; -- "V"
            when 3 =>
                result(6) := X"32"; -- "2"
                result(7) := X"30"; -- "0"
                result(8) := X"6D"; -- "m"
                result(9) := X"56"; -- "V"
            when 4 =>
                result(6) := X"35"; -- "5"
                result(7) := X"30"; -- "0"
                result(8) := X"6D"; -- "m"
                result(9) := X"56"; -- "V"
            when 5 =>
                result(6) := X"31"; -- "1"
                result(7) := X"56"; -- "V"
                result(8) := X"20"; -- " "
                result(9) := X"20"; -- " "
            when 6 =>
                result(6) := X"32"; -- "2"
                result(7) := X"56"; -- "V"
                result(8) := X"20"; -- " "
                result(9) := X"20"; -- " "
            when 7 =>
                result(6) := X"35"; -- "5"
                result(7) := X"56"; -- "V"
                result(8) := X"20"; -- " "
                result(9) := X"20"; -- " "
            when others =>
                result(6) := X"31"; -- "1"
                result(7) := X"30"; -- "0"
                result(8) := X"56"; -- "V"
                result(9) := X"20"; -- " "
        end case;
        
        return result;
    end function;
    
    -- Integer'dan Yatay Skala ASCII karakter dizisine dönüşüm
    function int_to_hscale_ascii(value: unsigned(3 downto 0)) return text_array is
        variable result : text_array := (others => X"20"); -- Boşluk ile başlat
        variable scale_value : integer;
    begin
        -- Ölçek değerini belirle
        scale_value := to_integer(value);
        
        case scale_value is
            when 1 =>
                result(6) := X"31"; -- "1"
                result(7) := X"75"; -- "u"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
            when 2 =>
                result(6) := X"32"; -- "2"
                result(7) := X"75"; -- "u"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
            when 3 =>
                result(6) := X"35"; -- "5"
                result(7) := X"75"; -- "u"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
            when 4 =>
                result(6) := X"31"; -- "1"
                result(7) := X"30"; -- "0"
                result(8) := X"75"; -- "u"
                result(9) := X"73"; -- "s"
            when 5 =>
                result(6) := X"32"; -- "2"
                result(7) := X"30"; -- "0"
                result(8) := X"75"; -- "u"
                result(9) := X"73"; -- "s"
            when 6 =>
                result(6) := X"35"; -- "5"
                result(7) := X"30"; -- "0"
                result(8) := X"75"; -- "u"
                result(9) := X"73"; -- "s"
            when 7 =>
                result(6) := X"31"; -- "1"
                result(7) := X"6D"; -- "m"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
            when 8 =>
                result(6) := X"32"; -- "2"
                result(7) := X"6D"; -- "m"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
            when others =>
                result(6) := X"35"; -- "5"
                result(7) := X"6D"; -- "m"
                result(8) := X"73"; -- "s"
                result(9) := X"20"; -- " "
        end case;
        
        return result;
    end function;
    
    -- Mod durumunu ASCII karakter dizisine dönüşüm
    function status_to_ascii(status_val: std_logic_vector(3 downto 0), run: std_logic) return text_array is
        variable result : text_array := (others => X"20"); -- Boşluk ile başlat
    begin
        -- İlk olarak çalışma modunu belirle
        if run = '0' then
            -- Durdurulmuş
            result(0) := X"53"; -- "S"
            result(1) := X"54"; -- "T"
            result(2) := X"4F"; -- "O"
            result(3) := X"50"; -- "P"
            result(4) := X"20"; -- " "
        else
            -- Çalışıyor
            result(0) := X"52"; -- "R"
            result(1) := X"55"; -- "U"
            result(2) := X"4E"; -- "N"
            result(3) := X"20"; -- " "
            result(4) := X"20"; -- " "
        end if;
        
        -- Sonra modu belirle
        case status_val is
            when "0000" =>
                result(5) := X"4E"; -- "N"
                result(6) := X"4F"; -- "O"
                result(7) := X"52"; -- "R"
                result(8) := X"4D"; -- "M"
                result(9) := X"4C"; -- "L"
            when "0001" =>
                result(5) := X"54"; -- "T"
                result(6) := X"52"; -- "R"
                result(7) := X"49"; -- "I"
                result(8) := X"47"; -- "G"
                result(9) := X"20"; -- " "
            when "0010" =>
                result(5) := X"56"; -- "V"
                result(6) := X"50"; -- "P"
                result(7) := X"4F"; -- "O"
                result(8) := X"53"; -- "S"
                result(9) := X"20"; -- " "
            when "0011" =>
                result(5) := X"48"; -- "H"
                result(6) := X"53"; -- "S"
                result(7) := X"43"; -- "C"
                result(8) := X"4C"; -- "L"
                result(9) := X"20"; -- " "
            when others =>
                result(5) := X"3F"; -- "?"
                result(6) := X"3F"; -- "?"
                result(7) := X"3F"; -- "?"
                result(8) := X"3F"; -- "?"
                result(9) := X"3F"; -- "?"
        end case;
        
        return result;
    end function;
    
begin
    -- Piksel koordinatlarını unsigned'a dönüştür
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    -- Character ROM bağlantısı
    char_rom_inst: character_rom
    port map (
        clk        => clk,
        char_code  => char_code,
        char_x     => char_x,
        char_y     => char_y,
        char_pixel => char_pixel
    );
    
    -- Her frame'de metin değerlerini güncelle
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                trig_value_str <= (others => X"20");  -- Boşluk
                vscale_value_str <= (others => X"20"); -- Boşluk
                hscale_value_str <= (others => X"20"); -- Boşluk
                status_str <= (others => X"20");      -- Boşluk
            else
                -- Sadece y=0 olduğunda hesapla (frame başlangıcı)
                if pix_y = 0 and pix_x = 0 then
                    trig_value_str <= int_to_trig_ascii(unsigned(trigger_level));
                    vscale_value_str <= int_to_vscale_ascii(unsigned(vertical_scale));
                    hscale_value_str <= int_to_hscale_ascii(unsigned(time_scale));
                    status_str <= status_to_ascii(status, running_mode);
                end if;
            end if;
        end if;
    end process;
    
    -- Metin görüntüleme alanı kontrolü
    on_trig_text <= '1' when (pix_x >= TRIG_TEXT_X) and (pix_x < TRIG_TEXT_X + FIELD_WIDTH*CHAR_WIDTH) and
                             (pix_y >= TRIG_TEXT_Y) and (pix_y < TRIG_TEXT_Y + CHAR_HEIGHT) else '0';
                             
    on_vscale_text <= '1' when (pix_x >= VSCALE_TEXT_X) and (pix_x < VSCALE_TEXT_X + FIELD_WIDTH*CHAR_WIDTH) and
                              (pix_y >= VSCALE_TEXT_Y) and (pix_y < VSCALE_TEXT_Y + CHAR_HEIGHT) else '0';
                              
    on_hscale_text <= '1' when (pix_x >= HSCALE_TEXT_X) and (pix_x < HSCALE_TEXT_X + FIELD_WIDTH*CHAR_WIDTH) and
                              (pix_y >= HSCALE_TEXT_Y) and (pix_y < HSCALE_TEXT_Y + CHAR_HEIGHT) else '0';
                              
    on_status_text <= '1' when (pix_x >= STATUS_TEXT_X) and (pix_x < STATUS_TEXT_X + FIELD_WIDTH*CHAR_WIDTH) and
                             (pix_y >= STATUS_TEXT_Y) and (pix_y < STATUS_TEXT_Y + CHAR_HEIGHT) else '0';
    
    -- Karakter koordinatları hesaplama
    process(pix_x, pix_y, on_trig_text, on_vscale_text, on_hscale_text, on_status_text,
            TRIG_TEXT_X, TRIG_TEXT_Y, VSCALE_TEXT_X, VSCALE_TEXT_Y, 
            HSCALE_TEXT_X, HSCALE_TEXT_Y, STATUS_TEXT_X, STATUS_TEXT_Y)
    begin
        -- Varsayılan değerler
        char_addr_x <= (others => '0');
        char_addr_y <= (others => '0');
        
        if on_trig_text = '1' then
            char_addr_x <= (pix_x - TRIG_TEXT_X) / CHAR_WIDTH;
            char_addr_y <= (pix_y - TRIG_TEXT_Y);
        elsif on_vscale_text = '1' then
            char_addr_x <= (pix_x - VSCALE_TEXT_X) / CHAR_WIDTH;
            char_addr_y <= (pix_y - VSCALE_TEXT_Y);
        elsif on_hscale_text = '1' then
            char_addr_x <= (pix_x - HSCALE_TEXT_X) / CHAR_WIDTH;
            char_addr_y <= (pix_y - HSCALE_TEXT_Y);
        elsif on_status_text = '1' then
            char_addr_x <= (pix_x - STATUS_TEXT_X) / CHAR_WIDTH;
            char_addr_y <= (pix_y - STATUS_TEXT_Y);
        end if;
    end process;
    
    -- Karakter kodu ve karakter içi koordinat seçimi
    process(char_addr_x, char_addr_y, pix_x, pix_y, on_trig_text, on_vscale_text, on_hscale_text, on_status_text,
            TRIG_LABEL, VSCALE_LABEL, HSCALE_LABEL, MODE_LABELS,
            trig_value_str, vscale_value_str, hscale_value_str, status_str,
            TRIG_TEXT_X, TRIG_TEXT_Y, VSCALE_TEXT_X, VSCALE_TEXT_Y, 
            HSCALE_TEXT_X, HSCALE_TEXT_Y, STATUS_TEXT_X, STATUS_TEXT_Y)
    begin
        -- Karakter içi koordinatlar
        if on_trig_text = '1' or on_vscale_text = '1' or on_hscale_text = '1' or on_status_text = '1' then
            char_x <= std_logic_vector(pix_x(2 downto 0));
            char_y <= std_logic_vector(pix_y(3 downto 0));
        else
            char_x <= (others => '0');
            char_y <= (others => '0');
        end if;
        
        -- Karakter kodu seçimi
        if on_trig_text = '1' then
            if char_addr_x < FIELD_WIDTH then
                if char_addr_x <= 5 then
                    char_code <= TRIG_LABEL(to_integer(char_addr_x));
                else
                    char_code <= trig_value_str(to_integer(char_addr_x));
                end if;
            else
                char_code <= X"20"; -- Boşluk
            end if;
        elsif on_vscale_text = '1' then
            if char_addr_x < FIELD_WIDTH then
                if char_addr_x <= 5 then
                    char_code <= VSCALE_LABEL(to_integer(char_addr_x));
                else
                    char_code <= vscale_value_str(to_integer(char_addr_x));
                end if;
            else
                char_code <= X"20"; -- Boşluk
            end if;
        elsif on_hscale_text = '1' then
            if char_addr_x < FIELD_WIDTH then
                if char_addr_x <= 5 then
                    char_code <= HSCALE_LABEL(to_integer(char_addr_x));
                else
                    char_code <= hscale_value_str(to_integer(char_addr_x));
                end if;
            else
                char_code <= X"20"; -- Boşluk
            end if;
        elsif on_status_text = '1' then
            if char_addr_x < FIELD_WIDTH then
                char_code <= status_str(to_integer(char_addr_x));
            else
                char_code <= X"20"; -- Boşluk
            end if;
        else
            char_code <= X"20"; -- Boşluk
        end if;
    end process;
    
    -- Text görüntüleme kontrolü
    text_on <= '1' when (on_trig_text = '1' or on_vscale_text = '1' or on_hscale_text = '1' or on_status_text = '1') and char_pixel = '1' else '0';
    
    -- Metin rengi
    text_rgb <= X"FFF"; -- Beyaz metin (12-bit RGB)
    
end Behavioral;