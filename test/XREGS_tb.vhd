-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

-- Copyright 2022 Luiz Schonarth

-- This file is part of RISC-VHDL.

-- RISC-VHDL is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- RISC_VHDL  is distributed in the hope that it will be useful, but 
-- WITHOUT ANY WARRANTY; without even the implied warranty of 
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with RISC-VHDL. If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XREGS_tb is
  generic (
    WSIZE : natural := 32;
    NREGS : natural := 32
  );
end entity;

architecture testbench of XREGS_tb is
  component XREGS 
    port (
      clk, wren, rst : in std_logic;
      rs1, rs2, rd :   in std_logic_vector(4 downto 0);
      data :           in std_logic_vector(WSIZE-1 downto 0);
      ro1, ro2 :       out std_logic_vector(WSIZE-1 downto 0)
    );
  end component;

  -- Defining and initializing the clock
  signal clk : std_logic := '0';
  constant clk_period : time := 2 ns;

  -- Initializing signal values
  signal wren, rst :    std_logic := '0';
  signal rs1, rs2, rd : std_logic_vector(4 downto 0) := (others => '0');
  signal data :         std_logic_vector(WSIZE-1 downto 0) := x"00000000";
  signal ro1, ro2 :     std_logic_vector(WSIZE-1 downto 0) := x"00000000";
  signal stop_signal :  boolean := false;


begin
  moduleXREGS: XREGS port map(clk, wren, rst, rs1, rs2, rd, data, ro1, ro2);

  -- Generate clock cycles
  clk_cycle : process
  begin
      while stop_signal = false loop
          clk <= not clk;
          wait for clk_period / 2;
      end loop;
      wait;
  end process clk_cycle;

  -- Testing XREGS module
  testbench : process
    constant UNKNOWN : std_logic_vector(WSIZE-1 downto 0) := (others => 'X');
  begin
    -----------------------------------------------------------------
    -- TEST 0: Reading memory after initializing module, x0 should --
    -- be 0 and the rest should be uninitialized                   --
    -----------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(0, rs1'length));  -- read x0 value
    wait for clk_period;

    assert ro1 = x"00000000" 
    report "TEST 0 FAILED: x0 value should be 0x00000000"
    severity failure;

    for i in 1 to NREGS/2-1 loop
      rs1 <= std_logic_vector(to_unsigned(i*2-1, rs1'length));  -- read x1, x3, ... , x31 values
      rs2 <= std_logic_vector(to_unsigned(i*2, rs2'length));    -- read x2, x4, ... , x30 values
      wait for clk_period;

      assert ro1 = UNKNOWN
      report "TEST 0 FAILED: should read unknown value in register x" & integer'image(i*2-1)
      severity failure;

      assert ro2 = UNKNOWN
      report "TEST 0 FAILED: should read unknown value in register x" & integer'image(i*2)
      severity failure;
    end loop;

    -----------------------------------------------------------------
    -- TEST 1: Reading memory values after reset, should be 0      --
    -----------------------------------------------------------------
    rst <= '1';  -- reset register values to 0x00000000 asynchronously
    wait for 100 ps;
    rst <= '0';

    for i in 0 to NREGS/2-1 loop
      rs1 <= std_logic_vector(to_unsigned(i*2, rs1'length));   -- read x0, x2, ... , x30 values
      rs2 <= std_logic_vector(to_unsigned(i*2+1, rs2'length)); -- read x1, x3, ... , x31 values
      wait for clk_period;

      assert ro1 = x"00000000"
      report "TEST 1 FAILED: should read value 0x00000000 in register x" & integer'image(i*2)
      severity failure;

      assert ro2 = x"00000000"
      report "TEST 1 FAILED: should read value 0x00000000 in register x" & integer'image(i*2+1)
      severity failure;
    end loop;

    -----------------------------------------------------------------
    -- TEST 2: Inserting 0xCAFECAFE into x1, x2, x3...             --
    -----------------------------------------------------------------
    wren <= '1';
    data <= x"CAFECAFE";

    for i in 1 to NREGS-1 loop
      rd <= std_logic_vector(to_unsigned(i, rd'length)); -- write data value to x1, x2, ... , x31
      wait for clk_period;
    end loop;

    wren <= '0';  -- enable read mode
    data <= x"00000000";

    for i in 1 to NREGS/2-1 loop
      rs1 <= std_logic_vector(to_unsigned(i*2-1, rs1'length)); -- read x1, x3, ... , x31 values
      rs2 <= std_logic_vector(to_unsigned(i*2, rs2'length));   -- read x2, x4, ... , x30 values
      wait for clk_period;

      assert ro1 = x"CAFECAFE"
      report "TEST 2 FAILED: should read value 0xCAFECAFE in register x" & integer'image(i*2-1)
      severity failure;

      assert ro2 = x"CAFECAFE"
      report "TEST 2 FAILED: should read value 0xCAFECAFE in register x" & integer'image(i*2)
      severity failure;
    end loop;

    -----------------------------------------------------------------
    -- TEST 3: Insert 0xFFFFFFFF into x0, should read 0            -- 
    -----------------------------------------------------------------
    wren <= '1';
    data <= x"FFFFFFFF";
    rd <= std_logic_vector(to_unsigned(0, rd'length)); -- write to x0
    wait for clk_period;

    data <= x"00000000";
    wren <= '0';  -- enable read mode
    rs1 <= std_logic_vector(to_unsigned(0, rs1'length)); -- read x0 value
    rs2 <= std_logic_vector(to_unsigned(0, rs2'length)); -- read x0 value
    wait for clk_period;

    assert ro1 = x"00000000" and ro2 = x"00000000"
    report "TEST 3 FAILED: x0 should always be 0x00000000"
    severity failure;

    -----------------------------------------------------------------
    -- TEST 4: Reset values, all indexes should read 0             --
    -----------------------------------------------------------------
    rst <= '1';   -- reset register values to 0x00000000 asynchronously
    wait for 100 ps;
    rst <= '0';

    for i in 0 to NREGS/2-1 loop
      rs1 <= std_logic_vector(to_unsigned(i*2, rs1'length));   -- read x0, x2, ... , x30 values
      rs2 <= std_logic_vector(to_unsigned(i*2+1, rs2'length)); -- read x1, x3, ... , x31 values
      wait for clk_period;

      assert ro1 = x"00000000"
      report "TEST 1 FAILED: should read value 0x00000000 in register x" & integer'image(i*2)
      severity failure;

      assert ro2 = x"00000000"
      report "TEST 1 FAILED: should read value 0x00000000 in register x" & integer'image(i*2+1)
      severity failure;
    end loop;

    report "TEST FINISHED: OK";
    stop_signal <= true;
    wait;
  end process testbench;

end architecture;
