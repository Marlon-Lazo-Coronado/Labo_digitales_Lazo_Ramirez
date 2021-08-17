`include "lut_multiplier_2b_cond.v"

module lut_multiplier_4b_cond
(
    input resetn_4b,
    input clk_4b,
    input[3:0] source_number_4b_0,
    input[3:0] source_number_4b_1,

    output reg[7:0] result_4b
);

wire[7:0] result_4b_0, result_4b_1;

always @ (*) begin
    if(resetn_4b == 0) begin
        result_4b = 0;
    end
    else begin
        result_4b = result_4b_0 + 4*result_4b_1;
    end
end

//lut_multiplier_2b instances.

lut_multiplier_2b_cond lut_2B_0(
    .resetn_2b              (resetn_4b),
    .clk_2b                 (clk_4b),
    .source_number_2b_0     (source_number_4b_0),
    .source_number_2b_1     (source_number_4b_1[1:0]),
    .result_2b              (result_4b_0)
);

lut_multiplier_2b_cond lut_2B_1(
    .resetn_2b              (resetn_4b),
    .clk_2b                 (clk_4b),
    .source_number_2b_0     (source_number_4b_0),
    .source_number_2b_1     (source_number_4b_1[3:2]),
    .result_2b              (result_4b_1)
);

endmodule