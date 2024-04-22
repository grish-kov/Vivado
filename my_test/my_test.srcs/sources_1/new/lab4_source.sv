`timescale 1ns / 1ps
module lab4_source #(
    parameter   N           = 10,
    parameter   G_BYT       = 1,
    parameter   CRC_PAUSE   = 10,
    parameter   IDLE_PAUSE  = 10,
    int         B           = 1, 
    int         W           = 8 * B
) (
    input   i_clk, 
    input   i_rst,
    if_axis.m m_axis
);

    logic [7:0] o_crc_res_dat = '0;
    logic [7:0] i_crc_wrd_dat = '0;
    logic       q_vld = '0;
    logic       m_crc_rst;


    CRC #(
		.POLY_WIDTH (W),          // Size of The Polynomial Vector
		.WORD_WIDTH (W),          // Size of The Input Words Vector
		.WORD_COUNT (0),          // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5),       // Polynomial Bit Vector
		.INIT_VALUE ('h01),       // Initial Value
		.CRC_REF_IN ('0),         // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0),         // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0),         // Input Word Byte Reverse
		.XOR_VECTOR ('0),         // CRC Final Xor Vector
		.NUM_STAGES (2)           // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc0 (
		.i_crc_a_clk_p (i_clk),         // Rising Edge Clock
		.i_crc_s_rst_p (m_crc_rst),       // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0),              // Input Initial Valid
		.i_crc_ini_dat ('0),              // Input Initial Value
		.i_crc_wrd_vld (q_vld),       // Word Data Valid Flag 
		.o_crc_wrd_rdy (),                // Ready To Recieve Word Data
		.i_crc_wrd_dat (i_crc_wrd_dat),   // Word Data
		.o_crc_res_vld (),                // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (o_crc_res_dat)    // Output CRC from Each Input Word
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

    reg [int'($ceil($clog2(N + 1))):0] q_cnt;
    
    always_ff @(posedge i_clk) begin
    
        if (i_rst) begin

            q_crnt_s <= S0;
            q_cnt <= 0;
            m_axis.tvalid <= '0;
            m_axis.tready <= '1;

        end
            
            case (q_crnt_s)
                S0: begin
                    
                    m_axis.tvalid <= 0;
                    if(m_axis.tready)
                        q_crnt_s <= S1;
                    
                end
                S1: begin
                    
                    m_axis.tlast <= 0;
                    
                    if (m_axis.tready & !m_axis.tvalid) 
                        m_axis.tvalid <= 1;
                    
                    m_axis.tdata <= 72;
                    m_crc_rst <= 1;
                    
                    if(m_axis.tready & m_axis.tvalid) begin
                        
                        q_crnt_s <= S2;
                        m_crc_rst <= 0;
                        
                    end
                    
                end
                S2: begin

                    m_axis.tdata <= N;
                    
                    if(m_axis.tready & m_axis.tvalid) begin
                        
                        q_crnt_s <= S3;
                        q_cnt <= 0;
                                                    
                    end
                    
                end
                S3: begin

                    if (q_cnt < N) begin

                        q_vld <= '1;
                        m_axis.tdata  <= q_cnt;
                        i_crc_wrd_dat <= q_cnt;
                        q_cnt <= q_cnt + 1;

                    end
                    
                    if (m_axis.tvalid & m_axis.tready & q_cnt == N) begin
                        
                        q_vld <= '0;
                        m_axis.tvalid <= 0;
                        q_crnt_s <= S4;
                        q_cnt <= 0;

                    end

                end
                S4: begin
                    
                    if (q_cnt <= CRC_PAUSE)
                        q_cnt <= q_cnt + 1;
                    else 
                        q_crnt_s <= S5;
                                              
                end
                S5: begin
                
                    m_axis.tvalid <= 1;
                    
                    m_axis.tdata <= o_crc_res_dat;
                    m_axis.tlast <= 1;
                    
                    m_axis.tvalid <= 0;
                    
                    q_crnt_s <= S6;
  
                end
                S6: begin
                
                   if (q_cnt <= IDLE_PAUSE)
                       q_cnt <= q_cnt + 1;
                   else
                       q_crnt_s <= S0;
                       
                end
                default: q_crnt_s <= S0;
                
            endcase
        end

endmodule