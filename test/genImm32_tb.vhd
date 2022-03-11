-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use STD.textio.all;

entity genImm32_tb is
end genImm32_tb;

architecture testbench of genImm32_tb is 
  component genImm32
    port (
          instr :   in std_logic_vector(31 downto 0);
          imm32 :   out signed(31 downto 0)
         );
  end component;

  signal instr :  std_logic_vector(31 downto 0);
  signal imm32 :  signed(31 downto 0);

begin
  genImm: genImm32 port map(instr => instr, imm32 => imm32);
  
  process
  variable my_line : LINE;
  begin
    instr <= x"000002B3"; -- add t0, zero, zero
    wait for 1 ns;
    if (to_integer(imm32) = 0) then
      write(my_line, string'("Test 1 passed"));
    else
      write(my_line, string'("Test 1 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"01002283"; -- lw t0, 16(zero)
    wait for 1 ns;
    if (to_integer(imm32) = 16) then
      write(my_line, string'("Test 2 passed"));
    else
      write(my_line, string'("Test 2 failed"));
    end if;
    writeline(output, my_line);
 
    instr <= x"F9C00313"; -- addi t1, zero, -100
    wait for 1 ns;
    if (to_integer(imm32) = -100) then
      write(my_line, string'("Test 3 passed"));
    else
      write(my_line, string'("Test 3 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"FFF2C293"; -- xori t0, t0, -1
    wait for 1 ns;
    if (to_integer(imm32) = -1) then
      write(my_line, string'("Test 4 passed"));
    else
      write(my_line, string'("Test 4 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"16200313"; -- addi t1, zero, 354
    wait for 1 ns;
    if (to_integer(imm32) = 354) then
      write(my_line, string'("Test 5 passed"));
    else
      write(my_line, string'("Test 5 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"01800067"; -- jalr zero, zero, 0x18
    wait for 1 ns;
    if (to_integer(imm32) = 24) then
      write(my_line, string'("Test 6 passed"));
    else
      write(my_line, string'("Test 6 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"00002437"; -- lui s0, 2
    wait for 1 ns;
    if (to_integer(imm32) = 8192) then
      write(my_line, string'("Test 7 passed"));
    else
      write(my_line, string'("Test 7 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"02542E23"; -- sw t0, 60(s0)
    wait for 1 ns;
    if (to_integer(imm32) = 60) then
      write(my_line, string'("Test 8 passed"));
    else
      write(my_line, string'("Test 8 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"FE5290E3"; -- bne t0, t0, main
    wait for 1 ns;
    if (to_integer(imm32) = -32) then
      write(my_line, string'("Test 9 passed"));
    else
      write(my_line, string'("Test 9 failed"));
    end if;
    writeline(output, my_line);

    instr <= x"00C000EF"; -- jal rot
    wait for 1 ns;
    if (to_integer(imm32) = 12) then
      write(my_line, string'("Test 10 passed"));
    else
      write(my_line, string'("Test 10 failed"));
    end if;
    writeline(output, my_line);

    writeline(output, my_line);
    write(my_line, string'("Test finished"));
    writeline(output, my_line);
    wait;
  end process;
end architecture;
