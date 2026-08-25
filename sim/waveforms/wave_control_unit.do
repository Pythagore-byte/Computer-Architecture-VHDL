onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color red /tb_control_unit/s_clk
add wave -noupdate /tb_control_unit/s_reset
add wave -noupdate -radix hexadecimal /tb_control_unit/s_instruction
add wave -noupdate /tb_control_unit/s_flags
add wave -noupdate /tb_control_unit/done
add wave -noupdate /tb_control_unit/s_AluCtr
add wave -noupdate /tb_control_unit/s_RegAff
add wave -noupdate /tb_control_unit/s_WrSrc
add wave -noupdate /tb_control_unit/s_MemWr
add wave -noupdate /tb_control_unit/s_RegSel
add wave -noupdate /tb_control_unit/s_ALUSrc
add wave -noupdate /tb_control_unit/s_nPCSel
add wave -noupdate /tb_control_unit/s_RegWr
add wave -noupdate /tb_control_unit/dut/decoder/inst_courante
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {154769 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
configure wave -valuecolwidth 208
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {162750 ps}
