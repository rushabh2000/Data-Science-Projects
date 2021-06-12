//Maybe rename this... top_level isn't very descriptive

module top_level_cdl
(
	input wire clk,
	input wire n_rst,
	//AHB
	input wire hsel,
	input wire [3:0] haddr,
	input wire [1:0] htrans,
	input wire [1:0] hsize,
	input wire hwrite,
	input wire [31:0] hwdata,
	output wire [31:0] hrdata,
	output wire hresp,
	output wire hready,

	//Other
	input wire dplus_in,
	input wire dminus_in,
	output wire dplus_out,
	output wire dminus_out,
	output wire d_mode
);
	//Receiver
	reg [2:0] 	rx_packet;
	reg 		rx_data_ready;
	reg 		rx_transfer_active;
	reg			rx_error;
	reg 		flush;
	reg [7:0]	rx_packet_data;
	reg 		store_rx_data;

	//Transmitter
	reg [2:0] 	tx_packet;
	reg 		tx_transfer_active;
	reg			tx_error;
	reg	[7:0]	tx_packet_data;
	reg 		get_tx_data;

	//Data Buffer
	reg [6:0]	buffer_occupancy;
	reg [7:0]	rx_data;
	reg			get_rx_data;
	reg [7:0]	tx_data;
	reg			store_tx_data;
	reg			clear;

	usb_rx RX (
		.clk(clk),
		.n_rst(n_rst),
		.d_plus(dplus_in),
		.d_minus(dminus_in),

		.rx_packet(rx_packet), //OUT
		.rx_data_ready(rx_data_ready), //OUT
		.rx_transfer_active(rx_transfer_active), //OUT
		.rx_error(rx_error), //OUT

		.flush(flush), //OUT
		.rx_packet_data(rx_packet_data), //OUT
		.store_rx_packet_data(store_rx_data), //OUT
		.buffer_ocup(buffer_occupancy) //IN
	);

	tx TX (
		.clk(clk),
		.n_rst(n_rst),
		.dplus_out(dplus_out),		//OUT
		.dminus_out(dminus_out),	//OUT

		.TX_Packet(tx_packet),						//IN
		.TX_ACTIVE_TRANSFER(tx_transfer_active),	//OUT
		.TX_ERROR(tx_error),						//OUT

		.TX_Packet_Data(tx_packet_data),	//IN
		.Get_TX_Packet_Data(get_tx_data),	//OUT
		.buffer_occupancy(buffer_occupancy)	//IN
	);

	data_buffer BUFF (
		.clk(clk),
		.n_rst(n_rst),

		.store_rx_packet_data(rx_packet_data),	//IN
		.store_rx_data(store_rx_data),		//IN
		.flush(flush),						//IN

		.tx_packet_data(tx_packet_data),	//OUT
		.get_tx_data(get_tx_data),			//IN

		.rx_data(rx_data),				//OUT
		.get_rx_data(get_rx_data),		//IN
		.store_tx_data(store_tx_data),	//IN
		.tx_data(tx_data),				//IN
		.clear(clear),					//IN
		.buffer_occupancy(buffer_occupancy) //OUT
	);

	ahb_lite_slave_cdl AHB (
		.clk(clk),
		.n_rst(n_rst),
		//AHB Lite Bus
		.hsel(hsel),
		.haddr(haddr),
		.htrans(htrans),
		.hsize(hsize),
		.hwrite(hwrite),
		.hwdata(hwdata),
		.hrdata(hrdata),
		.hresp(hresp),
		.hready(hready),
		//USB RX
		.rx_packet(rx_packet),
		.rx_data_ready(rx_data_ready),
		.rx_transfer_active(rx_transfer_active),
		.rx_error(rx_error),
		//Buffer
		.buffer_occupancy(buffer_occupancy),
		.rx_data(rx_data),
		.get_rx_data(get_rx_data),
		.store_tx_data(store_tx_data),
		.tx_data(tx_data),
		.clear(clear),
		//USB TX
		.tx_packet(tx_packet),
		.tx_transfer_active(tx_transfer_active),
		.tx_error(tx_error),
		//Misc
		.d_mode(d_mode)
	);

endmodule
