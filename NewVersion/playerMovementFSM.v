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
					S_SET_A: next_state = S_UPDATE_POSITION;
					
					S_SET_D: next_state = S_UPDATE_POSITION;
					
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

