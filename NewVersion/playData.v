module playData(
	input clock, reset, inInputState, inUpdatePositionState, inSetAState, inSetDState, 
	output [7:0] x_out,
	output [6:0] y_out,
	input keyboardAPressed, keyboardDPressed);

	reg [7:0] xout; //register holding the current x coordinate of top left corner of the player. To be assigned to x_out
	reg aPressed, dPressed;
	
   reg buttonPressed;	
	 
	localparam	x1 = 8'd14, //position 1
					x2 = 8'd54, //position 2
					x3 = 8'd94, //position 3
					x4 = 8'd134, //position 4
					y  = 7'd99; //y stays constant
	
	//logic for switching position and colour based on current state
	always @(posedge clock)
	begin
		if (!reset) begin xout <= x1; aPressed <= 0; dPressed <= 0; buttonPressed <= 0; end // default for reset,  c =1, x = x1
		else if (inSetAState) begin aPressed <= 1; dPressed <= 0; end
		else if (inSetDState) begin aPressed <= 0; dPressed <= 1;  end
		else if (inInputState) begin xout <= xout;  end
		
		else if (inUpdatePositionState) begin
			if (aPressed && !buttonPressed) begin
				if (xout == x1) xout <= x1;
				else if (xout == x2) xout <= x1;
				else if (xout == x3) xout <= x2;
				else if (xout == x4) xout <= x3;
				aPressed <= 0;
				buttonPressed <= 1;
			end
			
			if (dPressed && !buttonPressed) begin
				if (xout == x1) xout <= x2;
				else if (xout == x2) xout <= x3;
				else if (xout == x3) xout <= x4;
				else if (xout == x4) xout <= x4;
				dPressed <= 0;
				buttonPressed <= 1;
			end
		end
		
		if (keyboardAPressed == 1'b0 && keyboardDPressed == 1'b0) begin buttonPressed <= 0; aPressed <= 0; dPressed <= 0; end
	end

	//assigning outputs
	assign x_out = xout;
	assign y_out = y;

endmodule