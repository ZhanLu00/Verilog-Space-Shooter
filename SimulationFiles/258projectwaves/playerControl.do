vlib work
vlog -timescale 1ns/1ns playerMovementFSM.v
vsim playerMovementFSM
log {/*}
add wave {/*}

force clk 1 0, 0 10 -r 20
force resetn 0 0, 1 20


# keyboard input
force aPressed 0 0, 1 20, 0 30, 1 200, 0 220
force dPressed 0 0, 1 40, 0 60, 1 80, 0 100, 1 120, 0 140, 1 160, 0 180

run 220ns
