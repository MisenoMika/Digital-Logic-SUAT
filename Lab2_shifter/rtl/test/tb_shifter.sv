`timescale 1ns / 1ps

module tb_shifter;

    localparam int unsigned DATA_WIDTH  = 16;
    localparam int unsigned SHAMT_WIDTH = 4;
    localparam int unsigned OP_WIDTH    = 2;
    // localparam int unsigned CLK_FREQ_HZ  = 100_000_000;
    // localparam int unsigned CYCLE_TIME_S = 1;
    //
    typedef enum logic [3:0] {
        LOGIL_LEFT_SHIFT  = '0,
        LOGIC_RIGHT_SHIFT,
        ARTH_RIGHT_SHIFT
    } tb_state_t;
    /* verilator lint_off UNUSEDSIGNAL */
    tb_state_t                     tb_state;
    /* verilator lint_on UNUSEDSIGNAL */
    logic                          clk;
    logic                          start;
    logic      [ DATA_WIDTH - 1:0] data;
    logic      [SHAMT_WIDTH - 1:0] shamt;
    logic      [   OP_WIDTH - 1:0] op;
    logic      [ DATA_WIDTH - 1:0] out;
    logic                          clk_div_out;

    // DUT
    shifter #(
        .DATA_WIDTH(DATA_WIDTH),
        .SHAMT_WIDTH(SHAMT_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) dut (
        .clk  (clk),
        .start(start),
        .data (data),
        .shamt(shamt),
        .op   (op),
        .out  (out),
        .clk_div_en(clk_div_out)
    );

    // 100 MHz clock
    always #5 clk = ~clk;
    always #5000 clk_div_out = ~clk_div_out;  // 1 kHz clock for clk_div_en

    task automatic tick(input int unsigned num_ticks);
        for (int i = 0; i < num_ticks; i++) begin
            @(posedge clk);
        end
    endtask

    task automatic test_shift(input logic [15:0] test_data, input logic [3:0] test_shamt,
                              input logic [1:0] test_op);

        logic [15:0] expected;

        begin
            // Calculate expected result
            unique case (test_op)
                2'b00:   expected = test_data << test_shamt;
                2'b01:   expected = test_data >> test_shamt;
                2'b11:   expected = $signed(test_data) >>> test_shamt;
                default: expected = test_data;
            endcase

            // prepare inputs
            @(posedge clk_div_out);
            data  = test_data;
            shamt = test_shamt;
            op    = test_op;
            start = 1'b1;

            // latch inputs
            @(posedge clk_div_out);
            #1;
            start = 1'b0;

            // Change inputs after start to verify input latching
            /* verilator lint_off WIDTHTRUNC */
            data  = $urandom;
            shamt = $urandom;
            op    = $urandom;
            /* verilator lint_on WIDTHTRUNC */

            // Wait for shifting to finish
            tick(32'(test_shamt));
            #1;

            if (out === expected) begin
                $display("[PASS] data=%h shamt=%2d op=%b out=%h", test_data, test_shamt, test_op,
                         out);
            end else begin
                $display("[FAIL] data=%h shamt=%2d op=%b expected=%h actual=%h", test_data,
                         test_shamt, test_op, expected, out);
                $fatal(1, "Test failed.");
            end
        end

    endtask

    initial begin

        clk   = 1'b0;
        start = 1'b0;
        data  = 16'h0000;
        shamt = 4'd0;
        op    = 2'b00;
        tb_state = LOGIL_LEFT_SHIFT;
        $dumpfile("build/waves.fst");
        $dumpvars(0, tb_shifter);

        repeat (2) @(posedge clk);



        // Logical left shift

        tb_state = LOGIL_LEFT_SHIFT;
        $display("LEFT SHIFT TESTS");

        for (int shamt_i = 0; shamt_i < 16; shamt_i++) begin
            test_shift(16'h9234, shamt_i[3:0], 2'b00);
        end


        // Logical right shift

        tb_state = LOGIC_RIGHT_SHIFT;
        $display("RIGHT SHIFT TESTS");

        for (int shamt_i = 0; shamt_i < 16; shamt_i++) begin
            test_shift(16'h9234, shamt_i[3:0], 2'b01);
        end


        // Arithmetic right shift

        tb_state = ARTH_RIGHT_SHIFT;
        $display("ARITHMETIC RIGHT SHIFT TESTS");

        for (int shamt_i = 0; shamt_i < 16; shamt_i++) begin
            test_shift(16'h9234, shamt_i[3:0], 2'b11);
        end

        $display("All tests finished.");

        $finish;
    end

endmodule
