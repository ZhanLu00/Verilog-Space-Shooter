module healthUpdate(clk, resetn, updateHealth, HEX);
	input clk, resetn, updateHealth;
	output [6:0] HEX;
	
	reg [3:0] health;
	
	always @(posedge clk)
	begin
		if (!resetn)
			health <= 4'd10;
		else begin
			if (updateHealth)
				health <= health - 1;
			else
				health <= health;
		end
			
	end

	decoder7 scoreDisplay1(HEX, health[3:0]);
	
endmodule