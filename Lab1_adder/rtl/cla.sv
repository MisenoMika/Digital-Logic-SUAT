module cla #(
    parameter int unsigned DATA_WIDTH = 4
) (
    input [DATA_WIDTH - 1:0] src1,
    input [DATA_WIDTH - 1:0] src2,
    input cin_0,

    output [DATA_WIDTH - 1:0] sum,
    output cout,

    // block-level generate / propagate
    output logic G,
    output logic P
);

    // generate function
    logic [DATA_WIDTH - 1:0] g;

    // propagate function
    logic [DATA_WIDTH - 1:0] p;

    logic [DATA_WIDTH:0] cin;


    assign g = src1 & src2;

    assign p = src1 ^ src2;

    assign cin[0] = cin_0;

    assign cin[1] = g[0] | (p[0] & cin_0);

    assign cin[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin_0);

    assign cin[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin_0);

    assign cin[4] = g[3] |
              (p[3] & g[2]) |
              (p[3] & p[2] & g[1]) |
              (p[3] & p[2] & p[1] & g[0]) |
              (p[3] & p[2] & p[1] & p[0] & cin_0);

    assign sum = p ^ cin[DATA_WIDTH-1:0];

    assign cout = cin[DATA_WIDTH];

    // 4-bit group propagate
    assign P = &p;

    // 4-bit group generate
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
endmodule
