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
use work.memory.all;

entity Mem_RV_tb is
end entity;

architecture sim of Mem_RV_tb is
  component Mem_RV 
    port (
      clk     : in std_logic;
      wren    : in std_logic;
      address : in std_logic_vector(0 to ADDRSIZE-1);
      datain  : in std_logic_vector(0 to WSIZE-1);
      dataout : out std_logic_vector(0 to WSIZE-1)
    );
  end component;

  -- Initializing signal values
  signal wren            : std_logic;
  signal address         : std_logic_vector(0 to ADDRSIZE-1);
  signal datain, dataout : std_logic_vector(0 to WSIZE-1);

  -- Defining and initializing the clock
  signal   clk         : std_logic := '0';
  constant clk_period  : time := 10 ps;
  signal   stop_signal : boolean := false;
  constant expected_mem_data : MemArray := load_mem_file;

begin
  moduleMem_RV: Mem_RV port map(clk, wren, address, datain, dataout);

  -- Generate clock cycles
  Clock_Cycle : process
  begin
      while stop_signal = false loop
          clk <= not clk;
          wait for clk_period / 2;
      end loop;
      wait;
  end process Clock_Cycle;

  -- Testing Mem_RV module
  process
    variable expected_data : std_logic_vector(0 to WSIZE-1);
  begin
    -----------------------------------------------------------------
    -- TEST 1: Read memory from a "mem_dump.txt" file              --
    -----------------------------------------------------------------
    wren <= '0';

    for i in 0 to 10 loop
      address <= std_logic_vector(to_unsigned(i, address'length));
      wait for 10 ps;

      assert dataout = expected_mem_data(i)
      report "TEST 1 FAILED: Expected dataout to be equal expected_mem_data"
      severity failure;
    end loop;

    report "TEST 1 FINISHED";

    -----------------------------------------------------------------
    -- TEST 2: Write to every address and read it right afterwards --
    -----------------------------------------------------------------
    wren <= '1';

    for i in 0 to 2**ADDRSIZE-1 loop
      address <= std_logic_vector(to_unsigned(i, address'length));
      datain <= std_logic_vector(to_unsigned(i, datain'length));
      wait for 10 ps;

      assert dataout = datain
      report "TEST 2 FAILED: Expected dataout equals to datain right after 'write'"
      severity failure;
    end loop;

    report "TEST 2 FINISHED";

    -----------------------------------------------------------------
    -- TEST 3: Read address value inserted in TEST 1               --
    -----------------------------------------------------------------
    wren <= '0';

    for i in 0 to 2**ADDRSIZE-1 loop
      address <= std_logic_vector(to_unsigned(i, address'length));
      expected_data := std_logic_vector(to_unsigned(i, dataout'length));
      wait for 10 ps;

      assert dataout = expected_data
      report "TEST 3 FAILED: Expected dataout to equal the value set on the previous test"
      severity failure;
    end loop;

    report "TEST 3 FINISHED";

    stop_signal <= true;
    wait;
  end process;
end sim;
