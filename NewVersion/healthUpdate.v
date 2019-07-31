module healthUpdate(clk, resetn, updateHealth, HEX, inUpdatePositionStateMain);
	input clk, resetn, updateHealth, inUpdatePositionStateMain;
	output [6:0] HEX;
	
	reg [3:0] health;
	
	always @(posedge clk)
	begin
		if (!resetn)
			health <= 4'd10;
		else begin
			if (updateHealth && inUpdatePositionStateMain) begin
				if(health > 0)
					health <= health - 1;
				else
					health <= 4'd10;
			end
		end
	end
	
	

	decoder7 scoreDisplay1(HEX, health[3:0]);
	
endmodule

