
`timescale 1ns/1ns

module Controller (input Clk,Start,Rst,Run, input[1:0] stack_out, input is_deque_empty, is_full_X, is_full_Y, is_empty_X, is_empty_Y, is_wall, Finish,
                    output logic our_reset, push, pop_back, pop_front, ld_X, ld_Y, iz_X, iz_Y, sel_X, sel_Y, sel_add, sel_sub, pX_nX, pY_nY, Rd, Wr,
                    output logic Fail, Done, Din, output logic[1:0] dir);




    typedef enum logic[4:0] {Resetting, Idle, Starting,
                            Up, Handle_up, Push_up, Right, Handle_right, Push_right,
                            Left, Handle_left, Push_left, Down, Handle_down, Push_down,
                            Backtracking,Pop_stack, Pop_up, Pop_right, Pop_left, Pop_down, Wait_for_finish, Win, Lose,
                            Set_start_pos, Show_path, Wait_for_Rst} STATE;
    STATE ps,ns;


    always@(posedge Clk, posedge Rst) begin
        if(Rst) ps <= Resetting;
        else ps <= ns;
    end

    always@(ps, Start, is_full_Y, is_full_X, Finish, is_wall, is_empty_X, is_empty_Y, Run, Rst, is_deque_empty, stack_out)begin
        case(ps)
            Resetting : ns = Idle;
            Idle : ns = Start ? Starting : Idle;
            Starting : ns = Start ? Starting : Up;
            Up : ns = is_full_Y ? Right : Handle_up;
            Handle_up : ns = is_wall ? Right : Push_up;
            Push_up : ns = Wait_for_finish;
            Right : ns = is_full_X ? Left : Handle_right;
            Handle_right : ns = is_wall ? Left : Push_right;
            Push_right : ns = Wait_for_finish;
            Left : ns = is_empty_X ? Down : Handle_left;
            Handle_left : ns = is_wall ? Down : Push_left;
            Push_left : ns = Wait_for_finish;
            Down : ns = is_empty_Y ? Backtracking : Handle_down;
            Handle_down : ns = is_wall ? Backtracking : Push_down;
            Push_down : ns = Wait_for_finish;
            Backtracking : ns = Pop_stack;
            Pop_stack : ns = (stack_out == 2'b00) ? Pop_up:
                                (stack_out == 2'b01) ? Pop_right:
                                (stack_out == 2'b10) ? Pop_left:
                                (stack_out == 2'b11) ? Pop_down:
                                is_deque_empty ? Lose:
                                Backtracking;
            Pop_up   : ns = Up;
            Pop_right: ns = Up;
            Pop_left : ns = Up;
            Pop_down : ns = Up;
            Wait_for_finish : ns = Finish ? Win : Up;
            Win : ns = Run ? Set_start_pos : Win;
            Set_start_pos : ns = Show_path;
            Show_path : ns = is_deque_empty ? Wait_for_Rst : Show_path;
            Wait_for_Rst : ns = Rst ? Resetting : Wait_for_Rst;
            Lose : ns = Wait_for_Rst;
            default ns = Resetting;

        endcase
    end

    always@(ps) begin
        {our_reset, iz_Y, iz_X, ld_X, ld_Y, sel_Y, sel_X, sel_add, sel_sub, pY_nY, pX_nX, Rd, Wr, Din, push, Done, Fail, pop_back, pop_front} = 19'b0;
        case(ps)
            Resetting : our_reset = 1;
            Idle : begin iz_X = 1;iz_Y = 1;Wr = 1; Din = 1;end

            Up : begin sel_Y = 1; sel_add = 1; pY_nY = 1;end
            Handle_up : begin sel_Y = 1; sel_add = 1; pY_nY = 1; Rd = 1;end
            Push_up : begin sel_Y = 1; sel_add = 1; pY_nY = 1; dir = 2'b00; Wr = 1; Din = 1; push = 1; ld_X = 1; ld_Y = 1;end

            Right : begin sel_X = 1; sel_add = 1; pX_nX = 1;end
            Handle_right : begin sel_X = 1; sel_add = 1; pX_nX = 1; Rd = 1;end
            Push_right : begin sel_X = 1; sel_add = 1; pX_nX = 1; dir = 2'b01; Wr = 1; Din = 1; push = 1; ld_X = 1; ld_Y = 1;end

            Left : begin sel_X = 1; sel_sub = 1; pX_nX = 1;end
            Handle_left : begin sel_X = 1; sel_sub = 1; pX_nX = 1; Rd = 1;end
            Push_left : begin sel_X = 1; sel_sub = 1; pX_nX = 1; dir = 2'b10; Wr = 1; Din = 1; push = 1; ld_X = 1; ld_Y = 1;end

            Down : begin sel_Y = 1; sel_sub = 1; pY_nY = 1;end
            Handle_down : begin sel_Y = 1; sel_sub = 1; pY_nY = 1; Rd = 1;end
            Push_down : begin sel_Y = 1; sel_sub = 1; pY_nY = 1; dir = 2'b11; Wr = 1; Din = 1; push = 1; ld_X = 1; ld_Y = 1;end

            Backtracking : pop_back = 1;

            Pop_up : begin sel_Y = 1; sel_sub = 1; pY_nY = 1; ld_X = 1; ld_Y = 1; end
            Pop_right : begin sel_X = 1; sel_sub = 1; pX_nX = 1; ld_X = 1; ld_Y = 1; end
            Pop_left : begin sel_X = 1; sel_add = 1; pX_nX = 1; ld_X = 1; ld_Y = 1; end
            Pop_down : begin sel_Y = 1; sel_add = 1; pY_nY = 1; ld_X = 1; ld_Y = 1; end

            Win : Done = 1;
            Lose : Fail = 1;

            Set_start_pos : begin iz_X = 1;iz_Y = 1;end

            Show_path : pop_front = 1;
        endcase
    end

endmodule

