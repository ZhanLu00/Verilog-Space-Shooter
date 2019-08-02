module healthUpdate(clk, resetn, updateHealth, HEX, inUpdatePositionStateMain, healthOut, inGameOverState);
	input clk, resetn, updateHealth, inUpdatePositionStateMain, inGameOverState;
	output [6:0] HEX;
	output [3:0] healthOut;
	
	reg [3:0] health;
	
	always @(posedge clk)
	begin
		if (!resetn || inGameOverState)
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
	
	
	assign healthOut = health;
	decoder7 scoreDisplay1(HEX, health[3:0]);
	
endmodule

