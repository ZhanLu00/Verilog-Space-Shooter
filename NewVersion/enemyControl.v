module enemyControl(clk, resetn, enable, updatePosition, bottomReached, inResetState, inUpdatePositionStateE, collidedWithBullet, collidedWithPlayer, HEX, maxHealth, currHealth);
	input clk, resetn, enable, updatePosition, bottomReached, collidedWithBullet, collidedWithPlayer;
	output reg [2:0] maxHealth;
	output reg [2:0] currHealth;
	output [6:0] HEX;
	output reg inResetState, inUpdatePositionStateE; //booleans for being in a given state or not
	reg [3:0] current_state, next_state; 
    
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
				delayCounter <= 32'd25000000;//32'd50000000;
				delay <= 4'd1;
				maxHealth <= 3'd2;
				currHealth <= maxHealth;
		  end	
		  else begin
				if (generateDelay)
					delay <= delayInSeconds[3:0];
				if (current_state == S_RESET) begin
					if (delayCounter > 0)
						delayCounter <= delayCounter - 1;
					else begin
						delayCounter <= 32'd25000000;//32'd500000000;
						
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
	 
	 //outputting delay onto hex
	 decoder7 timer(HEX, delay[3:0]);
	
endmodule

/*
///////////////////////////////////////////////////////////////////////////////
// File downloaded from http://www.nandland.com
///////////////////////////////////////////////////////////////////////////////
// Description: 
// A LFSR or Linear Feedback Shift Register is a quick and easy way to generate
// pseudo-random data inside of an FPGA.  The LFSR can be used for things like
// counters, test patterns, scrambling of data, and others.  This module
// creates an LFSR whose width gets set by a parameter.  The o_LFSR_Done will
// pulse once all combinations of the LFSR are complete.  The number of clock
// cycles that it takes o_LFSR_Done to pulse is equal to 2^g_Num_Bits-1.  For
// example setting g_Num_Bits to 5 means that o_LFSR_Done will pulse every
// 2^5-1 = 31 clock cycles.  o_LFSR_Data will change on each clock cycle that
// the module is enabled, which can be used if desired.
//
// Parameters:
// NUM_BITS - Set to the integer number of bits wide to create your LFSR.
///////////////////////////////////////////////////////////////////////////////
module LFSR #(parameter NUM_BITS)
  (
   input i_Clk,
   input i_Enable,
 
   // Optional Seed Value
   input i_Seed_DV,
   input [NUM_BITS-1:0] i_Seed_Data,
 
   output [NUM_BITS-1:0] o_LFSR_Data,
   output o_LFSR_Done
   );
 
  reg [NUM_BITS:1] r_LFSR = 0;
  reg              r_XNOR;
 
 
  // Purpose: Load up LFSR with Seed if Data Valid (DV) pulse is detected.
  // Othewise just run LFSR when enabled.
  always @(posedge i_Clk)
    begin
      if (i_Enable == 1'b1)
        begin
          if (i_Seed_DV == 1'b1)
            r_LFSR <= i_Seed_Data;
          else
            r_LFSR <= {r_LFSR[NUM_BITS-1:1], r_XNOR};
        end
    end
 
  // Create Feedback Polynomials.  Based on Application Note:
  // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
  always @(*)
    begin
      case (NUM_BITS)
        3: begin
          r_XNOR = r_LFSR[3] ^~ r_LFSR[2];
        end
        4: begin
          r_XNOR = r_LFSR[4] ^~ r_LFSR[3];
        end
        5: begin
          r_XNOR = r_LFSR[5] ^~ r_LFSR[3];
        end
        6: begin
          r_XNOR = r_LFSR[6] ^~ r_LFSR[5];
        end
        7: begin
          r_XNOR = r_LFSR[7] ^~ r_LFSR[6];
        end
        8: begin
          r_XNOR = r_LFSR[8] ^~ r_LFSR[6] ^~ r_LFSR[5] ^~ r_LFSR[4];
        end
        9: begin
          r_XNOR = r_LFSR[9] ^~ r_LFSR[5];
        end
        10: begin
          r_XNOR = r_LFSR[10] ^~ r_LFSR[7];
        end
        11: begin
          r_XNOR = r_LFSR[11] ^~ r_LFSR[9];
        end
        12: begin
          r_XNOR = r_LFSR[12] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
        end
        13: begin
          r_XNOR = r_LFSR[13] ^~ r_LFSR[4] ^~ r_LFSR[3] ^~ r_LFSR[1];
        end
        14: begin
          r_XNOR = r_LFSR[14] ^~ r_LFSR[5] ^~ r_LFSR[3] ^~ r_LFSR[1];
        end
        15: begin
          r_XNOR = r_LFSR[15] ^~ r_LFSR[14];
        end
        16: begin
          r_XNOR = r_LFSR[16] ^~ r_LFSR[15] ^~ r_LFSR[13] ^~ r_LFSR[4];
          end
        17: begin
          r_XNOR = r_LFSR[17] ^~ r_LFSR[14];
        end
        18: begin
          r_XNOR = r_LFSR[18] ^~ r_LFSR[11];
        end
        19: begin
          r_XNOR = r_LFSR[19] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        20: begin
          r_XNOR = r_LFSR[20] ^~ r_LFSR[17];
        end
        21: begin
          r_XNOR = r_LFSR[21] ^~ r_LFSR[19];
        end
        22: begin
          r_XNOR = r_LFSR[22] ^~ r_LFSR[21];
        end
        23: begin
          r_XNOR = r_LFSR[23] ^~ r_LFSR[18];
        end
        24: begin
          r_XNOR = r_LFSR[24] ^~ r_LFSR[23] ^~ r_LFSR[22] ^~ r_LFSR[17];
        end
        25: begin
          r_XNOR = r_LFSR[25] ^~ r_LFSR[22];
        end
        26: begin
          r_XNOR = r_LFSR[26] ^~ r_LFSR[6] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        27: begin
          r_XNOR = r_LFSR[27] ^~ r_LFSR[5] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
        28: begin
          r_XNOR = r_LFSR[28] ^~ r_LFSR[25];
        end
        29: begin
          r_XNOR = r_LFSR[29] ^~ r_LFSR[27];
        end
        30: begin
          r_XNOR = r_LFSR[30] ^~ r_LFSR[6] ^~ r_LFSR[4] ^~ r_LFSR[1];
        end
        31: begin
          r_XNOR = r_LFSR[31] ^~ r_LFSR[28];
        end
        32: begin
          r_XNOR = r_LFSR[32] ^~ r_LFSR[22] ^~ r_LFSR[2] ^~ r_LFSR[1];
        end
 
      endcase // case (NUM_BITS)
    end // always @ (*)
 
 
  assign o_LFSR_Data = r_LFSR[NUM_BITS:1];
 
  // Conditional Assignment (?)
  assign o_LFSR_Done = (r_LFSR[NUM_BITS:1] == i_Seed_Data) ? 1'b1 : 1'b0;
 
endmodule // LFSR*/
	
	
	
	