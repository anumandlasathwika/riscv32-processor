module imm_gen (
    input  logic [31:0] instr,
    output logic [31:0] imm_out
);

    wire [6:0] opcode = instr[6:0];

    // Explicit sign-extension vectors constructed outside always_comb
    // to bypass Icarus Verilog constant-select and replication operator issues
    wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] b_imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] u_imm = {instr[31:12], 12'b0};
    wire [31:0] j_imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    // RV32I Base Opcodes
    localparam OP_I_TYPE   = 7'b0010011; // ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
    localparam OP_LOAD     = 7'b0000011; // LB, LH, LW, LBU, LHU
    localparam OP_JALR     = 7'b1100111; // JALR
    localparam OP_STORE    = 7'b0100011; // SB, SH, SW
    localparam OP_BRANCH   = 7'b1100011; // BEQ, BNE, BLT, BGE, BLTU, BGEU
    localparam OP_LUI      = 7'b0110111; // LUI
    localparam OP_AUIPC    = 7'b0010111; // AUIPC
    localparam OP_JAL      = 7'b1101111; // JAL

    always_comb begin
        case (opcode)
            OP_I_TYPE, OP_LOAD, OP_JALR: imm_out = i_imm;
            OP_STORE:                    imm_out = s_imm;
            OP_BRANCH:                   imm_out = b_imm;
            OP_LUI, OP_AUIPC:            imm_out = u_imm;
            OP_JAL:                      imm_out = j_imm;
            default:                     imm_out = 32'b0;
        endcase
    end

endmodule