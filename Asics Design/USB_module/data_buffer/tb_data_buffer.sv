// $Id: $
// File name:   tb_data_buffer.sv
// Created:     4/21/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: tb_data_buffer.
`timescale 1ns / 100ps
module tb_data_buffer();

	localparam CLK_PERIOD= 10;
	reg tb_clk;

	
	//CLOCK DIVIDER
	always
	begin
		tb_clk=1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk=1'b1;
		#(CLK_PERIOD/2.0);
	end

  integer tb_test_case_num;
	//Test Bench Signals
	reg tb_n_rst,tb_store_rx_data,tb_get_tx_data,tb_get_rx_data, tb_store_tx_data;
    reg [7:0] tb_rx_packet_data;
    reg [7:0] tb_tx_data;
    reg [6:0] tb_buffer_occupancy;
    reg [7:0] tb_tx_packet_data;
    reg [7:0] tb_rx_data;
    reg tb_clear;
    reg tb_flush;

    //integer testnum;
    integer tb_mismatch;
    string tb_test_case ;


    reg [6:0] tb_expected_buffer_occupancy;
    reg [7:0] tb_expected_tx_packet_data;
    reg [7:0] tb_expected_rx_data;
	//DUT PORT MAP

	data_buffer DUT(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.clear(tb_clear), 
		.buffer_occupancy(tb_buffer_occupancy),
		.store_rx_data(tb_store_rx_data), 
		.flush(tb_flush),
		.rx_packet_data(tb_rx_packet_data),
		.store_tx_data(tb_store_tx_data),
		.tx_data(tb_tx_data),
		.get_tx_data(tb_get_tx_data),
		.get_rx_data(tb_get_rx_data),
		.tx_packet_data(tb_tx_packet_data),
		.rx_data(tb_rx_data)
	);

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
  if(tb_expected_buffer_occupancy != tb_buffer_occupancy) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'buffer occupancy' output %s during %s test case", check_tag, tb_test_case) ;
  end
  if(tb_expected_rx_data != tb_rx_data) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'rx data' output %s during %s test case", check_tag, tb_test_case );
  end
  if(tb_expected_tx_packet_data != tb_tx_packet_data) begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'tx_packet_data' output %s during %s test case", check_tag, tb_test_case);
  end
end
endtask

task init_expected_outs;
begin
tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = '0;
  
end
endtask


initial 
begin
  tb_test_case_num   = -1;
  // Wait some time before starting first test case
  init_expected_outs();
  
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
  // small fill from RX to buffer
//*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "small fill from RX to buffer";
reset_dut();

tb_store_rx_data = 1'b1;
tb_rx_packet_data = 8'b11111111;

@(posedge tb_clk);
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = '0;
tb_expected_rx_data = '0;
check_outputs("during test_stream");

tb_store_rx_data = 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);

//*****************************************************************************
  // Largefill from RX to buffer
//*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "small fill from RX to buffer";
reset_dut();

tb_store_rx_data = 1'b1;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd1;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd2;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = '0;
tb_expected_rx_data = '0;
check_outputs("during test_stream");

tb_store_rx_data = 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);

//*****************************************************************************
// Max fill from RX (multiple packets)
//*****************************************************************************
tb_test_case_num += 1;
tb_test_case = "Max fill from RX (multiple packets)";
reset_dut();

tb_store_rx_data = 1'b1;

@(posedge tb_clk);
tb_rx_packet_data  = 8'd1;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd2;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd3;
@(posedge tb_clk);
tb_rx_packet_data = 8'd4;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

tb_store_rx_data= 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);




//*****************************************************************************
  // small fill from RX to ahb
  //*****************************************************************************
tb_test_case_num += 1;
tb_test_case = "small fill from RX";
reset_dut();



@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd1;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_store_rx_data= 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 8'd0;
tb_expected_rx_data = 8'd1;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b0;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

//*****************************************************************************
  // Large fill from RX to ahb
//*****************************************************************************
tb_test_case_num += 1;
tb_test_case = "Large fill from RX";
reset_dut();


@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd1;
@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd2;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_store_rx_data= 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);
tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 8'd0;
tb_expected_rx_data = 8'd1;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 8'd2;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b0;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");



//*****************************************************************************
  // Max fill from RX to ahb
  //*****************************************************************************
tb_test_case_num += 1;
tb_test_case = "Max fill from RX";
reset_dut();

@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd1;
@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd2;
@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data  = 8'd3;
@(posedge tb_clk);
tb_store_rx_data = 1'b1;
tb_rx_packet_data = 8'd4;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 3;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_store_rx_data= 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);
tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 8'd0;
tb_expected_rx_data = 8'd1;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 3;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 8'd2;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 8'd3;
check_outputs("during test_stream");
@(posedge tb_clk);
tb_get_rx_data = 1'b1;
#(CLK_PERIOD/2.0);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 8'd4;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_rx_data = 1'b0;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");



//*****************************************************************************
  // Small fill from AHB-Lite (visual check)
  //*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "Small fill from AHB-Lite (visual check)";
reset_dut();

tb_store_tx_data = 1'b1;
tb_tx_data = 8'b11111111;

@(posedge tb_clk);
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = '0;
tb_expected_rx_data = '0;
check_outputs("during test_stream");

tb_store_tx_data = 1'b0;
tb_tx_data =0;
#(CLK_PERIOD * 3.0);

//*****************************************************************************
  // Large fill from AHB-Lite (visual check)
  //*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "Large fill from AHB-Lite (visual check)";
reset_dut();

tb_store_tx_data = 1'b1;

@(posedge tb_clk);
tb_tx_data = 8'd1;
@(posedge tb_clk);
tb_tx_data = 8'd2;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

tb_store_tx_data = 1'b0;
tb_tx_data = 0;

#(CLK_PERIOD * 3.0);

//*****************************************************************************
  // Max fill from AHB-Lite (visual check)
  //*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "Max fill from AHB-Lite (visual check)";
reset_dut();

tb_store_tx_data = 1'b1;

@(posedge tb_clk);
tb_tx_data = 8'd1;
@(posedge tb_clk);
tb_tx_data = 8'd2;
@(posedge tb_clk);
tb_tx_data = 8'd3;
@(posedge tb_clk);
tb_tx_data = 8'd4;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

tb_store_tx_data = 1'b0;
tb_tx_data = 0;

#(CLK_PERIOD * 3.0);





//*****************************************************************************
  //Small drain to TX
//*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "Small drain to TX";
reset_dut();

tb_store_tx_data = 1'b1;
tb_tx_data = 8'b11111111;

@(posedge tb_clk);
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = '0;
check_outputs("during test_stream");

tb_store_tx_data = 1'b0;
tb_tx_data = 8'd0;
@(posedge tb_clk);
tb_get_tx_data = 1'b1;

#(CLK_PERIOD + 0.2);
tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 8'b11111111;
tb_expected_rx_data = '0;
check_outputs("during test_stream");

tb_get_tx_data = 1'b0;



#(CLK_PERIOD * 3.0);

//*****************************************************************************
// Large drain to TX 
//*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "Large drain to TX ";
reset_dut();



@(posedge tb_clk);
tb_store_tx_data = 1'b1;
tb_tx_data  = 8'd1;
@(posedge tb_clk);

tb_tx_data  = 8'd2;

#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_store_tx_data= 1'b0;
tb_tx_data= 8'd0;
#(CLK_PERIOD * 3.0);
tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");


@(posedge tb_clk);
tb_get_tx_data  = 1'b1;
#(CLK_PERIOD + 0.2);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 8'd1;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");


@(posedge tb_clk);
tb_get_tx_data  = 1'b1;
#(0.2 );
tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 8'd2;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");
tb_get_tx_data  = 1'b0;

#(CLK_PERIOD * 3.0);





//*****************************************************************************
// Max drain to TX 
//*****************************************************************************
tb_test_case_num +=1;
tb_test_case = "write test via tx_data from ahb(multiple fills)";
reset_dut();



@(posedge tb_clk);
tb_store_tx_data = 1'b1;
tb_tx_data  = 8'd1;
@(posedge tb_clk);

tb_tx_data  = 8'd2;
@(posedge tb_clk);

tb_tx_data = 8'd3;
@(posedge tb_clk);
tb_tx_data = 8'd4;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 3;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_store_tx_data= 1'b0;
tb_tx_data= 8'd0;
#(CLK_PERIOD * 3.0);
tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_tx_data = 1'b1;
#(CLK_PERIOD + 0.2);
tb_expected_buffer_occupancy = 3;
tb_expected_tx_packet_data = 8'd1;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_tx_data  = 1'b1;
#(0.2);
tb_expected_buffer_occupancy = 2;
tb_expected_tx_packet_data = 8'd2;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");

@(posedge tb_clk);
tb_get_tx_data  = 1'b1;
#( 0.2);
tb_expected_buffer_occupancy = 1;
tb_expected_tx_packet_data = 8'd3;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");
@(posedge tb_clk);
tb_get_tx_data  = 1'b1;
#(0.2 );
tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 8'd4;
tb_expected_rx_data = 8'd0;
check_outputs("during test_stream");
tb_get_tx_data  = 1'b0;

#(CLK_PERIOD * 3.0);


//*****************************************************************************
  // flush // clear
  //*****************************************************************************
tb_test_case_num += 1;
tb_test_case = "flush test";
reset_dut();

tb_store_rx_data = 1'b1;

@(posedge tb_clk);
tb_rx_packet_data  = 8'd1;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd2;
@(posedge tb_clk);
tb_rx_packet_data  = 8'd3;
@(posedge tb_clk);
tb_rx_packet_data = 8'd4;
#(CLK_PERIOD/2.0);

tb_expected_buffer_occupancy = 4;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

tb_store_rx_data= 1'b0;
tb_rx_packet_data = 8'd0;
#(CLK_PERIOD * 3.0);

@(posedge tb_clk)
tb_flush = 1'b1;

@(posedge tb_clk)
#(0.3);
tb_expected_buffer_occupancy = 0;
tb_expected_tx_packet_data = 0;
tb_expected_rx_data = 0;
check_outputs("during test_stream");

$stop;
end
endmodule
