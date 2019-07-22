vlib work
vlog -timescale 1ns/1ns enemyTest.v
vsim enemyTest
log {/*}
add wave {/*}
add wave {/enemyTest/d1/*}
add wave {/enemyTest/e1/*}

force clock 0 0ns, 1 10ns
force resetn 0 
force go 1 0ns, 0 40ns
run 20ns

force clock 0 0ns, 1 10ns -r 20ns
force resetn 1

run 530000ns
