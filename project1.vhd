----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:14:55 10/06/2025 
-- Design Name: 
-- Module Name:    project1 - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project1 is
	Port(
		--trig: in std_logic;
		clk: in std_logic;
		rst: in std_logic
	);
end project1;

architecture Behavioral of project1 is
	signal addr_bus : std_logic_vector(15 downto 0);
	signal din_cpu : std_logic_vector(7 downto 0);
	signal dout_cache: std_logic_vector(7 downto 0);
	signal cs_sig : std_logic;
   signal wr_rd_sig : std_logic;
   signal rdy_sig : std_logic;
	signal mem_addr : std_logic_vector(15 downto 0);
	signal mem_din : std_logic_vector(7 downto 0);
	signal mem_dout : std_logic_vector(7 downto 0);
	signal mem_wr_rd: std_logic;
	signal mem_strb: std_logic;
	signal cache_state : std_logic_vector(2 downto 0);
	signal valid_dbg : std_logic_vector(7 downto 0);
	signal dirty_dbg : std_logic_vector(7 downto 0);
	signal trig: std_logic;
	-- added to test
	signal rdy_q : std_logic := '0';
	signal trig_pulse: std_logic := '0';
	signal boot_q: std_logic := '0';
	
	component icon
		 port (
			CONTROL0 : inout std_logic_vector(35 downto 0)
		 );
   end component;

   component ila
		 port (
			CONTROL : inout std_logic_vector(35 downto 0);
			CLK     : in    std_logic;
			TRIG0   : in    std_logic_vector(88 downto 0)
		 );
  end component;

  signal control_bus: std_logic_vector(35 downto 0);
  signal probe_bus: std_logic_vector(88 downto 0);
begin
	
	C_CPU : entity work.CPU_gen
		port map(
			clk => clk,
			rst => rst,
			trig => trig,
			Address => addr_bus,
			wr_rd => wr_rd_sig,
			cs => cs_sig,
			DOut => din_cpu
		);
		
	C_cache : entity work.cache
		port map(
			clk => clk,
			rst => rst,
			cs => cs_sig,
			wr_rd => wr_rd_sig,
			addr => addr_bus,
			din => din_cpu,
			dout => dout_cache,
			rdy => rdy_sig,
			mem_addr => mem_addr,
			mem_din => mem_din,
			mem_dout => mem_dout,
			mem_wr_rd => mem_wr_rd,
			mem_strb => mem_strb,
			state_out => cache_state,
			valid_dbg => valid_dbg,
			dirty_dbg => dirty_dbg
		);
	
	C_SDRAM : entity work.sdram_controller
		port map (
			clk => clk,
			addr => mem_addr,
			wr_rd => mem_wr_rd,
			memstrb => mem_strb,
			din => mem_din,
			dout => mem_dout
		);

	C_ICON: icon
		port map(
			CONTROL0 => control_bus
		);
		
	C_ILA: ila
		port map(
			CONTROL => control_bus,
			CLK => clk,
			TRIG0 => probe_bus
			);
	 process(clk)
		begin
			if rising_edge(clk) then
				if rst = '1' then
				  rdy_q      <= '0';
				  trig_pulse <= '0';
				  boot_q     <= '1';          
				else
				  trig_pulse <= (rdy_sig and not rdy_q) or boot_q;
				  rdy_q      <= rdy_sig;
				  boot_q     <= '0';          
				end if;
			end if;
	  end process;
	  trig <= trig_pulse;
	  probe_bus(88 downto 81) <= mem_din; 
	  probe_bus(80) <= trig;
	  probe_bus(79 downto 72) <= valid_dbg;
	  probe_bus(71 downto 64) <= dirty_dbg;
	  probe_bus(63 downto 48) <= addr_bus;
	  probe_bus(47)<= cs_sig;
	  probe_bus(46)<= wr_rd_sig;
	  probe_bus(45)<= rdy_sig;
	  probe_bus(44)<= mem_strb;
	  probe_bus(43)<= mem_wr_rd;
	  probe_bus(42 downto 40) <= cache_state;
	  probe_bus(39 downto 24) <= mem_addr;
	  probe_bus(23 downto 16) <= mem_dout;
	  probe_bus(15 downto 8)  <= din_cpu;
	  probe_bus(7 downto 0)   <= dout_cache;
end Behavioral;

