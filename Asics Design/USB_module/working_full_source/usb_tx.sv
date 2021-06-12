// $Id: $
// File name:   usb_tx.sv
// Created:     4/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: USB TX top level

module usb_tx (
    input logic clk,
    input logic n_rst,
    input logic [6:0] buffer_occupancy,
    input logic [2:0] tx_packet,
    input logic [7:0] tx_packet_data,
    output logic get_tx_packet_data,
    output logic dplus_out,
    output logic dminus_out,
    output logic tx_error,
    output logic tx_transfer_active
);
	logic timer_enable;
	logic byte_done;
	logic activate_get_tx;
	logic [7:0]data_out;
	logic encoder_enable;
	logic pts_enable;
	logic serial_out; // check
	logic clock_timer;
	logic eop_enable;

	tx_timer TIMER (
                    .clk(clk),
                    .n_rst(n_rst),
                    .timer_enable(timer_enable),
                    .byte_done(byte_done),
                    .clock_timer(clock_timer),
                    .activate_get_tx(activate_get_tx)
	);

	tx_controller CTRL (
                    .clk(clk),
                    .n_rst(n_rst),
                    .buffer_occupancy(buffer_occupancy),
                    .tx_packet(tx_packet),
                    .tx_packet_data(tx_packet_data),
                    .byte_done(byte_done),// from clk
                    .get_tx_packet_data(get_tx_packet_data),
                    .data_out(data_out),
                    .encoder_enable(encoder_enable),
                    .timer_enable(timer_enable),
                    .pts_enable(pts_enable),
                    .clock_timer(clock_timer),
                    .eop_enable(eop_enable),
                    .activate_get_tx(activate_get_tx),
                    .tx_error(tx_error),
                    .tx_transfer_active(tx_transfer_active)
	);

	tx_encoder ENCOD(  
                    .clk(clk),
                    .n_rst(n_rst),
                    .encoder_enable(encoder_enable),
                    .clock_timer(clock_timer),
                    .dminus_out(dminus_out),
                    .dplus_out(dplus_out),
                    .serial_out(serial_out),
                    .eop_enable(eop_enable)
	);

	tx_pts P2S(
                    .clk(clk),
                    .n_rst(n_rst),
                    .data_out(data_out),
                    .serial_out(serial_out),
                    .pts_enable(pts_enable),
                    .clock_timer(clock_timer)
	);

endmodule
