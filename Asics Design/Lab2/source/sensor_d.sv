// $Id: $
// File name:   sensor_d.sv
// Created:     1/29/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: data flow version

module sensor_d
(
	input wire [3:0] sensors, //input from sensors
	output wire error// detector result
);
	wire out1;
	wire out2;
	wire out3;

assign error = sensors[0] | (sensors[1]&sensors[2]) | (sensors[1]&sensors[3]);

	
endmodule
	
