module top #(
    parameter int unsigned CLK_FREQ_HZ  = 100_000_000,
    parameter int unsigned CYCLE_TIME_S = 1,
    parameter int unsigned DATA_WIDTH   = 16,
    parameter int unsigned OP_WIDTH    = 2,
    parameter int unsigned SHAMT_WIDTH = 4
) (
    input logic clk,
    input logic start,
    input logic [DATA_WIDTH - 1:0] data,
    input logic [OP_WIDTH - 1:0] op,
    input logic [SHAMT_WIDTH - 1:0] shamt,

    output logic [7:0] code,
    output logic [7:0] cs_o
);

    logic clk_div_out;
    logic [DATA_WIDTH-1:0] data_out;

    shifter #(
        .DATA_WIDTH(DATA_WIDTH),
        .SHAMT_WIDTH(SHAMT_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) u_shifter (
        .clk(clk),
        .start(start),
        .data(data),
        .shamt(shamt),
        .op(op),
        .out(data_out),
        .clk_div_en(clk_div_out)
    );

    clkgen #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .CYCLE_TIME_S(CYCLE_TIME_S)
    ) u_clkgen (
        .clk(clk),
        .rst(start),
        .clk_out(clk_div_out)
    );

    seg_driver u_seg_driver (
        .clk  (clk),
        .data ({16'b0, data_out}),
        .reset(start),
        .code (code),
        .cs_o (cs_o)
    );

endmodule
