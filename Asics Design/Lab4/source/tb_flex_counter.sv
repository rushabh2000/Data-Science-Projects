// $Id: $
// File name:   tb_flex_counter.sv
// Created:     2/15/2021
// Author:      Rushabh Ranka
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: flex_counter test bench

`timescale 1ns / 10ps

module tb_flex_counter();

  localparam  CLK_PERIOD    = 2.5;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = 1; // Check right before the setup time starts
  localparam NUM_CNT_BITS = 4;
  
  localparam  INACTIVE_VALUE    = 1'b0;
  localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;

// Declare DUT portmap signals
  reg tb_clk;
  always 
begin
	tb_clk = 1'b0;
	#(CLK_PERIOD / 2.0);
	tb_clk = 1'b0;
        #(CLK_PERIOD / 2.0);
end
  reg tb_n_rst;
  reg tb_clear;
  reg tb_count_enable;
  reg [NUM_CNT_BITS -1: 0] tb_rollover_val;
  reg [NUM_CNT_BITS - 1:0] tb_count_out;
  reg tb_rollover_flag;

  integer tb_test_num;
  string tb_test_case;
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
    tb_count_enable =1'b0;
    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
endtask
// Task for standard DUT reset procedure
  task clear;
  begin
    // Activate the reset
    tb_clear = 1'b1;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
   tb_clear =1'b0;
   
    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
   
  end
endtask
// Task to cleanly and consistently check DUT output values
  task check_output;
    input logic [3:0] output_value;
    input logic  flag_value;
    input string check_tag;
  begin
    if((output_value == tb_count_out) & (flag_value == tb_rollover_flag)) begin // Check passed
      $info("Correct synchronizer output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect synchronizer output %d during %s test case", check_tag, tb_test_case);
    end
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
  
  // DUT Port map
  flex_counter DUT(.clk(tb_clk), .n_rst(tb_n_rst), .clear(tb_clear), .count_enable(tb_count_enable),.rollover_val(tb_rollover_val),.count_out(tb_count_out),.rollover_flag(tb_rollover_flag));
 
// Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_clear  = INACTIVE_VALUE;
    tb_count_enable = INACTIVE_VALUE;		 // Initialize input to inactive  value
    
    tb_test_num = 0;               // Intialize test case counter
    tb_test_case = "Test bench initializaton";
  
    // Wait some time before starting first test case
    #(0.1);
    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_clear  = INACTIVE_VALUE; // Set to be the the non-reset value
    tb_n_rst  = 1'b0;    // Activate reset
    tb_clk = INACTIVE_VALUE;
    tb_count_enable = 1'b0;
    tb_rollover_val = 1'b0100;
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_output( 1'b0,1'b0, 
                  "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output(1'b0,1'b0, 
                  "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;

   // ************************************************************************
    // Test Case 2: rollover for a rollover value that is not a power of 2
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "rollover for a rollover value that is not a power of 2";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    //reset_dut();
    tb_clear = 1;

    // Assign test case stimulus
    @(posedge tb_clk); 
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    tb_clear = 1'b0;
    tb_rollover_val = 4'b1111;
				
			
    // Wait for DUT to process stimulus before checking results
    
    #(CHECK_DELAY);
    @(posedge tb_clk); 

    @(posedge tb_clk);

    @(posedge tb_clk);

    @(posedge tb_clk);
  @(posedge tb_clk); 

    @(posedge tb_clk);

    @(posedge tb_clk);

    @(posedge tb_clk);
  @(posedge tb_clk); 

    @(posedge tb_clk);

    @(posedge tb_clk);

    @(posedge tb_clk);

  @(posedge tb_clk); 

    @(posedge tb_clk);

    @(posedge tb_clk);

    @(posedge tb_clk);
    
    
  
    
    check_output(4'b1111,1'b1,
                  "checking for rollover value");
    //tb_n_rst  = 1'b1; 

   // ************************************************************************
    // Test Case 3: Continuous counting
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Continus counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    reset_dut();
    
   @(posedge tb_clk); 
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    // Assign test case stimulus
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    tb_clear = 1'b0;
    tb_rollover_val = 4'b011;
			
    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk); 
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk); 
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    @(posedge tb_clk);
//$info("%dflag %d", tb_count_out,tb_rollover_flag);
    // Check results
    check_output(4'b0001,1'b0,
                  "checking for rollover value");
  // ************************************************************************
    // Test Case 4: Discontinuous counting
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Discontinus counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests 
    reset_dut();


    // Assign test case stimulus
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    tb_clear = 1'b0;
    tb_rollover_val = 4'b0101;
				
			
    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);//0 
    @(posedge tb_clk); //1
    @(posedge tb_clk);//2
    @(negedge tb_clk);
    
    tb_count_enable = 1'b0;
    @(posedge tb_clk);//2
    @(posedge tb_clk);//2
    @(negedge tb_clk);
    tb_count_enable = 1'b1;
    @(posedge tb_clk);//3
    @(posedge tb_clk);//4
    @(posedge tb_clk);//5


    // Check results
    check_output(4'b0101,1'b1,
                  "checking for rollover value");
// ************************************************************************
    // Test Case 5: Clearig while counting to check clear vs enable priority
    // *

 @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "clear vs enable priority check";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    reset_dut();


    // Assign test case stimulus
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    tb_clear = 1'b0;
    tb_rollover_val = 4'b0101;
				
			
    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);//0 
    @(posedge tb_clk); //1
    @(posedge tb_clk);//2
    @(negedge tb_clk);//2
    tb_clear = 1'b1;
    @(posedge tb_clk);//0
    @(posedge tb_clk);//0
   

    // Check results
    check_output(4'b0000,1'b0,
                  "checking for rollover value");

  
end
endmodule
