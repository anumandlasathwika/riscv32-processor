`timescale 1ns / 1ps

module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALU_control,
    output logic [31:0] result
);

    always_comb begin
        case (ALU_control)

            // ADD
            4'b0000:
                result = A + B;

            // SUB
            4'b0001:
                result = A - B;

            // OR
            4'b0010:
                result = A | B;

            // XOR
            4'b0011:
                result = A ^ B;

            // SLT - signed
            4'b0100:
                result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            // SLTU - unsigned
            4'b0101:
                result = (A < B) ? 32'd1 : 32'd0;

            // SLL
            4'b0110:
                result = A << B[4:0];

            // SRL
            4'b0111:
                result = A >> B[4:0];

            // SRA
            4'b1000:
                result = $signed(A) >>> B[4:0];

            // AND
            4'b1001:
                result = A & B;

            default:
                result = 32'h00000000;

        endcase
    end

endmodule