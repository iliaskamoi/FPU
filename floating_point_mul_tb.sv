`include "fp_mult_top.sv"
`include "multiplication.sv"
`include "typedef.svh"

module test_fp_mult;
    logic [31:0] a;
    logic [31:0] b;
    round_t rnd;   
    logic [31:0] z;
    logic [7:0] status;
    logic clk;
    logic [31:0] correct_result;

    fp_mult_top uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .rnd(rnd),
        .z(z),
        .status(status)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #7.5 clk = ~clk;
    end 

    round_t rounding_modes[6] = '{IEEE_near, IEEE_zero, IEEE_pinf, IEEE_ninf, near_up, away_zero};
    corner_case_t corner_cases[12] = '{
        NEG_SNAN, POS_SNAN,
        NEG_NAN, POS_NAN,
        NEG_INF, POS_INF,
        NEG_NORMAL, POS_NORMAL,
        NEG_DENORMAL, POS_DENORMAL,
        NEG_ZERO, POS_ZERO
    };
    initial begin
        /* Random checks for all rounding modes */
        @(posedge clk);
        for (int i = 0; i < 90; i++) begin
            @(posedge clk);
            a = $urandom();
            b = $urandom();
            rnd = rounding_modes[i%6];
            correct_result = multiplication(string'(rnd), a, b);
            @(posedge clk);
            @(posedge clk);
            if (z != correct_result) begin
                $error("Fail, my result = %x and actual result = %x\n", z, correct_result);
            end
        end
        @(posedge clk);
        
        $display("Random value tests completed successfuly.");
        /* Corner cases checks */
        for (int i = 0; i < 12; i++) begin
            for (int j = 0; j < 12; j++) begin
                a = corner_cases[j];
                b = corner_cases[i];
                rnd = rounding_modes[i%6];
                correct_result = multiplication(string'(rnd), a, b);
                @(posedge clk);
                @(posedge clk);
                if (z != correct_result) begin
                    $error("Fail, my result = %x and actual result = %x\n", z, correct_result);
                end
            end    
        end
        $display("Corner cases tests completed successfuly.");
        $finish;
    end
endmodule
