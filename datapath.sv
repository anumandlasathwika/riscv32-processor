`timescale 1ns / 1ps

module datapath #(
    parameter MEM_DEPTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,

    // Instruction Memory Interface
    input  logic [31:0] instr,
    output logic [31:0] pc_out,

    // Data Memory Interface
    output logic        mem_read,
    output logic        mem_write,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_write_data,
    input  logic [31:0] dmem_read_data,

    // Data Memory Control
    output logic [2:0]  dmem_size,
    output logic        dmem_unsigned,

    // Trap / Status
    output logic        trap_flag
);

    // ============================================================
    // INSTRUCTION FIELDS
    // ============================================================

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];


    // ============================================================
    // CONTROL SIGNALS
    // ============================================================

    logic        reg_write;
    logic [1:0]  alu_src_a;
    logic [1:0]  alu_src_b;
    logic [3:0]  alu_op;
    logic [1:0]  wb_sel;

    logic        branch;
    logic [2:0]  branch_type;
    logic        jump;
    logic        jalr;

    logic [2:0]  mem_size;
    logic        mem_unsigned;


    // ============================================================
    // IMMEDIATE GENERATOR
    // ============================================================

    logic [31:0] imm;

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_out (imm)
    );


    // ============================================================
    // CONTROL UNIT
    // ============================================================

    control_unit u_control (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       ({1'b0, funct7}),

        .reg_write    (reg_write),
        .alu_src_a    (alu_src_a),
        .alu_src_b    (alu_src_b),
        .alu_op       (alu_op),
        .wb_sel       (wb_sel),

        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .mem_size     (mem_size),
        .mem_unsigned (mem_unsigned),

        .branch       (branch),
        .branch_type  (branch_type),
        .jump          (jump),
        .jalr         (jalr),

        .trap_flag    (trap_flag)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    logic [31:0] reg_rdata1;
    logic [31:0] reg_rdata2;
    logic [31:0] writeback_data;

    register_file u_regfile (
        .clk          (clk),

        // register_file reset is active-high
        // datapath reset is active-low
        .reset        (~rst_n),

        .write_enable (reg_write),
        .write_addr   (rd),
        .write_data   (writeback_data),

        .read_addr1   (rs1),
        .read_addr2   (rs2),

        .read_data1   (reg_rdata1),
        .read_data2   (reg_rdata2)
    );


    // ============================================================
    // ALU INPUTS
    // ============================================================

    logic [31:0] alu_in_a;
    logic [31:0] alu_in_b;
    logic [31:0] alu_result;


    always_comb begin

        case (alu_src_a)

            2'b00:
                alu_in_a = reg_rdata1;

            2'b01:
                alu_in_a = pc_out;

            2'b10:
                alu_in_a = 32'h00000000;

            default:
                alu_in_a = 32'h00000000;

        endcase

    end


    always_comb begin

        case (alu_src_b)

            2'b00:
                alu_in_b = reg_rdata2;

            2'b01:
                alu_in_b = imm;

            default:
                alu_in_b = 32'h00000000;

        endcase

    end


    // ============================================================
    // ALU
    // ============================================================

    alu u_alu (
        .A           (alu_in_a),
        .B           (alu_in_b),
        .ALU_control (alu_op),
        .result      (alu_result)
    );


    // ============================================================
    // DATA MEMORY CONNECTION
    // ============================================================

    assign dmem_addr       = alu_result;
    assign dmem_write_data = reg_rdata2;
    assign dmem_size       = mem_size;
    assign dmem_unsigned   = mem_unsigned;


    // ============================================================
    // BRANCH COMPARISON
    // ============================================================

    logic take_branch;

    always_comb begin

        take_branch = 1'b0;

        if (branch) begin

            case (branch_type)

                // BEQ
                3'b000:
                    take_branch = (reg_rdata1 == reg_rdata2);

                // BNE
                3'b001:
                    take_branch = (reg_rdata1 != reg_rdata2);

                // BLT
                3'b100:
                    take_branch =
                        ($signed(reg_rdata1) < $signed(reg_rdata2));

                // BGE
                3'b101:
                    take_branch =
                        ($signed(reg_rdata1) >= $signed(reg_rdata2));

                // BLTU
                3'b110:
                    take_branch =
                        (reg_rdata1 < reg_rdata2);

                // BGEU
                3'b111:
                    take_branch =
                        (reg_rdata1 >= reg_rdata2);

                default:
                    take_branch = 1'b0;

            endcase

        end

    end


    // ============================================================
    // PROGRAM COUNTER
    // ============================================================

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic [31:0] jump_target;
    logic [31:0] pc_next;

    assign pc_plus_4    = pc_out + 32'd4;

    assign branch_target = pc_out + imm;

    assign jump_target =
        jalr
        ? ((reg_rdata1 + imm) & 32'hFFFFFFFE)
        : (pc_out + imm);


    always_comb begin

        if (jump)
            pc_next = jump_target;

        else if (take_branch)
            pc_next = branch_target;

        else
            pc_next = pc_plus_4;

    end


    // ============================================================
    // PROGRAM COUNTER MODULE
    // ============================================================

    pc u_pc (
        .clk    (clk),
        .reset  (~rst_n),
        .pc_in  (pc_next),
        .pc_out (pc_out)
    );


    // ============================================================
    // WRITEBACK MULTIPLEXER
    // ============================================================

    always_comb begin

        case (wb_sel)

            // ALU result
            2'b00:
                writeback_data = alu_result;

            // Data memory result
            2'b01:
                writeback_data = dmem_read_data;

            // PC + 4
            2'b10:
                writeback_data = pc_plus_4;

            default:
                writeback_data = 32'h00000000;

        endcase

    end

endmodule