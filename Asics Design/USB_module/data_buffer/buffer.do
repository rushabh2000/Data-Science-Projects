onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Control } -color Red /tb_data_buffer/tb_clk
add wave -noupdate -expand -group {Control } -color Red /tb_data_buffer/tb_n_rst
add wave -noupdate -expand -group {Control } -color Red /tb_data_buffer/tb_test_case_num
add wave -noupdate -divider ahb
add wave -noupdate -expand -group ahb -color Magenta /tb_data_buffer/tb_store_rx_data
add wave -noupdate -expand -group ahb -color Magenta /tb_data_buffer/tb_store_tx_data
add wave -noupdate -expand -group ahb -color Magenta -radix hexadecimal /tb_data_buffer/tb_expected_rx_data
add wave -noupdate -expand -group ahb -color Magenta -radix hexadecimal /tb_data_buffer/tb_tx_data
add wave -noupdate -expand -group ahb -color Magenta /tb_data_buffer/tb_clear
add wave -noupdate -divider {rx side}
add wave -noupdate -expand -group {rx side} -color Cyan /tb_data_buffer/tb_get_rx_data
add wave -noupdate -expand -group {rx side} -color Cyan -radix hexadecimal /tb_data_buffer/tb_rx_data
add wave -noupdate -expand -group {rx side} -color Cyan /tb_data_buffer/tb_flush
add wave -noupdate -expand -group {rx side} -color Cyan -itemcolor White -radix hexadecimal /tb_data_buffer/DUT/rx_packet_data
add wave -noupdate -divider {tx side}
add wave -noupdate -expand -group {tx side} -color {Blue Violet} -radix hexadecimal /tb_data_buffer/tb_get_tx_data
add wave -noupdate -expand -group {tx side} -color {Blue Violet} -radix hexadecimal /tb_data_buffer/tb_tx_packet_data
add wave -noupdate -expand -group {tx side} -color {Blue Violet} -radix hexadecimal /tb_data_buffer/tb_expected_tx_packet_data
add wave -noupdate -color Green -radix hexadecimal /tb_data_buffer/tb_buffer_occupancy
add wave -noupdate -radix decimal /tb_data_buffer/tb_mismatch
add wave -noupdate -radix unsigned /tb_data_buffer/tb_expected_buffer_occupancy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {865000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 285
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {1874565 ps}
