// $Id: $
// File name:   adder_1bit.sv
// Created:     2/2/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: 1-bit full adder
module adder_1bit (input reg a, input reg b, input reg carry_in, output reg sum, output reg carry_out);


assign sum = carry_in ^ (a ^ b);

assign carry_out = ((~carry_in) & b & a) | (carry_in & (b | a));



endmodule
