`timescale 1ns / 1ps

module data_memory_tb;

    logic        clk;
    logic        rst_n;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] addr;
    logic [31:0] write_data;
    logic [2:0]  mem_size;
    logic        mem_unsigned;
    logic [31:0] read_data;

    data_memory #(
        .MEM_DEPTH(64)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),
        .read_data(read_data)
    );

    // Clock
    always #5 clk = ~clk;

    task store_word(
        input [31:0] address,
        input [31:0] data
    );
        begin
            @(negedge clk);
            addr = address;
            write_data = data;
            mem_size = 3'b010;
            mem_write = 1'b1;

            @(negedge clk);
            mem_write = 1'b0;
        end
    endtask

    task store_half(
        input [31:0] address,
        input [31:0] data
    );
        begin
            @(negedge clk);
            addr = address;
            write_data = data;
            mem_size = 3'b001;
            mem_write = 1'b1;

            @(negedge clk);
            mem_write = 1'b0;
        end
    endtask

    task store_byte(
        input [31:0] address,
        input [31:0] data
    );
        begin
            @(negedge clk);
            addr = address;
            write_data = data;
            mem_size = 3'b000;
            mem_write = 1'b1;

            @(negedge clk);
            mem_write = 1'b0;
        end
    endtask

    task load_data(
        input [31:0] address,
        input [2:0] size,
        input unsigned_load,
        input [31:0] expected,
        input [80*8:1] name
    );
        begin
            @(negedge clk);

            addr = address;
            mem_size = size;
            mem_unsigned = unsigned_load;
            mem_read = 1'b1;

            #1;

            if (read_data === expected)
                $display("[PASS] %s : %h", name, read_data);
            else
                $display("[FAIL] %s : expected=%h actual=%h",
                         name, expected, read_data);

            mem_read = 1'b0;
        end
    endtask

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        addr = 32'h00000000;
        write_data = 32'h00000000;
        mem_size = 3'b010;
        mem_unsigned = 1'b0;

        // Reset
        #12;
        rst_n = 1'b1;

        // ----------------------------------------------------
        // SW
        // ----------------------------------------------------
        store_word(32'h00000000, 32'h12345678);

        // LW
        load_data(
            32'h00000000,
            3'b010,
            1'b0,
            32'h12345678,
            "LW"
        );

        // ----------------------------------------------------
        // SB
        // ----------------------------------------------------
        store_word(32'h00000004, 32'hAABBCCDD);

        store_byte(32'h00000004, 32'h00000011);

        load_data(
            32'h00000004,
            3'b010,
            1'b0,
            32'hAABBCC11,
            "SB + LW"
        );

        // ----------------------------------------------------
        // SH
        // ----------------------------------------------------
        store_word(32'h00000008, 32'h11223344);

        store_half(32'h00000008, 32'h0000ABCD);

        load_data(
            32'h00000008,
            3'b010,
            1'b0,
            32'h1122ABCD,
            "SH + LW"
        );

        // ----------------------------------------------------
        // LB signed
        // ----------------------------------------------------
        store_word(32'h0000000C, 32'h00000080);

        load_data(
            32'h0000000C,
            3'b000,
            1'b0,
            32'hFFFFFF80,
            "LB signed"
        );

        // ----------------------------------------------------
        // LBU unsigned
        // ----------------------------------------------------
        load_data(
            32'h0000000C,
            3'b000,
            1'b1,
            32'h00000080,
            "LBU unsigned"
        );

        // ----------------------------------------------------
        // LH signed
        // ----------------------------------------------------
        store_word(32'h00000010, 32'h00008000);

        load_data(
            32'h00000010,
            3'b001,
            1'b0,
            32'hFFFF8000,
            "LH signed"
        );

        // ----------------------------------------------------
        // LHU unsigned
        // ----------------------------------------------------
        load_data(
            32'h00000010,
            3'b001,
            1'b1,
            32'h00008000,
            "LHU unsigned"
        );

        $display("");
        $display("==========================================");
        $display("DATA MEMORY TEST COMPLETE");
        $display("==========================================");

        $finish;
    end

endmodule