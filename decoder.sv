module decoder (
    input  logic [31:0] instr,
    
    // Instruction fields
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    
    // Control signals
    output logic        reg_write,
    output logic        alu_src,       // 0: rs2_data, 1: immediate
    output logic        mem_to_reg,    // 0: ALU result, 1: Memory data
    output logic        mem_write,
    output logic        mem_read,
    output logic        branch,
    output logic        jump,
    output logic        jalr,          // High for JALR instruction
    output logic        luipc,         // High for LUI/AUIPC target handling
    output logic [3:0]  alu_control,
    output logic [2:0]  mem_size,      // Encodes funct3 for byte/half/word width and sign extension
    output logic [2:0]  branch_type,   // Encodes funct3 for branch conditions
    output logic        ecall_flag,    // Asserted on ECALL
    output logic        ebreak_flag    // Asserted on EBREAK
);

    // Slice instruction fields based on RV32I standard
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    assign mem_size    = funct3;
    assign branch_type = funct3;

    // Intermediate bit select for SRAI/SRLI determination
    wire funct7_bit5 = instr[30];

    // RV32I Opcodes
    localparam OP_R_TYPE  = 7'b0110011;
    localparam OP_I_TYPE  = 7'b0010011;
    localparam OP_LOAD    = 7'b0000011;
    localparam OP_STORE   = 7'b0100011;
    localparam OP_BRANCH  = 7'b1100011;
    localparam OP_JAL     = 7'b1101111;
    localparam OP_JALR    = 7'b1100111;
    localparam OP_LUI     = 7'b0110111;
    localparam OP_AUIPC   = 7'b0010111;
    localparam OP_MISC_MEM= 7'b0001111; // FENCE
    localparam OP_SYSTEM  = 7'b1110011; // ECALL / EBREAK

    // ALU Control Operations Map
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;
    localparam ALU_LUI  = 4'b1010;

    always_comb begin
        // Default values
        reg_write   = 1'b0;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        jalr        = 1'b0;
        luipc       = 1'b0;
        alu_control = ALU_ADD;
        ecall_flag  = 1'b0;
        ebreak_flag = 1'b0;

        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                case ({funct7, funct3})
                    10'b0000000_000: alu_control = ALU_ADD;  // ADD
                    10'b0100000_000: alu_control = ALU_SUB;  // SUB
                    10'b0000000_001: alu_control = ALU_SLL;  // SLL
                    10'b0000000_010: alu_control = ALU_SLT;  // SLT
                    10'b0000000_011: alu_control = ALU_SLTU; // SLTU
                    10'b0000000_100: alu_control = ALU_XOR;  // XOR
                    10'b0000000_101: alu_control = ALU_SRL;  // SRL
                    10'b0100000_101: alu_control = ALU_SRA;  // SRA
                    10'b0000000_110: alu_control = ALU_OR;   // OR
                    10'b0000000_111: alu_control = ALU_AND;  // AND
                    default:         alu_control = ALU_ADD;
                endcase
            end

            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000:  alu_control = ALU_ADD;  // ADDI
                    3'b010:  alu_control = ALU_SLT;  // SLTI
                    3'b011:  alu_control = ALU_SLTU; // SLTIU
                    3'b100:  alu_control = ALU_XOR;  // XORI
                    3'b110:  alu_control = ALU_OR;   // ORI
                    3'b111:  alu_control = ALU_AND;  // ANDI
                    3'b001:  alu_control = ALU_SLL;  // SLLI
                    3'b101:  begin
                        if (funct7_bit5)
                            alu_control = ALU_SRA;  // SRAI
                        else
                            alu_control = ALU_SRL;  // SRLI
                    end
                    default: alu_control = ALU_ADD;
                endcase
            end

            OP_LOAD: begin // LB, LH, LW, LBU, LHU
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                mem_read   = 1'b1;
                alu_control= ALU_ADD;
            end

            OP_STORE: begin // SB, SH, SW
                reg_write  = 1'b0;
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_control= ALU_ADD;
            end

            OP_BRANCH: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b1;
                alu_control= ALU_SUB;
            end

            OP_JAL: begin
                reg_write  = 1'b1;
                jump       = 1'b1;
            end

            OP_JALR: begin
                reg_write  = 1'b1;
                jump       = 1'b1;
                jalr       = 1'b1;
                alu_src    = 1'b1;
                alu_control= ALU_ADD;
            end

            OP_LUI: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                luipc      = 1'b1;
                alu_control= ALU_LUI;
            end

            OP_AUIPC: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                luipc      = 1'b1;
                alu_control= ALU_ADD;
            end

            OP_MISC_MEM: begin // FENCE
                reg_write = 1'b0;
            end

            OP_SYSTEM: begin
                if (funct3 == 3'b000) begin
                    if (rs2 == 5'b00000)
                        ecall_flag  = 1'b1; // ECALL
                    else if (rs2 == 5'b00001)
                        ebreak_flag = 1'b1; // EBREAK
                end
            end

            default: begin
                reg_write   = 1'b0;
                alu_src     = 1'b0;
                mem_to_reg  = 1'b0;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                jalr        = 1'b0;
                luipc       = 1'b0;
                alu_control = ALU_ADD;
                ecall_flag  = 1'b0;
                ebreak_flag = 1'b0;
            end
        endcase
    end

endmodule