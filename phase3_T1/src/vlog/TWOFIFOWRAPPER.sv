`include "/user/stud/fall19/zl2871/Desktop/phase3_T1/src/vlog/fifo.sv"
`include "/tools/mentor/questa_2019.2_1/linux_x86_64/share/assertion_lib/OVL/verilog/ovl_fifo.v"
`include "/tools/mentor/questa_2019.2_1/linux_x86_64/share/assertion_lib/OVL/verilog/ovl_fifo_index.v"
module TWOFIFOWRAPPER( clk, rst, in_read_ctrl, in_write_ctrl, in_write_data, 
             out_read_data, out_is_full, out_is_empty);
  
   input  logic       clk;
   input  logic       rst;
   input  logic       in_read_ctrl;
   input  logic       in_write_ctrl;
   input  logic [7:0] in_write_data;
   output logic [7:0] out_read_data;
   output logic       out_is_full;
   output logic       out_is_empty;

   logic	out_is_full1;
   logic	out_is_empty1;
   logic	out_is_full_reg;
   logic	out_is_empty_reg;
   logic	enable;

   fifo fifo1(clk, rst, in_read_ctrl, in_write_ctrl, in_write_data, 
             out_read_data, out_is_full1, out_is_empty1);

// enable decision block
always_ff @(posedge clk) begin
   if (rst) begin
      out_is_full_reg <= 1'b0;
      out_is_empty_reg <= 1'b1;
      out_is_empty <= 1;
      out_is_full <= 0;
   end
   else begin
      if (~in_read_ctrl & ~in_write_ctrl) begin
         out_is_empty <= out_is_empty_reg;
         out_is_full <= out_is_full_reg;
      end
      else begin
         out_is_empty <= out_is_empty1;
         out_is_full <= out_is_full1;
      end
   end
end

always_ff @(negedge in_write_ctrl) begin
   out_is_full_reg <= out_is_full1;
end

always_ff @(negedge in_read_ctrl) begin
   out_is_empty_reg <= out_is_empty1;
end

// for verifying fifo correctness
ovl_fifo #(
	.depth(4), .width(8), .enq_latency(1), .deq_latency(1))
	ovl_fifo_check(
		.clock(clk),
		.reset(!rst), .enable(1'b1),
		.enq(in_write_ctrl),
		.enq_data(in_write_data),
		.deq(in_read_ctrl),
		.deq_data(out_read_data),
		.full(out_is_full),
		.empty(out_is_empty));
endmodule
