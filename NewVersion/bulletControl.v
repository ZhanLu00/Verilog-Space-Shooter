module bulletControl(clk, resetn, inResetState,inUpdatePositionState, inWaitState, spacePressed, updatePosition, topReached, collidedWithEnemy);
	input clk, resetn, updatePosition, topReached, spacePressed, collidedWithEnemy;
	
	output reg inResetState, inUpdatePositionState, inWaitState; //booleans for being in a given state or not

	
	reg [3:0] current_state, next_state; 
    
   localparam  S_RESET        = 4'b0,/*
														In this state the delayCounter is reset to however many clock cycles 1/60 of a second is
														The frame counter is reset to 0
														X counter is set to 0
														Y counter is set to 60
									
														Erase current box (fill current coordinates with black)
												  */
               S_UPDATE_POSITION      = 4'b1,/*
														Update X, Y counters based on dir register
														Update dir register if necessary
											    */
                S_WAIT                 = 4'b0010; /*    the state that is waiting to update position and happends during enemy spawn*/


	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_RESET: next_state = (spacePressed) ? S_UPDATE_POSITION : S_RESET; 
					 S_UPDATE_POSITION: next_state = (topReached || collidedWithEnemy) ? S_RESET : S_WAIT;
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
		  inWaitState <= 0;
        case (current_state)
            S_RESET: inResetState <= 1'b1;
			S_UPDATE_POSITION: inUpdatePositionState <= 1'b1;
			S_WAIT: inWaitState <= 1;
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