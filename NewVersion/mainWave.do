vlib work
vlog -timescale 1ns/1ns main.v
vsim main
log {/*}
add wave {/*}
add wave {/main/mainDrawFSM/*}
add wave {/main/enemyController1/*}
add wave {/main/enemyData1/*}

#DRAW
force CLOCK_50 0 0ns, 1 10ns -r 20ns
force {KEY[3:0]} 2#1110 0ns, 2#1111 20ns
run 10000000ns