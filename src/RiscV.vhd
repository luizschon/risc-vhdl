-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

library ieee;
use ieee.std_logic_1164.all;
use work.riscv.all;

entity RiscV_multicycle is
  port (
    clk : in std_logic;
    rst : in std_logic
  );
end RiscV_multicycle;

architecture foo of RiscV_multicycle is

  component Reg is
    port (
      I    : in std_logic_vector(WORD_SIZE-1 downto 0);
      clk  : in std_logic;
      rst  : in std_logic;
      wren : in std_logic;
      Q    : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
  end component;

  component Datapath is
    port (
      clk         : in std_logic;
      rst         : in std_logic;
      PC          : in std_logic_vector(WORD_SIZE-1 downto 0);
      PCSource    : in std_logic_vector(1 downto 0);
      WritePCB    : in std_logic;    
      ALUOp       : in std_logic_vector(1 downto 0);
      ALUSrcA     : in std_logic_vector(1 downto 0);
      ALUSrcB     : in std_logic_vector(1 downto 0);
      RegWrite    : in std_logic;
      IRWrite     : in std_logic;
      IorD        : in std_logic_vector(1 downto 0);
      MemRead     : in std_logic;
      MemWrite    : in std_logic;
      MemtoReg    : in std_logic_vector(1 downto 0);
      ALUCond     : out std_logic;
      PCOut       : out std_logic_vector(WORD_SIZE-1 downto 0);
      op          : out std_logic_vector(6 downto 0)
    );
  end component;

  component RVControl is
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
  end component;

  signal PCRegOut, PCOut : std_logic_vector(WORD_SIZE-1 downto 0);
  signal op : std_logic_vector(6 downto 0);
  signal PCWrite, PCWriteCond, WritePCB, RegWrite, WritePCRes, 
         IRWrite, MemRead, MemWrite, ALUCond : std_logic;
  signal PCSource, IorD, ALUOp, ALUSrcA, 
         ALUSrcB, MemtoReg : std_logic_vector(1 downto 0);

begin

  Control: RVControl 
  port map (
    clk, 
    op, 
    PCSource, 
    PCWrite, 
    PCWriteCond, 
    WritePCB, 
    ALUOp, 
    ALUSrcA, 
    ALUSrcB, 
    RegWrite, 
    IRWrite, 
    IorD, 
    MemRead, 
    MemWrite, 
    MemtoReg
  ); 

  DatapathRV: Datapath
  port map (
    clk,
    rst,
    PCRegOut,
    PCSource,
    WritePCB,
    ALUOp,
    ALUSrcA,
    ALUSrcB,
    RegWrite,
    IRWrite,
    IorD,
    MemRead,
    MemWrite,
    MemtoReg,
    ALUCond,
    PCOut,
    op
  );

  PCReg: Reg 
  port map (
    PCOut, 
    clk, 
    rst, 
    WritePCRes, 
    PCRegOut
  );

  WritePCRes <= (PCWriteCond and ALUCond) or PCWrite;

end architecture;
