interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N;
	
	logic         tready;
	logic         tvalid;
	logic         tlast ;
	logic [W-1:0] tdata ;
	
endinterface

module lab4_top #(
    parameter G_BYT = 1
) (
    input i_clk,
    input [2:0] i_rst
);
    
    if_axis #(.N(G_BYT)) mst_fifo();
    if_axis #(.N(G_BYT)) slv_fifo();
    
    task send_pkt;
	   localparam N = 100; // number of samples in packet
	   int i;
	   begin
		  for (i = 1; i <= N; i ++) begin
			 s_axis.tvalid = 1;
             s_axis.tlast  = (i == N);
             s_axis.tdata  = 1;
			 s_axis.tvalid = 0;
		  end
	   end
    endtask
    
    lab4_source u_source (
    
        .i_clk              (i_clk),
        .i_rst              (i_rst[0]),
        .m_axis_tvalid      (mst_fifo.tvalid),
        .m_axis_tready      (mst_fifo.tready),
        .m_axis_tdata       (mst_fifo.tdata),
        .m_axis_tlast       (mst_fifo.tlast)
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
    
    (* keep_hierarchy="yes" *) lab4_sink u_sink (
    
        .i_clk              (i_clk),   
        .i_rst              (i_rst[2]),
        .s_axis_tvalid      (slv_fifo.tvalid),
        .s_axis_tready      (slv_fifo.tready),
        .s_axis_tdata       (slv_fifo.tdata),
        .s_axis_tlast       (slv_fifo.tlast)
        
    );
   
    
    
endmodule