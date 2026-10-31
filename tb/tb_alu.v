`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] op1;
    reg  [31:0] op2;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    // Instantiate the ALU
    alu uut (
        .op1(op1), .op2(op2), .alu_ctrl(alu_ctrl),
        .result(result), .zero(zero)
    );

    initial begin
        $dumpfile("waves/alu.vcd");
        $dumpvars(0, tb_alu);

        $display("Time: %0t | Starting ALU Test", $time);

        // Test 1: Addition (15 + 10 = 25 / 0x19)
        op1 = 32'd15; op2 = 32'd10; alu_ctrl = 4'b0000;
        #10;
        
        // Test 2: Subtraction (15 - 15 = 0, should trigger zero flag)
        op1 = 32'd15; op2 = 32'd15; alu_ctrl = 4'b1000;
        #10;

        // Test 3: Bitwise AND (0x00FF & 0x0F0F = 0x000F)
        op1 = 32'h00FF; op2 = 32'h0F0F; alu_ctrl = 4'b0111;
        #10;

        // Test 4: Logical Shift Left (0x0001 << 4 = 0x0010)
        op1 = 32'h0001; op2 = 32'd4; alu_ctrl = 4'b0001;
        #10;

        $display("Simulation Complete.");
        $finish;
    end
endmodule