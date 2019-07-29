module enemyDatapath(clk, inResetState, inUpdatePositionState,
							enemyXIn, enemyX, enemyY, bottomReached, speed);
	
	input clk, inResetState, inUpdatePositionState;
	input [7:0] enemyXIn;
	input [2:0] speed;
	output [7:0] enemyX;
	output [6:0] enemyY;
	output reg bottomReached;
	reg [7:0] xOut;
	reg [6:0] yOut;
	
	//random number generation
	wire [23:0] g_out, u_out;
	wire [23:0] number;
	LFSRPlus #(.W(24), .V(18), .g_type(1), .u_type(1)) randomNumGenerator(g_out, u_out, clk, n_reset, inResetState);
	assign number = {g_out} % 21; //gets you numbers from 0 to 21 - 1
	
	always @(posedge clk)
	begin
		if (inResetState) begin  
			xOut <= enemyXIn;
			bottomReached <= 0; 
			
			if (number >= 0)
				yOut <= number[6:0];
			else
				yOut <= 7'b0;
		end
		else if (inUpdatePositionState) begin 
			if (yOut + 7'd9 < 7'd119) begin
				yOut <= yOut + speed;
				bottomReached <= 0;
			end
			else begin
				yOut <= 0;
            bottomReached <= 1;
			end
		end
	end
	
	assign enemyX = xOut;
	assign enemyY = yOut;

endmodule