module Controller(op, func3, func7, RegWriteD, ResultSrcD, MemWriteD, JumpSelD, JumpD, BeqD, BneD,ALUControlD, ALUSrcD, ImmSrcD, done);

    localparam lw   = 7'b0000011,
            sw   = 7'b0100011,
            RT   = 7'b0110011,
            BT   = 7'b1100011,
            IT   = 7'b0010011,
            jalr = 7'b1100111,
            jal  = 7'b1101111,
            lui  = 7'b0110111;

    input [6:0] op, func7;
    input [2:0] func3;


    output BeqD, BneD;
    output reg MemWriteD, ALUSrcD, RegWriteD, JumpD, JumpSelD;
    output reg [1:0] ResultSrcD;
    output reg [2:0] ImmSrcD;
    output [2:0] ALUControlD;
    output reg done;
    
    reg[1:0] aluOp;
    reg branch;

    assign BeqD = branch & (func3 == 3'b000);
    assign BneD = branch & (func3 == 3'b001);

    assign ALUControlD = 
        (aluOp == 2'b00) ? 3'b000 :   //lw,sw,jalr,jal
        (aluOp == 2'b01) ? 3'b001 :   //beq,bne
        (aluOp == 2'b11) ? 3'b100 :   //lui
        (aluOp == 2'b10) ?    //add,sub,or,slt,and,addi,ori,slti
        (func3 == 3'b000) ? ((op == RT & func7 == 7'b0100000) ? 3'b001: 3'b000) :
        (func3 == 3'b111) ? 3'b010 :
        (func3 == 3'b110) ? 3'b011 :
        (func3 == 3'b010) ? 3'b101 : 3'b000 : 3'b000;




    always@(op, func3, func7) begin

        ResultSrcD = 2'b00;
        aluOp = 2'b00;
        ImmSrcD = 3'b000;
        MemWriteD = 1'b0;
        ALUSrcD = 1'b0;
        RegWriteD = 1'b0;
        JumpSelD = 1'b0;
        JumpD = 1'b0;
        branch = 1'b0;
        done = 1'b0;

        case(op)
            lw:   begin RegWriteD = 1; ALUSrcD = 1; ResultSrcD = 2'b01; end
            sw:   begin ImmSrcD = 3'b001; ALUSrcD = 1; MemWriteD = 1; end
            RT:   begin RegWriteD = 1; aluOp = 2'b10; end
            BT:   begin ImmSrcD = 3'b010; branch = 1; aluOp = 2'b01; end
            IT:   begin RegWriteD = 1; ALUSrcD = 1; aluOp = 2'b10; end
            jal:  begin RegWriteD = 1; ImmSrcD = 3'b011; ResultSrcD = 2'b10; JumpD = 1; end
            jalr: begin RegWriteD = 1; ALUSrcD = 1; JumpD = 1; JumpSelD = 1; end
            lui:  begin RegWriteD = 1; ImmSrcD = 3'b100; aluOp = 2'b11; end
            default: done = 1;
        endcase

    end

endmodule