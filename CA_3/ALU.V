`timescale 1ns/1ns


module ALU(
    input [2:0] ALUcontrol,
    input [7:0]SrcA,
    input [7:0]SrcB,
    output zero,
    output reg [7:0]ALUResult);

    localparam [2:0] ADD_OP    = 3'b000;
    localparam [2:0] SUB_OP    = 3'b001;
    localparam [2:0] AND_OP    = 3'b010;
    localparam [2:0] NOT_OP    = 3'b011;
    localparam [2:0] ISZERO_OP = 3'b100;


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