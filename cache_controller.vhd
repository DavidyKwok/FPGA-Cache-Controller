----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:02:19 09/23/2025 
-- Design Name: 
-- Module Name:    cache_controller - Behavioral 
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

entity cache_controller is
		Port(
				-- Basic Signals
				clk: in std_logic;
				rst: in std_logic;
				-- CPU Signals
				cs: in std_logic;
				wr_rd: in std_logic;
				addr: in std_logic_vector(15 downto 0);
				din: in std_logic_vector(7 downto 0);
				dout: out std_logic_vector(7 downto 0);
				rdy: out std_logic;
				--SRAM Signals
				sram_addr: out std_logic_vector(7 downto 0);
				sram_din: out std_logic_vector(7 downto 0);
				sram_dout: in std_logic_vector(7 downto 0);
				sram_wen: out std_logic;
				--SDRAM Signals
				mem_addr: out std_logic_vector(15 downto 0);
				mem_din: out std_logic_vector(7 downto 0);
				mem_dout: in std_logic_vector(7 downto 0);
				mem_wr_rd: out std_logic;
				mem_strb: out std_logic;
				state_out: out std_logic_vector(2 downto 0);
				valid_out  : out std_logic_vector(7 downto 0);
				dirty_out  : out std_logic_vector(7 downto 0)
		);			
end cache_controller;

architecture Behavioral of cache_controller is
	constant IDLE : std_logic_vector(2 downto 0) := "000";
	constant COMPARE: std_logic_vector(2 downto 0) := "001";
	constant HIT_RD: std_logic_vector(2 downto 0) := "010";
	constant HIT_WR: std_logic_vector(2 downto 0) := "011";
	constant MISS_CLEAN: std_logic_vector(2 downto 0) := "100";
	constant MISS_DIRTY: std_logic_vector(2 downto 0) := "101";
	constant REFILL: std_logic_vector(2 downto 0) := "110";
	constant WRITEBACK: std_logic_vector(2 downto 0) := "111";
	
	signal state: std_logic_vector(2 downto 0) := IDLE;
	type tag_array is array (0 to 7) of std_logic_vector(7 downto 0);
	signal tag_store: tag_array := (others => (others => '0'));
	signal valid_bits: std_logic_vector(7 downto 0) := (others => '0');
	signal dirty_bits: std_logic_vector(7 downto 0) := (others => '0');
	signal blk_cnt   : integer range 0 to 31 := 0;
   signal base_new  : std_logic_vector(15 downto 0);
   signal base_old  : std_logic_vector(15 downto 0);
	signal strb_phase : std_logic := '0';
   signal dout_r : std_logic_vector(7 downto 0) := (others => '0');
   signal rdy_r  : std_logic := '1';

begin
	dout <= dout_r;
	rdy <= rdy_r;
	state_out <= state;
	
	process(clk,rst)
		variable index: integer range 0 to 7;
	begin
		if rst = '1' then
			state <= IDLE;
			rdy_r <= '1';
			dout_r <= (others => '0');
			blk_cnt <= 0;
			tag_store <= (others => (others => '0'));
			valid_bits <= (others => '0');
			dirty_bits <= (others => '0');
			sram_addr <= (others => '0');
			sram_wen <= '0';
			sram_din <= (others => '0');
			mem_din <= (others => '0');
			mem_addr <= (others => '0');
			mem_strb <= '0';
			strb_phase <= '0';
			mem_wr_rd <= '0';

		elsif rising_edge(clk) then
			mem_strb <= '0';
			sram_wen <= '0';
			rdy_r <= '0';
			mem_wr_rd <= '0';
			
			index := to_integer(unsigned(addr(7 downto 5)));
			
			case state is 
			
			when IDLE =>
				rdy_r <= '1';
				-- Checks if CPU want so access the SRAM
				if cs = '1' then
					rdy_r <= '0';
					state <= COMPARE;
				end if;
			
			when COMPARE =>
				-- if the valid bit is 1 and the tag matches the one that is stored its a HIT
				if (valid_bits(index) = '1') and (tag_store(index) = addr(15 downto 8)) then
					if wr_rd = '0' then
						state <= HIT_RD;
					else
						state <= HIT_WR;
					end if;
				else
					-- if not then its a cache miss
					-- base address of new block from SDRAM
					 base_new <= addr(15 downto 8) & addr(7 downto 5) & "00000";
					-- base address of old block stored in cache
					 base_old <= tag_store(index) & addr(7 downto 5) & "00000";
					 blk_cnt <= 0;
					 if ((valid_bits(index) = '1') and(dirty_bits(index) = '1')) then
						state <= MISS_DIRTY;
					 else
						state <= MISS_CLEAN;
					 end if;
				end if;
				
				when HIT_RD =>
				  dout_r <= sram_dout;
				  rdy_r  <= '1';                
				  if cs = '0' then               
					 state <= IDLE;
				  else
					 state <= HIT_RD;
				  end if;

				when HIT_WR =>
				  sram_wen <= '1';
				  sram_din <= din;
				  dirty_bits(index) <= '1';
				  rdy_r  <= '1';                 
				  if cs = '0' then
					 state <= IDLE;
				  else
					 state <= HIT_WR;
				  end if;
					
				when MISS_CLEAN =>
					blk_cnt <= 0;
					-- reading
					mem_wr_rd <= '0';
					state <= REFILL;
				
				when MISS_DIRTY =>
					blk_cnt <= 0;
					--writing
					mem_wr_rd <= '1';
					state <= WRITEBACK;
				
				when REFILL =>
				-- write block from sdram to sram
					mem_wr_rd <= '0';  
					strb_phase <= not strb_phase;
					if strb_phase = '0' then
					  mem_strb <= '1';  
					  mem_addr <= std_logic_vector(unsigned(base_new) + blk_cnt);  
					  sram_wen <= '1';
					  sram_din <= mem_dout;
					  sram_addr <= addr(7 downto 5) & std_logic_vector(to_unsigned(blk_cnt, 5));
					  if blk_cnt = 31 then 
						  tag_store(index)  <= addr(15 downto 8);
						  valid_bits(index) <= '1';
						  dirty_bits(index) <= '0';
						  blk_cnt <= 0;
						  strb_phase <= '0';
						  state <= COMPARE;
						else
							blk_cnt <= blk_cnt + 1;
					 end if;
					end if;
					
				when WRITEBACK =>
				--store block from sram into sdram
					mem_wr_rd <= '1';  -- write to SDRAM
					strb_phase <= not strb_phase;
					if strb_phase = '0' then
					  mem_strb <= '1';
					  mem_addr <= std_logic_vector(unsigned(base_old) + blk_cnt);
					  mem_din <= sram_dout;
					  sram_addr <= addr(7 downto 5) & std_logic_vector(to_unsigned(blk_cnt, 5));

					 if blk_cnt = 31 then
						  dirty_bits(index) <= '0';
						  blk_cnt <= 0;
						  strb_phase <= '0';
						  state <= REFILL;
					 else
						blk_cnt <= blk_cnt + 1;
					 end if;
					end if;
					
				when others =>
					state <= IDLE;
				end case;
			end if;
	end process;
	valid_out <= valid_bits;
	dirty_out <= dirty_bits;
end Behavioral;

