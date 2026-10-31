`timescale 1ns / 1ps

module tmr_register_file (
    input  wire        clk,
    input  wire        rst_n,      // Active-low reset
    input  wire        we,         // Write Enable
    input  wire [4:0]  rs1_addr,   // Read Source 1 Address (5 bits for 32 registers)
    input  wire [4:0]  rs2_addr,   // Read Source 2 Address
    input  wire [4:0]  rd_addr,    // Write Destination Address
    input  wire [31:0] rd_data,    // Data to write
    output wire [31:0] rs1_data,   // TMR-corrected Read Data 1
    output wire [31:0] rs2_data    // TMR-corrected Read Data 2
);

    // Define three identical register banks (32 registers, 32 bits each)
    reg [31:0] bank_a [0:31];
    reg [31:0] bank_b [0:31];
    reg [31:0] bank_c [0:31];

    // Internal wires connecting raw read data to the voters
    wire [31:0] raw_rs1_a, raw_rs1_b, raw_rs1_c;
    wire [31:0] raw_rs2_a, raw_rs2_b, raw_rs2_c;

    integer i;

    // Synchronous Write Operation (Happens on the rising edge of the clock)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                bank_a[i] <= 32'h0;
                bank_b[i] <= 32'h0;
                bank_c[i] <= 32'h0;
            end
        end else if (we && rd_addr != 5'd0) begin
            // Write to all three banks simultaneously, unless writing to x0
            bank_a[rd_addr] <= rd_data;
            bank_b[rd_addr] <= rd_data;
            bank_c[rd_addr] <= rd_data;
        end
    end

    // Asynchronous Read Operation (Continuous assignment)
    assign raw_rs1_a = bank_a[rs1_addr];
    assign raw_rs1_b = bank_b[rs1_addr];
    assign raw_rs1_c = bank_c[rs1_addr];

    assign raw_rs2_a = bank_a[rs2_addr];
    assign raw_rs2_b = bank_b[rs2_addr];
    assign raw_rs2_c = bank_c[rs2_addr];

    // Instantiate TMR Voters for both read ports
    tmr_voter #( .WIDTH(32) ) voter_rs1 (
        .reg_a(raw_rs1_a), .reg_b(raw_rs1_b), .reg_c(raw_rs1_c),
        .reg_out(rs1_data)
    );

    tmr_voter #( .WIDTH(32) ) voter_rs2 (
        .reg_a(raw_rs2_a), .reg_b(raw_rs2_b), .reg_c(raw_rs2_c),
        .reg_out(rs2_data)
    );

endmodule