// $Id: $
// File name:   tx_pts.sv
// Created:     4/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: tx_pts.sv
module tx_pts (
    input wire clk,
    input wire n_rst,
    input wire pts_enable,
    input wire [7:0] data_out,
    output logic serial_out,
    input logic clock_timer
);

flex_pts_sr #(.NUM_BITS(8),.SHIFT_MSB(1'b0)) A(.clk(clk),.n_rst(n_rst),.parallel_in(data_out),.shift_enable(clock_timer),.load_enable(pts_enable),.serial_out(serial_out));


	
endmodule
