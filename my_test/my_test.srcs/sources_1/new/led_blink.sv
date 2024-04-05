`timescale 1ns / 1ps
module led_blink
#(
    parameter CLK_FREQUENCY = 200.0e6, // Гц
    parameter BLINK_PERIOD = 1.0 // секунды
)
(
    input wire i_clk,
    input wire i_rst, //!!!
    output logic [3:0] o_led='0
);
    //-- Constants
    localparam COUNTER_PERIOD = int(BLINK_PERIOD * CLK_FREQUENCY);
    localparam COUNTER_WIDTH = int($ceil($clog2(COUNTER_PERIOD +1)));

    //-- Counter
    logic on_led=0;
    reg [COUNTER_WIDTH -1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin
        if (i_rst || counter_value == COUNTER_PERIOD-1) begin
            counter_value <= 0;
        end
        else begin
            counter_value <= counter_value +1;
        end;

        if (counter_value < COUNTER_PERIOD/2) begin
            on_led<=0;
        end
        else begin
            on_led<=1;
        end;
        o_led[3:1]<={$size(o_led[3:1]){on_led}};
        o_led[0]<=!on_led;
    end
endmodule