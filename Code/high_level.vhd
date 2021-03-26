----------------------------------------------------------------------------------
-- Company: ENGS 31 14S
-- Engineer: Donald Stayner
--
-- Create Date:    18:40:54 05/25/2014
-- Module Name:    high_level - Behavioral
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description: High-level module for pathfinding code
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity high_level is
    Port ( TXD 	 : in  STD_LOGIC;
		   clk       : in  STD_LOGIC;
		   HS        : out  STD_LOGIC;
		   VS        : out  STD_LOGIC;
		   red_out : out  STD_LOGIC_VECTOR (2 downto 0);
		   green_out : out STD_LOGIC_VECTOR(2 downto 0);
		   blue_out : out STD_LOGIC_VECTOR (1 downto 0));
end high_level;

architecture Behavioral of high_level is

----------------------------------------------------------------------------------
----------------------------  Define Components  ---------------------------------
----------------------------------------------------------------------------------


component SerialRX is
    Port ( clk                 : in  STD_LOGIC;
		   TXD_unstable        : in  STD_LOGIC;
		   rx_data             : out  STD_LOGIC_VECTOR (7 downto 0);
		   rx_done_tick        : out  STD_LOGIC);
end component;

component vga_color is
	port(row,column	     	  : in INTEGER;
		   cell_address        : out std_logic_vector(7 downto 0);
		   cell_data           : in std_logic_vector(7 downto 0);
		   color               : out std_logic_vector(7 downto 0));
end component;

component vga_controller is
	port(clk_px				     : in std_logic;
		   clk_en       	     : in std_logic;
		  color    			     : in std_logic_vector(7 downto 0);
		  red			         : out std_logic_vector(2 downto 0);
		  green			         : out std_logic_vector(2 downto 0);
		  blue			         : out std_logic_vector(1 downto 0);
		  hs,vs			         : out std_logic;
		  row,column	         : out INTEGER);
end component;

component grid is
	Port ( clk 			 	     : in STD_LOGIC;
		   program             : in STD_LOGIC;
		   clk_enable          : in STD_LOGIC;
		   address             : in STD_LOGIC_VECTOR(7 downto 0);
		   program_value       : in STD_LOGIC_VECTOR(7 downto 0);
		   start_input         : in STD_LOGIC;
		   stop_input          : in STD_LOGIC;
		   start_address       : in STD_LOGIC_VECTOR(7 downto 0);
		   end_address	       : in STD_LOGIC_VECTOR(7 downto 0);
		   vga_address_request : in STD_LOGIC_VECTOR(7 downto 0);
		   read_value          : out STD_LOGIC_VECTOR(7 downto 0));
end component;

component control_word_decoder is
    Port ( RX_out            : in  STD_LOGIC_VECTOR (7 downto 0);
		   clk                 : in  STD_LOGIC;
		   rx_done_tick        : in STD_LOGIC;
		   start_address       : out  STD_LOGIC_VECTOR(7 downto 0);
		   end_address         : out  STD_LOGIC_VECTOR(7 downto 0);
		   program_value       : out  STD_LOGIC_VECTOR(7 downto 0);
		   program             : out  STD_LOGIC;
		   address             : out  STD_LOGIC_VECTOR(7 downto 0);
		   start_input         : out  STD_LOGIC;
		   stop_input          : out  STD_LOGIC);
end component;

component clk_enable_driver is
    Port ( clk    : in  STD_LOGIC;
           clk_en : out  STD_LOGIC);
end component;

component vga_clk_driver is
    Port ( clk   : in  STD_LOGIC;
           clk25 : out  STD_LOGIC);
end component;


-- Signals

	-- SerialRX to Control Word Decoder
	signal RX_data_sig          : STD_LOGIC_VECTOR(7 downto 0);
	signal rx_done_tick         : STD_LOGIC;

	-- Control Word Decoder and Grid
	signal program_value        : STD_LOGIC_VECTOR(7 downto 0);
	signal address_to_grid      : STD_LOGIC_VECTOR(7 downto 0);
	signal start_signal         : STD_LOGIC;
	signal stop_signal          : STD_LOGIC;
	signal program_signal       : STD_LOGIC;
	signal end_address          : STD_LOGIC_VECTOR(7 downto 0);
	signal start_address        : STD_LOGIC_VECTOR(7 downto 0);

	-- Grid and VGA
	signal vga_cell_request     : STD_LOGIC_VECTOR(7 downto 0);
	signal vga_cell_request_out : STD_LOGIC_VECTOR(7 downto 0);
	signal data_to_vga          : STD_LOGIC_VECTOR(7 downto 0);
	signal color_sig            : STD_LOGIC_VECTOR(7 downto 0);
	signal clk25_sig            : STD_LOGIC := '0';

	-- Clock enable signal: 50Hz clock
	signal clk_enable_sig       : STD_LOGIC := '0';

	-- VGA_color and VGA_controller
	signal row_sig              : integer;
	signal column_sig           : integer;

begin

decoder_one: control_word_decoder
	port map (
			clk                 => clk,
			rx_done_tick        => rx_done_tick,
			RX_out              => RX_data_sig,
			start_address       => start_address,
			end_address         => end_address,
			program_value       => program_value,
			program             => program_signal,
			address             => address_to_grid,
			start_input         => start_signal,
			stop_input          => stop_signal);

receiver: SerialRX
	port map (
			clk               => clk,
			TXD_unstable        => TXD,
			rx_data             => RX_data_sig,
			rx_done_tick        => rx_done_tick);


cell_grid: Grid
	port map (
			clk                 => clk,
			program             => program_signal,
			clk_enable          => clk_enable_sig,
			address             => address_to_grid,
			program_value       => program_value,
			start_input         => start_signal,
			stop_input          => stop_signal,
			start_address       => start_address,
			end_address         => end_address,
			vga_address_request => vga_cell_request_out,
			read_value          => data_to_vga);

vga_controller_one: vga_controller
	port map (
			clk_px              => clk,
			clk_en              => clk25_sig,
			color               => color_sig,
			red                 => red_out,
			green               => green_out,
			blue                => blue_out,
			hs                  => HS,
			vs                  => VS,
			row                 => row_sig,
			column              => column_sig);

vga_color_one: vga_color
	port map (
			row                 => row_sig,
			column              => column_sig,
			cell_address        => vga_cell_request,
			cell_data           => data_to_vga,
			color               => color_sig);

clk_driver: clk_enable_driver
	port map (
			clk => clk,
			clk_en => clk_enable_sig);

vga_driver: vga_clk_driver
	port map (
			clk => clk,
			clk25 => clk25_sig);


-- Mux to divide up loop between VGA and Grid for timing issues

process(clk) begin
	if rising_edge(clk) then
		vga_cell_request_out <= vga_cell_request;
	end if;
end process;

end Behavioral;


























