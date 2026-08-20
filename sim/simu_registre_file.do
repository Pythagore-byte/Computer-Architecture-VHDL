vlib work 
vcom -2008 ../rtl/datapath/register_file.vhd
vcom -2008 ../tb/tb_register_file.vhd
vsim tb_register_file

do waveforms/wave_register_file.do

run -all