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

entity Mux_4x1 is
  port (
    I0,   
    I1,
    I2,
    I3  : in std_logic_vector(WORD_SIZE-1 downto 0);
    Sel : in std_logic_vector(1 downto 0);
    O   : out std_logic_vector(WORD_SIZE-1 downto 0)
  ); 
end Mux_4x1;

architecture bhv of Mux_4x1 is
begin

  process (I0,I1,I2,I3,Sel)
  begin

    case Sel is 
      when "00" => O <= I0;
      when "01" => O <= I1;
      when "10" => O <= I2;
      when "11" => O <= I3;
      when others =>
    end case;

  end process;

end bhv;
