module bulletDatapath(clk, inResetState, inUpdatePositionState,
					    pXIn, bulletX, bulletY, topReached);
	
	input clk, inResetState, inUpdatePositionState;
	input [7:0] pXIn;
	output [7:0] bulletX;
	output [6:0] bulletY;
	output reg topReached;
	reg [7:0] xOut;
	reg [6:0] yOut;
	
	always @(posedge clk)
	begin
		if (inResetState) begin xOut <= pXIn; yOut <= 7'd99; topReached <= 0; end
		else if (inUpdatePositionState) begin 
			if (yOut > 8) //7'd119
				yOut <= yOut - 8;
			else begin
				yOut <= 7'd99;
				xOut <= pXIn;
            topReached <= 1;
         end
		end
	end
	
	assign bulletX = xOut;
	assign bulletY = yOut;

endmodule