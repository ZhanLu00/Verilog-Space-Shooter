module enemyControl(clk, resetn, enable, updatePosition, bottomReached, inResetState, inUpdatePositionStateE, collidedWithBullet, collidedWithPlayer, maxHealth, currHealth, score);
	input clk, resetn, enable, updatePosition, bottomReached, collidedWithBullet, collidedWithPlayer;
	output reg [2:0] maxHealth;
	output reg [2:0] currHealth;
	output reg inResetState, inUpdatePositionStateE; //booleans for being in a given state or not
	reg [3:0] current_state, next_state; 
   input [7:0] score;
	 
	wire [23:0] randOut;
	wire randDone;
	wire [23:0] delayInSeconds;
	reg generateDelay;
	reg [3:0] delay;
	reg [31:0] delayCounter;
	 
   localparam  S_RESET        = 4'd0,
               S_UPDATE_POSITION      = 4'd1,
               S_WAIT                 = 4'd2,
					S_GENERATE_DELAY = 4'd3; 


	 // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_RESET: next_state = (delay == 0) ? S_UPDATE_POSITION : S_RESET; 
					 S_UPDATE_POSITION: next_state = (bottomReached || collidedWithPlayer || (currHealth == 0)) ? S_GENERATE_DELAY : S_WAIT;
                S_WAIT: next_state = (updatePosition) ? S_UPDATE_POSITION : S_WAIT;
					 S_GENERATE_DELAY: next_state = S_RESET;
					 
            default:     next_state = S_RESET;
        endcase
    end // state_table



	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        inResetState <= 1'b0;
		  inUpdatePositionStateE <= 0;
		  generateDelay <= 0;
		  
        case (current_state)
            S_RESET: inResetState <= 1'b1;
				S_UPDATE_POSITION: inUpdatePositionStateE <= 1;
				S_GENERATE_DELAY: generateDelay <= 1;
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn) begin
            current_state <= S_RESET;
				delayCounter <= 32'd25000000;
				delay <= 4'd1;

		  end	
		  else begin

				if (generateDelay)
					delay <= delayInSeconds[3:0];
				if (current_state == S_RESET) begin

					if (score > 8'd30)
						maxHealth <= 3'd3;
					else if (score >= 8'd10)
						maxHealth <= 3'd2;
					else maxHealth <= 3'd1;
					
					if(currHealth <= 0)
						currHealth <= maxHealth;
				
					if (delayCounter > 0)
						delayCounter <= delayCounter - 1;
					else begin
						delayCounter <= 32'd25000000;
						
						if (delay > 0)
							delay <= delay - 1;
						else
							delay <= 4'd1;
					end
				end
				
				if(updatePosition && (collidedWithBullet) && currHealth > 0 && current_state != S_RESET)
					currHealth <= currHealth - 1;
				
				current_state <= next_state;
				if(currHealth <= 0)
						currHealth <= maxHealth;
						
			end
    end // state_FFS
	 
	 //generating random delay
	 LFSR #(.NUM_BITS(24)) randomNumGenerator(clk, generateDelay, 0, 0, randOut, randDone);
	 assign delayInSeconds = ({randOut} % 4) + 1;
	 
	
endmodule

	
	
	