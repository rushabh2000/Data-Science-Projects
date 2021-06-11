/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Fri Feb 12 15:24:15 2021
/////////////////////////////////////////////////////////////


module sync_high ( clk, n_rst, async_in, sync_out );
  input clk, n_rst, async_in;
  output sync_out;
  wire   data;

  DFFSR data_reg ( .D(async_in), .CLK(clk), .R(n_rst), .S(1'b1), .Q(data) );
  DFFSR nxt_data_reg ( .D(data), .CLK(clk), .R(n_rst), .S(1'b1), .Q(sync_out)
         );
endmodule

