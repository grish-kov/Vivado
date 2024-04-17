interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N;
	
	logic         tready;
	logic         tvalid;
	logic         tlast ;
	logic [W-1:0] tdata ;
	
endinterface

module lab4_top #(
    parameter G_BYT = 1,
    parameter N = 10,
    parameter S  /*  STOP      */ = 8'b0000000,
    parameter S0 /*  READY     */ = 8'b0000001,
    parameter S1 /*  INIT_H    */ = 8'b0000100,
    parameter S2 /*  INIT_L    */ = 8'b0001000,
    parameter S3 /*  PAYLOAD   */ = 8'b0001000,
    parameter S4 /*  CRC_PAUSE */ = 8'b0010000,
    parameter S5 /*  CRC       */ = 8'b0100000,
    parameter S6 /*  IDLE      */ = 8'b1000000
) (
    input       i_clk,
    input [2:0] i_rst
);
    
    if_axis #(.N(G_BYT)) mst_fifo();
    if_axis #(.N(G_BYT)) slv_fifo();
    
    
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
   
    reg [7:0] q_crnt_s = S0;
    reg [7:0] w_nxt_s;
    
    
    always @(posedge i_clk) begin
    
        if (i_rst[0])
            q_crnt_s <= S0;
		else begin
        	w_nxt_s = q_crnt_s;
            case (q_crnt_s)
                S0: begin
                
                    if(mst_fifo.tready) q_crnt_s = S1;
                    else q_crnt_s = S0;
                    
                end
                S1: begin
                
                    if(mst_fifo.tready & mst_fifo.tvalid) begin
                        mst_fifo.tdata = 72;
                        q_crnt_s = S2;    
                    end 
                    else q_crnt_s = S1;  
                    
                end
                S2: begin
                    
                    if(mst_fifo.tready & mst_fifo.tvalid) begin
                        mst_fifo.tdata = N;
                        q_crnt_s = S3;
                    end
                    else q_crnt_s = S2;  
                    
                end
                S3: begin

                    if(mst_fifo.tready & mst_fifo.tvalid) begin
                        for(int i = 2; i <= N; i ++) begin
                            mst_fifo.tvalid = 1;
                            mst_fifo.tlast  = (i == N);
                            mst_fifo.tdata  = i;
                            mst_fifo.tvalid = 0;
                        end
                        q_crnt_s = S4;
                    end
                    else q_crnt_s = S3;  

                end
                S4: begin

                    q_crnt_s = S5;
                        
                end
                S5: begin
                
                    q_crnt_s = S6;
                    
                end
                S6: begin
                
                    q_crnt_s = S0;
                    
                end
                default: q_crnt_s = S0;
            endcase
        end
    end
    
    
    
endmodule