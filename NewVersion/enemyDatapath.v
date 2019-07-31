module enemyDatapath(clk, inResetState, inUpdatePositionState,
							enemyXIn, enemyX, enemyY, bottomReached, speedIn, speed, resetn, colourIn, colourOut, score);
	
	input clk, inResetState, inUpdatePositionState, resetn;
	input [7:0] enemyXIn;
	output reg [3:0] speed;
	input [3:0] speedIn;
	input [2:0] colourIn;
	output [7:0] enemyX;
	output [6:0] enemyY;
	output reg [2:0] colourOut;
	output reg bottomReached;
	input [7:0] score;
	
	reg [7:0] xOut;
	reg [6:0] yOut;
		
		
	always @(*)
	begin
		case (speedIn < 4'd3)
			1'b1:begin
				case(score >= 8'd100) 
					1'b1: speed = speedIn + 4;
					
					1'b0: begin
						case (score >= 8'd50)
							1'b1: speed = speedIn + 3;
							
							1'b0: begin
								case (score >= 8'd30)
									1'b1: speed = speedIn + 2;
									
									1'b0: begin
										case (score >= 8'd10)
											1'b1: speed = speedIn + 1;
											1'b0: speed = speedIn;
										endcase
									end
								endcase
							end
					
						endcase
					end
		
				endcase
			end
			
			1'b0: begin
						case (speedIn >= 3)
							1'b1:begin
								case(score >= 8'd100) 
									1'b1: speed = speedIn + 2;
					
									1'b0: begin
											case (score >= 8'd50)
												1'b1: speed = speedIn + 2;
							
												1'b0: begin
														case (score >= 8'd30)
															1'b1: speed = speedIn + 1;
									
															1'b0: begin
																case (score >= 8'd10)
																	1'b1: speed = speedIn + 1;
																	1'b0: speed = speedIn;
																endcase
															end
														endcase
												end
					
											endcase
										end
		
								endcase
							end
					
					1'b0: speed = speed;
				endcase
			end
		endcase
		
	end
		
	always @(posedge clk)
	begin
		if (inResetState) begin  
			xOut <= enemyXIn;
			bottomReached <= 0; 
         yOut <= 7'd0;
			colourOut <= 3'b000;
		end
		else begin
			if (inUpdatePositionState) begin 
				if (yOut + 7'd9 < 7'd119) begin
					yOut <= yOut + speed;
					bottomReached <= 0;
				end
				else begin
					yOut <= 0;
					bottomReached <= 1;
				end
			end
			
			colourOut <= colourIn;
		end
	end
	
	assign enemyX = xOut;
	assign enemyY = yOut;

endmodule