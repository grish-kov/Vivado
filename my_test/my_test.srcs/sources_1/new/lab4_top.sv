interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N;
	
	logic         tready;
	logic         tvalid;
	logic         tlast;
	logic [W-1:0] tdata;
	
	modport m (input tready, output tvalid, tlast, tdata);
	modport s (output tready, input tvalid, tlast, tdata);
	
endinterface

module lab4_top #(
    parameter G_BYT = 1
) (
    input wire          i_clk,
    input wire [2:0]    i_rst,
    output wire         o_err
);  

    if_axis mst_fifo();
    if_axis slv_fifo();
    
    lab4_source u_source (
        .i_clk              (i_clk),
        .i_rst              (i_rst[0]),
        .m_axis             (mst_fifo)
        );
    
    axis_data_fifo_0 u_fifo (
        .s_axis_aresetn     (i_rst[1]),
        .s_axis_aclk        (i_clk),
        
        .s_axis_tvalid      (mst_fifo.tvalid),            // input wire s_axis_tvalid
        .s_axis_tready      (mst_fifo.tready),            // output wire s_axis_tready
        .s_axis_tdata       (mst_fifo.tdata),              // input wire [7 : 0] s_axis_tdata
        .s_axis_tlast       (mst_fifo.tlast),              // input wire s_axis_tlast
        
        .m_axis_tvalid      (slv_fifo.tvalid),            // output wire m_axis_tvalid
        .m_axis_tready      (slv_fifo.tready),            // input wire m_axis_tready
        .m_axis_tdata       (slv_fifo.tdata),              // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast       (slv_fifo.tlast),              // output wire m_axis_tlast
        
        .axis_wr_data_count (axis_wr_data_count),
        .axis_rd_data_count (axis_rd_data_count),
        .prog_empty         (prog_empty),
        .prog_full          (prog_full)
        );
        
    (* keep_hierarchy="yes" *) 
    lab4_sink u_sink (
        .i_clk              (i_clk),   
        .i_rst              (i_rst[2]),
        .o_err              (o_err),
        .s_axis             (slv_fifo)
        );
   
endmodule