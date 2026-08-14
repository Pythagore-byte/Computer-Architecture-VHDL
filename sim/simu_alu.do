vlib work 
vcom -2008 ../rtl/datapath/alu.vhd
vcom -2008 ../tb/tb_alu.vhd
vsim tb_alu

do waveforms/wave_alu.do

run -all