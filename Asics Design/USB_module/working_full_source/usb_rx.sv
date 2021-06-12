// $Id: $
// File name:   usb_rx.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: top level block for usb receiver.
module usb_rx(input clk, input n_rst, 
	input logic d_plus, input logic d_minus, 
	input logic [6:0] buffer_ocup,
	output logic [2:0] rx_packet, 
	output logic rx_data_ready, rx_error, rx_transfer_active,
	output logic flush, store_rx_packet_data,
	output logic [7:0] rx_packet_data 
);	
	logic d_plus_sync, d_minus_sync, d_edge, d_orig;
	logic shift_en, br, eop;
	
	//sync high for d_plus
	sync_high SYNC_H (
		.clk(clk), 
		.n_rst(n_rst), 
		.async_in(d_plus), 
		.sync_out(d_plus_sync)
	);
	
	//sync low for d_minus
	sync_low SYNC_L (
		.clk(clk), 
		.n_rst(n_rst), 
		.async_in(d_minus), 
		.sync_out(d_minus_sync)
	);
	
	//eop (in: clk, n_rst, d_minus_sync, d_plus_sync; out: eop)
	rx_eop EOP (
		.clk(clk), 
		.n_rst(n_rst), 
		.d_minus_sync(d_minus_sync), 
		.d_plus_sync(d_plus_sync),  
		.shift_en(shift_en), 
		.eop(eop), 
		.d_edge(d_edge)
	);
	
	//decoder (in: clk, n_rst, d_plus_sync, eop, shift_enable; out: d_original)
	rx_decoder DECODE (
		.clk(clk), 
		.n_rst(n_rst), 
		.d_plus_sync(d_plus_sync), 
		.eop(eop), 
		.d_edge(d_edge),
		.shift_enable(shift_en), 
		.d_original(d_orig)
	);
	
	//edge detect (in: clk, n_rst, d_plus_sync; out: d_edge)
	edge_detector EDGE(
		.clk(clk), 
		.n_rst(n_rst), 
		.d_plus_sync(d_plus_sync), 
		.d_edge(d_edge)
	);
	
	//timer (in: clk, n_rst, d_edge ; shift_enable, byte_recieved)
	rx_timer TIMER (
		.clk(clk), 
		.n_rst(n_rst), 
		.d_edge(d_edge), 
		.shift_enable(shift_en), 
		.byte_recieved(br), 
		.rx_transfer_active(rx_transfer_active)
	);
	
	//sr_8bit (in: clk, n_rst, shift_enable, d_original; out: rx_packet_data)
	sr_8bit SREG (
		.clk(clk), 
		.n_rst(n_rst), 
		.shift_enable(shift_en), 
		.d_original(d_orig), 
		.rx_packet_data(rx_packet_data)
	);
	
	//rcu (in: clk, n_rst, eop, d_edge, byte_recieved, shift_enable, rx_packet_data, buff_ocp;  out: rx_packet, flush, store_rx_packet_data, rx_error, rx_data_ready, rx_transfer_active)
	rx_rcu_usb FSM (
		.clk(clk), 
		.n_rst(n_rst), 
		.eop(eop), 
		.d_edge(d_edge), 
		.byte_recieved(br), 
		.shift_enable(shift_en), 
		.rx_packet_data(rx_packet_data), 
		.buff_ocp(buffer_ocup), 
		.rx_packet(rx_packet), 
		.flush(flush), 
		.store_rx_pd(store_rx_packet_data),
		.rx_error(rx_error), 
		.rx_dr(rx_data_ready), 
		.rx_ta(rx_transfer_active)
	);
endmodule
