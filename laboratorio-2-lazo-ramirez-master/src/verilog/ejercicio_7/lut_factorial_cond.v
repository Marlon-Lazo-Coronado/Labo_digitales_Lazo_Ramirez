`include "lut_multiplier_32b_cond.v"

module lut_factorial_cond
(
    input resetn_32b,
    input clk_32b,
    input[31:0] source_number_32b,
    input start,
    output reg[63:0] factorial,
    output reg output_ready
);

/*--------------------------------------------------------------------------------------------------------------*/

reg assign_input, counter_protection;
reg[31:0] number_less_one;
reg[63:0] assign_result;
wire[63:0] fact_LSB, fact_MSB;

/*--------------------------------------------------------------------------------------------------------------*/


always @ (*) begin
    if(resetn_32b == 0) begin
        assign_input = 0;
    end else begin
        if(start) begin
            assign_input = 1;
        end else begin
            assign_input = 0;
        end
    end
end

always @ (*) begin
    if(resetn_32b == 0) begin
        assign_result = 0;
    end else begin
        if(start) begin
            if(counter_protection == 1) begin
                factorial = assign_result;
            end
        end else begin
            assign_result = 0;
        end
    end
end

always @ (posedge clk_32b) begin
    if(resetn_32b == 0) begin
        factorial <= 0;
        output_ready <= 0;
        number_less_one <= 0;
        counter_protection <= 0;
    end else begin
        if(start) begin
            if(assign_input == 1) begin
                factorial[31:0] <= source_number_32b;
                assign_input <= 0;
                number_less_one <= source_number_32b - 1;
            end
            else begin
                factorial <= fact_LSB + fact_MSB;
                assign_result <= factorial;
                if(counter_protection == 0) begin
        
                end else begin
                    number_less_one <= number_less_one - 1;
                    if(number_less_one == 2) begin
                        output_ready = 1;
                    end
                    else if(number_less_one == 1) begin
                        number_less_one <= 1;
                        //factorial <= assign_result;
                    end 
                end
            end
            counter_protection <= counter_protection + 1;
        end else begin
            factorial <= 0;
            output_ready <= 0;
            number_less_one <= 0;
            counter_protection <= 0;
        end
    end
end

/*--------------------------------------------------------------------------------------------------------------*/

//lut_multiplier_32b instances

lut_multiplier_32b_cond lut_32_LSB(
    .resetn_32b             (resetn_32b),
    .clk_32b                (clk_32b),
    .source_number_32b_0    (factorial[31:0]),
    .source_number_32b_1    (number_less_one),
    .result_64b             (fact_LSB)
);
      
lut_multiplier_32b_cond lut_32_MSB(
    .resetn_32b             (resetn_32b),
    .clk_32b                (clk_32b),
    .source_number_32b_0    (factorial[63:32]),
    .source_number_32b_1    (number_less_one),
    .result_64b             (fact_MSB)
);

endmodule