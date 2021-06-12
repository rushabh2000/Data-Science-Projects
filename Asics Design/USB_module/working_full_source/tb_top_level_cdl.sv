// $Id: $
// File name:   tb_top_level_cdl.sv
// Created:     2021/04/25
// Author:      Tim Pritchett
// Lab Section: 9999
// Version:     1.0  Initial Design Entry
// Description: Full ABH-Lite slave/bus model test bench

`timescale 1ns / 10ps

module tb_top_level_cdl();

	// Timing related constants
	localparam CLK_PERIOD = 10;
	localparam BUS_DELAY  = 800ps; // Based on FF propagation delay

	// Sizing related constants
	localparam DATA_WIDTH      = 4;
	localparam ADDR_WIDTH      = 8;
	localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
	localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
	localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;

	// HTRANS Codes
	localparam TRANS_IDLE = 2'd0;
	localparam TRANS_BUSY = 2'd1;
	localparam TRANS_NSEQ = 2'd2;
	localparam TRANS_SEQ  = 2'd3;

	// HBURST Codes
	localparam BURST_SINGLE = 3'd0;
	localparam BURST_INCR   = 3'd1;
	localparam BURST_WRAP4  = 3'd2;
	localparam BURST_INCR4  = 3'd3;
	localparam BURST_WRAP8  = 3'd4;
	localparam BURST_INCR8  = 3'd5;
	localparam BURST_WRAP16 = 3'd6;
	localparam BURST_INCR16 = 3'd7;
	
	// Define our address mapping scheme via constants
	localparam ADDR_READ_MIN  = 8'd0;
	localparam ADDR_READ_MAX  = 8'd127;
	localparam ADDR_WRITE_MIN = 8'd64;
	localparam ADDR_WRITE_MAX = 8'd255;

	localparam SYNC_BYTE    = 8'b10000000;
	localparam ACK_BYTE     = 8'b00101101;
	localparam NAK_BYTE     = 8'b10100101;
	localparam DATA_BYTE    = 8'b00111100;

	localparam TX_IDLE      = 3'd0;
	localparam TX_SEND_DATA = 3'd1;
	localparam TX_ACK       = 3'd2;
	localparam TX_NAK       = 3'd3;

	logic [63:0] [7:0] data_list;
	logic [63:0] [7:0] result_list;
	integer idx_tx_packet_data = 0;

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
	localparam NACK = 8'b01011010;
*/
	localparam OUT 		= 8'b11100001; //0001
	localparam IN 		= 8'b01101001; //1001
	localparam DATA0	= 8'b11000011; //0011
	localparam DATA1	= 8'b11010010; //1011
	localparam ACK		= 8'b11010010; //0010
	localparam NAK		= 8'b01011010; //1010
	localparam STALL	= 8'b00011110; //1110
		
	//*****************************************************************************
	// Declare TB Signals (Bus Model Controls)
	//*****************************************************************************
	// Testing setup signals
	bit                          tb_enqueue_transaction;
	bit                          tb_transaction_write;
	bit                          tb_transaction_fake;
	bit [(ADDR_WIDTH - 1):0]     tb_transaction_addr;
	bit [((DATA_WIDTH*8) - 1):0] tb_transaction_data [];
	bit [2:0]                    tb_transaction_burst;
	bit                          tb_transaction_error;
	bit [2:0]                    tb_transaction_size;
	// Testing control signal(s)
	logic    tb_model_reset;
	logic    tb_enable_transactions;
	integer  tb_current_addr_transaction_num;
	integer  tb_current_addr_beat_num;
	logic    tb_current_addr_transaction_error;
	integer  tb_current_data_transaction_num;
	integer  tb_current_data_beat_num;
	logic    tb_current_data_transaction_error;
	
	string                 tb_test_case;
	integer                tb_test_case_num;
	bit   [DATA_MAX_BIT:0] tb_test_data [];
	string                 tb_check_tag;
	logic                  tb_mismatch;
	logic                  tb_check;
	integer                tb_i;
	
	//*****************************************************************************
	// General System signals
	//*****************************************************************************
	logic tb_clk;
	logic tb_n_rst;
	
	//*****************************************************************************
	// AHB-Lite-Slave side signals
	//*****************************************************************************
	logic                          tb_hsel;
	logic [1:0]                    tb_htrans;
	logic [2:0]                    tb_hburst;
	logic [(ADDR_WIDTH - 1):0]     tb_haddr;
	logic [2:0]                    tb_hsize;
	logic                          tb_hwrite;
	logic [((DATA_WIDTH*8) - 1):0] tb_hwdata;
	logic [((DATA_WIDTH*8) - 1):0] tb_hrdata;
	logic                          tb_hresp;
	logic                          tb_hready;

	//Output
	logic 		tb_dplus_in;
	logic 		tb_dminus_in;
	logic 		tb_dplus_out;
	logic 		tb_dminus_out;
	logic		tb_d_mode;

	logic [((DATA_WIDTH*8) - 1):0] tb_last_hrdata;
	
	//*****************************************************************************
	// Clock Generation Block
	//*****************************************************************************
	// Clock generation block
	always begin
		// Start with clock low to avoid false rising edge events at t=0
		tb_clk = 1'b0;
		// Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		// Wait half of the clock period before toggling clock value via rerunning the block 	(maintain 50% duty cycle)
		#(CLK_PERIOD/2.0);
	end
	
	//*****************************************************************************
	// Bus Model Instance
	//*****************************************************************************
	ahb_lite_bus_cdl 
		#(  
			.DATA_WIDTH(4), 
			.ADDR_WIDTH(8)
		)
	   	BFM(
			.clk(tb_clk),
			// Testing setup signals
			.enqueue_transaction(tb_enqueue_transaction),
			.transaction_write(tb_transaction_write),
			.transaction_fake(tb_transaction_fake),
			.transaction_addr(tb_transaction_addr),
			.transaction_size(tb_transaction_size),
			.transaction_data(tb_transaction_data),
			.transaction_burst(tb_transaction_burst),
			.transaction_error(tb_transaction_error),
			// Testing controls
			.model_reset(tb_model_reset),
			.enable_transactions(tb_enable_transactions),
			.current_addr_transaction_num(tb_current_addr_transaction_num),
			.current_addr_beat_num(tb_current_addr_beat_num),
			.current_addr_transaction_error(tb_current_addr_transaction_error),
			.current_data_transaction_num(tb_current_data_transaction_num),
			.current_data_beat_num(tb_current_data_beat_num),
			.current_data_transaction_error(tb_current_data_transaction_error),
			// AHB-Lite-Slave Side
			.hsel(tb_hsel),
			.haddr(tb_haddr),
			.hsize(tb_hsize),
			.htrans(tb_htrans),
			.hburst(tb_hburst),
			.hwrite(tb_hwrite),
			.hwdata(tb_hwdata),
			.hrdata(tb_hrdata),
			.hresp(tb_hresp),
			.hready(tb_hready)
	);

	//*****************************************************************************
	// Test Module Instance
	//*****************************************************************************
	top_level_cdl TOP (
		//AHB-Lite
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.hsel(tb_hsel),
		.haddr(tb_haddr[3:0]),
		.htrans(tb_htrans[1:0]),
		.hsize(tb_hsize[1:0]),
		.hwrite(tb_hwrite),
		.hwdata(tb_hwdata),
		.hrdata(tb_hrdata),
		.hresp(tb_hresp),
		.hready(tb_hready),

		//USB
		.dplus_in(tb_dplus_in),
		.dminus_in(tb_dminus_in),
		.dplus_out(tb_dplus_out),
		.dminus_out(tb_dminus_out),
		.d_mode(tb_d_mode)
	);
		
	
	//*****************************************************************************
	// DUT Related TB Tasks
	//*****************************************************************************
	// Task for standard DUT reset procedure
	task reset_dut;
	begin
		// Activate the reset
		tb_n_rst = 1'b0;
	
		// Maintain the reset for more than one cycle
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Wait until safely away from rising edge of the clock before releasing
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		
		// Leave out of reset for a couple cycles before allowing other stimulus
		// Wait for negative clock edges, 
		// since inputs to DUT should normally be applied away from rising clock edges
		@(negedge tb_clk);
		@(negedge tb_clk);
	end
	endtask
	
	//*****************************************************************************
	// Bus Model Usage Related TB Tasks
	//*****************************************************************************
	// Task to pulse the reset for the bus model
	task reset_model;
	begin
		tb_model_reset = 1'b1;
		#(0.1);
		tb_model_reset = 1'b0;
	end
	endtask
	
	// Task to enqueue a new transaction
	task enqueue_transaction;
		input bit for_dut;
		input bit write_mode;
		input bit [ADDR_MAX_BIT:0] address;
		input bit [DATA_MAX_BIT:0] data [];
		input bit [2:0] burst_type;
		input bit expected_error;
		input bit [1:0] size;
	begin
		// Make sure enqueue flag is low (will need a 0->1 pulse later)
		tb_enqueue_transaction = 1'b0;
		#0.1ns;
		
		// Setup info about transaction
		tb_transaction_fake  = ~for_dut;
		tb_transaction_write = write_mode;
		tb_transaction_addr  = address;
		tb_transaction_data  = data;
		tb_transaction_error = expected_error;
		tb_transaction_size  = {1'b0,size};
		tb_transaction_burst = burst_type;
	
		// Pulse the enqueue flag
		tb_enqueue_transaction = 1'b1;
		#0.1ns;
		tb_enqueue_transaction = 1'b0;
	end
	endtask
	
	// Task to wait for multiple transactions to happen
	task execute_transactions;
		input integer num_transactions;
		integer wait_var;
		integer last_hwrite;
	begin
		// Activate the bus model
		tb_enable_transactions = 1'b1;
		@(posedge tb_clk);
		//tb_last_hrdata = tb_hrdata;
		
		// Process the transactions (all but last one overlap 1 out of 2 cycles
		for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
			@(posedge tb_clk);	
			//if (last_hwrite == 1'b0) tb_last_hrdata = tb_hrdata;
			last_hwrite = tb_hwrite;
		end
		
		@(negedge tb_clk);
		tb_last_hrdata = tb_hrdata;
		// Run out the last one (currently in data phase)
		@(posedge tb_clk);
	
		// Turn off the bus model
		@(negedge tb_clk);	
		tb_enable_transactions = 1'b0;
	end
	endtask

//////////////////////////////////////////////////////////////////////
//																	//
//			Stuff from RX Test Bench								//
//																	//
//////////////////////////////////////////////////////////////////////
  
	// Test bench debug signals
	// Overall test case number for reference
	//logic tb_check;
	// Test case 'inputs' used for test stimulus
	//reg [7:0] tb_test_data;
	logic tb_test_eop;
	byte tb_test_data_packet;
	integer ones_cnt;
	integer tb_packet_num;

	// Test case expected output values for the test case
	logic [7:0] tb_expected_packet_data;
  	logic [3:0] tb_expected_packet;
	logic tb_expected_error;
	logic tb_expected_data_ready;
	logic tb_expected_transfer_active;
	logic tb_expected_flush;
	logic tb_expected_store_rx_packet_data;
  
/*
	task check_outputs;
	begin
		// Data recieved should match the data sent
		assert(tb_expected_packet == tb_rx_packet)
			$info("Test case %0d: Test data correctly received", tb_test_num);
		else
			$error("Test case %0d: Test data was not correctly received", tb_test_num);

		assert(tb_expected_packet_data == tb_packet_data)
			$info("Test case %0d: Test data correctly received", tb_test_num);
		else
			$error("Test case %0d: Test data was not correctly received", tb_test_num);
       
		assert(tb_expected_data_ready == tb_data_ready)
			$info("Test case %0d: DUT correctly asserted the data ready flag", tb_test_num);
		else
			$error("Test case %0d: DUT did not correctly assert the data ready flag", tb_test_num);

		assert(tb_expected_flush == tb_flush)
			$info("Test case %0d: DUT correctly asserted the flush flag", tb_test_num);
		else
			$error("Test case %0d: DUT did not correctly assert the flush flag", tb_test_num);

		assert(tb_expected_store_rx_packet_data == tb_store_rx_packet_data)
			$info("Test case %0d: DUT correctly asserted the store packet data flag", tb_test_num);
		else
			$error("Test case %0d: DUT did not correctly assert the store packet data flag", tb_test_num);
		assert(tb_expected_transfer_active == tb_transfer_active)
			$info("Test case %0d: DUT correctly asserted the transfer active flag", tb_test_num);
		else
			$error("Test case %0d: DUT did not correctly assert the transfer active flag", tb_test_num);
	
	    if(1'b0 == tb_expected_error) begin
			assert(1'b0 == tb_error)
				$info("Test case %0d: DUT correctly shows no error", tb_test_num);
			else
				$error("Test case %0d: DUT incorrectly shows an error", tb_test_num);
		end
		else begin
			assert(1'b1 == tb_error)
				$info("Test case %0d: DUT correctly shows an error", tb_test_num);
			else
				$error("Test case %0d: DUT incorrectly shows no error", tb_test_num);
		end
	end
	endtask
*/
/*
	task send_byte;
		input [7:0] data;
		logic [7:0] reversed;
		integer i;
		integer cnt;
	begin 
			@(negedge tb_clk);
			reversed = {<<{data}};
			for(i=0; i<8; i++) begin
				send_bit(reversed[i]);
			end
	end
	endtask
*/
	task send_byte;
		input [7:0] data;
		integer i;
		logic prev;
	begin
		prev = tb_dplus_in;
		@(negedge tb_clk);
		for (i = 0; i < 8; i++) begin			
			if (data[i] == 1'b1)
				send_bit(prev);
			else begin
				send_bit(~prev);
				prev = ~prev;
			end
		end
	end
	endtask

/*
	task send_pid;
		input[7:0] data;
		integer i;
	begin
		for(i=0; i<8; i++) begin
			send_bit(data[i]);
		end
	end
	endtask
*/

	task send_bit;
		input data;
	begin
		tb_dplus_in = data;
		tb_dminus_in = ~data;
		#(CLK_PERIOD * 8);
	end
	endtask

	task send_sync;
		logic [7:0] data;
		//tb_dplus_in = 1'b1;
		//tb_dminus_in = 1'b0;
	begin
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		data = 8'b10000000;
		send_byte(data);
	end
	endtask

	task send_byte_NRZ;
		input byte data;
		integer i;
		integer cnt;
		logic prev;
		bit check;
	begin
		@(negedge tb_clk);
		prev = tb_dplus_in;
		for(i=0; i<8; i++) begin
			prev = tb_dplus_in;
			if(ones_cnt == 6) begin
				send_bit(~prev);
				ones_cnt = 0;
				i -= 1;
			end 
			else if(data[i] == 1'b1) begin
					send_bit(prev);
					ones_cnt += 1;
			end
		end
		//check_packet(data == tb_packet_data, "tb_packet_data");
	end
	endtask

	task send_eop;
		integer i;
	begin
		for(i=0; i<2; i++) begin
			tb_dplus_in = 1'b0;
			tb_dminus_in = 1'b0;
			#(CLK_PERIOD *8);
		end
		tb_dplus_in = 1'b1;
		tb_dminus_in = 1'b0;
		#(CLK_PERIOD *8);
	end
	endtask

	task send_bad_eop;
		integer i;
	begin
		tb_dplus_in = 1'b0;
		tb_dminus_in = 1'b0;
		#(CLK_PERIOD *8);
		tb_dplus_in = 1'b1;
		tb_dminus_in = 1'b0;
		#(CLK_PERIOD *8);
	end
	endtask

	task send_token_data;
		input logic [6:0] addr;
		input logic [3:0] endpoint;
		input logic [4:0] crc;
		logic [10:0] data;
		logic [10:0] d;
		logic prev;
		logic [4:0] data5;
		logic curr;
	begin
		d = {addr, endpoint};
		data = {d[2:0], d[10:3]};
		for(int i=0; i< 11; i+=1) begin
			prev = data;
			if(curr == 1'b0) begin
				send_bit(~prev);
				ones_cnt = 0;		
			end 
			else if(curr == 1'b1) begin
					send_bit(prev);
					ones_cnt += 1;
			end 
			else begin
				send_bit(~prev);
				ones_cnt = 0;
			end
		end
		//check_packet(data == tb_packet_data, "tb_packet_data");
	end
	endtask

	task send_data_stream;
		input logic [7:0] data [];
	begin
		foreach (data[i]) send_byte_NRZ(data[i]);
	end
	endtask

	task check_packet;
		input bit conditional;
		input string var_name;
	begin
		if(conditional) begin
			tb_check =1;
			$display("%s %d CORRECT: %s test case", var_name, conditional, var_name);
		end 
		else begin
			$error("%s %d INCORRECT: %s test case", var_name, conditional, var_name);
		end
	end
	endtask 

	task send_random_data_stream;
		input int size;
		byte data [$];
	begin
		for(int i =0; i < size; i++) begin
			data.push_back($urandom(10));
		end
		foreach (data[i]) begin
			tb_packet_num = i;
		end
	end
	endtask


	task reset_input; 
	begin
		tb_dplus_in= 1'b1;
		tb_dminus_in = 1'b0;
	end
	endtask

/*
task reset_expected_out;
	begin
		tb_expected_packet_data = '0;
    tb_expected_packet = '0;
		tb_expected_error = 1'b0;
		tb_expected_data_ready = 1'b0;
		tb_expected_transfer_active = 1'b0;
		tb_expected_flush = 1'b0;
	  tb_expected_store_rx_packet_data = 1'b0;
	end
endtask
*/

	task wait_until_idle;
		input integer is_send;
		integer is_idle;
		bit [DATA_MAX_BIT:0] expect_read [];
	begin
		is_idle = 0;
		expect_read = (is_send) ? '{32'h00000002} : '{32'h00000001};
		#(CLK_PERIOD * 2); //buffer
		while(is_idle == 0) begin
			enqueue_transaction(1'b1, 1'b0, 8'h5, expect_read, BURST_SINGLE, 1'b0, 2'd0);
			execute_transactions(1);
			if (tb_last_hrdata == 32'h00000000)
				is_idle = 1;
			@(posedge tb_clk);
		end
		$info("Ignore the previous error, it is deliberate. See wait_until_idle task for details.");
		#(CLK_PERIOD * 2);	//buffer
	end
	endtask

	task memory_check;
	begin
		enqueue_transaction(1'b1, 1'b0, 8'hC, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0); //TPCR = cleared?
		enqueue_transaction(1'b1, 1'b0, 8'h6, '{32'h0}, BURST_SINGLE, 1'b0, 2'd1); //Errors?
		enqueue_transaction(1'b1, 1'b0, 8'h8, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0); //Buffer empty?
		execute_transactions(3);
	end
	endtask
	
//*****************************************************************************
//*****************************************************************************
// Main TB Process
//*****************************************************************************
//*****************************************************************************
initial begin
	// Initialize Test Case Navigation Signals
	tb_test_case       = "Initialization";
	tb_test_case_num   = -1;
	tb_test_data       = new[1];
	tb_check_tag       = "N/A";
	tb_check           = 1'b0;
	tb_mismatch        = 1'b0;
	// Initialize all of the directly controled DUT inputs
	tb_n_rst          = 1'b1;
	// Initialize all of the bus model control inputs
	tb_model_reset          = 1'b0;
	tb_enable_transactions  = 1'b0;
	tb_enqueue_transaction  = 1'b0;
	tb_transaction_write    = 1'b0;
	tb_transaction_fake     = 1'b0;
	tb_transaction_addr     = '0;
	tb_transaction_data     = new[1];
	tb_transaction_error    = 1'b0;
	tb_transaction_size     = 3'd0;
	tb_transaction_burst    = 3'd0;

	// Wait some time before starting first test case
	#(0.1);
	
	// Clear the bus model
	reset_model();

	//*****************************************************************************
	// Power-on-Reset Test Case (0)
	//*****************************************************************************
	// Update Navigation Info
	tb_test_case     = "Power-on-Reset";
	tb_test_case_num = tb_test_case_num + 1;
	
	// Reset the DUT
	reset_input();
	reset_dut();

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Transmission (Endpoint to Host)						//
//																				//
//////////////////////////////////////////////////////////////////////////////////

// DATA Packet
	tb_test_case     = "DATA Packet Transmission";
	tb_test_case_num = tb_test_case_num + 1;
	reset_dut();

	//8 byte packet
	enqueue_transaction(1'b1, 1'b1, 8'h0, '{32'h86422468}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 4);

	enqueue_transaction(1'b1, 1'b1, 8'h0, '{32'h75311357}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 4);

	enqueue_transaction(1'b1, 1'b1, 8'hC, '{32'h00000001}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	#(CLK_PERIOD * 2);

	wait_until_idle(1);
	memory_check();

// ACK Packet
	tb_test_case     = "ACK Packet Transmission";
	tb_test_case_num = tb_test_case_num + 1;
	reset_dut();

	enqueue_transaction(1'b1, 1'b1, 8'hC, '{32'h00000002}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);

	wait_until_idle(1);
	memory_check();

// NAK Packet
	tb_test_case     = "NAK Packet Transmission";
	tb_test_case_num = tb_test_case_num + 1;
	reset_dut();

	enqueue_transaction(1'b1, 1'b1, 8'hC, '{32'h00000003}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	
	wait_until_idle(1);
	memory_check();
	
// STALL Packet
	tb_test_case     = "STALL Packet Transmission";
	tb_test_case_num = tb_test_case_num + 1;
	reset_dut();

	enqueue_transaction(1'b1, 1'b1, 8'hC, '{32'h00000004}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	
	wait_until_idle(1);
	memory_check();

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Reception (Host to Endpoint)							//
//																				//
//////////////////////////////////////////////////////////////////////////////////

// IN Token
	tb_test_case     = "IN Token Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	send_sync();
	send_byte(IN);
	send_byte(8'd0);
	send_byte({3'b000, CRC5});
	//send_token_data(7'd1, 4'd1, 5'd0);
	send_eop();

// OUT Token
	tb_test_case     = "OUT Token Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	send_sync();
	send_byte(OUT);
	send_byte(8'd0);
	send_byte({3'b000, CRC5});
	//send_token_data(7'd1, 4'd1, 5'd0);
	send_eop();

	wait_until_idle(0);

// DATA0 Reception
	tb_test_case     = "DATA0 Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();
	#(CLK_PERIOD * 2);

	tb_expected_packet = DATA0;
	send_sync();
	send_byte(DATA0); //PID
	send_byte(8'h69);
	send_byte(8'h24);
	send_byte(8'h42);
	send_byte(8'h96);
	send_eop();
	
	wait_until_idle(0);
	enqueue_transaction(1'b1, 1'b0, 8'h0, '{32'h69244296}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

// DATA1 Reception
	tb_test_case     = "DATA1 Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	tb_test_data = '{32'h82284224};

	tb_expected_packet = DATA1;
	send_sync();
	send_byte(DATA1); //PID
	send_byte(8'h82);
	send_byte(8'h28);
	//send_byte(8'h42);
	//send_byte(8'h24);
	send_eop();

	wait_until_idle(0);
	enqueue_transaction(1'b1, 1'b0, 8'h0, '{32'h82284224}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

// ACK Reception
	tb_test_case     = "ACK Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	send_sync();
	send_byte(ACK);
	send_eop();

	wait_until_idle(0);
	enqueue_transaction(1'b1, 1'b0, 8'h4, '{32'h8}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

// NAK Reception
	tb_test_case     = "NAK Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	send_sync();
	send_byte(NAK);
	send_eop();

	wait_until_idle(0);

	enqueue_transaction(1'b1, 1'b0, 8'h4, '{32'h16}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

// STALL Reception
	tb_test_case     = "STALL Reception";
	tb_test_case_num = tb_test_case_num + 1;
	reset_input();
	reset_dut();

	send_sync();
	send_byte(STALL);
	send_eop();
	
	wait_until_idle(0);
	#(CLK_PERIOD * 2);

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			End Of Test Cases													//
//																				//
//////////////////////////////////////////////////////////////////////////////////

	tb_test_case     = "End of test cases";
	tb_test_case_num = tb_test_case_num + 1;
end

endmodule
