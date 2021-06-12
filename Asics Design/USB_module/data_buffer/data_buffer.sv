module data_buffer
(
    input logic clk,
    input logic n_rst,
    input logic clear,
    input logic flush,
    input logic store_rx_data,
    input logic [7:0] rx_packet_data,
    input logic store_tx_data,
    input logic [7:0] tx_data,
    output logic [6:0] buffer_occupancy,
    input logic get_tx_data,
    input logic get_rx_data,
    output logic [7:0] tx_packet_data,
    output logic [7:0] rx_data
) ;

reg [63:0] w_ptr, nxt_w_ptr, r_ptr, nxt_r_ptr;
reg[63:0] [7:0] nxt_data, curr_data;
reg [7:0] nxt_tx_packet_data;
always_ff @( posedge clk, negedge n_rst) begin : addressing
    if(n_rst == 1'b0)begin
        r_ptr <= '0;
        w_ptr <= '0;
        curr_data <= '0;
        tx_packet_data <=0;
    end

    else begin  
        if(clear || flush)begin
            curr_data <= '0;
            w_ptr <= 0;
            r_ptr <= 0;
            tx_packet_data <=0;
        end
        else begin
            curr_data <= nxt_data;
            r_ptr <= nxt_r_ptr;
            w_ptr <= nxt_w_ptr;
            tx_packet_data <= nxt_tx_packet_data;
        end
    end   
end

always_comb begin : nxt_state_logic
    buffer_occupancy = 0;
    //tx_packet_data = 0;
    nxt_tx_packet_data = tx_packet_data;
    rx_data =0;
    nxt_data = curr_data;
    nxt_r_ptr = r_ptr;
    nxt_w_ptr = w_ptr;
    nxt_tx_packet_data = tx_packet_data;
    if(get_rx_data == 1'b1)begin
        nxt_r_ptr = r_ptr + 1;
        rx_data = curr_data[r_ptr];
    end

    if(store_tx_data == 1'b1 ) begin
        nxt_w_ptr = w_ptr + 1;
        nxt_data[w_ptr] =  tx_data;
    end

    if(store_rx_data) begin
        nxt_w_ptr = w_ptr + 1;
        nxt_data[w_ptr] =  rx_packet_data;
    end

     if(get_tx_data)begin
        nxt_r_ptr = r_ptr + 1;
        nxt_tx_packet_data = curr_data[r_ptr];
    end

    if(w_ptr < r_ptr)begin
        buffer_occupancy = 64 - (r_ptr - nxt_w_ptr);
    end
    else
    buffer_occupancy = w_ptr - r_ptr;

end

endmodule
