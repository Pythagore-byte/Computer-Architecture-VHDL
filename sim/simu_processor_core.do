vlib work 
vcom -2008 ../rtl/control_unit/decoder.vhd
vcom -2008 ../rtl/control_unit/psr_reg.vhd
vcom -2008 ../rtl/control_unit/control_unit.vhd

vcom -2008 ../rtl/datapath/register_file.vhd
vcom -2008 ../rtl/datapath/mux2to1.vhd
vcom -2008 ../rtl/datapath/sign_extend.vhd
vcom -2008 ../rtl/datapath/alu.vhd
vcom -2008 ../rtl/datapath/data_memory.vhd
vcom -2008 ../rtl/datapath/datapath_complet.vhd

vcom -2008 ../rtl/instruction_unit/instruction_memory.vhd 
vcom -2008 ../rtl/instruction_unit/pc_reg.vhd 
vcom -2008 ../rtl/datapath/sign_extend.vhd 
vcom -2008 ../rtl/datapath/mux2to1.vhd 
vcom -2008 ../rtl/instruction_unit/instruction_unit.vhd 
vcom -2008 ../rtl/reg_Aff.vhd 
vcom -2008 ../rtl/peripherals/decodeur_7_segment.vhd 
vcom -2008 ../rtl/processor_core.vhd 

vcom -2008 ../tb/tb_processor_core.vhd
vsim tb_processor_core

do waveforms/wave_processor_core.do

run -all