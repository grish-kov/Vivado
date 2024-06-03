`timescale 1ns / 1ps

module lab5_top #(

    parameter ENA_FIFO = "False",
    int G_RM_ADDR_W = 4,    // AXIL xADDR bit width
	int G_RM_DATA_B = 4 

)(

    input reg [2 : 0]   i_rst_pkt,
    input               i_clk,
                        i_rst,
                        i_rst_n,

    if_axil.s           s_axil
);
    
    logic   w_err_crc,        
            w_err_mis_tlast,  
            w_err_unx_tlast;
    
    reg [7 : 0] w_len;

     (* keep_hierarchy="yes" *)
        lab4_top lab4_uut (

            .i_clk                  (i_clk),
            .i_rst                  (i_rst_pkt),
            .i_length               (w_len),

            .o_err_crc              (w_err_crc),        
            .o_err_mis_tlast        (w_err_mis_tlast),  
            .o_err_unx_tlast        (w_err_unx_tlast)
        );

    if (ENA_FIFO == "False") begin

        (* keep_hierarchy="yes" *)
        lab5_reg_map# (

            .G_RM_ADDR_W(G_RM_ADDR_W),
            .G_RM_DATA_B(G_RM_DATA_B)

        ) reg_map_uut (
            
            .i_clk                  (i_clk),
            .i_rst                  (i_rst),
            .i_err_crc              (w_err_crc),
            .i_err_mis_tlast        (w_err_mis_tlast),
            .i_err_unx_tlast        (w_err_unx_tlast),
            
            .o_length               (w_len),

            .s_axil                 (s_axil)
        );

    end
    else if (ENA_FIFO == "True") begin

        if_axil#(
            .N(G_RM_DATA_B), 
            .A(G_RM_ADDR_W)
            ) m_axil();

        (* keep_hierarchy="yes" *)
        axil_fifo#(
            .FEATURES ('{ '1,'1,'1,'1,'1 }) 
        ) axil_fifo_uut(

            .s_axi_aclk_p      	(i_clk),
            .m_axi_aclk_p      	(i_clk),
            
            .s_axi_arst_n		(i_rst_n),
            .m_axi_arst_n		(i_rst_n),

            .s_axi				(s_axil),
            .m_axi				(m_axil)

        );

        (* keep_hierarchy="yes" *)
        lab5_reg_map# (

            .G_RM_ADDR_W(G_RM_ADDR_W),
            .G_RM_DATA_B(G_RM_DATA_B)

        ) reg_map_uut (
            
            .i_clk                  (i_clk),
            .i_rst                  (i_rst),
            .i_err_crc              (w_err_crc),
            .i_err_mis_tlast        (w_err_mis_tlast),
            .i_err_unx_tlast        (w_err_unx_tlast),
            
            .o_length               (w_len),

            .s_axil                 (m_axil)
        );

    end
    else 
        $warning("Wrong argument in parameter: ENA_FIFO");

endmodule
