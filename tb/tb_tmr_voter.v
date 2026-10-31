`timescale 1ns / 1ps

module tb_tmr_voter;

    // Testbench signals
    parameter WIDTH = 32;
    reg  [WIDTH-1:0] a, b, c;
    wire [WIDTH-1:0] out;

    // Instantiate the Unit Under Test (UUT)
    tmr_voter #( .WIDTH(WIDTH) ) uut (
        .reg_a(a),
        .reg_b(b),
        .reg_c(c),
        .reg_out(out)
    );

    initial begin
        // 1. Tell Icarus Verilog to dump waveforms for GTKWave
        $dumpfile("waves/tmr_voter.vcd");
        $dumpvars(0, tb_tmr_voter);

        // 2. Normal State: All redundant registers agree
        $display("Time: %0t | System Normal", $time);
        a = 32'hAAAAAAAA; b = 32'hAAAAAAAA; c = 32'hAAAAAAAA;
        #10; // Wait 10 nanoseconds
        
        // 3. SEU Event 1: Cosmic ray hits Register A (massive multi-bit upset)
        $display("Time: %0t | Injecting SEU into Register A", $time);
        a = 32'hDEADBEEF; 
        #10;
        
        // Return to normal (pretend the register was refreshed)
        a = 32'hAAAAAAAA;
        #10;

        // 4. SEU Event 2: Cosmic ray hits Register C
        $display("Time: %0t | Injecting SEU into Register C", $time);
        c = 32'h00000000;
        #10;

        $display("Simulation Complete.");
        $finish;
    end

endmodule