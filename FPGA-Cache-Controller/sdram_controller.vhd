----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:02:29 10/06/2025 
-- Design Name: 
-- Module Name:    sdram_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sdram_controller is
	Port(
		clk : in std_logic;
		addr: in std_logic_vector(15 downto 0);
		wr_rd: in std_logic;
		memstrb: in std_logic;
		din: in std_logic_vector(7 downto 0);
		dout: out std_logic_vector(7 downto 0)
	);	
end sdram_controller;

architecture Behavioral of sdram_controller is
-- 16 bit address line so 2^16 = 65536
type mem_array is array (0 to 65535) of std_logic_vector (7 downto 0);
signal mem : mem_array := (others =>(others=> '0'));

begin
	process(clk)
	begin
	if rising_edge(clk) then
		if memstrb = '1' then
			if wr_rd = '1' then
				mem(to_integer(unsigned(addr))) <= din;
			else
				dout <= mem(to_integer(unsigned(addr)));
			end if;
		end if;
	end if;
	end process;
end Behavioral;

