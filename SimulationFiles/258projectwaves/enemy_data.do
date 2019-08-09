vlib work
vlog -timescale 1ns/1ns enemyDatapath.v
vsim enemyDatapath
log {/*}
add wave {/*}

force clk 1 0ns, 0 10ns -r 20ns
force resetn 1 0, 0 20, 1 40

# test state
force inResetState 0 0, 1 60, 0 80
force inUpdatePositionState 0 0, 1 100
force enemyXIn 8'b00001110 0
force speedIn 4'b0010 0
force colourIn 3'b100 0
force score 8'b00000000 0

# test score
force speedIn 4'b0001 100
force score 8'b01100110 120
force score 8'b01000000 160
force score 8'b00100000 200
force score 8'b00010000 240
force speedIn 4'b0011 280
force score 8'b01100110 320
force score 8'b01000000 360
force score 8'b00100000 400
force score 8'b00010000 440

# test
run 600ns

