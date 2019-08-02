/**
 * #############
 * INSTRUCTIONS
 * #############
 *
 * This file contains a module providing a high-level interface for a PS/2
 * keyboard, with output wires indicating the status of each of the keys
 * being tracked by the controller. Which keys are supported can be easily
 * changed, and this module should be adapted to match the needs of each
 * individual project. An additional parameter allows you to choose whether
 * the output wires stay high as long as the key is pressed down, or go
 * high for a single clock cycle when the key is initially pressed.
 *
 * The module in this file was designed for and was only tested on a DE1_SoC
 * FPGA board. Any model of FPGA other than this is not guaranteed to give
 * expected performance.
 *
 * Modules has been provided at the bottom of the page for testing purposes,
 * to see if the keyboard controller works on your board. These test modules
 * should also be modified to suit each individual project, see documentation
 * for the keyboard_interface_test modules for more details. Be sure to run
 * the test module before incorporating this controller into your project.
 *
 * The controller can operate in two modes, controlled by an instantiation
 * parameter in the module named PULSE_OR_HOLD. This parameter can be set
 * by declaring the module as follows:
 *
 * keyboard_tracker #(.PULSE_OR_HOLD(1)) <name>( ... I/O port declarations...
 *
 * Setting PULSE_OR_HOLD high on instantiating the module will cause it to
 * operate in pulse mode, in which the output for each key is sent high for
 * only one clock cycle when the key is pressed. Holding the key will not
 * cause the output to go high a second time. By contrast, if PULSE_OR_HOLD
 * is set low, the module will operate in hold mode, and the output for each
 * key will be high any time the key is pressed down.
 *
 *
 * BUG NOTE:
 * The core driver does not behave normally when at least two of the arrow keys
 * are held at the same time as another arrow key is pressed. This includes
 * instances when three or more arrow keys are pressed simultaneously.
 * Which keys are registered as being pressed in such an event may be undefined.
 *
 *
 * #########################
 * KEYBOARD PROTOCOL PRIMER
 * #########################
 *
 * The keyboard communicates with another device by sending signals through
 * its data wire. A single byte from the keyboard usually forms a code that
 * identifies a specific key. For example, the letter W is identified by the
 * hexidecimal code 1D, and the space bar is identified by hexidecimal 29.
 * When a key is pressed on the keyboard, its code is sent through the bus.
 * When a key is released, a break signal (F0) is sent, followed by the code
 * of the key that was released. Key codes are as specified by Keyboard Scan
 * Code Set 2.
 *
 * Most keys follow this pattern, of sending the key's code as a 'make' (press)
 * signal, and F0 followed by the key's code as a 'break' (release) signal.
 * Some keys follow a different pattern of signals, referred to in this file as
 * secondary codes. The only difference with secondary codes is that each
 * transmission from the keyboard is preceded by a byte with the hexadecimal
 * value E0. For example, the right arrow key will send E0 followed by its code,
 * hex 74, when pressed; it will send E0, F0, and then 74 as a break code.
 *
 * The print screen and pause keys follow neither rules, and have more complicated
 * codes. For that reason, those two keys are not supported by this controller.
 *
 *
 * #############################
 * PERSONALIZING THE CONTROLLER
 * #############################
 *
 * To add a new key to the controller, first find its code from Scan Code Set 2.
 * Then, add a local parameter named <KEY>_CODE containing the key's code. A new
 * output reg port must be added for the key, and internal registers <KEY>_lock
 * and <KEY>_press should be added too. Next, code must be added to the always
 * block inside the module to manage the values of the output.
 * 
 * See the always block for examples of the setups for several different keys.
 * The code for those keys can be copied to implement any additional keys.
 * Places inside the module (excluding output ports) where code needs to be
 * added to implement a new key are marked with TODO labels.
 *
 *
 * ################################
 * INPUT AND OUTPUT SPECIFICATIONS
 * ################################
 *
 * clock - Main clock signal for the controller. This signal is separate from
 *         the keyboard's clock signal, PS2_CLK. This input should be plugged
 *         into the same clock as the rest of the system is synchronized to.
 *
 * reset - Synchronous active-low reset signal. Resetting the controller will
 *         turn off all active keys. Calling a reset while holding keys on the
 *         keyboard may cause only the most recently pressed key to register
 *         again, as a consequence of keyboard protocol.
 *
 * PS2_CLK and PS2_DAT -
 *    These inputs correspond to the PS2_CLK and PS2_DAT signals from the board.
 *    Do NOT use PS2_CLK2 or PS2_DAT2 unless using a PS/2 splitter cable, or else
 *    neither input will be connected to anything.
 *
 * w, a, s, d, left, right, up, down, space, enter -
 *    Signals corresponding to WASD, the four arrow keys, the space bar, and
 *    enter. How these signals operate depends on the setting of PULSE_OR_HOLD.
 *
 *
 * #################
 * ACKNOWLEDGEMENTS
 * #################
 *
 * Credit for low-level PS/2 driver module (also a resource for PS/2 protocol):
 * http://www.eecg.toronto.edu/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html
 *
 */
module keyboard_tracker #(parameter PULSE_OR_HOLD = 0) (
    input clock,
	 input reset,
	 
	 inout PS2_CLK,
	 inout PS2_DAT,
	 
	 output w, a, s, d,
	 output left, right, up, down,
	 output space, enter
	 );
	 
	 // A flag indicating when the keyboard has sent a new byte.
	 wire byte_received;
	 // The most recent byte received from the keyboard.
	 wire [7:0] newest_byte;
	 	 
	 localparam // States indicating the type of code the controller expects
	            // to receive next.
	            MAKE            = 2'b00,
	            BREAK           = 2'b01,
					SECONDARY_MAKE  = 2'b10,
					SECONDARY_BREAK = 2'b11,
					
					// Make/break codes for all keys that are handled by this
					// controller. Two keys may have the same make/break codes
					// if one of them is a secondary code.
					// TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS	
					W_CODE = 8'h1d,
					A_CODE = 8'h1c,
					S_CODE = 8'h1b,
					D_CODE = 8'h23,
					LEFT_CODE  = 8'h6b,
					RIGHT_CODE = 8'h74,
					UP_CODE    = 8'h75,
					DOWN_CODE  = 8'h72,
					SPACE_CODE = 8'h29,
					ENTER_CODE = 8'h5a;
					
    reg [1:0] curr_state;
	 
	 // Press signals are high when their corresponding key is being pressed,
	 // and low otherwise. They directly represent the keyboard's state.
	 // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS	 
    reg w_press, a_press, s_press, d_press;
	 reg left_press, right_press, up_press, down_press;
	 reg space_press, enter_press;
	 
	 // Lock signals prevent a key press signal from going high for more than one
	 // clock tick when pulse mode is enabled. A key becomes 'locked' as soon as
	 // it is pressed down.
	 // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
	 reg w_lock, a_lock, s_lock, d_lock;
	 reg left_lock, right_lock, up_lock, down_lock;
	 reg space_lock, enter_lock;
	 
	 // Output is equal to the key press wires in mode 0 (hold), and is similar in
	 // mode 1 (pulse) except the signal is lowered when the key's lock goes high.
	 // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
    assign w = w_press && ~(w_lock && PULSE_OR_HOLD);
    assign a = a_press && ~(a_lock && PULSE_OR_HOLD);
    assign s = s_press && ~(s_lock && PULSE_OR_HOLD);
    assign d = d_press && ~(d_lock && PULSE_OR_HOLD);

    assign left  = left_press && ~(left_lock && PULSE_OR_HOLD);
    assign right = right_press && ~(right_lock && PULSE_OR_HOLD);
    assign up    = up_press && ~(up_lock && PULSE_OR_HOLD);
    assign down  = down_press && ~(down_lock && PULSE_OR_HOLD);

    assign space = space_press && ~(space_lock && PULSE_OR_HOLD);
    assign enter = enter_press && ~(enter_lock && PULSE_OR_HOLD);
	 
	 // Core PS/2 driver.
	 PS2_Controller #(.INITIALIZE_MOUSE(0)) core_driver(
	     .CLOCK_50(clock),
		  .reset(~reset),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .received_data(newest_byte),
		  .received_data_en(byte_received)
		  );
		  
    always @(posedge clock) begin
	     // Make is default state. State transitions are handled
        // at the bottom of the case statement below.
		  curr_state <= MAKE;
		  
		  // Lock signals rise the clock tick after the key press signal rises,
		  // and fall one clock tick after the key press signal falls. This way,
		  // only the first clock cycle has the press signal high while the
		  // lock signal is low.
		  // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
		  w_lock <= w_press;
		  a_lock <= a_press;
		  s_lock <= s_press;
		  d_lock <= d_press;
		  
		  left_lock <= left_press;
		  right_lock <= right_press;
		  up_lock <= up_press;
		  down_lock <= down_press;
		  
		  space_lock <= space_press;
		  enter_lock <= enter_press;
		  
	     if (~reset) begin
		      curr_state <= MAKE;
				
				// TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
				w_press <= 1'b0;
				a_press <= 1'b0;
				s_press <= 1'b0;
				d_press <= 1'b0;
				left_press  <= 1'b0;
				right_press <= 1'b0;
				up_press    <= 1'b0;
				down_press  <= 1'b0;
				space_press <= 1'b0;
				enter_press <= 1'b0;
				
				w_lock <= 1'b0;
				a_lock <= 1'b0;
				s_lock <= 1'b0;
				d_lock <= 1'b0;
				left_lock  <= 1'b0;
				right_lock <= 1'b0;
				up_lock    <= 1'b0;
				down_lock  <= 1'b0;
				space_lock <= 1'b0;
				enter_lock <= 1'b0;
        end
		  else if (byte_received) begin
		      // Respond to the newest byte received from the keyboard,
				// by either making or breaking the specified key, or changing
				// state according to special bytes.
				case (newest_byte)
				    // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
		          W_CODE: w_press <= curr_state == MAKE;
					 A_CODE: a_press <= curr_state == MAKE;
					 S_CODE: s_press <= curr_state == MAKE;
					 D_CODE: d_press <= curr_state == MAKE;
					 
					 LEFT_CODE:  left_press  <= curr_state == MAKE;
					 RIGHT_CODE: right_press <= curr_state == MAKE;
					 UP_CODE:    up_press    <= curr_state == MAKE;
					 DOWN_CODE:  down_press  <= curr_state == MAKE;
					 
					 SPACE_CODE: space_press <= curr_state == MAKE;
					 ENTER_CODE: enter_press <= curr_state == MAKE;

					 // State transition logic.
					 // An F0 signal indicates a key is being released. An E0 signal
					 // means that a secondary signal is being used, which will be
					 // followed by a regular set of make/break signals.
					 8'he0: curr_state <= SECONDARY_MAKE;
					 8'hf0: curr_state <= curr_state == MAKE ? BREAK : SECONDARY_BREAK;
		      endcase
        end
        else begin
		      // Default case if no byte is received.
		      curr_state <= curr_state;
		  end
    end
endmodule



/**
 * Tester module for mode 1 (pulse). LEDs on the board should flip once as soon
 * as the corresponding key is pressed down. Holding a key should not continue
 * to change the output, nor should the output change on key release.
 */ 
module keyboard_interface_test_mode1(
    input CLOCK_50,
	 input [3:0] KEY,
	 
	 inout PS2_CLK,
	 inout PS2_DAT,
	 
	 output [9:0] LEDR
	 );
	 
	 // Wires representing direct output from the keyboard controller.
	 wire w_pulse,
	      a_pulse,
			s_pulse,
			d_pulse,
			left_pulse,
			right_pulse,
			up_pulse,
			down_pulse,
			space_pulse,
			enter_pulse;
			
    // Registers holding the values displayed on the LEDs.
    reg  w_tot,
	      a_tot,
			s_tot,
			d_tot,
			left_tot,
			right_tot,
			up_tot,
			down_tot,
			space_tot,
			enter_tot;

    assign LEDR[4] = w_tot;
	 assign LEDR[5] = a_tot;
	 assign LEDR[6] = s_tot;
	 assign LEDR[7] = d_tot;
	 assign LEDR[0] = left_tot;
	 assign LEDR[1] = right_tot;
	 assign LEDR[2] = up_tot;
	 assign LEDR[3] = down_tot;
	 assign LEDR[8] = space_tot;
	 assign LEDR[9] = enter_tot;
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(1)) tester_mode1(
	     .clock(CLOCK_50),
		  .reset(KEY[0]),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(w_pulse),
		  .a(a_pulse),
		  .s(s_pulse),
		  .d(d_pulse),
		  .left(left_pulse),
		  .right(right_pulse),
		  .up(up_pulse),
		  .down(down_pulse),
		  .space(space_pulse),
		  .enter(enter_pulse)
		  );

    always @(posedge CLOCK_50) begin
	     if (~KEY[0]) begin
		      // Reset signal
		      w_tot <= 1'b0;
				a_tot <= 1'b0;
				s_tot <= 1'b0;
				d_tot <= 1'b0;
				
				left_tot  <= 1'b0;
				right_tot <= 1'b0;
				up_tot    <= 1'b0;
				down_tot  <= 1'b0;
				
				space_tot <= 1'b0;
				enter_tot <= 1'b0;
		  end
		  else begin
		      // State display wires (xxx_tot) flip values when their
				// corresponding key is pressed.
	         w_tot <= w_tot + w_pulse;
		      a_tot <= a_tot + a_pulse;
		      s_tot <= s_tot + s_pulse;
		      d_tot <= d_tot + d_pulse;
				
		      left_tot <= left_tot + left_pulse;
		      right_tot <= right_tot + right_pulse;
		      up_tot <= up_tot + up_pulse;
		      down_tot <= down_tot + down_pulse;
				
		      space_tot <= space_tot + space_pulse;
		      enter_tot <= enter_tot + enter_pulse;
		  end
    end
endmodule