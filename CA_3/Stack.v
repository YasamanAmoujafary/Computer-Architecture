`timescale 1ns/1ns

module Stack(clk, rst, Push, Pop, TOS, d_in, out);
    input clk, rst, Push, Pop, TOS;
    input [7:0] d_in;
    output reg [7:0] out;
    reg [7:0] stack_mem [31:0];
    reg [4:0] stack_pointer;

    assign out = (stack_pointer ? stack_mem[stack_pointer - 1] : 8'bx);
    always @(posedge clk, posedge rst)
    begin
        if(rst) stack_pointer = 5'd0;
        else if (Push)begin
            stack_mem[stack_pointer] = d_in;
            stack_pointer = stack_pointer + 1'b1;
        end
        else if (Pop)begin
            if (stack_pointer > 0)
                stack_pointer = stack_pointer - 1;
        end
    end
endmodule
