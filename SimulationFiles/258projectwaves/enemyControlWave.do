vlib work
vlog -timescale 1ns/1ns enemyControl.v
vsim enemyControl
log {/*}
add wave {/*}


#RESET
force clk 0 0ns, 1 10ns
force resetn 0
force enable 0
force updatePosition 0 0ns
force bottomReached 0
force collidedWithPlayer 0
force collidedWithBullet 0
run 20ns

#MOVE AND DELAY
force clk 0 0ns, 1 10ns -r 20ns
force resetn 1
# enable
force enable 1 60ns
# update position
force updatePosition 1 80ns
# collision
force collidedWithBullet 1 100ns
force collidedWithPlayer 1 150ns
force bottomReached 1 180ns
run 2000ns

