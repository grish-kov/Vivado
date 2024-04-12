`timescale 1ns / 1ps

module lab2c_top#(
    parameter G_CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real G_BLINK_PERIOD[3:0] = {1, 0.5, 2, 3}
)
(
    input wire [1:0] i_rst,
    input wire i_clk_p,
    input wire i_clk_n,
    output logic [3:0] o_led_d
);
    wire [3:0] m_led;
    
    buff u_buf(
        .i_clk_p(i_clk_p),
        .i_clk_n(i_clk_n),
        .o_clk(o_clk)
    );    
    
    led_blink u_led[3:0](
        .i_clk(o_clk),
        .o_led(m_led)    
    );
        defparam u_led[0].G_BLINK_PERIOD = G_BLINK_PERIOD[0];
        defparam u_led[1].G_BLINK_PERIOD = G_BLINK_PERIOD[1];
        defparam u_led[2].G_BLINK_PERIOD = G_BLINK_PERIOD[2];
        defparam u_led[3].G_BLINK_PERIOD = G_BLINK_PERIOD[3];
    
    mux u_mux(
        .i_x(m_led),
        .o_f(w_led),
        .i_sel(i_rst)
    );
    assign o_led_d = '{default: w_led};
endmodule
