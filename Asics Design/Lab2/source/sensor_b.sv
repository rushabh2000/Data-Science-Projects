// $Id: $
// File name:   sensor_b.sv
// Created:     1/29/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: behavioral implementation
module sensor_b
(
	input wire [3:0] sensors, //input from sensors
	output reg error// detector result
);
	 

	always_comb
	begin
	error = 0;
	error = sensors[0] | (sensors[1]&sensors[2]) | (sensors[1]&sensors[3]);
	end
	
endmodule
