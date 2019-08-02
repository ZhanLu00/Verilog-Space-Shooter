vlib work
vlog -timescale 1ns/1ns drawFSM.v
vsim drawFSM
log {/*}
add wave {/*}


#RESET
force clk 0 0ns, 1 10ns
force resetn 0
force playerHealth 2#1010
force spacePressed 0
force doneDrawing 0
force doneErasing 0
run 20ns

#GO TO MAIN GAME SCREEN
force clk 0 0ns, 1 10ns -r 20ns
force resetn 1
force spacePressed 1
run 40ns

force clk 0 0ns, 1 10ns
force spacePressed 0
force doneErasing 1
run 20ns

force clk 0 0ns, 1 10ns -r 20ns
force doneErasing 0
force doneDrawing 1
run 1000ns


