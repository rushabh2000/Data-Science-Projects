// $Id: $
// File name:   tb_usb_rx.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: test bench for top level usb reciever
`timescale 1ns / 10ps

module tb_usb_rx();

  // Define parameters
  parameter CLK_PERIOD  = 2.5;


//PID
localparam IN_PID = 3'b101;
localparam OUT_PID = 3'b110; 
localparam DATA_PID = 3'b1101;
localparam ACK_PID = 3'b010;
localparam NACK_PID = 3'b011;

localparam CRC5 = 5'b10011;

localparam OUT = 8'b10000111;
localparam IN = 8'b10010110; 
localparam DATA0 = 8'b11000011;
localparam DATA1 = 8'b11010010;
localparam ACK = 8'b01001011;
localparam NACK = 8'b01011010;


  
  //  DUT inputs
  reg tb_clk;
  reg tb_n_rst;
	logic tb_d_plus;
	logic tb_d_minus;
	logic[6:0] tb_buffer_occupancy;

  
  // DUT outputs
 	logic [2:0] tb_rx_packet;
	logic tb_data_ready;
	logic tb_error;
	logic tb_transfer_active;
	logic tb_flush;
	logic tb_store_rx_packet_data;
	logic [7:0] tb_packet_data;
  
  // Test bench debug signals
  // Overall test case number for reference
  integer tb_test_num;
  string  tb_test_case;
	logic tb_check;
  // Test case 'inputs' used for test stimulus
		reg [7:0] tb_test_data;
		logic tb_test_eop;
		byte tb_test_data_packet;
		integer ones_cnt;

		int tb_packet_num;

  // Test case expected output values for the test case
		logic [7:0] tb_expected_packet_data;
  	logic [3:0] tb_expected_packet;
		logic tb_expected_error;
		logic tb_expected_data_ready;
		logic tb_expected_transfer_active;
		logic tb_expected_flush;
		logic tb_expected_store_rx_packet_data;
		
		
  // DUT portmap
  usb_rx DUT (.clk(tb_clk), .n_rst(tb_n_rst), 
						  .d_plus(tb_d_plus), .d_minus(tb_d_minus), 
							.buffer_ocup(tb_buffer_occupancy),
							.rx_packet(tb_rx_packet), 
							.rx_data_ready(tb_data_ready),
							.rx_error(tb_error), 
							.rx_transfer_active(tb_transfer_active),
							.flush(tb_flush), 
							.store_rx_packet_data(tb_store_rx_packet_data),
							.rx_packet_data(tb_packet_data) );

//////TASKS/////////////
  
  task reset_dut;
  begin
    // Activate the design's reset (does not need to be synchronize with clock)
    tb_n_rst = 1'b0;
    
    // Wait for a couple clock cycles
    @(posedge tb_clk);
    @(posedge tb_clk);
    
    // Release the reset
    @(negedge tb_clk);
    tb_n_rst = 1;
    
    // Wait for a while before activating the design
    @(posedge tb_clk);
    @(posedge tb_clk);
  end
  endtask
  
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


    if(1'b0 == tb_expected_error)
    begin
      assert(1'b0 == tb_error)
        $info("Test case %0d: DUT correctly shows no error", tb_test_num);
      else
        $error("Test case %0d: DUT incorrectly shows an error", tb_test_num);
    end
    else
    begin
      assert(1'b1 == tb_error)
        $info("Test case %0d: DUT correctly shows an error", tb_test_num);
      else
        $error("Test case %0d: DUT incorrectly shows no error", tb_test_num);
    end
    
    
  end
  endtask

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

task send_pid;
	input[7:0] data;
	integer i;
	begin
		for(i=0; i<8; i++) begin
			send_bit(data[i]);
		end
	end
endtask

task send_bit;
	input data;
	begin
		tb_d_plus = data;
		tb_d_minus = ~data;
		#(CLK_PERIOD * 8);
	end
endtask

task send_sync;
	logic [7:0] data;
	tb_d_plus = 1'b1;
	tb_d_minus = 1'b0;
	@(negedge tb_clk);
	@(negedge tb_clk);
	@(negedge tb_clk);
	begin
		data = 8'b01010100;
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
		prev = tb_d_plus;
		for(i=0; i<8; i++) begin
			prev = tb_d_plus;
			if(ones_cnt == 6) begin
				send_bit(~prev);
				ones_cnt = 0;
				i -= 1;
			end else if(tb_test_data_packet[i] == 1'b1) begin
					send_bit(prev);
					ones_cnt += 1;

			end
		end

	check_packet(data == tb_packet_data, "tb_packet_data");
	end
endtask

task send_eop;
	integer i;
	begin
		for(i=0; i<2; i++) begin
			tb_d_plus = 1'b0;
			tb_d_minus = 1'b0;
			#(CLK_PERIOD *8);
		end
		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;
		#(CLK_PERIOD *8);
	end
endtask

task send_bad_eop;
	integer i;
	begin
			tb_d_plus = 1'b0;
			tb_d_minus = 1'b0;
			#(CLK_PERIOD *8);
			tb_d_plus = 1'b1;
			tb_d_minus = 1'b0;
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
		
			end else if(curr == 1'b1) begin
					send_bit(prev);
					ones_cnt += 1;

			end else begin
				send_bit(~prev);
				ones_cnt = 0;
				end
		end

	check_packet(data == tb_packet_data, "tb_packet_data");
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

	if(conditional) begin
		tb_check =1;
		$display("%s %d CORRECT: %s test case", var_name, conditional, var_name);
	end else begin
					$error("%s %d INCORRECT: %s test case", var_name, conditional, var_name);
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
		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;
	end
endtask

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

  
  always
  begin : CLK_GEN
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk = 1'b1;
    #(CLK_PERIOD / 2);
  end

  // Actual test bench process
  initial
  begin : TEST_PROC
    // Initialize all test bench signals
    tb_test_num               = -1;
    tb_test_case              = "TB Init";
    tb_test_data              = '1;
    tb_test_eop         			= 1'b1;
  

	 	tb_expected_packet_data = '1;
  	tb_expected_packet = '1;
		tb_expected_error = 1'b0;
		tb_expected_data_ready = 1'b0;
		tb_expected_transfer_active = 1'b0;
		tb_expected_flush = 1'b0;
		tb_expected_store_rx_packet_data = 1'b0;
   

    // Initilize all inputs to inactive/idle values
    tb_n_rst      = 1'b1; // Initially inactive
    tb_d_plus = 1'b1; // Initially idle
    tb_d_minus  = 1'b0; // Initially inactive
    
    // Get away from Time = 0
    #0.1; 
    
    // Test case 0: Basic Power on Reset
    tb_test_num  = 0;
    tb_test_case = "Power-on-Reset";
    
    
    // Power-on Reset Test case: Simply populate the expected outputs
    // These values don't matter since it's a reset test but really should be set to 'idle'/inactive values
    tb_test_data        = '1;
    tb_test_eop			    = 1'b0;
 
    
   
    tb_expected_packet   = '0;
    tb_expected_flush = 1'b0;
    tb_expected_data_ready    = 1'b0;	
    tb_expected_error = 1'b0;  
    tb_expected_packet_data = '0;
		tb_expected_transfer_active = 1'b1;
    tb_expected_store_rx_packet_data = 1'b0;
    
    // DUT Reset
    reset_dut;
    
    // Check outputs
    //check_outputs();
    
 ////////////////////////////////////////////////////////    
 reset_dut;
		tb_check = 1;
		tb_test_num  += 1;
    tb_test_case = "OUT";
    
    tb_expected_data_ready = 1'b1;  
    tb_expected_error = 1'b0;
		tb_expected_flush = 1'b0;
		tb_expected_transfer_active = 1'b1;
    tb_expected_store_rx_packet_data = 1'b1;
    
		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;

		  send_sync();
			send_byte_NRZ(OUT);
			send_token_data(7'd1, 4'd1, 5'd0);
			send_eop();
    
    // Check outputs
   // check_outputs();
 ////////////////////////////////////////////////////////    
/*
		tb_test_num  += 1;
    tb_test_case = "token stream";

	reset_dut();
	tb_check = 1;
		
	tb_d_plus = 1'b1;
	tb_d_minus = 1'b0;

	tb_expected_packet = 3'b101;
	tb_expected_store_rx_packet_data = 1'b0;

	reset_dut();
	send_sync();
	
	send_byte_NRZ(8'b00010100);
	send_random_data_stream(64);

	reset_dut();
	send_sync();
	send_pid(8'b00100111);
	send_token_data(7'b1010101, 4'b0101, 5'b01010);
	send_eop();

	
		*/
       
	////////////////////////////////////////////////////////    

		tb_test_num  += 1;
    tb_test_case = "DATA0 packet";

		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;
		tb_expected_packet = DATA0;

	reset_dut();
	send_sync();
	send_pid(DATA_PID);
	send_byte(DATA0);
	send_eop();
       
//////////////////////////////////////////

tb_test_num  += 1;
    tb_test_case = "ACK token";

		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;
		tb_expected_packet = ACK;

	reset_dut();
	send_sync();
	send_pid(8'b01101100);
	send_eop();
       
	#(CLK_PERIOD *128);


////////////////////////////////////////
tb_test_num  += 1;
    tb_test_case = "NACK token";

		tb_d_plus = 1'b1;
		tb_d_minus = 1'b0;
		tb_expected_packet = NACK;

	reset_dut();
	send_sync();
	send_pid(8'b01100011);
	send_eop();
       





////////////////////////////////////////////		      	      
		
  
  end

endmodule



