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
use work.riscv.all;

entity genImm32 is
  generic (
    WSIZE : natural := 32
  );
  port (
    instr :   in  std_logic_vector(WSIZE-1 downto 0);
    imm32 :   out std_logic_vector(WSIZE-1 downto 0)
  );
end genImm32;

architecture bhv of genImm32 is
  
  signal imm32_temp : signed(WSIZE-1 downto 0);

begin

  process (instr)

    -- Using 8 bits opcode instead of 7 for easy comparition with a x"XX" type number
    variable OPCODE :  std_logic_vector(6 downto 0);
    constant ZERO :  std_logic_vector(31 downto 0) := (others => '0');

  begin
    OPCODE := instr(6 downto 0);

    case OPCODE is
      when iRType => 
        imm32_temp <= ( others => '0' );
      when iILType|iItype => 
        imm32_temp <= resize(signed( instr(31 downto 20) ), WSIZE);
      when iJALR => 
        imm32_temp <= resize(signed( instr(31 downto 21) & '0' ), WSIZE);
      when iSType => 
        imm32_temp <= resize(signed( instr(31 downto 25) & 
                                instr(11 downto 7) ), 
                        WSIZE);
      when iBType => 
        imm32_temp <= resize(signed( instr(31) & 
                                instr(7) & 
                                instr(30 downto 25) & 
                                instr(11 downto 8) ), 
                        WSIZE);
      when iJAL => 
        imm32_temp <= resize(signed( instr(31) & 
                                instr(19 downto 12) &
                                instr(20) &
                                instr(30 downto 25) &
                                instr(24 downto 21) ),
                        WSIZE);
      when iLUI|iAUIPC => 
        imm32_temp <= signed(instr(31 downto 12) & ZERO(11 downto 0));
      when others => 
    end case;

  end process;

  imm32 <= std_logic_vector(imm32_temp);

end architecture;
