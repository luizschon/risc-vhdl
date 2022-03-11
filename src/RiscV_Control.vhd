-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv.all;

entity RVControl is
  port (
    clk         : in std_logic;
    op          : in std_logic_vector(6 downto 0);
    PCSource    : out std_logic_vector(1 downto 0);
    PCWrite     : out std_logic;
    PCWriteCond : out std_logic;
    WritePCB    : out std_logic;    
    ALUOp       : out std_logic_vector(1 downto 0);
    ALUSrcA     : out std_logic_vector(1 downto 0);
    ALUSrcB     : out std_logic_vector(1 downto 0);
    RegWrite    : out std_logic;
    IRWrite     : out std_logic;
    IorD        : out std_logic_vector(1 downto 0);
    MemRead     : out std_logic;
    MemWrite    : out std_logic;
    MemtoReg    : out std_logic_vector(1 downto 0)
  );
end RVControl;


architecture bhv of RVControl is

  type State is ( s0, s1, s2_MemType, s2_RType, s2_IType, s2_Branch, s2_JAL, s2_JALR, 
                  s2_AUIPC, s2_LUI, s3_Load, s3_Store, s3_RType, s4_Load );
  signal curr_state : State := s0;

begin

  process (clk)
  begin
    if rising_edge(clk) then
      case curr_state is
        -- Instruction fetch
        when s0 =>  
          curr_state  <= s1;
          
        -- Instruction decode / Register fetch
        when s1 => 

          case op is
            when iILType | iSType =>  curr_state <= s2_MemType;
            when iJAL =>              curr_state <= s2_JAL;
            when iJALR =>             curr_state <= s2_JALR;
            when iRtype =>            curr_state <= s2_RType;
            when iAUIPC =>            curr_state <= s2_AUIPC;
            when iLUI =>              curr_state <= s2_LUI;
            when iIType =>            curr_state <= s2_IType;
            when iBType =>            curr_state <= s2_Branch;
            when others =>
          end case;

        -- Memory address computation
        when s2_MemType =>
          if op = iILType then
            curr_state <= s3_Load;
          elsif op = iSType then
            curr_state <= s3_Store;
          end if;

        -- Execution
        when s2_RType => 
          curr_state <= s3_RType;

        -- Execution
        when s2_IType => 
          curr_state <= s3_RType;

        -- Branch completion
        when s2_Branch => 
          curr_state <= s0;

        when s2_JAL => 
          curr_state <= s0;

        when s2_JALR => 
          curr_state <= s0;

        when s2_AUIPC =>
          curr_state <= s3_RType;

        when s2_LUI =>
          curr_state <= s3_RType;

        -- Memory access
        when s3_Load => 
          curr_state <= s4_Load;

        -- Memory access
        when s3_Store => 
          curr_state <= s0;

        -- R-type completion
        when s3_RType => 
          curr_state <= s0;

        -- Memory read completion step
        when s4_Load => 
          curr_state <= s0;

      end case;
    end if;

  end process;

  process (curr_state)
  begin

    case curr_state is 
      -- Instruction fetch
      when s0 =>  
        PCSource    <= "00";  -- asserted 
        PCWrite     <= '1';   -- asserted
        PCWriteCond <= '0';
        WritePCB    <= '1';   -- asserted
        ALUOp       <= "00";  -- asserted
        ALUSrcA     <= "10";  -- asserted
        ALUSrcB     <= "01";  -- asserted
        RegWrite    <= '0';
        IRWrite     <= '1';   -- asserted
        IorD        <= "00";  -- asserted
        MemRead     <= '1';   -- asserted
        MemWrite    <= '0';
        MemtoReg    <= "00";

      -- Instruction decode / Register fetch
      when s1 => 
        PCWrite     <= '0';   -- deassertion
        WritePCB    <= '0';   -- deassertion
        IRWrite     <= '0';   -- deassertion
        MemRead     <= '0';   -- deassertion
        ALUOp       <= "00";  -- asserted
        ALUSrcA     <= "00";  -- asserted
        ALUSrcB     <= "11";  -- asserted

      -- Memory address computation
      when s2_MemType =>
        ALUSrcA     <= "01";  -- asserted
        ALUSrcB     <= "10";  -- asserted
        ALUOp       <= "00";  -- asserted

      -- Execution
      when s2_RType => 
        ALUSrcA     <= "01";  -- asserted
        ALUSrcB     <= "00";  -- asserted
        ALUOp       <= "10";  -- asserted

      when s2_IType => 
        ALUSrcA     <= "01";  -- asserted
        ALUSrcB     <= "10";  -- asserted
        ALUOp       <= "10";  -- asserted

      -- Branch completion
      when s2_Branch => 
        ALUSrcA     <= "01";  -- asserted
        ALUSrcB     <= "00";  -- asserted
        ALUOp       <= "10";  -- asserted
        PCWriteCond <= '1';   -- asserted
        PCSource    <= "01";  -- asserted

      when s2_JAL => 
        ALUSrcA     <= "00";  -- deasserted
        ALUSrcB     <= "00";  -- deasserted
        ALUOp       <= "00";  -- asserted
        PCSource    <= "01";  -- asserted
        PCWrite     <= '1';   -- asserted
        RegWrite    <= '1';   -- asserted
        MemtoReg    <= "01";  -- asserted

      when s2_JALR => 
        ALUSrcA     <= "01";  -- asserted
        ALUSrcB     <= "10";  -- asserted
        ALUOp       <= "00";  -- asserted
        PCSource    <= "00";  -- asserted
        PCWrite     <= '1';   -- asserted
        RegWrite    <= '1';   -- asserted
        MemtoReg    <= "01";  -- asserted

      when s2_AUIPC =>
        ALUSrcA     <= "00";
        ALUSrcB     <= "10";
        ALUOp       <= "00";

      when s2_LUI =>
        ALUSrcA     <= "11";
        ALUSrcB     <= "10";
        ALUOp       <= "00";

      -- Memory access
      when s3_Load => 
        ALUOp       <= "00";  -- deassertion
        ALUSrcA     <= "00";  -- deassertion
        ALUSrcB     <= "00";  -- deassertion
        IorD        <= "01";  -- asserted
        MemRead     <= '1';   -- asserted

      -- Memory access
      when s3_Store => 
        ALUOp       <= "00";  -- deassertion
        ALUSrcA     <= "00";  -- deassertion
        ALUSrcB     <= "00";  -- deassertion
        IorD        <= "01";  -- asserted
        MemWrite    <= '1';   -- asserted

      -- R-type completion
      when s3_RType => 
        ALUOp       <= "00";  -- deassertion
        ALUSrcA     <= "00";  -- deassertion
        ALUSrcB     <= "00";  -- deassertion
        RegWrite    <= '1';   -- asserted
        MemtoReg    <= "00";  -- asserted

      -- Memory read completion step
      when s4_Load => 
        IorD        <= "00";  -- deassertion
        MemRead     <= '0';   -- deassertion
        RegWrite    <= '1';   -- asserted
        MemtoReg    <= "10";  -- asserted

    end case;

  end process;

end bhv;
