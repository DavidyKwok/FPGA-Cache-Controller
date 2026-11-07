----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:20:50 10/06/2025 
-- Design Name: 
-- Module Name:    cache - Behavioral 
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

entity cache is
	Port(
		clk: in std_logic;
		rst: in std_logic;
		cs: in std_logic;
		wr_rd: in std_logic;
		addr: in std_logic_vector (15 downto 0);
		din: in std_logic_vector (7 downto 0);
		dout: out std_logic_vector (7 downto 0);
		rdy: out std_logic;
		mem_addr : out std_logic_vector (15 downto 0);
		mem_din : out std_logic_vector (7 downto 0);
		mem_wr_rd: out std_logic;
		mem_strb: out std_logic;
		mem_dout: in std_logic_vector (7 downto 0);
		state_out: out std_logic_vector(2 downto 0);
		valid_dbg: out std_logic_vector(7 downto 0);
		dirty_dbg: out std_logic_vector(7 downto 0)
		);
end cache;

architecture Behavioral of cache is

	signal sram_addr: std_logic_vector(7 downto 0);
	signal sram_din: std_logic_vector(7 downto 0);
	signal sram_dout: std_logic_vector(7 downto 0);
	signal sram_wen: std_logic;
begin
	
	C_cache_controller : entity work.cache_controller
		port map (
			clk => clk,
			rst => rst,
			cs => cs,
			wr_rd => wr_rd,
			addr => addr,
			din => din,
			dout => dout,
			rdy => rdy,
			sram_addr => sram_addr,
			sram_din => sram_din,
			sram_dout => sram_dout,
			sram_wen => sram_wen,
			mem_addr => mem_addr,
			mem_din => mem_din,
			mem_dout => mem_dout,
			mem_wr_rd => mem_wr_rd,
			mem_strb => mem_strb,
			state_out => state_out,
			valid_out => valid_dbg,
			dirty_out => dirty_dbg
		);
		
	C_bram : entity work.bram
		port map (
			clka => clk,
			wea(0) => sram_wen,
			addra => sram_addr,
			dina => sram_din,
			douta => sram_dout
		);
			
end Behavioral;

