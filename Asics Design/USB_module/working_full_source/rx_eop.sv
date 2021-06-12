// $Id: $
// File name:   rx_eop.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: dectects the end of a packet

module rx_eop (
	input clk, 
	input n_rst, 
	input logic d_plus_sync, 
	input logic d_minus_sync, 
	input logic d_edge, 
	input logic shift_en,
	output logic eop
);
	typedef enum bit [2:0] {IDLE, WAIT, WAIT2, STOP, CHECK1, CHECK2, CHECK3} stateType;
	stateType state, nxt_state;

	always_ff @(posedge clk, negedge n_rst) begin
		if(n_rst == 1'b0)
			state <= IDLE;
		else
			state <= nxt_state;
	end

/*
	always_comb begin
		eop = ~d_plus_sync & ~d_minus_sync; 
		if (~shift_en) 
			nxt_state = state;		
		else begin*/
			/*nxt_state = state;
			eop = 1'b0;
			case(state)
				CHECK2: begin
					if ((d_plus_sync == 1'b0) & (d_minus_sync == 1'b0)) begin
						eop = 1'b1;
						nxt_state = WAIT;
					end
				end
				CHECK1: begin
					if ((d_plus_sync == 1'b1) & (d_minus_sync == 1'b0)) begin
						eop = 1'b1;
						nxt_state = CHECK2;
					end
				end
				default: begin
					if ((d_plus_sync == 1'b0) & (d_minus_sync == 1'b0)) begin
						eop = 1'b1;
						nxt_state = CHECK1;
					end
					else
						nxt_state = IDLE;
				end
			endcase*/
				/*IDLE:	begin 
					if(d_edge == 1'b1)
						nxt_state = CHECK1;
					else nxt_state = IDLE;
				end
				CHECK1:begin  
					if((d_plus_sync == 1'b0) && (d_minus_sync == 1'b0))
						nxt_state = CHECK2;
					else nxt_state = CHECK1;
				end
				CHECK2:begin 
					if((d_plus_sync == 1'b0) && (d_minus_sync == 1'b0))
						nxt_state = CHECK3;
					else nxt_state = CHECK1;
				end
				CHECK3: begin 
					if((d_plus_sync == 1'b1) && (d_minus_sync == 1'b0))
						nxt_state = WAIT;
					else nxt_state = CHECK1;
				end
				WAIT: begin 
					eop = 1'b1;
					nxt_state = WAIT2;
				end
				WAIT2: begin 
					eop = 1'b1;
					nxt_state = STOP;
				end
				STOP: begin 
					eop = 1'b0;
					nxt_state = IDLE;
				end
			endcase*/

			//eop = ~d_plus_sync & ~d_minus_sync;
		/*end
	end*/

	assign eop = ~d_plus_sync & ~d_minus_sync;
endmodule
