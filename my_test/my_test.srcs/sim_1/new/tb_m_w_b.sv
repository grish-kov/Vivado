`timescale 1ns / 1ps
module tb_m_w_b #(
        parameter CLK_FREQUENCY  = 200.0e6,// Гц
        parameter real BLINK_PERIOD[0:3] = {1e-9, 0.5e-9, 2e-9, 3e-9}
    );
    localparam int T_CLK = 1.0e9 / CLK_FREQUENCY;
    
    bit i_clk = 1'b0;
    bit [0:1] i_rst = 2'b00;
    logic [0:3] o_led_d = '0;
    
    
    multiplex_with_blink#( 
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .BLINK_PERIOD(BLINK_PERIOD))
    UUT(
        .i_rst(i_rst),
        .i_clk_p(i_clk),
        .i_clk_n(!i_clk),
        .o_led_d(o_led_d)
    );

    always #(T_CLK/2) i_clk = ~i_clk;
    always#(300) i_rst = i_rst + 1;
endmodule
