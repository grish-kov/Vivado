`timescale 1ns / 1ps
module lab4_source #(
    parameter   N           = 10,
    parameter   G_BYT       = 1,
    parameter   CRC_PAUSE   = 10,
    parameter   IDLE_PAUSE  = 10,
    int         B           = 1, 
    int         W           = 8 * B
) (
    input       i_clk, 
    input       i_rst,
    if_axis.m   m_axis
);

    logic [7:0] o_crc_res       = '0;
    logic [7:0] i_crc_wrd       = '0;
    
    logic       q_vld           = '0;
    logic       m_crc_rst       = '0;

    reg [int'($ceil($clog2(N + 2))) : 0] q_cnt        = 0;
    reg [int'($ceil($clog2(N + 2))) : 0] q_shr [0:2]  = '{0, 0, 0};


    enum logic [1:0] {

        S0 = 0,
        S1 = 1
        
    } q_crnt_s;

    initial begin
        m_axis.tvalid   <= 0;
        m_axis.tlast    <= 0;
        m_axis.tdata    <= 0;
    end
    
    always_ff @(posedge i_clk) begin
    
        if (i_rst) begin

            m_axis.tvalid   <= '0;
            m_axis.tlast    <= '0;
            m_axis.tdata    <= '0;
            q_vld           <= 0;
            m_crc_rst       <= 1;
            q_crnt_s        <= S0;

        end else
        case (q_crnt_s) 

            S0 : begin
                
                m_axis.tvalid   <= 0;
                m_axis.tlast    <= 0;
                m_crc_rst       <= 0;
                q_cnt           <= 1;
                q_shr           <= '{0, 0, 1};
                q_crnt_s        <= S1;

            end

            S1 : begin
                
                if (!m_axis.tvalid) begin

                    m_axis.tvalid <= 1;

                end

                if (m_axis.tvalid & m_axis.tready)
                    q_shr <= {q_shr [1:2], q_cnt};

                if (q_cnt < N + 3) 
                    q_cnt <= q_cnt + 1;
                else if (q_cnt == N + 3) begin
                    
                    q_vld           <= 0;
                    m_axis.tlast    <= 1;
                    m_crc_rst       <= 1;
                    q_crnt_s        <= S0;

                end
                case (q_cnt)

                    1 : begin

                        m_axis.tdata <= 72;
                        q_cnt <= q_cnt + 1;

                    end 

                    2 : begin

                        m_axis.tdata <= N;
                        q_cnt <= q_cnt + 1;

                    end

                    N + 3 : 

                        m_axis.tdata <= o_crc_res;

                    default : begin 
                        
                        q_vld <= 1;
                        i_crc_wrd <= q_shr[0];  
                        m_axis.tdata <= q_shr[0];   
                        
                    end

                endcase
            
            end
            
            default : q_crnt_s <= S0;

        endcase

    end


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
		.NUM_STAGES (1)           // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc0 (
		.i_crc_a_clk_p (i_clk),         // Rising Edge Clock
		.i_crc_s_rst_p (m_crc_rst),       // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0),              // Input Initial Valid
		.i_crc_ini_dat ('0),              // Input Initial Value
		.i_crc_wrd_vld (q_vld),       // Word Data Valid Flag 
		.o_crc_wrd_rdy (),                // Ready To Recieve Word Data
		.i_crc_wrd_dat (i_crc_wrd),   // Word Data
		.o_crc_res_vld (),                // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (o_crc_res)    // Output CRC from Each Input Word
	);

endmodule