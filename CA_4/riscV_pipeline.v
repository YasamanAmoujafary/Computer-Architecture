`timescale 1ns/1ns

module Risc_V_Pipeline(clk, rst, done);

    input clk, rst;

    output done;

    wire [6:0] op, func7;
    wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    wire [2:0] ImmSrcD, ALUControlD, func3;
    wire [1:0] ResultSrcD, ForwardAE, ForwardBE;

    wire BeqD, BneD, MemWriteD, ALUSrcD, RegWriteD, JumpSelD, JumpD, PCSrcE, ResultSrcE0, StallF, StallD, FlushD, FlushE, RegWriteM, RegWriteW;

    Hazard_Unit my_hazard_unit(Rs1D, Rs2D, Rs1E, Rs2E, RdE, PCSrcE, ResultSrcE0,RdM, RdW, RegWriteM, RegWriteW, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);

    Datapath my_datapath(clk, rst, RegWriteD, ResultSrcD, MemWriteD, JumpSelD, JumpD, BeqD, BneD,ALUControlD, ALUSrcD, ImmSrcD, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE, 
                op, func3, func7, Rs1D, Rs2D, Rs1E, Rs2E, RdE, PCSrcE, ResultSrcE0, RdM, RdW, RegWriteM, RegWriteW);

    Controller my_controller(op, func3, func7, RegWriteD, ResultSrcD, MemWriteD, JumpSelD, JumpD, BeqD, BneD,ALUControlD, ALUSrcD, ImmSrcD, done);

    


endmodule