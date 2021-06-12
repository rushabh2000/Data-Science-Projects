module ahb_lite_slave_cdl
(
	//AHB
	input wire clk,
	input wire n_rst,
	input wire hsel,
	input wire [3:0] haddr,
	input wire [1:0] htrans,
	input wire [1:0] hsize,
	input wire hwrite,
	input wire [31:0] hwdata,
	output wire [31:0] hrdata,
	output wire hresp,
	output wire hready,

	//Receiver
	input wire [2:0] rx_packet,
	input wire rx_data_ready,
	input wire rx_transfer_active,
	input wire rx_error,
	output wire d_mode,
	
	//Data buffer	
	input wire [6:0] buffer_occupancy,
	input wire [7:0] rx_data,
	output wire get_rx_data,
	output wire store_tx_data,
	output wire [7:0] tx_data,
	output wire clear,

	//Transmitter
	output wire [2:0] tx_packet,
	input wire tx_transfer_active,
	input wire tx_error
);
	reg [15:0][7:0] mem, next_mem;
	reg [5:0][7:0] rwm;
	reg [31:0] curr_hrdata, next_hrdata;
	reg [3:0] last_haddr;
	reg [1:0] last_htrans, last_hsize, next_size, size, last_size;
	reg last_hwrite, last_hsel, last_hresp;
	reg raw_hazard, w_err, r_err;
	reg curr_hresp, curr_hready;
	reg curr_store_tx_data, curr_get_rx_data;

	reg [3:0] buff_state, next_buff_state;
	reg [1:0] buff_addr;

	reg last_tx_active, tx_active, last_rx_active, rx_active;
	reg next_tx_active, next_rx_active;

	typedef enum logic [3:0] {
		IDLE, WAIT_W, STORE1, STORE2, STORE3, STORE4,		
		WAIT_R, LOAD1, LOAD2, LOAD3, LOAD4
	} buff_state_list;

	typedef enum logic [2:0] {
		NO_PACKET, 
		DATA, 
		ACK, 
		NAK, 
		STALL,
		IN,
		OUT
	} packet_list;
	
	always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 1'b0) begin
			mem 		<= '0;
			curr_hrdata 	<= 0;
			last_hsel 	<= 0;
			last_haddr 	<= 0;
			last_htrans 	<= 0;
			last_hsize 	<= 0;
			last_hwrite	<= 0;
			last_hresp 	<= 0;
		end
		else begin
			mem 		<= next_mem;
			curr_hrdata 	<= next_hrdata;
			last_hsel 	<= hsel;
			last_haddr 	<= haddr;
			last_htrans 	<= htrans;
			last_hsize 	<= hsize;
			last_hwrite 	<= hwrite;
			last_hresp 	<= hresp;
		end
	end

	always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 1'b0) begin				
			last_rx_active <= 0;
			last_tx_active <= 0;
			tx_active <= 0;
			rx_active <= 0;
		end
		else begin
			last_rx_active <= rx_transfer_active;
			last_tx_active <= tx_transfer_active;
			tx_active <= next_tx_active;
			rx_active <= next_rx_active;
		end
	end

	always_comb begin
		if (last_tx_active & ~tx_transfer_active)
			next_tx_active = 0;
		else if (tx_transfer_active)
			next_tx_active = 1;
		else
			next_tx_active = tx_active;

		if (last_rx_active & ~rx_transfer_active)
			next_rx_active = 0;
		else if (rx_transfer_active)
			next_rx_active = 1;
		else
			next_rx_active = rx_active;
	end

	always_comb begin //memory write block
		rwm[5:0] = {mem[13:12], mem[3:0]};
		next_mem[3:0] = mem[3:0];
		next_mem[4][0] = rx_data_ready;
		next_mem[4][1] = (rx_packet == IN) ? 1 : 0;
		next_mem[4][2] = (rx_packet == OUT) ? 1 : 0;
		next_mem[4][3] = (rx_packet == ACK) ? 1 : 0;
		next_mem[4][4] = (rx_packet == NAK) ? 1 : 0;
		next_mem[4][7:5] = 0;
		next_mem[5] = {6'b0, tx_active, rx_active};
		//next_mem[5] = {6'b0, mem[5][1], mem[5][0]};
		next_mem[6] = {7'b0, rx_error};
		next_mem[7] = {7'b0, tx_error};
		next_mem[8] = {1'b0, buffer_occupancy};
		next_mem[11:9] = 0;
		next_mem[13:12] = mem[13:12];
		next_mem[15:14] = 0;

		if ((haddr == last_haddr) & (last_hwrite == 1) & (hwrite == 0))
			raw_hazard = 1;
		else
			raw_hazard = 0;
		
		if (mem[8] == 0) next_mem[13] = 0;
		//if (!(mem[12] == 0) & ~mem[5][1] & ~tx_active) next_mem[12] = 0;
		if (tx_active & ~next_tx_active) next_mem[12] = 0;

		if (last_hsel & (last_htrans == 2'd2)) begin
			if (last_hwrite) begin
				if (last_hsize == 0) begin //1 byte
					if (last_haddr < 4'd4) next_mem[0][7:0] = hwdata[7:0];
					else if (last_haddr == 12) next_mem[12][7:0] = hwdata[7:0];
					else if (last_haddr == 13) next_mem[13][7:0] = hwdata[7:0];
				end
				else if (last_hsize == 1) begin //2 bytes
					if (last_haddr < 4'h4) begin
						next_mem[0][7:0] = hwdata[ 7:0];
						next_mem[1][7:0] = hwdata[15:8];
					end					
					else if ((4'd11 < last_haddr) & (last_haddr < 4'd14)) begin
						next_mem[12][7:0] = hwdata[ 7:0];
						next_mem[13][7:0] = hwdata[15:8];
					end
				end
				else if ((last_hsize == 2) & (last_haddr < 4'd4)) begin //4 bytes
					next_mem[0] = hwdata[ 7: 0];
					next_mem[1] = hwdata[15: 8];
					next_mem[2] = hwdata[23:16];
					next_mem[3] = hwdata[31:24];
				end
			end
		end

		if (get_rx_data) next_mem[buff_addr] = rx_data;
	end

	always_comb begin //memory read block
		next_hrdata[31:0] = 0;
		
		if (hsel & ~hwrite & (htrans == 2)) begin
			if (raw_hazard) 
				next_hrdata[31:0] = hwdata[31:0];
			else if (haddr < 4'd4) begin 
				case (hsize)
					2'b00: 		next_hrdata[ 7:0] 	= mem[0];
					2'b01: 		next_hrdata[15:0] 	= mem[1:0];
					default: 	next_hrdata[31:0] 	= mem[3:0];
				endcase
			end
			else begin
				if ((hsize == 0) & (haddr < 4'd14)) //1 byte
					next_hrdata[7:0] = mem[haddr];
				else if ((hsize == 1) & (haddr < 4'd13)) //2 bytes
					next_hrdata[15:0] = {mem[haddr + 1], mem[haddr]};
				else if ((hsize == 2) & (haddr < 4'd11)) //4 bytes
					next_hrdata[31:0] = {mem[haddr + 3], mem[haddr + 2], mem[haddr + 1], mem[haddr]};
			end
		end
	end

	always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 0) begin
			size 		<= 0;
			last_size 	<= 0;
			buff_state 	<= 0;
		end
		else begin
			size 		<= next_size;
			last_size 	<= size;
			buff_state 	<= next_buff_state;
		end
	end

	always_comb begin //Buffer Manager
		next_size = (hsel & (htrans == 2)) ? hsize : size;

		curr_store_tx_data 	= 1'b0;
		curr_get_rx_data 	= 1'b0;
		buff_addr 	= 2'b00;

		//State machine
		case (buff_state)
			IDLE:	begin
					if (hsel & (htrans == 2) & (haddr < 4))
						next_buff_state = (hwrite) ? WAIT_W : WAIT_R;
					else
						next_buff_state = IDLE;
				end
			STORE1:	begin
					curr_store_tx_data = 1;
					buff_addr = 2'b00;
					next_buff_state = (last_size == 0) ? IDLE : STORE2;
				end
			STORE2:	begin
					curr_store_tx_data = 1;
					buff_addr = 2'b01;
					next_buff_state = (last_size == 1) ? IDLE : STORE3;
				end
			STORE3:	begin
					curr_store_tx_data = 1;
					buff_addr = 2'b10;
					next_buff_state = STORE4;
				end
			STORE4:	begin
					curr_store_tx_data = 1;
					buff_addr = 2'b11;
					next_buff_state = IDLE;
				end
			LOAD1: 	begin
					curr_get_rx_data = 1;
					buff_addr = 2'b00;
					next_buff_state = (last_size == 0) ? IDLE : LOAD2;
				end
			LOAD2: 	begin
					curr_get_rx_data = 1;
					buff_addr = 2'b01;
					next_buff_state = (last_size == 1) ? IDLE : LOAD3;
				end
			LOAD3: 	begin
					curr_get_rx_data = 1;
					buff_addr = 2'b10;
					next_buff_state = LOAD4;
				end
			LOAD4: 	begin
					curr_get_rx_data = 1;
					buff_addr = 2'b11;
					next_buff_state = IDLE;
				end
			default: next_buff_state = buff_state + 1; //WAIT_W and WAIT_R
		endcase 
	end

	always_comb begin //hresp controller
		w_err = 0;
		r_err = 0;
		if (hsel & hwrite) begin
			if ((4'b0011 < haddr) & (haddr < 4'b1100))
				w_err = 1;
		end
		else if (hsel & ~hwrite) begin
			if (((4'b1000 < haddr) & (haddr < 4'b1100)) | (4'b1110 < haddr))
				r_err = 1;
		end

		curr_hresp = w_err | r_err;
		curr_hready = ~(curr_hresp & (curr_hresp ^ last_hresp));
	end

	assign hrdata 	= curr_hrdata;
	assign hresp 	= curr_hresp;
	assign hready 	= curr_hready;

	assign clear 	 	= mem[13][0];
	assign tx_packet 	= (~tx_transfer_active & tx_active) ? 3'b0 : ((mem[12][2:0] > 3'b100) ? NO_PACKET : mem[12][2:0]);
	assign tx_data 		= mem[buff_addr];

	assign store_tx_data 	= curr_store_tx_data;
	assign get_rx_data 		= curr_get_rx_data;
	assign d_mode 			= (rx_transfer_active) ? 1'b0 : 1'b1;

endmodule
