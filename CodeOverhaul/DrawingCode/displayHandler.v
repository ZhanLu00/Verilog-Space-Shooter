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