vlib work
vlog -timescale 1ns/1ns drawFSM.v
vsim drawFSM
log {/*}
add wave {/*}

force clk 0 0ns, 1 10ns -r 20ns
force resetn 0 0ns, 1 20ns
force done 0 0ns, 1 20ns, 0 40ns, 1 60ns, 0 80ns, 1 100ns, 0 120ns, 1 140ns, 0 160ns, 1 180ns, 0 200ns, 1 220ns
run 240ns

