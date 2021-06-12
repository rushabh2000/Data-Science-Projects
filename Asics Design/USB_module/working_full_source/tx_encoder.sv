// $Id: $
// File name:   tx_encoder.sv
// Created:     4/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: TX Encoder
module tx_encoder(
    input wire clk,
    input wire n_rst,
    input wire encoder_enable,
    input wire serial_out,
    input wire clock_timer,
    input logic eop_enable,
    output reg dminus_out,
    output reg dplus_out
);
reg nxt_dminus;
reg nxt_dplus;

always_ff @(posedge clk, negedge n_rst) begin
	if(n_rst == 1'b0) begin
		dminus_out<=0;
		dplus_out<=1; 
	end
	else begin
		dminus_out<=nxt_dminus;
		dplus_out<=nxt_dplus;
	end
end

always_comb begin : encoder_logic
    nxt_dminus = dminus_out;
	nxt_dplus = dplus_out;
    if(clock_timer == 1)begin
    if(eop_enable == 1'b1) begin
		nxt_dminus = 1'b0;
		nxt_dplus = 1'b0;
	end

    else if(serial_out == 1 && encoder_enable == 1)begin
        nxt_dminus = dminus_out;
	    nxt_dplus  = dplus_out;
    end

    else begin
        nxt_dminus = !dminus_out;
        nxt_dplus = !dplus_out;
        // unsure when to invert
    end
    end
    else begin
    nxt_dminus = dminus_out;
	nxt_dplus = dplus_out;
    end

    
end
endmodule
