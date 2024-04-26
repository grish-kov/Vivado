`timescale 1ns / 1ps

interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N;
	
	logic         tready;
	logic         tvalid;
	logic         tlast;
	logic [W-1:0] tdata;
	
	modport m (input tready, output tvalid, tlast, tdata);
	modport s (output tready, input tvalid, tlast, tdata);
	
endinterface

module tb_lab4_sink #(
    parameter C_T_CLK   = 1.0,
    parameter N         = 8,
    int       B         = 1, 
    int       W         = 8 * B
) ();

    logic           i_clk   = 1;
    logic [2:0]     i_rst   = 3'b000;
    logic           s_valid = '0;

    logic           m_valid = '0;
    logic [W-1:0]   m_data  = '0;
    
    if_axis m_axis ();

    lab4_sink #(
        .N(N),
        .B(B),
        .W(W)
    ) 
    UUT (
        .s_axis     (m_axis),
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .o_err      (o_err)
    );
    
    task send_pkt;
        localparam [W-1:0] C_DATA_ARR [0:7] = '{1, 1, 2, 3, 4, 5, 6, 7};
        begin

            m_axis.tdata <= 72;
            #(2 * C_T_CLK);
            m_axis.tdata <= N;
            #(2 * C_T_CLK);
            for (int i = 0; i < $size(C_DATA_ARR); i++) begin
                m_axis.tvalid <= '1;
                m_axis.tdata  <= C_DATA_ARR[i];
                #(2 * C_T_CLK);
                m_axis.tvalid <= '0;
            end

            #(C_T_CLK);

            m_axis.tlast <= 1;
            #(245 * C_T_CLK);
            m_axis.tdata <= 62;
            m_axis.tlast <= 0;
        end
    endtask

    always #(C_T_CLK / 2) i_clk = ~i_clk;

    always #(C_T_CLK * 244) begin

        s_valid = ~s_valid;
        send_pkt();

    end 

    initial begin   

        i_rst = 3'b101;
        #10 i_rst = 3'b010;

    end

endmodule