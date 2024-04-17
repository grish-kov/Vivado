`timescale 1ns / 1ps
module lab4_source (
    input i_clk, 
    input i_rst,
    output m_axis_tready,
	output m_axis_tvalid,
	output m_axis_tlast,
	output [7:0] m_axis_tdata
);
    CRC u_crc();


endmodule