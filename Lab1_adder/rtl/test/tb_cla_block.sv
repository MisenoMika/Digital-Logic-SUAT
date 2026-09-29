`timescale 1ns / 1ps

module tb_cla_block ();
    localparam int unsigned DATA_WIDTH = 16;
    localparam int unsigned NUM_RANDOM = 10000;

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

    cla_block #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_dut_ra (
        .src1 (src1),
        .src2 (src2),
        .cin_0(cin_0),
        .sum  (dut_sum),
        .cout (dut_cout)
    );

    integer errors;

    task automatic check(input [DATA_WIDTH - 1:0] a, input [DATA_WIDTH - 1:0] b, input c);
        src1  = a;
        src2  = b;
        cin_0 = c;
        #10;
        if (dut_sum != ref_sum || dut_cout != ref_cout) begin
            errors = errors + 1;
            $display("MISMATCH: src1=%h src2=%h cin=%b | dut={cout=%b,sum=%h} ref={cout=%b,sum=%h}",
                     src1, src2, cin_0, dut_cout, dut_sum, ref_cout, ref_sum);
        end
    endtask

    initial begin
        integer i;

        $dumpfile("build/waves.fst");
        $dumpvars(0, tb_cla_block);

        errors = 0;

        // some boundary tests
        check({DATA_WIDTH{1'b0}}, {DATA_WIDTH{1'b0}}, 1'b0);
        check({DATA_WIDTH{1'b1}}, {DATA_WIDTH{1'b1}}, 1'b0);
        check({DATA_WIDTH{1'b1}}, {DATA_WIDTH{1'b1}}, 1'b1);
        check({DATA_WIDTH{1'b1}}, {DATA_WIDTH{1'b0}}, 1'b1);
        check({DATA_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}}, 1'b1);
        check(16'h0001, {DATA_WIDTH{1'b1}}, 1'b0);
        check(16'hAAAA, 16'h5555, 1'b1);
        check(16'h8000, 16'h8000, 1'b0);

        // random tests
        /* verilator lint_off WIDTHTRUNC */
        for (i = 0; i < NUM_RANDOM; i++) begin
            check($urandom, $urandom, $urandom_range(1));
        end
        /* verilator lint_on WIDTHTRUNC */

        if (errors == 0) $display("ALL %0d TESTS PASSED", NUM_RANDOM + 8);
        else $display("TEST FAILED: %0d mismatch(es)", errors);

        $finish;
    end
endmodule
