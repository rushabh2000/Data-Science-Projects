// $Id: $
// File name:   flex_counter.sv
// Created:     2/12/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: flex_counter

module flex_counter2
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
	output reg rollover_flag,
    output reg activate_get_tx
);
reg [NUM_CNT_BITS : 0]nxt_counter;
reg nxt_roll;
reg nxt_activate_get_tx;

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
	begin
	count_out <= 1'b1;
	rollover_flag <= 1'b0;
    activate_get_tx <= '0;
	end

	else
	begin
    activate_get_tx <= nxt_activate_get_tx;
	count_out <= nxt_counter;
	rollover_flag <= nxt_roll;
	end
end
always_comb
begin
	nxt_counter = count_out;
	nxt_roll = rollover_flag;
    nxt_activate_get_tx = activate_get_tx;
	
	if(clear == 1)begin
		nxt_counter = 1'b1;
		nxt_roll = 1'b0;
        nxt_activate_get_tx = 1'b0;
	end

	else if(count_enable == 1'b1)
	begin 
        nxt_activate_get_tx = 1'b0;

        if( count_out == rollover_val - 2)begin
            nxt_activate_get_tx = 1'b1;
        end
		if(rollover_flag == 1)begin
			nxt_counter = 1'b1;
			nxt_roll = 0;
		end
	else if ( count_out == rollover_val - 1) begin
		nxt_counter = count_out + 1;
		nxt_roll = 1;
	end
	else
	begin
		nxt_counter = count_out + 1;
		nxt_roll = 1'b0;
	end
	end
else
begin
nxt_counter = count_out ;
nxt_roll = rollover_flag;
end
	
	
	
end
endmodule

