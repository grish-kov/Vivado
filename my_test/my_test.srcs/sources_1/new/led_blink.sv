`timescale 1ns / 1ps
module buff(
    input wire i_rst,
    input wire i_clk_n,
    input wire i_clk_p,
    output wire o_clk    
);
    IBUFDS #(
      .DIFF_TERM("FALSE"),
      .IBUF_LOW_PWR("TRUE"),
      .IOSTANDARD("DEFAULT")
    ) IBUFDS_inst (
      .O(w_clk_in),
      .I(i_clk_p),
      .IB(i_clk_n)
    );
    
    BUFG BUFG_inst (
      .O(o_clk),
      .I(w_clk_in)
    );
endmodule 

module led_blink
#(
    parameter CLK_FREQUENCY = 50.0e6, // Гц
    parameter BLINK_PERIOD = 1.0 // секунды
)
(
    (* MARK_DEBUG="true" *)

    input wire i_rst,
    input wire i_clk,
    output logic [3:0] o_led=4'b0001
);

    //-- Constants
    localparam int COUNTER_PERIOD = (BLINK_PERIOD * CLK_FREQUENCY);
    localparam int COUNTER_WIDTH = ($ceil($clog2(COUNTER_PERIOD + 1)));

    //-- Counter
    logic on_led=0; int i = 0;
    
    reg [COUNTER_WIDTH - 1 : 0] counter_value = '0;
    always_ff @(posedge i_clk) begin     
       
        if (i_rst || counter_value == COUNTER_PERIOD-1) begin
            counter_value <= 0;
        end 
        else begin
            counter_value <= counter_value + 1;
        end;
        if (counter_value < COUNTER_PERIOD/2)
            on_led <= 0;
        else 
            on_led <= 1;
      
        if(counter_value == COUNTER_PERIOD/2) begin
            o_led <= o_led <<< 1;
            if(o_led == 4'b1000) o_led <= 4'b0001;
        end;
        
    end
    
endmodule

module top(
    
    input wire i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    output logic [3:0] o_led

);
    
    buff BUFF(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .i_rst(i_rst),
        .o_clk(o_clk)
    );
    
    led_blink led(
        .i_rst(i_rst),
        .i_clk(o_clk),
        .o_led(o_led)    
    );
    
endmodule