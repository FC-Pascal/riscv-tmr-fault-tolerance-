`timescale 1ns / 1ps

module decoder (
    input  wire [31:0] instr,       // Raw 32-bit instruction from memory
    output wire [4:0]  rs1_addr,    // Routed to Register File
    output wire [4:0]  rs2_addr,    // Routed to Register File
    output wire [4:0]  rd_addr,     // Routed to Register File
    output reg  [3:0]  alu_ctrl,    // Routed to ALU
    output reg         reg_we       // Register Write Enable
);

    // Internal wire assignments slicing the instruction
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    assign rd_addr  = instr[11:7];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];

    // RISC-V Base Opcodes
    localparam OP_R_TYPE = 7'b0110011;

    // ALU Control Code Mapping (matching our alu.v)
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b1000;
    localparam ALU_AND = 4'b0111;

    always @(*) begin
        // Default control states to prevent latches
        alu_ctrl = 4'b0000;
        reg_we   = 1'b0;

        case (opcode)
            OP_R_TYPE: begin
                reg_we = 1'b1; // R-type instructions always write a result to rd
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000) alu_ctrl = ALU_SUB;
                        else                      alu_ctrl = ALU_ADD;
                    end
                    3'b111: alu_ctrl = ALU_AND;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end
            // Future expansion for I-type, Branches, etc. goes here
            default: begin
                reg_we = 1'b0;
            end
        endcase
    end

endmodule