`include "segment_hex.v"
`include "segmentdec.v"

`ifndef segment_switch
`define segment_switch

module segment_switch(
    input clk,
    input resetn,
    input[31:0] number,
    input switch,

    output reg [7:0] cathode_array,
    output reg [7:0] anode_array
);

    wire[7:0] anode_hex, anode_dec;
    wire[7:0] cathode_hex, cathode_dec;


    always @ (posedge clk) begin
        if(resetn) begin
            if(switch == 0) begin
                cathode_array <= cathode_hex;
                anode_array <= anode_hex;
            end else if (switch == 1) begin
                cathode_array <= cathode_dec;
                anode_array <= anode_dec;        
            end else begin
                cathode_array <= 0;
                anode_array <= 0;
            end
        end else begin
            cathode_array <= 0;
            anode_array <= 0;          
        end
    end

/* segments instances */
segment_hex segment_hex_inst(
    .clk(clk),
    .resetn(resetn),
    .hex_input(number),
    .cathode_array(cathode_hex),
    .anode_array(anode_hex)
);

segmentdec segment_dec_inst(
    .clk(clk),
    .resetn(resetn),
    .num_bit(number),
    .catodo(cathode_dec),
    .anodo(anode_dec) 
);

endmodule
`endif