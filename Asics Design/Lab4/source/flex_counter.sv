// $Id: $
// File name:   flex_counter.sv
// Created:     2/12/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: flex_counter

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS - 1 : 0] rollover_val,
	output reg [NUM_CNT_BITS - 1:0] count_out,
	output reg rollover_flag
);
reg [NUM_CNT_BITS - 1 : 0]nxt_counter;
reg nxt_roll;

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
	begin
	count_out <= 1'b0;
	rollover_flag <= 1'b0;
	end

	else
	begin
	count_out <= nxt_counter;
	rollover_flag <= nxt_roll;
	end
end
always_comb
begin
	nxt_counter = count_out;
	nxt_roll = 1'b0;
	
	if(clear == 1)begin
	nxt_counter = 1'b0;
	end

	else if(count_enable == 1'b1)
	begin 
	if(rollover_flag == 1)
	nxt_counter = 1'b1;
	else
	nxt_counter = nxt_counter + 1;
	end

	if(rollover_val == nxt_counter)
	nxt_roll = 1'b1;
	
	
	
end
endmodule

