vlib work 
vcom -2008 ../rtl/datapath/register_file.vhd
vcom -2008 ../rtl/datapath/mux2to1.vhd
vcom -2008 ../rtl/datapath/sign_extend.vhd
vcom -2008 ../rtl/datapath/alu.vhd
vcom -2008 ../rtl/datapath/datapath.vhd
vcom -2008 ../tb/tb_datapath.vhd
vsim tb_datapath

do waveforms/wave_datapath.do

run -all