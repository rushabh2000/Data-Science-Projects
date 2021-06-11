// $Id: $
// File name:   adder_nbit.sv
// Created:     2/4/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: nbit adder.

module adder_nbit
#(
	parameter BIT_WIDTH = 4
)
(
	input wire [(BIT_WIDTH -1):0]a, //inputs
	input wire [(BIT_WIDTH -1):0]b,
	input wire carry_in,
	output wire [(BIT_WIDTH -1):0]sum,
	output wire overflow
);
	wire [(BIT_WIDTH):0] carrys;
	genvar i;
	

	assign carrys[0] = carry_in;
	generate 
	for(i =0; i<= (BIT_WIDTH -1);i = i +1)
		begin
		adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i +1]));
	end
endgenerate
assign overflow = carrys[(BIT_WIDTH)];

endmodule
