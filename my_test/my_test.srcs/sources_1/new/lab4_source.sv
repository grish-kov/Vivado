`timescale 1ns / 1ps
module lab4_source #(
    parameter N = 10,
    parameter G_BYT = 1
   
    ) (
    input i_clk, 
    input i_rst,
    output logic m_axis_tready,
	output logic m_axis_tvalid = 0,
	output logic m_axis_tlast,
	output reg [N - 1:0] m_axis_tdata
);
    CRC u_crc (
    
        .i_crc_a_clk_p  (i_clk),
        .i_crc_s_rst_p  (i_rst),
        .i_crc_ini_vld  (m_axis_tvalid),    
        .i_crc_ini_dat  (m_axis_tdata)
    
    );

    enum logic [7:0]{

        S  /*  STOP      */ = 8'b0000000,
        S0 /*  READY     */ = 8'b0000001,
        S1 /*  INIT_H    */ = 8'b0000010,
        S2 /*  INIT_L    */ = 8'b0000100,
        S3 /*  PAYLOAD   */ = 8'b0001000,
        S4 /*  CRC_PAUSE */ = 8'b0010000,
        S5 /*  CRC       */ = 8'b0100000,
        S6 /*  IDLE      */ = 8'b1000000
        
    } q_crnt_s;


    if_axis #(.N(G_BYT)) m_axis();

    reg [int'($ceil($clog2(N + 1))):0] q_cnt;
    
    assign m_axis_tready = 1;
    
    always_ff @(posedge i_clk) begin
    
        if (i_rst) begin

            q_crnt_s <= S0;
            q_cnt <= 0;

        end
            
            case (q_crnt_s)
                S0: begin
                
                    if(m_axis_tready)
                        q_crnt_s <= S1;
                    
                end
                S1: begin
                
                    if (m_axis_tready & !m_axis_tvalid) 
                        m_axis_tvalid <= 1;
                    
                    m_axis.tdata <= 72;
                    
                    if(m_axis_tready & m_axis_tvalid) begin
                        
                        m_axis_tvalid <= 0; 
                        q_crnt_s <= S2;

                    end 
                    
                end
                S2: begin
                
                    if (m_axis_tready & !m_axis_tvalid) 
                        m_axis_tvalid <= 1;
                    
                    m_axis.tdata <= N;
                    
                    if(m_axis_tready & m_axis_tvalid) begin
                        
                        m_axis_tvalid <= 0;
                        q_crnt_s <= S3;
                        q_cnt <= 0;
                            
                    end
                    
                end
                S3: begin

                    if (m_axis_tready & !m_axis_tvalid) 
                        m_axis_tvalid <= 1;
                    
                    if (q_cnt <= N) begin

                        m_axis.tdata  <= 97 + q_cnt;
                        q_cnt <= q_cnt + 1;

                    end
                    
                    if (m_axis_tvalid & m_axis_tready & q_cnt == N) begin
                        q_crnt_s <= S4;
                        m_axis_tvalid <= 0;
                        q_cnt <= 0;
                    end

                end
                S4: begin

                    q_crnt_s <= S5;
                        
                end
                S5: begin
                
                    q_crnt_s <= S6;
                    
                end
                S6: begin
                
                    q_crnt_s <= S0;
                    
                end
                default: q_crnt_s <= S0;
            endcase
        end

endmodule