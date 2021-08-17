
`include "text_display.v"

`ifndef prs_game
`define prs_game

module prs_game(
    input clk,
    input resetn,
    input enable,
    input ps2_data,
    input ps2_clk,

    output reg[7:0] cathode_array,
    output reg[7:0] anode_array 
);
    wire[7:0] cathode_array_w;
    wire[7:0] anode_array_w;
    reg[3:0] SELECTOR;
    reg[31:0] counter_delay;
    reg[15:0] counter_select;
    wire disable_text_w;
    parameter DELAY = 300000000;
    // parameter DELAY = 500;

    reg[7:0] STATE;

    parameter IDLE = 8'b00000001;
    parameter START = 8'b00000010;
    parameter SELECT = 8'b00000100;
    parameter DELAY_STATE = 8'b00001000;
    parameter USER_CHOICE = 8'b00010000;
    parameter OPTION_DISPLAY = 8'b00100000;
    parameter RIVAL = 8'b01000000;
    parameter WIN_LOST = 8'b10000000;

    reg start_done;
    reg select_done;
    reg user_choice_done;
    reg rival_text_done;
    reg rival_done;

    always @ (*) begin
        if(resetn) begin
            cathode_array <= cathode_array_w;
            anode_array <= anode_array_w;
        end else begin
            anode_array <= 8'b11111111;
            cathode_array <= 8'b00000000;
        end
    end

    
    reg[5:0] gen_counter;
    reg read_flag;
    reg[7:0] mouse_data;
    reg[1:0] option_switch;
    reg[1:0] enemy_choice;

    reg middle_auto;
    reg left_auto;

    /* mouse data read */
    always @ (negedge ps2_clk) begin
        if(resetn) begin
            case(1)
                ps2_data == 0 && read_flag == 0: begin
                    read_flag <= 1;
                    gen_counter <= gen_counter + 1;
                end
                read_flag: begin
                    if(gen_counter == 32) begin
                        gen_counter <= 0;
                        read_flag <= 0;
                    end else begin
                        gen_counter <= gen_counter + 1;
                    end

                    if(gen_counter < 9) begin
                        mouse_data[gen_counter] <= ps2_data;
                    end else begin
                        mouse_data <= mouse_data;
                    end
                end
            endcase
        end else begin
            gen_counter <= 0;
            read_flag <= 0;
            mouse_data <= 0;
        end
    end

    /* game flow */
    always @ (posedge clk) begin
        if(resetn) begin
            middle_auto <= 0;
            left_auto <= 1;
            case(STATE)
                IDLE: begin
                    if(start_done && select_done && user_choice_done && rival_done) begin
                        STATE <= WIN_LOST;
                    end else if(start_done && select_done && user_choice_done && ~rival_done) begin
                        STATE <= RIVAL;
                    end else if(start_done && select_done && ~user_choice_done && ~rival_done) begin
                        STATE <= USER_CHOICE;
                    end else if(start_done && ~select_done && ~user_choice_done && ~rival_done) begin
                        STATE <= SELECT;
                    end else begin
                        STATE <= START;
                    end
                end
                START: begin
                    /* Start message */
                    start_done <= 1;
                    SELECTOR <= 0;
                    STATE <= DELAY_STATE;
                end
                SELECT: begin
                    /* Select message */
                    select_done <= 1;
                    SELECTOR <= 1;
                    STATE <= DELAY_STATE;
                end
                DELAY_STATE: begin
                    /* programmed delay */
                    if(counter_delay == DELAY) begin
                        STATE <= IDLE;
                        counter_delay <= 0;
                    end else begin
                        counter_delay <= counter_delay + 1;
                        STATE <= DELAY_STATE;
                    end
                end
                USER_CHOICE: begin
                    /* user choice */
              
                    /* middle click */
                    if(/*mouse_data[2] == 0*/middle_auto) begin
                        if(option_switch == 2) begin
                            option_switch <= 0;
                            STATE <= OPTION_DISPLAY;
                        end else begin
                            option_switch <= option_switch + 1;
                            STATE <= OPTION_DISPLAY;
                        end
                    end else begin
                        option_switch <= option_switch;
                        STATE <= OPTION_DISPLAY;
                    end
                end 
                OPTION_DISPLAY: begin
                    if(option_switch == 0) begin
                        SELECTOR <= 4;
                        /* left click */
                        if(/*mouse_data[0] == 1*/left_auto) begin
                            STATE <= DELAY_STATE;
                            user_choice_done <= 1;
                        end else begin
                            STATE <= USER_CHOICE;
                        end
                    end else if(option_switch == 1) begin
                        SELECTOR <= 2;
                        /* left click */
                        if(/*mouse_data[0] == 1*/left_auto) begin
                            STATE <= DELAY_STATE;
                            user_choice_done <= 1;
                        end else begin
                            STATE <= USER_CHOICE;
                        end
                    end else begin
                        SELECTOR <= 3;
                        /* left click */
                        if(/*mouse_data[0] == 1*/left_auto) begin
                            STATE <= DELAY_STATE;
                            user_choice_done <= 1;
                        end else begin
                            STATE <= USER_CHOICE;
                        end
                    end
                end
                RIVAL: begin
                    if(~rival_text_done) begin
                        SELECTOR <= 5;
                        STATE <= DELAY_STATE;
                        rival_text_done <= 1;
                        //enemy_choice <= (enemy_choice << 1)|(enemy_choice[0]^enemy_choice[1]);
                        enemy_choice <= 2;
                    end else begin
                        /* random enemy choice */
                        if(enemy_choice==0) begin
                            SELECTOR <= 4;
                            STATE <= DELAY_STATE;
                            rival_done <= 1;
                        end else if(enemy_choice==1) begin
                            SELECTOR <= 2;
                            STATE <= DELAY_STATE;
                            rival_done <= 1;
                        end else if(enemy_choice==2) begin
                            SELECTOR <= 3;
                            STATE <= DELAY_STATE;
                            rival_done <= 1;
                        end else begin
                            STATE <= RIVAL;
                        end
                    end
                end
                WIN_LOST: begin
                    if(option_switch == 2 && enemy_choice == 1) begin
                        SELECTOR <= 6;
                    end else if(option_switch == 2 && enemy_choice == 0) begin
                        SELECTOR <= 7;
                    end else if(option_switch == 1 && enemy_choice == 0) begin
                        SELECTOR <= 6;
                    end else if(option_switch == 0 && enemy_choice == 1) begin
                        SELECTOR <= 7;
                    end else if(option_switch == 0 && enemy_choice == 2) begin
                        SELECTOR <= 6;
                    end else if(option_switch == 1 && enemy_choice == 2) begin
                        SELECTOR <= 7;
                    end else begin
                        SELECTOR <= 8;
                    end
                end
            endcase
        end else begin
            start_done <= 0;
            select_done <= 0;
            option_switch <= 0;
            user_choice_done <= 0;
            counter_delay <= 0;
            STATE <= IDLE;
            enemy_choice <= 2;
            rival_text_done <= 0;
            rival_done <= 0;
        end
    end

text_display text_display_inst(
    .clk(clk),
    .resetn(resetn),
    .enable(enable),
    .selector(SELECTOR),

    .cathode_array(cathode_array_w),
    .anode_array(anode_array_w),
    .disable_text (disable_text_w)
);
endmodule
`endif
