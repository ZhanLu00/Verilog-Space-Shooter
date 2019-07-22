module main(
	input CLOCK_50,
	input [3:0] KEY,
	inout PS_CLK, PS2_DAT,
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK_N,					//	VGA BLANK
	output VGA_SYNC_N,						//	VGA SYNC
	output [9:0] VGA_R,   						//	VGA Red[9:0]
	output [9:0] VGA_G,	 						//	VGA Green[9:0]
	output [9:0] VGA_B 
);

	wire clk, resetn;
	assign resetn = KEY[0];
	assign clk = CLOCK_50;

	// wire for draw fsm
	wire [3:0] drawSig;
	wire enable_draw;

	// wire for i/o of p/e position and color
	wire [7:0] playerX, eX0, eX1, eX2, eX3;
    wire [6:0] playerY, eY0, eY1, eY2, eY3;
    wire go1, go2, go3, go4, reset_N0, reset_N1, reset_N2, reset_N3;
    wire [2:0] playerColour, colourE1, colourE2, colourE3, colourE4;
    wire plot1, plot2, plot3, plot4;

    // 
    wire [7:0] x_draw;
    wire [6:0] y_draw;
    wire [4:0] w_draw, h_draw;
    wire [2:0] c_draw;

    //
    wire [7:0] finalX;
    wire [6:0] finalY;
    wire [2:0] finalC;
    wire finalDone;

    // for keyboard
    wire dPressed, aPressed;



	// draw fsm
	drawFSM draw_control(
        .clk(clk), 
        .resetn(resetn), 
        .done(done_out),
        .mainDrawSignal(drawSig),
        .enable(enable_draw)
    );

    // draw datapath
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
        .p_w(5'd10),
        .p_h(5'd10),
        .e_w(5'd10),
        .e_h(5'd10),
        .p_c(playerColour),
        .e_c0(colourE1),
        .e_c1(colourE2),
        .e_c2(colourE3),
        .e_c3(colourE4),
        .clk(clock),
        .draw(enable_draw),
        .reset(resetn),
        .control_signal(drawSig),
        .start_x(x_draw),
        .start_y(y_draw),
        .width(w_draw),
        .height(h_draw),
        .color(c_draw)
    );


    //initiate draw 
    draw d(
        .x_in(x_draw),
        .y_in(y_draw),
        .width(w_draw), 
        .height(h_draw),
        .c_in(c_draw),
        .draw(enable_draw), 
        .clk(clock), 
        .reset(resetn),
        .x_out(finalX),
        .y_out(finalY),
        .c_out(finalC),
        .done(finalDone)
    );


    wire ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;
    //player movement FSM
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

endmodule