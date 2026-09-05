module register_file_tb;

    logic clk;
    logic reset;
    logic write_enable;
    logic [4:0] write_addr;
    logic [31:0] write_data;
    logic [4:0] read_addr1;
    logic [4:0] read_addr2;
    logic [31:0] read_data1;
    logic [31:0] read_data2;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        read_addr1 = 0;
        read_addr2 = 0;

        #10;
        reset = 0;

        // Write 100 into register 5
        write_enable = 1;
        write_addr = 5;
        write_data = 100;

        #10;

        // Write 200 into register 10
        write_addr = 10;
        write_data = 200;

        #10;
        write_enable = 0;

        // Read registers 5 and 10
        read_addr1 = 5;
        read_addr2 = 10;

        #1;
        $display("Register 5 = %d", read_data1);
        $display("Register 10 = %d", read_data2);

        // Check register 0
        read_addr1 = 0;
        #1;
        $display("Register 0 = %d", read_data1);

        $finish;
    end

endmodule