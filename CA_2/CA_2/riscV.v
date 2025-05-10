`timescale 1ns/1ns

module RiscV(clk, rst, done);
    input clk, rst;
    output done;

    wire MemWrite,ALUSrc, Regwrite, Zero;
    wire [1:0] PCSrc,ResultSrc;
    wire [2:0] ImmSrc, ALUControl;

    wire [6:0] op, func7;
    wire [2:0] func3;
   
    DataPth datapath(clk, rst,PCSrc,ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, Regwrite, Zero, op, func3, func7);
    Controller controller(op, func3, func7, Zero,PCSrc, ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, Regwrite, done);
    


endmodule