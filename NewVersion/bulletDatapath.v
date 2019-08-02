module bulletDatapath(clk, inResetState, inUpdatePositionState, inWaitState,
					    pXIn, bulletX, bulletY, topReached, active);
	
	input clk, inResetState, inUpdatePositionState, inWaitState;
	input [7:0] pXIn;
	output [7:0] bulletX;
	output [6:0] bulletY;
	output reg topReached;
	reg [7:0] xOut;
	reg [6:0] yOut;
	
	output reg active;
	
	always @(posedge clk)
	begin
		if (inResetState) begin xOut <= pXIn; yOut <= 7'd99; topReached <= 0; active <= 0; end
		else if (inUpdatePositionState) begin 
			active <= 1;
		
		
			if (yOut > 8) //7'd119
				yOut <= yOut - 6;
			else begin
				yOut <= 7'd99;
				xOut <= pXIn;
            topReached <= 1;
         end
		end
		else if (inWaitState)
			active <= 1;
	end
	
	assign bulletX = xOut;
	assign bulletY = yOut;

endmodule