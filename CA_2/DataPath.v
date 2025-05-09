module DataPth(clk, rst,PCSrc,ResulSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, Regwrite, Zero, op, func3, func7);
    input clk,rst,MemWrite,ALUSrc, Regwrite;
    input [1:0] PCSrc,ResulSrc;
    input [2:0] ImmSrc, ALUControl;

    output [6:0] op;
    output [6:0] func7;
    output [2:0] func3;
    output Zero;

    wire[31:0] PCNext, PC, Instr, PCPlus4, ImmExt, SrcA, SrcB, WriteData, ALUResult, ReadData, PCTarget, Result;
    wire [4:0] A1,A2,A3;
    wire [24:0] InpExt;

    MUX3to1 PCMUX(PCPlus4, PCTarget, ALUResult, PCSrc, PCNext);
    Register PCRegister(clk, rst, PCNext, PC);
    Instruction_Memory InstructionMemory(PC, Instr);

    assign PCPlus4 = PC + 32'd4;

    assign A1 = Instr[19:15];
    assign A2 = Instr[24:20];
    assign A3 = Instr[11:7];
    assign InpExt = Instr[31:7];

    Register_File RegisterFile(clk, rst, A1, A2, A3, Result, Regwrite, SrcA, WriteData);

    Extend SignExtend(InpExt, ImmSrc, ImmExt);

    MUX2to1 RDSMUX(WriteData, ImmExt, ALUSrc, SrcB);

    ALU MyALU(SrcA, SRCB, ALUControl, ALUResult, Zero);

    assign PCTarget = PC + ImmExt;

    Data_Memory DataMemory(clk, rst, ALUResult, WriteData, MemWrite, ReadData);

    MUX3to1 ResultMUX(ALUResult, ReadData, PCPlus4, ResulSrc, Result);















endmodule