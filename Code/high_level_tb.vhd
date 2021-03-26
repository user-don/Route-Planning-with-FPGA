--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   23:36:22 05/26/2014
-- Design Name:
-- Module Name:   O:/31designs/engs31_final_project_stayner/vhdl/high_level_tb.vhd
-- Project Name:  engs31_final_project_stayner
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: high_level
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY high_level_tb IS
END high_level_tb;

ARCHITECTURE behavior OF high_level_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT high_level is
    Port ( TXD   : in  STD_LOGIC;
       clk       : in  STD_LOGIC;
       --RXD       : out  STD_LOGIC;
       HS        : out  STD_LOGIC;
       VS        : out  STD_LOGIC;
       red_out : out  STD_LOGIC_VECTOR (2 downto 0);
       green_out : out STD_LOGIC_VECTOR(2 downto 0);
       blue_out : out STD_LOGIC_VECTOR (1 downto 0));
    end COMPONENT;


   --Inputs
   signal TXD : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal HS : std_logic;
   signal VS : std_logic;
   signal red_out : STD_LOGIC_VECTOR(2 downto 0);
   signal green_out : STD_LOGIC_VECTOR(2 downto 0);
   signal blue_out : STD_LOGIC_VECTOR (1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

   constant bit_time : time := 8.68 us; -- for baudrate 115200

   -- Write cell cost x09 to cell 0
   constant TXData_1 : std_logic_vector(7 downto 0) := x"57";
   constant TXData_2 : std_logic_vector(7 downto 0) := x"01";
   constant TXData_3 : std_logic_vector(7 downto 0) := x"00";
   constant TXData_4 : std_logic_vector(7 downto 0) := "01010101";

   -- Write cell cost
   constant TXData_5 : std_logic_vector(7 downto 0) := x"57";
   constant TXData_6 : std_logic_vector(7 downto 0) := x"01";
   constant TXData_7 : std_logic_vector(7 downto 0) := x"01";
   constant TXData_8 : std_logic_vector(7 downto 0) := "01110111";

   -- Write cell cost
   constant TXData_9 : std_logic_vector(7 downto 0) := x"57";
   constant TXData_10 : std_logic_vector(7 downto 0) := x"01";
   constant TXData_11 : std_logic_vector(7 downto 0) := x"02";
   constant TXData_12 : std_logic_vector(7 downto 0) := "11111111";

   -- Write beginning address
   constant TXData_13 : std_logic_vector(7 downto 0) := x"57";
   constant TXData_14: std_logic_vector(7 downto 0) := x"02";
   constant TXData_15 : std_logic_vector(7 downto 0) := x"00";
	constant TXData_16 : std_logic_vector(7 downto 0) := x"FF";

   -- Write end address
   constant TXData_17 : std_logic_vector(7 downto 0) := x"57";
   constant TXData_18 : std_logic_vector(7 downto 0) := x"03";
   constant TXData_19 : std_logic_vector(7 downto 0) := x"02";
	constant TXData_20 : std_logic_vector(7 downto 0) := x"FF";

   -- Write start program execution
	 constant TXData_21 : std_logic_vector(7 downto 0) := x"57";
	 constant TXData_22 : std_logic_vector(7 downto 0) := x"04";
	 constant TXData_23 : std_logic_vector(7 downto 0) := x"FF";
	 constant TXData_24 : std_logic_vector(7 downto 0) := x"FF";


BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: high_level PORT MAP (
          TXD => TXD,
          clk => clk,
          HS => HS,
          VS => VS,
          red_out => red_out,
          green_out => green_out,
          blue_out => blue_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
    TXD <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;

      -- insert stimulus here

      wait for 10 us;

      TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_1(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

      TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_2(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

      TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_3(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;
      TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_4(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

		wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_5(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_6(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_7(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_8(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_9(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_10(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_11(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_12(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_13(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_14(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_15(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_16(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_17(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_18(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_19(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;
		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_20(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_21(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_22(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;


		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_23(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;

		TXD <= '0'; -- Start bit
      wait for bit_time;

      for bitcount in 0 to 7 loop
        TXD <= TXData_24(bitcount);
        wait for bit_time;
      end loop;

      TXD <= '1'; -- Stop bit

      wait for bit_time;


      wait for 10 us;

      wait;
   end process;

END;
