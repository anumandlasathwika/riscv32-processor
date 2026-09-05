`timescale 1ns / 1ps

module data_memory #(
    parameter MEM_DEPTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,

    input  logic        mem_read,
    input  logic        mem_write,

    input  logic [31:0] addr,
    input  logic [31:0] write_data,

    // 000 = Byte
    // 001 = Halfword
    // 010 = Word
    input  logic [2:0]  mem_size,

    // 1 = unsigned load
    // 0 = signed load
    input  logic        mem_unsigned,

    output logic [31:0] read_data
);

    logic [31:0] mem [0:MEM_DEPTH-1];

    integer i;

    // Word address
    wire [29:0] word_addr = addr[31:2];

    // Byte position inside the 32-bit word
    wire [1:0] byte_offset = addr[1:0];

    // ---------------------------------------------------------
    // RESET + STORE
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem[i] <= 32'h00000000;
            end

        end
        else if (mem_write && (word_addr < MEM_DEPTH)) begin

            case (mem_size)

                // SB - Store Byte
                3'b000: begin
                    case (byte_offset)
                        2'b00: mem[word_addr][7:0]   <= write_data[7:0];
                        2'b01: mem[word_addr][15:8]  <= write_data[7:0];
                        2'b10: mem[word_addr][23:16] <= write_data[7:0];
                        2'b11: mem[word_addr][31:24] <= write_data[7:0];
                    endcase
                end

                // SH - Store Halfword
                3'b001: begin
                    if (byte_offset[1] == 1'b0)
                        mem[word_addr][15:0] <= write_data[15:0];
                    else
                        mem[word_addr][31:16] <= write_data[15:0];
                end

                // SW - Store Word
                3'b010: begin
                    mem[word_addr] <= write_data;
                end

                default: begin
                    // Invalid memory size -> do nothing
                end

            endcase
        end
    end

    // ---------------------------------------------------------
    // LOAD
    // ---------------------------------------------------------
    always_comb begin

        read_data = 32'h00000000;

        if (mem_read && (word_addr < MEM_DEPTH)) begin

            case (mem_size)

                // LB / LBU
                3'b000: begin

                    case (byte_offset)

                        2'b00: begin
                            if (mem_unsigned)
                                read_data = {24'h000000, mem[word_addr][7:0]};
                            else
                                read_data = {{24{mem[word_addr][7]}},
                                             mem[word_addr][7:0]};
                        end

                        2'b01: begin
                            if (mem_unsigned)
                                read_data = {24'h000000, mem[word_addr][15:8]};
                            else
                                read_data = {{24{mem[word_addr][15]}},
                                             mem[word_addr][15:8]};
                        end

                        2'b10: begin
                            if (mem_unsigned)
                                read_data = {24'h000000, mem[word_addr][23:16]};
                            else
                                read_data = {{24{mem[word_addr][23]}},
                                             mem[word_addr][23:16]};
                        end

                        2'b11: begin
                            if (mem_unsigned)
                                read_data = {24'h000000, mem[word_addr][31:24]};
                            else
                                read_data = {{24{mem[word_addr][31]}},
                                             mem[word_addr][31:24]};
                        end

                    endcase
                end

                // LH / LHU
                3'b001: begin

                    if (byte_offset[1] == 1'b0) begin

                        if (mem_unsigned)
                            read_data = {16'h0000, mem[word_addr][15:0]};
                        else
                            read_data = {{16{mem[word_addr][15]}},
                                         mem[word_addr][15:0]};

                    end
                    else begin

                        if (mem_unsigned)
                            read_data = {16'h0000, mem[word_addr][31:16]};
                        else
                            read_data = {{16{mem[word_addr][31]}},
                                         mem[word_addr][31:16]};

                    end
                end

                // LW
                3'b010: begin
                    read_data = mem[word_addr];
                end

                default: begin
                    read_data = 32'h00000000;
                end

            endcase
        end
    end

endmodule