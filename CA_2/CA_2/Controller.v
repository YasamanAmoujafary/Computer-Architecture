module Controller(op, func3, func7, Zero,PCSrc, ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, RegWrite, done);

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
    input Zero;


    output reg [1:0]PCSrc;
    output reg MemWrite, ALUSrc, RegWrite;
    output reg [1:0] ResultSrc;
    output reg [2:0] ImmSrc;
    output reg[2:0] ALUControl;
    output reg done;

    reg[1:0] aluOp;
    reg jmp,branch;

    wire beq, bne;

    reg jalr_sel, PCSrc_temp;

    assign beq = branch & (func3 == 3'b000);
    assign bne = branch & (func3 == 3'b001);

    assign PCSrc_temp = jmp | (beq & Zero) | (bne & ~Zero);

    assign PCSrc = jalr_sel ? 2'b10: {1'b0, PCSrc_temp};

    assign ALUControl = 
        (aluOp == 2'b00) ? 3'b000 :   //lw,sw,jalr,jal
        (aluOp == 2'b01) ? 3'b001 :   //beq,bne
        (aluOp == 2'b11) ? 3'b100 :   //lui
        (aluOp == 2'b10) ?    //add,sub,or,slt,and,addi,ori,slti
        (func3 == 3'b000) ? ((op == RT & func7 == 7'b0100000) ? 3'b001: 3'b000) :
        (func3 == 3'b111) ? 3'b010 :
        (func3 == 3'b110) ? 3'b011 :
        (func3 == 3'b010) ? 3'b101 : 3'b000 : 3'b000;



    always@(op, func3, func7) begin

        jalr_sel = 1'b0;
        ResultSrc = 2'b0;
        aluOp = 2'b0;
        ImmSrc = 3'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        jmp = 1'b0;
        branch = 1'b0;
        done = 1'b0;

        case(op)
            lw:   begin RegWrite = 1; ALUSrc = 1; ResultSrc = 2'b01; end 
            sw:   begin ImmSrc = 3'b001; ALUSrc = 1; MemWrite = 1; end 
            RT:   begin RegWrite = 1; aluOp = 2'b10; end   //add,sub,and,or,slt
            BT:   begin ImmSrc = 3'b010; branch = 1; aluOp = 2'b01; end //beq,bne
            IT:   begin RegWrite = 1; ALUSrc = 1; aluOp = 2'b10; end   //lw,addi,ori,slti
            jal:  begin RegWrite = 1; ImmSrc = 3'b011; ResultSrc = 2'b10; jmp = 1; end
            jalr: begin RegWrite = 1; ALUSrc = 1;ResultSrc = 2'b10; jalr_sel = 1; end
            lui:  begin RegWrite = 1; ImmSrc = 3'b100; aluOp = 2'b11; end
            default: done = 1;
        endcase

    end

endmodule