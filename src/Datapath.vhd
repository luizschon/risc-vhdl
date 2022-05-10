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
use work.riscv.all;

entity Datapath is
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
end Datapath;

architecture foo of Datapath is

  component Mem_RV is
    port (
      clk     : in std_logic;
      wren    : in std_logic;
      ren     : in std_logic;
      address : in std_logic_vector(0 to IMEM_ADDR-1);
      datain  : in std_logic_vector(0 to WORD_SIZE-1);
      dataout : out std_logic_vector(0 to WORD_SIZE-1)
    );
  end component;

  component XREGS is
    generic (
      WSIZE : natural := 32;
      NREGS : natural := 32
    );
    port (
      clk, wren, rst : in std_logic;
      rs1, rs2, rd :   in std_logic_vector(4 downto 0);
      data :           in std_logic_vector(WSIZE-1 downto 0);
      ro1, ro2 :       out std_logic_vector(WSIZE-1 downto 0)
    );
  end component;

  component ULARV is
    port (
      ALU_ctrl : in std_logic_vector(3 downto 0);
      A, B   : in std_logic_vector(WORD_SIZE-1 downto 0);
      Z      : out std_logic_vector(WORD_SIZE-1 downto 0);
      cond     : out std_logic
    );
  end component;

  component ALUControl is
    port (
      ALUOp    : in std_logic_vector(1 downto 0);
      instr    : in std_logic_vector(WORD_SIZE-1 downto 0);
      ALU_ctrl : out std_logic_vector(3 downto 0)
    );
  end component;

  component Reg is
    port (
      I    : in std_logic_vector(WORD_SIZE-1 downto 0);
      clk  : in std_logic;
      rst  : in std_logic;
      wren : in std_logic;
      Q    : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
  end component;

  component Mux_4x1 is
    port (
      I0,   
      I1,
      I2,
      I3  : in std_logic_vector(WORD_SIZE-1 downto 0);
      Sel : in std_logic_vector(1 downto 0);
      O   : out std_logic_vector(WORD_SIZE-1 downto 0)
    ); 
  end component;

  component genImm32 is
    generic (
      WSIZE : natural := 32
    );
    port (
      instr :   in  std_logic_vector(WSIZE-1 downto 0);
      imm32 :   out std_logic_vector(WSIZE-1 downto 0)
    );
  end component;

  signal MemData, PCBackOut, IROut, MDROut, imm, Mux0Out, 
         Mux1Out, Mux2Out, Mux3Out, ro1, ro2, DataAddr,
         ARegOut, BRegOut, ALUOut, ALURegOut, ShiftedImm : std_logic_vector(WORD_SIZE-1 downto 0);

  signal ALUCtrlOut : std_logic_vector(3 downto 0);

  signal ReadAddr : std_logic_vector(IMEM_ADDR-1 downto 0);

begin

  op <= IROut(6 downto 0);
  ShiftedImm <= imm(WORD_SIZE-2 downto 0) & '0'; -- Shifts imm to the left by 1
  ReadAddr <= Mux0Out(IMEM_ADDR+1 downto 2);
  DataAddr <= "000" & ALURegOut(WORD_SIZE-1 downto 3);

  dp_PCBack: Reg 
  port map (
    PC, 
    clk,
    rst,
    WritePCB, 
    PCBackOut
  );

  dp_Mux0: Mux_4x1 
  port map (
    PC, 
    ALURegOut,
    ZERO32,
    ZERO32,
    IorD,
    Mux0Out
  );

  dp_Mem: Mem_RV 
  port map (
    clk, 
    MemWrite, 
    MemRead, 
    ReadAddr,
    BRegOut, 
    MemData
  );

  dp_IR: Reg 
  port map (
    MemData, 
    clk, 
    rst, 
    IRWrite, 
    IROut
  );

  dp_MDR: Reg 
  port map (
    MemData, 
    clk, 
    rst, 
    '1', 
    MDROut
  );

  dp_GenImm: genImm32 
  port map (
    IROut, 
    imm
  );

  dp_Mux1: Mux_4x1 
  port map (
    ALURegOut, 
    PC, 
    MDROut, 
    ZERO32,
    MemtoReg, 
    Mux1Out
  );

  dp_XREGS: XREGS 
  port map (
    clk, 
    RegWrite, 
    rst, 
    IROut(19 downto 15), 
    IROut(24 downto 20), 
    IROut(11 downto 7), 
    Mux1Out, 
    ro1, 
    ro2
  );

  dp_AReg: Reg 
  port map (
    ro1, 
    clk, 
    rst, 
    '1', 
    ARegOut
  );
  
  dp_BReg: Reg 
  port map (
    ro2, 
    clk, 
    rst, 
    '1', 
    BRegOut
  );
  
  dp_Mux2: Mux_4x1 
  port map (
    PCBackOut, 
    ARegOut, 
    PC, 
    ZERO32,
    ALUSrcA, 
    Mux2Out
  );

  dp_Mux3: Mux_4x1 
  port map (
    BRegOut, 
    INC_PC, 
    imm, 
    ShiftedImm,
    ALUSrcB, 
    Mux3Out
  );

  dp_ALUCtrl: ALUControl 
  port map (
    ALUOp, 
    IROut,
    ALUCtrlOut
  );

  dp_ALU: ULARV 
  port map (
    ALUCtrlOut, 
    Mux2Out, 
    Mux3Out, 
    ALUOut, 
    ALUCond
  );

  dp_ALUReg: Reg 
  port map (
    ALUOut, 
    clk, 
    rst, 
    '1', 
    ALURegOut
  );

  dp_Mux4: Mux_4x1 
  port map (
    ALUOut, 
    ALURegOut, 
    ZERO32,
    ZERO32,
    PCSource, 
    PCOut
  );

end architecture;
