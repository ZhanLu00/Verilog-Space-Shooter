vlib work
vlog -timescale 1ns/1ns bulletControl.v
vsim bulletControl
log {/*}
add wave {/*}

force clk 1 0, 0 10 -r 20
force resetn 0 0, 1 20

force updatePosition 0 0, 1 20
force topReached 0 0, 1 40
force spacePressed 0 0, 1 60, 0 80, 1 100, 0 120, 1 140, 0 160, 1 180, 0 200
force collidedWithEnemy 0 0, 1 100

force resetn 0 260

run 260ns
