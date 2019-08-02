module drawFSM(clk, resetn, objectToDraw, vgaPlot, doneDrawing, doneErasing, inEraseState, inUpdatePositionState, inDrawGameoverScreenState, inDrawStartScreenState, spacePressed, playerHealth);

	input clk, resetn, doneDrawing, doneErasing, spacePressed;
	input [3:0] playerHealth;
	output [3:0] objectToDraw;
	output vgaPlot;
	output reg inEraseState, inUpdatePositionState, inDrawGameoverScreenState, inDrawStartScreenState; 

	reg [3:0] drawSignalOut;
	reg [5:0] current_state, next_state;
	reg vgaPlotOut;
	reg [3:0] frameCounter;
	reg [26:0] rateDividerCounter;
	
	localparam S_ERASE = 6'd1,
				  S_DRAW_PLAYER = 6'd2,
				  S_DRAW_BULLET = 6'd3,
				  S_DRAW_ENEMY1 = 6'd4,
				  S_DRAW_ENEMY2 = 6'd5,
				  S_DRAW_ENEMY3 = 6'd6,
				  S_DRAW_ENEMY4 = 6'd7,
				  S_DRAW_HEALTHBAR_M1 = 6'd8,
				  S_DRAW_HEALTHBAR_C1 = 6'd9,
				  S_DRAW_HEALTHBAR_M2 = 6'd10,
				  S_DRAW_HEALTHBAR_C2 = 6'd11, 
				  S_DRAW_HEALTHBAR_M3 = 6'd12,
				  S_DRAW_HEALTHBAR_C3 = 6'd13,
				  S_DRAW_HEALTHBAR_M4 = 6'd14,
				  S_DRAW_HEALTHBAR_C4 = 6'd15,
				  
 				  S_WAIT1 = 6'd16,
				  S_WAIT2 = 6'd17,
				  S_WAIT3 = 6'd18,
				  S_WAIT4 = 6'd19,
				  S_WAIT5 = 6'd20,
				  S_WAIT6 = 6'd21,
				  S_WAIT7 = 6'd22,
				  S_WAIT8 = 6'd23,
				  S_WAIT9 = 6'd24,
				  S_WAIT10 = 6'd25,
				  S_WAIT11 = 6'd26,
				  S_WAIT12 = 6'd27,
				  S_WAIT13 = 6'd28,
				  S_WAIT14 = 6'd29,
				  S_RESET_FRAMES = 6'd30,
				  S_DELAY_UPDATE = 6'd31,
				  S_UPDATE_POSITION = 6'd32,
				  S_DRAW_START_SCREEN = 6'd33,
				  S_DRAW_GAMEOVER_SCREEN = 6'd34;
				  

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)  
					S_DRAW_START_SCREEN: next_state = (spacePressed) ? S_ERASE: S_DRAW_START_SCREEN;
					
					S_DRAW_GAMEOVER_SCREEN: next_state = (spacePressed) ? S_DRAW_START_SCREEN : S_DRAW_GAMEOVER_SCREEN;
		
					S_ERASE: next_state = (doneErasing) ? S_DRAW_PLAYER : S_ERASE;
					
					S_DRAW_PLAYER: next_state = (doneDrawing) ? S_WAIT1 : S_DRAW_PLAYER;
				   S_WAIT1: next_state = S_DRAW_BULLET;
					
					S_DRAW_BULLET: next_state = (doneDrawing) ? S_WAIT6 : S_DRAW_BULLET;
					S_WAIT6: next_state = S_DRAW_ENEMY1;
				
					S_DRAW_ENEMY1: next_state = (doneDrawing) ? S_WAIT2 : S_DRAW_ENEMY1;
					S_WAIT2: next_state = S_DRAW_ENEMY2;
					
					S_DRAW_ENEMY2: next_state = (doneDrawing) ? S_WAIT3 : S_DRAW_ENEMY2;
					S_WAIT3: next_state = S_DRAW_ENEMY3;
					
					S_DRAW_ENEMY3: next_state = (doneDrawing) ? S_WAIT4 : S_DRAW_ENEMY3;
					S_WAIT4: next_state = S_DRAW_ENEMY4;
					
					S_DRAW_ENEMY4: next_state = (doneDrawing) ? S_WAIT5 : S_DRAW_ENEMY4;
					S_WAIT5: next_state = S_DRAW_HEALTHBAR_M1;
					
					S_DRAW_HEALTHBAR_M1: next_state = (doneDrawing) ? S_WAIT7 : S_DRAW_HEALTHBAR_M1;
					S_WAIT7: next_state = S_DRAW_HEALTHBAR_C1;
					
					S_DRAW_HEALTHBAR_C1: next_state = (doneDrawing) ? S_WAIT8 : S_DRAW_HEALTHBAR_C1;
					S_WAIT8: next_state = S_DRAW_HEALTHBAR_M2;
					
					S_DRAW_HEALTHBAR_M2: next_state = (doneDrawing) ? S_WAIT9 : S_DRAW_HEALTHBAR_M2;
					S_WAIT9: next_state = S_DRAW_HEALTHBAR_C2;
					
					S_DRAW_HEALTHBAR_C2: next_state = (doneDrawing) ? S_WAIT10 : S_DRAW_HEALTHBAR_C2;
					S_WAIT10: next_state = S_DRAW_HEALTHBAR_M3;
					
					S_DRAW_HEALTHBAR_M3: next_state = (doneDrawing) ? S_WAIT11 : S_DRAW_HEALTHBAR_M3;
					S_WAIT11: next_state = S_DRAW_HEALTHBAR_C3;
					
					S_DRAW_HEALTHBAR_C3: next_state = (doneDrawing) ? S_WAIT12 : S_DRAW_HEALTHBAR_C3;
					S_WAIT12: next_state = S_DRAW_HEALTHBAR_M4;
					
					S_DRAW_HEALTHBAR_M4: next_state = (doneDrawing) ? S_WAIT13 : S_DRAW_HEALTHBAR_M4;
					S_WAIT13: next_state = S_DRAW_HEALTHBAR_C4;
					
					S_DRAW_HEALTHBAR_C4: next_state = (doneDrawing) ? S_WAIT14 : S_DRAW_HEALTHBAR_C4;
					S_WAIT14: next_state = S_RESET_FRAMES;
					
					S_RESET_FRAMES: next_state = S_DELAY_UPDATE;
					S_DELAY_UPDATE: next_state = (frameCounter == 4'd3/*4'b1111*/) ? S_UPDATE_POSITION : S_DELAY_UPDATE;
					S_UPDATE_POSITION: next_state = (playerHealth >= 1) ? S_ERASE : S_DRAW_GAMEOVER_SCREEN;
					
				default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table

    //control signal change code
    always @(*)
    begin: enable_signals
        drawSignalOut <= 4'b0; 
		  vgaPlotOut <= 1'b0;
		  inEraseState <= 0;
		  inUpdatePositionState <= 0;
		  inDrawStartScreenState <= 0;
		  inDrawGameoverScreenState <= 0;
		  
        case (current_state)
				S_ERASE: begin inEraseState <= 1; vgaPlotOut <= 1; end
				S_DRAW_START_SCREEN: begin inDrawStartScreenState <= 1; vgaPlotOut <= 1; end
				S_DRAW_GAMEOVER_SCREEN: begin inDrawGameoverScreenState <= 1; vgaPlotOut <= 1; end
				S_DELAY_UPDATE: begin vgaPlotOut <= 0; end
				S_UPDATE_POSITION: begin inUpdatePositionState <= 1; vgaPlotOut <= 0; end 
				S_RESET_FRAMES: begin vgaPlotOut <= 0; end
				
				S_DRAW_PLAYER: begin
					drawSignalOut <= 4'd1;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_ENEMY1: begin
					drawSignalOut <= 4'd2;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_ENEMY2: begin
					drawSignalOut <= 4'd3;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_ENEMY3: begin
					drawSignalOut <= 4'd4;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_ENEMY4: begin
					drawSignalOut <= 4'd5;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_BULLET: begin
					drawSignalOut <= 4'd6;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_M1: begin
					drawSignalOut <= 4'd7;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_C1: begin
					drawSignalOut <= 4'd8;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_M2: begin
					drawSignalOut <= 4'd9;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_C2: begin
					drawSignalOut <= 4'd10;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_M3: begin
					drawSignalOut <= 4'd11;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_C3: begin
					drawSignalOut <= 4'd12;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_M4: begin
					drawSignalOut <= 4'd13;
					vgaPlotOut <= 1;
				end
				
				S_DRAW_HEALTHBAR_C4: begin
					drawSignalOut <= 4'd14;
					vgaPlotOut <= 1;
				end
				
				S_WAIT1: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT2: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT3: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT4: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT5: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT6: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT7: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
				S_WAIT8: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT9: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT10: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT11: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT12: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT13: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				S_WAIT14: begin
					vgaPlotOut <= 0;
					drawSignalOut <= 0;
				end
				
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_DRAW_START_SCREEN;
				frameCounter <= 0;
				rateDividerCounter <= 27'd833333;
        end
        else begin
            current_state <= next_state;
				
				if (current_state == S_RESET_FRAMES) begin
					rateDividerCounter <= 27'd833333;
					frameCounter <= 4'b0;
				end
				else if(current_state == S_DELAY_UPDATE) begin			
					if (rateDividerCounter == 0) begin
						frameCounter <= frameCounter + 1'b1;
						rateDividerCounter <= 27'd833333; 
					
						if (frameCounter == 4'd3)
							frameCounter <= 0;
						else
							frameCounter <= frameCounter + 1'b1;
					end
					else
						rateDividerCounter <= rateDividerCounter - 1'b1;
				end
			end
    end // state_FFS

    assign objectToDraw = drawSignalOut;
	 assign vgaPlot = vgaPlotOut;
endmodule