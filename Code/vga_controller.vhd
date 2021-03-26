library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vga_controller is
	port(clk_px			: in std_logic;
       	  clk_en        : in std_logic;
		  color			: in std_logic_vector(7 downto 0);
		  red			: out std_logic_vector(2 downto 0);
		  green			: out std_logic_vector(2 downto 0);
		  blue			: out std_logic_vector(1 downto 0);
		  hs,vs			: out std_logic;
		  row,column	: out INTEGER);
end vga_controller;

architecture Behavioral of vga_controller is

	signal 	v_count,h_count: INTEGER := 0;
	constant FRONT_PORCH_H 	: INTEGER := 16;
	constant FRONT_PORCH_V 	: INTEGER := 2;
	constant BACK_PORCH_H 	: INTEGER := 48;
	constant BACK_PORCH_v 	: INTEGER := 36;
	constant SYNC_WIDTH_H 	: INTEGER := 96;
	constant SYNC_WIDTH_V 	: INTEGER := 3;
	constant SCREEN_H		: INTEGER := 640;
	constant SCREEN_V		: INTEGER := 480;


begin
	process(clk_px)
	begin
		if rising_edge(clk_px) then
            if (clk_en = '1') then

			-- based on the counts provide sync pulses
			if (h_count < SYNC_WIDTH_H) then
				hs <= '0';
			else
				hs <= '1';
			end if;

			if (v_count < SYNC_WIDTH_V) then
				vs <= '0';
			else
				vs <= '1';
			end if;

			-- rollover counts
			if (h_count < (FRONT_PORCH_H + BACK_PORCH_H + SYNC_WIDTH_H + SCREEN_H)) then
				h_count <= h_count + 1;
			else
				v_count <= v_count + 1;
				h_count <= 0;
			end if;

			if (v_count = (FRONT_PORCH_V + BACK_PORCH_v + SYNC_WIDTH_V + SCREEN_V)) then
				v_count <= 0;
			end if;

			-- color on valid times
			if (h_count > (BACK_PORCH_H + SYNC_WIDTH_H)) and (h_count < (BACK_PORCH_H + SYNC_WIDTH_H + SCREEN_H)) and (v_count > (BACK_PORCH_v + SYNC_WIDTH_V)) and (v_count < (BACK_PORCH_v + SYNC_WIDTH_V + SCREEN_V)) then
				red	<= color(7 downto 5);
				green	<= color(4 downto 2);
				blue	<= color(1 downto 0);
			else
				red <= "000";
				green <= "000";
				blue <= "00";
			end if;

			-- show currect coordinates
			if (h_count < (BACK_PORCH_H + SYNC_WIDTH_H)) then
				column <= 0;
			elsif (h_count > (BACK_PORCH_H + SYNC_WIDTH_H + SCREEN_H)) then
				column <= SCREEN_H;
			else
				column <= h_count-(BACK_PORCH_H + SYNC_WIDTH_H);
			end if;

			if (v_count < (BACK_PORCH_v + SYNC_WIDTH_V)) then
				row <= 0;
			elsif (v_count > (BACK_PORCH_v + SYNC_WIDTH_V + SCREEN_V)) then
				row <= SCREEN_V;
			else
				row <= v_count-(BACK_PORCH_v + SYNC_WIDTH_V);
			end if;
                    end if;

		end if;
	end process;

end Behavioral;
