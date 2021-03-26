----------------------------------------------------------------------------------
-- Company: Engs 31 14S
-- Engineer: Donald Stayner and Hambleton Sonnenfeld
--
-- Create Date:    20:34:11 04/29/2014
-- Module Name:    SerialRX - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description: SerialRX.vhd takes serial bytes as input and outputs in parallel
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity SerialRX is
    Port ( clk              : in  STD_LOGIC;
           TXD_unstable     : in  STD_LOGIC;
           rx_data          : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_done_tick     : out  STD_LOGIC);
end SerialRX;

architecture Behavioral of SerialRX is

-- component brg is
--     Port ( clk         : in  STD_LOGIC;
--            br_tick16   : out  STD_LOGIC);
-- end component;

	signal TXD_flop1 : STD_LOGIC := '1'; -- output from flop one
	signal TXD      : STD_LOGIC := '1'; -- stable output from flop two

	signal rx_register       : std_logic_vector(9 downto 0):= "1111111111";
	signal shift_done      : std_logic := '0';
	signal shift_reg_en    : std_logic; -- enable input for shift register

	-- Data register
	signal data_reg_en     : std_logic;

	-- Controller FSM
	type state_type is (idle, brg_count, shift, StoreData, finished);
	signal current_state, next_state: state_type;

	-- Bit Counter
	signal bit_count       : unsigned(3 downto 0) := "0000";

	-- BRG Counter
	signal baud_rate_pulse    : std_logic;  --brg_pulse_en,
	signal brg_pulse_count : unsigned(3 downto 0) := "0111";
	signal set_counters : std_logic := '0';

	-- Baud Rate Generator
	constant baudrate : integer := 115200;
	constant M        : integer := (100000000) / (16 * baudrate);
	signal baud_rate_generator_count : integer := 0;
	signal br_tick16 : STD_LOGIC;

begin

-------------------------  Baud-Rate Generator  ---------------------------------

-- brg_one: brg
-- 	port map (
-- 				clk => clk,
-- 				br_tick16 => br_tick16);


BaudRateGenerator:
process(clk) begin
	if rising_edge(clk) then

		if (baud_rate_generator_count >= (M - 1)) then
			br_tick16 <= '1';
			baud_rate_generator_count <= 0;
		else
			baud_rate_generator_count <= baud_rate_generator_count + 1;
			br_tick16 <= '0';
		end if;

	end if;
end process BaudRateGenerator;


----------------------  Double-Flop Synchronizer  -------------------------------

FlopSync:
process(clk) begin
	if rising_edge(clk) then
		--TXD_flop1 <= TXD_unstable;
		TXD_flop1 <= TXD_unstable;
	end if;
end process FlopSync;

SecondFlopSync:
process(clk) begin
	if rising_edge(clk) then
		TXD <= TXD_flop1;
	end if;
end process SecondFlopSync;

-------------------------  Shift and Data Register ----------------------------

RegisterProcess:
process(clk, rx_register) begin
	if rising_edge(clk) then

		if shift_reg_en = '1' then
			--rx_register_sig <= rx_register_sig srl 1;
			--rx_register_sig(9) <= TXD;
			--rx_register <= std_logic_vector(rx_register_sig);
			rx_register <= TXD & rx_register(9 downto 1);
		else
			rx_register <= rx_register;
		end if;

		if data_reg_en = '1' then
			rx_data <= rx_register(8 downto 1);
		end if;

	end if;
end process RegisterProcess;


SerialBitCounter:
process(clk, bit_count) begin
	if rising_edge(clk) then

		if set_counters = '1' then
			bit_count <= "0000";
		else
			if shift_reg_en = '1' then
				bit_count <= bit_count + 1;
			end if;
		end if;

		shift_done <= '0';

		if bit_count = "1010" then
			shift_done <= '1';
		end if;

	end if;
end process SerialBitCounter;

BaudRateCounter:
process(clk, brg_pulse_count) begin
	if rising_edge(clk) then

		if set_counters = '1' then
			brg_pulse_count <= "0111";
		end if;

		baud_rate_pulse <= '0';
		if br_tick16 = '1' then

			if brg_pulse_count = "0000" then
				baud_rate_pulse <= '1';
				brg_pulse_count <= "1111";
			else
				brg_pulse_count <= brg_pulse_count - 1;
			end if;

		end if;
	end if;
end process BaudRateCounter;

------------------  Controller Finite-State Machine  ---------------------------


clk_process:
process(clk) begin
	if rising_edge(clk) then
		current_state <= next_state;
	end if;
end process clk_process;

-- Finite State Machine
combo_logic:
process(current_state, TXD, baud_rate_pulse, shift_done) begin

shift_reg_en   <= '0';
data_reg_en    <= '0';
rx_done_tick   <= '0';
set_counters <= '0';
next_state <= current_state;


	case current_state is

		when idle =>
			set_counters <= '1';
			if TXD = '0' then
				next_state <= brg_count;
			end if;

		when brg_count =>
			if shift_done = '1' then
				next_state <= StoreData;
			elsif baud_rate_pulse = '1' then
				next_state <= shift;
			end if;

		when shift =>
			shift_reg_en <= '1';
			next_state   <= brg_count;

		when StoreData =>
			data_reg_en  <= '1';
			next_state   <= finished;

		when finished =>
			rx_done_tick <= '1';
			next_state   <= idle;
	end case current_state;
end process combo_logic;

end Behavioral;



