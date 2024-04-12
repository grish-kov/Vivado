`timescale 1ns / 1ps

module lab2a_top#(
    parameter G_CLK_FREQUENCY  = 200.0e6,
    parameter real G_BLINK_PERIOD = 1
)
(
    (* MARK_DEBUG="true" *) input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    (* MARK_DEBUG="true" *) output logic [3:0] o_led
);
    
    buff u_buf(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .i_rst(i_rst),
        .o_clk(o_clk)
    );
    
    led_blink#(
        .G_CLK_FREQUENCY(G_CLK_FREQUENCY),
        .G_BLINK_PERIOD(G_BLINK_PERIOD)
    )
     u_led(
        .i_rst(i_rst),
        .i_clk(o_clk),
        .o_led(o_led)    
    );

endmodule
