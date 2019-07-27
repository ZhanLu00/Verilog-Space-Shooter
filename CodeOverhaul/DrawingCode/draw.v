/*
Module that outputs the coordinates of an object being draw based on the (x, y) of top-left corner and the object's width and height.

x_in: The x coordinate of top-left corner of object being drawn
y_in: The y coordinate of top-left corner of object being drawn
width: The width of the object in binary
height: The height of the object in binary
c_in: The colour to draw the object in
enableLoad: Controls whether this module will load in new starting coordinates in preparation for drawing a new object
clk: Circuit clock signal
reset: Circuit reset signal (active low)

x_out: The x coordinate of the current pixel to draw
y_out: The y coordinate of the current pixel to draw
c_out: The colour of the current pixel to draw 
done: Whether the module is done outputting the coordinates for the current object or not

enableDraw: controls when this module should enable its counters and when not
*/

module draw(
	input [7:0] x_in,
	input [6:0] y_in,
	input [4:0] width, height,
	input [2:0] c_in,
	input clk, reset, enableDraw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] c_out,
	output done
);
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg [2:0] color;		//reg for color
	reg start;
    
	// draw logic

    	always @(posedge clk)
    	begin
    		if (!enableDraw || !reset) begin //when not draw and reset
    			counterX<=0; // reset counters when not enable
    			counterY<=0;
    			xOut<=0;	// when not drawing, x,y=0, c=0
    			yOut<=0;
    			color<= 3'b0;// when not drawing, current pixel = background color
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
    				color <= c_in;
    			end
    			else if (start) begin			// when started to draw
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


	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign done = done_;
	assign c_out = color;

endmodule
