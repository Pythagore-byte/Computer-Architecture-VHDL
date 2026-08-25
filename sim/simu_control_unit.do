vlib work 
vcom -2008 ../rtl/control_unit/decoder.vhd
vcom -2008 ../rtl/control_unit/psr_reg.vhd
vcom -2008 ../rtl/control_unit/control_unit.vhd
vcom -2008 ../tb/tb_control_unit.vhd
vsim tb_control_unit

do waveforms/wave_control_unit.do

run -all