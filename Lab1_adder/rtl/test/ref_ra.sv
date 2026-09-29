module ref_ra #(
    parameter int unsigned DATA_WIDTH = 4
) (
    input logic [DATA_WIDTH - 1:0] src1,
    input logic [DATA_WIDTH - 1:0] src2,
    input logic cin_0,
    output logic [DATA_WIDTH - 1:0] sum,
    output logic cout
);

    assign {cout, sum} = src1 + src2 + cin_0;
endmodule
