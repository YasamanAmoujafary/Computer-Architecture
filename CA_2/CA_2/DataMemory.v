module Data_Memory(clk, rst, A, WD, WE, RD);
    input clk, rst;
    input unsigned [31:0] A, WD;
    input WE;
    output unsigned [31:0] RD;

    reg unsigned [31:0] DataMem[15999:0];

	assign RD = DataMem[A>>2];

	always @(posedge clk ,posedge rst) begin
        if (rst)
            $readmemh("DataMem.txt", DataMem);

		else if (WE) 
            DataMem[A>>2] = WD;

	end


endmodule
