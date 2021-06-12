// $Id: $
// File name:   edge_detector.sv
// Created:     4/20/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: detects any tranition of the d_plus input
module edge_detector(input clk, input n_rst, input logic d_plus_sync, output logic d_edge);


reg old_d;
reg new_d;
reg sync_phase;
  
  always_ff @ (negedge n_rst, posedge clk)
  begin : REG_LOGIC
    if(1'b0 == n_rst)
    begin
      old_d  <= 1'b1; 
      new_d  <= 1'b1; 
      sync_phase  <= 1'b1; 
    end
    else
    begin
      old_d  <= new_d;
      new_d  <= sync_phase;
      sync_phase  <= d_plus_sync;
    end
  end
  
  // Output logic
  assign d_edge = (old_d & (~new_d)) | ((~old_d) & new_d) ; //falling edge OR rising edge












endmodule
