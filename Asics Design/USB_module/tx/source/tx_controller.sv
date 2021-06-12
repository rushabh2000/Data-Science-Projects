// $Id: $
// File name:   tx_controller.sv
// Created:     4/14/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: TX controler
module tx_controller
(
    input logic clk,
    input logic n_rst,
    input logic clock_timer,
    input logic [6:0] buffer_occupancy,
    input logic [2:0] tx_packet,
    input logic [7:0] tx_packet_data,
    input logic byte_done,
    input logic activate_get_tx,
    output logic get_tx_packet_data,
    output logic tx_error,
    output logic tx_transfer_active,
    output logic [7:0] data_out,
    output logic encoder_enable,
    output logic timer_enable,
    output logic pts_enable,
    output logic eop_enable
);
typedef enum bit [3:0] {IDLE,SYNC,PID, DATA,CRC1,CRC2,EOP1,EOP2, EOP3,WAIT1} StateType;  
StateType state;
StateType nxt_state;
reg [2:0] stored_tx_packet;
reg [2:0] nxt_stored_tx_packet;
reg nxt_encoder_enable;
reg [7:0] nxt_data_out;
reg nxt_pts_enable;
reg nxt_timer_enable;
reg nxt_eop_enable;
reg nxt_get_tx_packet_data;
//reg nxt_tx_error;
reg nxt_tx_transfer_active;
reg [7:0] nxt_tx_packet_data;
reg [7:0] nxt_stored_tx_packet_data;
reg [7:0] stored_tx_packet_data;

always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst == 1'b0) begin
        state <= IDLE;
        stored_tx_packet <= '0;
        eop_enable <= '0;
        timer_enable <='0;
        pts_enable <= '0;
        data_out <= '0;
        encoder_enable <= '0;
        get_tx_packet_data <= '0;
        tx_transfer_active <= '0;// <= '0;
        //tx_packet_data <= '0;
        //tx_error <= 0;
        //nxt_tx_packet_data <='0;
        stored_tx_packet_data <= '0;
    end
    else begin
        state <= nxt_state;
        stored_tx_packet <= nxt_stored_tx_packet;
        encoder_enable <= nxt_encoder_enable;
        data_out <= nxt_data_out;
        pts_enable <= nxt_pts_enable;
        timer_enable <= nxt_timer_enable;
        eop_enable <= nxt_eop_enable;
        get_tx_packet_data <= nxt_get_tx_packet_data;
        tx_transfer_active <= nxt_tx_transfer_active;
        stored_tx_packet_data <= nxt_stored_tx_packet_data;
        //nxt_tx_packet_data <= tx_packet_data;
        //tx_packet_data <= nxt_tx_packet_data;
        //tx_error <= nxt_tx_error;
	end
end

always_comb begin : next_state_logic
    nxt_state = state;
    nxt_stored_tx_packet = stored_tx_packet;
    nxt_eop_enable = eop_enable;
    nxt_pts_enable = pts_enable;
    nxt_timer_enable = timer_enable;
    nxt_encoder_enable = encoder_enable;
    nxt_data_out = data_out;
    nxt_get_tx_packet_data = get_tx_packet_data;
    nxt_tx_transfer_active = tx_transfer_active;
    nxt_stored_tx_packet_data = stored_tx_packet_data;
    //nxt_tx_packet_data = tx_packet_data;
    //nxt_tx_error = tx_error;
    tx_error = 1'b0;
    case(state)
    	IDLE:begin
    		if(tx_packet >4)begin
        		tx_error = 1'b1;
   			end
        	if(tx_packet != 3'd0 && tx_error != 1'b1)begin 
        	    nxt_state = SYNC;
        	    nxt_stored_tx_packet = tx_packet;
        	    nxt_timer_enable = 1'b1;
        	    nxt_encoder_enable = 1'b1;
        	    nxt_pts_enable = 1'b1;
        	    nxt_data_out = 8'b10000000;
        	    nxt_tx_transfer_active = 1'b1;
        	end 
       
        	else begin
        		nxt_pts_enable = 1'b0;
        		nxt_state = IDLE;
        	end
    	end
    	SYNC:begin
        	if(byte_done ==1 && clock_timer ==1) begin
        	nxt_state = PID;
        	nxt_pts_enable = 1;
	
	            if(stored_tx_packet == 3'd1 ) begin //data
	            	nxt_data_out = 8'b00111100; // data
	            end
	            else if(stored_tx_packet == 3'd2 ) begin // ack
					nxt_data_out = 8'b00101101;
			    end
	            else if(stored_tx_packet == 3'd4) begin
	            	nxt_data_out = 8'b11100001;
	            end
	            else begin
	            	nxt_data_out = 8'b10100101;        
	            end
	        end
	        else begin
	            nxt_state = SYNC;
	            nxt_pts_enable = 0;
	        end
	    end

    	PID:begin
    	    nxt_get_tx_packet_data = 1'b0;	
	        if(activate_get_tx == 1'b1 && clock_timer == 1'b1 && stored_tx_packet == 3'b01) begin
				nxt_get_tx_packet_data = 1'b1;
			end
        	if(byte_done == 1 && clock_timer ==1)begin
        	    if(stored_tx_packet == 3'd1 )begin // data 
        	        nxt_state = DATA;
        	        nxt_pts_enable = 1'b1;
        	        nxt_stored_tx_packet_data = tx_packet_data;
        	        nxt_data_out = nxt_stored_tx_packet_data ;
        	       // nxt_get_tx_packet_data = 1'b1;
        	    end
        	    else if (stored_tx_packet != 3'd1 ) begin
        	        nxt_state = EOP1;
        	        nxt_eop_enable = 1'b1;
        	    end
        	    else begin
        	        nxt_state = EOP1;
        	    end
        	end
    
        	else begin
        	    nxt_pts_enable = 1'b0;
        	    nxt_state = PID;
        	end
    	end
    	DATA:begin
    	    nxt_get_tx_packet_data = 1'b0;
    	    if(byte_done == 1 &&  buffer_occupancy == 0 && clock_timer == 1'b1) begin // buffer occupanncy condition
    		    nxt_state = WAIT1;
    		    nxt_pts_enable = 1'b1;
    		    nxt_data_out = tx_packet_data;
    	    end
    	    else if(byte_done ==1 && clock_timer == 1'b1)begin
    		    nxt_state = DATA;
    		    nxt_stored_tx_packet_data = tx_packet_data;
    		    nxt_data_out = nxt_stored_tx_packet_data ;
    		    //nxt_data_out = nxt_tx_packet_data;
    		    nxt_pts_enable = 1'b1;
    		    //nxt_get_tx_packet_data = 1'b1;
    	    end
    	    else if(activate_get_tx == 1'b1 && clock_timer == 1'b1) begin
				nxt_get_tx_packet_data = 1'b1;
			end
    	    else begin
    		    nxt_state = DATA;
    		    nxt_pts_enable = 1'b0;
    	    end
    	end
    	WAIT1: begin
            if(byte_done == 1 && clock_timer == 1'b1)begin
                nxt_state = CRC1;
                nxt_pts_enable = 1'b1;
                nxt_data_out = 8'd13;
            end
            else
            nxt_state = WAIT1;
            nxt_pts_enable = 1'b0;
    	end

    	CRC1:begin
        	if(byte_done ==1 && clock_timer == 1'b1) begin
        		nxt_state = CRC2;
        		nxt_pts_enable = 1'b1;
        		nxt_data_out = 8'd14;
        	end 
        	else begin
        		nxt_state = CRC1;
        		nxt_pts_enable = 1'b0;
        	end
    	end
    	CRC2:begin
    	    if(byte_done ==1 && clock_timer == 1'b1)begin
    		    nxt_state = EOP1;
    		    nxt_eop_enable = 1'b1;
    	    end
    	    else begin
    		    nxt_state = CRC2;
    		    nxt_pts_enable = 1'b0;
    	    end
    	end
    	EOP1:begin
    	    if(clock_timer == 1'b1 )begin
        		nxt_eop_enable = 1'b1;
        	    nxt_state = EOP2;
        	end
        	else begin
        	    nxt_state = EOP1;
        	end
    	end
    	EOP2:begin
        	if(clock_timer == 1'b1)begin
  				nxt_state = EOP3;
				nxt_eop_enable = 1'b0;
        	end
        	else
        	    nxt_state = EOP2;
    	end
    	EOP3: begin
			if(clock_timer == 1'b1) begin
    	    	nxt_state = IDLE;
            	nxt_tx_transfer_active = 1'b0;
            	nxt_timer_enable = 1'b0;
            	nxt_encoder_enable = 1'b0;
            	nxt_pts_enable = 1'b0;
       	    	nxt_eop_enable = 1'b0;
        	    //nxt_data_out = 8'd0;
       		end
			else begin
				nxt_state = EOP3;
    			//nxt_pts_enable = 1'b0;
			end
		end
    endcase
end

/*
always_comb begin :output_logic

    case(state)
    IDLE:begin
	   
            data_out = '0;
    end
    SYNC:begin
  	    timer_enable = 1'b1;
	    pts_enable = 1'b1;
	    encoder_enable = 1'b1;
        eop_enable = 0;
        data_out = 8'b00000001;
    end
    PID:begin
        if(stored_tx_packet == 3'd1 && byte_done ==1 && clock_timer == 1)begin // data
            data_out = 8'b00111100;
        end
   else if(stored_tx_packet == 3'd2 && byte_done == 1 && clock_timer == 1) begin // ack
					data_out = 8'b00101101;
			end
     else if(stored_tx_packet == 3'd3 && byte_done == 1 && clock_timer == 1) begin // nak
					data_out = 8'b10100101;
                            
    		end
    end
    DATA:begin
        Get_TX_Packet_Data = 1'b1; // enable before getting data ? or enable in PID ?
        data_out = TX_Packet_Data ; 
    end
    CRC1:
	if(byte_done ==1 && clock_timer == 1)
        data_out = 8'd13;
    CRC2:
	if(byte_done ==1 && clock_timer == 1)
        data_out = 8'd14;
    EOP1:
        if(clock_timer == 0)begin
        eop_enable = 1'b1;
        data_out = '0;
        end
    EOP2:begin
        if(clock_timer == 0)begin
        eop_enable = 1'b1;
        data_out = '0;
        timer_enable = 1'b0;
	pts_enable = 1'b0;
	encoder_enable = 1'b0;
    end
    end
    endcase
end
*/
endmodule
