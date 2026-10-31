`timescale 1ns / 1ps

module tb_decoder;

    reg  [31:0] instr;
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [3:0]  alu_ctrl;
    wire        reg_we;

    decoder uut (
        .instr(instr),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .alu_ctrl(alu_ctrl), .reg_we(reg_we)
    );

    initial begin
        $dumpfile("waves/decoder.vcd");
        $dumpvars(0, tb_decoder);

        $display("Time: %0t | Testing Decoder", $time);

        // Test 1: ADD x5, x1, x2 (0x002082B3)
        // Expect: rs1=1, rs2=2, rd=5, alu_ctrl=0 (ADD), reg_we=1
        instr = 32'h002082B3;
        #10;

        // Test 2: SUB x6, x3, x4 (0x40418333)
        // Expect: rs1=3, rs2=4, rd=6, alu_ctrl=8 (SUB), reg_we=1
        instr = 32'h40418333;
        #10;

        $display("Simulation Complete.");
        $finish;
    end
endmodule