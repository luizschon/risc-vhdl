-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

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
