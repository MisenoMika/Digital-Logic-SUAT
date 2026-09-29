module lfsr #(
    parameter int unsigned DATA_WIDTH = 4
) (
    input logic clk,
    input logic rst,
    output logic [DATA_WIDTH - 1:0] lfsr_out
);

    logic [DATA_WIDTH - 1:0] lfsr_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_reg <= '1;  // Initialize to all ones
        end else begin
            lfsr_reg <= {lfsr_reg[DATA_WIDTH-2:0], lfsr_reg[DATA_WIDTH-1] ^ lfsr_reg[DATA_WIDTH-2]};
        end
    end

    assign lfsr_out = lfsr_reg;
endmodule
