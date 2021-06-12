// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/19/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: flex pts.

module flex_pts_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire load_enable,
	input wire [NUM_BITS - 1:0] parallel_in,
	output wire serial_out
);
reg [NUM_BITS - 1 : 0] next_out;
reg [NUM_BITS - 1:0] buff_out;
always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
	begin
	buff_out <= '1;
	end

	else
	begin
	buff_out <= next_out;
	end
end

always_comb
begin
	next_out = buff_out;
	
	if(load_enable == 1'b1)
	begin
		
			next_out = parallel_in;
	end
	
	
		 else if((shift_enable == 1'b1) & (SHIFT_MSB == 1))
			next_out = {buff_out [NUM_BITS - 2:0],1'b1};
		else if ((shift_enable == 1'b1) & (SHIFT_MSB == 0))
			next_out = {1'b1,buff_out[NUM_BITS - 1:1]};
	

end
if(SHIFT_MSB == 1) 
assign serial_out = buff_out[NUM_BITS-1];
else
assign serial_out = buff_out[0];
endmodule


