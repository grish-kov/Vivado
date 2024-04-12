`timescale 1ns / 1ps

module lab2b_top#(
    parameter G_CLK_FREQUENCY  = 200.0e6,
    parameter real G_BLINK_PERIOD [0:1] = {1, 0.5},
    parameter logic G_dir [0:1] =  {1, 0}
)
(
    (* MARK_DEBUG="true" *) input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    (* MARK_DEBUG="true" *) output logic [7:0] o_led
);
    genvar i;
    
    buff u_buf(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .i_rst(i_rst),
        .o_clk(o_clk)
    );
    
    generate for(i = 0; i <= 1; i++) begin
        led_run#(
            .G_CLK_FREQUENCY(G_CLK_FREQUENCY),
            .G_BLINK_PERIOD(G_BLINK_PERIOD[i]),
            .G_dir(G_dir[i])
        )
         u_led(
            .i_rst(i_rst),
            .i_clk(o_clk),
            .o_led(o_led[4 * (i+1) - 1 : 4 * i])    
        );
        end
    endgenerate

endmodule
