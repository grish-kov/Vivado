`timescale 1ns / 1ps

module lab5_reg_map(
    input logic             i_err_crc,        
                            i_err_mis_tlast,  
                            i_err_unx_tlast,
                            i_clk,
    input reg [7 : 0]       i_length,

    output reg   [7 : 0]    o_length,
                            o_err,

    if_axil.s   s_axil,
    if_axil.m   m_axil
    
    );

    assign o_length = i_length;

    reg [31 : 0]    RW_LEN,
                    RD_STAT;

    assign RW_LEN [7 : 0] = i_length;
    assign RD_STAT [0]  = i_err_crc;
    assign RD_STAT [8]  = i_err_unx_tlast;
    assign RD_STAT [16] = i_err_mis_tlast;

endmodule
