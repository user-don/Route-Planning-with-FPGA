----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
-- Create Date:    17:13:48 05/21/2014
-- Module Name:    unit_cell - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LX16-CS324
-- Description: Unit Cell
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity unit_cell is
	Port ( clk                  : in  STD_LOGIC;
			 north_trigger     : in  STD_LOGIC;
		   clk_en            : in  STD_LOGIC;
		   east_trigger      : in  STD_LOGIC;
		   south_trigger     : in  STD_LOGIC;
		   west_trigger      : in  STD_LOGIC;
		   TNC_value         : in  STD_LOGIC_VECTOR (7 downto 0);
		   program           : in  STD_LOGIC;
		   stop_input        : in  STD_LOGIC;
		   start_input       : in  STD_LOGIC;
		   triggered_by      : out  STD_LOGIC_VECTOR (1 downto 0);
		   read_TNC          : out  STD_LOGIC_VECTOR (7 downto 0);
		   activate_adjacent : out  STD_LOGIC := '0');
end unit_cell;

architecture Behavioral of unit_cell is

-- Signal for TNC value (writen to read_TNC output each clk cycle)
signal TNC_signal         : STD_LOGIC_VECTOR(7 downto 0) := x"FC";

-- Signal to prevent decrementing if stopped or TNC value reaches zero
signal begin_decrementing : STD_LOGIC := '0';

-- Signal to prevent start
signal started_cell       : STD_LOGIC := '0';
signal is_stopped         : STD_LOGIC := '0';

begin

process(clk) begin

	if rising_edge(clk) then

		-- program value
		if program = '1' then
			TNC_signal <= TNC_value;

		elsif stop_input = '1' OR is_stopped = '1' then
			begin_decrementing <= '0';
			is_stopped <= '1';

		elsif TNC_signal = "00000000" then
			begin_decrementing <= '0';
			activate_adjacent <= '1';

		elsif begin_decrementing = '0' AND started_cell = '0' then
			if north_trigger = '1' then
				triggered_by <= "00";
				begin_decrementing <= '1';
			elsif east_trigger = '1' then
				triggered_by <= "01";
				begin_decrementing <= '1';
			elsif south_trigger = '1' then
				triggered_by <= "10";
				begin_decrementing <= '1';
			elsif west_trigger = '1' then
				triggered_by <= "11";
				begin_decrementing <= '1';
			elsif start_input = '1' then
				started_cell <= '1';
				begin_decrementing <= '1';
			end if;

		elsif begin_decrementing = '1' AND clk_en = '1' then
			TNC_signal <= TNC_signal - 1;
		end if;

		read_TNC <= TNC_signal;
	end if;
end process;

end Behavioral;