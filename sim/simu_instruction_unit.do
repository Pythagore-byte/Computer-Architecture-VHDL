vlib work 
vcom -2008 ../rtl/instruction_unit/instruction_memory.vhd 
vcom -2008 ../rtl/instruction_unit/pc_reg.vhd 
vcom -2008 ../rtl/datapath/sign_extend.vhd 
vcom -2008 ../rtl/instruction_unit/instruction_unit.vhd 
vcom -2008 ../tb/tb_instruction_unit.vhd
vsim tb_instruction_unit

add wave -r *

run -all