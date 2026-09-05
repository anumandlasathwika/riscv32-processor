`timescale 1ns / 1ps

module datapath_tb;

    logic clk;
    logic rst_n;

    logic [31:0] instr;
    logic [31:0] pc_out;

    logic        mem_read;
    logic        mem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_write_data;
    logic [31:0] dmem_read_data;

    logic trap_flag;


    // ============================================================
    // DUT
    // ============================================================

    datapath dut (
        .clk             (clk),
        .rst_n           (rst_n),

        .instr           (instr),
        .pc_out          (pc_out),

        .mem_read        (mem_read),
        .mem_write       (mem_write),
        .dmem_addr       (dmem_addr),
        .dmem_write_data (dmem_write_data),
        .dmem_read_data  (dmem_read_data),

        .trap_flag       (trap_flag)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;

        instr = 32'h00000013;       // NOP
        dmem_read_data = 32'h00000000;

        #20;

        rst_n = 1'b1;

        // --------------------------------------------------------
        // ADDI x1, x0, 10
        // x1 = 10
        // --------------------------------------------------------

        instr = 32'h00A00093;

        #10;

        if (dut.u_regfile.registers[1] == 32'd10)
            $display("[PASS] ADDI x1,x0,10");
        else
            $display("[FAIL] ADDI x1,x0,10 : x1=%h",
                     dut.u_regfile.registers[1]);


        // --------------------------------------------------------
        // ADDI x2, x0, 20
        // x2 = 20
        // --------------------------------------------------------

        instr = 32'h01400113;

        #10;

        if (dut.u_regfile.registers[2] == 32'd20)
            $display("[PASS] ADDI x2,x0,20");
        else
            $display("[FAIL] ADDI x2,x0,20 : x2=%h",
                     dut.u_regfile.registers[2]);


        // --------------------------------------------------------
        // ADD x3, x1, x2
        // x3 = 10 + 20 = 30
        // --------------------------------------------------------

        instr = 32'h002081B3;

        #10;

        if (dut.u_regfile.registers[3] == 32'd30)
            $display("[PASS] ADD x3,x1,x2");
        else
            $display("[FAIL] ADD x3,x1,x2 : x3=%h",
                     dut.u_regfile.registers[3]);


        // --------------------------------------------------------
        // SUB x4, x2, x1
        // x4 = 20 - 10 = 10
        // --------------------------------------------------------

        instr = 32'h40110233;

        #10;

        if (dut.u_regfile.registers[4] == 32'd10)
            $display("[PASS] SUB x4,x2,x1");
        else
            $display("[FAIL] SUB x4,x2,x1 : x4=%h",
                     dut.u_regfile.registers[4]);


        // --------------------------------------------------------
        // AND x5, x1, x2
        // 10 & 20 = 0
        // --------------------------------------------------------

        instr = 32'h0020F2B3;

        #10;

        if (dut.u_regfile.registers[5] == 32'd0)
            $display("[PASS] AND x5,x1,x2");
        else
            $display("[FAIL] AND x5,x1,x2 : x5=%h",
                     dut.u_regfile.registers[5]);


        // --------------------------------------------------------
        // OR x6, x1, x2
        // 10 | 20 = 30
        // --------------------------------------------------------

        instr = 32'h0020E333;

        #10;

        if (dut.u_regfile.registers[6] == 32'd30)
            $display("[PASS] OR x6,x1,x2");
        else
            $display("[FAIL] OR x6,x1,x2 : x6=%h",
                     dut.u_regfile.registers[6]);


        // --------------------------------------------------------
        // XOR x7, x1, x2
        // 10 ^ 20 = 30
        // --------------------------------------------------------

        instr = 32'h0020C3B3;

        #10;

        if (dut.u_regfile.registers[7] == 32'd30)
            $display("[PASS] XOR x7,x1,x2");
        else
            $display("[FAIL] XOR x7,x1,x2 : x7=%h",
                     dut.u_regfile.registers[7]);


        // --------------------------------------------------------
        // LUI x8, 0x12345
        // x8 = 0x12345000
        // --------------------------------------------------------

        instr = 32'h12345437;

        #10;

        if (dut.u_regfile.registers[8] == 32'h12345000)
            $display("[PASS] LUI x8");
        else
            $display("[FAIL] LUI x8 : x8=%h",
                     dut.u_regfile.registers[8]);


        // --------------------------------------------------------
        // Check x0 is always zero
        // --------------------------------------------------------

        if (dut.u_regfile.registers[0] == 32'h00000000)
            $display("[PASS] x0 remains zero");
        else
            $display("[FAIL] x0 changed : x0=%h",
                     dut.u_regfile.registers[0]);


        $display("");
        $display("========================================");
        $display("DATAPATH TEST COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule