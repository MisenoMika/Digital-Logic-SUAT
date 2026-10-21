// The fsm sequence
// EW through -> EW left -> SN through -> SN left
// Every time the direction changes, there go for a full L_RED light for 2 seconds.
module trafficlight #(
    parameter int unsigned CNT_W = 8,
    parameter int unsigned FULL_RED_TIME_S = 2,
    parameter int unsigned YELLOW_TIME_S = 3,
    parameter int unsigned GREEN_TIME_S = 5
) (
    input logic clk,
    input logic rst,
    input logic clk_posedge,

    // Traffic light leds
    output lab3_pkg::tl_light_t light_ew_thru,  // East-West through light
    output lab3_pkg::tl_light_t light_ew_left,  // East-West left turn light
    output lab3_pkg::tl_light_t light_sn_thru,  // South-North through light
    output lab3_pkg::tl_light_t light_sn_left,  // South-North left turn light

    // Traffic light counter(7-seg)
    output logic [CNT_W-1:0] cnt_ew_thru,  // East-West through light counter
    output logic [CNT_W-1:0] cnt_ew_left,  // East-West left light counter
    output logic [CNT_W-1:0] cnt_sn_thru,  // South-North through light counter
    output logic [CNT_W-1:0] cnt_sn_left   // South-North left light counter
);
    import lab3_pkg::*;
    localparam int unsigned ALL_RED_TIME_S = GREEN_TIME_S + YELLOW_TIME_S + FULL_RED_TIME_S;
    localparam int unsigned RESET_TIME_S   = ALL_RED_TIME_S * 3 + FULL_RED_TIME_S;

    logic cnt_ew_thru_done;
    logic cnt_ew_left_done;
    logic cnt_sn_thru_done;
    logic cnt_sn_left_done;

    tl_state_t tl_state;
    tl_state_t tl_n_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            tl_state <= S_EW_THRU_G;
        end else if (clk_posedge) begin
            tl_state <= tl_n_state;
        end
    end

    // ---------------------
    // FSM Next State Logic
    // ---------------------

    always_comb begin
        tl_n_state = tl_state;

        unique case (tl_state)
            S_EW_THRU_G: begin
                if (cnt_ew_thru_done) begin
                    tl_n_state = S_EW_THRU_Y;
                end
            end

            S_EW_THRU_Y: begin
                if (cnt_ew_thru_done) begin
                    tl_n_state = S_RED_TO_EW_LEFT;
                end
            end

            S_RED_TO_EW_LEFT: begin
                if (cnt_ew_left_done) begin
                    tl_n_state = S_EW_LEFT_G;
                end
            end

            S_EW_LEFT_G: begin
                if (cnt_ew_left_done) begin
                    tl_n_state = S_EW_LEFT_Y;
                end
            end

            S_EW_LEFT_Y: begin
                if (cnt_ew_left_done) begin
                    tl_n_state = S_RED_TO_SN_THRU;
                end
            end

            S_RED_TO_SN_THRU: begin
                if (cnt_sn_thru_done) begin
                    tl_n_state = S_SN_THRU_G;
                end
            end

            S_SN_THRU_G: begin
                if (cnt_sn_thru_done) begin
                    tl_n_state = S_SN_THRU_Y;
                end
            end

            S_SN_THRU_Y: begin
                if (cnt_sn_thru_done) begin
                    tl_n_state = S_RED_TO_SN_LEFT;
                end
            end

            S_RED_TO_SN_LEFT: begin
                if (cnt_sn_left_done) begin
                    tl_n_state = S_SN_LEFT_G;
                end
            end

            S_SN_LEFT_G: begin
                if (cnt_sn_left_done) begin
                    tl_n_state = S_SN_LEFT_Y;
                end
            end

            S_SN_LEFT_Y: begin
                if (cnt_sn_left_done) begin
                    tl_n_state = S_RED_TO_EW_THRU;
                end
            end

            S_RED_TO_EW_THRU: begin
                if (cnt_ew_thru_done) begin
                    tl_n_state = S_EW_THRU_G;
                end
            end

            default: begin
                tl_n_state = tl_state;
            end
        endcase
    end

    // ---------------------
    // Traffic Light Conversion
    // ---------------------
    always_comb begin
        light_ew_thru = L_RED;
        light_ew_left = L_RED;
        light_sn_thru = L_RED;
        light_sn_left = L_RED;
        case (tl_state)
            S_EW_THRU_G: begin
                light_ew_thru = L_GREEN;
            end

            S_EW_THRU_Y: begin
                light_ew_thru = L_YELLOW;
            end

            S_EW_LEFT_G: begin
                light_ew_left = L_GREEN;
            end

            S_EW_LEFT_Y: begin
                light_ew_left = L_YELLOW;
            end

            S_SN_THRU_G: begin
                light_sn_thru = L_GREEN;
            end

            S_SN_THRU_Y: begin
                light_sn_thru = L_YELLOW;
            end

            S_SN_LEFT_G: begin
                light_sn_left = L_GREEN;
            end

            S_SN_LEFT_Y: begin
                light_sn_left = L_YELLOW;
            end

            default: begin
                // all L_RED
                light_ew_thru = L_RED;
                light_ew_left = L_RED;
                light_sn_thru = L_RED;
                light_sn_left = L_RED;
            end
        endcase
    end

    // --------------------
    // Traffic light Counter
    // --------------------

    assign cnt_ew_thru_done = (cnt_ew_thru == 1);
    assign cnt_ew_left_done = (cnt_ew_left == 1);
    assign cnt_sn_thru_done = (cnt_sn_thru == 1);
    assign cnt_sn_left_done = (cnt_sn_left == 1);

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt_ew_thru <= CNT_W'(GREEN_TIME_S);
            cnt_ew_left <= CNT_W'(ALL_RED_TIME_S);
            cnt_sn_thru <= CNT_W'(ALL_RED_TIME_S * 2);
            cnt_sn_left <= CNT_W'(ALL_RED_TIME_S * 3);
        end else if (clk_posedge) begin
            cnt_ew_thru <= cnt_ew_thru - 1;
            cnt_ew_left <= cnt_ew_left - 1;
            cnt_sn_thru <= cnt_sn_thru - 1;
            cnt_sn_left <= cnt_sn_left - 1;
            unique case (tl_state)
                S_EW_THRU_G: begin
                    if (cnt_ew_thru_done) begin
                        cnt_ew_thru <= CNT_W'(YELLOW_TIME_S);
                    end
                end

                S_EW_THRU_Y: begin
                    if (cnt_ew_thru_done) begin
                        cnt_ew_thru <= CNT_W'(RESET_TIME_S);
                    end
                end

                S_RED_TO_EW_LEFT: begin
                    if (cnt_ew_left_done) begin
                        cnt_ew_left <= CNT_W'(GREEN_TIME_S);
                    end
                end

                S_EW_LEFT_G: begin
                    if (cnt_ew_left_done) begin
                        cnt_ew_left <= CNT_W'(YELLOW_TIME_S);
                    end
                end

                S_EW_LEFT_Y: begin
                    if (cnt_ew_left_done) begin
                        cnt_ew_left <= CNT_W'(RESET_TIME_S);
                    end
                end

                S_RED_TO_SN_THRU: begin
                    if (cnt_sn_thru_done) begin
                        cnt_sn_thru <= CNT_W'(GREEN_TIME_S);
                    end
                end

                S_SN_THRU_G: begin
                    if (cnt_sn_thru_done) begin
                        cnt_sn_thru <= CNT_W'(YELLOW_TIME_S);
                    end
                end

                S_SN_THRU_Y: begin
                    if (cnt_sn_thru_done) begin
                        cnt_sn_thru <= CNT_W'(RESET_TIME_S);
                    end
                end

                S_RED_TO_SN_LEFT: begin
                    if (cnt_sn_left_done) begin
                        cnt_sn_left <= CNT_W'(GREEN_TIME_S);
                    end
                end

                S_SN_LEFT_G: begin
                    if (cnt_sn_left_done) begin
                        cnt_sn_left <= CNT_W'(YELLOW_TIME_S);
                    end
                end

                S_SN_LEFT_Y: begin
                    if (cnt_sn_left_done) begin
                        cnt_sn_left <= CNT_W'(RESET_TIME_S);
                    end
                end

                S_RED_TO_EW_THRU: begin
                    if (cnt_ew_thru_done) begin
                        cnt_ew_thru <= CNT_W'(GREEN_TIME_S);
                    end
                end
            endcase
        end
    end

`ifndef __SYNTHESIS__
    tl_state_t past_tl_state;
    always_ff @(posedge clk) begin
        if (rst) begin
            past_tl_state <= S_EW_THRU_G;
        end else if (tl_state !== past_tl_state) begin
            $display("==========================");
            $display("t=%6t | tl_state=%s", $time, tl_state.name());
            $display("==========================");
        end
        past_tl_state <= tl_state;
    end
`endif
endmodule
