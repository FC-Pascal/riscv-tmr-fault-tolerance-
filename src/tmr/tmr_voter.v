`timescale 1ns / 1ps

module tmr_voter #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] reg_a,
    input  wire [WIDTH-1:0] reg_b,
    input  wire [WIDTH-1:0] reg_c,
    output wire [WIDTH-1:0] reg_out
);

    // Continuous assignment: The hardware constantly evaluates this expression.
    // If one register suffers a bit-flip (SEU), the other two will mask it.
    assign reg_out = (reg_a & reg_b) | (reg_b & reg_c) | (reg_a & reg_c);

endmodule