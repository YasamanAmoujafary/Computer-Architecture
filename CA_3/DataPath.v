`timescale 1ns/1ns

module DataPath(
    input clk, rst, RegWrite, LoadA, LoadB, PCWrite, AdrSrc, MemWrite, IRWrite, Push, Pop, Tos,
    input [1:0] ResultSrc, ALUSrcA, ALUSrcB,
    input  [2:0] ALUControl,
    output [2:0] op,
    output Zero
    );

    wire [4:0] Adr, PCNext;
    wire [7:0] WriteData, ReadData, OldPC, Instr, Data, StackOut, A, SrcA, SrcB, ALUResult, AluOut, Result;

    assign PCNext = Result[0:4];
    ParamRegister #(5) my_pc_register (clk, rst, PCWrite, PCNext, PC);
    MUX2to1_5Bit my_MUX2to1_5Bit(PC, PCNext, AdrSrc, Adr);
    InstructionMemory my_InstructionMemory(clk, MemWrite, Adr, WriteData, ReadData);
    ParamRegister #(8) my_clk_register (clk, rst, IRWrite, {3'b000, PC}, OldPC);
    ParamRegister #(8) my_instr_register (clk, rst, IRWrite, ReadData, Instr);
    ParamRegister #(8) my_data_register (clk, rst, IRWrite, 1'b1, Data);
    Stack8x32 my_stack(clk, rst, Push, Pop, TOS, Result, StackOut);
    ParamRegister #(8) my_A_reg(clk, rst, LoadA, StackOut, A);
    ParamRegister #(8) my_B_reg(clk, rst, LoadB, StackOut, WriteData);
    MUX3to1 my_A_mux({3'b000, PC}, OldPC, A, ALUSrcA, SrcA);
    MUX3to1 my_B_mux(WriteData, {3'b000, Instr[0:4]}, 8'b11111111, ALUSrcB, SrcB);
    ALU my_ALU(ALUControl, SrcA, SrcB, Zero, ALUResult);
    ParamRegister #(8) my_alu_register(clk, rst, 1'b1, ALUResult, AluOut);
    MUX4to1 my_MUX4to1(AluOut, Data, ALUResult, {3'b000, Instr[0:4]}, ResultSrc, Result);

endmodule