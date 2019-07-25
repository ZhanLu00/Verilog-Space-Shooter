module playData(
	input ld_1, ld_2, ld_3, ld_4,
	input clock, reset, erase, draw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out);

	reg [7:0] xout;
	reg [2:0] cout;
	
    	
	 
	localparam	x1 = 8'd14,
			x2 = 8'd54,
			x3 = 8'd94,
			x4 = 8'd134,
			y  = 7'd99,
			COLOR = 3'b111;

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

	
	assign x_out = xout;
	assign y_out = y;
	assign color_out = cout;

endmodule
