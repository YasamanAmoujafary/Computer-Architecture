`timescale 1ns/1ns

module Register_4bit(input Clk, our_reset,ld,iz, input[3:0] parrel_load,iz_load,output logic[3:0] out,output logic is_full, is_empty);
    always@(posedge Clk, posedge our_reset) begin
        if(our_reset)
            out <= 4'b0000;
        else if(iz)
            out <= iz_load;
        else if(ld)
            out <= parrel_load;
        else
            out <= out;
    end

    assign is_full = &out;
    assign is_empty = ~(|out);
endmodule

module AddSub(input[3:0] inp, input sel_add, sel_sub, output[3:0] out);
    assign out = sel_add ? (inp + 1) :
                sel_sub  ? (inp - 1) :
                inp;
endmodule

module Deque(input Clk, our_reset,push, pop_back, pop_front, input[1:0] stack_in, output logic[1:0] stack_out, Move, output logic is_deque_empty);

    logic [1:0] deque[255:0];
    logic [7:0] left_pointer, right_pointer;

    always @(posedge Clk or posedge our_reset) begin
        if (our_reset) begin
            left_pointer <= 0;
            right_pointer <= 0;
            is_deque_empty <= 1;
        end
        else if (push) begin   // baraye 255 bayad check konam?
            deque[left_pointer] <= stack_in;
            left_pointer <= left_pointer + 1;
            is_deque_empty <= 0;
        end
        else if (pop_front) begin
            if (left_pointer > right_pointer) begin
                stack_out <= deque[right_pointer];
                right_pointer <= right_pointer + 1;
                if (right_pointer == left_pointer)
                    is_deque_empty <= 1;
            end
        end
        else if (pop_back) begin
            if (left_pointer > right_pointer) begin
                stack_out <= deque[left_pointer - 1];
                left_pointer <= left_pointer - 1;
                if (left_pointer == right_pointer)
                    is_deque_empty <= 1;
            end
        end
    end
    
    assign Move = pop_front ? stack_out : 2'bzz;

endmodule

module DataPath(input Clk, our_reset,ld_X, ld_Y, iz_X, iz_Y, sel_X, sel_Y, sel_add, sel_sub, pX_nX, pY_nY, push, pop_back, pop_front, input[1:0] stack_in,
                output logic[1:0] stack_out,Move, output logic is_deque_empty, is_full_X, is_full_Y, is_empty_X, is_empty_Y, Finish,
                output logic[3:0] X,Y);
    logic[3:0] iz_load_Y = 4'b1111;
    logic[3:0] iz_load_X = 4'b0000;
    logic[3:0] X_out, Y_out;
    logic[3:0] inp_addsub, out_addsub;


    Register_4bit X_reg(Clk, our_reset, ld_X, iz_X, X, iz_load_X ,X_out, is_full_X, is_empty_X);
    Register_4bit Y_reg(Clk, our_reset, ld_Y, iz_Y, Y, iz_load_Y ,Y_out, is_full_Y, is_empty_Y);

    assign inp_addsub = sel_X ? X_out :
                        sel_Y ? Y_out :
                        4'bzzzz;

    AddSub MyAddSub(inp_addsub, sel_add, sel_sub, out_addsub);

    assign X = pX_nX ? out_addsub : X_out;
    assign Y = pY_nY ? out_addsub : Y_out;

    Deque MyDeque(Clk, our_reset,push, pop_back, pop_front, stack_in, stack_out, Move,is_deque_empty);

    assign Finish = is_full_X & is_empty_Y;

endmodule
