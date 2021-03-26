----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
--
-- Create Date:    02:45:29 05/22/2014
-- Module Name:    grid - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:  Wrapper to interface cells with other components of system
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity grid is
	Port ( clk 			 	   : in STD_LOGIC;
		   program             : in STD_LOGIC;
		   clk_enable          : in STD_LOGIC;
		   address             : in STD_LOGIC_VECTOR(7 downto 0);
		   program_value       : in STD_LOGIC_VECTOR(7 downto 0);
		   start_input         : in STD_LOGIC;
		   stop_input          : in STD_LOGIC;
		   start_address       : in STD_LOGIC_VECTOR(7 downto 0);
		   end_address		   : in STD_LOGIC_VECTOR(7 downto 0);
		   vga_address_request : in STD_LOGIC_VECTOR(7 downto 0);
		   read_value          : out STD_LOGIC_VECTOR(7 downto 0));
end grid;

architecture Behaviorial of grid is

component unit_cell is
	Port ( clk			        : in  STD_LOGIC;
			 north_trigger     : in  STD_LOGIC := '0';
		   clk_en            : in  STD_LOGIC;
		   east_trigger      : in  STD_LOGIC := '0';
		   south_trigger     : in  STD_LOGIC := '0';
		   west_trigger      : in  STD_LOGIC := '0';
		   TNC_value         : in  STD_LOGIC_VECTOR (7 downto 0);
		   program           : in  STD_LOGIC;
		   stop_input        : in  STD_LOGIC;
		   start_input       : in  STD_LOGIC;
		   triggered_by      : out  STD_LOGIC_VECTOR (1 downto 0);
		   read_TNC          : out  STD_LOGIC_VECTOR (7 downto 0);
		   activate_adjacent : out  STD_LOGIC);
end component;

-- Arrays for storage of cell values and trigger directions
type matrix_256_bits is array (0 to 255) of STD_LOGIC;
signal activate_adjacent_array : matrix_256_bits := (others => '0');
signal program_selected_cell   : matrix_256_bits := (others => '0');
signal start_array             : matrix_256_bits := (others => '0');
signal stop_array              : matrix_256_bits := (others => '0');
signal backtrace_array         : matrix_256_bits := (others => '0');

type TNC_array is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
signal TNC_value_array           : TNC_array := (others => (others => '0'));

type direction_array is array (0 to 255) of STD_LOGIC_VECTOR(1 downto 0);
signal triggered_direction_array : direction_array := (others => (others => '0'));

-- Signal linking stop input from decoder to stop inputs of cells
signal stop_input_sig : STD_LOGIC := '0';


-- Backtrace Signals
signal enable_backtrace      : STD_LOGIC := '0';
signal halt_decrementing  	 : STD_LOGIC := '0';
signal clear_backtrace       : STD_LOGIC := '0';
signal current_backtrace     : INTEGER;
signal get_end_address_value : STD_LOGIC := '0';

begin


---------------------------------- Backtrace Process -----------------------------
BacktraceProcess:
process(clk) begin

	if rising_edge(clk) then

		-- Assigns end address to backtrace variable (called when program started)
		if get_end_address_value = '1' then
			current_backtrace <= to_integer(unsigned(end_address));
		end if;

		-- Body of the backtrace process
		if enable_backtrace = '1' then

			if current_backtrace = to_integer(unsigned(start_address)) then
				clear_backtrace <= '1';
				halt_decrementing <= '1';
			else
				if triggered_direction_array(current_backtrace) = "00" then
					current_backtrace <= current_backtrace - 16;
				elsif triggered_direction_array(current_backtrace) = "01" then
					current_backtrace <= current_backtrace  + 1;
				elsif triggered_direction_array(current_backtrace) = "10" then
					current_backtrace <= current_backtrace + 16;
				elsif triggered_direction_array(current_backtrace) = "11" then
					current_backtrace <= current_backtrace - 1;
				end if;
			end if;

			-- Tracks progress of backtrace in an array for VGA display
			backtrace_array(current_backtrace) <= '1';
		end if;

	end if;
end process BacktraceProcess;
--------------------------Process: VGA Query Grid for value-----------------------
vga_query:
process(clk) begin
	if rising_edge(clk) then
		if clear_backtrace = '1' OR enable_backtrace = '1' then

			if backtrace_array(to_integer(unsigned(vga_address_request))) = '1' then
				read_value <= x"FE";
			elsif vga_address_request = end_address then
				read_value <= x"FE";
			elsif vga_address_request = start_address then
				read_value <= x"FE";
			else
				read_value <= TNC_value_array(to_integer(unsigned(vga_address_request)));
			end if;
		else
			read_value <= TNC_value_array(to_integer(unsigned(vga_address_request)));
		end if;
	end if;
end process vga_query;
-----------------------------  Program and Start  --------------------------------

-- Clocked process to program cell values and start the program
controller_process:
process(clk) begin

	if rising_edge(clk) then
		program_selected_cell <= (others => '0');
		get_end_address_value <= '0';
		start_array <= (others => '0');

		if program = '1' then
			program_selected_cell(to_integer(unsigned(address))) <= '1';

		elsif start_input = '1' then
			get_end_address_value <= '1';
			start_array(to_integer(unsigned(start_address))) <= '1';
		end if;

	end if;
end process controller_process;

---------------------  Track Decrementing and Backtrace  ------------------------

-- Clocked process to track process of decrementing and backtrace
check_if_done:
process(clk) begin

	if rising_edge(clk) then
		if clear_backtrace = '1' then
			enable_backtrace <= '0';
		elsif activate_adjacent_array(to_integer(unsigned(end_address))) = '1' then
			enable_backtrace <= '1';
		end if;
	end if;
end process check_if_done;


---------------------  Stop Decrementing for All Cells  ------------------------

stop_cells:
process(clk) begin
	if rising_edge(clk) then
		if halt_decrementing = '1' OR stop_input = '1' then
			stop_input_sig <= '1';
		else
			stop_input_sig <= '0';
		end if;
	end if;
end process stop_cells;

----------------------------------------------------------------------------------
------------------------------  Generate Grid  -----------------------------------
----------------------------------------------------------------------------------

rows : for row in 0 to 15 generate
	cols : for col in 0 to 15 generate

------------------------------  Middle Block  ------------------------------------
	general:if ((row > 0) AND (col > 0) AND (row < 15) AND (col < 15)) generate
	middle_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array((col + (row * 16)) - 16),
				south_trigger     => activate_adjacent_array((col + (row * 16)) + 16),
				east_trigger      => activate_adjacent_array((col + (row * 16)) + 1),
				west_trigger      => activate_adjacent_array((col + (row * 16)) - 1),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(col + (row * 16)),
				start_input       => start_array(col + (row * 16)),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(col + (row * 16)),
				read_TNC          => TNC_value_array(col + (row * 16)),
				activate_adjacent => activate_adjacent_array(col + (row * 16)));
	end generate general;

----------------------------------------------------------------------------------
--------------------------------  Corners  ---------------------------------------
----------------------------------------------------------------------------------

	upper_left:if ((row = 0) AND (col = 0)) generate
	upper_left_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => open,
				south_trigger     => activate_adjacent_array(16),
				east_trigger      => activate_adjacent_array(1),
				west_trigger      => open,
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(0),
				start_input       => start_array(0),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(0),
				read_TNC          => TNC_value_array(0),
				activate_adjacent => activate_adjacent_array(col + row * 16));
	end generate upper_left;

--------------------------  Upper Right Corner  ----------------------------------
	upper_right:if ((row = 0) AND (col = 15)) generate
	upper_right_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => open,
				south_trigger     => activate_adjacent_array(31),
				east_trigger      => open,
				west_trigger      => activate_adjacent_array(14),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(15),
				start_input       => start_array(15),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(15),
				read_TNC          => TNC_value_array(15),
				activate_adjacent => activate_adjacent_array(15));
	end generate upper_right;

--------------------------  Lower Left Corner  -----------------------------------
	lower_left:if ((row = 15) AND (col = 0)) generate
	lower_left_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array(224),
				south_trigger     => open,
				east_trigger      => activate_adjacent_array(241),
				west_trigger      => open,
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(240),
				start_input       => start_array(240),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(240),
				read_TNC          => TNC_value_array(240),
				activate_adjacent => activate_adjacent_array(240));
	end generate lower_left;

--------------------------  Lower Right Corner  ----------------------------------
	lower_right:if ((row = 15) AND (col = 15)) generate
	lower_right_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array(239),
				south_trigger     => open,
				east_trigger      => open,
				west_trigger      => activate_adjacent_array(254),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(255),
				start_input       => start_array(255),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(255),
				read_TNC          => TNC_value_array(255),
				activate_adjacent => activate_adjacent_array(255));
	end generate lower_right;

----------------------------------------------------------------------------------
----------------------------  Outside Lines  -------------------------------------
----------------------------------------------------------------------------------

------------------------------  Upper Row  ---------------------------------------
	upper_row:if ((row = 0) AND (col > 0) AND (col < 15)) generate
	upper_row_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => open,
				south_trigger     => activate_adjacent_array(col + 16),
				east_trigger      => activate_adjacent_array(col + 1),
				west_trigger      => activate_adjacent_array(col - 1),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(col),
				start_input       => start_array(col),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(col),
				read_TNC          => TNC_value_array(col),
				activate_adjacent => activate_adjacent_array(col));
	end generate upper_row;


------------------------------  Right Column  --------------------------------------
	right_row:if ((row > 0) AND (row < 15) AND (col = 15)) generate
	right_row_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array((row * 16) - 1),
				south_trigger     => activate_adjacent_array((row * 16) + 31),
				east_trigger      => open,
				west_trigger      => activate_adjacent_array((row * 16) + 14),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell((row * 16) + 15),
				start_input       => start_array((row * 16) + 15),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array((row * 16) + 15),
				read_TNC          => TNC_value_array((row * 16) + 15),
				activate_adjacent => activate_adjacent_array((row * 16) + 15));
	end generate right_row;

------------------------------  Bottom Row  ---------------------------------------
	bottom_row:if ((row = 15) AND (col > 0) AND (col < 15)) generate
	bottom_row_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array((col + 240) - 16),
				south_trigger     => open,
				east_trigger      => activate_adjacent_array(col + 241),
				west_trigger      => activate_adjacent_array(col + 239),
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(col + 240),
				start_input       => start_array(col + 240),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(col + 240),
				read_TNC          => TNC_value_array(col + 240),
				activate_adjacent => activate_adjacent_array(col + 240));
	end generate bottom_row;

------------------------------  Left Column  --------------------------------------
	left_row:if ((row > 0) AND (row < 15) AND (col = 0)) generate
	left_row_cell: unit_cell
	port map (  clk 			  => clk,
				north_trigger     => activate_adjacent_array((row * 16) - 16),
				south_trigger     => activate_adjacent_array((row * 16) + 16),
				east_trigger      => activate_adjacent_array((row * 16) + 1),
				west_trigger      => open,
				clk_en            => clk_enable,
				TNC_value         => program_value,
				program           => program_selected_cell(row * 16),
				start_input       => start_array(row * 16),
				stop_input        => stop_input_sig,
				triggered_by      => triggered_direction_array(row * 16),
				read_TNC          => TNC_value_array(row * 16),
				activate_adjacent => activate_adjacent_array(row * 16));
	end generate left_row;

	end generate cols;
end generate rows;
end Behaviorial;