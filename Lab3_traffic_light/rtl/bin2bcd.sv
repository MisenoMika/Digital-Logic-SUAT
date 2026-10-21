module bin2bcd #(
    // now only support 8-bit input
    parameter int DATA_WIDTH = 8
) (
    input  logic [DATA_WIDTH-1:0] bin_in,
    output logic [DATA_WIDTH-1:0] bcd_out
);

    logic [DATA_WIDTH-1:0] shift_stage[DATA_WIDTH+1];

    assign shift_stage[0] = '0;

    generate
        for (genvar i = 0; i < DATA_WIDTH; i++) begin : g_dabble
            wire [3:0] lo = shift_stage[i][3:0];
            wire [3:0] hi = shift_stage[i][7:4];
            // Add 3 if any BCD digit is greater than or equal to 5
            wire [3:0] lo_corr = (lo >= 5) ? lo + 3 : lo;
            wire [2:0] hi_corr = (hi >= 5) ? hi[2:0] + 3 : hi[2:0];
            // Shift left by 1
            assign shift_stage[i+1] = {hi_corr, lo_corr, bin_in[DATA_WIDTH-1-i]};
        end
    endgenerate

    assign bcd_out = shift_stage[DATA_WIDTH];

    // `ifndef __SYNTHESIS__
    //     always_comb begin
    //         // Display the BCD output in binary format for simulation
    //         assert (bin_in < 100)
    //         else $error("[bin2bcd] Input binary number must be less than 100 for BCD conversion.\n");
    //     end
    // `endif

endmodule
