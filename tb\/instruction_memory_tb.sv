`timescale 1ns / 1ps

module instruction_memory_tb;

    logic [31:0] addr;
    logic [31:0] instr;

    int pass_count = 0;
    int fail_count = 0;

    // Instantiate Unit Under Test
    instruction_memory #(
        .MEM_DEPTH(64)
    ) uut (
        .addr(addr),
        .instr(instr)
    );

    // Helper task to check read values
    task check_instr(input string test_name, input logic [31:0] expected_instr);
        #10;
        if (instr === expected_instr) begin
            $display("[PASS] %-35s | addr = 0x%8h | instr = 0x%8h", test_name, addr, instr);
            pass_count++;
        end else begin
            $display("[FAIL] %-35s | addr = 0x%8h | Expected 0x%8h, Got 0x%8h", test_name, addr, expected_instr, instr);
            fail_count++;
        end
    endtask

    initial begin
        $display("==================================================");
        $display("INSTRUCTION MEMORY INDEPENDENT VERIFICATION");
        $display("==================================================");

        // Pre-load instruction memory array with test RV32I instructions
        uut.mem[0] = 32'h00500093; // ADDI x1, x0, 5    (addr 0x00)
        uut.mem[1] = 32'h00a00113; // ADDI x2, x0, 10   (addr 0x04)
        uut.mem[2] = 32'h002081b3; // ADD  x3, x1, x2   (addr 0x08)
        uut.mem[3] = 32'h00312023; // SW   x3, 0(x2)    (addr 0x0C)
        uut.mem[4] = 32'h00012203; // LW   x4, 0(x2)    (addr 0x10)

        // 1. Test Fetching Word Address 0 (0x00000000)
        addr = 32'h00000000;
        check_instr("1. Fetch Addr 0x00000000", 32'h00500093);

        // 2. Test Fetching Word Address 1 (0x00000004)
        addr = 32'h00000004;
        check_instr("2. Fetch Addr 0x00000004", 32'h00a00113);

        // 3. Test Fetching Word Address 2 (0x00000008)
        addr = 32'h00000008;
        check_instr("3. Fetch Addr 0x00000008", 32'h002081b3);

        // 4. Test Fetching Word Address 3 (0x0000000C)
        addr = 32'h0000000c;
        check_instr("4. Fetch Addr 0x0000000C", 32'h00312023);

        // 5. Test Fetching Word Address 4 (0x00000010)
        addr = 32'h00000010;
        check_instr("5. Fetch Addr 0x00000010", 32'h00012203);

        // 6. Test Uninitialized / In-Bounds Memory Location (Addr 0x00000014 -> Word 5)
        addr = 32'h00000014;
        check_instr("6. Uninitialized In-Bounds Addr", 32'h00000000);

        // 7. Test Out-Of-Bounds Address (Addr 0x00000400 -> Word 256 > MEM_DEPTH)
        addr = 32'h00000400;
        check_instr("7. Out-Of-Bounds Memory Access", 32'h00000000);

        $display("==================================================");
        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);
        $display("==================================================");

        if (fail_count == 0)
            $display("ALL INSTRUCTION MEMORY TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        $finish;
    end

endmodule