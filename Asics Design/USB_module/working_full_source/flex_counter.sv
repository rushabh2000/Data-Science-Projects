// $Id: $
// File name:   flex_counter.sv
// Created:     2/10/2021
// Author:      Sam Kovnar
// Lab Section: 337-009
// Version:     1.0  Initial Design Entry
// Description: flexible and scalable counter

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [(NUM_CNT_BITS - 1):0] rollover_val,
	output wire [(NUM_CNT_BITS - 1):0] count_out,
	output wire rollover_flag
);

	reg [(NUM_CNT_BITS - 1):0] count, next_count;
	reg rollover, next_rollover;

	always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 0) begin		
			count <= 0;
			rollover <= 0;
		end		
		else begin
			count <= next_count;
			rollover <= next_rollover;
		end
	end

	always_comb begin
		if (clear == 1)
			next_count = 0;
		else if (count_enable == 0)
			next_count = count;
		else begin
			if (count >= rollover_val)
				next_count = 1;
			else
				next_count = count + 1;
		end
		if (next_count == rollover_val)
			next_rollover = 1;		
		else
			next_rollover = 0;
	end	
		
	assign count_out = count;
	assign rollover_flag= rollover;

endmodule
