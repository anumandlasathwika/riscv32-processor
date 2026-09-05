`timescale 1ns / 1ps

module pc (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_in,
    output logic [31:0] pc_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'h00000000;
        end else begin
            pc_out <= pc_in;
        end
    end

endmodule