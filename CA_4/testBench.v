`timescale 1ns/1ns

module riscV_PL_TB();

    reg clk = 1'b0, rst = 1'b1;

    wire done;
    Risc_V_Pipeline uut(clk, rst, done);
    always #20 clk = ~clk;
	initial begin
        #10 rst = 1'b0;
        #10000 $stop;
    end

endmodule