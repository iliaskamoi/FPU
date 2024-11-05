`include "typedef.svh"

module round_mult (
    input logic [23:0] mantissa,
    input logic guard_bit,
    input logic sticky_bit,
    input logic calculated_sign,
    input round_t rnd,
    output logic [24:0] post_round_mantissa,
    output logic inexact
);

    always_comb begin : INEXACT
        inexact = guard_bit || sticky_bit;
    end

    always_comb begin : ROUNDING
        /* Initialization of variables in case of lack of `else` statements */
        post_round_mantissa = {0, mantissa};

        case (rnd)
            IEEE_near : begin
                if (guard_bit && (sticky_bit || mantissa[0])) begin 
                    post_round_mantissa = mantissa + 1;
                end
            end
            IEEE_zero : begin
                if (guard_bit && sticky_bit) begin
                    post_round_mantissa = mantissa + 1;
                end
            end
            IEEE_pinf : begin
                if (guard_bit && sticky_bit) begin
                    post_round_mantissa = mantissa + 1;
                end
            end
            IEEE_ninf : begin
                if (sticky_bit && guard_bit) begin
                    post_round_mantissa = mantissa + 1;
                end
            end
            near_up : begin
                if (guard_bit && sticky_bit) begin 
                    post_round_mantissa = mantissa + 1;
                end
            end
            away_zero : begin
                if (guard_bit && (sticky_bit || mantissa[0])) begin
                    post_round_mantissa = mantissa + 1;
                end
            end
            default : begin
                if (guard_bit && (sticky_bit || mantissa[0])) begin 
                    post_round_mantissa = mantissa + 1;  
                end
            end
        endcase
    end
endmodule