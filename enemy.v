module enemy(
        input [2:0] colour,
        input go1, go2, go3, go4, clk, reset_N0, reset_N1, reset_N2, reset_N3,
        output [7:0] x_out0, x_out1, x_out2, x_out3,
        output [6:0] y_out0, y_out1, y_out2, y_out3,
        output [2:0] colour_out0, colour_out1, colour_out2, colour_out3,
        output plot1, plot2, plot3, plot0  
);

    wire reset_C0, reset_C1, reset_C2, reset_C3;
    wire en_XY0, en_XY1, en_XY2, en_XY3;
    wire en_de0, en_de1, en_de2, en_de3;
    wire erase0, erase1, erase2, erase3;
    wire p0, p1, p2, p3;
    wire hold0, hold1, hold2, hold3; 
    wire done0, done1, done2, done3;

    localparam X0   = 8'd14,
               Y0   = 7'd0,
               X1   = 8'd54,
               Y1   = 7'd0,
               X2   = 8'd94,
               Y2   = 7'd0,
               X3   = 8'd134,
               Y3   = 7'd0;

    wire [7:0] x0out, x1out, x2out, x3out;
    wire [6:0] y0out, y1out, y2out, y3out;
    wire [2:0] c_out0, c_out1, c_out2, c_oiut3;


	
    // initiate four enemy
    control_enemy c0(
        .go(go0),
        .clk(clk),
        .reset_N(reset_N0),
        .hold(hold0),
        .done(done0),
        .reset_C(reset_C0),
        .en_XY(en_XY0),
        .en_de(en_de0),
        .erase(erase0),
        .plot(p0)
    );

    datapath_enemy d0(
        .reset_C(reset_C0),
        .reset_N(reset_N0),
        .clk(clk),
        .enable_delay(en_de0),
        .enable_XY(en_XY),
        .erase(erase0),
        .plot(p0),
        .xIn(X0),
        .yIn(Y0),
        .colour(colour),
        .x_out(x0out),
        .y_out(y0out),
        .colour_out(c_out0),
        .hold(hold0),
        .done(done)
    );
    
    control_enemy c1(
        .go(go1),
        .clk(clk),
        .reset_N(reset_N1),
        .hold(hold1),
        .done(done1),
        .reset_C(reset_C1),
        .en_XY(en_XY1),
        .en_de(en_de1),
        .erase(erase1),
        .plot(p1)
    );

    datapath_enemy d1(
        .reset_C(reset_C1),
        .reset_N(reset_N1),
        .clk(clk),
        .enable_delay(en_de1),
        .enable_XY(en_XY1),
        .erase(erase1),
        .plot(p1),
        .xIn(X1),
        .yIn(Y1),
        .colour(colour),
        .x_out(x1out),
        .y_out(y1out),
        .colour_out(c_out1),
        .hold(hold1),
        .done(done1)
    );

    control_enemy c2(
        .go(go2),
        .clk(clk),
        .reset_N(reset_N2),
        .hold(hold2),
        .done(done2),
        .reset_C(reset_C2),
        .en_XY(en_XY2),
        .en_de(en_de2),
        .erase(erase2),
        .plot(p2)
    );

    datapath_enemy d2(
        .reset_C(reset_C2),
        .reset_N(reset_N2),
        .clk(clk),
        .enable_delay(en_de2),
        .enable_XY(en_XY2),
        .erase(erase2),
        .plot(p2),
        .xIn(X2),
        .yIn(Y2),
        .colour(colour),
        .x_out(x2out),
        .y_out(y2out),
        .colour_out(c_out2),
        .hold(hold2),
        .done(done2)
    );

    control_enemy c3(
        .go(go3),
        .clk(clk),
        .reset_N(reset_N3),
        .hold(hold3),
        .done(done3),
        .reset_C(reset_C3),
        .en_XY(en_XY3),
        .en_de(en_de3),
        .erase(erase3),
        .plot(p3)
    );

    datapath_enemy d3(
        .reset_C(reset_C33),
        .reset_N(reset_N),
        .clk(clk),
        .enable_delay(en_de3),
        .enable_XY(en_XY3),
        .erase(erase3),
        .plot(p3),
        .xIn(X3),
        .yIn(Y3),
        .colour(colour),
        .x_out(x3out),
        .y_out(y3out),
        .colour_out(c_out3),
        .hold(hold3),
        .done(done3)
    );

    //assign outputs
    assign x_out0 = x0out;
    assign y_out0 = y0out;
    assign plot0 = p0;
    assign x_out1 = x1out;
    assign y_out1 = y1out;
    assign plot1 = p1;
    assign x_out2 = x2out;
    assign y_out2 = y2out;
    assign plot2 = p2;
    assign x_out3 = x3out;
    assign y_out3 = y3out;
    assign plot3 = p3;

endmodule