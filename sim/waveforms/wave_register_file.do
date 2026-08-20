onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 INPUTS
add wave -noupdate -color red /tb_register_file/clk
add wave -noupdate -color blue /tb_register_file/reset
add wave -noupdate /tb_register_file/WE
add wave -noupdate -radix decimal /tb_register_file/RA
add wave -noupdate -radix decimal /tb_register_file/RB
add wave -noupdate -radix decimal /tb_register_file/RW
add wave -noupdate -radix decimal /tb_register_file/W
add wave -noupdate -divider -height 20 OUTPUTS
add wave -noupdate -radix decimal /tb_register_file/A
add wave -noupdate -radix decimal /tb_register_file/B
add wave -noupdate -divider -height 20 {BANC REGISTRE}
add wave -noupdate -radix decimal -childformat {{/tb_register_file/inst/banc(15) -radix decimal} {/tb_register_file/inst/banc(14) -radix decimal} {/tb_register_file/inst/banc(13) -radix decimal} {/tb_register_file/inst/banc(12) -radix decimal} {/tb_register_file/inst/banc(11) -radix decimal} {/tb_register_file/inst/banc(10) -radix decimal} {/tb_register_file/inst/banc(9) -radix decimal} {/tb_register_file/inst/banc(8) -radix decimal} {/tb_register_file/inst/banc(7) -radix decimal} {/tb_register_file/inst/banc(6) -radix decimal} {/tb_register_file/inst/banc(5) -radix decimal} {/tb_register_file/inst/banc(4) -radix decimal} {/tb_register_file/inst/banc(3) -radix decimal} {/tb_register_file/inst/banc(2) -radix decimal} {/tb_register_file/inst/banc(1) -radix decimal} {/tb_register_file/inst/banc(0) -radix decimal}} -expand -subitemconfig {/tb_register_file/inst/banc(15) {-radix decimal} /tb_register_file/inst/banc(14) {-radix decimal} /tb_register_file/inst/banc(13) {-radix decimal} /tb_register_file/inst/banc(12) {-radix decimal} /tb_register_file/inst/banc(11) {-radix decimal} /tb_register_file/inst/banc(10) {-radix decimal} /tb_register_file/inst/banc(9) {-radix decimal} /tb_register_file/inst/banc(8) {-radix decimal} /tb_register_file/inst/banc(7) {-radix decimal} /tb_register_file/inst/banc(6) {-radix decimal} /tb_register_file/inst/banc(5) {-radix decimal} /tb_register_file/inst/banc(4) {-radix decimal} /tb_register_file/inst/banc(3) {-radix decimal} /tb_register_file/inst/banc(2) {-radix decimal} /tb_register_file/inst/banc(1) {-radix decimal} /tb_register_file/inst/banc(0) {-radix decimal}} /tb_register_file/inst/banc
add wave -noupdate /tb_register_file/done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {69921 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
configure wave -valuecolwidth 148
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
WaveRestoreZoom {0 ps} {73935 ps}
