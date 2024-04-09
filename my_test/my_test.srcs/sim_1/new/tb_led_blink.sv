`timescale 1ns / 1ps
module tb_led_blink
#(
    parameter CLK_FREQUENCY = 200.0e6, 
    parameter BLINK_PERIOD = 1e-6
);
  
    localparam int T_CLK = (1.0e9 / CLK_FREQUENCY); // ns
    //-- Signals
    bit i_clk = 1'b0;
    bit i_rst = 1'b0;
   
    led_blink# (.CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD)) UUT_2 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_led ());
  
    always #(T_CLK/2) i_clk = ~i_clk;
    initial begin 
        i_rst = 1'b0;
        #10e3 i_rst = 1'b1; 
        #(500000*T_CLK) i_rst = 1'b0;
    end
endmodule