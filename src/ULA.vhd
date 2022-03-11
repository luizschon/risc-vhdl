-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv.all;

entity ULARV is
  port (
    ALU_ctrl : in std_logic_vector(3 downto 0);
    A, B     : in std_logic_vector(WORD_SIZE-1 downto 0);
    Z        : out std_logic_vector(WORD_SIZE-1 downto 0);
    cond     : out std_logic
  );
end ULARV;

architecture foo of ULARV is
begin

  process (ALU_ctrl, A, B)
  begin

    case ALU_ctrl is
      when ULA_ADD  => Z <= std_logic_vector(signed(A) + signed(B));
      when ULA_SUB  => Z <= std_logic_vector(signed(A) - signed(B));
      when ULA_AND  => Z <= A and B;
      when ULA_OR   => Z <= A or B;
      when ULA_XOR  => Z <= A xor B;
      when ULA_SLT  => 
        if signed(A) < signed(B) then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;

      when ULA_SLTU =>
        if unsigned(A) < unsigned(B) then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;
        
      when ULA_SGE =>
        if signed(A) >= signed(B) then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;

      when ULA_SGEU =>
        if unsigned(A) >= unsigned(B) then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;

      when ULA_SEQ =>
        if A = B then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;

      when ULA_SNE =>
        if A /= B then
          Z <= x"00000001";
          cond <= '1';
        else
          Z <= (others => '0');
          cond <= '0';
        end if;

      when others =>
    end case;

  end process;

end architecture;
