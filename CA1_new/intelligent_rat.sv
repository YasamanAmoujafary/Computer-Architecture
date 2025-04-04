`timescale  1ns/1ns

module IntelligentRat(input Clk,Rst,Start,Run,output Fail,Done,output[1:0] Move);

    wire[3:0] X,Y;
    logic Din,Dout,Rd,Wr;

    wire[1:0] stack_out,stack_in;
    wire is_deque_empty, is_full_X, is_full_Y, is_empty_X, is_empty_Y,is_wall, Finish;

    wire pY_nY, pX_nX, sel_sub, sel_add, sel_Y, sel_X, iz_Y, iz_X, ld_Y, ld_X, pop_back, pop_front, push;

    wire our_reset;

    wire[1:0] dir;

    assign  is_wall = Dout ? 1 :0;
    assign stack_in = dir;

    Controller MyController(Clk,Start,Rst,Run,stack_out,is_deque_empty, is_full_X, is_full_Y, is_empty_X, is_empty_Y, is_wall, Finish,
                    our_reset, push, pop_back, pop_front, ld_X, ld_Y, iz_X, iz_Y, sel_X, sel_Y, sel_add, sel_sub, pX_nX, pY_nY, Rd, Wr,
                    Fail, Done, Din, dir);

    DataPath MyDataPath(Clk, our_reset,ld_X, ld_Y, iz_X, iz_Y, sel_X, sel_Y, sel_add, sel_sub, pX_nX, pY_nY, push, pop_back, pop_front, stack_in,
                stack_out,Move, is_deque_empty, is_full_X, is_full_Y, is_empty_X, is_empty_Y, Finish,
                X,Y);

    MazeMemory MyMazeMemory(Clk, our_reset,X,Y,Din, Rd, Wr,Dout);

endmodule





