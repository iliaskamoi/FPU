module test_status_bits(
    input logic [7:0] status
);
    logic overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
    assign {overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f} = status;

    always_comb assert ( !(zero_f && inf_f) ) else $error("zero_f and inf_f asserted together");
    always_comb assert ( !(zero_f && nan_f) ) else $error("zero_f and nan_f asserted together");
    always_comb assert ( !(inf_f && nan_f) ) else $error("inf_f and nan_f asserted together");
    always_comb assert ( !(huge_f && tiny_f) ) else $error("huge_f and tiny_f asserted together");
endmodule



module test_status_z_combinations(
    input logic clk,
    input logic [31:0] z,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [7:0] status
);

    logic overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
    assign {overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f} = status;

    assert property (@(posedge clk) zero_f |-> (z[30:23] == 8'b00000000))
        else $error("zero_f asserted but exponent of z is not all zeros");
    assert property (@(posedge clk) inf_f |-> (z[30:23] == 8'b11111111))
        else $error("inf_f asserted but exponent of z is not all ones");
    assert property (@(posedge clk) nan_f |-> ( (a[30:23] == 8'b11111111 && b[30:23] == 8'b00000000) ||
                                                (a[30:23] == 8'b00000000 && b[30:23] == 8'b11111111) ))
        else $error("nan_f asserted but exponents of a and b are not as expected two cycles before");
    assert property (@(posedge clk) huge_f |-> ( (z[30:23] == 8'b11111111) || 
                                                 (z[30:23] == 8'b11111110 && z[22:0] == 23'b11111111111111111111111) ))
        else $error("huge_f asserted but exponent of z is not all ones or maxNormal case");
    assert property (@(posedge clk) tiny_f |-> ( (z[30:23] == 8'b00000000) ||
                                                 (z[30:23] == 8'b00000001 && z[22:0] == 23'b00000000000000000000000) ))
        else $error("tiny_f asserted but exponent of z is not all zeros or minNormal case");

endmodule
