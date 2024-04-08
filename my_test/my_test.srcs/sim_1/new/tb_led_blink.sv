`timescale 1ns / 1ps
module tb_led_blink
#(
    parameter CLK_FREQUENCY = 50.0e6, 
    parameter BLINK_PERIOD = 1
);
  
    localparam T_CLK = int(1.0e9 / CLK_FREQUENCY); // ns
    //-- Signals
    bit i_clk_n = 1'b0; 
    bit i_clk_p = 1'b0;
    bit i_rst = 1'b0;
   
    led_blink# (.CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD)) UUT_2 (
    .i_clk_p (i_clk_p),
    .i_rst(i_rst),
    .o_led ());
  
    always #(T_CLK/2) i_clk_p = ~i_clk_p;
    initial begin 
        i_rst = 1'b0;
        #10e3 i_rst = 1'b1; 
        #(500000*T_CLK) i_rst = 1'b0;
    end
endmodule