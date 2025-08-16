module Datapath (clk, rst, RegWriteD, ResultSrcD, MemWriteD, JumpSelD, JumpD, BeqD, BneD,ALUControlD, ALUSrcD, ImmSrcD, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE, 
                op, func3, func7, Rs1D, Rs2D, Rs1E, Rs2E, RdE, PCSrcE, ResultSrcE0, RdM, RdW, RegWriteM, RegWriteW);
    
    input clk, rst, RegWriteD, MemWriteD, JumpSelD, JumpD, BeqD, BneD, ALUSrcD, StallF, StallD, FlushD, FlushE;
    input [1:0] ResultSrcD, ForwardAE, ForwardBE;
    input [2:0] ALUControlD, ImmSrcD;

    output PCSrcE, ResultSrcE0, RegWriteM, RegWriteW;
    output [6:0] op;
    output [2:0] func3;
    output [6:0] func7;
    output [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;

    wire [31:0] PCFPrime, PCPLus4F, PCF, InstrF;

    wire [1:0] ResultSrcW;
    wire [31:0] ALUResultW, ReadDataW, PCPlus4W, ResultW;

    wire [4:0] RdD;
    wire [31:0] InstrD, PCD, PCPLus4D, Rd1D, Rd2D, PCPlus4D, ExtImmD;

    wire MemWriteM;
    wire [1:0] ResultSrcM;
    wire [31:0] ALUResultM, WriteDataM, PCPlus4M, ReadDataM;

    wire RegWriteE, MemWriteE, JumpSelE, JumpE, BeqE, BneE, ALUSrcE, ZeroE;
    wire [1:0] ResultSrcE;
    wire [2:0] ALUControlE, ImmSrcE;
    wire [4:0] Rs1E, Rs2E;
    wire [31:0] Rd1E, Rd2E, PCE, ExtImmE, PCPlus4E, srcAE, srcBE, WriteDataE, ALUResultE, PCTargetE, PCPlusImmE;


    assign op = InstrD[6:0];
    assign func3 = InstrD[14:12];
    assign func7 = InstrD[31:25];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];
    assign PCSrcE = JumpE | (BeqE & ZeroE) | (BneE & ~ZeroE) | (BltE & LTE) | (BgeE & ~LTE);
    assign ResultSrcE0 = ResultSrcE[0];

    MUX2to1 PC_sel_MUX(PCPLus4F, PCTargetE, PCSrcE, PCFPrime);

    PC_Register PC_reg(clk, rst, StallF, PCFPrime, PCF);
    Instruction_Memory Instruction_Mem(PCF, InstrF);
    assign PCPLus4F = PCF + 32'd4;


    PipeLine_Register_FD my_reg_FD(clk, rst, StallD, FlushD, InstrF, PCF, PCPLus4F, InstrD, PCD, PCPlus4D);
    Register_File reg_file(clk, rst, Rs1D, Rs2D, RdW, ResultW, RegWriteW, Rd1D, Rd2D);
    Extend extend(InstrD[31:7], ImmSrcD, ExtImmD);

    Register_DE my_reg_DE(clk, rst, FlushE, RegWriteD, ResultSrcD, MemWriteD, JumpSelD, JumpD, BeqD, BneD,
                                    ALUControlD, ALUSrcD, ImmSrcD, Rd1D, Rd2D, PCD, Rs1D, Rs2D, RdD, ExtImmD, PCPlus4D,
                                    RegWriteE, ResultSrcE, MemWriteE, JumpSelE, JumpE, BeqE, BneE,ALUControlE,
                                    ALUSrcE, ImmSrcE, Rd1E, Rd2E, PCE, Rs1E, Rs2E, RdE, ExtImmE, PCPlus4E);
    
    MUX3to1 ALU_sel_MUX_A(Rd1E, ResultW, ALUResultM, ForwardAE, srcAE);
    MUX3to1 Data_Mem_Sel_MUX(Rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
    MUX2to1 ALU_sel_MUX_B(WriteDataE, ExtImmE, ALUSrcE, srcBE);
    ALU my_alu(srcAE, srcBE, ALUControlE, ALUResultE, ZeroE);
    assign PCPlusImmE = PCE + ExtImmE;
    MUX2to1 PC_JUMP_Sel_MUX(PCPlusImmE, ALUResultE, JumpSelE, PCTargetE);


    Register_MW my_reg_MW(clk, rst, RegWriteM, ResultSrcM, ALUResultM, ReadDataM, RdM, PCPlus4M,
                                    RegWriteW, ResultSrcW, ALUResultW, ReadDataW, RdW, PCPlus4W);
    MUX3to1 MUX_write_sel(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);


    Register_EM my_reg_EM(clk, rst, RegWriteE, ResultSrcE, MemWriteE, ALUResultE, WriteDataE, RdE, PCPlus4E,
                                    RegWriteM, ResultSrcM, MemWriteM, ALUResultM, WriteDataM, RdM, PCPlus4M);
    Data_Memory my_data_mem(clk, rst, ALUResultM, WriteDataM, MemWriteM, ReadDataM);

    

endmodule