vlib work
vlog -timescale 1ns/1ns enemyControl.v
vsim enemyControl
log {/*}
add wave {/*}


#RESET
force clk 0 0ns, 1 10ns
force resetn 0
force enable 0
force updatePosition 0
force bottomReached 0
force collidedWithPlayer 0
force collidedWithBullet 0
run 20ns

#MOVE AND DELAY
force clk 0 0ns, 1 10ns -r 20ns
force resetn 1
force bottomReached 1 140ns
run 2000ns