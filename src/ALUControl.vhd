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
use work.riscv.all;

entity ALUControl is
  port (
    ALUOp    : in std_logic_vector(1 downto 0);
    instr    : in std_logic_vector(WORD_SIZE-1 downto 0);
    ALU_ctrl : out std_logic_vector(3 downto 0)
  );
end ALUControl;

architecture bhv of ALUControl is

  signal OP : std_logic_vector(6 downto 0);
  signal func3 : std_logic_vector(2 downto 0);
  signal func7 : std_logic_vector(6 downto 0);

begin

  OP <= instr(6 downto 0);
  func3 <= instr(14 downto 12);
  func7 <= instr(31 downto 25);

  process (ALUOp, func3, func7)
  begin
    
    case ALUOp is
      when "00" => ALU_ctrl <= ULA_ADD;
      when "01" => ALU_ctrl <= ULA_SUB;
      when "10" =>

      if OP = iBType then
        case func3 is
          when iBEQ3  => ALU_ctrl <= ULA_SEQ;
          when iBNE3  => ALU_ctrl <= ULA_SNE;
          when iBGE3  => ALU_ctrl <= ULA_SGE;
          when iBGEU3 => ALU_ctrl <= ULA_SGEU;
          when iBLT3  => ALU_ctrl <= ULA_SLT;
          when iBLTU3 => ALU_ctrl <= ULA_SLTU;
          when others =>
        end case;
      else
        case func3 is
          when iADDSUB3 =>
            if func7 = iSUB7 then ALU_ctrl <= ULA_SUB;
            else ALU_ctrl <= ULA_ADD;
            end if;
          when iAND3  => ALU_ctrl <= ULA_AND;
          when iOR3   => ALU_ctrl <= ULA_OR;
          when iXOR3  => ALU_ctrl <= ULA_XOR;
          when iSLT3  => ALU_ctrl <= ULA_SLT;
          when others =>
        end case;
      end if;

      when others =>

    end case;

  end process;

end bhv;
