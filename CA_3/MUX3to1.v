module MUX3to1(inp0, inp1, inp2, sel, out);
	input [7:0] inp0, inp1, inp2;
	input [1:0] sel;
	output [7:0] out;
	assign out = sel == 2'b00 ? inp0 :
		    sel == 2'b01 ? inp1 :
		    sel == 2'b10 ? inp2 : 32'bx;
endmodule