// $Id: $
// File name:   sync_low.sv
// Created:     2/12/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: sync_low

module sync_low
(
	input wire clk,
	input wire n_rst,
	input wire async_in,
	output wire sync_out
);
reg data;
reg nxt_data;

always_ff @(posedge clk, negedge n_rst)

begin 

	if(1'b0 == n_rst)
	begin
	data <= 1'b0;
	nxt_data <= 1'b0;
	end

	else
	begin
	data <= async_in;
	nxt_data <= data;
	end
end

assign sync_out  = nxt_data;
endmodule
