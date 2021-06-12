// $Id: $
// File name:   rx_rcu_usb.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: reciever controller block to execute FSM
module rx_rcu_usb(
	input clk, 
	input n_rst, 
	input logic        eop, 
	input logic        d_edge, 
	input logic        byte_recieved, 
	input logic        shift_enable, 
	input logic  [7:0] rx_packet_data, 
	input logic  [6:0] buff_ocp, 
	output logic [2:0] rx_packet, 
	output logic       flush, 
	output logic       store_rx_pd,
	output logic       rx_error, 
	output logic       rx_dr, 
	output logic       rx_ta
);

localparam SYNC = 8'b10000000;
//PID
localparam IN_PID = 3'b101;
localparam OUT_PID = 3'b110; 
localparam DATA_PID = 3'b001;
localparam ACK_PID = 3'b010;
localparam NACK_PID = 3'b011;

localparam CRC5 = 5'b10011;

/*
localparam OUT = 8'b10000111;
localparam IN = 8'b10010110; 
localparam DATA0 = 8'b11000011;
localparam DATA1 = 8'b11010010;
localparam ACK = 8'b01001011;
localparam NACK = 8'b01011010;*/

	localparam OUT 		= 8'b11100001; //0001
	localparam IN 		= 8'b01101001; //1001
	localparam DATA0	= 8'b11000011; //0011
	localparam DATA1	= 8'b11010010; //1011
	localparam ACK		= 8'b11010010; //0010
	localparam NACK		= 8'b01011010; //1010
	localparam STALL	= 8'b00011110; //1110

typedef enum bit [4:0] {IDLE, SYNC_BYTE, SYNC_ERROR, PID, IN_TOKEN, OUT_TOKEN, IN_TOKEN2, OUT_TOKEN2, ACK_STATE, NACK_STATE, CHECK_EOP, EOP1, EOP2, ERROR, DATA_STATE, WAIT, WAIT2, WAIT_EOP, STOP} stateType;
stateType state, nxt_state;

logic nxt_error, eop_error;


always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0) begin
			state <= IDLE;
			rx_error <= 0;
	end
	else begin
		state <= nxt_state;
		rx_error <= nxt_error;
	end
end

always_comb begin: NXT_LOGIC
	nxt_state = state;
	eop_error = 1'b0;
	flush = 1'b0;
	case(state)
		IDLE: begin 
			if(d_edge) nxt_state = SYNC_BYTE;
		end
		SYNC_BYTE: begin
			if(byte_recieved) begin
				if(rx_packet_data == SYNC) begin
					nxt_state = PID;
					flush = 1'b1;
				end
				else nxt_state = SYNC_ERROR;
			end
		end
		SYNC_ERROR: begin
			nxt_state = IDLE;
		end
		PID: begin
			nxt_state = PID;
			if(byte_recieved) begin
				if(rx_packet_data == OUT) begin 
					nxt_state = OUT_TOKEN; 
					flush = 1'b1; 
				end
				else if (rx_packet_data == IN) begin 
					nxt_state = IN_TOKEN; 
					flush = 1'b1; 
				end
				else if (rx_packet_data == DATA0 || rx_packet_data == DATA1) 
					nxt_state = DATA_STATE;
				else if (rx_packet_data == ACK) 
					nxt_state = ACK_STATE;
				else if (rx_packet_data == NACK) 
					nxt_state = NACK_STATE;
				else 
					nxt_state = ERROR;
			end
		end
		IN_TOKEN: begin
			if(byte_recieved) begin
				if(rx_packet_data == '0) //compare ADDRESS part of IN token 
					nxt_state = IN_TOKEN2;
				else nxt_state = ERROR;
			end
		end
  		IN_TOKEN2: begin  //rx_packet_data == {3'b000, crc5}
			nxt_state = IN_TOKEN2;
			if(byte_recieved) begin
					if(rx_packet_data == {3'b000, CRC5})
						nxt_state = WAIT_EOP;
			end
		end
		OUT_TOKEN: begin
			nxt_state = OUT_TOKEN;
			if(byte_recieved) begin
				if(rx_packet_data == '0) //compare ADDRESS part of OUT token TOKEN = {7'0, 4'0, CRC5}
					nxt_state = OUT_TOKEN2;
				else nxt_state = ERROR;
			end
		end
		OUT_TOKEN2:  begin
			nxt_state = OUT_TOKEN2;
			if(byte_recieved) begin
				if(rx_packet_data == {3'b000, CRC5})
						nxt_state = WAIT_EOP;
			end
		end
		ACK_STATE: begin
			if(eop)
				nxt_state = CHECK_EOP;
		end
		NACK_STATE:begin
			if(eop)
				nxt_state = CHECK_EOP;
		end
		DATA_STATE: begin  //will get byte recieved until eop
			if(byte_recieved) 
				nxt_state = WAIT;
		end
		WAIT: begin
			if(byte_recieved)
				nxt_state = WAIT2;
		end
		WAIT2: begin
			if(eop)
				nxt_state = CHECK_EOP;
			else nxt_state = ERROR;
		end
		WAIT_EOP: begin
			if(eop)	
				nxt_state = CHECK_EOP;
			else 
				nxt_state = WAIT_EOP;
		end
		CHECK_EOP: begin
			if(eop && ~byte_recieved)
				eop_error = 1'b1;
			else 
				eop_error = 1'b0;
			nxt_state = STOP;
		end
		EOP1: begin
			if(!eop_error) 
				nxt_state = EOP2;
			else 
				nxt_state = ERROR;
		end
		EOP2: begin
			if(!eop_error)
				nxt_state = STOP;
			else 
				nxt_state = ERROR;
		end
		STOP:begin
			if (~d_edge | eop)
				nxt_state = STOP;
			else
				nxt_state = IDLE;
		end
		ERROR: nxt_state = IDLE;
	endcase
end



always_comb begin : OUT_LOGIC
	nxt_error = 1'b0;
	rx_dr = 1'b0;
	rx_ta = 1'b0;
	rx_packet = '0; 
	store_rx_pd = 1'b0;
	case(state)
		IDLE: rx_ta =1'b0;
		SYNC_BYTE: begin
			rx_ta =1'b1;
			rx_dr = 1'b1;
		end
		SYNC_ERROR: begin
			nxt_error = 1'b1;
			rx_ta = 1'b1;
		end
		PID: begin
			rx_ta = 1'b1;
			rx_dr = 1'b0;
		end
		IN_TOKEN: rx_ta =1'b1;
		IN_TOKEN2:begin
			if(byte_recieved)
				rx_packet = IN_PID;
				rx_ta =1'b1;
			end
		OUT_TOKEN: rx_ta =1'b1;
		OUT_TOKEN2: begin
			if(byte_recieved)
				rx_packet = OUT_PID;
				rx_ta =1'b1;
			end
		ACK_STATE:begin 
			rx_ta = 1'b1;
			rx_packet = ACK_PID;
		end
		NACK_STATE:begin 
			rx_ta = 1'b1;
			rx_packet = NACK_PID;
		end
		DATA_STATE: begin
			rx_packet = DATA_PID; 
			rx_ta = 1'b1;	
		end
		WAIT: begin
			rx_packet = DATA_PID; 
			rx_ta = 1'b1;
			//store_rx_pd = 1'b1;
		end
		WAIT2: begin
			rx_packet = DATA_PID; 
			rx_ta = 1'b1;
			store_rx_pd = 1'b1;
		end
  		EOP1: rx_ta = 1'b1;
		EOP2: rx_ta = 1'b1;
		CHECK_EOP: rx_ta = 1'b0;
		WAIT_EOP: rx_ta = 1'b1;
		STOP: rx_ta = 1'b0;
		ERROR: begin
			nxt_error = 1'b1;
			rx_ta = 1'b0;
		end
	endcase
end

endmodule
