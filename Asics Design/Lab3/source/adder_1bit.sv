// $Id: $
// File name:   adder_1bit.sv
// Created:     1/29/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: adder1.
`timescale 1ns / 100ps
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

	always @ ( a,b,carry_in)
	begin
			assert( ( a == 1'b1 ) || (a == 1'b0))
			else $error ( " Input 'a' of component is not a digitl logic value");

			assert( ( b == 1'b1 ) || (b == 1'b0))
			else $error ( " Input 'b' of component is not a digitl logic value");
			
			assert( ( carry_in == 1'b1 ) || (carry_in == 1'b0))
			else $error ( " Input 'carry_in' of component is not a digitl logic value");
	end
	
always @ ( a,b,carry_in)
	begin
	#(2) assert((( a + b + carry_in) % 2) == sum)
	else $error ( " Input 'a' of component is not a digitl logic value");
	end

endmodule
	
