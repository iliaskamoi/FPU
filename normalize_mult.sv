module normalize_mult (
    input logic [9:0] add_result,
    input logic [47:0] mult_result,
    input logic [2:0] rnd,
    output logic [9:0] norm_exp,
    output logic [22:0] norm_mant,
    output logic guard_bit,
    output logic sticky_bit
);
    always_comb begin
        sticky_bit = mult_result[47] ? |mult_result[22:0] : |mult_result[21:0];
        guard_bit = mult_result[47] ? mult_result[23] : mult_result[22];
        norm_mant = mult_result[47] ? mult_result[46:24] : mult_result[45:23];
        norm_exp =  mult_result[47] ? add_result + 1 : add_result;
        
        /* This is my addition to handle the denormals. It is not explicitly requested, but the results were incorrect otherwise */
        if ($signed(norm_exp) < 0) begin
            norm_mant = mult_result[47] ? mult_result[47:25] : mult_result[46:24];
            norm_mant = (norm_mant >> -(norm_exp));
            guard_bit = !($signed(norm_exp) < (-23));
            norm_exp = 10'b0;
            
        end
    end
endmodule