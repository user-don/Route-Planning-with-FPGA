----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
--
-- Create Date:    02:45:29 05/26/2014
-- Module Name:    clk_enable_driver - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description: Clock divider for the unit cell's decrementing process; output is 50Hz
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity clk_enable_driver is
    Port ( clk    : in  STD_LOGIC;
           clk_en : out  STD_LOGIC);
end clk_enable_driver;

architecture Behavioral of clk_enable_driver is

	constant slow_rate : integer := 2000000;
	signal count : integer := 0;

begin
process(clk) begin
	if rising_edge(clk) then

		if count = slow_rate then
			clk_en <= '1';
			count <= 0;
		else
			count <= count + 1;
			clk_en <= '0';
		end if;
	end if;
end process;

end Behavioral;
