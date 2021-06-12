// $Id: $
// File name:   tb_flex_counter.sv
// Created:     2/16/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: test bench for flexiable counter
`timescale  1ns/ 10ps

module tb_flex_counter();

// Define local parameters used by the test bench
	localparam NUM_CNT_BITS = 4;

	localparam  CLK_PERIOD    = 2.5;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts

	localparam  INACTIVE_VALUE     = 1'b0;
  localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;

 // Declare DUT portmap signals

reg tb_clk;
reg tb_n_rst;
reg tb_clear;
reg tb_count_enable;
reg [(NUM_CNT_BITS -1):0] tb_rollover_val;
reg [(NUM_CNT_BITS -1):0] tb_count_out;
reg tb_rollover_flag;

// Declare test bench signals
integer tb_test_num;
string tb_test_case;
//integer tb_expected_count; ??

//tasks
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

task check_out;
	input logic expected_val;
	input string check_tag;
begin
	if(expected_val == tb_count_out)
		$info("Correct count output %s during %s test case.", check_tag,tb_test_case);
	else
		$error("Incorrect count output %s during %s test case.", check_tag, tb_test_case);
	

end
endtask

task check_rollover;
input logic expected_val;
input string check_tag;

begin
	if(expected_val == tb_rollover_flag)
		$info("Correct rollover flag output %s during %s test case.", check_tag,tb_test_case);
	else
		$error("Incorrect rollover flag output %s during %s test case.", check_tag, tb_test_case);

end
endtask


task clear;
begin
	tb_clear = 1'b1;

	@(posedge tb_clk);

	@(negedge tb_clk);
	tb_clear = 1'b0;

@(negedge tb_clk);
@(negedge tb_clk);

end
endtask

// Clock generation block

always
  begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end


//test cases

// DUT Port map
flex_counter DUT (.clk(tb_clk), .n_rst(tb_n_rst), .clear(tb_clear), .count_enable(tb_count_enable), 
         .rollover_val(tb_rollover_val), .count_out(tb_count_out), .rollover_flag(tb_rollover_flag));
  
  // Test bench main process
  initial
  begin
	tb_rollover_val = 8'd8;
	tb_clear = 1'b0;
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_test_num = 0;               // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    // Wait some time before starting first test case
    #(0.1);
		//************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_count_enable  = INACTIVE_VALUE; // Set to be the the non-reset value
    tb_n_rst  = 1'b0;    // Activate reset
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_out( RESET_OUTPUT_VALUE, 
                  "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_out( RESET_OUTPUT_VALUE, 
                  "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_out( RESET_OUTPUT_VALUE, 
                  "after reset was released");

//test case 2: continuous counting
	@(negedge tb_clk);
		tb_test_num = tb_test_num + 1;
    tb_test_case = "Continuous Counting";
	
		tb_count_enable = INACTIVE_VALUE;
		tb_rollover_flag = INACTIVE_VALUE;
		reset_dut();

		tb_count_enable = 1'b1;
		@(posedge tb_clk);
		
		#(CHECK_DELAY);
		check_out(4'b1, "after one clock cycle" );
		check_rollover(1'b0, "after one clock cycle" ); 
		
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 2 clock cycle" );
		check_rollover(1'b0, "after 2 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0011, "after 3 clock cycle" );
		check_rollover(1'b0, "after 3 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0100, "after 4 clock cycle" );
		check_rollover(1'b0, "after 4 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0101, "after 5 clock cycle" );
		check_rollover(1'b0, "after 5 clock cycle" );

@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0110, "after 6 clock cycle" );
		check_rollover(1'b0, "after 6 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0111, "after 7 clock cycle" );
		check_rollover(1'b0, "after 7 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b1000, "after 8 clock cycle" );
		check_rollover(1'b1, "after 8 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b1, "after 9 clock cycle" );
		check_rollover(1'b0, "after 9 clock cycle" );

		//go through clk cycles until 1 before rollover and then check again after rollover value hit 

		//cycle once more to check count and that flag turned off


//test case 3: Discontinuous counting c_e set to zero
@(negedge tb_clk);
		tb_test_num = tb_test_num + 1;
    tb_test_case = "Discontinuous Counting";
	
		tb_count_enable = INACTIVE_VALUE;
		reset_dut();
		
		tb_count_enable = 1'b1;
		
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b1, "after one clock cycle" );
		check_rollover(1'b0, "after one clock cycle" ); 

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 2 clock cycle" );
		check_rollover(1'b0, "after 2 clock cycle" );
		tb_count_enable = 1'b0;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 3 clock cycle and count_enable is off" );
		check_rollover(1'b0, "after 3 clock cycle and count_enable is off" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 4 clock cycle and count_enable is off" );
		check_rollover(1'b0, "after 4 clock cycle and count_enable is off" );
		tb_count_enable = 1'b1;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0011, "after 5 clock cycle and count_enable on" );
		check_rollover(1'b0, "after 5 clock cycle and count_enable on" );

		@(posedge tb_clk)
		#(CHECK_DELAY);
		check_out(4'b0100, "after 6 clock cycle and count_enable on" );
		check_rollover(1'b0, "after 6 clock cycle and count_enable on" );
		tb_count_enable = 1'b0;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0100, "after 7 clock cycle and count_enable off" );
		check_rollover(1'b1, "after 7 clock cycle and count_enable off" );
		tb_count_enable = 1'b0;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0101, "after 8 clock cycle and count_enable on" );
		check_rollover(1'b0, "after 8 clock cycle and count_enable on" );


//test case 4: clear while counting
@(negedge tb_clk);
		tb_test_num = tb_test_num + 1;
    tb_test_case = "Clear while counting";
	
		tb_count_enable = INACTIVE_VALUE;
		reset_dut();
//call clear task 

		tb_count_enable = 1'b1;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b1, "after one clock cycle" );
		check_rollover(1'b0, "after one clock cycle" );


		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 2 clock cycle" );
		check_rollover(1'b0, "after 2 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0011, "after 3 clock cycle" );
		check_rollover(1'b0, "after 3 clock cycle" );

		tb_clear= 1'b1;

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0, "after 4 clock cycle" );
		check_rollover(1'b0, "after 4 clock cycle" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0, "after 5 clock cycle" );
		check_rollover(1'b0, "after 5 clock cycle" );
	
	tb_clear = 1'b0;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0001, "after 6 clock cycle" );
		check_rollover(1'b0, "after 6 clock cycle" );

//test case 5: rollover value not a power of 2
 @(negedge tb_clk);
		tb_test_num = tb_test_num + 1;
    tb_test_case = "rollover val not a power of 2";
	
		tb_count_enable = INACTIVE_VALUE;
		reset_dut();
		tb_rollover_val = 5'd5;
		
		tb_count_enable = 1'b1;
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0001, "after one clock cycle" );
		check_rollover(1'b0, "after one clock cycle" ); 

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 2 clock cycle" );
		check_rollover(1'b0, "after 2 clock cycle" );
		
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0011, "after 3 clock cycle and count_enable is off" );
		check_rollover(1'b0, "after 3 clock cycle and count_enable is off" );

		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0100, "after 4 clock cycle and count_enable is off" );
		check_rollover(1'b0, "after 4 clock cycle and count_enable is off" );
		
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0101, "after 5 clock cycle and count_enable on" );
		check_rollover(1'b1, "after 5 clock cycle and count_enable on" );

		@(posedge tb_clk)
		#(CHECK_DELAY);
		check_out(4'b1, "after 6 clock cycle and count_enable on" );
		check_rollover(1'b0, "after 6 clock cycle and count_enable on" );
		
		@(posedge tb_clk);
		#(CHECK_DELAY);
		check_out(4'b0010, "after 7 clock cycle and count_enable off" );
		check_rollover(1'b0, "after 7 clock cycle and count_enable off" );




end

endmodule
