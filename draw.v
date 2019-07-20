module draw(
    input [7:0] x_in,
    input [6:0] y_in,
    input [4:0] width, height,
    input [2:0] c_in,
    input draw, clk, reset,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] c_out,
    output done
);
    reg [7:0] counterX, xOut; 
    reg [6:0] counterY, yOut;
    reg done_;


    always @(posedge clk)
    begin
        if (reset) begin
            xOut <= x_in;
            yOut <= y_in;
            done_ <= 0;
        end
        else if (draw) begin
            if (counterX == (width-1)) begin
                counterX <= 0; 
                counterY <= counterY + 1; end
            else if (counterX < (width-1)) begin
                counterX <= counterX + 1; end

            if (counterY == height) begin
                done_ <= 1'b1; end
        end

    end

    assign x_out = xOut + counterX;
    assign y_out = yOut + counterY;
    assign done = done_;

endmodule