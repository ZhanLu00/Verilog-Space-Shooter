module playerWithDisplay(input clk, resetn,
    input [7:0] e0_x, e1_x, e2_x, e3_x,
    input [6:0] e0_y, e1_y, e2_y, e3_y,
    input [4:0] p_w, p_h, e_w, e_h,
    input [2:0] e_c0, e_c1, e_c2, e_c3
    input aPressed, dPressed);


	wire [7:0] vgaX;
	wire [6:0] vgaY;
	wire [2:0] vgaColour;
	wire fsmDoneSig;
	wire [3:0] mainDrawSignal;
	wire enableDraw, enableLoad; 

	wire [7:0] playerX;
	wire [6:0] playerY;
	wire [2:0] playerColour;

	wire ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;
	
	playerMovementFSM playerMovement(clk, resetn, ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState, aPressed, dPressed);
	playData playerDatapath(ld_pos1, ld_pos2, ld_pos3, ld_pos4, clk, resetn, inEraseState, inDrawState, playerX, playerY, playerColour);

	displayHandler handler(playerX, e0_x, e1_x, e2_x, e3_x,
			       playerY, e0_y, e1_y, e2_y, e3_y,
			       p_w, p_h, e_w, e_h, playerColour,
			       e_c0, e_c1, e_c2, e_c3,
				    clk, enableLoad, resetn, mainDrawSignal, vgaX, vgaY, vgaColour, fsmDoneSig, enableDraw);
					 
	drawFSM drawController(fsmDoneSig, clk, resetn, mainDrawSignal, enableDraw, enableLoad);
endmodule


/*
FSM that controls the current state that the player is in.

clk: Main circuit clock signal
resetn: Reset signal (active low)

ld_pos1: Control signal for changing player position to POS1 (should be connected to datapath)
ld_pos2: Control signal for changing player position to POS2 (should be connected to datapath)
ld_pos3: Control signal for changing player position to POS3 (should be connected to datapath)
ld_pos4: Control signal for changing player position to POS4 (should be connected to datapath)
inEraseState: Controls whether the player is in the erase state
inDrawState: Controls whether the player is in the draw state

aPressed: Whether the A key on the keyboard is pressed
dPressed: Whether the D key on the keyboard is pressed
*/
module playerMovementFSM(clk, resetn, ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState, aPressed, dPressed);
	input clk, resetn, aPressed, dPressed;
	
	output reg ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;
	
	reg [3:0] current_state, next_state, previous_state, after_erase_state; //state registers
																									/*previous_state stores the previous POS state of the FSM
																									  after_erase_state stores the POS state to go to after being erased	
																									*/
   reg [7:0] drawCounter; //counter that determines whether the player is done drawing or not

   localparam  S_POS1 = 4'd0,						  
               S_POS2 = 4'd1,
               S_POS3 = 4'd2,
               S_POS4 = 4'd3,
               S_ERASE = 4'd4,
               S_DRAW = 4'd5;

	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
					S_POS1: begin
						next_state = (dPressed == 1'b1) ? S_ERASE : S_DRAW;
						after_erase_state = (dPressed == 1'b1) ? S_POS2 : S_POS1;
					end
					S_POS2: begin
						next_state = (dPressed == 1'b1 || aPressed == 1'b1) ? S_ERASE : S_DRAW;
						case (dPressed)
							1'b1: after_erase_state = S_POS3;
							1'b0:begin
								case (aPressed)
									1'b1: after_erase_state = S_POS1;
									1'b0: after_erase_state = S_POS2;
								endcase
							end
						endcase
					end
					S_POS3: begin
						next_state = (dPressed == 1'b1 || aPressed == 1'b1) ? S_ERASE : S_DRAW;
						case (dPressed)
							1'b1: after_erase_state = S_POS4;
							1'b0:begin
								case (aPressed)
									1'b1: after_erase_state = S_POS2;
									1'b0: after_erase_state = S_POS3;
								endcase
							end
						endcase
					end
					S_POS4: begin
						next_state = (aPressed == 1'b1) ? S_ERASE : S_DRAW;
						after_erase_state = (aPressed == 1'b1) ? S_POS3 : S_POS4;
					end	
					S_ERASE: begin
                        case (drawCounter == 8'd99)
							1'b1: next_state = after_erase_state;
							
							1'b0: next_state = S_ERASE;
                        
						endcase
					end
					
					S_DRAW: next_state = (drawCounter == 8'd99) ? previous_state : S_DRAW;
            default:     next_state = S_DRAW;
        endcase
    end // state_table



	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_pos1 = 1'b0;
		  ld_pos2 = 1'b0;
		  ld_pos3 = 1'b0;
		  ld_pos4 = 1'b0;
		  inDrawState = 1'b0;
		  inEraseState = 1'b0;

        case (current_state)
            S_POS1: ld_pos1 = 1'b1;
            S_POS2: ld_pos2 = 1'b1;
            S_POS3: ld_pos3 = 1'b1;
            S_POS4: ld_pos4 = 1'b1;
            S_DRAW: inDrawState = 1'b1;
            S_ERASE: inEraseState = 1'b1;
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_POS1;
				previous_state <= S_POS1;
            drawCounter <= 8'd0;
        end
        else begin
			  //if switching from a POS state, store the current state in previous_state
			  if (next_state != current_state && (current_state == S_POS1 || current_state == S_POS2 || current_state == S_POS3 || current_state == S_POS4))
					previous_state <= current_state;
					current_state <= next_state;
			  end
			  
			  //update draw counter
			  if (current_state == S_ERASE || current_state == S_DRAW) begin
					if (drawCounter < 8'd99)
						 drawCounter <= drawCounter + 1;
					else
						 drawCounter <= 8'd0;
			  end
		  end // state_FFS


endmodule

/*
Module that controls the position and colour of the player.

ld_1: Signal that controls whether player top-left corner coordinates should be changed to position 1
ld_2: Signal that controls whether player top-left corner coordinates should be changed to position 2
ld_3: Signal that controls whether player top-left corner coordinates should be changed to position 3
ld_4: Signal that controls whether player top-left corner coordinates should be changed to position 4
clock: main circuit clock signal
reset: reset signal (active low)
erase: Signal that controls whether the player colour should be changed to black
draw: Signal that controls whether the player colour should be changed to white

x_out: wire? holding the x coordinate of the top left corner of the player
y_out: wire? holding the y coordinate of the top left corner of the player
colour_out: wire? holding the colour that the player should be drawn in on the screen
*/

module playData(
	input ld_1, ld_2, ld_3, ld_4,
	input clock, reset, erase, draw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out);

	reg [7:0] xout; //register holding the current x coordinate of top left corner of the player. To be assigned to x_out
	reg [2:0] cout; //register holding the current colour of the player. To be assigned to colour_out.
	
    	
	 
	localparam	x1 = 8'd14, //position 1
					x2 = 8'd54, //position 2
					x3 = 8'd94, //position 3
					x4 = 8'd134, //position 4
					y  = 7'd99, //y stays constant
					COLOR = 3'b111; //default colour is white
	
	//logic for switching position and colour based on current state
	always @(posedge clock)
	begin
		if (!reset) begin cout <= COLOR; xout <= x1; end // default for reset,  c =1, x = x1
		else if (erase) begin cout <= 3'b0; xout <= xout; end // erase: color = 0, x = the last stored position
		else if (draw) begin 
			if (ld_1) begin xout <= x1; cout <= COLOR; end
			if (ld_2) begin xout <= x2; cout <= COLOR; end
			if (ld_3) begin xout <= x3; cout <= COLOR; end
			if (ld_4) begin xout <= x4; cout <= COLOR; end
			
		end

	end

	//assigning outputs
	assign x_out = xout;
	assign y_out = y;
	assign color_out = cout;

endmodule



/*
Draw FSM that controls which object should be currently drawn (ie. which object's coordinates arec counted in drawDisplay and sent to the VGA)

done: whether the object currently being drawn by the display handler has finished being drawn or not
clk: the circuit's clock signal
resetn: reset signal (active low)

mainDrawSignal: binary value representing which object to draw
					1: Player
					2: Enemy 1
					3: Enemy 2
					4: Enemy 3
					5: Enemy 4
					6: Bullet
enableDraw: whether the VGA should have its plot on or off
enableLoad: controls whether the displayHandler should be loading in new starting coordinates or not
*/

module drawFSM(done, clk, resetn, mainDrawSignal, enableDraw, enableLoad);
	input done;
	input clk;
	input resetn;
	output enableDraw;
	output enableLoad;
	
	output [3:0] mainDrawSignal;

   reg [3:0] drawSignalOut; //wire to be assigned as the value of the mainDrawSignal
   reg [3:0] current_state, next_state; //registers holding the current and next states, respectively
	reg [3:0] state_after_wait;
	reg [1:0] delayCounter;
	reg enableDrawOut;
	reg enableLoadOut;
	
	 //State constants
    localparam S_DRAW_PLAYER = 4'd0,
               S_DRAW_ENEMY1 = 4'd1,
               S_DRAW_ENEMY2 = 4'd2,
               S_DRAW_ENEMY3 = 4'd3,
               S_DRAW_ENEMY4 = 4'd4,
               S_DRAW_BULLET = 4'd5,
					S_LOAD_WAIT = 4'd6,
					S_DRAW_WAIT = 4'd7;

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)           
                S_DRAW_PLAYER: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_PLAYER;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY1 : S_DRAW_WAIT;
					 end
					 
                S_DRAW_ENEMY1: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY1;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY2 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY2: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY2;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY3 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY3: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY3;
						state_after_wait = (done == 1'b1) ? S_DRAW_ENEMY4 : S_DRAW_WAIT;
                end
					 
					 S_DRAW_ENEMY4: begin
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_ENEMY4;
						state_after_wait = (done == 1'b1) ? S_DRAW_BULLET : S_DRAW_WAIT;
                end
					 
					 S_DRAW_BULLET: begin 
						next_state = (done == 1'b1) ? S_DRAW_WAIT : S_DRAW_BULLET;
						state_after_wait = (done == 1'b1) ? S_DRAW_PLAYER : S_DRAW_WAIT;
					 end
					 
					 S_LOAD_WAIT: begin
						next_state = (delayCounter == 2'b11) ? S_DRAW_PLAYER : S_LOAD_WAIT;
					 end
					 
					 S_DRAW_WAIT: begin
						next_state = state_after_wait;
					 end
				default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; //by default, draw the player
		  enableDrawOut <= 1'b0;
		  //enableLoadOut <= 1'b0;
		  
        case (current_state)
				S_LOAD_WAIT: begin drawSignalOut <= 4'd0; enableDrawOut <= 0;  enableLoadOut = 1'b1; end
            S_DRAW_PLAYER: begin drawSignalOut <= 4'd1; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY1: begin drawSignalOut <= 4'd2; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY2: begin drawSignalOut <= 4'd3; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY3: begin drawSignalOut <= 4'd4; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_ENEMY4: begin drawSignalOut <= 4'd5; enableDrawOut <= 1; enableLoadOut = 1'b0; end
            S_DRAW_BULLET: begin drawSignalOut <= 4'd6; enableDrawOut <= 1; enableLoadOut = 1'b0; end
				S_DRAW_WAIT: begin 
					enableDrawOut <= 0;  
					enableLoadOut = 1'b1; 
					
					case (state_after_wait)
						S_DRAW_PLAYER: drawSignalOut <= 4'd1;
						S_DRAW_ENEMY1: drawSignalOut <= 4'd2;
						S_DRAW_ENEMY2: drawSignalOut <= 4'd3;
						S_DRAW_ENEMY3: drawSignalOut <= 4'd4;
						S_DRAW_ENEMY4: drawSignalOut <= 4'd5;
						S_DRAW_BULLET: drawSignalOut <= 4'd6;
					endcase
					
					
				end
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_LOAD_WAIT;
				delayCounter <= 2'b0;
				state_after_wait <= S_DRAW_PLAYER;
        end
        else 
            current_state <= next_state;
		  if (delayCounter < 2'b11)
			delayCounter <= delayCounter + 1;
       
    end // state_FFS

    assign mainDrawSignal = drawSignalOut;
	 assign enableDraw = enableDrawOut;
	 assign enableLoad = enableLoadOut;
endmodule

/*
Module that outputs the coordinates of an object being draw based on the (x, y) of top-left corner and the object's width and height.

x_in: The x coordinate of top-left corner of object being drawn
y_in: The y coordinate of top-left corner of object being drawn
width: The width of the object in binary
height: The height of the object in binary
c_in: The colour to draw the object in
enableLoad: Controls whether this module will load in new starting coordinates in preparation for drawing a new object
clk: Circuit clock signal
reset: Circuit reset signal (active low)

x_out: The x coordinate of the current pixel to draw
y_out: The y coordinate of the current pixel to draw
c_out: The colour of the current pixel to draw 
done: Whether the module is done outputting the coordinates for the current object or not

enableDraw: controls when this module should enable its counters and when not
*/

module draw(
    input [7:0] x_in,
    input [6:0] y_in,
    input [4:0] width, height,
    input [2:0] c_in,
    input enableLoad, clk, reset,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] c_out,
    output done, input enableDraw
);
    reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
    reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
    reg done_;						//placeholder for the done output signal

	 //Draw logic
    always @(posedge clk)
    begin
		  if ((counterX == 0 && counterY == 0) || enableDraw == 0)
					done_ <= 0;
	 
        if (!reset) begin
		      counterX <= 0;
				counterY <= 0;
            xOut <= x_in;
            yOut <= y_in;
            done_ <= 0;
        end
        else if (enableLoad) begin
				xOut <= x_in;
            yOut <= y_in;
		  end
		  else if (enableDraw) begin	
				
					if (xOut < 8'd180 && xOut >= 8'd0 && yOut <= 7'd127 && yOut >= 7'b0 && done_ == 0) begin //this is needed so that it starts counting at 30 and not 31 for example. Need a delay between loading in the values and starting to count
						if (counterX == width - 1) begin
							counterX <= 0; 
							counterY <= counterY + 1; 
							if (counterY == height - 1) begin
								done_ <= 1'b1; 
								counterY <= 0;
							end
						end
						else if (counterX < width)
							 counterX <= counterX + 1;
					end
		  end
		  
		  else //if the module is not enabled, it cannot be done drawing
				done_ <= 0;
				
				
    end

	 //assigning wires and registers to their corresponding outputs
    assign x_out = xOut + counterX;
    assign y_out = yOut + counterY;
    assign done = done_;
	 assign c_out = c_in;

endmodule

/*
Module that acts as a datapath for the drawing FSM and decides which coordinates should be currently sent to the VGA.


p_x: x coordinate of top left corner of player
e0_x: x coordinate of top left corner of first enemeny
e1_x: x coordinate of top left corner of second enemy
e2_x: x coordinate of top left corner of third enemy
e3_x: x coordinate of top left corner of fourth enemy
p_y: y coordinate of top left corner of player
e0_y: y coordinate of top left corner of first enemy 
e1_y: y coordinate of top left corner of second enemy
e2_y: y coordinate of top left corner of third enemy
e3_y: y coordinate of top left corner of fourth enemy
p_c: player colour
e_c0: first enemy colour
e_c1: second enemy colour
e_c2: third enemy colour
e_c3: fourth enemy colour
clk: circuit clock signal
enableLoad: Signal that controls loading of the next object's top-left corner coordinates into the draw module
reset: reset signal (active low)
control_signal: determines the coordinates of what object (out of the ones listed above) should be sent to the VGA

vgaX: output signal for the x coordinates going to the VGA
vgaY: output signal for the y coordinates going to the VGA
vgaColour: output signal for the colour of the pixel being drawn to the VGA
fsmDoneSignal: signal that goes to drawFSM to tell it that the current object is done drawing and the state can be switched

enableDraw: Signal that controls whether the draw module should start its counters (ie. begin drawing)
*/
module displayHandler(
    input [7:0] p_x, e0_x, e1_x, e2_x, e3_x,
    input [6:0] p_y, e0_y, e1_y, e2_y, e3_y,
    input [4:0] p_w, p_h, e_w, e_h,
    input [2:0] p_c, e_c0, e_c1, e_c2, e_c3,
    input clk, enableLoad, reset,
    input [3:0] control_signal,
    output [7:0] vgaX,
	 output [6:0] vgaY,
	 output [2:0] vgaColour,
	 output fsmDoneSignal,
	 input enableDraw
);


    reg [7:0] px, e0x, e1x, e2x, e3x; //x coordinates of top left corner of in-game objects
    reg [6:0] py, e0y, e1y, e2y, e3y; //y coordinates of top left corner of in-game objects
    reg [4:0] pw, ph, ew, eh; //width and height of the player and the enemy
    reg [2:0] pc, e0c, e1c, e2c, e3c; //colours of each enemy and player

    reg [7:0] drawX; //x coordinate of top left corner of the object being drawn
    reg [6:0] drawY; //y coordinate of the top left corner of the object being drawn
    reg [4:0] drawWidth, drawHeight; //width and height of the object being drawn
    reg [2:0] drawColour; //colour of the object being drawn

    //logic that decides which object to draw
    always @(posedge clk)
    begin
        if (!reset) begin
            px<=p_x; e0x<=e0_x; e1x<=e1_x; e2x<=e2_x; e3x<=e3_x; 
            py<=p_y; e0y<=e0_y; e1y<=e1_y; e2y<=e2_y; e3y<=e3_y; 
            pw<=p_w; ph<=p_h; ew<=e_w; eh<=e_h; pc<=p_c; e0c<=e_c0; e1c<=e_c1; e2c<=e_c2; e3c<=e_c3;
        end
    end

    // choose output by controller
    // 0: player, 1:e0, 2:e1m, 3:e2, 4:e3
    always @(*)
    begin 
        case (control_signal)
            1: begin drawX <= px; drawY <= py; drawWidth <= pw; drawHeight <= ph; drawColour <= pc; end //player
            2: begin drawX <= e0x; drawY <= e0y; drawWidth <= ew; drawHeight <= eh; drawColour <= e0c; end //e1
            3: begin drawX <= e1x; drawY <= e1y; drawWidth <= ew; drawHeight <= eh; drawColour <= e1c; end //e2
            4: begin drawX <= e2x; drawY <= e2y; drawWidth <= ew; drawHeight <= eh; drawColour<= e2c; end //e3
            5: begin drawX <= e3x; drawY <= e3y; drawWidth <= ew; drawHeight <= eh; drawColour <= e3c; end //e4
				default: begin drawX <= px; drawY <= py; drawWidth <= pw; drawHeight <= ph; drawColour <= pc; end
        endcase
    end

	 //module that produces coordinates that are to be sent to the vga
	 wire [7:0] vgaXOut; //wire to be assigned to vgaX
	 wire [6:0] vgaYOut; //wire to be assigned to vgaY
	 wire [2:0] vgaColourOut; //wire to be assigned to vgaColour
	 wire doneOut; //wire to be assigned to fsmDoneSignal
	 
	 draw mainDrawModule(.x_in(drawX), .y_in(drawY), .width(drawWidth), .height(drawHeight), .c_in(drawColour), .enableLoad(enableLoad) /*this has to potentially be changed*/, .clk(clk), .reset(reset),
								.x_out(vgaXOut), .y_out(vgaYOut), .c_out(vgaColourOut), .done(doneOut), .enableDraw(enableDraw));
								
	 assign vgaX = vgaXOut;
	 assign vgaY = vgaYOut;
	 assign vgaColour = vgaColourOut;
	 assign fsmDoneSignal = doneOut;
endmodule