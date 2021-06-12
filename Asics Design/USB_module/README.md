



Source/
	top_level_cdl.sv - top level RTL code for entire design

	ahb_lite_interface.sv - top level RTL code for AHB-Lite interface for USB receiver/transmitter

	data_buffer.sv - top level RTL code for data buffer

	usb_rx.sv - top level code for USB receiver (RX)
	adder_1bit.sv - 1-bit adder used by flexible adder
	adder_nbit.sv - flexible adder used by USB receiver
	edge_detector.sv - edge detector code used by USB RX
	flex_pts_sr.sv - RTL code for flexible parallel to series shift register
	flex_stp_sr.sv - RTL code for flexible serial to parallel shift register
	rx_decoder.sv - RTL code for NRZI decoder for USB RX
	rx_eop.sv - RTL code for RX end of packet detector
	rx_rcu_usb.sv - RTL code for RX control unit
	rx_timer.sv - timer module RTL code used by USB RX
	sr_8bit.sv - 8-bit shift register RTL code
	start_bit_det.sv - start bit detector RTL code
	sync_high.sv - RTL code for high synchronizer module
	sync_low.sv - RTL code for low synchronizer module
	
	usb_tx.sv - top level code for USB transmitter
	flex_counter.sv - RTL code for standard flexible counter module
	flex_counter2.sv - RTL code for modified flexible counter module
	tx_controller.sv - RTL code for TX controller state machine
	tx_encoder.sv - RTL code for NRZI encoding module
	tx_pts.sv - RTL code for parallel to serial shift register
	tx_timer.sv - RTL code for timer module for USB TX

	tb_top_level_cdl.sv - test bench for top level RTL code for entire design
	tb_ahb_lite_interface.sv - test bench for ahb_lite_interface.sv
	tb_data_buffer.sv - test bench for data_buffer.sv
	tb_usb_rx.sv - test bench for usb_rx.sv
	tb_usb_tx.sv - test bench for usb_tx.sv

	tb_flex_counter.sv - test bench for flex_counter.sv
	tb_sync_low.sv - test bench for sync_low.sv
	
Reports/
	top_level_cdl.log - synthesis report file for top level
	top_level_cdl.rep - report for top level design

	ahb_lite_interface.log - synthesis report file for ahb-lite interface
	ahb_lite_interface.rep - report for ahb-lite interface
	ahb_lite_report.txt - coverate report for ahb-lite interface test bench

	data_buffer.log - synthesis report file for data buffer
	data_buffer.rep - report for data buffer
	data_buffer_report.txt - coverage report for data buffer test bench

	usb_rx.log - synthesis report file for USB receiver
	usb_rx.rep - report for usb receiver
	usb_rx_report.txt - coverage report for USB receiver test bench

	usb_tx.log - synthesis report file for USB transmitter
	usb_tx.rep - report for USB transmitter
	usb_tx_report.txt - coverage report for USB transmitter test bench

	
