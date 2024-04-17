`timescale 1ns / 1ps
module lab4_sink (
    input i_clk, 
    input i_rst,
    input [7:0] s_axis_tdata,
    input s_axis_tready,
	input s_axis_tvalid,
	input s_axis_tlast
);
    
    CRC u_crc();
    
endmodule