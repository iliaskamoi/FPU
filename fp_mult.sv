`include "normalize_mult.sv"
`include "round_mult.sv"
`include "exception_mult.sv"
`include "typedef.svh"
module fp_mult (
    input logic [31:0] a, b,
    input round_t rnd,
    output logic [7:0] status,
    output logic [31:0] z
);
    localparam int signed MIN_EXPONENT = -126;
    localparam int MAX_EXPONENT = 255;

    /* Floating point number sign calculation */
    logic sign_bit_a, sign_bit_b, sign_norm_eh;    
    always_comb begin : SIGN_BIT
        sign_bit_a = a[31];
        sign_bit_b = b[31];
        sign_norm_eh = sign_bit_a ^ sign_bit_b;
    end

    /* Exponent addition */
    logic [7:0] exp_bits_a, exp_bits_b;
    logic [9:0] exp_add_norm;
    always_comb begin : EXPONENT_ADDITION
        exp_bits_a = a[30:23];
        exp_bits_b = b[30:23];    
    end

    /*Exponent subtraction of bias */
    always_comb begin : EXPONENT_SUBTRACTION_OF_BIAS
        exp_add_norm = exp_bits_a + exp_bits_b - 127;
    end

    /* Mantissa multiplication */
    logic [22:0] mant_bits_a, mant_bits_b;
    logic [47:0] mant_mult_norm;
    always_comb begin : MANTISSA_MULTIPLICATION
        mant_bits_a = a[22:0];
        mant_bits_b = b[22:0];
        mant_mult_norm = {1'b1, mant_bits_a} * {1'b1, mant_bits_b};
    end 

    /* Truncation and normalization */
    logic [9:0] exp_norm_eh;
    logic [22:0] mant_norm_rnd;
    logic guard_bit_norm_rnd;
    logic sticky_bit_norm_rnd;
    
    normalize_mult normalizer (
        .add_result(exp_add_norm),
        .mult_result(mant_mult_norm),
        .rnd(rnd),
        .norm_exp(exp_norm_eh),
        .norm_mant(mant_norm_rnd),
        .guard_bit(guard_bit_norm_rnd),
        .sticky_bit(sticky_bit_norm_rnd)
    );

    /* Rounding */
    logic [23:0] mantissa_norm_rnd_ext;
    assign mantissa_norm_rnd_ext = {1'b1, mant_norm_rnd};
    logic [24:0] mant_rnd_eh;
    logic inexact_rd_eh;
    round_mult rounding (
        .mantissa(mantissa_norm_rnd_ext),
        .guard_bit(guard_bit_norm_rnd),
        .sticky_bit(sticky_bit_norm_rnd),
        .calculated_sign(sign_norm_eh),
        .rnd(rnd),
        .post_round_mantissa(mant_rnd_eh),
        .inexact(inexact_rd_eh)
    );
    
    logic [23:0] post_rounding_mantissa;
    logic [9:0] post_rounding_exponent;
    always_comb begin : POST_ROUNDING
        post_rounding_exponent = mant_rnd_eh[24] ? exp_norm_eh + 1 : exp_norm_eh;
        post_rounding_mantissa = mant_rnd_eh[24] ? mant_rnd_eh >> 1 : mant_rnd_eh;
    end
   
    /* Early version of the "z" output of the multiplier for the exception module */
    logic [31:0] z_calc;
    always_comb begin : Z_CALC
        z_calc = {sign_norm_eh, post_rounding_exponent[7:0], post_rounding_mantissa[22:0]};
    end
    
    /* Calculation of `overflow` and `underflow` */
    logic overflow, underflow;
    always_comb begin : OVERFLOW_UNDERFLOW_CALC
        overflow = $signed(exp_norm_eh) > MAX_EXPONENT;
        underflow = $signed(exp_norm_eh) < MIN_EXPONENT & mant_norm_rnd != 0;
    end
    
    /* Denormal handling */
    always_comb begin : DENORMALS
        
    end
    
    /* Exception Handling */  
    logic [31:0] z_eh_out;
    logic [7:0] status;
    logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
    exception_mult exception (
        .a(a),
        .b(b),
        .z_calc(z_calc),
        .rnd(rnd),
        .overflow(overflow),
        .underflow(underflow),
        .inexact(inexact_rd_eh),
        .zero_f(zero_f),
        .inf_f(inf_f),
        .nan_f(nan_f),
        .tiny_f(tiny_f),
        .huge_f(huge_f),
        .inexact_f(inexact_f),
        .z(z_eh_out)
    );
    always_comb begin : OUTPUTS
        z = z_eh_out;
        status = {overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f};
    end
endmodule