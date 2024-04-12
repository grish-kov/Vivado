`timescale 1ns / 1ps
module tb_lab2b
#(
    parameter G_CLK_FREQUENCY  = 200.0e6,// Гц
    parameter real G_BLINK_PERIOD[0:1] = {1e-6, 1e-9},
    parameter logic G_dir[0:1] =  {1, 0} // секунды
);
  
    localparam int C_T_CLK = 1.0e9 / G_CLK_FREQUENCY;

    bit i_clk = 1'b0;
    bit i_rst = 1'b0;
   
    lab2b_top#(
    .G_CLK_FREQUENCY(G_CLK_FREQUENCY),
    .G_BLINK_PERIOD (G_BLINK_PERIOD),
    .G_dir(G_dir)
    ) UUT_2 (
    .i_rst(i_rst),
    .i_clk_p(i_clk),
    .i_clk_n(!i_clk),
    .o_led1(o_led1)
    );
  
    always #(C_T_CLK/2) i_clk = ~i_clk;
    initial begin 
        i_rst = 1'b0;
        #10e3 i_rst = 1'b1; 
        #(500000*C_T_CLK) i_rst = 1'b0;
    end
endmodule