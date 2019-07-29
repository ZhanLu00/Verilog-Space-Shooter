module main(CLOCK_50, KEY, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, LEDR);
	input CLOCK_50;
	input [3:0] KEY;
	inout PS2_CLK, PS2_DAT;
	output VGA_CLK, VGA_HS,	VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B;
	output [6:0] HEX0, HEX1, HEX2;
	output [9:0] LEDR;
	
	//MAIN CIRCUIT VARS
	wire clk, resetn;
	assign clk = CLOCK_50;
	assign resetn = KEY[0];
	
	//PLAYER VARS
	wire inInputState, inUpdatePositionState, inSetAState, inSetDState;
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
	wire inEraseStateMain, inUpdatePositionStateMain;
	wire [7:0] eraseX, xDraw;
	wire [6:0] eraseY, yDraw;
	wire [2:0] eraseColour, colourDraw;
	
	//ENEMY VARS
	wire bottomReachedE1, inResetStateE1, inUpdatePositionStateE1, bottomReachedE2, inResetStateE2, inUpdatePositionStateE2, 
		  bottomReachedE3, inResetStateE3, inUpdatePositionStateE3, bottomReachedE4, inResetStateE4, inUpdatePositionStateE4;
	wire [7:0] enemyX1, enemyX2, enemyX3, enemyX4;
	wire [6:0] enemyY1, enemyY2, enemyY3, enemyY4;
	wire [2:0] enemyColour1, enemyColour2, enemyColour3, enemyColour4;
	wire [2:0] enemySpeed1, enemySpeed2, enemySpeed3, enemySpeed4;
	//assign these here for now, but should be assigning them in difficulty changing modules or something like that
	assign enemyColour1 = 3'b101;
	assign enemyColour2 = 3'b011;
	assign enemyColour3 = 3'b100;
	assign enemyColour4 = 3'b110;
	assign enemySpeed1 = 3'd4;
	assign enemySpeed2 = 3'd2;
	assign enemySpeed3 = 3'd3;
	assign enemySpeed4 = 3'd1;
	
	//BULLET VARS
	wire inResetStateB1, inUpdatePositionStateB1, topReachedB1;
	wire [7:0] bulletX1;
	wire [6:0] bulletY1;
	
	//KEYBOARD VARS
	wire w, aPressed, s, dPressed, left, right, up, down, spacePressed, enter;
	
	
	//player
	playerMovementFSM playerMover(clk, resetn, inInputState, inUpdatePositionState, inSetAState, inSetDState, aPressed, dPressed);
	playData playerData(clk, resetn, inInputState, inUpdatePositionState, inSetAState, inSetDState, playerX, playerY, aPressed, dPressed);

	//enemies
	enemyControl enemyController1(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE1, inResetStateE1, inUpdatePositionStateE1, beCollision1);
	enemyDatapath enemyData1(clk, inResetStateE1, inUpdatePositionStateMain, 8'd14, enemyX1, enemyY1, bottomReachedE1, enemySpeed1);
	
	enemyControl enemyControl2(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE2, inResetStateE2, inUpdatePositionStateE2, beCollision2);
	enemyDatapath enemyData2(clk, inResetStateE2, inUpdatePositionStateMain, 8'd54, enemyX2, enemyY2, bottomReachedE2, enemySpeed2);
	
	enemyControl enemyControl3(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE3, inResetStateE3, inUpdatePositionStateE3, beCollision3);
	enemyDatapath enemyData3(clk, inResetStateE3, inUpdatePositionStateMain, 8'd94, enemyX3, enemyY3, bottomReachedE3, enemySpeed3);
	
	enemyControl enemyControl4(clk, resetn, 1'b1, inUpdatePositionStateMain, bottomReachedE4, inResetStateE4, inUpdatePositionStateE4, beCollision4);
	enemyDatapath enemyData4(clk, inResetStateE4, inUpdatePositionStateMain, 8'd134, enemyX4, enemyY4, bottomReachedE4, enemySpeed4);

	//bullet
	bulletControl bulletControl1(clk, resetn, inResetStateB1, inUpdatePositionStateB1, spacePressed, inUpdatePositionStateMain, topReachedB1, (beCollision1 || beCollision2 || beCollision3 || beCollision4));
	bulletDatapath bulletData1(clk, inResetStateB1, inUpdatePositionStateB1, playerX + 3'd3, bulletX1, bulletY1, topReachedB1);
	
	//drawing
	drawFSM mainDrawFSM(clk, resetn, objectToDraw, vgaPlot, doneDrawing, doneErasing, inEraseStateMain, inUpdatePositionStateMain);
	displayHandler handler(playerX, enemyX1, enemyX2, enemyX3, enemyX4, bulletX1, playerY, enemyY1, enemyY2, enemyY3, enemyY4, bulletY1,
								  5'd10, 5'd10, 5'd10, 5'd10, 5'd4, 5'd4, 3'b111, enemyColour1, enemyColour2, enemyColour3, enemyColour4, 3'b111, clk, resetn, objectToDraw,
								  drawX, drawY, drawColour, drawWidth, drawHeight, peCollision1, peCollision2, peCollision3, peCollision4, beCollision1,
								  beCollision2, beCollision3, beCollision4, inResetStateB1);
								  
	draw mainDraw(drawX, drawY, drawWidth, drawHeight, drawColour, clk, resetn, vgaPlot, xDraw, yDraw, colourDraw, doneDrawing, inEraseStateMain);
	erase eraseModule(clk, resetn, vgaPlot, eraseX, eraseY, eraseColour, doneErasing, inEraseStateMain);
	


	//keyboard
	keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
	     .clock(clk),
		  .reset(resetn),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(w),
		  .a(aPressed),
		  .s(s),
		  .d(dPressed),
		  .left(left),
		  .right(right),
		  .up(up),
		  .down(down),
		  .space(spacePressed),
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
		
		//decoder7 d1(HEX0, playerX[3:0]);
		//decoder7 d2(HEX1, playerX[7:4]);
		
		//HEX display updates
		scoreUpdate updateS(clk, resetn, (beCollision1 || beCollision2 || beCollision3 || beCollision4), HEX0, HEX1);
		healthUpdate updateH(clk, resetn, (peCollision1 || peCollision2 || peCollision3 || peCollision4), HEX2);
		
		
		//collision checks
		assign LEDR[0] = peCollision1;
		assign LEDR[1] = peCollision2;
		assign LEDR[2] = peCollision3;
		assign LEDR[3] = peCollision4;
		assign LEDR[4] = beCollision1;
		assign LEDR[5] = beCollision2;
		assign LEDR[6] = beCollision3;
		assign LEDR[7] = beCollision4;

		//choose input to the vga either from the erase module or the draw module
		assign vgaX = (inEraseStateMain) ? eraseX : xDraw;
		assign vgaY = (inEraseStateMain) ? eraseY : yDraw;
		assign vgaColour = (inEraseStateMain) ? eraseColour : colourDraw;
	
endmodule







/*
module bulletControl(clk, resetn, inResetState,inUpdatePositionState, spacePressed, updatePosition, topReached);
	input clk, resetn, updatePosition, topReached, spacePressed;
	
	output reg inResetState, inUpdatePositionState; //booleans for being in a given state or not

	
	reg [3:0] current_state, next_state; 
    
   localparam  S_RESET        = 4'b0,
												  
               S_UPDATE_POSITION      = 4'b1,
                S_WAIT                 = 4'b0010; 


	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_RESET: next_state = (spacePressed) ? S_UPDATE_POSITION : S_RESET; 
					 S_UPDATE_POSITION: next_state = (topReached) ? S_RESET : S_WAIT;
                S_WAIT: next_state = (updatePosition) ? S_UPDATE_POSITION : S_WAIT; 
            default: next_state = S_RESET;
        endcase
    end // state_table



	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        inResetState <= 1'b0;
		inUpdatePositionState <= 1'b0;
		  
        case (current_state)
            S_RESET: inResetState <= 1'b1;
			S_UPDATE_POSITION: inUpdatePositionState <= 1'b1;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_RESET;
        else 
            current_state <= next_state;
    end // state_FFS
	
endmodule

module bulletControl(clk, resetn, inResetState,inUpdatePositionState, spacePressed, updatePosition, topReached);
	input clk, resetn, updatePosition, topReached, spacePressed;
	
	output reg inResetState, inUpdatePositionState; //booleans for being in a given state or not

	
	reg [3:0] current_state, next_state; 
    
   localparam  S_RESET        = 4'b0,
               S_UPDATE_POSITION      = 4'b1,
                S_WAIT                 = 4'b0010; 


	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_RESET: next_state = (spacePressed) ? S_UPDATE_POSITION : S_RESET; 
					 S_UPDATE_POSITION: next_state = (topReached) ? S_RESET : S_WAIT;
                S_WAIT: next_state = (updatePosition) ? S_UPDATE_POSITION : S_WAIT; 
            default: next_state = S_RESET;
        endcase
    end // state_table



	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        inResetState <= 1'b0;
		inUpdatePositionState <= 1'b0;
		  
        case (current_state)
            S_RESET: inResetState <= 1'b1;
			S_UPDATE_POSITION: inUpdatePositionState <= 1'b1;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_RESET;
        else 
            current_state <= next_state;
    end // state_FFS
	
endmodule



module drawFSM(clk, resetn, objectToDraw, vgaPlot, doneDrawing, doneErasing, inEraseState, inUpdatePositionState);

	input clk, resetn, doneDrawing, doneErasing;
	output [3:0] objectToDraw;
	output vgaPlot;
	output reg inEraseState, inUpdatePositionState; 

	reg [3:0] drawSignalOut;
	reg [3:0] current_state, next_state;
	reg vgaPlotOut;
	reg [3:0] frameCounter;
	reg [26:0] rateDividerCounter;
	
	localparam S_ERASE = 4'd1,
				  S_DRAW_PLAYER = 4'd2,
				  S_DRAW_ENEMY1 = 4'd3,
				  S_WAIT1 = 4'd4,
				  S_WAIT2 = 4'd5,
				  S_RESET_FRAMES = 4'd6,
				  S_DELAY_UPDATE = 4'd7,
				  S_UPDATE_POSITION = 4'd8;

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)    
					S_ERASE: next_state = (doneErasing) ? S_DRAW_PLAYER : S_ERASE;
					
					S_DRAW_PLAYER: next_state = (doneDrawing) ? S_WAIT1 : S_DRAW_PLAYER;
				   S_WAIT1: next_state = S_DRAW_ENEMY1;
				
					S_DRAW_ENEMY1: next_state = (doneDrawing) ? S_WAIT2 : S_DRAW_ENEMY1;
					S_WAIT2: next_state = S_RESET_FRAMES;
					
					S_RESET_FRAMES: next_state = S_DELAY_UPDATE;
					S_DELAY_UPDATE: next_state = (frameCounter == 4'b1111) ? S_UPDATE_POSITION : S_DELAY_UPDATE;
					S_UPDATE_POSITION: next_state = S_ERASE;
					
				default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; 
		  vgaPlotOut <= 1'b0;
		  inEraseState <= 0;
		  inUpdatePositionState <= 0;
		  
        case (current_state)
				S_ERASE: begin inEraseState <= 1; vgaPlotOut <= 1; end
				S_DELAY_UPDATE: begin vgaPlotOut <= 0; end
				S_UPDATE_POSITION: begin inUpdatePositionState <= 1; vgaPlotOut <= 0; end 
				S_RESET_FRAMES: begin vgaPlotOut <= 0; end
				
				S_DRAW_PLAYER: begin
					drawSignalOut <= 4'd1;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_ENEMY1: begin
					drawSignalOut <= 4'd2;
					vgaPlotOut <= 1;
				end
				
				S_WAIT1: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT2: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_ERASE;
				frameCounter <= 0;
				rateDividerCounter <= 27'd3;//27'd833333 27'b11001011011100110100
        end
        else begin
            
				current_state <= next_state;
				if (current_state == S_RESET_FRAMES) begin
					rateDividerCounter <= 27'd3;//27'd833333 27'b11001011011100110100
					frameCounter <= 4'b0;
				end
				else if(current_state == S_DELAY_UPDATE) begin			
					if (rateDividerCounter == 0) begin
						frameCounter <= frameCounter + 1'b1;
						rateDividerCounter <= 27'd3; //27'd833333  27'b11001011011100110100
					
						if (frameCounter == 4'b1111)
							frameCounter <= 0;
						else
							frameCounter <= frameCounter + 1'b1;
					end
					else
						rateDividerCounter <= rateDividerCounter - 1'b1;
				end
				
			end
    end // state_FFS

    assign objectToDraw = drawSignalOut;
	 assign vgaPlot = vgaPlotOut;
endmodule



module draw(
	input [7:0] x_in,
	input [6:0] y_in,
	input [4:0] width, height,
	input [2:0] c_in,
	input clk, reset, enableDraw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] c_out,
	output done,
	input inEraseStateMain
);
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg [2:0] color;		//reg for color
	reg start;
    
	// draw logic

    	always @(posedge clk)
    	begin
    		if (!enableDraw || !reset) begin //when not draw and reset
    			counterX<=0; // reset counters when not enable
    			counterY<=0;
    			xOut<=0;	// when not drawing, x,y=0, c=0
    			yOut<=0;
    			color<= 3'b0;// when not drawing, current pixel = background color
    			done_<= 0;
    			start <=0;
    		end
    		else if (enableDraw && !done_ && !inEraseStateMain) begin // when start draw and have not done draw yet
    			if (!start) begin 		// initiate starting drawing condition
    				start <= 1;
    				counterX <= 0;
    				counterY <= 0;
    				xOut<=x_in;
    				yOut<=y_in;
    				color <= c_in;
    			end
    			else if (start) begin			// when started to draw
    				if (counterX < width-1) begin counterX <= counterX + 1; end 	// drawing row
    				else if (counterX == width-1) begin		// one row finished, y+1 or not
    					counterX <= 0; 
    					if (counterY < height-1) begin	// new row
    						counterY <= counterY + 1;
    					end
    					else if (counterY == height-1) begin
    						done_ = 1;
    					end
    				end
    			end
    		end
    	end


	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign done = done_;
	assign c_out = color;

endmodule

module enemyControl(clk, resetn, enable, updatePosition, bottomReached, inResetState, inUpdatePositionStateE);
	input clk, resetn, enable, updatePosition, bottomReached;
	
	output reg inResetState, inUpdatePositionStateE; //booleans for being in a given state or not
	
	reg [3:0] current_state, next_state; 
    
   localparam  S_RESET        = 4'b0,
               S_UPDATE_POSITION      = 4'b1,
               S_WAIT                 = 4'b0010; 


	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_RESET: next_state = (enable) ? S_UPDATE_POSITION : S_RESET; 
					 S_UPDATE_POSITION: next_state = (bottomReached) ? S_RESET : S_WAIT;
                S_WAIT: next_state = (updatePosition) ? S_UPDATE_POSITION : S_WAIT; 
            default:     next_state = S_RESET;
        endcase
    end // state_table



	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        inResetState <= 1'b0;
		  inUpdatePositionStateE <= 0;
		  
        case (current_state)
            S_RESET: inResetState <= 1'b1;
				S_UPDATE_POSITION: inUpdatePositionStateE <= 1;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_RESET;
        else
            current_state <= next_state;
    end // state_FFS
	 

endmodule


module enemyDatapath(clk, inResetState, inUpdatePositionState,
							enemyXIn, enemyX, enemyY, bottomReached);
	
	input clk, inResetState, inUpdatePositionState;
	input [7:0] enemyXIn;
	output [7:0] enemyX;
	output [6:0] enemyY;
	output reg bottomReached;
	reg [7:0] xOut;
	reg [6:0] yOut;
	
	always @(posedge clk)
	begin
		if (inResetState) begin  xOut <= enemyXIn; yOut <= 7'b0; bottomReached <= 0; end
		else if (inUpdatePositionState) begin 
			if (yOut + 7'd9 < 7'd119) 
				yOut <= yOut + 1;
			else begin
				yOut <= 0;
            bottomReached <= 1;
			end
		end
	end
	
	assign enemyX = xOut;
	assign enemyY = yOut;

endmodule

module erase(
	input clk, reset, enableDraw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] c_out,
	output done,
	input inEraseStateMain
);
    
	reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
	reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
	reg done_;			//placeholder for the done output signal
	reg [2:0] color;		//reg for color
	reg start;

    localparam width = 8'd159,
              height = 7'd119;
	// draw logic

    	always @(posedge clk)
    	begin
    		if (!enableDraw || !reset) begin //when not draw and reset
    			counterX<=0; // reset counters when not enable
    			counterY<=0;
    			xOut<=0;	// when not drawing, x,y=0, c=0
    			yOut<=0;
    			done_<= 0;
    			start <=0;
    		end
    		else if (enableDraw && !done_ && inEraseStateMain) begin // when start draw and have not done draw yet
    			if (!start) begin 		// initiate starting drawing condition
    				start <= 1;
    				counterX <= 0;
    				counterY <= 0;
    				xOut<=0;
    				yOut<=0;
    			end
    			else if (start) begin			// when started to draw
    				if (counterX < width) begin counterX <= counterX + 1; end 	// drawing row
    				else if (counterX == width) begin		// one row finished, y+1 or not
    					counterX <= 0; 
    					if (counterY < height) begin	// new row
    						counterY <= counterY + 1;
    					end
    					else if (counterY == height) begin
    						done_ = 1;
    					end
    				end
    			end
    		end
    	end


	//assigning wires and registers to their corresponding outputs
	assign x_out = xOut + counterX;
	assign y_out = yOut + counterY;
	assign done = done_;
	assign c_out = 3'b0;

endmodule

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

module playerMovementFSM(clk, resetn, inInputState, inUpdatePositionState, inSetAState, inSetDState, aPressed, dPressed);
	input clk, resetn, aPressed, dPressed;
	
	output reg inInputState, inUpdatePositionState, inSetAState, inSetDState;

	reg [3:0] current_state, next_state;
	
	localparam S_INPUT = 4'd0,
				  S_UPDATE_POSITION = 4'd1,
				  S_SET_A = 4'd2,
				  S_SET_D = 4'd3;

	always@(*)
    begin: state_table 
            case (current_state)
					S_INPUT: begin
						case (aPressed)
							1'b0: begin
								case (dPressed)
									1'b0: next_state = S_INPUT; 
									
									1'b1: next_state = S_SET_D;
								endcase
							end	
							1'b1: next_state = S_SET_A;
						endcase
					end	
					S_UPDATE_POSITION: next_state = S_INPUT;
					S_SET_A: next_state = S_INPUT;
					
					S_SET_D: next_state = S_INPUT;
					
            default: next_state = S_INPUT;
        endcase
    end // state_table
	 
	 
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  inInputState = 1'b0;
		  inUpdatePositionState = 1'b0;
		  inSetAState = 1'b0;
		  inSetDState = 1'b0;

        case (current_state)
				S_INPUT: inInputState = 1'b1; 
				S_UPDATE_POSITION: inUpdatePositionState = 1'b1;
				S_SET_A: inSetAState = 1'b1;
				S_SET_D: inSetDState = 1'b1;
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_INPUT;
        end
        else begin
			  current_state <= next_state;
		  end // state_FFS
	 end
endmodule

module displayHandler(
    input [7:0] playerXIn, enemyXIn1,
    input [6:0] playerYIn, enemyYIn1,
    input [4:0] playerWidthIn, playerHeightIn, enemyWidthIn, enemyHeightIn,
    input [2:0] playerColourIn, enemyColourIn1,
    input clk, resetn,
    input [3:0] control_signal,
    output [7:0] drawX,
	 output [6:0] drawY,
	 output [2:0] drawColour,
	 output [4:0] drawWidth, drawHeight
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
				default: begin drawXOut <= playerXIn; drawYOut <= playerYIn; drawWidthOut <= playerWidthIn; drawHeightOut <= playerHeightIn; drawColourOut <= playerColourIn;end
        endcase
    end
	 
	 assign drawX = drawXOut;
	 assign drawY = drawYOut;
	 assign drawColour = drawColourOut;
	 assign drawWidth = drawWidthOut;
	 assign drawHeight = drawHeightOut;

endmodule*/