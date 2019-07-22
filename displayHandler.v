module displayHandler(
    input [7:0] p_x, e0_x, e1_x, e2_x, e3_x,
    input [6:0] p_y, e0_y, e1_y, e2_y, e3_y,
    input [4:0] p_w, p_h, e_w, e_h,
    input [2:0] p_c, e_c0, e_c1, e_c2, e_c3,
    input clk, draw, reset,
    input [3:0] control_signal,
    output [7:0] start_x, 
    output [6:0] start_y, 
    output [4:0] width, height,
    output [2:0] color
);


    reg [7:0] px, e0x, e1x, e2x, e3x;
    reg [6:0] py, e0y, e1y, e2y, e3y;
    reg [4:0] pw, ph, ew, eh;
    reg [2:0] pc, e0c, e1c, e2c, e3c;

    reg [7:0] x_out;
    reg [6:0] y_out;
    reg [4:0] w_out, h_out;
    reg [2:0] c_out;

    // register
    always @(posedge clk)
    begin
        if (!reset) begin
            px<=p_x; e0x<=e0_x; e1x<=e1_x; e2x<=e2_x; e3x<=e3_x; 
            py<=p_y; e0y<=e0_y; e1y<=e1_y; e2y<=e2_y; e3y<=e3_y; 
            pw<=p_w; ph<=p_h; ew<=e_w; eh<=e_h; pc<=p_c; e0c<=e_c0; e1c<=e_c1; e2c<=e_c2; e3c<=e_c3;
        end
    end

    // choose output by controller
    // 0: player, 1:e0, 2:e1m, 3:e2, 4:e3
    always @(*)
    begin 
        case (control_signal)
            0: begin x_out <= px; y_out <= py; w_out <= pw; h_out <= ph; c_out <= pc; end
            1: begin x_out <= e0x; y_out <= e0y; w_out <= ew; h_out <= eh; c_out <= e0c; end
            2: begin x_out <= e1x; y_out <= e1y; w_out <= ew; h_out <= eh; c_out <= e1c; end
            3: begin x_out <= e2x; y_out <= e2y; w_out <= ew; h_out <= eh; c_out <= e2c; end
            4: begin x_out <= e3x; y_out <= e3y; w_out <= ew; h_out <= eh; c_out <= e3c; end
	    default: begin x_out <= px; y_out <= py; w_out <= pw; h_out <= ph; c_out <= pc; end
        endcase
    end

    assign start_x = x_out;
    assign start_y = y_out;
    assign width = w_out;
    assign height = h_out;
    assign color = c_out;
    

endmodule