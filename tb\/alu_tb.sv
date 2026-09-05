`timescale 1ns / 1ps

module alu_tb;

    logic [31:0] A;
    logic [31:0] B;
    logic [3:0]  ALU_control;
    logic [31:0] result;

    alu dut (
        .A(A),
        .B(B),
        .ALU_control(ALU_control),
        .result(result)
    );

    integer passed = 0;
    integer failed = 0;

    task test;
        input [3:0] ctrl;
        input [31:0] a;
        input [31:0] b;
        input [31:0] expected;

        begin
            A = a;
            B = b;
            ALU_control = ctrl;
            #10;

            if (result === expected) begin
                passed = passed + 1;
                $display("PASS: ctrl=%b A=%h B=%h result=%h",
                         ctrl, a, b, result);
            end
            else begin
                failed = failed + 1;
                $display("FAIL: ctrl=%b A=%h B=%h expected=%h got=%h",
                         ctrl, a, b, expected, result);
            end
        end
    endtask

    initial begin

        // ADD
        test(4'b0000, 32'd5, 32'd3, 32'd8);

        // SUB
        test(4'b0001, 32'd5, 32'd3, 32'd2);

        // OR
        test(4'b0010, 32'h5, 32'h3, 32'h7);

        // XOR
        test(4'b0011, 32'h5, 32'h3, 32'h6);

        // SLT signed
        test(4'b0100, 32'hFFFFFFFF, 32'd1, 32'd1);

        // SLTU unsigned
        test(4'b0101, 32'd1, 32'hFFFFFFFF, 32'd1);

        // SLL
        test(4'b0110, 32'd1, 32'd3, 32'd8);

        // SRL
        test(4'b0111, 32'd16, 32'd2, 32'd4);

        // SRA
        test(4'b1000, 32'hFFFFFFF0, 32'd2, 32'hFFFFFFFC);

        // AND
        test(4'b1001, 32'h5, 32'h3, 32'h1);

        $display("");
        $display("================================");
        $display("Tests passed : %0d", passed);
        $display("Tests failed : %0d", failed);
        $display("================================");

        if (failed == 0)
            $display("ALL ALU TESTS PASSED!");
        else
            $display("ALU TESTS FAILED!");

        $finish;
    end

endmodule