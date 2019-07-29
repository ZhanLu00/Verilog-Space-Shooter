module drawFSM(clk, resetn, objectToDraw, vgaPlot, doneDrawing, doneErasing, inEraseState, inUpdatePositionState);

	input clk, resetn, doneDrawing, doneErasing;
	output [3:0] objectToDraw;
	output vgaPlot;
	output reg inEraseState, inUpdatePositionState; 

	reg [3:0] drawSignalOut;
	reg [4:0] current_state, next_state;
	reg vgaPlotOut;
	reg [3:0] frameCounter;
	reg [26:0] rateDividerCounter;
	
	localparam S_ERASE = 5'd1,
				  S_DRAW_PLAYER = 5'd2,
				  S_DRAW_BULLET = 5'd8,
				  S_DRAW_ENEMY1 = 5'd3,
				  S_DRAW_ENEMY2 = 5'd4,
				  S_DRAW_ENEMY3 = 5'd6,
				  S_DRAW_ENEMY4 = 5'd7,
				  
				  S_WAIT1 = 5'd9,
				  S_WAIT2 = 5'd10,
				  S_WAIT3 = 5'd11,
				  S_WAIT4 = 5'd12,
				  S_WAIT5 = 5'd13,
				  S_WAIT6 = 5'd14,
				  S_RESET_FRAMES = 5'd15,
				  S_DELAY_UPDATE = 5'd16,
				  S_UPDATE_POSITION = 5'd17;
				  

	 //State Table
    always@(*)
    begin: state_table 
            case (current_state)    
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
					S_WAIT5: next_state = S_RESET_FRAMES;
					
					
					
					S_RESET_FRAMES: next_state = S_DELAY_UPDATE;
					S_DELAY_UPDATE: next_state = (frameCounter == 4'd3/*4'b1111*/) ? S_UPDATE_POSITION : S_DELAY_UPDATE;
					S_UPDATE_POSITION: next_state = S_ERASE;
					
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
		  
        case (current_state)
				S_ERASE: begin inEraseState <= 1; vgaPlotOut <= 1; end
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
				
        endcase
    end // enable_signals

	 //logic for switching states on positive clock edges and reseting when resetn is 0
    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_ERASE;
				frameCounter <= 0;
				rateDividerCounter <= 27'd833333;
        end
        else begin
            current_state <= next_state;
				
				if (current_state == S_RESET_FRAMES) begin
					rateDividerCounter <= 27'd833333;//27'd833333 27'b11001011011100110100
					frameCounter <= 4'b0;
				end
				else if(current_state == S_DELAY_UPDATE) begin			
					if (rateDividerCounter == 0) begin
						frameCounter <= frameCounter + 1'b1;
						rateDividerCounter <= 27'd833333; //27'd833333  27'b11001011011100110100
					
						if (frameCounter == 4'd3/*4'b1111*/)
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