/*
Module that outputs the coordinates of an object being draw based on the (x, y) of top-left corner and the object's width and height.

x_in: The x coordinate of top-left corner of object being drawn
y_in: The y coordinate of top-left corner of object being drawn
width: The width of the object in binary
height: The height of the object in binary
c_in: The colour to draw the object in
draw: 
clk: Circuit clock signal
reset: Circuit reset signal (active low)

x_out: The x coordinate of the current pixel to draw
y_out: The y coordinate of the current pixel to draw
c_out: The colour of the current pixel to draw 
done: Whether the module is done outputting the coordinates for the current object or not
*/

module draw(
    input [7:0] x_in,
    input [6:0] y_in,
    input [4:0] width, height,
    input [2:0] c_in,
    input draw, clk, reset,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] c_out,
    output done
);
    reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
    reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
    reg done_;						//placeholder for the done output signal

	 //Draw logic
    always @(posedge clk)
    begin
        if (!reset) begin
            xOut <= x_in;
            yOut <= y_in;
            done_ <= 0;
        end
        else if (draw) begin
            if (counterX == (width-1)) begin
                counterX <= 0; 
                counterY <= counterY + 1; end
            else if (counterX < (width-1)) begin
                counterX <= counterX + 1; end

            if (counterY == height) begin
                done_ <= 1'b1; end
        end

    end

	 //assigning wires and registers to their corresponding outputs
    assign x_out = xOut + counterX;
    assign y_out = yOut + counterY;
    assign done = done_;

endmodule