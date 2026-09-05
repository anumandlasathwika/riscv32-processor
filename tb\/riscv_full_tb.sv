`timescale 1ns / 1ps

module riscv_top_tb;

    logic clk;
    logic rst_n;
    logic [31:0] pc;
    logic trap_flag;

    integer pass_count;
    integer fail_count;

    // ============================================================
    // DUT
    // ============================================================

    riscv_top #(
        .MEM_DEPTH(64)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .pc        (pc),
        .trap_flag (trap_flag)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // HELPER TASK
    // ============================================================

    task check_reg;
        input integer reg_num;
        input [31:0] expected;
        input [127:0] name;

        begin
            if (dut.u_datapath.u_regfile.registers[reg_num] == expected) begin
                $display("[PASS] %s = %h", name,
                         dut.u_datapath.u_regfile.registers[reg_num]);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] %s = %h, expected %h",
                         name,
                         dut.u_datapath.u_regfile.registers[reg_num],
                         expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

    $dumpfile("riscv_full.vcd");
    $dumpvars(0, riscv_top_tb);

    pass_count = 0;
    fail_count = 0;

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        rst_n = 1'b0;

        #20;

        // ========================================================
        // TEST 1: BRANCHES
        // ========================================================

        // 0: ADDI x1,x0,5
        dut.u_instruction_memory.mem[0] = 32'h00500093;

        // 1: ADDI x2,x0,5
        dut.u_instruction_memory.mem[1] = 32'h00500113;

        // 2: BEQ x1,x2,+8
        dut.u_instruction_memory.mem[2] = 32'h00208463;

        // 3: skipped
        dut.u_instruction_memory.mem[3] = 32'h06300513;

        // 4: ADDI x10,x0,10
        dut.u_instruction_memory.mem[4] = 32'h00A00513;

        // 5: BNE x1,x2,+8
        dut.u_instruction_memory.mem[5] = 32'h00209463;

        // 6: ADDI x11,x0,11
        dut.u_instruction_memory.mem[6] = 32'h00B00593;

        // 7: ADDI x3,x0,1
        dut.u_instruction_memory.mem[7] = 32'h00100193;

        // 8: ADDI x4,x0,2
        dut.u_instruction_memory.mem[8] = 32'h00200213;

        // 9: BLT x3,x4,+8
        dut.u_instruction_memory.mem[9] = 32'h0041C463;

        // 10: skipped
        dut.u_instruction_memory.mem[10] = 32'h06300613;

        // 11: ADDI x12,x0,12
        dut.u_instruction_memory.mem[11] = 32'h00C00613;

        // 12: BGE x4,x3,+8
        dut.u_instruction_memory.mem[12] = 32'h00325463;

        // 13: skipped
        dut.u_instruction_memory.mem[13] = 32'h06300693;

        // 14: ADDI x13,x0,13
        dut.u_instruction_memory.mem[14] = 32'h00D00693;

        // 15: BLTU x3,x4,+8
        dut.u_instruction_memory.mem[15] = 32'h0041E463;

        // 16: skipped
        dut.u_instruction_memory.mem[16] = 32'h06300713;

        // 17: ADDI x14,x0,14
        dut.u_instruction_memory.mem[17] = 32'h00E00713;

        // 18: BGEU x4,x3,+8
        dut.u_instruction_memory.mem[18] = 32'h00327463;

        // 19: skipped
        dut.u_instruction_memory.mem[19] = 32'h06300793;

        // 20: ADDI x15,x0,15
        dut.u_instruction_memory.mem[20] = 32'h00F00793;

        // ========================================================
        // TEST 2: JAL
        // ========================================================

        // 21: JAL x16,+8
        dut.u_instruction_memory.mem[21] = 32'h0080086F;

        // 22: skipped
        dut.u_instruction_memory.mem[22] = 32'h06300813;

        // 23: ADDI x17,x0,17
        dut.u_instruction_memory.mem[23] = 32'h01100893;

        // ========================================================
        // TEST 3: JALR
        // ========================================================

        // 24: ADDI x18,x0,116
        dut.u_instruction_memory.mem[24] = 32'h07400913;

        // 25: JALR x19,x18,0
        dut.u_instruction_memory.mem[25] = 32'h000909E7;

        // 26: skipped
        dut.u_instruction_memory.mem[26] = 32'h06300A13;

        // 27: skipped
        dut.u_instruction_memory.mem[27] = 32'h06300A93;

        // 28: skipped
        dut.u_instruction_memory.mem[28] = 32'h06300B13;

        // 29: target
        // ADDI x20,x0,20
        dut.u_instruction_memory.mem[29] = 32'h01400A13;

        // ========================================================
        // TEST 4: BYTE MEMORY
        // ========================================================

        // 30: ADDI x21,x0,171 = 0xAB
        dut.u_instruction_memory.mem[30] = 32'h0AB00A93;

        // 31: SB x21,0(x0)
        dut.u_instruction_memory.mem[31] = 32'h01500023;

        // 32: LB x22,0(x0)
        dut.u_instruction_memory.mem[32] = 32'h00000B03;

        // 33: LBU x23,0(x0)
        dut.u_instruction_memory.mem[33] = 32'h00004B83;

        // ========================================================
        // TEST 5: HALFWORD MEMORY
        // ========================================================

        // 34: LUI x24,0x1
        // x24 = 0x00001000
        dut.u_instruction_memory.mem[34] = 32'h00001C37;

        // 35: ADDI x24,x24,0x234
        // x24 = 0x00001234
        dut.u_instruction_memory.mem[35] = 32'h234C0C13;

        // 36: SH x24,2(x0)
        dut.u_instruction_memory.mem[36] = 32'h01801123;

        // 37: LH x25,2(x0)
        dut.u_instruction_memory.mem[37] = 32'h00201C83;

        // 38: LHU x26,2(x0)
        dut.u_instruction_memory.mem[38] = 32'h00205D03;

        // ========================================================
        // TEST 6: WORD MEMORY
        // ========================================================

        // 39: SW x20,4(x0)
        dut.u_instruction_memory.mem[39] = 32'h01402223;

        // 40: LW x27,4(x0)
        dut.u_instruction_memory.mem[40] = 32'h00402D83;

        // ========================================================
        // SYSTEM INSTRUCTIONS
        // ========================================================

        // 41: FENCE
        dut.u_instruction_memory.mem[41] = 32'h0000000F;

        // 42: ECALL
        dut.u_instruction_memory.mem[42] = 32'h00000073;

        // 43: EBREAK
        dut.u_instruction_memory.mem[43] = 32'h00100073;

        // 44: NOP
        dut.u_instruction_memory.mem[44] = 32'h00000013;

        // ========================================================
        // RELEASE RESET
        // ========================================================

        rst_n = 1'b1;

        #500;

        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("================================================");
        $display("       REMAINING RV32I CPU TEST");
        $display("================================================");

        check_reg(10, 32'd10, "BEQ");
        check_reg(11, 32'd11, "BNE");
        check_reg(12, 32'd12, "BLT");
        check_reg(13, 32'd13, "BGE");
        check_reg(14, 32'd14, "BLTU");
        check_reg(15, 32'd15, "BGEU");

        check_reg(16, 32'd88, "JAL link");

        check_reg(19, 32'd104, "JALR link");
        check_reg(20, 32'd20, "JALR target");

        check_reg(22, 32'hFFFFFFAB, "LB");
        check_reg(23, 32'h000000AB, "LBU");

        check_reg(25, 32'h00001234, "LH");
        check_reg(26, 32'h00001234, "LHU");

        check_reg(27, 32'h00000014, "LW");

        check_reg(0, 32'h00000000, "x0");

        // ========================================================
        // SUMMARY
        // ========================================================

        $display("");
        $display("================================================");
        $display("       RV32I REMAINING TEST RESULTS");
        $display("================================================");

        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);

        if (fail_count == 0)
            $display("ALL REMAINING CPU TESTS PASSED");
        else
            $display("SOME CPU TESTS FAILED");

        $display("================================================");

        $finish;
    end

endmodule