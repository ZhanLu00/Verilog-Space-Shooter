module erase(
	input clk, reset, enableDraw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] c_out,
	output done,
	input inEraseStateMain
);
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg [2:0] color;		//reg for color
	reg start;

    localparam width = 8'd159,
              height = 7'd119;
	// draw logic

    	always @(posedge clk)
    	begin
    		if (!enableDraw || !reset) begin //when not draw and reset
    			counterX<=0; // reset counters when not enable
    			counterY<=0;
    			xOut<=0;	// when not drawing, x,y=0, c=0
    			yOut<=0;
    			done_<= 0;
    			start <=0;
    		end
    		else if (enableDraw && !done_ && inEraseStateMain) begin // when start draw and have not done draw yet
    			if (!start) begin 		// initiate starting drawing condition
    				start <= 1;
    				counterX <= 0;
    				counterY <= 0;
    				xOut<=0;
    				yOut<=0;
    			end
    			else if (start) begin			// when started to draw
    				if (counterX < width) begin counterX <= counterX + 1; end 	// drawing row
    				else if (counterX == width) begin		// one row finished, y+1 or not
    					counterX <= 0; 
    					if (counterY < height) begin	// new row
    						counterY <= counterY + 1;
    					end
    					else if (counterY == height) begin
    						done_ = 1;
    					end
    				end
    			end
    		end
    	end


	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign done = done_;
	assign c_out = 3'b0;

endmodule