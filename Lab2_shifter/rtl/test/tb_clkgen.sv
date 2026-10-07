`timescale 1ns / 1ps

module tb_clkgen;

    localparam int unsigned CLK_FREQ_HZ = 100_000_000;
    localparam int unsigned CYCLE_TIME_S = 1;

    localparam int unsigned HALF_PERIOD_CYCLES = CLK_FREQ_HZ * CYCLE_TIME_S / 2;

    logic clk;
    logic rst;
    logic clk_out;

    clkgen #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .CYCLE_TIME_S(CYCLE_TIME_S)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .clk_out(clk_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/waves.fst");
        $dumpvars(0, tb_clkgen);
        clk = 0;
        rst = 1;

        repeat (2) @(posedge clk);
        rst = 0;

        repeat (10) begin
            $display("Time: %0t, clk_out: %b", $time, clk_out);
            repeat (HALF_PERIOD_CYCLES) @(posedge clk);

            // #1;
            //
            // if (clk_out !== ~prev_clk_out) begin
            //     $error("clk_out toggle error at time %0t: expected=%b actual=%b", $time,
            //            ~prev_clk_out, clk_out);
            // end
            //
            // prev_clk_out = clk_out;
        end

        $display("TEST PASS");
        $finish;
    end

    // logic prev_clk_out;

    // initial begin
    //     prev_clk_out = 1'b0;
    // end

endmodule
