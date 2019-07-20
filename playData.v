module playData(
	input ld_1, ld_2, ld_3, ld_4,
	input clock, reset, erase, draw,
	input [2:0] color_in,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out);

	reg [7:0] xout;
   //reg [6:0] yout;
	reg [2:0] cout;
	wire [7:0] boxX;
	wire [6:0] boxY;
	
    assign color_out = cout;
	 
	localparam	x1 = 8'd14,
				x2 = 8'd54,
				x3 = 8'd94,
				x4 = 8'd134,
				y  = 7'd99,
				COLOR = 3'b111;

	always @(posedge clock)
	begin
		if (erase || !reset) begin cout <= 3'b000; xout <= x1; end
		else begin 
			//if (draw) begin
				if (ld_1) begin xout <= x1; cout <= COLOR; end
				if (ld_2) begin xout <= x2; cout <= COLOR; end
				if (ld_3) begin xout <= x3; cout <= COLOR; end
				if (ld_4) begin xout <= x4; cout <= COLOR; end
			//end
		end
	end


	drawBox p(
		.xin(xout),
		.yin(y),
		.reset_N(reset),
		.clk(clock),
		.x_out(boxX),
		.y_out(boxY)
				
	);
	
	assign x_out = boxX;
	assign y_out = boxY;

endmodule