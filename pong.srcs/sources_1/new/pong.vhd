LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        ADC_CS : OUT STD_LOGIC; -- ADC signals
        ADC_SCLK : OUT STD_LOGIC;
        ADC_SDATA1 : IN STD_LOGIC;
        ADC_SDATA2 : IN STD_LOGIC;
        ADC_CS2 : OUT STD_LOGIC; -- ADC signals 2
        ADC_SCLK2 : OUT STD_LOGIC;
        ADC_SDATA12 : IN STD_LOGIC;
        ADC_SDATA22 : IN STD_LOGIC;
        SSEG_CA : OUT STD_LOGIC_VECTOR (7 downto 0); --Signals for 7 segment display
        SSEG_AN : OUT STD_LOGIC_VECTOR (7 downto 0);
        btn1 : IN STD_LOGIC;
        btn0 : IN STD_LOGIC); -- button to initiate serve
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL batpos2 : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL serial_clk, sample_clk : STD_LOGIC;
    SIGNAL adout : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL adout2 : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL an_number : natural range 0 to 7 := 0; 
    SIGNAL count : STD_LOGIC_VECTOR (9 DOWNTO 0); -- counter to generate ADC clocks
    SIGNAL tmrVal : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- Records number on 7 seg display
    SIGNAL tmrVal2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- Records number on 7 seg display
    SIGNAL segCounter : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- Records number on 7 seg display
    SIGNAL clk_counter : natural range 0 to 50000000 := 0;

    COMPONENT adc_if IS
        PORT (
            SCK : IN STD_LOGIC;
            SDATA1 : IN STD_LOGIC;
            SDATA2 : IN STD_LOGIC;
            CS : IN STD_LOGIC;
            data_1 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            data_2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            bat_x2 : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            serve : IN STD_LOGIC;
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            scoreCount1 : OUT STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
            scoreCount2 : OUT STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;

BEGIN
    -- Process to generate clock signals
    ckp : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk_in);
        count <= count + 1; -- counter to generate ADC timing signals
        clk_counter <= clk_counter + 1;
        if clk_counter >= 100000 then 
            clk_counter <= 0;
            an_number <= an_number+1;
            if an_number > 6 then 
                an_number <= 0;
            end if;
        end if;
    END PROCESS;
    process(an_number)
    begin
        case an_number is
        when 0 => SSEG_AN <= "11111110";
        when 1 => SSEG_AN <= "11111111";
        when 2 => SSEG_AN <= "11111111";
        when 3 => SSEG_AN <= "11111111";
        when 4 => SSEG_AN <= "11101111";
        when 5 => SSEG_AN <= "11111111";
        when 6 => SSEG_AN <= "11111111";
        when 7 => SSEG_AN <= "11111111";
        end case;
    end process;
    process(an_number)
    begin
        case an_number is
        when 0 => segCounter <= tmrVal;
        when 1 => segCounter <= tmrVal;
        when 2 => segCounter <= tmrVal;
        when 3 => segCounter <= tmrVal;
        when 4 => segCounter <= tmrVal2;
        when 5 => segCounter <= tmrVal2;
        when 6 => segCounter <= tmrVal2;
        when 7 => segCounter <= tmrVal2;
        end case;
    end process;
    process(segCounter)
    begin
        case segCounter is
            when "0000" => SSEG_CA <= "11000000";
            when "0001" => SSEG_CA <= "11111001";
            when "0010" => SSEG_CA <= "10100100";
            when "0011" => SSEG_CA <= "10110000";
            when "0100" => SSEG_CA <= "10011001";
            when "0101" => SSEG_CA <= "10010010";
            when "0110" => SSEG_CA <= "10000010";
            when "0111" => SSEG_CA <= "11111000";
            when "1000" => SSEG_CA <= "10000000";
            when "1001" => SSEG_CA <= "10010000";
            when others => SSEG_CA <= "11111111";
         end case;
    end process;
    serial_clk <= NOT count(4); -- 1.5 MHz serial clock for ADC
    ADC_SCLK <= serial_clk;
    ADC_SCLK2 <= serial_clk;
    sample_clk <= count(9); -- sampling clock is low for 16 SCLKs
    ADC_CS <= sample_clk;
    ADC_CS2 <= sample_clk;
    -- Multiplies ADC output (0-4095) by 5/32 to give bat position (0-640)
    --batpos <= ('0' & adout(11 DOWNTO 3)) + adout(11 DOWNTO 5);
    batpos <= ("00" & adout(11 DOWNTO 3)) + adout(11 DOWNTO 4);
    batpos2 <= ("00" & adout2(11 DOWNTO 3)) + adout2(11 DOWNTO 4);
    -- 512 + 256 = 768
--    SSEG_AN(0) <= '0';
--    SSEG_AN(1) <= '1';
--    SSEG_AN(2) <= '1';
--    SSEG_AN(3) <= '1';
--    SSEG_AN(4) <= '1';
--    SSEG_AN(5) <= '1';
--    SSEG_AN(6) <= '1';
--    SSEG_AN(7) <= '1';
--    with tmrVal select
--        SSEG_CA <= "11000000" when "0000",
--                      "11111001" when "0001",
--                      "10100100" when "0010",
--                      "10110000" when "0011",
--                      "10011001" when "0100",
--                      "10010010" when "0101",
--                      "10000010" when "0110",
--                      "11111000" when "0111",
--                      "10000000" when "1000",
--                      "10010000" when "1001",
--                      "11111111" when others;
--                when "0000" => SSEG_CA <= "11000000";
--                when "0001" => SSEG_CA <= "11111001";
--                when "0010" => SSEG_CA <= "10100100";
--                when "0011" => SSEG_CA <= "10110000";
--                when "0100" => SSEG_CA <= "10011001";
--                when "0101" => SSEG_CA <= "10010010";
--                when "0110" => SSEG_CA <= "10000010";
--                when "0111" => SSEG_CA <= "11111000";
--                when "1000" => SSEG_CA <= "10000000";
--                when "1001" => SSEG_CA <= "10010000";
--                when others => SSEG_CA <= "11111111";
    adc : adc_if
    PORT MAP(-- instantiate ADC serial to parallel interface
        SCK => serial_clk, 
        CS => sample_clk, 
        SDATA1 => ADC_SDATA1, 
        SDATA2 => ADC_SDATA2, 
        data_1 => OPEN, 
        data_2 => adout 
    );
    adc2 : adc_if
    PORT MAP(-- instantiate ADC serial to parallel interface
        SCK => serial_clk,
        CS => sample_clk,
        SDATA1 => ADC_SDATA12,
        SDATA2 => ADC_SDATA22,
        data_1 => OPEN,
        data_2 => adout2
    );
    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        bat_x => batpos,
        bat_x2 => batpos2, 
        serve => btn0, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        scoreCount1 => tmrVal,
        scoreCount2 => tmrVal2
    );
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
END Behavioral;