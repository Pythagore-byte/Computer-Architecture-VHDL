create_clock -name CLK_50 -period 20.000 [get_ports CLK_50]

create_clock -name clk_slow -period 100000000.000 \
    [get_registers {*clk_div*|clk*}]

derive_clock_uncertainty

set_clock_groups -asynchronous \
    -group {CLK_50} \
    -group {clk_slow}

set_false_path -from [get_ports {KEY[*]}]
set_false_path -from [get_ports SW]
set_false_path -to   [get_ports {HEX*}]