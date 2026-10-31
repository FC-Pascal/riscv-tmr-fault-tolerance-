`timescale 1ns / 1ps

module cpu_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instr,      // Instruction fetched from external memory
    output wire [31:0] alu_result  // Exposed as an output for testbench visibility
);

    // Internal routing wires
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [3:0]  alu_ctrl;
    wire        reg_we;
    
    wire [31:0] rs1_data, rs2_data;
    wire        alu_zero;

    // 1. Instruction Decoder
    decoder u_decoder (
        .instr(instr),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .alu_ctrl(alu_ctrl), .reg_we(reg_we)
    );

    // 2. TMR-Protected Register File
    tmr_register_file u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .we(reg_we),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .rd_data(alu_result), // Loop the ALU result back to the write port
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    // 3. Arithmetic Logic Unit (ALU)
    alu u_alu (
        .op1(rs1_data),
        .op2(rs2_data),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

endmodule