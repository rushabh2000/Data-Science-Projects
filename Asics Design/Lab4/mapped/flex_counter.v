/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Wed Feb 17 20:28:22 2021
/////////////////////////////////////////////////////////////


module flex_counter ( clk, n_rst, clear, count_enable, rollover_val, count_out, 
        rollover_flag );
  input [3:0] rollover_val;
  output [3:0] count_out;
  input clk, n_rst, clear, count_enable;
  output rollover_flag;
  wire   N10, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n43, n44, n45, n46, n47, n48, n49;
  wire   [3:0] nxt_counter;

  DFFSR \count_out_reg[0]  ( .D(nxt_counter[0]), .CLK(clk), .R(n_rst), .S(1'b1), .Q(count_out[0]) );
  DFFSR rollover_flag_reg ( .D(N10), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        rollover_flag) );
  DFFSR \count_out_reg[1]  ( .D(nxt_counter[1]), .CLK(clk), .R(n_rst), .S(1'b1), .Q(count_out[1]) );
  DFFSR \count_out_reg[2]  ( .D(nxt_counter[2]), .CLK(clk), .R(n_rst), .S(1'b1), .Q(count_out[2]) );
  DFFSR \count_out_reg[3]  ( .D(nxt_counter[3]), .CLK(clk), .R(n_rst), .S(1'b1), .Q(count_out[3]) );
  NOR2X1 U32 ( .A(n28), .B(n29), .Y(N10) );
  NAND2X1 U33 ( .A(n30), .B(n31), .Y(n29) );
  XNOR2X1 U34 ( .A(rollover_val[1]), .B(nxt_counter[1]), .Y(n31) );
  OAI22X1 U35 ( .A(n32), .B(n33), .C(n34), .D(n35), .Y(nxt_counter[1]) );
  XNOR2X1 U36 ( .A(n36), .B(n37), .Y(n34) );
  XNOR2X1 U37 ( .A(rollover_val[2]), .B(nxt_counter[2]), .Y(n30) );
  OAI22X1 U38 ( .A(n32), .B(n38), .C(n39), .D(n35), .Y(nxt_counter[2]) );
  XNOR2X1 U39 ( .A(n40), .B(n41), .Y(n39) );
  NAND2X1 U40 ( .A(n42), .B(n43), .Y(n28) );
  XNOR2X1 U41 ( .A(rollover_val[0]), .B(nxt_counter[0]), .Y(n43) );
  OAI22X1 U42 ( .A(n37), .B(n35), .C(n32), .D(n44), .Y(nxt_counter[0]) );
  XNOR2X1 U43 ( .A(rollover_val[3]), .B(nxt_counter[3]), .Y(n42) );
  OAI22X1 U44 ( .A(n45), .B(n35), .C(n32), .D(n46), .Y(nxt_counter[3]) );
  OR2X1 U45 ( .A(clear), .B(count_enable), .Y(n32) );
  NAND2X1 U46 ( .A(count_enable), .B(n47), .Y(n35) );
  INVX1 U47 ( .A(clear), .Y(n47) );
  XOR2X1 U48 ( .A(n48), .B(n49), .Y(n45) );
  NOR2X1 U49 ( .A(n41), .B(n40), .Y(n49) );
  NAND2X1 U50 ( .A(n37), .B(n36), .Y(n40) );
  NOR2X1 U51 ( .A(n33), .B(rollover_flag), .Y(n36) );
  INVX1 U52 ( .A(count_out[1]), .Y(n33) );
  NOR2X1 U53 ( .A(n44), .B(rollover_flag), .Y(n37) );
  INVX1 U54 ( .A(count_out[0]), .Y(n44) );
  OR2X1 U55 ( .A(n38), .B(rollover_flag), .Y(n41) );
  INVX1 U56 ( .A(count_out[2]), .Y(n38) );
  OR2X1 U57 ( .A(n46), .B(rollover_flag), .Y(n48) );
  INVX1 U58 ( .A(count_out[3]), .Y(n46) );
endmodule

