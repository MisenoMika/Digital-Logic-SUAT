`include "define.vh"

module Top (
      input logic clk
    , input logic rst

    , input logic [`REG_ADDR_BW] write_addr
    , input logic                wen
    , input logic [`REG_ADDR_BW] read_addr1
    , input logic                read_en1
    , input logic [`REG_ADDR_BW] read_addr2
    , input logic                read_en2

    , input logic           ALUSrc
    , input logic [    5:0] ALUctrl
    , input logic [`IMM_BW] Imm

    , output logic [`ALU_DATA_BW] ALU_result
    , output logic zero
    , output logic lt
    , output logic ltu
    , output logic ge
    , output logic geu
);

    logic [`REG_BW] read_data1;
    logic [`REG_BW] read_data2;

    ALU u_ALU (
        .input_A(read_data1),
        .input_B(ALUSrc ? Imm : read_data2),
        .ALUctrl(ALUctrl),
        .result(ALU_result),
        .zero(zero),
        .lt(lt),
        .ltu(ltu),
        .ge(ge),
        .geu(geu)
    );
    regfile u_regfile (
        .clk(clk),
        .rst(rst),
        .write_addr(write_addr),
        .write_data(ALU_result),
        .wen(wen),
        .read_addr1(read_addr1),
        .read_data1(read_data1),
        .read_en1(read_en1),
        .read_addr2(read_addr2),
        .read_data2(read_data2),
        .read_en2(read_en2)
    );

endmodule
