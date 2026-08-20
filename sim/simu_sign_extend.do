vlib work 
vcom -2008 ../rtl/datapath/sign_extend.vhd
vcom -2008 ../tb/tb_sign_extend.vhd
vsim tb_sign_extend

do waveforms/wave_sign_extend.do

run -all
