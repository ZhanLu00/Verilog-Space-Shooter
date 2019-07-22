module enemyTest(clock, resetn, go);
	input clock, resetn, go;
	
	wire resetC, enXY, enDE, erase, plot;
	wire hold, done;
	control_enemy e1(go, clock, resetn, hold, done, resetC, enXY, enDE, erase, plot);
	
	wire [7:0] xOut;
	wire [6:0] yOut;
	wire [2:0] colourOut;
	
	
	
	datapath_enemy d1(resetC, resetn, clock, enDE, enXY, erase, plot, 8'd14, 7'd0, 3'b111, xOut, yOut, colourOut, hold, done);



endmodule


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

module datapath_enemy(
	input reset_C, reset_N, clk, enable_delay, enable_XY, erase, plot,
	input [7:0] xIn,
	input [6:0] yIn,
	input [2:0] colour,
	
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] colour_out,

	output reg  hold, done
	);
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] colour_reg;
	reg down;
	reg [19:0] delay_count;
	reg [7:0] frame; 
	reg bottom_reached;
	
	reg [4:0] countX, countY;

	
	//XY counter logic
	always @(posedge clk)
	begin
	
		if(!reset_N || bottom_reached)
		begin
			x <= xIn;
			y <= 7'b0;
			down <= 1'b1;
			bottom_reached <= 0;
		end
		else if (enable_XY)
		begin
			if(down) begin
				y <= y + 1;
				// when enemy touches the bottom
				if (y_out > 8'd111) begin
					bottom_reached <= 1;	
					down <= 0;
				end
					//y <= yIn;
			end
			
		end
	end

	//delay&frame counter
	always @(posedge clk)
	begin
		if (!reset_N || !reset_C) begin
			delay_count <= 0;
			frame <= 0;
			hold <= 0;
		end
		else if (enable_delay) begin
			if (delay_count == 10'd2) begin //should be 833333
				delay_count <= 0;
				frame <= frame + 1;
			end
			else
				delay_count <= delay_count + 1;

			if (frame == 4'b1111) //should be 1111 in bin
				hold <= 1;		
			end					
	end
	
	always @(posedge clk)
	begin
		if(!reset_N)
			colour_reg <= 0;
		else 
			if (erase)
				colour_reg <= 0;
			else
				colour_reg <= colour;
			
	end

	//counter
	always @(posedge clk)
	begin
		if(!reset_N) begin
			countX <= 0;
			countY <= 0;
			done <= 0;
		end
		else if (!plot) begin
			countX <= 0;
			countY <= 0;
			done <= 0;		
		end
		
		else if (countX == 4'b1001) begin //(4'b1001 == 10)
				countX <= 0;
				countY <= countY + 1;
		end
		else if (countX < 4'b1001)
				countX <= countX + 1'b1;	
		if (countY == 4'b1001) begin
			countY <= 0;
			done <= 1;
		end
	end

	assign x_out = x;
	assign y_out = y;
	assign colour_out = colour_reg;

endmodule