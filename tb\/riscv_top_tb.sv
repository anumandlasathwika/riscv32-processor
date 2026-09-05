`timescale 1ns / 1ps

module riscv_top_tb;

    logic clk;
    logic rst_n;

    logic [31:0] pc;
    logic        trap_flag;

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
    // TEST PROGRAM
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        rst_n = 1'b0;

        #20;

        // --------------------------------------------------------
        // PROGRAM
        // --------------------------------------------------------
        //
        // 0  ADDI  x1,  x0, 10
        // 1  ADDI  x2,  x0, 20
        // 2  ADD   x3,  x1, x2
        // 3  SUB   x4,  x2, x1
        // 4  AND   x5,  x1, x2
        // 5  OR    x6,  x1, x2
        // 6  XOR   x7,  x1, x2
        // 7  SLT   x8,  x1, x2
        // 8  SLTU  x9,  x1, x2
        // 9  SLL   x10, x1, x2
        // 10 SRL   x11, x2, x1
        // 11 SRA   x12, x2, x1
        //
        // 12 SLTI  x13, x1, 15
        // 13 SLTIU x14, x1, 15
        // 14 XORI  x15, x1, 15
        // 15 ORI   x16, x1, 1
        // 16 ANDI  x17, x2, 3
        // 17 SLLI  x18, x1, 2
        // 18 SRLI  x19, x2, 1
        //
        // 19 LUI   x20, 0x12345
        // 20 AUIPC x21, 1
        //
        // 21 SW    x3, 0(x1)
        // 22 LW    x22, 0(x1)
        //
        // 23 NOP
        // 24 NOP
        // --------------------------------------------------------

        dut.u_instruction_memory.mem[0]  = 32'h00A00093;
        dut.u_instruction_memory.mem[1]  = 32'h01400113;
        dut.u_instruction_memory.mem[2]  = 32'h002081B3;
        dut.u_instruction_memory.mem[3]  = 32'h40110233;
        dut.u_instruction_memory.mem[4]  = 32'h0020F2B3;
        dut.u_instruction_memory.mem[5]  = 32'h0020E333;
        dut.u_instruction_memory.mem[6]  = 32'h0020C3B3;
        dut.u_instruction_memory.mem[7]  = 32'h0020A433;
        dut.u_instruction_memory.mem[8]  = 32'h0020B4B3;
        dut.u_instruction_memory.mem[9]  = 32'h00209533;
        dut.u_instruction_memory.mem[10] = 32'h001155B3;
        dut.u_instruction_memory.mem[11] = 32'h40115633;

        dut.u_instruction_memory.mem[12] = 32'h00F0A693;
        dut.u_instruction_memory.mem[13] = 32'h00F0B713;
        dut.u_instruction_memory.mem[14] = 32'h00F0C793;
        dut.u_instruction_memory.mem[15] = 32'h0010E813;
        dut.u_instruction_memory.mem[16] = 32'h00317893;
        dut.u_instruction_memory.mem[17] = 32'h00209913;
        dut.u_instruction_memory.mem[18] = 32'h00115993;

        dut.u_instruction_memory.mem[19] = 32'h12345A37;
        dut.u_instruction_memory.mem[20] = 32'h00001A97;

        dut.u_instruction_memory.mem[21] = 32'h0030A023;
        dut.u_instruction_memory.mem[22] = 32'h0000AB03;

        dut.u_instruction_memory.mem[23] = 32'h00000013;
        dut.u_instruction_memory.mem[24] = 32'h00000013;

        // --------------------------------------------------------
        // RELEASE RESET
        // --------------------------------------------------------

        rst_n = 1'b1;

        // 25 instructions × 10 ns = 250 ns
        #270;

        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("================================================");
        $display("          RISC-V CPU INTEGRATION TEST");
        $display("================================================");

        $display("x1  = %h", dut.u_datapath.u_regfile.registers[1]);
        $display("x2  = %h", dut.u_datapath.u_regfile.registers[2]);
        $display("x3  = %h", dut.u_datapath.u_regfile.registers[3]);
        $display("x4  = %h", dut.u_datapath.u_regfile.registers[4]);
        $display("x5  = %h", dut.u_datapath.u_regfile.registers[5]);
        $display("x6  = %h", dut.u_datapath.u_regfile.registers[6]);
        $display("x7  = %h", dut.u_datapath.u_regfile.registers[7]);
        $display("x8  = %h", dut.u_datapath.u_regfile.registers[8]);
        $display("x9  = %h", dut.u_datapath.u_regfile.registers[9]);
        $display("x10 = %h", dut.u_datapath.u_regfile.registers[10]);
        $display("x11 = %h", dut.u_datapath.u_regfile.registers[11]);
        $display("x12 = %h", dut.u_datapath.u_regfile.registers[12]);
        $display("x13 = %h", dut.u_datapath.u_regfile.registers[13]);
        $display("x14 = %h", dut.u_datapath.u_regfile.registers[14]);
        $display("x15 = %h", dut.u_datapath.u_regfile.registers[15]);
        $display("x16 = %h", dut.u_datapath.u_regfile.registers[16]);
        $display("x17 = %h", dut.u_datapath.u_regfile.registers[17]);
        $display("x18 = %h", dut.u_datapath.u_regfile.registers[18]);
        $display("x19 = %h", dut.u_datapath.u_regfile.registers[19]);
        $display("x20 = %h", dut.u_datapath.u_regfile.registers[20]);
        $display("x21 = %h", dut.u_datapath.u_regfile.registers[21]);
        $display("x22 = %h", dut.u_datapath.u_regfile.registers[22]);

        // ========================================================
        // CHECKS
        // ========================================================

        if (dut.u_datapath.u_regfile.registers[1] == 32'd10)
            $display("[PASS] ADDI x1,x0,10");
        else
            $display("[FAIL] ADDI x1");

        if (dut.u_datapath.u_regfile.registers[2] == 32'd20)
            $display("[PASS] ADDI x2,x0,20");
        else
            $display("[FAIL] ADDI x2");

        if (dut.u_datapath.u_regfile.registers[3] == 32'd30)
            $display("[PASS] ADD x3,x1,x2");
        else
            $display("[FAIL] ADD x3");

        if (dut.u_datapath.u_regfile.registers[4] == 32'd10)
            $display("[PASS] SUB x4,x2,x1");
        else
            $display("[FAIL] SUB x4");

        if (dut.u_datapath.u_regfile.registers[5] == 32'd0)
            $display("[PASS] AND x5,x1,x2");
        else
            $display("[FAIL] AND x5");

        if (dut.u_datapath.u_regfile.registers[6] == 32'd30)
            $display("[PASS] OR x6,x1,x2");
        else
            $display("[FAIL] OR x6");

        if (dut.u_datapath.u_regfile.registers[7] == 32'd30)
            $display("[PASS] XOR x7,x1,x2");
        else
            $display("[FAIL] XOR x7");

        if (dut.u_datapath.u_regfile.registers[8] == 32'd1)
            $display("[PASS] SLT x8,x1,x2");
        else
            $display("[FAIL] SLT x8");

        if (dut.u_datapath.u_regfile.registers[9] == 32'd1)
            $display("[PASS] SLTU x9,x1,x2");
        else
            $display("[FAIL] SLTU x9");

        if (dut.u_datapath.u_regfile.registers[13] == 32'd1)
            $display("[PASS] SLTI x13,x1,15");
        else
            $display("[FAIL] SLTI x13");

        if (dut.u_datapath.u_regfile.registers[14] == 32'd1)
            $display("[PASS] SLTIU x14,x1,15");
        else
            $display("[FAIL] SLTIU x14");

        if (dut.u_datapath.u_regfile.registers[15] == 32'd5)
            $display("[PASS] XORI x15,x1,15");
        else
            $display("[FAIL] XORI x15");

        if (dut.u_datapath.u_regfile.registers[16] == 32'd11)
            $display("[PASS] ORI x16,x1,1");
        else
            $display("[FAIL] ORI x16");

        if (dut.u_datapath.u_regfile.registers[17] == 32'd0)
            $display("[PASS] ANDI x17,x2,3");
        else
            $display("[FAIL] ANDI x17");

        if (dut.u_datapath.u_regfile.registers[18] == 32'd40)
            $display("[PASS] SLLI x18,x1,2");
        else
            $display("[FAIL] SLLI x18");

        if (dut.u_datapath.u_regfile.registers[19] == 32'd10)
            $display("[PASS] SRLI x19,x2,1");
        else
            $display("[FAIL] SRLI x19");

        if (dut.u_datapath.u_regfile.registers[20] == 32'h12345000)
            $display("[PASS] LUI x20");
        else
            $display("[FAIL] LUI x20");

        if (dut.u_datapath.u_regfile.registers[0] == 32'h00000000)
            $display("[PASS] x0 remains zero");
        else
            $display("[FAIL] x0 changed");

        $display("");
        $display("================================================");
        $display("        RISC-V CPU TEST COMPLETE");
        $display("================================================");

        $finish;
    end

endmodule