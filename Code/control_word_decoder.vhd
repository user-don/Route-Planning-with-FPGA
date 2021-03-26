----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
--
-- Create Date:    00:49:01 05/26/2014
-- Module Name:    control_word_decoder - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description: Decodes serial communications from SerialRX module into
-- 				commands for the Grid
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_word_decoder is
    Port ( RX_out        : in   STD_LOGIC_VECTOR (7 downto 0);
           clk           : in   STD_LOGIC;
           rx_done_tick  : in   STD_LOGIC;
           start_address : out  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
           end_address   : out  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
           program_value : out  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
           program       : out  STD_LOGIC := '0';
           address       : out  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
           start_input   : out  STD_LOGIC := '0';
           stop_input    : out  STD_LOGIC := '0');
end control_word_decoder;

architecture Behavioral of control_word_decoder is

-- Signals for FSM
signal set_address       : STD_LOGIC := '0';
signal set_start_address : STD_LOGIC := '0';
signal set_end_address   : STD_LOGIC := '0';
signal set_cost          : STD_LOGIC := '0';

-- Signals for address, start_address, end_address and program_value to prevent latching
signal address_s         : STD_LOGIC_VECTOR(7 downto 0) := ("11111111");
signal start_address_s   : STD_LOGIC_VECTOR(7 downto 0) := ("11111111");
signal end_address_s     : STD_LOGIC_VECTOR(7 downto 0) := ("11111111");
signal program_value_s   : STD_LOGIC_VECTOR(7 downto 0) := ("11111111");



type state_type is (idle, readData, header, command, programStartAddress, programEndAddress,
					writeAddress, costValue, program_state);

signal current_state, next_state : state_type;

begin

setAddress:
process(clk) begin
	if rising_edge(clk) then
		if set_address = '1' then
			address_s <= RX_out;
		else
			address_s <= address_s;
		end if;
	end if;
end process SetAddress;
address <= address_s;

SetStartAddress:
process(clk) begin
	if rising_edge(clk) then
		if set_start_address = '1' then
			start_address_s <= RX_out;
		else
			start_address_s <= start_address_s;
		end if;
	end if;
end process SetStartAddress;
start_address <= start_address_s;

SetEndAddress:
process(clk) begin
	if rising_edge(clk) then
		if set_end_address = '1' then
			end_address_s <= RX_out;
		else
			end_address_s <= end_address_s;
		end if;
	end if;
end process SetEndAddress;
end_address <= end_address_s;

setCost:
process(clk) begin
	if rising_edge(clk) then
		if set_cost = '1' then
			program_value_s <= RX_out;
		else
			program_value_s <= program_value_s;
		end if;
	end if;
end process setCost;
program_value <= program_value_s;



clk_process: process(clk) begin
	if rising_edge(clk) then
		current_state <= next_state;
	end if;
end process clk_process;

fsm_logic: process(current_state, RX_out, rx_done_tick) begin

-- Set sensitive variables to zero
start_input <= '0';
stop_input <= '0';
set_address <= '0';
set_start_address <= '0';
set_end_address <= '0';
set_cost <= '0';
program <= '0';
next_state <= current_state;


	case current_state is

		when idle =>
			if rx_done_tick = '1' then
				next_state <= readData;
			else
				next_state <= idle;
			end if;

		 when readData =>
		 	if RX_out = x"57" then
		 		next_state <= header;
		 	else
		 		next_state <= idle;
		 	end if;

		when header =>
			if rx_done_tick = '1' then
				next_state <= command;
			else
				next_state <= header;
			end if;

		when command =>

			-- Cell Cost Write
			if RX_out = x"01" then
				next_state <= writeAddress;

			-- Start Cell Address
			elsif RX_out = x"02" then
				next_state <= programStartAddress;

			-- End Cell Address
			elsif RX_out = x"03" then
				next_state <= programEndAddress;

			-- Start Signal
			elsif RX_out = x"04" then
				start_input <= '1';
				next_state <= idle;

			-- End Signal
			elsif RX_out = x"05" then
				stop_input <= '1';
				next_state <= idle;
			else
				next_state <= command;
			end if;

		-- Third Bye: Programming Start Address
		when programStartAddress =>
			if rx_done_tick = '1' then
				set_start_address <= '1';
				next_state <= idle;
			else
				next_state <= programStartAddress;
			end if;


		-- Third Byte: Programming End Address
		when programEndAddress =>
			if rx_done_tick = '1' then
				set_end_address <= '1';
				next_state <= idle;
			else
				next_state <= programEndAddress;
			end if;

		-- Third Byte: Write address for cell cost
		when writeAddress =>
			if rx_done_tick = '1' then
				set_address <= '1';
				next_state <= costValue;
			else
				next_state <= writeAddress;
			end if;

		-- Fourth Byte: Write cell cost
		when costValue =>
			if rx_done_tick = '1' then
				set_cost <= '1';
				next_state <= program_state;
			else
				next_state <= costValue;
			end if;


		-- Program cell cost
		when program_state =>
			program <= '1';
			next_state <= idle;


	end case current_state;

end process fsm_logic;

end Behavioral;



