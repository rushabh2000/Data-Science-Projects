// $Id: $
// File name:   tb_ahb_lite_slave_cdl.sv
// Created:     10/1/2018
// Author:      Tim Pritchett
// Lab Section: 9999
// Version:     1.0  Initial Design Entry
// Description: Full ABH-Lite slave/bus model test bench

`timescale 1ns / 10ps

module tb_ahb_lite_slave_cdl();

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

//Receiver
logic [2:0]		tb_rx_packet;			//IN
logic 			tb_rx_data_ready;		//IN
logic 			tb_rx_transfer_active;	//IN
logic 			tb_rx_error;			//IN
logic 			tb_d_mode;

//Data Buffer
logic [6:0] 	tb_buffer_occupancy;	//IN
logic [7:0]		tb_rx_data;				//IN
logic 			tb_get_rx_data;
logic [7:0] 	tb_tx_data;
logic 			tb_store_tx_data;
logic			tb_clear;

//Transmitter
logic [2:0]		tb_tx_packet;
logic 			tb_tx_transfer_active;	//IN
logic			tb_tx_error;			//IN

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
	// Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
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
ahb_lite_slave_cdl TM ( 
	.clk(tb_clk), 
	.n_rst(tb_n_rst),
	// AHB-Lite-Slave Side Bus
	.hsel(tb_hsel),
	.haddr(tb_haddr[3:0]),
	.htrans(tb_htrans[1:0]),
	.hsize(tb_hsize[1:0]),
	//.hburst(tb_hburst),
	.hwrite(tb_hwrite),
	.hwdata(tb_hwdata),
	.hrdata(tb_hrdata),
	.hresp(tb_hresp),
	.hready(tb_hready),

	//Receiver
	.rx_packet(tb_rx_packet),
	.rx_data_ready(tb_rx_data_ready),
	.rx_transfer_active(tb_rx_transfer_active),
	.rx_error(tb_rx_error),
	.d_mode(tb_d_mode),

	//Data Buffer
	.buffer_occupancy(tb_buffer_occupancy),
	.rx_data(tb_rx_data),
	.get_rx_data(tb_get_rx_data),
	.tx_data(tb_tx_data),
	.store_tx_data(tb_store_tx_data),
	.clear(tb_clear),
	
	//Transmitter
	.tx_packet(tb_tx_packet),
	.tx_transfer_active(tb_tx_transfer_active),
	.tx_error(tb_tx_error)
	
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
begin
	// Activate the bus model
	tb_enable_transactions = 1'b1;
	@(posedge tb_clk);
	
	// Process the transactions (all but last one overlap 1 out of 2 cycles
	for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
		@(posedge tb_clk);
	end

	// Run out the last one (currently in data phase)
	@(posedge tb_clk);

	// Turn off the bus model
	@(negedge tb_clk);
	tb_enable_transactions = 1'b0;
end
endtask

task reset_interface_inputs;
begin
	tb_rx_packet = 0;
	tb_rx_data_ready = 0;
	tb_rx_transfer_active = 0;
	tb_rx_error = 0;

	tb_buffer_occupancy = 0;
	tb_rx_data = 0;

	tb_tx_transfer_active = 0;
	tb_tx_error = 0;
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

	//Set interface inputs to zero
	reset_interface_inputs();
	

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
	reset_dut();

	// No actual DUT -> Just a place holder currently
  
/*  //*****************************************************************************
  	// Test Case: Singleton Write
	//*****************************************************************************
	// Update Navigation Info
	tb_test_case     = "Single Word Write";
	tb_test_case_num = tb_test_case_num + 1;

	// Reset the DUT to isolate from prior test case
	reset_dut();

	// Enqueue the needed transactions
	tb_test_data = '{32'd1000}; 
	enqueue_transaction(1'b1, 1'b1, 8'd64, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
  
	// Run the transactions via the model
	execute_transactions(1);


	//*****************************************************************************
	// Test Case: Back-to-Back Write/Read
	//*****************************************************************************
	// Update Navigation Info
	tb_test_case     = "Back to back Write/Read";
	tb_test_case_num = tb_test_case_num + 1;

	// Reset the DUT to isolate from prior test case
	reset_dut();

	// Enqueue the needed transactions
	tb_test_data = '{32'hADAD8000};
	// Enqueue the write
	enqueue_transaction(1'b1, 1'b1, 8'd70, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	// Enqueue the 'check' read
	enqueue_transaction(1'b1, 1'b0, 8'd70, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);

	// Run the transactions via the model
	execute_transactions(2);*/

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: RAW Hazard											//
//																				//
//////////////////////////////////////////////////////////////////////////////////

	//The state machine is going to go wonky on these ones. Just ignore it.
	//The only thing that matters for this test is whether it can read back
	//data written on the cycle immediately beforehand.

	//This isn't super important for this design, because you would never realistically
	//want to write and read to the buffer on consecutive clock cycles. One generally
	//only receives or transfers at a time, not both.

/*  Test Case: 1-byte RAW Hazard  */
	tb_test_case 		= "1-byte RAW hazard";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();
	reset_interface_inputs();

	tb_test_data = '{32'h00000031};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd0); //RAW
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd0); //Not RAW
	execute_transactions(3);

/*  Test Case: 2-byte RAW Hazard  */
	tb_test_case 		= "2-byte RAW hazard";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();
	reset_interface_inputs();

	tb_test_data = '{32'h00007531};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd1); //RAW
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd1); //Not RAW
	execute_transactions(3);

/*  Test Case: 4-byte RAW Hazard  */
	tb_test_case 		= "4-byte RAW hazard";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();
	reset_interface_inputs();

	tb_test_data = '{32'hFDB97531};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd2); //RAW
	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd2); //Not RAW
	execute_transactions(3);

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Store to Buffer	 									//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: 1-byte buffer write  */
	tb_test_case 		= "1-byte buffer write";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_dut();

	tb_test_data = '{32'h00000031};
	enqueue_transaction(1'b1, 1'b1, 8'h03, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);

	execute_transactions(1);
	#(CLK_PERIOD * 5);

/*  Test Case: 2-byte buffer write  */
	tb_test_case 		= "2-byte buffer write";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_dut();
	
	tb_test_data = '{32'h00007531};
	enqueue_transaction(1'b1, 1'b1, 8'h02, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);

	execute_transactions(1);
	#(CLK_PERIOD * 5);
	
/*  Test Case: 4-byte buffer write  */
	tb_test_case 		= "4-byte buffer write";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();

	tb_test_data = '{32'hFDB97531};
	enqueue_transaction(1'b1, 1'b1, 8'h01, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);

	execute_transactions(1);
	#(CLK_PERIOD * 5); //Wait to finish the loading sequence

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Load from Buffer										//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: 1-byte buffer read  */
	tb_test_case 		= "1-byte buffer read";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();

	tb_test_data = '{32'h00000031};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h01, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);
	#(CLK_PERIOD * 5); //Wait to finish the loading sequence

/*  Test Case: 2-byte buffer read  */
	tb_test_case 		= "2-byte buffer read";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();

	tb_test_data = '{32'h00007531};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h01, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
	execute_transactions(1);
	#(CLK_PERIOD * 5); //Wait to finish the loading sequence

/*  Test Case: 4-byte buffer read  */
	tb_test_case 		= "4-byte buffer read";
	tb_test_case_num	= tb_test_case_num + 1;
	reset_dut();

	tb_test_data = '{32'hFDB97531};
	tb_rx_data = 8'h55;

	enqueue_transaction(1'b1, 1'b1, 8'h01, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5);

	enqueue_transaction(1'b1, 1'b0, 8'h00, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);
	#(CLK_PERIOD * 5); //Wait to finish the loading sequence

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: TX Packet Control Register							//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: TPCR operation  */
	tb_test_case 		= "TPCR operation";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'h00000001};
	
	enqueue_transaction(1'b1, 1'b1, 8'h0C, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //set register value

	tb_tx_transfer_active = 1'b1;

	#(CLK_PERIOD * 2);
	enqueue_transaction(1'b1, 1'b0, 8'h0C, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //read while transaction still marked active (reg not reset yet)

	tb_tx_transfer_active = 1'b0;

	#(CLK_PERIOD * 2);
	enqueue_transaction(1'b1, 1'b0, 8'h0C, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //Transaction marked complete, should be cleared now.

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Flush Buffer Control Register						//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: FBCR operation  */
	tb_test_case 		= "FBCR operation";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'h1};
	tb_buffer_occupancy = 7'h5;
	
	enqueue_transaction(1'b1, 1'b1, 8'h0D, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //Set value

	#(CLK_PERIOD * 2);
	enqueue_transaction(1'b1, 1'b0, 8'h0D, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //Not cleared yet
	
	tb_buffer_occupancy = 7'h0;

	#(CLK_PERIOD * 2);
	enqueue_transaction(1'b1, 1'b0, 8'h0D, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1); //Cleared

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Standard Read from Read-Only Memory					//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: Standard 1-byte memory read  */
	tb_test_case 		= "1-byte memory read";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(1);

/*  Test Case: Standard 2-byte memory read  */
	tb_test_case 		= "2-byte memory read";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd1);
	execute_transactions(1);

/*  Test Case: Standard 4-byte memory read  */
	tb_test_case 		= "4-byte memory read";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(1);

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Single Reads with Overlap							//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: Overlapping 1-byte memory reads  */
	tb_test_case 		= "Overlapping 1-byte reads";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0);
	enqueue_transaction(1'b1, 1'b0, 8'h4, '{32'h0}, BURST_SINGLE, 1'b0, 2'd0);
	execute_transactions(2);

/*  Test Case: Overlapping 2-byte memory reads  */
	tb_test_case 		= "Overlapping 2-byte reads";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd1);
	enqueue_transaction(1'b1, 1'b0, 8'h4, '{32'h0}, BURST_SINGLE, 1'b0, 2'd1);
	execute_transactions(2);

/*  Test Case: Overlapping 4-byte memory reads  */
	tb_test_case 		= "Overlapping 4-byte reads";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h5, '{32'h0}, BURST_SINGLE, 1'b0, 2'd2);
	enqueue_transaction(1'b1, 1'b0, 8'h4, '{32'h0}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(2);

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Single Writes with Overlap							//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*	These tests won't produce valid behavior with the buffer, but they also
 *	shouldn't cause an error. We're just making sure that it can properly
 *	update the memory.
 */

/*  Test Case: Overlapping 1-byte memory writes  */
	tb_test_case 		= "Overlapping 1-byte writes";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	//tb_test_data = '{32'h000000F0};

	enqueue_transaction(1'b1, 1'b1, 8'h0, '{32'h000000F0}, BURST_SINGLE, 1'b0, 2'd1);
	enqueue_transaction(1'b1, 1'b1, 8'h1, '{32'h0000003C}, BURST_SINGLE, 1'b0, 2'd1);
	execute_transactions(2);

/*  Test Case: Overlapping 2-byte memory writes  */
	tb_test_case 		= "Overlapping 2-byte writes";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'h0000F0F0};

	enqueue_transaction(1'b1, 1'b1, 8'h0, '{32'h0000F0F0}, BURST_SINGLE, 1'b0, 2'd1);
	enqueue_transaction(1'b1, 1'b1, 8'h1, '{32'h00003C3C}, BURST_SINGLE, 1'b0, 2'd1);
	execute_transactions(2);

/*  Test Case: Overlapping 4-byte memory writes  */
	tb_test_case 		= "Overlapping 4-byte writes";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'hF0F0F0F0};

	enqueue_transaction(1'b1, 1'b1, 8'h0, '{32'hF0F0F0F0}, BURST_SINGLE, 1'b0, 2'd2);
	enqueue_transaction(1'b1, 1'b1, 8'h1, '{32'h3C3C3C3C}, BURST_SINGLE, 1'b0, 2'd2);
	execute_transactions(2);

	//This test is a little weird, since all writes to 0x0 through 0x3 are written starting
	//at 0x0. So, it's really just consecutive writes to the SAME address.

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Invalid Address Error								//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: 1-byte read from invalid address  */
	tb_test_case 		= "1-byte read from invalid address";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h9, '{32'h0}, BURST_SINGLE, 1'b1, 2'd0);
	execute_transactions(1);

/*  Test Case: 2-byte read from invalid address  */
	tb_test_case 		= "2-byte read from invalid address";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h9, '{32'h0}, BURST_SINGLE, 1'b1, 2'd1);
	execute_transactions(1);

/*  Test Case: 4-byte read from invalid address  */
	tb_test_case 		= "4-byte read from invalid address";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	enqueue_transaction(1'b1, 1'b0, 8'h9, '{32'h0}, BURST_SINGLE, 1'b1, 2'd2);
	execute_transactions(1);

//////////////////////////////////////////////////////////////////////////////////
//																				//
//			Test Category: Invalid Write Error									//
//																				//
//////////////////////////////////////////////////////////////////////////////////

/*  Test Case: 1-byte invalid write  */
	tb_test_case 		= "1-byte write to read-only memory";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'hC3C3C3C3};

	enqueue_transaction(1'b1, 1'b1, 8'h4, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
	execute_transactions(1);

/*  Test Case: 2-byte invalid write  */
	tb_test_case 		= "2-byte write to read-only memory";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'hC3C3C3C3};

	enqueue_transaction(1'b1, 1'b1, 8'h4, tb_test_data, BURST_SINGLE, 1'b1, 2'd1);
	execute_transactions(1);

/*  Test Case: 4-byte invalid write  */
	tb_test_case 		= "4-byte write to read-only memory";
	tb_test_case_num 	= tb_test_case_num + 1;
	reset_interface_inputs();
	reset_dut();

	tb_test_data = '{32'hC3C3C3C3};

	enqueue_transaction(1'b1, 1'b1, 8'h4, tb_test_data, BURST_SINGLE, 1'b1, 2'd2);
	execute_transactions(1);

/*
  //*****************************************************************************
  // Test Case: INCR4 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "INCR4 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[4];
  for(tb_i = 0; tb_i < 4; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd64, tb_test_data, BURST_INCR4, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd64, tb_test_data, BURST_INCR4, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(8);
  
  //*****************************************************************************
  // Test Case: INCR8 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "INCR8 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[8];
  for(tb_i = 0; tb_i < 8; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd64, tb_test_data, BURST_INCR8, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd64, tb_test_data, BURST_INCR8, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(16);

  //*****************************************************************************
  // Test Case: INCR16 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "INCR16 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[16];
  for(tb_i = 0; tb_i < 16; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd64, tb_test_data, BURST_INCR16, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd64, tb_test_data, BURST_INCR16, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(32);

  //*****************************************************************************
  // Test Case: WRAP4 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "WRAP4 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[4];
  for(tb_i = 0; tb_i < 4; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd68, tb_test_data, BURST_WRAP4, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd68, tb_test_data, BURST_WRAP4, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(8);
  
  //*****************************************************************************
  // Test Case: WRAP8 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "WRAP8 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[8];
  for(tb_i = 0; tb_i < 8; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd68, tb_test_data, BURST_WRAP8, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd68, tb_test_data, BURST_WRAP8, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(16);
  
  //*****************************************************************************
  // Test Case: WRAP16 Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "WRAP16 Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[16];
  for(tb_i = 0; tb_i < 16; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd68, tb_test_data, BURST_WRAP16, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd68, tb_test_data, BURST_WRAP16, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(32);


  //*****************************************************************************
  // Test Case: INCR Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "INCR Bursts";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[7];
  for(tb_i = 0; tb_i < 7; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd64, tb_test_data, BURST_INCR, 1'b0, 2'd2);
  // Enqueue the 'check' read
  enqueue_transaction(1'b1, 1'b0, 8'd64, tb_test_data, BURST_INCR, 1'b0, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(14);
  
  
  //*****************************************************************************
  // Test Case: Erroneous Singleton Write
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Erroneous Single Word Write";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  tb_test_data = '{32'd1000}; 
  enqueue_transaction(1'b1, 1'b1, 8'd32, tb_test_data, BURST_SINGLE, 1'b1, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(1);


//*****************************************************************************
  // Test Case: Erroneous Singleton Read
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Erroneous Single Word Read";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  tb_test_data = '{32'd1000}; 
  enqueue_transaction(1'b1, 1'b0, 8'd128, tb_test_data, BURST_SINGLE, 1'b1, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(1);


  //*****************************************************************************
  // Test Case: Erroneous INCR4 Write Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Erroneous INCR4 Write Burst";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[4];
  for(tb_i = 0; tb_i < 4; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b1, 8'd32, tb_test_data, BURST_INCR4, 1'b1, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(8);
  
  //*****************************************************************************
  // Test Case: Erroneous INCR4 Read Burst
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Erroneous INCR4 Read Burst";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior test case
  reset_dut();

  // Enqueue the needed transactions
  // Create the Test Data for the burst
  tb_test_data = new[4];
  for(tb_i = 0; tb_i < 4; tb_i++)begin
    tb_test_data[tb_i] = {16'hABCD,tb_i[15:0]};
  end
  // Enqueue the write
  enqueue_transaction(1'b1, 1'b0, 8'd128, tb_test_data, BURST_INCR4, 1'b1, 2'd2);
  
  // Run the transactions via the model
  execute_transactions(8);
*/
//////////////////////////////////////////////////////////////////////////////////
//																				//
//			End Of Test Cases													//
//																				//
//////////////////////////////////////////////////////////////////////////////////

	tb_test_case     = "End of test cases";
	tb_test_case_num = tb_test_case_num + 1;


end

endmodule
