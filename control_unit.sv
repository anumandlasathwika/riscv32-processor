`timescale 1ns / 1ps

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [7:0] funct7,

    output logic       reg_write,
    output logic [1:0] alu_src_a,
    output logic [1:0] alu_src_b,
    output logic [3:0] alu_op,
    output logic [1:0] wb_sel,

    output logic       mem_read,
    output logic       mem_write,
    output logic [2:0] mem_size,
    output logic       mem_unsigned,

    output logic       branch,
    output logic [2:0] branch_type,
    output logic       jump,
    output logic       jalr,

    output logic       trap_flag
);

    // RV32I opcodes
    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_TYPE = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_MISC   = 7'b0001111;
    localparam OP_SYSTEM = 7'b1110011;

    // ALU control codes
    // 0000 = ADD
    // 0001 = SUB
    // 0010 = OR
    // 0011 = XOR
    // 0100 = SLT
    // 0101 = SLTU
    // 0110 = SLL
    // 0111 = SRL
    // 1000 = SRA
    // 1001 = AND

    always_comb begin

        // Safe defaults
        reg_write    = 1'b0;
        alu_src_a    = 2'b00;
        alu_src_b    = 2'b00;
        alu_op       = 4'b0000;
        wb_sel       = 2'b00;

        mem_read     = 1'b0;
        mem_write    = 1'b0;
        mem_size     = 3'b010;
        mem_unsigned = 1'b0;

        branch       = 1'b0;
        branch_type  = 3'b000;
        jump         = 1'b0;
        jalr         = 1'b0;

        trap_flag    = 1'b0;

        case (opcode)

            // =====================================================
            // R-TYPE
            // =====================================================
            OP_R_TYPE: begin

                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b00;
                wb_sel    = 2'b00;

                case (funct3)

                    3'b000: begin
                        if (funct7[5])
                            alu_op = 4'b0001;   // SUB
                        else
                            alu_op = 4'b0000;   // ADD
                    end

                    3'b001:
                        alu_op = 4'b0110;       // SLL

                    3'b010:
                        alu_op = 4'b0100;       // SLT

                    3'b011:
                        alu_op = 4'b0101;       // SLTU

                    3'b100:
                        alu_op = 4'b0011;       // XOR

                    3'b101: begin
                        if (funct7[5])
                            alu_op = 4'b1000;   // SRA
                        else
                            alu_op = 4'b0111;   // SRL
                    end

                    3'b110:
                        alu_op = 4'b0010;       // OR

                    3'b111:
                        alu_op = 4'b1001;       // AND

                    default:
                        alu_op = 4'b0000;

                endcase
            end


            // =====================================================
            // I-TYPE ALU
            // =====================================================
            OP_I_TYPE: begin

                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                wb_sel    = 2'b00;

                case (funct3)

                    3'b000:
                        alu_op = 4'b0000;       // ADDI

                    3'b010:
                        alu_op = 4'b0100;       // SLTI

                    3'b011:
                        alu_op = 4'b0101;       // SLTIU

                    3'b100:
                        alu_op = 4'b0011;       // XORI

                    3'b110:
                        alu_op = 4'b0010;       // ORI

                    3'b111:
                        alu_op = 4'b1001;       // ANDI

                    3'b001:
                        alu_op = 4'b0110;       // SLLI

                    3'b101: begin
                        if (funct7[5])
                            alu_op = 4'b1000;   // SRAI
                        else
                            alu_op = 4'b0111;   // SRLI
                    end

                    default:
                        alu_op = 4'b0000;

                endcase
            end


            // =====================================================
            // LOAD
            // =====================================================
            OP_LOAD: begin

                reg_write    = 1'b1;
                alu_src_a    = 2'b00;
                alu_src_b    = 2'b01;
                wb_sel       = 2'b01;

                mem_read     = 1'b1;
                alu_op       = 4'b0000;

                case (funct3)

                    3'b000: begin
                        mem_size     = 3'b000;
                        mem_unsigned = 1'b0;   // LB
                    end

                    3'b001: begin
                        mem_size     = 3'b001;
                        mem_unsigned = 1'b0;   // LH
                    end

                    3'b010: begin
                        mem_size     = 3'b010;
                        mem_unsigned = 1'b0;   // LW
                    end

                    3'b100: begin
                        mem_size     = 3'b000;
                        mem_unsigned = 1'b1;   // LBU
                    end

                    3'b101: begin
                        mem_size     = 3'b001;
                        mem_unsigned = 1'b1;   // LHU
                    end

                    default: begin
                        mem_size     = 3'b010;
                        mem_unsigned = 1'b0;
                    end

                endcase
            end


            // =====================================================
            // STORE
            // =====================================================
            OP_STORE: begin

                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                mem_write = 1'b1;
                alu_op    = 4'b0000;

                case (funct3)

                    3'b000:
                        mem_size = 3'b000;     // SB

                    3'b001:
                        mem_size = 3'b001;     // SH

                    3'b010:
                        mem_size = 3'b010;     // SW

                    default:
                        mem_size = 3'b010;

                endcase
            end


            // =====================================================
            // BRANCH
            // =====================================================
            OP_BRANCH: begin

                branch      = 1'b1;
                branch_type = funct3;

                alu_src_a   = 2'b00;
                alu_src_b   = 2'b00;
                alu_op      = 4'b0001;         // SUB

            end


            // =====================================================
            // LUI
            // =====================================================
            OP_LUI: begin

                reg_write = 1'b1;
                alu_src_a = 2'b10;
                alu_src_b = 2'b01;
                wb_sel    = 2'b00;
                alu_op    = 4'b0000;

            end


            // =====================================================
            // AUIPC
            // =====================================================
            OP_AUIPC: begin

                reg_write = 1'b1;
                alu_src_a = 2'b01;
                alu_src_b = 2'b01;
                wb_sel    = 2'b00;
                alu_op    = 4'b0000;

            end


            // =====================================================
            // JAL
            // =====================================================
            OP_JAL: begin

                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b0;
                wb_sel    = 2'b10;

            end


            // =====================================================
            // JALR
            // =====================================================
            OP_JALR: begin

                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                wb_sel    = 2'b10;

                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op    = 4'b0000;

            end


            // =====================================================
            // FENCE
            // =====================================================
            OP_MISC: begin
                // Simplified as NOP
            end


            // =====================================================
            // ECALL / EBREAK
            // =====================================================
            OP_SYSTEM: begin
                trap_flag = 1'b1;
            end


            // =====================================================
            // UNKNOWN OPCODE
            // =====================================================
            default: begin
                // Safe NOP-like behavior
            end

        endcase
    end

endmodule