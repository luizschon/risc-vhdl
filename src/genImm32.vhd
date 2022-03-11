-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília
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
