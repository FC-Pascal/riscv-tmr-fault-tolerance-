`timescale 1ns / 1ps

module tb_cpu_core;

    reg         clk;
    reg         rst_n;
    reg  [31:0] instr;
    wire [31:0] alu_result;

    cpu_core uut (
        .clk(clk), .rst_n(rst_n), .instr(instr), .alu_result(alu_result)
    );

    // 100MHz Clock Generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/cpu_core.vcd");
        $dumpvars(0, tb_cpu_core);
        
        $dumpvars(1, uut.u_reg_file.bank_a[5]);
        $dumpvars(1, uut.u_reg_file.bank_b[5]);
        $dumpvars(1, uut.u_reg_file.bank_c[5]);

        clk = 0; rst_n = 0; instr = 32'h00000000;
        
        #15 rst_n = 1; // 1. Release reset first

        // 2. Initialize x1 and x2 after the reset clears
        uut.u_reg_file.bank_a[1] = 32'd10; uut.u_reg_file.bank_b[1] = 32'd10; uut.u_reg_file.bank_c[1] = 32'd10;
        uut.u_reg_file.bank_a[2] = 32'd15; uut.u_reg_file.bank_b[2] = 32'd15; uut.u_reg_file.bank_c[2] = 32'd15;
        
        // Cycle 1: ADD x5, x1, x2 (10 + 15 = 25)
        $display("Time: %0t | Executing ADD x5, x1, x2", $time);
        @(posedge clk);
        instr = 32'h002082B3;
        
        // Cycle 2: SUB x6, x5, x1 (25 - 10 = 15)
        @(posedge clk);
        $display("Time: %0t | Executing SUB x6, x5, x1 with simultaneous SEU attack", $time);
        instr = 32'h40128333;
        
        #1; // 3. Wait 1ns for the RTL to finish saving the ADD result
        
        // INJECT FAULT: Particle strikes Bank B of register x5 asynchronously
        uut.u_reg_file.bank_b[5] = 32'hDEADBEEF;
        
        @(posedge clk);
        $display("Time: %0t | Final ALU Result: %0d (Should be 15 despite the fault)", $time, alu_result);
        
        #20;
        $finish;
    end
endmodule