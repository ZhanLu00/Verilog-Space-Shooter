module enemy(
        input [2:0] colour,
        input go1, go2,, go3, go4, clk, reset_N0, reset_N1, reset_N2, reset_N3,
        output [7:0] x_out0, x_out1, x_out2, x_out3,
        output [6:0] y_out0, y_out1, y_out2, y_out3,
        output [2:0] colour_out0, colour_out1, colour_out2, colour_out3,
        output plot    
);

    wire reset_C0, reset_C1, reset_C2, reset_C3;
    wire en_XY0, en_XY1, en_XY2, en_XY3;
    wire en_de0, en_de1, en_de2, en_de3;
    wire erase0, erase1, erase2, erase3;
    wire p0, p1, p2, p3;
    wire hold0, hold1, hold2, hold3; 
    wire done0, done1, done2, done3;

    localparam X0   = 8'd14,
               Y0   =,
               X1   = 8'd54,
               Y1   =,
               X2   = 8'd94,
               Y2   =,
               X3   =,
               Y3   =;

    wire [7:0] x0out, x1out, x2out, x3out;
    wire [6:0] y0out, y1out, y2out, y3out;
    wire [2:0] c_out0, c_out1, c_out2, c_oiut3;


	
    // initiate four enemy
    control_enemy c0(
        .go(go0),
        .clk(clk),
        .reset_N(reset_N0),
        .hold(hold0),
        .done(done0),
        .reset_C(reset_C0),
        .en_XY(en_XY0),
        .en_de(en_de0),
        .erase(erase0),
        .plot(p0)
    )

    datapath_enemy d0(
        .reset_C(reset_C0),
        .reset_N(reset_N0),
        .clk(clk),
        .enable_delay(en_de0),
        .enable_XY(en_XY)0,
        .erase(erase0),
        .plot(p0)
        .xIn(X0),
        .yIn(Y0),
        .colour(colour),
        .x_output(x0out),
        .y_output(y0out),
        .colour_out(c_out0),
        .hold(hold0),
        .done(done)
    );
    
        control_enemy c1(
        .go(go1),
        .clk(clk),
        .reset_N(reset_N1),
        .hold(hold1),
        .done(done1),
        .reset_C(reset_C1),
        .en_XY(en_XY1),
        .en_de(en_de1),
        .erase(erase1),
        .plot(p1)
    )

    datapath_enemy d1(
        .reset_C(reset_C1),
        .reset_N(reset_N1),
        .clk(clk),
        .enable_delay(en_de1),
        .enable_XY(en_XY1),
        .erase(erase1),
        .plot(p1)
        .xIn(X1),
        .yIn(Y1),
        .colour(colour),
        .x_output(x1out),
        .y_output(y1out),
        .colour_out(c_out1),
        .hold(hold1),
        .done(done1)
    );

        control_enemy c2(
        .go(go2),
        .clk(clk),
        .reset_N(reset_N2),
        .hold(hold2),
        .done(done2),
        .reset_C(reset_C2),
        .en_XY(en_XY2),
        .en_de(en_de2),
        .erase(erase2),
        .plot(p2)
    )

    datapath_enemy d2(
        .reset_C(reset_C2),
        .reset_N(reset_N2),
        .clk(clk),
        .enable_delay(en_de2),
        .enable_XY(en_XY2),
        .erase(erase2),
        .plot(p2)
        .xIn(X2),
        .yIn(Y2),
        .colour(colour),
        .x_output(x2out),
        .y_output(y2out),
        .colour_out(c_out2),
        .hold(hold2),
        .done(done2)
    );

        control_enemy c3(
        .go(go3),
        .clk(clk),
        .reset_N(reset_N3),
        .hold(hold3),
        .done(done3),
        .reset_C(reset_C3),
        .en_XY(en_XY3),
        .en_de(en_de3),
        .erase(erase3),
        .plot(p3)
    )

    datapath_enemy d3(
        .reset_C(reset_C33),
        .reset_N(reset_N),
        .clk(clk),
        .enable_delay(en_de3),
        .enable_XY(en_XY3),
        .erase(erase3),
        .plot(p3)
        .xIn(X3),
        .yIn(Y3),
        .colour(colour),
        .x_output(x3out),
        .y_output(y3out),
        .colour_out(c_out3),
        .hold(hold3),
        .done(done3)
    );

endmodule

module control_enemy(
	input go, clk, reset_N,hold,done,
	output reg reset_C, en_XY, en_de, erase, plot
	);

	// draw -> erase ->update -> keep going
	
	reg [2:0] current_state, next_state;

	localparam START = 3'd0,
			   START_WAIT = 3'd1,
			   DRAW = 3'd2,
			   DELAY = 3'd3,
			   ERASE = 3'd4,
			   UPDATE_XY= 3'd5;

	always @(*)
	begin : enemy_statetable
		case (current_state)
			START: next_state = go? START_WAIT: START; 
			START_WAIT: next_state = go? START_WAIT: DRAW;
			DRAW: next_state = done? DELAY : DRAW; 
			DELAY: next_state = hold? ERASE: DELAY;
			ERASE: next_state = done? UPDATE_XY: ERASE;
			UPDATE_XY: next_state = DRAW;
		endcase	
	end
	
	// set proper output for current state
	always @(*)
	begin
		reset_C = 0;
		en_XY = 0;
		en_de = 0;
		erase = 0;
		plot = 0;
		case (current_state)
			DRAW: plot = 1;
			DELAY: begin reset_C = 1; en_de = 1; end
			ERASE: begin erase = 1; plot = 1; end
			UPDATE_XY: en_XY = 1;	
		endcase	
	end	

	always @(posedge clk)
	begin
		if (!reset_N)
			current_state <= START;
		else
			current_state <= next_state;
	end

endmodule

module datapath_enemy(
	input reset_C, reset_N, clk, enable_delay, enable_XY, erase, plot,
	input [7:0] xIn,
	input [6:0] yIn,
	input [2:0] colour,
	
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] colour_out,

	output reg  hold, done
	);
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] colour_reg;
	reg down;
	reg [7:0] count;
	reg [19:0] delay_count;
	reg [7:0] frame; 
	reg bottom_reached;

	//XY counter logic
	always @(posedge clk)
	begin
		if(!reset_N || bottom_reached)
		begin
			x <= xIn;
			y <= 7'b0;
			down <= 1'b0;
			bottom_reached <= 0;
		end
		else if (enable_XY)
		begin
			if(down) begin
				y <= y + 1;
				// when enemy touches the bottom
				if (y + 1'd9 == 3'd119)
					bottom_reached <= 1;		
			end
			
		end
	end

	//delay&frame counter
	always @(posedge clk)
	begin
		if (!reset_N || !reset_C) begin
			delay_count <= 0;
			frame <= 0;
			hold <= 0;
		end
		else if (enable_delay) begin
			if (delay_count == 6'd8333333) begin
				delay_count <= 0;
				frame <= frame + 1;
			end
			else
				delay_count <= delay_count + 1;

			if (frame == 8'b10011001) 
				hold <= 1;		
			end					
	end
	
	always @(posedge clk)
	begin
		if(!reset_N)
			colour_reg <= 0;
		else 
			if (erase)
				colour_reg <= 0;
			else
				colour_reg <= colour;
			
	end

	//counter
	always @(posedge clk)
	begin
		if(!reset_N) begin
			count <= 0;
			done <= 0;
		end
		else if (!plot) begin
			count <= 0;
			done <= 0;		
		end
		else if (count == 8'b10011001) begin
					count <= 0;
					done <= 1;
				end			
		else
			count <= count + 1'b1;	
						
	end

	assign x_out = x + count[3:0];
	assign y_out = y + count[7:4];
	assign colour_out = colour_reg;

endmodule