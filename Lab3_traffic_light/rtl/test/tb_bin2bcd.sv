`timescale 1ns / 1ps
module tb_bin2bcd;

    localparam int DATA_WIDTH = 8;

    logic [DATA_WIDTH-1:0] bin_in;
    logic [DATA_WIDTH-1:0] bcd_out;

    bin2bcd #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .bin_in (bin_in),
        .bcd_out(bcd_out)
    );

    // Ref
    function automatic logic [DATA_WIDTH-1:0] ref_bcd(input logic [DATA_WIDTH-1:0] b);
        return ((b / 10) << 4) | (b % 10);
    endfunction

    int errors = 0;
    int checks = 0;

    task automatic check(input logic [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] exp;
        bin_in = b;
        #1;  // 等待 always_comb 收敛
        exp = ref_bcd(b);
        checks++;
        if (bcd_out !== exp) begin
            errors++;
            $error("[FAIL] bin=%0d (0x%02x): got 0x%02x (%0d%0d), expected 0x%02x (%0d%0d)", b, b,
                   bcd_out, bcd_out[7:4], bcd_out[3:0], exp, exp[7:4], exp[3:0]);
        end
    endtask

    initial begin
        $dumpfile("build/tb_bin2bcd.fst");
        $dumpvars(0, tb_bin2bcd);

        bin_in = '0;
        #1;

        $display("\n===== [1] Exhaustive test 0..99 =====");
        for (int i = 0; i < 100; i++) check(i[DATA_WIDTH-1:0]);
        $display("Exhaustive done. checks=%0d errors=%0d", checks, errors);

        $display("\n===== [2] Directed corner cases =====");
        check(8'd0);  // 0   -> 0x00
        check(8'd1);  // 1   -> 0x01
        check(8'd9);  // 9   -> 0x09  (跨进位)
        check(8'd10);  // 10  -> 0x10
        check(8'd19);  // 19  -> 0x19
        check(8'd20);  // 20  -> 0x20
        check(8'd49);  // 49  -> 0x49
        check(8'd50);  // 50  -> 0x50
        check(8'd89);  // 89  -> 0x89
        check(8'd90);  // 90  -> 0x90
        check(8'd99);  // 99  -> 0x99

        $display("\n===== [3] Random tests (0..99) =====");
        /* verilator lint_off WIDTHTRUNC */
        for (int i = 0; i < 20; i++) check($urandom_range(0, 99));
        /* verilator lint_on WIDTHTRUNC */

        $display("\n===== [4] Invalid input (>=100) - expect DUT assertion =====");
        bin_in = 8'd100;
        #1;
        bin_in = 8'd200;
        #1;
        bin_in = 8'd255;
        #1;

        $display("\n============================================");
        $display(" Summary: checks=%0d  errors=%0d", checks, errors);
        if (errors == 0) $display(" *** ALL TESTS PASSED ***");
        else $display(" *** %0d TEST(S) FAILED ***", errors);
        $display("============================================\n");
        $finish;
    end

    always_comb begin
        if (bin_in < 100) begin
            a_bcd_lo_valid :
            assert (bcd_out[3:0] <= 4'd9)
            else $error("[SVA] low  nibble = %0d is not a valid BCD digit", bcd_out[3:0]);
            a_bcd_hi_valid :
            assert (bcd_out[7:4] <= 4'd9)
            else $error("[SVA] high nibble = %0d is not a valid BCD digit", bcd_out[7:4]);
        end
    end

endmodule
