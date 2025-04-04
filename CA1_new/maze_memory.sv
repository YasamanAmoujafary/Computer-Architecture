`timescale 1ns/1ns

module MazeMemory(input Clk, our_reset, input[3:0] X,Y, input Din, Rd, Wr, output logic Dout);
	logic[15:0] Maze[0:15];
	logic [0:15]temp;
	initial begin
		$readmemh("maze_map.txt", Maze);
	end
	always@(posedge Clk or posedge our_reset) begin
		if(our_reset)begin
			$readmemh("maze_map.txt", Maze);
			Dout <= 1'bz;
		end
		else if(Wr)begin
			temp = Maze[15-Y];
			temp[X] = Din;
			Maze[15 - Y] = temp;
		end	
	end
	always@(X or Y or Rd) begin
		if(Rd)begin
			temp = Maze[15-Y];
			Dout = temp[X];

		end
		else	
			Dout = 1'bz;
	end
endmodule

