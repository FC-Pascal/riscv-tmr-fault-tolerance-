`timescale 1ns / 1ps

module tb_tmr_register_file;

    reg         clk;
    reg         rst_n;
    reg         we;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data, rs2_data;

    // Instantiate the UUT
    tmr_register_file uut (
        .clk(clk), .rst_n(rst_n), .we(we),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr), .rd_data(rd_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    // Generate a 100MHz Clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/tmr_register_file.vcd");
        $dumpvars(0, tb_tmr_register_file);
        
        // Dump specific internal array variables for GTKWave visibility
        $dumpvars(1, uut.bank_a[5], uut.bank_b[5], uut.bank_c[5]);

        // Initialize signals
        clk = 0; rst_n = 0; we = 0;
        rs1_addr = 0; rs2_addr = 0; rd_addr = 0; rd_data = 0;
        
        #15 rst_n = 1; // Release reset

        // 1. Write a valid value to Register x5
        $display("Time: %0t | Writing 0x0000BEEF to x5", $time);
        @(posedge clk);
        we = 1; rd_addr = 5'd5; rd_data = 32'h0000BEEF;
        @(posedge clk);
        we = 0;

        // 2. Read x5 on both ports to verify
        rs1_addr = 5'd5; rs2_addr = 5'd5;
        #10;
        
       // 3. Inject SEU into Bank B, Register x5 (Direct Memory Overwrite)
        $display("Time: %0t | Particle Strike! Corrupting Bank B, x5", $time);
        uut.bank_b[5] = 32'hFFFFFFFF; 
        #10;

        // 4. Read again. The output should still be 0x0000BEEF due to Banks A & C
        $display("Time: %0t | rs1_data: %h, rs2_data: %h", $time, rs1_data, rs2_data);
        #10;

        // 5. (No 'release' command needed because we did not use 'force')
        #10;

        $finish;
    end
endmodule