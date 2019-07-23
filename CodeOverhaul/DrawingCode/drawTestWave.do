vlib work
vlog -timescale 1ns/1ns draw.v
vsim draw
log {/*}
add wave {/*}

#RESET
force clk 0 0ns, 1 10ns
force reset 0 0ns, 1 20ns
force enable 0
run 20ns

#Test draw a 10x10 starting from (30, 40) box in colour 2#101 (testing whether output coordinates and colour are correct)
force clk 0 0ns, 1 10ns -r 20ns
force x_in 2#00011110
force y_in 2#0101000
force width 2#01010
force height 2#01010
force c_in 2#101
force enable 1 20ns
run 1000ns
