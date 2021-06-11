// $Id: $
// File name:   adder_16bit.sv
// Created:     2/5/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: 16bit adder.


module adder_16bit
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);

	// STUDENT: Fill in the correct port map with parameter override syntax for using your n-bit ripple carry adder design to be an 8-bit ripple carry adder design
	adder_nbit #(16) IX ((a),(b),(carry_in),(sum),(overflow));
	
	genvar i;
	generate
		for(i =0; i<= 15;i = i +1)
		begin
		always @ ( a ,b,carry_in)
		begin
			assert( ( a[i] == 1'b1 ) || (a[i] == 1'b0))
			else $error ( " Input 'a' of component is not a digitl logic value");

			assert( ( b[i] == 1'b1 ) || (b[i] == 1'b0))
			else $error ( " Input 'b' of component is not a digitl logic value");
			
			assert( ( carry_in == 1'b1 ) || (carry_in == 1'b0))
			else $error ( " Input 'carry_in' of component is not a digitl logic value");
		end
		end
	endgenerate
endmodule	
