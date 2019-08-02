module main(CLOCK_50, KEY, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3);
	input CLOCK_50;
	input [3:0] KEY;
	inout PS2_CLK, PS2_DAT;
	output VGA_CLK, VGA_HS,	VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	//MAIN CIRCUIT VARS
	wire clk, resetn;
	assign clk = CLOCK_50;
	assign resetn = KEY[0];
	
	//PLAYER VARS
	wire inInputState, inUpdatePositionState, inSetAState, inSetDState;
	wire [7:0] score;
	wire [3:0] health;
	wire [7:0] playerX;
	wire [6:0] playerY;
	
	//COLLISION VARS
	wire peCollision1, peCollision2, peCollision3, peCollision4;
	wire beCollision1, beCollision2, beCollision3, beCollision4;
	
	//VGA VARS
	wire [7:0] vgaX; //these get sent directly to the VGA
	wire [6:0] vgaY;
	wire [2:0] vgaColour;
	
	//DRAW VARS
	wire vgaPlot, doneDrawing, doneErasing;
	wire [3:0] objectToDraw;
	wire [7:0] drawX; //these are the top left corner coordinates and the colour of the object being sent to the vgaX, vgaY and vgaColour
	wire [6:0] drawY;
	wire [2:0] drawColour;
	wire [4:0] drawWidth, drawHeight;
	wire inEraseStateMain, inUpdatePositionStateMain, inDrawGameoverScreenState, inDrawStartScreenState;
	wire [7:0] eraseX, xDraw;
	wire [6:0] eraseY, yDraw;
	wire [2:0] eraseColour, colourDraw;
	
	//ENEMY VARS
	wire bottomReachedE1, inResetStateE1, inUpdatePositionStateE1, bottomReachedE2, inResetStateE2, inUpdatePositionStateE2, 
		  bottomReachedE3, inResetStateE3, inUpdatePositionStateE3, bottomReachedE4, inResetStateE4, inUpdatePositionStateE4;
	wire [7:0] enemyX1, enemyX2, enemyX3, enemyX4;
	wire [6:0] enemyY1, enemyY2, enemyY3, enemyY4;
	wire [2:0] enemyColour1, enemyColour2, enemyColour3, enemyColour4, enemyColourIn1, enemyColourIn2, enemyColourIn3, enemyColourIn4;
	wire [3:0] enemySpeed1, enemySpeed2, enemySpeed3, enemySpeed4;
	wire [2:0] enemyHealthCurr1, enemyHealthCurr2, enemyHealthCurr3, enemyHealthCurr4;
	wire [2:0] enemyHealthMax1, enemyHealthMax2, enemyHealthMax3, enemyHealthMax4;
	wire [2:0] currHealthCol1, currHealthCol2, currHealthCol3, currHealthCol4, maxHealthCol1, maxHealthCol2, maxHealthCol3, maxHealthCol4; 

	//BULLET VARS
	wire inResetStateB1, inUpdatePositionStateB1, inWaitStateB1, topReachedB1;
	wire [7:0] bulletX1;
	wire [6:0] bulletY1;
	wire activeB;
	
	//KEYBOARD VARS
	wire w, a, s, d, left, right, up, down, space, enter;
	
	wire aPressed, dPressed, spacePressed;
	assign aPressed = ~KEY[3];
	assign dPressed = ~KEY[2];
	assign spacePressed = ~KEY[1];
	
	//player
	playerMovementFSM playerMover(clk, resetn, inInputState, inUpdatePositionState, inSetAState, inSetDState, aPressed, dPressed);
	playData playerData(clk, resetn, inInputState, inUpdatePositionState, inSetAState, inSetDState, playerX, playerY, aPressed, dPressed);

	//enemies
	enemyControl enemyController1(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE1, inResetStateE1, inUpdatePositionStateE1, beCollision1, peCollision1, enemyHealthMax1, enemyHealthCurr1, score);
	enemyDatapath enemyData1(clk, inResetStateE1, inUpdatePositionStateMain, 8'd14, enemyX1, enemyY1, bottomReachedE1, 4'd2, enemySpeed1, resetn, enemyColourIn1, enemyColour1, score, maxHealthCol1, currHealthCol1);
	
	enemyControl enemyControl2(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE2, inResetStateE2, inUpdatePositionStateE2, beCollision2, peCollision2, enemyHealthMax2, enemyHealthCurr2, score);
	enemyDatapath enemyData2(clk, inResetStateE2, inUpdatePositionStateMain, 8'd54, enemyX2, enemyY2, bottomReachedE2, 4'd3, enemySpeed2, resetn, enemyColourIn2, enemyColour2, score, maxHealthCol2, currHealthCol2);
	
	enemyControl enemyControl3(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE3, inResetStateE3, inUpdatePositionStateE3, beCollision3, peCollision3, enemyHealthMax3, enemyHealthCurr3, score);
	enemyDatapath enemyData3(clk, inResetStateE3, inUpdatePositionStateMain, 8'd94, enemyX3, enemyY3, bottomReachedE3, 4'd4, enemySpeed3, resetn, enemyColourIn3, enemyColour3, score, maxHealthCol3, currHealthCol3);
	
	enemyControl enemyControl4(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE4, inResetStateE4, inUpdatePositionStateE4, beCollision4, peCollision4, enemyHealthMax4, enemyHealthCurr4, score);
	enemyDatapath enemyData4(clk, inResetStateE4, inUpdatePositionStateMain, 8'd134, enemyX4, enemyY4, bottomReachedE4, 4'd1, enemySpeed4, resetn, enemyColourIn4, enemyColour4, score, maxHealthCol4, currHealthCol4);

	//bullet
	bulletControl bulletControl1(clk, resetn, inResetStateB1, inUpdatePositionStateB1, inWaitStateB1, spacePressed, inUpdatePositionStateMain, topReachedB1, (beCollision1 || beCollision2 || beCollision3 || beCollision4));
	bulletDatapath bulletData1(clk, inResetStateB1, inUpdatePositionStateB1, inWaitStateB1, playerX + 3'd3, bulletX1, bulletY1, topReachedB1, activeB);
	
	//drawing
	drawFSM mainDrawFSM(clk, resetn, objectToDraw, vgaPlot, doneDrawing, doneErasing, inEraseStateMain, inUpdatePositionStateMain, inDrawGameoverScreenState, inDrawStartScreenState, spacePressed, health);
	displayHandler handler(playerX, enemyX1, enemyX2, enemyX3, enemyX4, bulletX1, playerY, enemyY1, enemyY2, enemyY3, enemyY4, bulletY1,
								  5'd10, 5'd10, 5'd10, 5'd10, 5'd4, 5'd4, 3'b111, enemyColour1, enemyColour2, enemyColour3, enemyColour4, 3'b111, clk, resetn, objectToDraw,
								  drawX, drawY, drawColour, drawWidth, drawHeight, peCollision1, peCollision2, peCollision3, peCollision4, beCollision1,
								  beCollision2, beCollision3, beCollision4, activeB, {2'b0, enemyHealthMax1}, {2'b0, enemyHealthCurr1},
								  {2'b0, enemyHealthMax2}, {2'b0, enemyHealthCurr2}, {2'b0, enemyHealthMax3}, {2'b0, enemyHealthCurr3},
								  {2'b0, enemyHealthMax4}, {2'b0, enemyHealthCurr4}, currHealthCol1, currHealthCol2, currHealthCol3, currHealthCol4, maxHealthCol1,
								  maxHealthCol2, maxHealthCol3, maxHealthCol4);
								  
								  								  
	draw mainDraw(drawX, drawY, drawWidth, drawHeight, drawColour, clk, resetn, vgaPlot, xDraw, yDraw, colourDraw, doneDrawing, inEraseStateMain);
	erase eraseModule(clk, resetn, vgaPlot, eraseX, eraseY, eraseColour, doneErasing, inEraseStateMain);
	
	updateEnemyColours updateEColour(clk, resetn, enemyColourIn1, enemyColourIn2, enemyColourIn3, enemyColourIn4, score);

	//keyboard
	keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
	     .clock(clk),
		  .reset(resetn),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(w),
		  .a(a),
		  .s(s),
		  .d(d),
		  .left(left),
		  .right(right),
		  .up(up),
		  .down(down),
		  .space(space),
		  .enter(enter)
		  );
	
	//vga
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(vgaColour),
			.x(vgaX),
			.y(vgaY),
			.plot(vgaPlot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
		//HEX display updates
		scoreUpdate updateS(clk, resetn, ((beCollision1 && !inResetStateE1) || (beCollision2 && !inResetStateE2) || (beCollision3 && !inResetStateE3) || (beCollision4 && !inResetStateE4)), HEX0, HEX1, inUpdatePositionStateMain, score);
		healthUpdate updateH(clk, resetn, (peCollision1 || peCollision2 || peCollision3 || peCollision4), HEX2, inUpdatePositionStateMain, health, inDrawGameoverScreenState);

		
		reg [7:0] vgaXOut;
		reg [6:0] vgaYOut;
		reg [2:0] vgaColourOut;
		wire [7:0] startScreenX, gameOScreenX;
		wire [6:0] startScreenY, gameOScreenY;
		wire [2:0] startScreenColour, gameOScreenColour;
		
		//Start and End game screens
		drawGameOverScreen gameOverScreen(clk, resetn, inDrawGameoverScreenState, gameOScreenX, gameOScreenY, gameOScreenColour);
		drawStartGameScreen startScreen(clk, resetn, inDrawStartScreenState, startScreenX, startScreenY, startScreenColour);


		
		always @(*)
		begin
			case (inEraseStateMain)
				1'b1: begin vgaXOut = eraseX; vgaYOut = eraseY; vgaColourOut = colourDraw; end
				1'b0: begin
					case (inDrawGameoverScreenState)
						1'b1: begin vgaXOut = gameOScreenX; vgaYOut = gameOScreenY; vgaColourOut = gameOScreenColour; end
						1'b0: begin
							case (inDrawStartScreenState)
								1'b1: begin vgaXOut = startScreenX; vgaYOut = startScreenY; vgaColourOut = startScreenColour; end
								1'b0: begin vgaXOut = xDraw; vgaYOut = yDraw; vgaColourOut <= colourDraw; end
							endcase
						end
					endcase
				end
			endcase
		end	
		//choose input to the vga either from the erase module or the draw module
		assign vgaX = vgaXOut;
		assign vgaY = vgaYOut;
		assign vgaColour = vgaColourOut;
		

	
endmodule





