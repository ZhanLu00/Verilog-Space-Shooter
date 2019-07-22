module playerMovement(clock, resetn, aP, dP, x_out, y_out);
    input clock, resetn, aP, dP;
	output [7:0] x_out;
	output [6:0] y_out;
    wire [7:0] x;
    wire [6:0] y;
    wire [2:0] colour_out;

    wire ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;

    playerMovementFSM c1(
        .clk(clock),
        .resetn(resetn), 
        .ld_pos1(ld_pos1), 
        .ld_pos2(ld_pos2), 
        .ld_pos3(ld_pos3), 
        .ld_pos4(ld_pos4), 
        .inEraseState(inEraseState), 
        .inDrawState(inDrawState), 
        .aPressed(aP), 
        .dPressed(dP)
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
	    .x_out(x),
	    .y_out(y),
	    .color_out(colour_out)
    );

	assign x_out = x;
	assign y_out = y;
    
endmodule   

module playerMovementFSM(clk, resetn, ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState, aPressed, dPressed);
	input clk, resetn, aPressed, dPressed;
	
	output reg ld_pos1, ld_pos2, ld_pos3, ld_pos4, inEraseState, inDrawState;
	
	reg [3:0] current_state, next_state, previous_state, after_erase_state; 
    	reg [7:0] drawCounter;

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
		  if (next_state != current_state && (current_state == S_POS1 || current_state == S_POS2 || current_state == S_POS3 || current_state == S_POS4))
				previous_state <= current_state;
				current_state <= next_state;
		  end
        if (current_state == S_ERASE || current_state == S_DRAW) begin
            if (drawCounter < 8'd99)
                drawCounter <= drawCounter + 1;
            else
                drawCounter <= 8'd0;
        end
    end // state_FFS


endmodule

module playData(
	input ld_1, ld_2, ld_3, ld_4,
	input clock, reset, erase, draw,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out);

	reg [7:0] xout;
	reg [2:0] cout;
	
    	
	 
	localparam	x1 = 8'd14,
			x2 = 8'd54,
			x3 = 8'd94,
			x4 = 8'd134,
			y  = 7'd99,
			COLOR = 3'b111;

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

	
	assign x_out = xout;
	assign y_out = y;
	assign color_out = cout;

endmodule
