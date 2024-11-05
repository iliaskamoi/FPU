`include "typedef.svh"

module exception_mult (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] z_calc,
    input logic overflow,
    input logic underflow,
    input logic inexact,
    input round_t rnd,
    output logic [31:0] z,
    output logic zero_f,
    output logic inf_f,
    output logic nan_f,
    output logic tiny_f,
    output logic huge_f,
    output logic inexact_f
);

typedef enum logic [2:0] {
    ZERO,
    INF,
    NORM,
    MIN_NORM,
    MAX_NORM
} interp_t;

function interp_t num_interp(input logic [31:0] num);
    logic [7:0] exp;
    logic [22:0] frac;
    exp = num[30:23];
    frac = num[22:0];

    if (exp == 8'b00000000) begin
        return ZERO;
    end
    else if (exp == 8'b11111111) begin
        return INF;
    end
    else begin
        return NORM;
    end
endfunction

function logic [30:0] z_num(input interp_t interp);
    case (interp)
        ZERO: return 31'b0_00000000_0000000000000000000000;
        INF:  return 31'b0_111111110_000000000000000000000;
        default: return 31'b0_00000000_0000000000000000000000;
    endcase
endfunction

    interp_t interp_a, interp_b;
always_comb begin
    /* Initialization of variables in case of lack of `else` statements */
    zero_f = 1'b0;
    inf_f = 1'b0;
    nan_f = 1'b0;
    tiny_f = 1'b0;
    inexact_f = inexact;
    huge_f = 1'b0;

    interp_a = num_interp(a);
    interp_b = num_interp(b);

    case ({interp_a, interp_b})
        {ZERO, INF}, {INF, ZERO}: begin
            z = {1'b0, 8'hFF, 23'h000000};
            inf_f = 1'b1;
        end
        {ZERO, NORM}, {NORM, ZERO}, {ZERO, ZERO}: begin
            z = {a[31] ^ b[31], 8'h00, 23'h000000};
            zero_f = 1'b1;
        end
        {NORM, INF}, {INF, NORM}, {INF, INF}: begin
            z = {a[31] ^ b[31], 8'hFF, 23'h000000};
            inf_f = 1'b1;
        end
        /* For the special Normal x Normal case `underflow` and `overflow` are checked.
         * Exponent and Significand values for MaxNorm and MinNorm are taken from Table 2 
         */
        default: begin
            /* If `overflow is true, it means we have a "huge" number and the relative flag is raised.
             * In case `underflow` is true the relative tiny flag is raised. Both cases adhere to what 
             * described in Table 3.
             */
            if (overflow) begin
                if (rnd == IEEE_pinf) begin
                    z = {z_calc[31], 8'hFF, 23'h800000};
                end
                else begin
                    z = {z_calc[31], 8'hFF, 23'b0};
                end
                huge_f = 1'b1;
            end 
            else if (underflow) begin
                if (rnd == IEEE_ninf) begin
                    z = {z_calc[31], 8'h01, 23'b0};
                end 
                else begin
                    z = 32'b0;
                end
                tiny_f = 1'b1;
            end 
            else begin
                z = z_calc;
                inexact_f = inexact;
            end
        end
    endcase
end

endmodule
