`timescale 1ns / 1ps
module lab4_source #(
    parameter N = 10,
    parameter G_BYT = 1,
    int B = 1, 
	int W = 8 * B
    ) (
    input i_clk, 
    input i_rst,
    output logic m_axis_tready,
	output logic m_axis_tvalid = 0,
	output logic m_axis_tlast,
	output reg [N - 1:0] m_axis_tdata
);
    logic         s_ready = '0;
    logic         s_valid = '0;
    logic [W-1:0] s_data  = '0;

    CRC #(
		.POLY_WIDTH (W   ), // Size of The Polynomial Vector
		.WORD_WIDTH (W   ), // Size of The Input Words Vector
		.WORD_COUNT (0   ), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('1  ), // Initial Value
		.CRC_REF_IN ('0  ), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0  ), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0  ), // Input Word Byte Reverse
		.XOR_VECTOR ('0  ), // CRC Final Xor Vector
		.NUM_STAGES (2   )  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc (
		.i_crc_a_clk_p (i_clk  ), // Rising Edge Clock
		.i_crc_s_rst_p (i_rst), // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0), // Input Initial Valid
		.i_crc_ini_dat ('0), // Input Initial Value
		.i_crc_wrd_vld (m_axis_tvalid), // Word Data Valid Flag 
		.o_crc_wrd_rdy (s_ready), // Ready To Recieve Word Data
		.i_crc_wrd_dat (m_axis.tdata), // Word Data
		.o_crc_res_vld (s_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (s_data)  // Output CRC from Each Input Word
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

                        m_axis.tdata  <= q_cnt;
                        q_cnt <= q_cnt + 1;

                    end
                    
                    if (m_axis_tvalid & m_axis_tready & q_cnt == N) begin
                        q_crnt_s <= S4;
                        m_axis_tvalid <= 0;
                        q_cnt <= 0;
                    end

                end
                S4: begin

                    /*
                        Проверка контрольной суммы
                    */

                   if (q_cnt <= N)
                        q_cnt <= q_cnt + 1;
                    else
                        q_crnt_s <= S5;
                                            
                end
                S5: begin
                    
                    m_axis_tlast <= 1;
                    m_axis_tvalid <= 0;
                    q_crnt_s <= S6;
                    
                end
                S6: begin
                
                    q_crnt_s <= S0;
                    
                end
                default: q_crnt_s <= S0;
            endcase
        end

endmodule