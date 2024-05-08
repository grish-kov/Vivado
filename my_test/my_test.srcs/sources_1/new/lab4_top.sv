`timescale 1ns / 1ps

module lab4_top #(
    parameter int   G_P_LEN     = 10,                             // Packet length  
                    G_BYT       = 1,                              // Amout of byte in data
                    G_BIT_WIDTH = 8 * G_BYT,                      // Amout of bit in data
                    G_CNT_WIDTH = ($ceil($clog2(G_P_LEN + 1)))    // Counter width
) (
    input wire [2:0]  i_rst,
          wire        i_clk
);  

    if_axis #(.N(G_BYT)) mst_fifo();  // Interface for connecting sorce and FIFO
    if_axis #(.N(G_BYT)) slv_fifo();  // Interface for connecting FIFO and sink

    // Initiating source module
    (* keep_hierarchy="yes" *)
    lab4_source #(
        .G_P_LEN                (G_P_LEN)
    ) u_source (
        .i_clk                  (i_clk),
        .i_rst                  (i_rst[0]),
        .m_axis                 (mst_fifo)
        );

    // Initiating FIFO module
    (* keep_hierarchy="yes" *) 
    axis_fifo #(
        .PACKET_MODE            ("True"),         // Initiating packet mode of FIFO
        .DEPTH                  (256),            // Set depth of FIFO to 256
        .FEATURES               (8'b01100111),    // Enable features of FIFO
        .PROG_FULL              (32)              // Set prog. full threshold to 32
    ) u_fifo (
        .s_axis_a_clk_p         (i_clk),
        .m_axis_a_clk_p         (i_clk),
        .s_axis_a_rst_n         (i_rst[1]),
        .m_axis_a_rst_n         (i_rst[1]),

        .s_axis                 (mst_fifo),
        .m_axis                 (slv_fifo),

        .o_fifo_a_tfull         (o_fifo_a_tfull),
        .o_fifo_p_tfull         (o_fifo_p_tfull),
        .o_fifo_w_count         (o_fifo_w_count),
        
        .o_fifo_a_empty         (o_fifo_a_empty),
        .o_fifo_p_empty         (o_fifo_p_empty),
        .o_fifo_r_count         (o_fifo_r_count)
        );
    
    // Initiating sink module
    (* keep_hierarchy="yes" *) 
    lab4_sink #(
        .G_P_LEN                (G_P_LEN)
    ) u_sink (
        .i_clk                  (i_clk),   
        .i_rst                  (i_rst[2]),
        .s_axis                 (slv_fifo)
        );
   
endmodule