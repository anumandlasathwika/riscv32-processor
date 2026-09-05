module register_file (
    input  logic        clk,
    input  logic        reset,

    input  logic        write_enable,
    input  logic [4:0]  write_addr,
    input  logic [31:0] write_data,

    input  logic [4:0]  read_addr1,
    input  logic [4:0]  read_addr2,

    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [0:31];

    integer i;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (write_enable && write_addr != 5'b00000) begin
            registers[write_addr] <= write_data;
        end
    end

    always_comb begin
        if (read_addr1 == 5'b00000)
            read_data1 = 32'b0;
        else
            read_data1 = registers[read_addr1];

        if (read_addr2 == 5'b00000)
            read_data2 = 32'b0;
        else
            read_data2 = registers[read_addr2];
    end

endmodule