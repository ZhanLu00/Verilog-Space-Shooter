vlib work
vlog -timescale 1ns/1ns playData.v
vsim playData
log {/*}
add wave {/*}

force clock 1 0, 0 10 -r 20
force reset 0 0, 1 20

# check states
force inInputState 0 0, 1 20
force inUpdatePositionState 0 0, 1 40
force inSetAState 0 0, 1 60
force inSetDState 0 0, 1 80

# keyboard input
force keyboardAPressed 0 0, 1 20 -r 40
force keyboardDPressed 0 0, 1 40 -r 40

run 200ns
