-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RiscV_tb is
end entity;

architecture testbench of RiscV_tb is
  component RiscV_multicycle 
    port (
      clk : std_logic;
      rst : std_logic
    );
  end component;

  signal clk, rst : std_logic := '0';
  constant clk_period : time := 1 ns;

begin

  tb_RiscV: RiscV_multicycle port map(clk, rst);

  -- Generate Clock pulses
  process
  begin

    wait for clk_period;
    for i in 0 to 500 loop
      clk <= not clk;
      wait for clk_period/2;
    end loop;

    wait;

  end process;

  process
  begin

    rst <= '1';
    wait for clk_period;

    rst <= '0';

    wait;

  end process;

end testbench;
