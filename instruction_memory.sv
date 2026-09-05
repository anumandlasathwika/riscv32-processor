`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_DEPTH = 64 // 64 words (256 bytes)
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    // Memory array holding 32-bit instructions initialized to zero
    logic [31:0] mem [0:MEM_DEPTH-1];

    // Word-aligned index derived from byte address (addr / 4)
    wire [29:0] word_addr = addr[31:2];

    // Zero-initialize memory using systemic initialization
    initial begin
        for (integer idx = 0; idx < MEM_DEPTH; idx = idx + 1) begin
            mem[idx] = 32'h00000000;
        end
    end

    always_comb begin
        if (word_addr < MEM_DEPTH) begin
            instr = mem[word_addr];
        end else begin
            instr = 32'h00000000; // Default for out-of-bounds memory access
        end
    end

endmodule