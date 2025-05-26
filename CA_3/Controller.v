`timescale 1ns/1ns

`define ADD_OP 3'b000
`define SUB_OP 3'b001
`define AND_OP 3'b010
`define NOT_OP 3'b011
`define PUSH_OP 3'100
`define POP_OP 3'b101
`define JMP_OP 3'110
`define JZ_OP 3'b111



module Controller(clk, rst, op, is_zero,PCWrite,Pop, Push, Tos,AdrSrc, MemWrite, IRwrite, ResultSrc, ALUControl, ALUSrcA, ALUSrcB, StackRegOut, RegWrite, Done);
    input[2:0] opcode;
    input clk,rst,is_zero;

    output reg PCWrite, AdrSrc, MemWrite, IRwrite,ldA,ldB, RegWrite, Pop, Push, Tos,Done;
    output reg [1:0] ResultSrc,ALUSrcA,ALUSrcB;
    output reg [2:0] ALUControl;

    localparam [4:0]
        IF        = 5'd0,
        LDA       = 5'd1,
        LDB       = 5'd2,
        ADD       = 5'd3,
        SUB       = 5'd4,
        AND       = 5'd5,
        NOT       = 5'd6,
        PUSH_RES  = 5'd7,
        JZ1       = 5'd8,
        JZ2       = 5'd9,
        JMP1      = 5'd10,
        JMP2      = 5'd11,
        PUSH1     = 5'd12,
        PUSH2     = 5'd13,
        POP1      = 5'd14,
        POP2      = 5'd15;

    reg [4:0] ps, ns;

    always@(posedge clk, posedge rst) begin
        if(rst) ps <= IF;
        else ps <= ns;
    end

    always@(ps, op, is_zero)begin
        case(ps)

            IF : ns =   (op == ADD_OP | op == SUB_OP | op == AND_OP | op == NOT_OP) ? LDA:
                        (op == JZ_OP)   ? JZ1   :
                        (op == JMP_OP)  ? JMP1  :
                        (op == POP_OP)  ? POP1  :
                        (op == PUSH_OP) ? PUSH1 : IF;
            LDA : ns = (op == NOT_OP) ? NOT: LDB;
            LDB : begin
                if(op == ADD_OP)
                    ns = ADD;
                else if(op ==SUB_OP)
                    ns = SUB
                else if(op == AND_OP)
                    ns = AND
                else
                    ns = LDB
                end
            ADD : ns = PUSH_RES;
            SUB : ns = PUSH_RES;
            AND : ns = PUSH_RES;
            NOT : ns = PUSH_RES;
            PUSH_RES : ns = IF;
            JZ1 : ns = JZ2;
            JZ2 : ns = JMP1;
            JMP1: ns = JMP2;
            JMP2: ns = IF;
            PUSH1:ns = PUSH2;
            PUSH2:ns = IF;
            POP1: ns = POP2;
            POP2: ns = IF;
            default ns = IF;

    endcase
    end
    always@(ps, op, is_zero)begin

        PCWrite =1'b0;
        AdrSrc =1'b0;
        MemWrite =1'b0;
        IRwrite =1'b0;
        StackRegOut=1'b0;
        RegWrite=1'b0;
        Pop=1'b0;
        Push =1'b0;
        Tos =1'b0;
        Done =1'b0;
        ldA = 1'b0;
        ldB = 1'b0;
        ResultSrc = 2'b00;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b00;
        ALUControl = 3'b000;
        case(ps)

            IF :  begin IRwrite =1; ALUSrcA = 2'b00; ALUSrcB = 2'b10; ALUControl = 3'b000; ResultSrc = 2'b10; PCWrite =1; end
            LDA : begin Pop = 1'b1; ldA = 1'b1; end
            LDB : begin Pop = 1'b1; ldB = 1'b1; end
            ADD : begin ALUSrcA = 2'b10; ALUSrcB = 2'b00; ALUControl = 3'b000; end
            SUB : begin ALUSrcA = 2'b10; ALUSrcB = 2'b00; ALUControl = 3'b001; end
            AND : begin ALUSrcA = 2'b10; ALUSrcB = 2'b00; ALUControl = 3'b010;end
            NOT : begin ALUSrcA = 2'b10; ALUSrcB = 2'b00; ALUControl = 3'b011;end
            PUSH_RES : begin ResultSrc =2'b10; Push =1'b1; end
            JZ1 : begin Tos = 1'b1; ldB =1'b1; end
            JZ2 : begin ALUControl = 3'b100; end
            JMP1: begin ALUSrcA = 2'b01; ALUSrcB = 2'b01; ALUControl = 3'b000; end
            JMP2: begin ResultSrc = 2'b10; PCWrite = 1'b1; end
            PUSH1: begin ResultSrc = 2'b11; AdrSrc = 1'b1; end
            PUSH2: begin ResultSrc = 2'b01; Push = 1'b1; end
            POP1: begin Pop = 1'b1; ldB = 1'b1; end
            POP2: begin  MemWrite = 1'b1; ResultSrc = 2'b11; end;
            default Done = 1'b1;

    endcase
    end
endmodule