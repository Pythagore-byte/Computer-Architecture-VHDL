vlib work 
vcom -2008 ../rtl/control_unit/decoder.vhd
vcom -2008 ../tb/tb_decoder.vhd
vsim tb_decoder

add wave -r *

run -all