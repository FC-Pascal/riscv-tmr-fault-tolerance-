`timescale 1ns / 1ps

module alu (
    input  wire [31:0] op1,       // Operand 1 (usually from rs1)
    input  wire [31:0] op2,       // Operand 2 (usually from rs2)
    input  wire [3:0]  alu_ctrl,  // 4-bit Control Signal from the Decoder
    output reg  [31:0] result,    // The calculated answer
    output wire        zero       // High if result is 0 (used for Branching)
);

    // ALU Control Codes (Standardized for our microarchitecture)
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b1000;
    localparam AND  = 4'b0111;
    localparam OR   = 4'b0110;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0001; // Shift Left Logical
    localparam SRL  = 4'b0101; // Shift Right Logical

    // Combinational logic: Evaluate whenever inputs change
    always @(*) begin
        case (alu_ctrl)
            ADD:  result = op1 + op2;
            SUB:  result = op1 - op2;
            AND:  result = op1 & op2;
            OR:   result = op1 | op2;
            XOR:  result = op1 ^ op2;
            SLL:  result = op1 << op2[4:0]; // Shift by lower 5 bits of op2
            SRL:  result = op1 >> op2[4:0];
            default: result = 32'h00000000;
        endcase
    end

    // The zero flag is useful for BEQ (Branch if Equal) instructions
    assign zero = (result == 32'h00000000) ? 1'b1 : 1'b0;

endmodule