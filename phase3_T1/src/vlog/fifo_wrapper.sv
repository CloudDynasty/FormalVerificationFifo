`include "/user/stud/fall19/zl2871/Desktop/phase3_T1/src/vlog/fifo.sv"
`include "/tools/mentor/questa_2019.2_1/linux_x86_64/share/assertion_lib/OVL/verilog/ovl_fifo.v"

module fifo_wrapper( clk, rst, in_read_ctrl, in_write_ctrl, in_write_data, 
             out_read_data, out_is_full, out_is_empty
             );

   
parameter
  ENTRIES = 4; 
  
localparam [31:0]  
  ENTRIES_LOG2 = $clog2(ENTRIES);
  
   input  logic       clk; 
   input  logic       rst;
   input  logic       in_read_ctrl;
   input  logic       in_write_ctrl;
   input  logic [7:0] in_write_data;
   output logic [7:0] out_read_data;
   output logic       out_is_full;
   output logic       out_is_empty;

   logic [ENTRIES_LOG2-1:0]  write_ptr;
   logic [ENTRIES_LOG2-1:0]  read_ptr;
   logic [ENTRIES-1:0] [7:0] fifo_data;
   logic [7:0]               head;
   logic [ENTRIES_LOG2:0]    number_of_current_entries; 

   logic                     out_is_full_tmp;   
   logic                     out_is_empty_tmp;
   logic                     last_out_is_empty;
   logic                     last_out_is_full; 
   
   logic                     fifo_is_correct; 

   fifo
      #(.ENTRIES(ENTRIES))
   fifo_inst
     (.clk(clk),
      .rst(rst),
      .in_read_ctrl(in_read_ctrl),
      .in_write_ctrl(in_write_ctrl),
      .in_write_data(in_write_data),
      .out_read_data(out_read_data),
      .out_is_full(out_is_full_tmp),
      .out_is_empty(out_is_empty_tmp));


always_comb  begin
   if (rst) begin
      out_is_full = out_is_full_tmp;
      out_is_empty = out_is_empty_tmp;
   end
   else begin
      if (fifo_is_correct) begin
         out_is_full = out_is_full_tmp;
         out_is_empty = out_is_empty_tmp;
      end
      else begin 
         out_is_full = last_out_is_full;
         out_is_empty = last_out_is_empty;
      end
   end
end

always_ff @(posedge clk) begin
   if (rst) begin
      fifo_is_correct <= 1'b0;
      last_out_is_full <= 1'b0;
      last_out_is_empty <= 1'b1;
   end
   else begin
      fifo_is_correct <= in_read_ctrl | in_write_ctrl;
      last_out_is_full <= out_is_full;
      last_out_is_empty <= out_is_empty;
   end
end

// for verifying fifo correctness
ovl_fifo #(
	.depth(4), .width(8), .enq_latency(0), .deq_latency(0), .pass_thru(0))
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
   
