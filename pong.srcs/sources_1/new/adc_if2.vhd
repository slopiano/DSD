LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY adc_if2 IS
	PORT (
		SCK2 : IN STD_LOGIC; -- serial clock that goes to ADC
		SDATA12 : IN STD_LOGIC; -- serial data channel 1
		SDATA22 : IN STD_LOGIC; -- serial data channel 2
		CS2 : IN STD_LOGIC; -- chip select that initiates A/D conversion
		data_12 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- parallel 12-bit data ch1
		data_22 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)); -- parallel 12-bit data ch2
END adc_if2;

ARCHITECTURE Behavioral OF adc_if2 IS
	SIGNAL pdata12, pdata22 : std_logic_vector (11 DOWNTO 0); -- 12-bit shift registers
BEGIN
	-- this process waits for CS=0 and then clocks serial data from ADC into shift register
	-- MSBit first. After 16 SCK's, four leading zeros will have fallen out of the most significant
	-- end of the shift register and the register will contain the parallel 12-bit data
	adpr : PROCESS
	BEGIN
		WAIT UNTIL falling_edge (SCK2);
		IF CS2 = '0' THEN
			pdata12 <= pdata12 (10 DOWNTO 0) & SDATA12;
			pdata22 <= pdata22 (10 DOWNTO 0) & SDATA22;
		END IF;
	END PROCESS;
	-- this process waits for rising edge of CS and then loads parallel data
	-- from shift register into appropriate output port
	sync : PROCESS
	BEGIN
		WAIT UNTIL rising_edge (CS2);
		data_12 <= pdata12;
		data_22 <= pdata22;
	END PROCESS;
END Behavioral;