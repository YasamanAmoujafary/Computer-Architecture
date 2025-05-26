module ParamRegister #(
    parameter len = 8
)(
    input clk,
    input rst,
    input en,
    input [len-1:0] in,
    output reg [len-1:0] out
);

    always @(posedge clk, posedge rst) begin
        if (rst)
            out <= {len{1'b0}};
        else if (en)
            out <= in;
        else
            out <= out;
    end

endmodule
