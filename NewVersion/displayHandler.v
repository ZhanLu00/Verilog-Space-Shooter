module displayHandler(
    input [7:0] playerXIn, enemyXIn1, enemyXIn2, enemyXIn3, enemyXIn4, bulletXIn,
    input [6:0] playerYIn, enemyYIn1, enemyYIn2, enemyYIn3, enemyYIn4, bulletYIn,
    input [4:0] playerWidthIn, playerHeightIn, enemyWidthIn, enemyHeightIn, bulletWidth, bulletHeight,
    input [2:0] playerColourIn, enemyColourIn1, enemyColourIn2, enemyColourIn3, enemyColourIn4, bulletColour,
    input clk, resetn,
    input [3:0] control_signal,
    output [7:0] drawX,
	 output [6:0] drawY,
	 output [2:0] drawColour,
	 output [4:0] drawWidth, drawHeight,
	 output reg pe_collision1, pe_collision2, pe_collision3,pe_collision4,
	 output reg be_collision1, be_collision2, be_collision3, be_collision4,
	 input activeB,
	 input [4:0] enemyHealthWidthM1, enemyHealthWidthC1, enemyHealthWidthM2, enemyHealthWidthC2, enemyHealthWidthM3, enemyHealthWidthC3, enemyHealthWidthM4, enemyHealthWidthC4,
	 input [2:0] currHealthCol1, currHealthCol2, currHealthCol3, currHealthCol4, maxHealthCol1,  maxHealthCol2,  maxHealthCol3, maxHealthCol4
);
	 reg [7:0] drawXOut;
	 reg [6:0] drawYOut;
	 reg [2:0] drawColourOut;
	 reg [4:0] drawWidthOut, drawHeightOut;
	
    // choose output by controller
    // 1: player, 2:e1
    always @(*)
    begin 
        case (control_signal)
		      //0: begin drawXOut <= 8'd0; drawYOut <= 7'd0; drawWidthOut <= 5'd0; drawHeightOut <= 5'd0; drawColourOut <= 3'd0; end
            1: begin drawXOut <= playerXIn; drawYOut <= playerYIn; drawWidthOut <= playerWidthIn; drawHeightOut <= playerHeightIn; drawColourOut <= playerColourIn; end
				2: begin drawXOut <= enemyXIn1; drawYOut <= enemyYIn1; drawWidthOut <= enemyWidthIn; drawHeightOut <= enemyHeightIn; drawColourOut <= enemyColourIn1; end
				3: begin drawXOut <= enemyXIn2; drawYOut <= enemyYIn2; drawWidthOut <= enemyWidthIn; drawHeightOut <= enemyHeightIn; drawColourOut <= enemyColourIn2;end
				4: begin drawXOut <= enemyXIn3; drawYOut <= enemyYIn3; drawWidthOut <= enemyWidthIn; drawHeightOut <= enemyHeightIn; drawColourOut <= enemyColourIn3;end
				5: begin drawXOut <= enemyXIn4; drawYOut <= enemyYIn4; drawWidthOut <= enemyWidthIn; drawHeightOut <= enemyHeightIn; drawColourOut <= enemyColourIn4;end
				6: begin drawXOut <= bulletXIn; drawYOut <= bulletYIn; drawWidthOut <= bulletWidth; drawHeightOut <= bulletHeight; drawColourOut <= bulletColour;end
				7: begin drawXOut <= enemyXIn1; drawYOut <= (enemyYIn1 + 7'd11); drawWidthOut <= (enemyHealthWidthM1 * 3); drawHeightOut <= 5'd1; drawColourOut <= maxHealthCol1; end
				8: begin drawXOut <= enemyXIn1; drawYOut <= (enemyYIn1 + 7'd11); drawWidthOut <= (enemyHealthWidthC1 * 3); drawHeightOut <= 5'd1; drawColourOut <= currHealthCol1; end
				9: begin drawXOut <= enemyXIn2; drawYOut <= (enemyYIn2 + 7'd11); drawWidthOut <= (enemyHealthWidthM2 * 3); drawHeightOut <= 5'd1; drawColourOut <= maxHealthCol2; end
				10: begin drawXOut <= enemyXIn2; drawYOut <= (enemyYIn2 + 7'd11); drawWidthOut <= (enemyHealthWidthC2 * 3); drawHeightOut <= 5'd1; drawColourOut <= currHealthCol2; end
				11: begin drawXOut <= enemyXIn3; drawYOut <= (enemyYIn3 + 7'd11); drawWidthOut <= (enemyHealthWidthM3 * 3); drawHeightOut <= 5'd1; drawColourOut <= maxHealthCol3; end
				12: begin drawXOut <= enemyXIn3; drawYOut <= (enemyYIn3 + 7'd11); drawWidthOut <= (enemyHealthWidthC3 * 3); drawHeightOut <= 5'd1; drawColourOut <= currHealthCol3; end
				13: begin drawXOut <= enemyXIn4; drawYOut <= (enemyYIn4 + 7'd11); drawWidthOut <= (enemyHealthWidthM4 * 3); drawHeightOut <= 5'd1; drawColourOut <= maxHealthCol4; end
				14: begin drawXOut <= enemyXIn4; drawYOut <= (enemyYIn4 + 7'd11); drawWidthOut <= (enemyHealthWidthC4 * 3); drawHeightOut <= 5'd1; drawColourOut <= currHealthCol4; end
				default: begin drawXOut <= playerXIn; drawYOut <= playerYIn; drawWidthOut <= playerWidthIn; drawHeightOut <= playerHeightIn; drawColourOut <= playerColourIn;end
        endcase
    end
	 
	 //collision checks
	 always @(posedge clk)
	 begin
		//enemy vs. player
		if ((enemyXIn1 + enemyWidthIn) >= playerXIn && (enemyXIn1 + enemyWidthIn) <= (playerXIn + playerWidthIn) && (enemyYIn1 + enemyHeightIn) > playerYIn
	        && (enemyYIn1 + enemyHeightIn) < (playerYIn + playerHeightIn))
			  
			pe_collision1 <= 1;
		else pe_collision1 <= 0;
		
		if ((enemyXIn2 + enemyWidthIn) >= playerXIn && (enemyXIn2 + enemyWidthIn) <= (playerXIn + playerWidthIn) && (enemyYIn2 + enemyHeightIn) > playerYIn
	        && (enemyYIn2 + enemyHeightIn) < (playerYIn + playerHeightIn))
			  
			pe_collision2 <= 1;
		else pe_collision2 <= 0;
		
		if ((enemyXIn3 + enemyWidthIn) >= playerXIn && (enemyXIn3 + enemyWidthIn) <= (playerXIn + playerWidthIn) && (enemyYIn3 + enemyHeightIn) > playerYIn
		    && (enemyYIn3 + enemyHeightIn) < (playerYIn + playerHeightIn))
			 
			pe_collision3 <= 1;
		else pe_collision3 <= 0;
		
		if ((enemyXIn4 + + enemyWidthIn) >= playerXIn && (enemyXIn4 + enemyWidthIn) <= (playerXIn + playerWidthIn) && (enemyYIn4 + enemyHeightIn) > playerYIn
		    && (enemyYIn4 + enemyHeightIn) < (playerYIn + playerHeightIn))
			 
			pe_collision4 <= 1;
		else pe_collision4 <= 0;
		
		
	 end
	 	 	 
	 //collision checks
	 always @(posedge clk)
	 begin
		//enemy vs. bullet
		if (activeB && (bulletXIn + bulletWidth) >= enemyXIn1 && (bulletXIn + bulletWidth) <= (enemyXIn1 + enemyWidthIn) && (bulletYIn + bulletHeight) >= enemyYIn1
		    && (bulletYIn + bulletHeight) <= (enemyYIn1 + enemyHeightIn))
			 
			be_collision1 <= 1;
		else be_collision1 <= 0;
		
		if (activeB && (bulletXIn + bulletWidth) >= enemyXIn2 && (bulletXIn + bulletWidth) <= (enemyXIn2 + enemyWidthIn) && (bulletYIn + bulletHeight) >= enemyYIn2
		    && (bulletYIn + bulletHeight) <= (enemyYIn2 + enemyHeightIn))
			 
			be_collision2 <= 1;
		else be_collision2 <= 0;
		
		if (activeB && (bulletXIn + bulletWidth) >= enemyXIn3 && (bulletXIn + bulletWidth) <= (enemyXIn3 + enemyWidthIn) && (bulletYIn + bulletHeight) >= enemyYIn3
		    && (bulletYIn + bulletHeight) <= (enemyYIn3 + enemyHeightIn))
			 
			be_collision3 <= 1;
		else be_collision3 <= 0;
		
		if (activeB && (bulletXIn + bulletWidth) >= enemyXIn4 && (bulletXIn + bulletWidth) <= (enemyXIn4 + enemyWidthIn) && (bulletYIn + bulletHeight) >= enemyYIn4
		    && (bulletYIn + bulletHeight) <= (enemyYIn4 + enemyHeightIn))
			 
			be_collision4 <= 1;
		else be_collision4 <= 0;

	 end

	 
	 assign drawX = drawXOut;
	 assign drawY = drawYOut;
	 assign drawColour = drawColourOut;
	 assign drawWidth = drawWidthOut;
	 assign drawHeight = drawHeightOut;
	
endmodule