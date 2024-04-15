`timescale 1ns / 1ps
module tb_lab3(
    input wire i_clk, 
	input wire i_rst,
	input wire i_dA,
	input wire i_dB,
	output logic [1:0] o_lA = '0,
	output logic [1:0] o_lB = '0
    );
    
    bit i_clk = 1'b0;
    bit i_rst = 1'b1;
    logic i_dA = 1'b0;
	logic i_dB = 1'b0;
    
    lab3_top
    UUT(
        .i_rst(i_rst),
        .i_clk(i_clk),
        .i_dA(i_dA),
        .i_dB(i_dB),
        .o_lA(o_lA),
        .o_lB(o_lB)
    );
    int C_T_CLK = 1.0e9 / 200_000_000;
    always #(C_T_CLK) i_clk = ~i_clk;
    always #(2.3e3) i_dA = ~i_dA;
    always #(1.1e3) i_dB = ~i_dB;
    initial begin
        i_rst = 1'b1;
        #10 i_rst = 1'b0;
        #500 i_rst = 1'b1; 
        #1000 i_rst = 1'b0;
    end
endmodule
