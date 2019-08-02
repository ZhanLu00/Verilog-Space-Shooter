vlib work
vlog -timescale 1ns/1ns healthUpdate.v
vsim healthUpdate
log {/*}
add wave {/*}


#RESET
force clk 0 0ns, 1 10ns
force resetn 0
force updateHealth 0
force inUpdatePositionStateMain 0
force inGameOverState 0
run 20ns

#UPDATE HEALTH TWICE
force clk 0 0ns, 1 10ns -r 20ns
force resetn 1
force updateHealth 1 0ns, 0 20ns, 1 40ns, 0 60ns
force inUpdatePositionStateMain 1 0ns, 0 20ns, 1 40ns, 0 60ns
run 80ns


