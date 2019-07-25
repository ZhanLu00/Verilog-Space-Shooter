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
    input enableLoad, clk, reset,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] c_out,
    output done, input enableDraw
);
    reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
    reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
    reg done_;						//placeholder for the done output signal

	 //Draw logic
    always @(posedge clk)
    begin
		  if ((counterX == 0 && counterY == 0) || enableDraw == 0)
					done_ <= 0;
	 
        if (!reset) begin
		      counterX <= 0;
				counterY <= 0;
            xOut <= x_in;
            yOut <= y_in;
            done_ <= 0;
        end
        else if (enableLoad) begin
				xOut <= x_in;
            yOut <= y_in;
		  end
		  else if (enableDraw) begin	
				
					if (xOut < 8'd180 && xOut >= 8'd0 && yOut <= 7'd127 && yOut >= 7'b0 && done_ == 0) begin //this is needed so that it starts counting at 30 and not 31 for example. Need a delay between loading in the values and starting to count
						if (counterX == width - 1) begin
							counterX <= 0; 
							counterY <= counterY + 1; 
							if (counterY == height - 1) begin
								done_ <= 1'b1; 
								counterY <= 0;
							end
						end
						else if (counterX < width)
							 counterX <= counterX + 1;
					end
		  end
		  
		  else //if the module is not enabled, it cannot be done drawing
				done_ <= 0;
				
				
    end

	 //assigning wires and registers to their corresponding outputs
    assign x_out = xOut + counterX;
    assign y_out = yOut + counterY;
    assign done = done_;
	 assign c_out = c_in;

endmodule