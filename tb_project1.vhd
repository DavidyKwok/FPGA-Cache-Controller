--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:25:05 10/08/2025
-- Design Name:   
-- Module Name:    tb_project1.vhd
-- Project Name:  Project1_Cache_Controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: project1
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_project1 is
end tb_project1;

architecture sim of tb_project1 is

  component project1
    port(
      clk : in std_logic;
      rst : in std_logic
    );
  end component;

  signal clk_tb : std_logic := '0';
  signal rst_tb : std_logic := '1';

  signal done_sim : boolean := false;

begin
 
  DUT : project1
    port map(
      clk => clk_tb,
      rst => rst_tb
    );

  clk_process : process
  begin
    while not done_sim loop
      clk_tb <= '0';
      wait for 10 ns;
      clk_tb <= '1';
      wait for 10 ns;
    end loop;
    wait;
  end process;
 
  reset_process : process
  begin
    rst_tb <= '1';
    wait for 200 ns;
    rst_tb <= '0';
    wait;
  end process;


  stop_process : process
  begin
    wait for 5 ms;
    done_sim <= true;
    wait;
  end process;

end sim;
