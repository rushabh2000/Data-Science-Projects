// $Id: $
// File name:   adder_nbit.sv
// Created:     2/3/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: scaleable adder design
module adder_nbit
#( parameter BIT_WIDTH =4)
( input wire [(BIT_WIDTH-1) :0] a, input wire [BIT_WIDTH-1:0] b, input wire carry_in, output wire [BIT_WIDTH-1:0] sum, output wire overflow);

wire [BIT_WIDTH +1:0] interm;
genvar i;

assign interm[0] = carry_in;
generate
for( i=0; i< BIT_WIDTH; i++)
begin
	adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(interm[i]), .sum(sum[i]), .carry_out(interm[i +1]));


end
endgenerate

assign overflow = interm[BIT_WIDTH];






endmodule
