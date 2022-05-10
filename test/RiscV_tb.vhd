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

entity RiscV_tb is
end entity;

architecture testbench of RiscV_tb is
  component RiscV_multicycle 
    port (
      clk : std_logic;
      rst : std_logic
    );
  end component;

  signal clk, rst : std_logic := '0';
  constant clk_period : time := 1 ns;

begin

  tb_RiscV: RiscV_multicycle port map(clk, rst);

  -- Generate Clock pulses
  process
  begin

    wait for clk_period;
    for i in 0 to 500 loop
      clk <= not clk;
      wait for clk_period/2;
    end loop;

    wait;

  end process;

  process
  begin

    rst <= '1';
    wait for clk_period;

    rst <= '0';

    wait;

  end process;

end testbench;
