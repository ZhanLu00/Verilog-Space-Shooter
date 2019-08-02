module updateEnemyColours(clk, resetn, colour1, colour2, colour3, colour4, score);
	input score, clk, resetn;
	output reg [2:0] colour1, colour2, colour3, colour4;	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			colour1 <= 3'b011;
			colour2 <= 3'b010;
			colour3 <= 3'b110;
			colour4 <= 3'b101;
		end
		else  begin
			if (score % 4 == 0) begin colour1 = 3'b011; colour2 = 3'b010; colour3 = 3'b110; colour4 = 3'b101;  end
			else if (score % 4 == 1) begin colour1 = 3'b010; colour2 = 3'b011; colour3 = 3'b101; colour4 = 3'b110; end 
			else if (score % 4 == 2) begin colour1 = 3'b101; colour2 = 3'b110; colour3 = 3'b010; colour4 = 3'b011; end 
			else if (score % 4 ==  3) begin colour1 = 3'b010; colour2 = 3'b011; colour3 = 3'b101; colour4 = 3'b110; end 
			
		end
	
		
	end
	
endmodule