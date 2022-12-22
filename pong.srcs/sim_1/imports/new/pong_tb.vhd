----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2022 07:55:49 PM
-- Design Name: 
-- Module Name: pong_tb - Behavioral
-- Project Name: 
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

entity pong_tb is
--  Port ( );
end pong_tb;

architecture Behavioral of pong_tb is

component pong
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
 end component;
 
component adc_if
	PORT (
		SCK : IN STD_LOGIC; -- serial clock that goes to ADC
		SDATA1 : IN STD_LOGIC; -- serial data channel 1
		SDATA2 : IN STD_LOGIC; -- serial data channel 2
		CS : IN STD_LOGIC; -- chip select that initiates A/D conversion
		data_1 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- parallel 12-bit data ch1
		data_2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)); -- parallel 12-bit data ch2
 end component;
 
 COMPONENT bat_n_ball
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
end component;

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

signal clk_in, btn0, btn1, ADC_SDATA22, ADC_SDATA12, ADC_SCLK2, ADC_CS2, ADC_SDATA2, ADC_SDATA1, ADC_SCLK, ADC_CS, VGA_vsync, VGA_hsync : STD_LOGIC;
signal S_vsync, S_red, S_green, S_blue: STD_LOGIC;
signal  SSEG_CA, SSEG_AN : STD_LOGIC_VECTOR (7 downto 0);
signal pixel_row, pixel_col, bat_x, bat_x2 : STD_LOGIC_VECTOR (10 DOWNTO 0);
signal scoreCount1, scoreCount2: STD_LOGIC_VECTOR(3 DOWNTO 0);

begin
 uut: pong
    PORT MAP(   clk_in => clk_in,
                VGA_hsync => VGA_hsync,
                VGA_vsync => VGA_vsync,
                ADC_CS => ADC_CS,
                ADC_SCLK => ADC_SCLK,
                ADC_SDATA1 => ADC_SDATA1,
                ADC_SDATA2 => ADC_SDATA2,
                ADC_CS2 => ADC_CS2,
                ADC_SCLK2 => ADC_SCLK2,
                ADC_SDATA12 => ADC_SDATA12,
                ADC_SDATA22 => ADC_SDATA22,
                SSEG_CA => SSEG_CA,
                SSEG_AN => SSEG_AN,
                btn1 => btn1,
                btn0 => btn0
                );
add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => pixel_row, 
        pixel_col => pixel_col, 
        bat_x => bat_x,
        bat_x2 => bat_x2, 
        serve => btn0, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        scoreCount1 => scoreCount1,
        scoreCount2 => scoreCount2
    );
process
   
    begin
        clk_in <= '0';
        btn0 <= '1';
        btn1 <= '0';
        scoreCount1 <= "0001";
        scoreCount2 <= "0010";
        wait for 100 ns;
        scoreCount1 <= "0000";
        scoreCount2 <= "0110";
        wait for 100 ns;
        scoreCount1 <= "0010";
        scoreCount2 <= "1001";
        wait for 100 ns;
        scoreCount1 <= "0111";
        scoreCount2 <= "0010";
        wait for 100 ns;
        scoreCount1 <= "0001";
        scoreCount2 <= "1000";
        
        assert false report "end of test";
        wait;
    end process;
end Behavioral;
