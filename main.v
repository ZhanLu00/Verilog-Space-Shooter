module main(
    input CLOCK_50, input [3:0] KEY,
    inout PS_CLK, PS2_DAT,
    		// The ports below are for the VGA output.  Do not change.
		output VGA_CLK,   						//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,					//	VGA BLANK
		output VGA_SYNC_N,						//	VGA SYNC
		output [9:0] VGA_R,   						//	VGA Red[9:0]
		output [9:0] VGA_G,	 						//	VGA Green[9:0]
		output [9:0] VGA_B   
);



    wire resetn, clk;
    assign resetn = ~KEY[0];
    assign clk = CLOCK_50;



    wire [3:0] mainDrawSignal;
    wire done_out, enable_draw;

		
		//VGA Code
		wire [7:0] x;
		wire [6:0] y;
		wire [2:0] colour_out;
		
		vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour_out),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
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

    //Keyboard
    wire aPressed, dPressed, sPressed, wPressed, leftPressed, rightPressed, upPressed, downPressed, spacePressed, enterPressed;
    keyboard_tracker #(.PULSE_OR_HOLD(0)) keyboard(
	      .clock(clk),
		  .reset(resetn),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(wPressed),
		  .a(aPressed),
		  .s(sPressed),
		  .d(dPressed),
		  .left(leftPressed),
		  .right(rightPressed),
		  .up(upPressed),
		  .down(downPressed),
		  .space(spacePressed),
		  .enter(enterPressed)
		  );

    wire x_draw, y_draw, w_draw, h_draw, c_draw;

    //initiate draw 
    draw d(
        .x_in(x_draw),
        .y_in(y_draw),
        .width(w_draw), 
        .height(h_draw),
        .c_in(c_draw),
        .draw(enable_draw), 
        .clk(clk), 
        .reset(~resetn),
        .x_out(x),
        .y_out(y),
        .c_out(colour_out),
        .done(done_out)
    );

    // initiate draw datapath
    displayHandler draw_datapath(
        .p_x(playerX),
        .e0_x(eX0),
        .e1_x(eX1),
        .e2_x(eX2),
        .e3_x(eX3),
        .p_y(playerY),
        .e0_y(eY0),
        .e1_y(eY1),
        .e2_y(eY2),
        .e3_y(eY3),
        .p_w(4'd10),
        .p_h(4'd10),
        .e_w(4'd10),
        .e_h(4'd10),
        .p_c(playerColour),
        .e_c0(colourE1),
        .e_c1(colourE2),
        .e_c2(colourE3),
        .e_c3(colourE4),
        .clk(clk),
        .draw(enable_draw),
        .reset(~resetn),
        .control_signal(mainDrawSignal),
        .start_x(x_draw),
        .start_y(y_draw),
        .width(w_draw),
        .height(h_draw),
        .color(c_draw)
    );

    // initiate draw fsm
    drawFSM draw_control(
        .mainDrawSignal(mainDrawSignal), 
        .clk(clk), 
        .resetn(resetn), 
        .done(done_out),
        .enable(enable_draw)
    );

    //player movement FSM
    wire ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;
    playerMovementFSM c1(
        .clk(clk),
        .resetn(resetn), 
        .ld_pos1(ld_pos1), 
        .ld_pos2(ld_pos2), 
        .ld_pos3(ld_pos3), 
        .ld_pos4(ld_pos4), 
        .inEraseState(inEraseState), 
        .inDrawState(inDrawState), 
        .aPressed(aPressed), 
        .dPressed(dPressed)
    );
    
    

    //player datapath
    wire [7:0] playerX;
    wire [6:0] playerY;
    wire [2:0] playerColour;

    playData p1(
        .ld_1(ld_pos1),
        .ld_2(ld_pos2),
        .ld_3(ld_pos3),
        .ld_4(ld_pos4),
        .clock(clock), 
        .reset(resetn),
        .erase(inEraseState),
        .draw(inDrawState),
        .x_out(playerX),
        .y_out(playery),
        .color_out(playerColour)
    );

    //Enemy
    wire [7:0] eX0, eX1, eX2, eX3;
    wire [6:0] eY0, eY1, eY2, eY3;
    wire go1, go2, go3, go4, reset_N0, reset_N1, reset_N2, reset_N3;
    wire [2:0] colourE1, colourE2, colourE3, colourE4;
    wire plot1, plot2, plot3, plot4;

    assign go1 = ~KEY[1];
    assign go2 = ~KEY[1];
    assign go3 = ~KEY[1];
    assign go4 = ~KEY[1];
    assign reset_N0 = ~KEY[2];
    assign reset_N1 = ~KEY[2];
    assign reset_N2 = ~KEY[2];
    assign reset_N3 = ~KEY[2];

    enemy enemyController(3'b111, go1, go2, go3, go4, clk, reset_N0, reset_N1, reset_N2, reset_N3, eX0, eX1, eX2, eX3, eY0, eY1, eY2, eY3,
                         colourE1, colourE2, colourE3, colourE4, plot1, plot2, plot3, plot4);


endmodule

    


    