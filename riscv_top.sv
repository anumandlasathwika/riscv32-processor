`timescale 1ns / 1ps

module riscv_top #(
    parameter MEM_DEPTH = 64
)(
    input  logic        clk,
    input  logic        rst_n,

    // Debug outputs
    output logic [31:0] pc,
    output logic        trap_flag
);

    logic [31:0] instruction;

    // Data memory signals
    logic        mem_read;
    logic        mem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_write_data;
    logic [31:0] dmem_read_data;

    // Memory access control
    logic [2:0]  dmem_size;
    logic        dmem_unsigned;

    // ---------------------------------------------------------
    // INSTRUCTION MEMORY
    // ---------------------------------------------------------
    instruction_memory #(
        .MEM_DEPTH(MEM_DEPTH)
    ) u_instruction_memory (
        .addr  (pc),
        .instr (instruction)
    );

    // ---------------------------------------------------------
    // DATAPATH
    // ---------------------------------------------------------
    datapath #(
        .MEM_DEPTH(MEM_DEPTH)
    ) u_datapath (
        .clk             (clk),
        .rst_n           (rst_n),
        .instr           (instruction),
        .pc_out          (pc),

        .mem_read        (mem_read),
        .mem_write       (mem_write),
        .dmem_addr       (dmem_addr),
        .dmem_write_data (dmem_write_data),
        .dmem_read_data  (dmem_read_data),

        .dmem_size       (dmem_size),
        .dmem_unsigned   (dmem_unsigned),

        .trap_flag       (trap_flag)
    );

    // ---------------------------------------------------------
    // DATA MEMORY
    // ---------------------------------------------------------
    data_memory #(
        .MEM_DEPTH(MEM_DEPTH)
    ) u_data_memory (
        .clk          (clk),
        .rst_n        (rst_n),

        .mem_read     (mem_read),
        .mem_write    (mem_write),

        .addr         (dmem_addr),
        .write_data   (dmem_write_data),

        .mem_size     (dmem_size),
        .mem_unsigned (dmem_unsigned),

        .read_data    (dmem_read_data)
    );

endmodule