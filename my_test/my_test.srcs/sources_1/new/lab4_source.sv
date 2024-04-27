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

    logic [7:0] o_crc_res       = '0;
    logic [7:0] i_crc_wrd_dat   = '0;
    
    logic       q_vld           = '0;
    logic       m_crc_rst       = '0;
    logic       q_tmp           = '0;

    reg [int'($ceil($clog2(N + 2))):0] q_shr [0:1]  = '{0,0};
    reg [int'($ceil($clog2(N + 2))):0] q_cnt        = '0;
    reg [int'($ceil($clog2(N + 2))):0] q_shr_cnt    = '0;

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
		.o_crc_res_dat (o_crc_res)    // Output CRC from Each Input Word
	);

    enum logic [7:0]{

        S0 /*  READY     */ = 8'b0000001,
        S1 /*  INIT_H    */ = 8'b0000010,
        S2 /*  INIT_L    */ = 8'b0000100,
        S3 /*  PAYLOAD   */ = 8'b0001000,
        S4 /*  CRC_PAUSE */ = 8'b0010000,
        S5 /*  CRC       */ = 8'b0100000,
        S6 /*  IDLE      */ = 8'b1000000
        
    } q_crnt_s;

    initial begin
        m_axis.tvalid   <= '0;
        m_axis.tlast    <= '0;
        m_axis.tdata    <= '0;
    end

    int i = 0;    

    always_ff @(posedge i_clk) begin

        if (i_rst) begin

            q_crnt_s <= S0;
            q_cnt <= 0;
            q_shr_cnt <= 2;
            q_vld <= 0;
            q_shr <= '{0, 1}; 
            m_axis.tvalid <= '0;
            m_axis.tlast  <= '0;
            m_axis.tdata  <= '0;
            m_crc_rst <= 1;

        end else 
            case (q_crnt_s)
                S0: begin   // init state
                    
                    if(m_axis.tready) begin
                        
                        m_crc_rst <= 0;
                        // q_cnt <= 0;
                        m_axis.tvalid <= 0;
                        m_axis.tlast <= 0;
                        q_vld <= 0; 
                        q_crnt_s <= S1;

                    end
                    
                end
                S1: begin   // send header
                    
                    if (m_axis.tready & !m_axis.tvalid) 
                        m_axis.tvalid <= 1;  

                    case (q_cnt) 
                    
                        0:      m_axis.tdata <= 72;

                        1:      m_axis.tdata <= N;

                        N + 1:  m_axis.tdata <= o_crc_res;
                        
                        default : m_axis.tdata <= q_shr[0];

                    endcase

                    q_cnt <= q_cnt + 1;

                    q_shr_cnt <= q_shr_cnt + 1;

                    if (q_shr_cnt == N + 2)
                        q_shr_cnt <= 0;

                    q_shr[0] <= q_shr[1];
                    q_shr[1] <= q_shr_cnt; 

                    if (m_axis.tready & m_axis.tvalid & q_cnt == N + 2) begin
                        
                        q_shr_cnt <= 0;
                        q_cnt <= 0;
                        q_crnt_s <= S0;
                        
                    end

                end
                /*S2: begin   // send length
                     
//                     if (m_axis.tready & !m_axis.tvalid)
//                         m_axis.tvalid <= 1;

                   

//                      if (m_axis.tready & m_axis.tvalid) begin
                        
// //                        m_axis.tvalid <= 0;
//                         q_cnt <= 0;
                        q_crnt_s <= S3;
                        
                    // end

                end
                S3: begin   // send payload

                    // if (m_axis.tready & !m_axis.tvalid) begin
                        
                    //     m_axis.tvalid <= 1;
                    //     q_vld <= 1;

                    // end

                    // if (m_axis.tready & q_cnt < N + 2) begin

                    //     m_axis.tdata  <= q_cnt;
                    //     i_crc_wrd_dat <= q_cnt;
                    //     q_cnt <= q_cnt + 1;

                    // end
                        
                    // if (m_axis.tvalid & m_axis.tready & q_cnt == N) begin
                        
                    //     q_vld <= '0;
                    //     m_axis.tvalid <= 0;
                    //     q_cnt <= 0;
                        q_crnt_s <= S4;

                    // end

                end
                S4: begin   // crc pause
                            
//                    if (q_cnt <= CRC_PAUSE)
//                        q_cnt <= q_cnt + 1;
//                    else 
                    q_crnt_s <= S5;
                                 
                end
                S5: begin   // send crc

                    if (m_axis.tready & !m_axis.tvalid) begin
                        
                        m_axis.tvalid <= 1;
                        m_axis.tlast <= 1;

                    end
                    
                    m_axis.tdata <= o_crc_res_dat;
                    
                    if (m_axis.tvalid & m_axis.tready) begin
                       
                        m_axis.tvalid <= 0;
                        q_cnt <= 0;    
                        q_crnt_s <= S6;
                    
                    end          
                    
                end
                S6: begin   // idle pause
                
                    if (q_cnt <= IDLE_PAUSE)
                        q_cnt <= q_cnt + 1;
                    else
                        q_crnt_s <= S0;
                
                end*/

                default: q_crnt_s <= S0;
                
            endcase
        end
endmodule