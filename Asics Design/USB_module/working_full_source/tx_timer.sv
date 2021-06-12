// $Id: $
// File name:   tx_timer.sv
// Created:     4/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: TX Timer module
module tx_timer(
    input wire clk,
    input wire n_rst,
    input logic timer_enable,
    output logic clock_timer,
    output logic byte_done,
	output logic activate_get_tx
);
reg[3:0] count_out;
reg[3:0] count_out2;


flex_counter #(4)A(.clk(clk),.count_enable(timer_enable),.clear(1'b0),.n_rst(n_rst),.count_out(count_out),.rollover_flag(clock_timer),.rollover_val(4'd8));
flex_counter2 #(4)B(.clk(clk),.count_enable(clock_timer),.clear(1'b0),.n_rst(n_rst),.count_out(count_out2),.rollover_flag(byte_done),.rollover_val(4'd8), .activate_get_tx(activate_get_tx));


endmodule
