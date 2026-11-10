
`include "define.vh"

module regfile (
      input logic clk
    , input logic rst

    , input logic [`REG_ADDR_BW] write_addr
    , input logic [     `REG_BW] write_data
    , input logic                wen

    , input  logic [`REG_ADDR_BW] read_addr1
    , output logic [     `REG_BW] read_data1
    , input  logic                read_en1

    , input  logic [`REG_ADDR_BW] read_addr2
    , output logic [     `REG_BW] read_data2
    , input  logic                read_en2
);

    logic [`REG_BW] regs[32];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= `ZERO32;
            end
        end else if (wen && write_addr != 0) begin
            regs[write_addr] <= write_data;
        end
    end

    assign read_data1 = (read_en1 && read_addr1 != 0) ? regs[read_addr1] : `ZERO32;
    assign read_data2 = (read_en2 && read_addr2 != 0) ? regs[read_addr2] : `ZERO32;


endmodule
