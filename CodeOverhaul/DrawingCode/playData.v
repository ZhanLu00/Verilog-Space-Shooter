/*
Module that controls the position and colour of the player.

ld_1: Signal that controls whether player top-left corner coordinates should be changed to position 1
ld_2: Signal that controls whether player top-left corner coordinates should be changed to position 2
ld_3: Signal that controls whether player top-left corner coordinates should be changed to position 3
ld_4: Signal that controls whether player top-left corner coordinates should be changed to position 4
clock: main circuit clock signal
reset: reset signal (active low)
erase: Signal that controls whether the player colour should be changed to black
draw: Signal that controls whether the player colour should be changed to white

x_out: wire? holding the x coordinate of the top left corner of the player
y_out: wire? holding the y coordinate of the top left corner of the player
colour_out: wire? holding the colour that the player should be drawn in on the screen
*/

module playData(
	input ld_1, ld_2, ld_3, ld_4,
	input clock, reset, erase, draw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out);

	reg [7:0] xout; //register holding the current x coordinate of top left corner of the player. To be assigned to x_out
	reg [2:0] cout; //register holding the current colour of the player. To be assigned to colour_out.
	
    	
	 
	localparam	x1 = 8'd14, //position 1
					x2 = 8'd54, //position 2
					x3 = 8'd94, //position 3
					x4 = 8'd134, //position 4
					y  = 7'd99, //y stays constant
					COLOR = 3'b111; //default colour is white
	
	//logic for switching position and colour based on current state
	always @(posedge clock)
	begin
		if (!reset) begin cout <= COLOR; xout <= x1; end // default for reset,  c =1, x = x1
		else if (erase) begin cout <= 3'b0; xout <= xout; end // erase: color = 0, x = the last stored position
		else if (draw) begin 
			if (ld_1) begin xout <= x1; cout <= COLOR; end
			if (ld_2) begin xout <= x2; cout <= COLOR; end
			if (ld_3) begin xout <= x3; cout <= COLOR; end
			if (ld_4) begin xout <= x4; cout <= COLOR; end
			
		end

	end

	//assigning outputs
	assign x_out = xout;
	assign y_out = y;
	assign color_out = cout;

endmodule
