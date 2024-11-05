`ifndef ROUNDING_MODES_SVH
`define ROUNDING_MODES_SVH

typedef enum logic [2:0] {
    IEEE_near, 
    IEEE_zero, 
    IEEE_pinf, 
    IEEE_ninf, 
    near_up, 
    away_zero
} round_t;

typedef enum logic [31:0] {
    POS_INF = 32'h7F800000,
    NEG_INF = 32'hFF800000,
    POS_ZERO = 32'h00000000,
    NEG_ZERO = 32'h80000000,
    POS_NAN = 32'h7FC00001,
    NEG_NAN = 32'hFFF80001,
    POS_SNAN = 32'h7F800001,
    NEG_SNAN = 32'hFFF00001,
    NEG_NORMAL = 32'hC0000000,
    POS_NORMAL = 32'h40000000,
    NEG_DENORMAL = 32'h80000001,
    POS_DENORMAL = 32'h00000001
} corner_case_t;
`endif