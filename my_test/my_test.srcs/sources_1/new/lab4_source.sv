`timescale 1ns / 1ps
module lab4_source #(
    parameter N = 8
    ) (
    input i_clk, 
    input i_rst,
    output m_axis_tready,
	output m_axis_tvalid,
	output m_axis_tlast,
	output [N - 1:0] m_axis_tdata
);
    CRC u_crc(
    
        .i_crc_a_clk_p  (i_clk),
        .i_crc_s_rst_p  (i_rst),
        .i_crc_ini_vld  (m_axis_tvalid),    
        .i_crc_ini_dat  (m_axis_tdata)
    
    );


endmodule