module cla_block #(
    parameter int unsigned DATA_WIDTH = 16
) (
    input logic [DATA_WIDTH - 1:0] src1,
    input logic [DATA_WIDTH - 1:0] src2,
    input cin_0,

    output [DATA_WIDTH - 1:0] sum,
    output cout

);
    logic [3:0] block_G;
    logic [3:0] block_P;
    logic [4:0] block_cin;

    localparam int unsigned NumBlocks = DATA_WIDTH / 4;

    assign block_cin[0] = cin_0;

    genvar i;
    /* verilator lint_off PINCONNECTEMPTY */
    generate
        for (i = 0; i < NumBlocks; i++) begin : gen_cla4

            cla #(
                .DATA_WIDTH(4)
            ) u_cla4 (
                .src1 (src1[i*4+:4]),
                .src2 (src2[i*4+:4]),
                .cin_0(block_cin[i]),

                .sum (sum[i*4+:4]),
                .cout(),

                .G(block_G[i]),
                .P(block_P[i])
            );

        end
    endgenerate
    /* verilator lint_on PINCONNECTEMPTY */

    assign block_cin[1] = block_G[0] | (block_P[0] & cin_0);

    assign block_cin[2] = block_G[1] | (block_P[1] & block_G[0]) | (block_P[1] & block_P[0] & cin_0);

    assign block_cin[3] =
        block_G[2] |
        (block_P[2] & block_G[1]) |
        (block_P[2] & block_P[1] & block_G[0]) |
        (block_P[2] & block_P[1] & block_P[0] & cin_0);

    assign block_cin[4] =
        block_G[3] |
        (block_P[3] & block_G[2]) |
        (block_P[3] & block_P[2] & block_G[1]) |
        (block_P[3] & block_P[2] & block_P[1] & block_G[0]) |
        (block_P[3] & block_P[2] & block_P[1] & block_P[0] & cin_0);


    assign cout = block_cin[4];

endmodule
