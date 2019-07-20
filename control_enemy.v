module control_enemy(
	input go, clk, reset_N,hold,done,
	output reg reset_C, en_XY, en_de, erase, plot
	);

	// draw -> erase ->update -> keep going
	
	reg [2:0] current_state, next_state;

	localparam START = 3'd0,
			   START_WAIT = 3'd1,
			   DRAW = 3'd2,
			   DELAY = 3'd3,
			   ERASE = 3'd4,
			   UPDATE_XY= 3'd5;

	always @(*)
	begin : enemy_statetable
		case (current_state)
			START: next_state = go? START_WAIT: START; 
			START_WAIT: next_state = go? START_WAIT: DRAW;
			DRAW: next_state = done? DELAY : DRAW; 
			DELAY: next_state = hold? ERASE: DELAY;
			ERASE: next_state = done? UPDATE_XY: ERASE;
			UPDATE_XY: next_state = DRAW;
		endcase	
	end
	
	// set proper output for current state
	always @(*)
	begin
		reset_C = 0;
		en_XY = 0;
		en_de = 0;
		erase = 0;
		plot = 0;
		case (current_state)
			DRAW: plot = 1;
			DELAY: begin reset_C = 1; en_de = 1; end
			ERASE: begin erase = 1; plot = 1; end
			UPDATE_XY: en_XY = 1;	
		endcase	
	end	

	always @(posedge clk)
	begin
		if (!reset_N)
			current_state <= START;
		else
			current_state <= next_state;
	end

endmodule