onerror {resume}
radix define buffer_state {
    "4'b0000" "IDLE",
    "4'b0001" "WAIT_W",
    "4'b0010" "STORE1",
    "4'b0011" "STORE2",
    "4'b0100" "STORE3",
    "4'b0101" "STORE4",
    "4'b0110" "WAIT_R",
    "4'b0111" "LOAD1",
    "4'b1000" "LOAD2",
    "4'b1001" "LOAD3",
    "4'b1010" "LOAD4",
    -default default
}
radix define t_packet {
    "3'b000" "NO_PACKET",
    "3'b001" "DATA",
    "3'b010" "ACK",
    "3'b011" "NAK",
    "3'b100" "STALL",
    -default default
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Test Info}
add wave -noupdate -color Yellow -itemcolor Yellow -label {Test Case} /tb_ahb_lite_slave_cdl/tb_test_case
add wave -noupdate -color Gold -itemcolor Gold -label {Test #} -radix decimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/tb_test_case_num
add wave -noupdate -divider System
add wave -noupdate -color White -itemcolor White -label Clock -radix binary /tb_ahb_lite_slave_cdl/TM/clk
add wave -noupdate -color Red -itemcolor Red -label Reset -radix binary /tb_ahb_lite_slave_cdl/TM/n_rst
add wave -noupdate -color Yellow -itemcolor Yellow -label {D Mode} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/d_mode
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HSEL -radix binary /tb_ahb_lite_slave_cdl/TM/hsel
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HADDR -radix hexadecimal /tb_ahb_lite_slave_cdl/TM/haddr
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HTRANS -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/htrans
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HSIZE -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hsize
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HWRITE -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hwrite
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label HWDATA -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hwdata
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Green Yellow} -itemcolor {Green Yellow} -label HRDATA -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hrdata
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Green Yellow} -itemcolor {Green Yellow} -label HRESP -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hresp
add wave -noupdate -expand -group {AHB-Lite Bus} -color {Green Yellow} -itemcolor {Green Yellow} -label HREADY -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/hready
add wave -noupdate -color Red -itemcolor Red -label {RAW Hazard} -radix binary /tb_ahb_lite_slave_cdl/TM/raw_hazard
add wave -noupdate -group {Delayed AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label {last HSEL} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/last_hsel
add wave -noupdate -group {Delayed AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label {last HADDR} -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/last_haddr
add wave -noupdate -group {Delayed AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label {last HSIZE} -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/last_hsize
add wave -noupdate -group {Delayed AHB-Lite Bus} -color {Spring Green} -itemcolor {Spring Green} -label {last HWRITE} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/last_hwrite
add wave -noupdate -group {USB RX} -color Orange -itemcolor Orange -label {RX Packet} -radix t_packet /tb_ahb_lite_slave_cdl/TM/rx_packet
add wave -noupdate -group {USB RX} -color Orange -itemcolor Orange -label {RX Data Ready} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/rx_data_ready
add wave -noupdate -group {USB RX} -color Orange -itemcolor Orange -label {RX Transfer Active} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/rx_transfer_active
add wave -noupdate -group {USB RX} -color Orange -itemcolor Orange -label {RX Error} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/rx_error
add wave -noupdate -expand -group {Data Buffer} -color {Sky Blue} -itemcolor {Sky Blue} -label {Buffer Occupancy} -radix decimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/buffer_occupancy
add wave -noupdate -expand -group {Data Buffer} -color {Sky Blue} -itemcolor {Sky Blue} -label {RX Data} -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/rx_data
add wave -noupdate -expand -group {Data Buffer} -color Cyan -itemcolor Cyan -label {Get RX Data} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/get_rx_data
add wave -noupdate -expand -group {Data Buffer} -color Cyan -itemcolor Cyan -label {Store TX Data} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/store_tx_data
add wave -noupdate -expand -group {Data Buffer} -color Cyan -itemcolor Cyan -label {TX Data} -radix hexadecimal -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/tx_data
add wave -noupdate -expand -group {Data Buffer} -color Cyan -itemcolor Cyan -label Clear -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/clear
add wave -noupdate -expand -group {USB TX} -color Yellow -itemcolor Yellow -label {TX Packet} -radix t_packet -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/tx_packet
add wave -noupdate -expand -group {USB TX} -color Yellow -itemcolor Yellow -label {TX Transfer Active} -radix binary /tb_ahb_lite_slave_cdl/TM/tx_transfer_active
add wave -noupdate -expand -group {USB TX} -color Yellow -itemcolor Yellow -label {TX Error} -radix binary -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/tx_error
add wave -noupdate -expand -group {Interface Memory} -label 0xF -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[15]}
add wave -noupdate -expand -group {Interface Memory} -label 0xE -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[14]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0xD: FBCR} -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[13]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0xC: TPCR} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[12]}
add wave -noupdate -expand -group {Interface Memory} -label 0xB -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[11]}
add wave -noupdate -expand -group {Interface Memory} -label 0xA -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[10]}
add wave -noupdate -expand -group {Interface Memory} -label 0x9 -radix hexadecimal {/tb_ahb_lite_slave_cdl/TM/mem[9]}
add wave -noupdate -expand -group {Interface Memory} -color {Blue Violet} -itemcolor {Blue Violet} -label {0x8: ROM [2]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[8]}
add wave -noupdate -expand -group {Interface Memory} -color {Blue Violet} -itemcolor {Blue Violet} -label {0x7: ROM [1]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[7]}
add wave -noupdate -expand -group {Interface Memory} -color {Blue Violet} -itemcolor {Blue Violet} -label {0x6: ROM [0]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[6]}
add wave -noupdate -expand -group {Interface Memory} -color {Blue Violet} -itemcolor {Blue Violet} -label {0x5: Status [1]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[5]}
add wave -noupdate -expand -group {Interface Memory} -color {Blue Violet} -itemcolor {Blue Violet} -label {0x4: Status [0]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[4]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0x3: Buffer [3]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[3]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0x2: Buffer [2]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[2]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0x1: Buffer [1]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[1]}
add wave -noupdate -expand -group {Interface Memory} -color Magenta -itemcolor Magenta -label {0x0: Buffer [0]} -radix hexadecimal -radixshowbase 0 {/tb_ahb_lite_slave_cdl/TM/mem[0]}
add wave -noupdate -label buff_state -radix buffer_state -radixshowbase 0 /tb_ahb_lite_slave_cdl/TM/buff_state
add wave -noupdate -label buff_addr -radix hexadecimal /tb_ahb_lite_slave_cdl/TM/buff_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2125000 ps} 0}
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
WaveRestoreZoom {2025840 ps} {2281840 ps}
