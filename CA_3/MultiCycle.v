`timescale 1ns/1ns

module MultiCycle(clk, rst,Done);

    input clk,rst;
    output Done;

    wire[2:0] op;
    wire is_zero;

    wire PCWrite, AdrSrc, MemWrite, IRwrite,ldA,ldB, RegWrite, Pop, Push, Tos;
    wire [1:0] ResultSrc,ALUSrcA,ALUSrcB;
    wire [2:0] ALUControl;


    DataPath Mydp(
    clk, rst, RegWrite, ldA, ldB, PCWrite, AdrSrc, MemWrite, IRwrite, Push, Pop, Tos,
    ResultSrc, ALUSrcA, ALUSrcB,
    ALUControl,
    op, is_zero
    );

    Controller MyController(clk, rst, op, is_zero,PCWrite,Pop, Push, Tos,AdrSrc, MemWrite, IRwrite, ResultSrc, ALUControl, ALUSrcA, ALUSrcB, ldA,ldB, RegWrite, Done);


endmodule