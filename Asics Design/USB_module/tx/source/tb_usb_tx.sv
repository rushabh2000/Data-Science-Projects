// $Id: $
// File name:   tx_tb.sv
// Created:     4/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: transmitter testbench.
`timescale 1ns / 10ps
module tb_usb_tx();
localparam CLK_PERIOD = 10;
localparam BUS_DELAY  = 800ps;

// Preset Values
localparam [7:0] SYNC_BYTE = 8'b10000000;
localparam [7:0] ACK_BYTE = 8'b00101101;
localparam [7:0] NAK_BYTE = 8'b10100101;//
localparam [2:0] TX_IDLE = 3'd0;
localparam [2:0] TX_SEND_DATA = 3'd1;
localparam [7:0] DATA_BYTE = 8'b00111100;
localparam [2:0] TX_NAK = 3'd3;
localparam [2:0] TX_ACK = 3'd2;
logic     		[63:0][7:0] data_list;
integer		       idx_tx_packet_data = 0;

//*****************************************************************************
// Declare TB Signals (Bus Model Controls)
//*****************************************************************************
// Testing control signal(s)
string      tb_check_tag;
logic       tb_mismatch;
logic       tb_check;
integer     i;
integer     tb_test_case_num;
string      tb_test_case;
//*****************************************************************************
// General System signals
//*****************************************************************************
logic tb_clk;
logic tb_n_rst;
logic tb_usb_clk;
//*****************************************************************************
// USB_tx side Signals
//*****************************************************************************
logic [7:0] tb_tx_packet_data;
logic [2:0] tb_tx_packet;
logic       tb_dplus_out;
logic       tb_dminus_out;
logic       tb_get_tx_packet_data;
logic [6:0] tb_buffer_occupancy;

// Expected value check signals
logic		tb_expected_dplus_out;
logic 		tb_expected_dminus_out;
logic 		tb_expected_get_tx_packet_data;
// Test Values
logic [63:0][7:0] result_list;
logic prev_dplus;

//*****************************************************************************
// DUT
//*****************************************************************************

usb_tx DUT (
	.clk(tb_clk), 
	.n_rst(tb_n_rst), 
	.tx_packet(tb_tx_packet), 
	.tx_packet_data(tb_tx_packet_data), 
	.dplus_out(tb_dplus_out), 
	.dminus_out(tb_dminus_out), 
	.get_tx_packet_data(tb_get_tx_packet_data), 
	.buffer_occupancy(tb_buffer_occupancy)
);

//*****************************************************************************
// Clock Generation Block
//****************************************************************************
always begin
  // Start with clock low to avoid false rising edge events at t=0
  tb_clk = 1'b0;
  // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
  tb_clk = 1'b1;
  // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
end
always begin
  // Start with clock low to avoid false rising edge events at t=0b00101101
  tb_usb_clk = 1'b0;
  // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
  #((CLK_PERIOD * 8) /2.0);
  tb_usb_clk = 1'b1;
  // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
   #((CLK_PERIOD * 8) /2.0);
end

task reset_dut;
begin
  // Activate the reset
  tb_n_rst = 1'b0;

  // Maintain the reset for more than one cyclediuo
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

task check_outputs;
  input string check_tag;
begin
  tb_mismatch = 1'b0;
  if(tb_expected_dplus_out != tb_dplus_out) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'dplus' output %s during %s test case", check_tag, tb_test_case);
  end
  if(tb_expected_dminus_out != tb_dminus_out) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'dminus' output %s during %s test case", check_tag, tb_test_case);
  end
  if(tb_expected_get_tx_packet_data != tb_get_tx_packet_data) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'get_tx_packet_data' output %s during %s test case", check_tag, tb_test_case);
  end
end
endtask

task check_eop;
  logic [2:0] expected_dplus;
  logic [2:0] expected_dminus;
  integer i;
begin
  expected_dplus = 3'b000;
  expected_dminus = 3'b000;
  for(i = 0; i < 3; i++) begin
    tb_expected_dplus_out = expected_dplus[i];
    tb_expected_dminus_out = expected_dminus[i];
    tb_expected_get_tx_packet_data = 0;
    check_outputs("EOP check");
    #((CLK_PERIOD * 8));
  end
end
endtask
task reset_tb;
begin
  reset_dut();
  
  prev_dplus = tb_dplus_out;
  init_expected_outs();

  tb_tx_packet = 0;
  tb_tx_packet_data = 0;
 // idx_TX_Packet_Data = 0;
end
endtask

task test_stream;
  input [7:0] expected_result;
  integer i;
  logic [7:0] expected_result_lsb;
  logic [7:0] expected_dplus;
begin
  for(i = 0; i < 8; i++) begin
    expected_result_lsb[i] = expected_result[i];
  end
  for(i = 0; i < 8; i++) begin
    if(expected_result_lsb[i] == 0) begin
      expected_dplus[i] = !prev_dplus;
      prev_dplus = expected_dplus[i];
    end else if (expected_result_lsb[i] == 1)
      expected_dplus[i] = prev_dplus;
  end
  for(i = 0; i < 8; i++) begin
    tb_expected_dplus_out = expected_dplus[i];
    tb_expected_dminus_out = !expected_dplus[i];
    tb_expected_get_tx_packet_data = 0;
    if(tb_get_tx_packet_data == 1'b1) begin
      tb_expected_get_tx_packet_data = 1'b1;
    end
    check_outputs("during test_stream");
    #((CLK_PERIOD * 8));
  end
end
endtask



task init_expected_outs;
begin
  tb_expected_dplus_out = 1'b1; 
  tb_expected_dminus_out = 1'b0;
  tb_expected_get_tx_packet_data = 1'b0;
  
end
endtask

always_comb begin
  //tb_buffer_occupancy = 7'b1000000 ;
  if (tb_get_tx_packet_data == 1) begin
    tb_tx_packet_data = data_list[idx_tx_packet_data];
    idx_tx_packet_data += 1;
    //tb_buffer_occupancy = tb_buffer_occupancy - idx_tx_packet_data ;
  end
end


initial begin
  // Initialize Test Case Navigation Signals
  //tb_test_case       = "Initilization";
  tb_test_case_num   = -1;
  // Wait some time before starting first test case
  init_expected_outs();
  tb_tx_packet=0;
  #(0.1);

  //*****************************************************************************
  // Power-on-Reset Test Case
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Power-on-Reset";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT
  reset_dut();

  // Check outputs for reset state
  check_outputs("after DUT reset");

  // Give some visual spacing between check and next test case start
  #(CLK_PERIOD * 3 * 8);
  //*****************************************************************************
  // NAK
  //*****************************************************************************
  
  // Update Navigation Info
   tb_test_case     = "Send NAK";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT
  reset_tb();

 @(posedge tb_usb_clk);
  tb_tx_packet = TX_NAK;  //8'b10100101
                                
                                
  #((CLK_PERIOD * 8) + 0.1);
  tb_tx_packet = 0;
  #(CLK_PERIOD);
  test_stream(SYNC_BYTE);
  test_stream(NAK_BYTE);
  check_eop();
 #(CLK_PERIOD * 3 * 8);
//*****************************************************************************
  // ACK
  //*****************************************************************************
  
  // Update Navigation Info
   tb_test_case     = "Send ACK";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT
  reset_tb();

 @(posedge tb_usb_clk);
  tb_tx_packet = TX_ACK;  //8'b10100101
                                
                                
  #((CLK_PERIOD * 8) + 0.1);
  tb_tx_packet = 0;
  #(CLK_PERIOD);
  test_stream(SYNC_BYTE);
  test_stream(ACK_BYTE);
  check_eop();
 #(CLK_PERIOD * 3 * 8);

 
//*****************************************************************************
  // SEND_DATA
  //*****************************************************************************
  
tb_test_case     = "Send DATA";
tb_test_case_num = tb_test_case_num + 1;


reset_tb();
@(negedge tb_usb_clk);
@(negedge tb_usb_clk);

#(CLK_PERIOD * 3 * 8);

result_list[0] = 8'd0;
data_list[0] = 8'd0;

for (i = 1; i < 64; i++)begin
    result_list[i] = result_list[i-1] + 1;
    data_list[i] = data_list[i-1] + 1;
end

tb_tx_packet = 0;
@(posedge tb_usb_clk);

  tb_tx_packet = TX_SEND_DATA;
  #((CLK_PERIOD * 8 )+ 0.1);
  tb_tx_packet = 0;
  #(CLK_PERIOD);
  tb_buffer_occupancy = 64;
  test_stream(SYNC_BYTE);
  test_stream(DATA_BYTE); //00111100
  for(i = 0; i < 64; i++) begin
    tb_buffer_occupancy = tb_buffer_occupancy - 1;
    test_stream(result_list[i]);
    
  end
  #(CLK_PERIOD);
  test_stream(8'd13);
  test_stream(8'd14);
  check_eop();
  #(CLK_PERIOD * 8 * 3);

$stop;
end 
endmodule
