`timescale 1ns / 1ps
module tb_trafficlight;
    import lab3_pkg::*;

    /* verilator lint_off UNUSEDPARAM */
    localparam int CLK_FREQ_HZ = 1;
    localparam int CYCLE_TIME_S = 1;
    /* verilator lint_on UNUSEDPARAM */
    localparam int CNT_W = 8;
    localparam int FULL_RED_TIME_S = 2;
    localparam int YELLOW_TIME_S = 3;
    localparam int GREEN_TIME_S = 5;

    localparam int ONE_PHASE_CYC = (GREEN_TIME_S + YELLOW_TIME_S + FULL_RED_TIME_S) * CLK_FREQ_HZ;
    localparam int ONE_CYCLE_CYC = ONE_PHASE_CYC * 4;  // 400 clk
    localparam int SIM_CLK_CYCLES = ONE_CYCLE_CYC * 2 + 40;  // 跑两轮


    // DUT io
    logic clk;
    logic rst;
    logic clk_posedge;

    tl_light_t light_ew_thru, light_ew_left, light_sn_thru, light_sn_left;
    logic [CNT_W-1:0] cnt_ew_thru, cnt_ew_left, cnt_sn_thru, cnt_sn_left;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    trafficlight #(
        .CNT_W          (CNT_W),
        .FULL_RED_TIME_S(FULL_RED_TIME_S),
        .YELLOW_TIME_S  (YELLOW_TIME_S),
        .GREEN_TIME_S   (GREEN_TIME_S)
    ) dut (
        .clk          (clk),
        .rst          (rst),
        .clk_posedge  (clk_posedge),
        .light_ew_thru(light_ew_thru),
        .light_ew_left(light_ew_left),
        .light_sn_thru(light_sn_thru),
        .light_sn_left(light_sn_left),
        .cnt_ew_thru  (cnt_ew_thru),
        .cnt_ew_left  (cnt_ew_left),
        .cnt_sn_thru  (cnt_sn_thru),
        .cnt_sn_left  (cnt_sn_left)
    );

    initial begin
        rst         = 1'b1;
        clk_posedge = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
        repeat (SIM_CLK_CYCLES) @(posedge clk);
        $display("===== Simulation finished @ %0t =====", $time);
        $finish;
    end

    // print fsm state when state change
    tl_light_t past_light_ew_thru, past_light_ew_left, past_light_sn_thru, past_light_sn_left;
    logic [CNT_W-1:0] past_cnt_ew_thru, past_cnt_ew_left, past_cnt_sn_thru, past_cnt_sn_left;

    always @(posedge clk) begin
        if (rst) begin
            past_light_ew_thru <= light_ew_thru;
            past_light_ew_left <= light_ew_left;
            past_light_sn_thru <= light_sn_thru;
            past_light_sn_left <= light_sn_left;
            past_cnt_ew_thru   <= cnt_ew_thru;
            past_cnt_ew_left   <= cnt_ew_left;
            past_cnt_sn_thru   <= cnt_sn_thru;
            past_cnt_sn_left   <= cnt_sn_left;
            $display("t=%6t | EWt=%s(%0d) EWl=%s(%0d) SNt=%s(%0d) SNl=%s(%0d)", $time,
                     light_ew_thru.name(), cnt_ew_thru, light_ew_left.name(), cnt_ew_left,
                     light_sn_thru.name(), cnt_sn_thru, light_sn_left.name(), cnt_sn_left);
        end else begin
            if ({light_ew_thru, light_ew_left, light_sn_thru, light_sn_left,
                 cnt_ew_thru, cnt_ew_left, cnt_sn_thru, cnt_sn_left} !==
                {past_light_ew_thru, past_light_ew_left, past_light_sn_thru, past_light_sn_left,
                 past_cnt_ew_thru, past_cnt_ew_left, past_cnt_sn_thru, past_cnt_sn_left})
            begin
                $display("t=%6t | EWt=%s(%0d) EWl=%s(%0d) SNt=%s(%0d) SNl=%s(%0d)", $time,
                         light_ew_thru.name(), cnt_ew_thru, light_ew_left.name(), cnt_ew_left,
                         light_sn_thru.name(), cnt_sn_thru, light_sn_left.name(), cnt_sn_left);
            end
            past_light_ew_thru <= light_ew_thru;
            past_light_ew_left <= light_ew_left;
            past_light_sn_thru <= light_sn_thru;
            past_light_sn_left <= light_sn_left;
            past_cnt_ew_thru   <= cnt_ew_thru;
            past_cnt_ew_left   <= cnt_ew_left;
            past_cnt_sn_thru   <= cnt_sn_thru;
            past_cnt_sn_left   <= cnt_sn_left;
        end
    end

    initial begin
        $dumpfile("build/tb_trafficlight.fst");
        $dumpvars(0, tb_trafficlight);
    end


endmodule
