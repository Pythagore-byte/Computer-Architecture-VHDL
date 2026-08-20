vlib work 
vcom -2008 ../rtl/datapath/data_memory.vhd
vcom -2008 ../tb/tb_data_memory.vhd
vsim tb_data_memory

do waveforms/wave_data_memory.do

run -all
