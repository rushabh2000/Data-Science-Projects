// $Id: $
// File name:   rx_timer.sv
// Created:     4/19/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: timing controller of USB reciver
module rx_timer (input clk, input n_rst, input logic d_edge, input logic rx_transfer_active, output logic shift_enable, output logic byte_recieved);


logic [3:0] clk_count; 
logic[3:0] bit_count; 
logic temp_flag;

logic enable_timer;

reg edge_flag, next_edge_flag;

typedef enum bit [2:0] {IDLE, WAIT,WAIT2, STOP, WAIT3} stateType;
stateType state, nxt_state;

always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 1'b0)
		edge_flag <= 1'b0;
	else
		edge_flag <= next_edge_flag;
end

always_comb begin
	next_edge_flag = edge_flag;

	

	if (d_edge == 1'b1)
		next_edge_flag = 1'b1;
end

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
			state <= IDLE;
	else
		state <= nxt_state;
end

always_comb begin
nxt_state = state;
//enable_timer = 1'b0;

			case(state)
			IDLE: begin
			if(d_edge == 1'b1) nxt_state = WAIT;
			else nxt_state = IDLE;
			end
			WAIT: nxt_state = WAIT2;
			WAIT2: nxt_state = WAIT3;
			WAIT3: nxt_state = STOP;
			STOP: begin enable_timer = 1'b1;
						nxt_state = IDLE;
			end
			endcase
end

flex_counter #(.NUM_CNT_BITS(4)) CLK (.clk(clk), .n_rst(n_rst), .count_enable(/*enable_timer*/edge_flag), 
.rollover_val(4'b1000), .count_out(clk_count), .rollover_flag(temp_flag), .clear(/*byte_recieved*/1'b0));

/*
always_comb begin
//	shift_enable = temp_flag;
	if(clk_count == 4'b0001) begin
		shift_enable = 1'b1;
	end
	else
		shift_enable = 1'b0;
	end
end
*/

assign shift_enable = (clk_count == 4'd1) ? 1'b1 : 1'b0;

//check rollover val
flex_counter #(.NUM_CNT_BITS(4)) bitc (.clk(clk), .n_rst(n_rst), .count_enable(/*temp_flag*/shift_enable), .rollover_val(4'b1000),
.count_out(bit_count), .rollover_flag(byte_recieved), .clear(byte_recieved));

endmodule
