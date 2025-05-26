`timescale 1ns/1ns

typedef enum logic [2:0] {ADD_OP, SUB_OP, AND_OP, NOT_OP, ISZERO_OP} ALUOP;
module ALU(
    input [2:0] ALUcontrol,
    input [7:0]SrcA,
    input [7:0]SrcB,
    output zero,
    output reg [7:0]ALUResult);

    always@(ALUcontrol, SrcA, SrcB) begin
        case(ALUcontrol)
            ADD_OP: ALUResult = SrcA + SrcB;
            SUB_OP: ALUResult = SrcA - SrcB;
            AND_OP: ALUResult = SrcA & SrcB;
            NOT_OP:  ALUResult = ~SrcA;
            ISZERO_OP: ALUResult = SrcA == 0;
        endcase
    end
    assign zero = (ALUResult == 0) ? 1:0;


endmodule