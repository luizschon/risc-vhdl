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

entity XREGS is
  generic (
    WSIZE : natural := 32;
    NREGS : natural := 32
  );
  port (
    clk, wren, rst : in std_logic;
    rs1, rs2, rd :   in std_logic_vector(4 downto 0);
    data :           in std_logic_vector(WSIZE-1 downto 0);
    ro1, ro2 :       out std_logic_vector(WSIZE-1 downto 0)
  );
end XREGS;

architecture foo of XREGS is

    type reg_word_array is array (0 to NREGS-1) of std_logic_vector(WSIZE-1 downto 0); 
    -- Initialize array as xReg(0) = 0x00000000 and the rest as unknown
    signal xReg : reg_word_array := (0 => (others => '0'), others => (others => 'X'));

begin

  process (clk, rst)
    variable addr : natural;
  begin
    if rst = '1' then
      for i in 0 to NREGS-1 loop
        xReg(i) <= x"00000000";
      end loop;
    end if;

   if rising_edge(clk) then
      if wren = '1' and rst = '0' then
        addr := to_integer(unsigned(rd));

        if addr /= 0 then
          xReg(addr) <= data;
        end if;
      end if;
    end if;
  end process;

  ro1 <= xReg(to_integer(unsigned(rs1)));
  ro2 <= xReg(to_integer(unsigned(rs2)));

end architecture;
