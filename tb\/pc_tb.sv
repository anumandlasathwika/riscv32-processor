`timescale 1ns / 1ps

module pc_tb;

    logic        clk;
    logic        reset;
    logic [31:0] pc_in;
    logic [31:0] pc_out;

    int pass_count = 0;
    int fail_count = 0;

    // Instantiate Unit Under Test
    pc uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Helper Verification Task
    task check_pc(input string test_name, input logic [31:0] expected_pc);
        if (pc_out === expected_pc) begin
            $display("[PASS] %-30s | pc_out = 0x%8h", test_name, pc_out);
            pass_count++;
        end else begin
            $display("[FAIL] %-30s | Expected 0x%8h, Got 0x%8h", test_name, expected_pc, pc_out);
            fail_count++;
        end
    endtask

    initial begin
        // Initialize Signals
        clk   = 0;
        reset = 0;
        pc_in = 32'h00000000;

        $display("==================================================");
        $display("PROGRAM COUNTER INDEPENDENT VERIFICATION");
        $display("==================================================");

        // Test 1: Assert Reset
        reset = 1;
        #10; // Wait for active clock edge
        check_pc("1. Active Reset", 32'h00000000);

        // Test 2: Deassert Reset and Apply First PC Value
        reset = 0;
        pc_in = 32'h00000004;
        #10;
        check_pc("2. Update PC to 0x00000004", 32'h00000004);

        // Test 3: Sequential PC Updates (Sequential Fetching)
        pc_in = 32'h00000008;
        #10;
        check_pc("3. Update PC to 0x00000008", 32'h00000008);

        pc_in = 32'h0000000C;
        #10;
        check_pc("4. Update PC to 0x0000000C", 32'h0000000c);

        // Test 4: Jump Target (Branch or JAL Target)
        pc_in = 32'h00001000;
        #10;
        check_pc("5. Jump Target 0x00001000", 32'h00001000);

        // Test 5: Mid-execution Asynchronous/Synchronous Reset
        reset = 1;
        #10;
        check_pc("6. Mid-Execution Reset", 32'h00000000);

        // Test 6: Resume Post-Reset
        reset = 0;
        pc_in = 32'h00000004;
        #10;
        check_pc("7. Resume Fetching Post-Reset", 32'h00000004);

        $display("==================================================");
        $display("Tests passed : %0d", pass_count);
        $display("Tests failed : %0d", fail_count);
        $display("==================================================");

        if (fail_count == 0)
            $display("ALL PROGRAM COUNTER TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        $finish;
    end

endmodule