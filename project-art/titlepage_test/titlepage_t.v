module titlepage_t(CLOCK_50, KEY, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B
);
	input CLOCK_50;
	input [3:0] KEY;
	output VGA_CLK, VGA_HS,	VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	
	//MAIN CIRCUIT VARS
	wire clk, resetn;
	assign clk = CLOCK_50;
	assign resetn = KEY[0];


	//VGA VARS
	wire [7:0] vgaX; //these get sent directly to the VGA
	wire [6:0] vgaY;
	wire [2:0] vgaColour;
	
	//vga
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(vgaColour),
			.x(vgaX),
			.y(vgaY),
			.plot(1),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	wire [14:0] address;
	wire done;
	

	draw d(clk, resetn, 1, address, done, color);
	assign vgaX = address[7:0];
	assign vgaY = address[14:8];
	assign vgaColour = color;
	
endmodule


module draw(
	input clk, reset, enableDraw,
	output [14:0] address,
	output done,
	output [2:0] c_out
);
	
	localparam 	width = 8'd159,
			height = 7'd119,
			x_in = 8'b0,
			y_in = 7'b0;
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg start;
    
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
    		else if (enableDraw && !done_) begin // when start draw and have not done draw yet
    			if (!start) begin 		// initiate starting drawing condition
    				start <= 1;
    				counterX <= 0;
    				counterY <= 0;
    				xOut<=x_in;
    				yOut<=y_in;
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

	wire [2:0] color;
	titlepage t1(
		.address(address),
		.clock(clk),
		.q(color));
		
	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign done = done_;
	assign address = {y_out, x_out};
	assign c_out = color;
	

endmodule
	
	

