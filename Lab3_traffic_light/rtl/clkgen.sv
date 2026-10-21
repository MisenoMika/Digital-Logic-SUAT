module clkgen #(
    parameter int unsigned CLK_FREQ_HZ  = 100_000_000,
    parameter int unsigned CYCLE_TIME_S = 1
) (
    input  logic clk,
    input  logic rst,
    output logic clk_posedge
);
    logic clk_ff0;
    localparam int unsigned CNT_W = $clog2(CLK_FREQ_HZ * CYCLE_TIME_S);
    logic [CNT_W - 1:0] counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= '0;
            clk_ff0 <= 1'b0;
            clk_posedge <= 1'b0;
        end else begin
            clk_posedge <= 1'b0;

            if (counter == CNT_W'(CLK_FREQ_HZ * CYCLE_TIME_S / 2 - 1)) begin
                counter <= '0;
                clk_ff0 <= ~clk_ff0;

                // generate a posedge pulse
                if (!clk_ff0) clk_posedge <= 1'b1;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end


endmodule
