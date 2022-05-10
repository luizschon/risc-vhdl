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

entity ULARV_tb is
  generic (
    WSIZE : natural := 32
  );
end entity;

architecture testbench of ULARV_tb is
  component ULARV 
    port (
      opcode : in std_logic_vector(3 downto 0);
      A, B   : in std_logic_vector(WSIZE-1 downto 0);
      Z      : out std_logic_vector(WSIZE-1 downto 0);
      cond   : out std_logic
  );
  end component;

  -- Initializing signal values
  signal opcode  : std_logic_vector(3 downto 0) := "0000";
  signal A, B, Z : std_logic_vector(WSIZE-1 downto 0) := x"00000000";
  signal cond    : std_logic := '0';

begin
  moduleULARV: ULARV port map(opcode, A, B, Z, cond);

  -- Testing ULARV module
  process
    -- Enum type for operations
    type OP_enum is ( ADD_op, SUB_op, AND_op, OR_op, 
                      XOR_op, SLL_op, SRL_op, SRA_op,
                      SLT_op, SLTU_op, SGE_op, SGEU_op, 
                      SEQ_op, SNE_op );
    -- Largest integer value with 32 bits using 2-complements representation
    constant MAX_INT32 : std_logic_vector(WSIZE-1 downto 0) := (31 => '0', others => '1');
    constant MIN_INT32 : std_logic_vector(WSIZE-1 downto 0) := (31 => '1', others => '0');
  begin
    ------------------------------------------
    -- TEST 1: Adding numbers together      --
    ------------------------------------------
    -- Converting the enum position value of 
    -- ADD_op ("0000") to a std_logic_vector of length 4
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(ADD_op), 4));

    A <= std_logic_vector(to_signed(1, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 2 
    report "TEST 1: FAILED (1+1 should be 2)"
    severity failure;

    A <= std_logic_vector(to_signed(100, WSIZE));
    B <= std_logic_vector(to_signed(0, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 100
    report "TEST 1: FAILED (100+0 should be 100)"
    severity failure;

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(-5, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 5
    report "TEST 1: FAILED (10+(-5) should be 5)"
    severity failure;

    A <= MAX_INT32;
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = MIN_INT32 
    report "TEST 1: FAILED (overflow expected when adding the max integer value by 1)"
    severity failure;

    report "TEST 1: OK";

    ------------------------------------------
    -- TEST 2: Subtracting numbers together --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SUB_op), 4));

    A <= std_logic_vector(to_signed(2, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 1 
    report "TEST 2: FAILED (2-1 should be 1)"
    severity failure;

    A <= std_logic_vector(to_signed(100, WSIZE));
    B <= std_logic_vector(to_signed(0, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 100
    report "TEST 2: FAILED (100-0 should be 100)"
    severity failure;

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(-5, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = 15
    report "TEST 2: FAILED (10-(-5) should be 15)"
    severity failure;

    A <= MIN_INT32;
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = MAX_INT32 
    report "TEST 2: FAILED (underflow expected when subtracting the min integer value by 1)"
    severity failure;

    report "TEST 2: OK";

    ------------------------------------------
    -- TEST 3: AND operation                -- 
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(AND_op), 4));

    A <= x"CAFECAFE";
    B <= x"FFFFFFFF";
    wait for 1 ns;

    assert Z = A 
    report "TEST 3: FAILED (0xCAFECAFE and 0xFFFFFFFF should equal 0xCAFECAFE)"
    severity failure;

    A <= x"ABBAABBA";
    B <= x"00000000";
    wait for 1 ns;

    assert Z = B
    report "TEST 3: FAILED (0xABBAABBA and 0x00000000 should equal 0x00000000)"
    severity failure;

    report "TEST 3: OK";
   
    ------------------------------------------
    -- TEST 4: OR operation                 --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(OR_op), 4));

    A <= x"CAFECAFE";
    B <= x"FFFFFFFF";
    wait for 1 ns;

    assert Z = B 
    report "TEST 4: FAILED (0xCAFECAFE or 0xFFFFFFFF should equal 0xFFFFFFFF)"
    severity failure;

    A <= x"ABBAABBA";
    B <= x"00000000";
    wait for 1 ns;

    assert Z = A
    report "TEST 4: FAILED (0xABBAABBA or 0x00000000 should equal 0xABBAABBA)"
    severity failure;

    report "TEST 4: OK";
   
    ------------------------------------------
    -- TEST 5: XOR operation                --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(XOR_op), 4));

    A <= x"CAFECAFE";
    B <= x"FFFFFFFF";
    wait for 1 ns;

    assert Z = not A 
    report "TEST 5: FAILED (0xCAFECAFE xor 0x0000000 should equal 0x35013501 (not 0xCAFECAFE))"
    severity failure;

    A <= x"ABBAABBA";
    B <= x"00000000";
    wait for 1 ns;

    assert Z = A
    report "TEST 5: FAILED (0xABBAABBA xor 0x00000000 should equal 0xABBAABBA)"
    severity failure;

    report "TEST 5: OK";
   
    ------------------------------------------
    -- TEST 6: SLL operation                --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SLL_op), 4));

    A <= x"0000CAFE";
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = to_integer(signed(A))*2
    report "TEST 6: FAILED (0x0000CAFE sll 1 should equal 2*0x0000CAFE)"
    severity failure;

    A <= (30 => '1', others => '0');
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = MIN_INT32
    report "TEST 6: FAILED (0x40000000 sll 1 should equal min integer value (0x80000000)"
    severity failure;

    A <= x"ABBAABBA";
    B <= std_logic_vector(to_signed(WSIZE, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000"
    report "TEST 6: FAILED (0xABBAABBA sll WSIZE should equal 0x00000000)"
    severity failure;

    report "TEST 6: OK";
   
    ------------------------------------------
    -- TEST 7: SRL operation                --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SRL_op), 4));

    A <= x"CAFECAFE";
    B <= std_logic_vector(to_signed(WSIZE/2, WSIZE));
    wait for 1 ns;

    assert Z = x"0000CAFE"
    report "TEST 7: FAILED (0xCAFECAFE srl WSIZE/2 should equal 0x0000CAFE)"
    severity failure;

    A <= std_logic_vector(to_signed(-1, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = MAX_INT32
    report "TEST 7: FAILED (0xFFFFFFFF srl 1 should equal max integer value (0x7FFFFFFF)"
    severity failure;

    A <= x"ABBAABBA";
    B <= std_logic_vector(to_signed(WSIZE, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000"
    report "TEST 7: FAILED (0xABBAABBA srl 32 should equal 0x00000000)"
    severity failure;

    report "TEST 7: OK";

    ------------------------------------------
    -- TEST 8: SRA operation                --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SRA_op), 4));

    A <= (others => '1');
    B <= std_logic_vector(to_signed(WSIZE/2, WSIZE));
    wait for 1 ns;

    assert Z = A
    report "TEST 8: FAILED (0xFFFFFFFF sra WSIZE/2 should equal 0xFFFFFFFF)"
    severity failure;

    A <= MAX_INT32;
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert to_integer(signed(Z)) = to_integer(signed(MAX_INT32))/2
    report "TEST 8: FAILED (max integer (0x7FFFFFFF) srl 1 should equal max integer divided by 2 (0x3FFFFFFF)"
    severity failure;

    A <= MIN_INT32;
    B <= std_logic_vector(to_signed(WSIZE, WSIZE));
    wait for 1 ns;

    assert Z = x"FFFFFFFF"
    report "TEST 8: FAILED (min integer (0x80000000) srl 32 should equal 0xFFFFFFFF (-1))"
    severity failure;

    report "TEST 8: OK";

    ------------------------------------------
    -- TEST 9: SLT operation                --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SLT_op), 4));

    A <= std_logic_vector(to_signed(1, WSIZE));
    B <= std_logic_vector(to_signed(2, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 9: FAILED (Z and cond should equal 1 (1 < 2))"
    severity failure;

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(5, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 9: FAILED (Z and cond should equal 0 (10 not < 5))"
    severity failure;

    A <= std_logic_vector(to_signed(-1, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 9: FAILED (Z and cond should equal 1 (-1 < 1))"
    severity failure;

    report "TEST 9: OK";

    ------------------------------------------
    -- TEST 10: SLTU operation              --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SLTU_op), 4));

    A <= std_logic_vector(to_signed(1, WSIZE));
    B <= std_logic_vector(to_signed(2, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 10: FAILED (Z and cond should equal 1 (1 < 2))"
    severity failure;

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(5, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 10: FAILED (Z and cond should equal 0 (10 not < 5))"
    severity failure;

    A <= std_logic_vector(to_signed(-1, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 10: FAILED (Z and cond should equal 0 (unsigned(-1) not < unsigned(1)))"
    severity failure;

    report "TEST 10: OK";

    ------------------------------------------
    -- TEST 11: SGE operation               --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SGE_op), 4));

    A <= std_logic_vector(to_signed(2, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 11: FAILED (Z and cond should equal 1 (2 >= 1))"
    severity failure;

    A <= std_logic_vector(to_signed(5, WSIZE));
    B <= std_logic_vector(to_signed(10, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 11: FAILED (Z and cond should equal 0 (5 not >= 10))"
    severity failure;

    A <= std_logic_vector(to_signed(100, WSIZE));
    B <= std_logic_vector(to_signed(100, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 11: FAILED (Z and cond should equal 1 (100 >= 100))"
    severity failure;

    A <= std_logic_vector(to_signed(1, WSIZE));
    B <= std_logic_vector(to_signed(-1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 11: FAILED (Z and cond should equal 1 (1 >= -1))"
    severity failure;

    report "TEST 11: OK";

    ------------------------------------------
    -- TEST 12: SGEU operation              --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SGEU_op), 4));

    A <= std_logic_vector(to_signed(2, WSIZE));
    B <= std_logic_vector(to_signed(1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 12: FAILED (Z and cond should equal 1 (2 >= 1))"
    severity failure;

    A <= std_logic_vector(to_signed(5, WSIZE));
    B <= std_logic_vector(to_signed(10, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 12: FAILED (Z and cond should equal 0 (5 not >= 10))"
    severity failure;

    A <= std_logic_vector(to_signed(100, WSIZE));
    B <= std_logic_vector(to_signed(100, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 12: FAILED (Z and cond should equal 1 (100 >= 100))"
    severity failure;

    A <= std_logic_vector(to_signed(1, WSIZE));
    B <= std_logic_vector(to_signed(-1, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 12: FAILED (Z and cond should equal 0 (1 not >= -1))"
    severity failure;

    report "TEST 12: OK";

    ------------------------------------------
    -- TEST 13: SEQ operation               --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SEQ_op), 4));

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(10, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 13: FAILED (Z and cond should equal 1 (10 == 10))"
    severity failure;

    A <= std_logic_vector(to_signed(-5, WSIZE));
    B <= std_logic_vector(to_signed(-5, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 13: FAILED (Z and cond should equal 1 (-5 == -5))"
    severity failure;

    A <= std_logic_vector(to_signed(2, WSIZE));
    B <= std_logic_vector(to_signed(0, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 13: FAILED (Z and cond should equal 0 (2 not == 0))"
    severity failure;

    report "TEST 13: OK";

    ------------------------------------------
    -- TEST 14: SNE operation               --
    ------------------------------------------
    opcode <= std_logic_vector(to_unsigned(OP_enum'POS(SNE_op), 4));

    A <= std_logic_vector(to_signed(10, WSIZE));
    B <= std_logic_vector(to_signed(10, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 14: FAILED (Z and cond should equal 0 (10 not != 10))"
    severity failure;

    A <= std_logic_vector(to_signed(-5, WSIZE));
    B <= std_logic_vector(to_signed(-5, WSIZE));
    wait for 1 ns;

    assert Z = x"00000000" and cond = '0'
    report "TEST 14: FAILED (Z and cond should equal 0 (-5 not != -5))"
    severity failure;

    A <= std_logic_vector(to_signed(2, WSIZE));
    B <= std_logic_vector(to_signed(0, WSIZE));
    wait for 1 ns;

    assert Z = x"00000001" and cond = '1'
    report "TEST 14: FAILED (Z and cond should equal 1 (2 != 0))"
    severity failure;

    report "TEST 14: OK";
    report "TEST COMPLETED";
    wait;

  end process;
end testbench;
