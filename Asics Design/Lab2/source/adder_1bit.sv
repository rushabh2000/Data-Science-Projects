// $Id: $
// File name:   adder_1bit.sv
// Created:     1/29/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: adder1.
module adder_1bit
(
	input wire a, //inputs
	input wire b,
	input wire carry_in,
	output wire sum,
	output wire carry_out
);
	assign sum = carry_in ^ (a ^ b);
	assign carry_out = ((! carry_in) & b & a) | (carry_in & (b | a));
endmodule
	
