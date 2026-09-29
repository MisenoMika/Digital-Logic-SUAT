`timescale 1ns / 1ps

module tb_cla ();
    localparam int unsigned DATA_WIDTH = 4;

    logic [DATA_WIDTH - 1:0] src1;
    logic [DATA_WIDTH - 1:0] src2;
    logic cin_0;

    // DUT
    logic [DATA_WIDTH - 1:0] dut_sum;
    logic dut_cout;

    // REF
    logic [DATA_WIDTH - 1:0] ref_sum;
    logic ref_cout;

    ref_ra #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ref_ra (
        .src1 (src1),
        .src2 (src2),
        .cin_0(cin_0),
        .sum  (ref_sum),
        .cout (ref_cout)
    );

    /* verilator lint_off PINCONNECTEMPTY */
    cla #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_dut_ra (
        .src1 (src1),
        .src2 (src2),
        .cin_0(cin_0),
        .sum  (dut_sum),
        .cout (dut_cout),
        .G    (),
        .P    ()
    );
    /* verilator lint_on PINCONNECTEMPTY */

    initial begin
        integer i;
        integer errors;

        $dumpfile("build/waves.fst");
        $dumpvars(0, tb_cla);

        errors = 0;

        for (i = 0; i < (1 << (2 * DATA_WIDTH + 1)); i++) begin
            {cin_0, src1, src2} = i[2*DATA_WIDTH:0];
            #10;

            if (dut_sum != ref_sum || dut_cout != ref_cout) begin
                errors = errors + 1;
                $display(
                    "MISMATCH: src1=%b src2=%b cin=%b | dut={cout=%b,sum=%b} ref={cout=%b,sum=%b}",
                    src1, src2, cin_0, dut_cout, dut_sum, ref_cout, ref_sum);
            end
        end

        if (errors == 0) $display("ALL 512 TESTS PASSED");
        else $display("TEST FAILED: %0d mismatch(es)", errors);

        $finish;
    end
endmodule
