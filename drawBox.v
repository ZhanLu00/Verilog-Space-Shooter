module drawBox(xin, yin,reset_N, clk, x_out, y_out);
	input reset_N, clk;
	input [7:0] xin;
	input [6:0] yin;
	//input [2:0] colour;
	
	output [7:0] x_out;
	output [6:0] y_out;
	//output [2:0] colour_out;

	reg [7:0] x;
	reg [6:0] y;
	//reg [2:0] colour_reg;
	reg [3:0] countX;
	reg [3:0] countY;

	//input logic
	always @(posedge clk)
	begin
		if(!reset_N)
		begin
			x <= 8'd14;//previously these were set to 0, so it would draw a pixel at (0, 0) before drawing the box
			y <= 7'd99;
			//colour_reg <= 0;
		end
		else
		begin
			x <= xin;
			y <= yin;
			//colour_reg <= colour;
			
		end
	end

	//counter
	always @(posedge clk)
	begin
		if(!reset_N) begin
			countX <= 0;
			countY <= 0;
		end
		else begin
			if (countX == 4'b1010) begin //(was 153 or something)
				countX <= 0;
				countY <= countY + 1;
			end
			else
				countX <= countX + 1'b1;	
				
			if (countY == 4'b1010)
				countY <= 0;
		end
	end

	assign x_out = x + countX;
	assign y_out = y + countY;
	//assign colour_out = colour_reg;
endmodule