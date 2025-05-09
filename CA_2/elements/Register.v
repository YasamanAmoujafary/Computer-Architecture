module Register(clk, rst, reg_in, out);
    input clk, rst;
    input [31:0] reg_in;
    output reg [31:0] out;

    always @(posedge clk ,posedge rst) begin
        if (rst)
            out = 32'd0;
        else 
            out = reg_in;
    end

endmodule