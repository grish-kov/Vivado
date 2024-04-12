`timescale 1ns / 1ps
module tb_m_w_b #(
        parameter G_CLK_FREQUENCY  = 200.0e6,// Гц
        parameter real G_BLINK_PERIOD[0:3] = {1e-8, 0.5e-7, 2e-8, 1.5e-8}
    );
    localparam int C_T_CLK = 1.0e9 / G_CLK_FREQUENCY;
    
    bit i_clk = 1'b0;
    bit [0:1] i_rst = 2'b00;
    logic o_led_d = '0;
    
    
    top_multiplex_with_blink#( 
        .G_CLK_FREQUENCY(G_CLK_FREQUENCY),
        .G_BLINK_PERIOD(G_BLINK_PERIOD))
    UUT(
        .i_rst(i_rst),
        .i_clk_p(i_clk),
        .i_clk_n(!i_clk),
        .o_led_d(o_led_d)
    );

    always #(C_T_CLK/2) i_clk = ~i_clk;
    always#(300) i_rst = i_rst + 1;
    
endmodule
