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
use work.riscv.all;

entity Mem_RV is
  port (
    clk     : in std_logic;
    wren    : in std_logic;
    ren     : in std_logic;
    address : in std_logic_vector(0 to IMEM_ADDR-1);
    datain  : in std_logic_vector(0 to WORD_SIZE-1);
    dataout : out std_logic_vector(0 to WORD_SIZE-1)
  );
end Mem_RV;

architecture behav of Mem_RV is
  
  signal mem : MemArray := load_mem_file;
  signal read_address : std_logic_vector(0 to ADDRSIZE-1) := (others => '0');

begin
  Write_mem: process (clk)
  begin
    if rising_edge(clk) then
      if (wren = '1') then
        mem(to_integer(unsigned(address))) <= datain;
      end if;
    end if;
  end process Write_mem;

  process (ren, address)
  begin
    if ren = '1' then
      read_address <= address;
    end if;
  end process;

  dataout <= mem(to_integer(unsigned(read_address)));
  
end architecture;
