----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
--
-- Create Date:    22:22:53 05/26/2014
-- Module Name:    vga_clk_driver - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description: Clock divider for VGA Controller; clocked at 25Mhz
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity vga_clk_driver is
    Port ( clk : in  STD_LOGIC;
           clk25 : out  STD_LOGIC);
end vga_clk_driver;

architecture Behavioral of vga_clk_driver is

	constant vga_count : integer := 4;
	signal count : integer := 0;

begin
process(clk) begin
	if rising_edge(clk) then

		if count = 0 then
			clk25 <= '1';
			count <= vga_count - 1;
		else
			count <= count - 1;
			clk25 <= '0';
		end if;

	end if;
end process;


end Behavioral;

