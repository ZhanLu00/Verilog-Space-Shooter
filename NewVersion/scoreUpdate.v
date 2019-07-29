module scoreUpdate(clk, resetn, updateScore, HEX1, HEX2);
	input clk, resetn, updateScore;
	output [6:0] HEX1, HEX2;
	
	reg [7:0] score;
	
	always @(posedge clk)
	begin
		if (!resetn)
			score <= 0;
		else begin
			if (updateScore)
				score <= score + 1;
			else
				score <= score;
		end
			
	end

	decoder7 scoreDisplay1(HEX1, score[3:0]);
	decoder7 scoreDisplay2(HEX2, score[7:4]);
	
endmodule