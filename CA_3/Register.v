module Register(clk, rst, en,reg_in, out);
    input clk, rst,en;
    input [7:0] reg_in;
    output reg [7:0] out;

    always @(posedge clk ,posedge rst) begin
        if (rst)
            out = 8'd0;
        else if(en)
            out = reg_in;
        else 
            out = out;
    end

endmodule