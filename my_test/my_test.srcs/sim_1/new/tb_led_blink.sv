`timescale 1ns / 1ps
module tb_led_blink
#(
    parameter CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real BLINK_PERIOD[0:1] = {1e-6, 1e-9},
    parameter logic dir[0:1] =  {1, 0} // секунды
);
  
    localparam int T_CLK = 1.0e9 / CLK_FREQUENCY;
//    localparam int T_CLK[0:1] = (1.0e9 / CLK_FREQUENCY[0:1]);
//    localparam int T_CLK[0:1] = {
//        1.0e9 / CLK_FREQUENCY[0],
//        1.0e9 / CLK_FREQUENCY[1]
//    };
    
    bit i_clk = 1'b0;
    bit i_rst = 1'b0;
   
    top#(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD),
    .dir(dir)
    ) UUT_2 (
    .i_rst(i_rst),
    .i_clk_p(i_clk),
    .i_clk_n(!i_clk),
    .o_led1(o_led1)
    );
  
    always #(T_CLK/2) i_clk = ~i_clk;
    initial begin 
        i_rst = 1'b0;
        #10e3 i_rst = 1'b1; 
        #(500000*T_CLK) i_rst = 1'b0;
    end
endmodule