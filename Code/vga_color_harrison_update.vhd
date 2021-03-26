library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vga_color is
	port(row,column	     : in INTEGER;
         cell_address    : out std_logic_vector(7 downto 0);
         cell_data       : in std_logic_vector(7 downto 0);
         color           : out std_logic_vector(7 downto 0));
end vga_color;

architecture Behavioral of vga_color is

	-- Predefined 8-bit colors that nearly match real test pattern colors
	constant RED		: std_logic_vector(7 downto 0) := "11100000";
	constant GREEN		: std_logic_vector(7 downto 0) := "00011100";
	constant BLUE		: std_logic_vector(7 downto 0) := "00000011";
	constant CYAN		: std_logic_vector(7 downto 0) := "00011111";
	constant YELLOW		: std_logic_vector(7 downto 0) := "11111100";
	constant PURPLE		: std_logic_vector(7 downto 0) := "01100011";
	constant WHITE		: std_logic_vector(7 downto 0) := "11011011";
	constant BLACK		: std_logic_vector(7 downto 0) := "00000000";
	constant GRAY0		: std_logic_vector(7 downto 0) := "01001001";
	constant GRAY1		: std_logic_vector(7 downto 0) := "10010010";
	constant DARK_BLU	: std_logic_vector(7 downto 0) := "00001010";
	constant DARK_PUR	: std_logic_vector(7 downto 0) := "01000010";



	signal column_enable: std_logic;
	signal row_enable: std_logic;
	signal column_box: std_logic_vector(3 downto 0);
	signal row_box: std_logic_vector(3 downto 0);
	signal color_shade: std_logic_vector(7 downto 0);


begin

	-- set the colors based on the current pixel
	process(row,column, row_enable, row_box, cell_data, color_shade, column_enable, column_box)
	begin



    if (row >= 17) and (row <= 43) then
	   row_box <= "0000";
	   row_enable <= '1';
    elsif (row >= 45) and (row <= 71) then
	   row_box <= "0001";
	   row_enable <= '1';
    elsif (row >= 73) and (row <= 99) then
	   row_box <= "0010";
	   row_enable <= '1';
    elsif (row >= 101) and (row <= 127) then
	   row_box <= "0011";
	   row_enable <= '1';
    elsif (row >= 129) and (row <= 155) then
	   row_box <= "0100";
	   row_enable <= '1';
    elsif (row >= 157) and (row <= 183) then
	   row_box <= "0101";
	   row_enable <= '1';
    elsif (row >= 185) and (row <= 211) then
	   row_box <= "0110";
	   row_enable <= '1';
    elsif (row >= 213) and (row <= 239) then
	   row_box <= "0111";
	   row_enable <= '1';
    elsif (row >= 241) and (row <= 267) then
	   row_box <= "1000";
	   row_enable <= '1';
    elsif (row >= 269) and (row <= 295) then
	   row_box <= "1001";
	   row_enable <= '1';
    elsif (row >= 297) and (row <= 323) then
	   row_box <= "1010";
	   row_enable <= '1';
    elsif (row >= 325) and (row <= 351) then
	   row_box <= "1011";
	   row_enable <= '1';
    elsif (row >= 353) and (row <= 379) then
	   row_box <= "1100";
	   row_enable <= '1';
    elsif (row >= 381) and (row <= 407) then
	   row_box <= "1101";
	   row_enable <= '1';
    elsif (row >= 409) and (row <= 435) then
	   row_box <= "1110";
	   row_enable <= '1';
    elsif (row >= 437) and (row <= 462) then
	   row_box <= "1111";
	   row_enable <= '1';
	else row_enable <= '0';
	   row_box <= "0000";
	   end if;


    if (column >= 97) and (column <= 123) then
	   column_box <= "0000";
	   column_enable <= '1';
    elsif (column >=125) and (column <= 151) then
	   column_box <= "0001";
	   column_enable <= '1';
    elsif (column >= 153) and (column <= 179) then
	   column_box <= "0010";
	   column_enable <= '1';
    elsif (column >= 181) and (column <= 207) then
	   column_box <= "0011";
	   column_enable <= '1';
    elsif (column >= 209) and (column <= 235) then
	   column_box <= "0100";
	   column_enable <= '1';
    elsif (column >= 237) and (column <= 263) then
	   column_box <= "0101";
	   column_enable <= '1';
    elsif (column >= 265) and (column <= 291) then
	   column_box <= "0110";
	   column_enable <= '1';
    elsif (column >= 293) and (column <= 319) then
	   column_box <= "0111";
	   column_enable <= '1';
    elsif (column >= 321) and (column <= 347) then
	   column_box <= "1000";
	   column_enable <= '1';
    elsif (column >= 349) and (column <= 375) then
	   column_box <= "1001";
	   column_enable <= '1';
    elsif (column >= 377) and (column <= 403) then
	   column_box <= "1010";
	   column_enable <= '1';
    elsif (column >= 405) and (column <= 431) then
	   column_box <= "1011";
	   column_enable <= '1';
    elsif (column >= 433) and (column <= 459) then
	   column_box <= "1100";
	   column_enable <= '1';
    elsif (column >= 461) and (column <= 487) then
	   column_box <= "1101";
	   column_enable <= '1';
    elsif (column >= 489) and (column <= 514) then
	   column_box <= "1110";
	   column_enable <= '1';
    elsif (column >= 516) and (column <= 542) then
	   column_box <= "1111";
	   column_enable <= '1';
	else column_enable <= '0';
	   column_box <= "0000";
	   end if;


	if ((row_enable = '1') and (column_enable = '1')) then
	   cell_address <= row_box & column_box;
	   color_shade <= cell_data;
	   else cell_address <= "00000000";
	      color_shade <= "11111111";
		  end if;

	if color_shade = x"00" then color <= red;
		elsif color_shade < std_logic_vector(conv_unsigned(4, 8)) then color <= d2;
		elsif color_shade < std_logic_vector(conv_unsigned(12, 8)) then color <= d3;
		elsif color_shade < std_logic_vector(conv_unsigned(16, 8)) then color <= d4;
		elsif color_shade < std_logic_vector(conv_unsigned(20, 8)) then color <= d5;
		elsif color_shade < std_logic_vector(conv_unsigned(24, 8)) then color <= d6;
		elsif color_shade < std_logic_vector(conv_unsigned(28, 8)) then color <= d7;
		elsif color_shade < std_logic_vector(conv_unsigned(32, 8)) then color <= d8;
		elsif color_shade < std_logic_vector(conv_unsigned(36, 8)) then color <= d9;
		elsif color_shade < std_logic_vector(conv_unsigned(40, 8)) then color <= d10;
		elsif color_shade < std_logic_vector(conv_unsigned(44, 8)) then color <= d11;
		elsif color_shade < std_logic_vector(conv_unsigned(48, 8)) then color <= d12;
		elsif color_shade < std_logic_vector(conv_unsigned(52, 8)) then color <= d13;
		elsif color_shade < std_logic_vector(conv_unsigned(56, 8)) then color <= d14;
		elsif color_shade < std_logic_vector(conv_unsigned(60, 8)) then color <= d15;
		elsif color_shade < std_logic_vector(conv_unsigned(64, 8)) then color <= d16;
		elsif color_shade < std_logic_vector(conv_unsigned(68, 8)) then color <= d17;
		elsif color_shade < std_logic_vector(conv_unsigned(72, 8)) then color <= d18;
		elsif color_shade < std_logic_vector(conv_unsigned(76, 8)) then color <= d19;
		elsif color_shade < std_logic_vector(conv_unsigned(80, 8)) then color <= d20;
		elsif color_shade < std_logic_vector(conv_unsigned(84, 8)) then color <= d21;
		elsif color_shade < std_logic_vector(conv_unsigned(88, 8)) then color <= d22;
		elsif color_shade < std_logic_vector(conv_unsigned(92, 8)) then color <= d23;
		elsif color_shade < std_logic_vector(conv_unsigned(96, 8)) then color <= d24;
		elsif color_shade < std_logic_vector(conv_unsigned(100, 8)) then color <= d25;
		elsif color_shade < std_logic_vector(conv_unsigned(104, 8)) then color <= d26;
		elsif color_shade < std_logic_vector(conv_unsigned(108, 8)) then color <= d27;
		elsif color_shade < std_logic_vector(conv_unsigned(112, 8)) then color <= d28;
		elsif color_shade < std_logic_vector(conv_unsigned(116, 8)) then color <= d29;
		elsif color_shade < std_logic_vector(conv_unsigned(120, 8)) then color <= d30;
		elsif color_shade < std_logic_vector(conv_unsigned(124, 8)) then color <= d31;
		elsif color_shade < std_logic_vector(conv_unsigned(128, 8)) then color <= d32;
		elsif color_shade < std_logic_vector(conv_unsigned(132, 8)) then color <= d33;
		elsif color_shade < std_logic_vector(conv_unsigned(136, 8)) then color <= d34;
		elsif color_shade < std_logic_vector(conv_unsigned(140, 8)) then color <= d35;
		elsif color_shade < std_logic_vector(conv_unsigned(144, 8)) then color <= d36;
		elsif color_shade < std_logic_vector(conv_unsigned(148, 8)) then color <= d37;
		elsif color_shade < std_logic_vector(conv_unsigned(152, 8)) then color <= d38;
		elsif color_shade < std_logic_vector(conv_unsigned(156, 8)) then color <= d39;
		elsif color_shade < std_logic_vector(conv_unsigned(160, 8)) then color <= d40;
		elsif color_shade < std_logic_vector(conv_unsigned(164, 8)) then color <= d41;
		elsif color_shade < std_logic_vector(conv_unsigned(168, 8)) then color <= d42;
		elsif color_shade < std_logic_vector(conv_unsigned(172, 8)) then color <= d43;
		elsif color_shade < std_logic_vector(conv_unsigned(176, 8)) then color <= d44;
		elsif color_shade < std_logic_vector(conv_unsigned(180, 8)) then color <= d45;
		elsif color_shade < std_logic_vector(conv_unsigned(184, 8)) then color <= d46;
		elsif color_shade < std_logic_vector(conv_unsigned(188, 8)) then color <= d47;
		elsif color_shade < std_logic_vector(conv_unsigned(192, 8)) then color <= d48;
		elsif color_shade < std_logic_vector(conv_unsigned(196, 8)) then color <= d49;
		elsif color_shade < std_logic_vector(conv_unsigned(200, 8)) then color <= d50;
		elsif color_shade < std_logic_vector(conv_unsigned(204, 8)) then color <= d51;
		elsif color_shade < std_logic_vector(conv_unsigned(208, 8)) then color <= d52;
		elsif color_shade < std_logic_vector(conv_unsigned(212, 8)) then color <= d53;
		elsif color_shade < std_logic_vector(conv_unsigned(216, 8)) then color <= d54;
		elsif color_shade < std_logic_vector(conv_unsigned(220, 8)) then color <= d55;
		elsif color_shade < std_logic_vector(conv_unsigned(224, 8)) then color <= d56;
		elsif color_shade < std_logic_vector(conv_unsigned(228, 8)) then color <= d57;
		elsif color_shade < std_logic_vector(conv_unsigned(232, 8)) then color <= d58;
		elsif color_shade < std_logic_vector(conv_unsigned(236, 8)) then color <= d59;
		elsif color_shade < std_logic_vector(conv_unsigned(240, 8)) then color <= d60;
		elsif color_shade < std_logic_vector(conv_unsigned(244, 8)) then color <= d61;
		elsif color_shade < std_logic_vector(conv_unsigned(248, 8)) then color <= d62;
		elsif color_shade < std_logic_vector(conv_unsigned(252, 8)) then color <= d63;
		elsif color_shade < std_logic_vector(conv_unsigned(256, 8)) then color <= d64;
	    else color <= black;
	   end if;

	end process;

end Behavioral;
