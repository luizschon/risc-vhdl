-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv.WORD_SIZE;

entity Reg_tb is
end Reg_tb;

architecture sim of Reg_tb is

  component Reg
    generic (
      DATA_SIZE : natural
    );
    port (
      I    : in std_logic_vector(WORD_SIZE-1 downto 0);
      clk  : in std_logic;
      rst  : in std_logic;
      wren : in std_logic;
      Q    : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
  end component;

  -- Defining and initializing the clock
  signal clk : std_logic := '0';
  constant clk_period : time := 10 ps;
  signal stop_signal :  boolean := false;

  -- Initializing signal values
  signal wren, rst : std_logic := '0';
  signal I, Q      : std_logic_vector(WORD_SIZE-1 downto 0) := x"00000000";


begin
  moduleReg32: Reg generic map(WORD_SIZE)  
                   port map(I, clk, rst, wren, Q);

  -- Generate clock cycles
  clk_cycle : process
  begin

      while stop_signal = false loop
          clk <= not clk;
          wait for clk_period / 2;
      end loop;
      wait;

  end process clk_cycle;

  -- Testing Reg32 module
  testbench : process
    constant ZERO : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
  begin

    rst <= '1';
    wait for clk_period/2;
    rst <= '0';
    assert Q = ZERO
    report "Q should be zero after reset"
    severity failure;

    I <= x"FFFFFFFF";
    wait for clk_period;
    assert Q = ZERO
    report "Q should be zero since wren = 0"
    severity failure;

    wren <= '1';
    wait for clk_period;
    assert Q = I
    report "Q should be equal to I (0xFFFFFFFF)"
    severity failure;

    wren <= '0';
    wait for clk_period;
    assert Q = I
    report "Q should still be equal to I (0xFFFFFFFF)"
    severity failure;

    wren <= '1';
    I <= x"00000000";
    wait for clk_period;
    assert Q = I
    report "Q should be equal to I (0x00000000)"
    severity failure;

    report "TEST COMPLETED";
    stop_signal <= true;
    wait;

  end process testbench;

end sim;

