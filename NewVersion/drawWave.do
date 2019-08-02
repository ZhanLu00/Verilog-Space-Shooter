vlib work
vlog -timescale 1ns/1ns draw.v
vsim draw
log {/*}
add wave {/*}


#RESET
force clk 0 0ns, 1 10ns
force reset 0
force x_in 2#0001100
force y_in 2#011001
force width 2#00011
force height 2#00011
force c_in 2#111
force enableDraw 0
force inEraseStateMain 0
run 20ns

#DRAW A 3x3 BOX AT (12, 25) IN WHITE
force clk 0 0ns, 1 10ns -r 20ns
force reset 1
force enableDraw 1
run 1000ns