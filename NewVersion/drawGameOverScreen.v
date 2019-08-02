module drawGameOverScreen(clk, resetn, enableDraw, x_out, y_out, c_out);
	
	input clk, resetn, enableDraw;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	localparam 	width = 8'd160,
			height = 7'd120,
			x_in = 8'b0,
			y_in = 7'b0;
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg start;
    
	// draw logic
	
    	always @(posedge clk)
    	begin
    		if (!resetn) begin //when not draw and reset
    			counterX<=0; // reset counters when not enable
    			counterY<=0;
    			xOut<=0;	// when not drawing, x,y=0, c=0
    			yOut<=0;
    			done_<= 0;
    			start <=0;
    		end
    		else if (enableDraw && !done_) begin // when start draw and have not done draw yet
    			if (!start) begin 		// initiate starting drawing condition
    				start <= 1;
    				counterX <= 0;
    				counterY <= 0;
    				xOut<=x_in;
    				yOut<=y_in;
    			end
    			else if (start && delay_over) begin			// when started to draw
    				if (counterX < width-1) begin counterX <= counterX + 1; end 	// drawing row
    				else if (counterX == width-1) begin		// one row finished, y+1 or not
    					counterX <= 0; 
    					if (counterY < height-1) begin	// new row
    						counterY <= counterY + 1;
    					end
    					else if (counterY == height-1) begin
    						done_ = 1;
    					end
    				end
    			end
    		end
    	end
	
	reg [1:0] count2;
	reg delay_over;
	
	
	always @(posedge clk)
	begin
		if (!start) begin  delay_over <= 0; count2 <= 0; end	// at reset
		else begin
			if (count2 == 0) begin delay_over <=0; count2 <= 2; end	//delay for reset
			else if (count2 == 1) begin delay_over <= 0; count2 <= 2; end// delay for 1 clk
			else if (count2 == 2) begin delay_over <= 1; count2 <= 1; end// draws things
		end
	end

	wire [2:0] color;
	wire [14:0] address;
	gameover o1(
		.address(address),
		.clock(clk),
		.q(color));
    
	
	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign address = y_out*8'd159 + x_out;
	assign c_out = color;
endmodule