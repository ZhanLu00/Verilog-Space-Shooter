vlib work
vlog -timescale 1ns/1ns displayTestCombined.v
vsim displayTestCombined
log {/*}
add wave {/*}

#RESET
force clk 0 0ns, 1 10ns
force resetn 0 0ns, 1 20ns
force p_x 2#00011110 
force e0_x 2#00100011 
force e1_x 2#00100011
force e2_x 2#00100011 
force e3_x 2#00100011 
force p_y 2#0101000 
force e0_y 2#0101101
force e1_y 2#0101101 
force e2_y 2#0101101 
force e3_y 2#0101101 
force p_w 2#01010 
force p_h 2#01010 
force e_w 2#01010 
force e_h 2#01010 
force p_c 2#101
force e_c0 2#100
force e_c1 2#100
force e_c2 2#100
force e_c3 2#100
run 20ns

#TEST DRAWING
force clk 0 0ns, 1 10ns -r 20ns
run 2000ns




