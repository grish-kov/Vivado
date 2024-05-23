`timescale 1ns / 1ps

module lab5_reg_map(
    input wire          i_err_crc,        
                        i_err_mis_tlast,  
                        i_err_unx_tlast,
                        i_clk,
    input reg [31 : 0]  i_length,

    output reg   [31 : 0]   o_length,
                            o_err
    );

    assign o_length = i_length;

    // i_err_crc,        
    // i_err_mis_tlast,  
    // i_err_unx_tlast,


endmodule
