module light_top (
    clk
    , reset
    , east
    , west
    , north
    , south
    , code
    , cs_o
);
    import lab3_pkg::*;

    input clk, reset;
    // output led_out;  // out for 24 LED
    output east, west, north, south;  // out for 4 direction traffic light
    output code, cs_o;

    wire clk, reset;
    // wire [23:0] led_out;
    wire [2:0] east, west, north, south;
    wire [7:0] code, cs_o;

    wire [31:0] seg_out;  // out for seg
    tl_light_t
        light_east_west_through,
        light_east_west_leftturn,
        light_south_north_through,
        light_south_north_leftturn;
    wire [7:0]  count_east_west_through, count_east_west_leftturn,
               count_south_north_through, count_south_north_leftturn;

    logic clk_posedge;

    // 计算 2^width - 1 需要的十进制位数
    function automatic int calc_bcd_digits(input int width);
        int digits = 1;
        longint unsigned max_val = (longint'(1) << width) - 1;
        longint unsigned pow10 = 10;
        while (pow10 <= max_val) begin
            digits++;
            pow10 *= 10;
        end
        return digits;
    endfunction


    logic [31:0] bcd_out;

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_bin2bcd
            bin2bcd #(
                .DATA_WIDTH(8)
            ) u_bin2bcd (
                .bin_in (seg_out[i*8+:8]),
                .bcd_out(bcd_out[i*8+:8])
            );
        end
    endgenerate

    trafficlight u_trafficlight (
        .clk(clk),
        .rst(reset),
        .clk_posedge(clk_posedge),
        .light_ew_thru(light_east_west_through),
        .light_ew_left(light_east_west_leftturn),
        .light_sn_thru(light_south_north_through),
        .light_sn_left(light_south_north_leftturn),
        .cnt_ew_thru(count_east_west_through),
        .cnt_ew_left(count_east_west_leftturn),
        .cnt_sn_thru(count_south_north_through),
        .cnt_sn_left(count_south_north_leftturn)
    );

    clkgen u_clkgen (
        .clk(clk),
        .rst(reset),
        .clk_posedge(clk_posedge)
    );
    assign east = light_east_west_through;
    assign west = light_east_west_leftturn;
    assign south = light_south_north_through;
    assign north = light_south_north_leftturn;
    // assign led_out = {
    //     (light_east_west_through[2] == 1),
    //     (light_east_west_leftturn[2] == 1),
    //     (light_south_north_through[2] == 1),
    //     (light_south_north_leftturn[2] == 1),
    //     4'b0000,
    //     (light_east_west_through[1] == 1),
    //     (light_east_west_leftturn[1] == 1),
    //     (light_south_north_through[1] == 1),
    //     (light_south_north_leftturn[1] == 1),
    //     4'b0000,
    //     (light_east_west_through[0] == 1),
    //     (light_east_west_leftturn[0] == 1),
    //     (light_south_north_through[0] == 1),
    //     (light_south_north_leftturn[0] == 1),
    //     4'b0000
    // };

    assign seg_out = {
        count_east_west_through,
        count_east_west_leftturn,
        count_south_north_through,
        count_south_north_leftturn
    };

    seg_driver u_seg_driver (
          .clk  (clk)
        , .data (bcd_out)
        , .reset(reset)
        , .code (code)
        , .cs_o (cs_o)
    );

endmodule
