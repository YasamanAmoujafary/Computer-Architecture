module MUX2to1(inp0, inp1, sel, out);
	input [7:0] inp0, inp1;
	input sel;
	output [7:0] out;
	assign out = sel == 1'b0 ? inp0 :
		     sel == 1'b1 ? inp1 : 32'bx;
endmodule

module MUX2to1_5Bit(inp0, inp1, sel, out);
	input [4:0] inp0, inp1;
	input sel;
	output [4:0] out;
	assign out = sel == 1'b0 ? inp0 :
		     sel == 1'b1 ? inp1 : 32'bx;
endmodule