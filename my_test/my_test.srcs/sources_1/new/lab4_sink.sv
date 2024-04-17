`timescale 1ns / 1ps
module lab4_sink #(
    parameter N = 8
)(
    input i_clk, 
    input i_rst,
    input [N - 1:0] s_axis_tdata,
    input s_axis_tready,
	input s_axis_tvalid,
	input s_axis_tlast
);
    
    CRC u_crc(
    
        .i_crc_a_clk_p  (i_clk),
        .i_crc_s_rst_p  (i_rst),
        .i_crc_ini_vld  (s_axis_tvalid),    
        .i_crc_ini_dat  (s_axis_tdata)
    
    );
    
endmodule