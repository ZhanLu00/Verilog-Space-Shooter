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