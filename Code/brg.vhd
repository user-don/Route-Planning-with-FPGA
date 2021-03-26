----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner and Hambleton Sonnenfeld
-- Create Date:    00:00:01 04/28/2014
-- Module Name:    brg - Behavioral
-- Target Devices:
-- Description: Baud Rate Generator
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity brg is
    Port ( clk         : in  STD_LOGIC;
           br_tick16   : out  STD_LOGIC);
end brg;

architecture Behavioral of brg is
  constant baudrate : integer := 115200; -- baudrate is fixed constant
  constant M        : integer := (100000000)/(16*baudrate); -- updated for 100MHz
  signal count      : integer:= 0;

begin
process(clk) begin
  if rising_edge(clk) then

		if (count >= (M-1)) then
			br_tick16 <= '1';
			count <= 0;
		else
			count <= count + 1;
			br_tick16 <= '0';
		end if;
	end if;

end process;
end Behavioral;