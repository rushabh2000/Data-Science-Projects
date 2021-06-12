// $Id: $
// File name:   flex_counter.sv
// Created:     2/15/2021
// Author:      Leah Crisco
// Lab Section: 337-002
// Version:     1.0  Initial Design Entry
// Description: flexible counter 
module flex_counter (clk,  n_rst, clear,count_enable, rollover_val, count_out, rollover_flag);

parameter NUM_CNT_BITS = 4;

input clk, n_rst, clear, count_enable;
input wire [(NUM_CNT_BITS -1):0] rollover_val;
output reg [(NUM_CNT_BITS -1):0] count_out;
output reg rollover_flag;

reg [(NUM_CNT_BITS-1) : 0] nxt_count;
reg  nxt_rollover_flag;

always_ff @ (posedge clk, negedge n_rst)
begin : REG_LOGIC
	if(1'b0 == n_rst) begin
			count_out <= '0;
			rollover_flag <= 1'b0;
end
	
else begin
	count_out <= nxt_count;
	rollover_flag <= nxt_rollover_flag;
	end
end

always_comb
begin : NXT_LOGIC
nxt_count = count_out;
nxt_rollover_flag = rollover_flag;

//check clear
if(1'b1 == clear) begin
		nxt_count = '0;
		nxt_rollover_flag = 1'b0;
end

//check rollover flag 
else if (rollover_val == (count_out+1)) begin
	if(count_enable == 1'b1) begin	
		nxt_rollover_flag = 1'b1;
		nxt_count = count_out +1;
end
end

else if( count_out == rollover_val) begin
	if(count_enable == 1'b1) begin	
		nxt_count = 1'b1;
		nxt_rollover_flag = 1'b0;
end
end


//count
else //if(rollover_flag != 1'b1) begin
 if((1'b1 == count_enable)) begin
	nxt_count = count_out +1;
end
//end


end

endmodule
