// $Id: $
// File name:   sr_8bit.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: 8-bit shift register
module sr_8bit
(
  input  clk,
  input  n_rst,
  input logic d_original,
  input logic shift_enable,
  output logic [7:0] rx_packet_data
);

  flex_stp_sr #(
    .NUM_BITS(8),
		.SHIFT_MSB(0)
  )
  CORE(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(d_original),
    .shift_enable(shift_enable),
    .parallel_out(rx_packet_data)
  );

endmodule
