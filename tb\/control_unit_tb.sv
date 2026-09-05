`timescale 1ns / 1ps

module control_unit_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [7:0] funct7;

    logic       reg_write;
    logic [1:0] alu_src_a;
    logic [1:0] alu_src_b;
    logic [3:0] alu_op;
    logic [1:0] wb_sel;
    logic       mem_read;
    logic       mem_write;
    logic [2:0] mem_size;
    logic       mem_unsigned;
    logic       branch;
    logic [2:0] branch_type;
    logic       jump;
    logic       jalr;
    logic       trap_flag;

    int pass_count = 0;
    int fail_count = 0;

    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_op(alu_op),
        .wb_sel(wb_sel),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),
        .branch(branch),
        .branch_type(branch_type),
        .jump(jump),
        .jalr(jalr),
        .trap_flag(trap_flag)
    );

    task test_inst(
        input string name,
        input [6:0]  op,
        input [2:0]  f3,
        input [7:0]  f7,
        input        exp_reg_w,
        input [1:0]  exp_src_a,
        input [1:0]  exp_src_b,
        input [3:0]  exp_alu_op,
        input [1:0]  exp_wb,
        input        exp_m_read,
        input        exp_m_write,
        input        exp_branch,
        input        exp_jump,
        input        exp_jalr,
        input        exp_trap
    );
        opcode = op;
        funct3 = f3;
        funct7 = f7;
        #1;

        if (reg_write === exp_reg_w && alu_src_a === exp_src_a && alu_src_b === exp_src_b &&
            alu_op === exp_alu_op && wb_sel === exp_wb && mem_read === exp_m_read &&
            mem_write === exp_m_write && branch === exp_branch && jump === exp_jump &&
            jalr === exp_jalr && trap_flag === exp_trap) begin
            $display("[PASS] %-10s | Decoded correctly", name);
            pass_count++;
        end else begin
            $display("[FAIL] %-10s | Signal mismatch", name);
            fail_count++;
        end
    endtask

    initial begin
        $display("========================================");
        $display("RV32I CONTROL UNIT TESTBENCH");
        $display("========================================");

        // R-Type Instructions
        test_inst("ADD",    7'b0110011, 3'b000, 8'b00000000, 1, 0, 0, 4'b0000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SUB",    7'b0110011, 3'b000, 8'b00100000, 1, 0, 0, 4'b0001, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLL",    7'b0110011, 3'b001, 8'b00000000, 1, 0, 0, 4'b0110, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLT",    7'b0110011, 3'b010, 8'b00000000, 1, 0, 0, 4'b0100, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLTU",   7'b0110011, 3'b011, 8'b00000000, 1, 0, 0, 4'b0101, 0, 0, 0, 0, 0, 0, 0);
        test_inst("XOR",    7'b0110011, 3'b100, 8'b00000000, 1, 0, 0, 4'b0011, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SRL",    7'b0110011, 3'b101, 8'b00000000, 1, 0, 0, 4'b0111, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SRA",    7'b0110011, 3'b101, 8'b00100000, 1, 0, 0, 4'b1000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("OR",     7'b0110011, 3'b110, 8'b00000000, 1, 0, 0, 4'b0010, 0, 0, 0, 0, 0, 0, 0);
        test_inst("AND",    7'b0110011, 3'b111, 8'b00000000, 1, 0, 0, 4'b1001, 0, 0, 0, 0, 0, 0, 0);

        // I-Type Instructions
        test_inst("ADDI",   7'b0010011, 3'b000, 8'b00000000, 1, 0, 1, 4'b0000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLTI",   7'b0010011, 3'b010, 8'b00000000, 1, 0, 1, 4'b0100, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLTIU",  7'b0010011, 3'b011, 8'b00000000, 1, 0, 1, 4'b0101, 0, 0, 0, 0, 0, 0, 0);
        test_inst("XORI",   7'b0010011, 3'b100, 8'b00000000, 1, 0, 1, 4'b0011, 0, 0, 0, 0, 0, 0, 0);
        test_inst("ORI",    7'b0010011, 3'b110, 8'b00000000, 1, 0, 1, 4'b0010, 0, 0, 0, 0, 0, 0, 0);
        test_inst("ANDI",   7'b0010011, 3'b111, 8'b00000000, 1, 0, 1, 4'b1001, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SLLI",   7'b0010011, 3'b001, 8'b00000000, 1, 0, 1, 4'b0110, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SRLI",   7'b0010011, 3'b101, 8'b00000000, 1, 0, 1, 4'b0111, 0, 0, 0, 0, 0, 0, 0);
        test_inst("SRAI",   7'b0010011, 3'b101, 8'b00100000, 1, 0, 1, 4'b1000, 0, 0, 0, 0, 0, 0, 0);

        // Loads
        test_inst("LB",     7'b0000011, 3'b000, 8'b00000000, 1, 0, 1, 4'b0000, 1, 1, 0, 0, 0, 0, 0);
        test_inst("LH",     7'b0000011, 3'b001, 8'b00000000, 1, 0, 1, 4'b0000, 1, 1, 0, 0, 0, 0, 0);
        test_inst("LW",     7'b0000011, 3'b010, 8'b00000000, 1, 0, 1, 4'b0000, 1, 1, 0, 0, 0, 0, 0);
        test_inst("LBU",    7'b0000011, 3'b100, 8'b00000000, 1, 0, 1, 4'b0000, 1, 1, 0, 0, 0, 0, 0);
        test_inst("LHU",    7'b0000011, 3'b101, 8'b00000000, 1, 0, 1, 4'b0000, 1, 1, 0, 0, 0, 0, 0);

        // Stores
        test_inst("SB",     7'b0100011, 3'b000, 8'b00000000, 0, 0, 1, 4'b0000, 0, 0, 1, 0, 0, 0, 0);
        test_inst("SH",     7'b0100011, 3'b001, 8'b00000000, 0, 0, 1, 4'b0000, 0, 0, 1, 0, 0, 0, 0);
        test_inst("SW",     7'b0100011, 3'b010, 8'b00000000, 0, 0, 1, 4'b0000, 0, 0, 1, 0, 0, 0, 0);

        // Branches
        test_inst("BEQ",    7'b1100011, 3'b000, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);
        test_inst("BNE",    7'b1100011, 3'b001, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);
        test_inst("BLT",    7'b1100011, 3'b100, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);
        test_inst("BGE",    7'b1100011, 3'b101, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);
        test_inst("BLTU",   7'b1100011, 3'b110, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);
        test_inst("BGEU",   7'b1100011, 3'b111, 8'b00000000, 0, 0, 0, 4'b0001, 0, 0, 0, 1, 0, 0, 0);

        // Upper / Jumps
        test_inst("LUI",    7'b0110111, 3'b000, 8'b00000000, 1, 2, 1, 4'b0000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("AUIPC",  7'b0010111, 3'b000, 8'b00000000, 1, 1, 1, 4'b0000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("JAL",    7'b1101111, 3'b000, 8'b00000000, 1, 0, 0, 4'b0000, 2, 0, 0, 0, 1, 0, 0);
        test_inst("JALR",   7'b1100111, 3'b000, 8'b00000000, 1, 0, 1, 4'b0000, 2, 0, 0, 0, 1, 1, 0);

        // System
        test_inst("FENCE",  7'b0001111, 3'b000, 8'b00000000, 0, 0, 0, 4'b0000, 0, 0, 0, 0, 0, 0, 0);
        test_inst("ECALL",  7'b1110011, 3'b000, 8'b00000000, 0, 0, 0, 4'b0000, 0, 0, 0, 0, 0, 0, 1);
        test_inst("EBREAK", 7'b1110011, 3'b000, 8'b00000001, 0, 0, 0, 4'b0000, 0, 0, 0, 0, 0, 0, 1);

        $display("========================================");
        $display("RV32I CONTROL UNIT TEST RESULTS");
        $display("========================================");
        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);
        $display("========================================");

        if (fail_count == 0)
            $display("ALL 40 RV32I CONTROL UNIT TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule