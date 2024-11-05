`include "fp_mult.sv"
module fp_mult_top (
   input logic clk,
   input logic rst,
   input logic [2:0] rnd,
   input logic [31:0] a,
   input logic [31:0] b,
   output logic [31:0] z,
   output logic [7:0] status
);

    logic [31:0] a_buffer, b_buffer;
    logic [2:0] rnd_buffer;
    logic [31:0] z_buffer;
    logic [7:0] status_buffer;
    
    fp_mult multiplier(
      .a(a_buffer),
      .b(b_buffer),
      .rnd(rnd_buffer),
      .z(z_buffer),
      .status(status_buffer)
    );
    
    
    always_ff @(posedge clk) begin
         a_buffer <= a;
         b_buffer <= b;
	     rnd_buffer <= rnd;
         z <= z_buffer;
         status <= status_buffer;
    end
endmodule