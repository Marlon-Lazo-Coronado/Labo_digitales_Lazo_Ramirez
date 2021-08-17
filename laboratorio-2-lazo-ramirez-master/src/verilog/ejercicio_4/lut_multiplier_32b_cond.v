`include "lut_multiplier_4b_cond.v"

module lut_multiplier_32b_cond
(
    input resetn_32b,
    input clk_32b,
    input[31:0] source_number_32b_0,
    input[31:0] source_number_32b_1,

    output reg[63:0] result_64b
);

wire[63:0] result_64b_0, result_64b_1, result_64b_2, result_64b_3, result_64b_4, result_64b_5, result_64b_6, result_64b_7;

always @ (*) begin
    if(resetn_32b == 0) begin
        result_64b = 0;
    end
    else begin
        result_64b = result_64b_0 + (result_64b_1<<4)
                                  + (result_64b_2<<8)
                                  + (result_64b_3<<12)
                                  + (result_64b_4<<16)
                                  + (result_64b_5<<20)
                                  + (result_64b_6<<24)
                                  + (result_64b_7<<28);
    end
end

//lut_4b_multiplier instances.

lut_multiplier_4b_cond lut_4B_0(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[3:0]),
    .result_4b              (result_64b_0)
);

lut_multiplier_4b_cond lut_4B_1(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[7:4]),
    .result_4b              (result_64b_1)
);

lut_multiplier_4b_cond lut_4B_2(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[11:8]),
    .result_4b              (result_64b_2)
);

lut_multiplier_4b_cond lut_4B_3(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[15:12]),
    .result_4b              (result_64b_3)
);

lut_multiplier_4b_cond lut_4B_4(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[19:16]),
    .result_4b              (result_64b_4)
);

lut_multiplier_4b_cond lut_4B_5(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[23:20]),
    .result_4b              (result_64b_5)
);

lut_multiplier_4b_cond lut_4B_6(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[27:24]),
    .result_4b              (result_64b_6)
);

lut_multiplier_4b_cond lut_4B_7(
    .resetn_4b              (resetn_32b),
    .clk_4b                 (clk_32b),
    .source_number_4b_0     (source_number_32b_0),
    .source_number_4b_1     (source_number_32b_1[31:28]),
    .result_4b              (result_64b_7)
);

endmodule