module drawFSM(mainDrawSignal, clk, resetn, done, enable);
    input done, clk, resetn;
    //output drawPlayer, drawEnemy1, drawEnemy2, drawEnemy3, drawEnemy4, drawBullet;

    output [3:0] mainDrawSignal;
    reg [3:0] drawSignalOut;

    output enable;
    assign enable=1;

    reg [3:0] current_state, next_state;

    localparam S_DRAW_PLAYER = 4'd0,
               S_DRAW_ENEMY1 = 4'd1,
               S_DRAW_ENEMY2 = 4'd2,
               S_DRAW_ENEMY3 = 4'd3,
               S_DRAW_ENEMY4 = 4'd4,
               S_DRAW_BULLET = 4'd5;

    always@(*)
    begin: state_table 
            case (current_state)           
                S_DRAW_PLAYER: next_state = (done == 1'b1) ? S_DRAW_ENEMY1 : S_DRAW_PLAYER;
                S_DRAW_ENEMY1: next_state = (done == 1'b1) ? S_DRAW_ENEMY2 : S_DRAW_ENEMY1;
                S_DRAW_ENEMY2: next_state = (done == 1'b1) ? S_DRAW_ENEMY3 : S_DRAW_ENEMY2;
                S_DRAW_ENEMY3: next_state = (done == 1'b1) ? S_DRAW_ENEMY4 : S_DRAW_ENEMY3;
                S_DRAW_ENEMY4: next_state = (done == 1'b1) ? S_DRAW_BULLET : S_DRAW_ENEMY4;
                S_DRAW_BULLET: next_state = (done == 1'b1) ? S_DRAW_PLAYER : S_DRAW_BULLET;



            default:     next_state = S_DRAW_PLAYER;
        endcase
    end // state_table


    always @(*)
    begin: enable_signals
        // By default make all our signals 0
       // drawPlayer = 1'b0;
        //drawEnemy1 = 1'b0;
        //drawEnemy2 = 1'b0;
        //drawEnemy3 = 1'b0;
        //drawEnemy4 = 1'b0;
        //drawBullet = 1'b0;
        drawSignalOut <= 4'b0;

        case (current_state)
            S_DRAW_PLAYER: drawSignalOut <= 4'd0;
            S_DRAW_ENEMY1: drawSignalOut <= 4'd1;
            S_DRAW_ENEMY2: drawSignalOut <= 4'd2;
            S_DRAW_ENEMY3: drawSignalOut <= 4'd3;
            S_DRAW_ENEMY4: drawSignalOut <= 4'd4;
            S_DRAW_BULLET: drawSignalOut <= 4'd5;
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    always@(posedge clk)
    begin: state_FFs
        if (resetn == 1'b0) begin
            current_state <= S_DRAW_PLAYER;
        end
        else 
            current_state <= next_state;
	
       
    end // state_FFS

    assign mainDrawSignal = drawSignalOut;

endmodule