module displayTestCombined(input clk, resetn,
    input [7:0] p_x, e0_x, e1_x, e2_x, e3_x,
    input [6:0] p_y, e0_y, e1_y, e2_y, e3_y,
    input [4:0] p_w, p_h, e_w, e_h,
    input [2:0] p_c, e_c0, e_c1, e_c2, e_c3);

	wire [7:0] vgaX;
	wire [6:0] vgaY;
	wire [2:0] vgaColour;
	wire fsmDoneSig;
	wire [3:0] mainDrawSignal;

	displayHandler handler(p_x, e0_x, e1_x, e2_x, e3_x,
			       p_y, e0_y, e1_y, e2_y, e3_y,
			       p_w, p_h, e_w, e_h, p_c,
			       e_c0, e_c1, e_c2, e_c3,
				clk, 1'b1, resetn, mainDrawSignal, vgaX, vgaY, vgaColour, fsmDoneSig);
	drawFSM drawController(fsmDoneSig, clk, resetn, mainDrawSignal);
	
endmodule

/*
Module that acts as a datapath for the drawing FSM and decides which coordinates should be currently sent to the VGA.


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
draw: 
reset: reset signal (active low)
control_signal: determines the coordinates of what object (out of the ones listed above) should be sent to the VGA

vgaX: output signal for the x coordinates going to the VGA
vgaY: output signal for the y coordinates going to the VGA
vgaColour: output signal for the colour of the pixel being drawn to the VGA
fsmDoneSignal: signal that goes to drawFSM to tell it that the current object is done drawing and the state can be switched
*/
module displayHandler(
    input [7:0] p_x, e0_x, e1_x, e2_x, e3_x,
    input [6:0] p_y, e0_y, e1_y, e2_y, e3_y,
    input [4:0] p_w, p_h, e_w, e_h,
    input [2:0] p_c, e_c0, e_c1, e_c2, e_c3,
    input clk, draw, reset,
    input [3:0] control_signal,
    output [7:0] vgaX,
	 output [6:0] vgaY,
	 output [2:0] vgaColour,
	 output fsmDoneSignal
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
            0: begin drawX <= px; drawY <= py; drawWidth <= pw; drawHeight <= ph; drawColour <= pc; end //player
            1: begin drawX <= e0x; drawY <= e0y; drawWidth <= ew; drawHeight <= eh; drawColour <= e0c; end //e1
            2: begin drawX <= e1x; drawY <= e1y; drawWidth <= ew; drawHeight <= eh; drawColour <= e1c; end //e2
            3: begin drawX <= e2x; drawY <= e2y; drawWidth <= ew; drawHeight <= eh; drawColour<= e2c; end //e3
            4: begin drawX <= e3x; drawY <= e3y; drawWidth <= ew; drawHeight <= eh; drawColour <= e3c; end //e4
	    default: begin drawX <= px; drawY <= py; drawWidth <= pw; drawHeight <= ph; drawColour <= pc; end
        endcase
    end

	 //module that produces coordinates that are to be sent to the vga
	 wire [7:0] vgaXOut; //wire to be assigned to vgaX
	 wire [6:0] vgaYOut; //wire to be assigned to vgaY
	 wire [2:0] vgaColourOut; //wire to be assigned to vgaColour
	 wire doneOut; //wire to be assigned to fsmDoneSignal
	 
	 draw mainDrawModule(.x_in(drawX), .y_in(drawY), .width(drawWidth), .height(drawHeight), .c_in(drawColour), .enable((control_signal >= 1'b0)) /*this has to potentially be changed*/, .clk(clk), .reset(reset),
								.x_out(vgaXOut), .y_out(vgaYOut), .c_out(vgaColourOut), .done(doneOut));
								
	 assign vgaX = vgaXOut;
	 assign vgaY = vgaYOut;
	 assign vgaColour = vgaColourOut;
	 assign fsmDoneSignal = doneOut;
endmodule

/*
Module that outputs the coordinates of an object being draw based on the (x, y) of top-left corner and the object's width and height.

x_in: The x coordinate of top-left corner of object being drawn
y_in: The y coordinate of top-left corner of object being drawn
width: The width of the object in binary
height: The height of the object in binary
c_in: The colour to draw the object in
enable: The enable signal for the module 
clk: Circuit clock signal
reset: Circuit reset signal (active low)

x_out: The x coordinate of the current pixel to draw
y_out: The y coordinate of the current pixel to draw
c_out: The colour of the current pixel to draw 
done: Whether the module is done outputting the coordinates for the current object or not
*/

module draw(
    input [7:0] x_in,
    input [6:0] y_in,
    input [4:0] width, height,
    input [2:0] c_in,
    input enable, clk, reset,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] c_out,
    output done
);
    reg [7:0] counterX, xOut; //placeholder for x_out and the counter assosciated with it
    reg [6:0] counterY, yOut; //placeholder for y_out and the counter assosciated with it
    reg done_;						//placeholder for the done output signal

	 //Draw logic
    always @(posedge clk)
    begin
        if (!reset) begin
		      counterX <= 0;
				counterY <= 0;
            xOut <= x_in;
            yOut <= y_in;
            done_ <= 0;
        end
        else if (enable) begin
		xOut <= x_in;
            yOut <= y_in;
				if (counterX == 0 && counterY == 0)
					done_ <= 0;
		  
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
Draw FSM that controls which object should be currently drawn (ie. which object's coordinates arec counted in drawDisplay and sent to the VGA)

done: whether the object currently being drawn by the display handler has finished being drawn or not
clk: the circuit's clock signal
resetn: reset signal (active low)

mainDrawSignal: binary value representing which object to draw
					0: Player
					1: Enemy 1
					2: Enemy 2
					3: Enemy 3
					4: Enemy 4
					5: Bullet
*/

module drawFSM(done, clk, resetn, mainDrawSignal);
	input done;
	input clk;
	input resetn;
	
	output [3:0] mainDrawSignal;

   reg [3:0] drawSignalOut; //wire to be assigned as the value of the mainDrawSignal
   reg [3:0] current_state, next_state; //registers holding the current and next states, respectively

	 //State constants
    localparam S_DRAW_PLAYER = 4'd0,
               S_DRAW_ENEMY1 = 4'd1,
               S_DRAW_ENEMY2 = 4'd2,
               S_DRAW_ENEMY3 = 4'd3,
               S_DRAW_ENEMY4 = 4'd4,
               S_DRAW_BULLET = 4'd5;

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)           
                S_DRAW_PLAYER: next_state = (done == 1'b1) ? S_DRAW_ENEMY1 : S_DRAW_PLAYER;
                S_DRAW_ENEMY1: next_state = (done == 1'b1) ? S_DRAW_ENEMY2 : S_DRAW_ENEMY1;
                S_DRAW_ENEMY2: next_state = (done == 1'b1) ? S_DRAW_ENEMY3 : S_DRAW_ENEMY2;
                S_DRAW_ENEMY3: next_state = (done == 1'b1) ? S_DRAW_ENEMY4 : S_DRAW_ENEMY3;
                S_DRAW_ENEMY4: next_state = (done == 1'b1) ? S_DRAW_BULLET : S_DRAW_ENEMY4;
                S_DRAW_BULLET: next_state = (done == 1'b1) ? S_DRAW_PLAYER : S_DRAW_BULLET;
            default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; //by default, draw the player

        case (current_state)
            S_DRAW_PLAYER: drawSignalOut <= 4'd0;
            S_DRAW_ENEMY1: drawSignalOut <= 4'd1;
            S_DRAW_ENEMY2: drawSignalOut <= 4'd2;
            S_DRAW_ENEMY3: drawSignalOut <= 4'd3;
            S_DRAW_ENEMY4: drawSignalOut <= 4'd4;
            S_DRAW_BULLET: drawSignalOut <= 4'd5;
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_DRAW_PLAYER;
        end
        else 
            current_state <= next_state;
	
       
    end // state_FFS

    assign mainDrawSignal = drawSignalOut;

endmodule