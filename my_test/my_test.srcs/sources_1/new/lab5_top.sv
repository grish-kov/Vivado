`timescale 1ns / 1ps

module lab5_top(

    input reg [7 : 0]  i_length,
                        i_err,
    input               i_clk,
                        i_rst,

    if_axil.m           m_axil,
    if_axil.s           s_axil
);

    logic   o_err_crc,        
            o_err_mis_tlast,  
            o_err_unx_tlast;
    
    reg [7 : 0] w_len;
    
    

    (* keep_hierarchy="yes" *)
    lab4_top #(

    ) lab4_uut (

        .i_clk                  (i_clk),
        .i_rst                  (i_rst),
        .i_length               (w_len),
        .o_err_crc              (o_err_crc),        
        .o_err_mis_tlast        (o_err_mis_tlast),  
        .o_err_unx_tlast        (o_err_unx_tlast)
    );

    (* keep_hierarchy="yes" *)
    lab5_reg_map #(

    ) reg_map_uut (
        
        .i_clk                  (i_clk),
        .i_length               (i_length),
        .o_length               (w_len),
        .o_err                  (o_err),
        .i_err_crc              (o_err_crc),
        .i_err_mis_tlast        (o_err_mis_tlast),
        .i_err_unx_tlast        (o_err_unx_tlast),

        .s_axil                 (s_axil),
        .m_axil                 (m_axil)
    );
    
endmodule
