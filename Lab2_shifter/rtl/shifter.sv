module shifter #(
    parameter int unsigned DATA_WIDTH = 16,
    parameter int unsigned SHAMT_WIDTH = 4,
    parameter int unsigned OP_WIDTH = 2
) (
    input logic clk,
    input logic start,
    input logic [DATA_WIDTH-1:0] data,
    input logic [SHAMT_WIDTH-1:0] shamt,
    input logic [OP_WIDTH-1:0] op,
    output logic [DATA_WIDTH-1:0] out,

    input clk_div_en
);

    logic [SHAMT_WIDTH - 1:0] shamt_r;
    logic [SHAMT_WIDTH - 1:0] shamt_cnt;
    logic [DATA_WIDTH - 1:0] data_r;
    logic [OP_WIDTH - 1:0] op_r;

    always_ff @(posedge clk) begin
        if (start) begin
            shamt_r <= shamt;
            data_r  <= data;
            op_r    <= op;
            shamt_cnt <= 0;
        end else if (shamt_cnt < shamt_r && clk_div_en) begin
            unique case (op_r)
                2'b00: data_r <= {data_r[DATA_WIDTH-2:0], 1'b0};  // shift left

                2'b01: data_r <= {1'b0, data_r[DATA_WIDTH-1:1]};  // logical shift right

                2'b11:
                data_r <= {data_r[DATA_WIDTH-1], data_r[DATA_WIDTH-1:1]};  // arithmetic shift right

                default: data_r <= data_r;  // keep
            endcase
            shamt_cnt <= shamt_cnt + 1;
        end
    end

    assign out = data_r;

endmodule
