onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 INPUTS
add wave -noupdate /tb_alu/OP
add wave -noupdate -radix decimal /tb_alu/A
add wave -noupdate -radix decimal /tb_alu/B
add wave -noupdate -divider -height 20 OUTPUT
add wave -noupdate -color Magenta -height 20 -radix decimal -childformat {{/tb_alu/S(31) -radix decimal} {/tb_alu/S(30) -radix decimal} {/tb_alu/S(29) -radix decimal} {/tb_alu/S(28) -radix decimal} {/tb_alu/S(27) -radix decimal} {/tb_alu/S(26) -radix decimal} {/tb_alu/S(25) -radix decimal} {/tb_alu/S(24) -radix decimal} {/tb_alu/S(23) -radix decimal} {/tb_alu/S(22) -radix decimal} {/tb_alu/S(21) -radix decimal} {/tb_alu/S(20) -radix decimal} {/tb_alu/S(19) -radix decimal} {/tb_alu/S(18) -radix decimal} {/tb_alu/S(17) -radix decimal} {/tb_alu/S(16) -radix decimal} {/tb_alu/S(15) -radix decimal} {/tb_alu/S(14) -radix decimal} {/tb_alu/S(13) -radix decimal} {/tb_alu/S(12) -radix decimal} {/tb_alu/S(11) -radix decimal} {/tb_alu/S(10) -radix decimal} {/tb_alu/S(9) -radix decimal} {/tb_alu/S(8) -radix decimal} {/tb_alu/S(7) -radix decimal} {/tb_alu/S(6) -radix decimal} {/tb_alu/S(5) -radix decimal} {/tb_alu/S(4) -radix decimal} {/tb_alu/S(3) -radix decimal} {/tb_alu/S(2) -radix decimal} {/tb_alu/S(1) -radix decimal} {/tb_alu/S(0) -radix decimal}} -radixshowbase 0 -subitemconfig {/tb_alu/S(31) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(30) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(29) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(28) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(27) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(26) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(25) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(24) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(23) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(22) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(21) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(20) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(19) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(18) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(17) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(16) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(15) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(14) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(13) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(12) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(11) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(10) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(9) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(8) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(7) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(6) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(5) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(4) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(3) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(2) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(1) {-color Magenta -radix decimal -radixshowbase 0} /tb_alu/S(0) {-color Magenta -radix decimal -radixshowbase 0}} /tb_alu/S
add wave -noupdate -divider -height 20 FLAGS
add wave -noupdate -color Red /tb_alu/N
add wave -noupdate -color yellow /tb_alu/Z
add wave -noupdate /tb_alu/C
add wave -noupdate -color blue /tb_alu/V
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {109860 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {275 ps} {115775 ps}
