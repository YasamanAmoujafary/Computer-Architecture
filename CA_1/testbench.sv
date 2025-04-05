`timescale 1ns/1ns
module int_ratTB ();
	reg Clk=0, Rst=0, Start=0, Run=0;
	wire Done,Fail;
	wire [1:0] Move;
	always  #1 Clk=~Clk;
	IntelligentRat ir(Clk, Rst, Start, Run, Fail, Done, Move);
	initial begin
		#5 Rst=1;
		#5 Rst=0;
		#5 Start=1;
		#10 Start=0;
		#3000 Run=1;
		#100 Run=0;
		#10 $stop;
	end
endmodule
