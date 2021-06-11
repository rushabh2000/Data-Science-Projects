// $Id: $
// File name:   sensor_s.sv
// Created:     1/29/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: .

module sensor_s
(
	input reg [3:0] sensors, //input from sensors
	output reg error// detector result
);
	wire out1;
	wire out2;
	wire out3;

	AND2X1 red23output(.Y(out1),.A(sensors[1]),.B(sensors[3]));
	AND2X1 red24output (.Y(out2),.A(sensors[1]),.B(sensors[2]));
	OR2X1 red234output (.Y(out3),.A(out1),.B(out2));
	OR2X1 finaloutput (.Y(error),.A(out3),.B(sensors[0]));
	
endmodule
	
