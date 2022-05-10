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
use work.riscv.WORD_SIZE;

entity Reg is
  port (
    I    : in std_logic_vector(WORD_SIZE-1 downto 0);
    clk  : in std_logic;
    rst  : in std_logic;
    wren : in std_logic;
    Q    : out std_logic_vector(WORD_SIZE-1 downto 0)
  );
end Reg;

architecture bhv of Reg is

  signal Q_temp : std_logic_vector(WORD_SIZE-1 downto 0);

begin

  process (clk, rst)
  begin

    if rst = '1' then
      Q_temp <= (others => '0');
    elsif rising_edge(clk) then
      if wren = '1' then
        Q_temp <= I;
      end if;
    end if;

  end process;

  Q <= Q_temp;

end bhv;
