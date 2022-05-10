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

entity Mux_4x1_tb is
end Mux_4x1_tb;

architecture tb of Mux_4x1_tb is

  component Mux_4x1
    port (
      I0,   
      I1,
      I2,
      I3  : in std_logic_vector(WORD_SIZE-1 downto 0);
      Sel : in std_logic_vector(1 downto 0);
      O   : out std_logic_vector(WORD_SIZE-1 downto 0)
    ); 
  end component;

  signal T_I0, T_I1, T_I2, T_I3, T_O : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
  signal T_Sel : std_logic_vector(1 downto 0) := "00";

begin

  uMux: Mux_4x1 port map (T_I0, T_I1, T_I2, T_I3, T_Sel, T_O);
	
  process							
  begin								
			 	
    T_I0 <= (0 => '1', others => '0');  -- 0x00000001
    T_I1 <= (1 => '1', others => '0');	-- 0x00000002	
    T_I2 <= (2 => '1', others => '0');  -- 0x00000004
    T_I3 <= (3 => '1', others => '0');	-- 0x00000008
      
    -- case select equal "00"
    wait for 10 ns;	
    T_Sel <= "00";	
    wait for 1 ns;
    assert T_O = T_I0 report "Error Case 0" severity error;
      
    -- case select equal "01"
    wait for 10 ns;
    T_Sel <= "01";	  
    wait for 1 ns;
    assert T_O = T_I1 report "Error Case 1" severity error;
      
    -- case select equal "10"
    wait for 10 ns;
    T_Sel <= "10";	  
    wait for 1 ns;
    assert T_O = T_I2 report "Error Case 2" severity error;
       
    -- case select equal "11"
    wait for 10 ns;
    T_Sel <= "11";	  
    wait for 1 ns;
    assert T_O = T_I3 report "Error Case 3" severity error;
        
    report "TEST COMPLETED";
    wait;
  end process;

end tb;

