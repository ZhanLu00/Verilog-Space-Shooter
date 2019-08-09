vlib work
vlog -timescale 1ns/1ns bulletDatapath.v
vsim bulletDatapath
log {/*}
add wave {/*}

force clk 1 0, 0 10 -r 20
force pXIn 8'b00010000 0
force inResetState 0 0, 1 20, 0 40
force inUpdatePositionState 0 0, 1 80, 0 100, 1 120, 0 140, 1 160, 0 180

force inWaitState 0 0, 1 200

run 220ns
