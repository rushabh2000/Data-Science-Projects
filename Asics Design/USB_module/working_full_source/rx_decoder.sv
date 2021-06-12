// $Id: $
// File name:   rx_decoder.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: block to complete NRZI decoding
module rx_decoder  (
	input clk, 
	input n_rst, 
	input logic d_plus_sync, 
	input logic eop, 
	input logic d_edge, 
	input logic shift_enable, 
	output logic d_original
);

logic nxt_d;
logic nxt_out;

always_ff @(posedge clk, negedge n_rst) begin

	if(n_rst == 1'b0) begin
		nxt_d <= 1'b1;
		nxt_out <= 1'b1;
	end
	else if(shift_enable == 1'b1) begin
			nxt_d <= d_plus_sync;
			nxt_out <= nxt_d;
	end
	else begin
		nxt_d <= nxt_d;
		nxt_out <= nxt_out;
	end
end

//assign d_original = nxt_d ~^ nxt_out;
assign d_original = nxt_d ^ ~d_plus_sync;

endmodule
