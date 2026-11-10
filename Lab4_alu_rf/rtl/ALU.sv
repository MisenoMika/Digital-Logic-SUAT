
`include "define.vh"

module ALU (
      input logic [`ALU_DATA_BW] input_A
    , input logic [`ALU_DATA_BW] input_B
    , input logic [         5:0] ALUctrl

    , output logic [`ALU_DATA_BW] result
    , output logic zero
    , output logic lt
    , output logic ltu
    , output logic ge
    , output logic geu
);
    import lab4_pkg::*;
    alu_op_t alu_op;
    assign alu_op = alu_op_t'(ALUctrl);

    wire [`ALU_DATA_BW] add_result = input_A + input_B;
    wire [`ALU_DATA_BW] and_result = input_A & input_B;
    wire [`ALU_DATA_BW] or_result = input_A | input_B;
    wire [`ALU_DATA_BW] xor_result = input_A ^ input_B;
    wire [`ALU_DATA_BW] sll_result = input_A << input_B[4:0];
    wire [`ALU_DATA_BW] srl_result = input_A >> input_B[4:0];
    wire [`ALU_DATA_BW] sra_result = $signed(input_A) >>> input_B[4:0];

    logic c_out;

    logic [`ALU_DATA_BW] sub_result;
    assign {c_out, sub_result} = {1'b0, input_A} + {1'b0, ~input_B} + 1'b1;
    wire sub_overflow = input_A[31] ^ input_B[31] ^ c_out;
    // wire sub_overflow = (input_A[31] != input_B[31]) && (sub_result[31] != input_A[31]);


    assign zero = sub_result == 0;
    // assign lt   = sub_overflow ^ sub_result[31];
    // assign ge   = ~sub_overflow ^ sub_result[31];
    assign lt   = ~sub_overflow;
    assign ge   = sub_overflow;
    assign ltu  = ~c_out;
    assign geu  = c_out;

    always_comb begin
        case (alu_op)
            ALU_ADD: result = add_result;
            ALU_SUB: result = sub_result;
            ALU_AND: result = and_result;
            ALU_OR:  result = or_result;
            ALU_XOR: result = xor_result;
            ALU_SLL: result = sll_result;
            ALU_SRL: result = srl_result;
            ALU_SRA: result = sra_result;
            default: result = `ZERO32;
        endcase
    end

endmodule
