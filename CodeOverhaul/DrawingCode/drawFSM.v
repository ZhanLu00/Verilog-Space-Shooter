/*
Draw FSM that controls which object should be currently drawn (ie. which object's coordinates arec counted in drawDisplay and sent to the VGA)

done: whether the object currently being drawn by the display handler has finished being drawn or not
clk: the circuit's clock signal
resetn: reset signal (active low)

mainDrawSignal: binary value representing which object to draw
					0: Player
					1: Enemy 1
					2: Enemy 2
					3: Enemy 3
					4: Enemy 4
					5: Bullet
*/

module drawFSM(done, clk, resetn, mainDrawSignal);
	input done;
	input clk;
	input resetn;
	
	output [3:0] mainDrawSignal;

   reg [3:0] drawSignalOut; //wire to be assigned as the value of the mainDrawSignal
   reg [3:0] current_state, next_state; //registers holding the current and next states, respectively

	 //State constants
    localparam S_DRAW_PLAYER = 4'd0,
               S_DRAW_ENEMY1 = 4'd1,
               S_DRAW_ENEMY2 = 4'd2,
               S_DRAW_ENEMY3 = 4'd3,
               S_DRAW_ENEMY4 = 4'd4,
               S_DRAW_BULLET = 4'd5;

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)           
                S_DRAW_PLAYER: next_state = (done == 1'b1) ? S_DRAW_ENEMY1 : S_DRAW_PLAYER;
                S_DRAW_ENEMY1: next_state = (done == 1'b1) ? S_DRAW_ENEMY2 : S_DRAW_ENEMY1;
                S_DRAW_ENEMY2: next_state = (done == 1'b1) ? S_DRAW_ENEMY3 : S_DRAW_ENEMY2;
                S_DRAW_ENEMY3: next_state = (done == 1'b1) ? S_DRAW_ENEMY4 : S_DRAW_ENEMY3;
                S_DRAW_ENEMY4: next_state = (done == 1'b1) ? S_DRAW_BULLET : S_DRAW_ENEMY4;
                S_DRAW_BULLET: next_state = (done == 1'b1) ? S_DRAW_PLAYER : S_DRAW_BULLET;
            default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; //by default, draw the player

        case (current_state)
            S_DRAW_PLAYER: drawSignalOut <= 4'd0;
            S_DRAW_ENEMY1: drawSignalOut <= 4'd1;
            S_DRAW_ENEMY2: drawSignalOut <= 4'd2;
            S_DRAW_ENEMY3: drawSignalOut <= 4'd3;
            S_DRAW_ENEMY4: drawSignalOut <= 4'd4;
            S_DRAW_BULLET: drawSignalOut <= 4'd5;
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_DRAW_PLAYER;
        end
        else 
            current_state <= next_state;
	
       
    end // state_FFS

    assign mainDrawSignal = drawSignalOut;

endmodule