`timescale 1ns / 1ps

module led_run
#(
    parameter G_CLK_FREQUENCY  = 200.0e6, // Гц
    parameter G_BLINK_PERIOD = 1.0, // секунды
    parameter G_dir = 1 
)
(
    input wire i_rst,
    input wire i_clk,
    output logic [3:0] o_led=4'b0001
);
    
    localparam int C_COUNTER_PERIOD = (G_BLINK_PERIOD * G_CLK_FREQUENCY);
    localparam int C_COUNTER_WIDTH = ($ceil($clog2(C_COUNTER_PERIOD + 1)));
    
    reg [C_COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == C_COUNTER_PERIOD-1) begin
            counter_value <= 0;
           
        end 
        else begin
            counter_value <= counter_value + 1;
        end;
        if (i_rst) o_led=4'b0001;
        if(counter_value == C_COUNTER_PERIOD/2) begin
            if(G_dir) begin
                o_led <= o_led <<< 1;
                if(o_led == 4'b1000) o_led <= 4'b0001;
            end
            else begin 
                o_led <= o_led >>> 1;
                if(o_led == 4'b0001) o_led <= 4'b1000;
            end
        end;
        
    end
    
endmodule