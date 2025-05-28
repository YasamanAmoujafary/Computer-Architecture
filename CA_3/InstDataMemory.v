module InstructionMemory (
    input clk,input rst,
    input reg w_en,
    input reg [4:0] addr,
    input reg [7:0] wdata,
    output reg [7:0] rdata
);

    reg [7:0] memory [0:31];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            $readmemb("inst.mem", memory, 0, 15);
            $readmemb("mem.mem",  memory, 16, 31);
        end
        else if (w_en)
            memory[addr] <= wdata;
    end

    assign rdata = memory[addr];

endmodule