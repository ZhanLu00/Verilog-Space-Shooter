/*
Draw FSM that controls which object should be currently drawn (ie. which object's coordinates arec counted in drawDisplay and sent to the VGA)

done: whether the object currently being drawn by the display handler has finished being drawn or not
clk: the circuit's clock signal
resetn: reset signal (active low)

mainDrawSignal: binary value representing which object to draw
					1: Player
					2: Enemy 1
					3: Enemy 2
					4: Enemy 3
					5: Enemy 4
					6: Bullet
enableDraw: whether the VGA should have its plot on or off
enableLoad: controls whether the displayHandler should be loading in new starting coordinates or not
*/

module drawFSM(done, clk, resetn, mainDrawSignal, enableDraw, enableLoad);
	input done;
	input clk;
	input resetn;
	output enableDraw;
	output enableLoad;
	
	output [3:0] mainDrawSignal;

   reg [3:0] drawSignalOut; //wire to be assigned as the value of the mainDrawSignal
   reg [3:0] current_state, next_state; //registers holding the current and next states, respectively
	reg [3:0] state_after_wait;
	reg [1:0] delayCounter;
	reg enableDrawOut;
	reg enableLoadOut;
	
	 //State constants
    localparam S_DRAW_PLAYER = 4'd0,
               S_DRAW_ENEMY1 = 4'd1,
               S_DRAW_ENEMY2 = 4'd2,
               S_DRAW_ENEMY3 = 4'd3,
               S_DRAW_ENEMY4 = 4'd4,
               S_DRAW_BULLET = 4'd5,
					S_LOAD_WAIT = 4'd6,
					S_DRAW_WAIT = 4'd7;

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)           
                S_DRAW_PLAYER: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_PLAYER;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY1 : S_DRAW_WAIT;
					 end
					 
                S_DRAW_ENEMY1: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY1;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY2 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY2: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY2;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY3 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY3: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY3;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY4 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY4: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY4;
						state_after_wait = (done == 1'b1) ? S_DRAW_BULLET : S_DRAW_WAIT;
                end
					 
					 S_DRAW_BULLET: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_BULLET;
						state_after_wait = (done == 1'b1) ? S_DRAW_PLAYER : S_DRAW_WAIT;
					 end
					 
					 S_LOAD_WAIT: begin
						next_state = (delayCounter == 2'b11) ? S_DRAW_PLAYER : S_LOAD_WAIT;
					 end
					 
					 S_DRAW_WAIT: begin
						next_state = state_after_wait;
					 end
				default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; //by default, draw the player
		  enableDrawOut <= 1'b0;
		  //enableLoadOut <= 1'b0;
		  
        case (current_state)
				S_LOAD_WAIT: begin drawSignalOut <= 4'd0; enableDrawOut <= 0;  enableLoadOut = 1'b1; end
            S_DRAW_PLAYER: begin drawSignalOut <= 4'd1; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY1: begin drawSignalOut <= 4'd2; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY2: begin drawSignalOut <= 4'd3; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY3: begin drawSignalOut <= 4'd4; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY4: begin drawSignalOut <= 4'd5; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_BULLET: begin drawSignalOut <= 4'd6; enableDrawOut <= 1; enableLoadOut = 1'b0; end
				S_DRAW_WAIT: begin 
					enableDrawOut <= 0;  
					enableLoadOut = 1'b1; 
					
					case (state_after_wait)
						S_DRAW_PLAYER: drawSignalOut <= 4'd1;
						S_DRAW_ENEMY1: drawSignalOut <= 4'd2;
						S_DRAW_ENEMY2: drawSignalOut <= 4'd3;
						S_DRAW_ENEMY3: drawSignalOut <= 4'd4;
						S_DRAW_ENEMY4: drawSignalOut <= 4'd5;
						S_DRAW_BULLET: drawSignalOut <= 4'd6;
					endcase
					
					
				end
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_LOAD_WAIT;
				delayCounter <= 2'b0;
				state_after_wait <= S_DRAW_PLAYER;
        end
        else 
            current_state <= next_state;
		  if (delayCounter < 2'b11)
			delayCounter <= delayCounter + 1;
       
    end // state_FFS

    assign mainDrawSignal = drawSignalOut;
	 assign enableDraw = enableDrawOut;
	 assign enableLoad = enableLoadOut;
endmodule