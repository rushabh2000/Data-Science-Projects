// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/22/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: flexiable serial to parallel shift register
module flex_stp_sr (clk, n_rst, shift_enable, serial_in, parallel_out);

parameter NUM_BITS = 4;
parameter SHIFT_MSB = 1; 

input clk, n_rst, shift_enable;
input reg serial_in;
output reg [(NUM_BITS-1) :0] parallel_out;

reg [(NUM_BITS-1) :0] nxt_out;

always_ff @(posedge clk, negedge n_rst)
begin

if(n_rst == 1'b0)
	parallel_out <= {NUM_BITS{1'b1}};
else
	parallel_out <= nxt_out;

end

always_comb 
begin
nxt_out = parallel_out;

if(SHIFT_MSB)begin
if(shift_enable == 1'b1)begin
	nxt_out = {parallel_out[(NUM_BITS-2):0], serial_in};

	end
end
else begin
if(shift_enable == 1'b1)begin
	nxt_out = {serial_in, parallel_out[(NUM_BITS-1):1]};

	end
end
end

endmodule

