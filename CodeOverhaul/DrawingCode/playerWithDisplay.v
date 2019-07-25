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

	playerMovementFSM playerMovement();


	displayHandler handler(p_x, e0_x, e1_x, e2_x, e3_x,
			       p_y, e0_y, e1_y, e2_y, e3_y,
			       p_w, p_h, e_w, e_h, p_c,
			       e_c0, e_c1, e_c2, e_c3,
				clk, enableLoad, resetn, mainDrawSignal, vgaX, vgaY, vgaColour, fsmDoneSig, enableDraw);
	drawFSM drawController(fsmDoneSig, clk, resetn, mainDrawSignal, enableDraw, enableLoad);



endmodule