`timescale 1ns / 1ps

module led_blink
#(
    parameter G_CLK_FREQUENCY  = 200.0e6,
    parameter G_BLINK_PERIOD = 1.0,
    parameter int G_LED_WIDTH = 4
)
(
    input wire i_rst,
    input wire i_clk,
    output logic [G_LED_WIDTH:0] o_led='0
);
    
    logic on_led = 0;
    
    localparam int C_COUNTER_PERIOD = (G_BLINK_PERIOD * G_CLK_FREQUENCY);
    localparam int C_COUNTER_WIDTH = ($ceil($clog2(C_COUNTER_PERIOD + 1)));
    
    reg [C_COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == C_COUNTER_PERIOD-1)
            counter_value <= 0;
        else 
            counter_value <= counter_value + 1;
      
        if (counter_value < C_COUNTER_PERIOD/2)
            on_led <= 0;
        else 
            on_led <= 1;
            
        o_led[3:1] <= {$size(o_led[3:1]){on_led}};
        o_led[0] <= ~on_led;
        
    end
    
endmodule