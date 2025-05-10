module ALU(A, B, control, out, Zero);
	input unsigned [31:0] A, B;
	input [2:0] control;

	localparam SUM  = 3'b000,
	           SUB  = 3'b001,
	           AND_ = 3'b010,
	           OR   = 3'b011,
	           SRCB = 3'b100,
	           LT_  = 3'b101;

	output reg unsigned [31:0] out;
	output Zero;

	always @(A , B ,control) begin
		case(control)
			SUM:  out = A + B;
			SUB:  out = A - B;
			AND_: out = A & B;
			OR:   out = A | B;
			SRCB: out = B;
			LT_:  out = (A < B);
			default: out = 32'bx;
		endcase
	end

	assign Zero = ~( |(out) );

endmodule
