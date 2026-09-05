`timescale 1ns/1ps

module imm_gen_tb;

    logic [31:0] instr;
    logic [31:0] imm_out;

    integer pass_count;
    integer fail_count;

    imm_gen dut (
        .instr(instr),
        .imm_out(imm_out)
    );

    task automatic check_imm;
        input [31:0] instruction;
        input [31:0] expected;
        input [127:0] name;

        begin
            instr = instruction;
            #1;

            if (imm_out === expected) begin
                $display("[PASS] %0s", name);
                $display("       Instruction : %h", instruction);
                $display("       Immediate   : %h", imm_out);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] %0s", name);
                $display("       Instruction : %h", instruction);
                $display("       Expected    : %h", expected);
                $display("       Got         : %h", imm_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;
        instr = 32'b0;

        // =====================================================
        // I-TYPE TESTS
        // =====================================================

        // ADDI x5, x1, 12
        check_imm(
            32'h00C08293,
            32'h0000000C,
            "I-type ADDI +12"
        );

        // LW x6, -8(x2)
        check_imm(
            32'hFF812303,
            32'hFFFFFFF8,
            "I-type LW -8"
        );

        // JALR x1, -4(x3)
        check_imm(
            32'hFFC180E7,
            32'hFFFFFFFC,
            "I-type JALR -4"
        );

        // =====================================================
        // S-TYPE TESTS
        // =====================================================

        // SW x5, 20(x4)
        check_imm(
            32'h00522A23,
            32'h00000014,
            "S-type SW +20"
        );

        // SW x5, -12(x4)
        check_imm(
            32'hFE522A23,
            32'hFFFFFFF4,
            "S-type SW -12"
        );

        // =====================================================
        // B-TYPE TESTS
        // =====================================================

        // BEQ x6, x7, +16
        check_imm(
            32'h00730863,
            32'h00000010,
            "B-type BEQ +16"
        );

        // BLT x6, x7, -16
        check_imm(
            32'hFE7348E3,
            32'hFFFFFFF0,
            "B-type BLT -16"
        );

        // =====================================================
        // U-TYPE TESTS
        // =====================================================

        // LUI x8, 0x12345
        check_imm(
            32'h12345437,
            32'h12345000,
            "U-type LUI"
        );

        // AUIPC x9, 0xFFFFF
        check_imm(
            32'hFFFFF497,
            32'hFFFFF000,
            "U-type AUIPC"
        );

        // =====================================================
        // J-TYPE TESTS
        // =====================================================

        // JAL x1, +2048
        check_imm(
            32'h001000EF,
            32'h00000800,
            "J-type JAL +2048"
        );

        // JAL x1, -2048
        check_imm(
            32'h801FF0EF,
            32'hFFFFF800,
            "J-type JAL -2048"
        );

        // =====================================================
        // INVALID / NO-IMMEDIATE TEST
        // =====================================================

        // ADD x1, x2, x3
        // R-type has no immediate.
        check_imm(
            32'h003100B3,
            32'h00000000,
            "R-type ADD has no immediate"
        );

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("==============================================");
        $display("RV32I IMMEDIATE GENERATOR TEST RESULTS");
        $display("==============================================");
        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);
        $display("==============================================");

        if (fail_count == 0)
            $display("ALL IMMEDIATE GENERATOR TESTS PASSED");
        else
            $display("IMMEDIATE GENERATOR TESTS FAILED");

        $display("==============================================");

        $finish;

    end

endmodule