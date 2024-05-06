`timescale 1ns / 1ps
module lab4_sink #(
    parameter   N,
    int         B = 1, 
    int         W = 8 * B
)(
    input       i_clk, 
    input       i_rst,
    input       i_rd,
    output      o_err,
    if_axis.s   s_axis
);

    logic [7:0] o_crc_res   = '0;
    logic [7:0] i_crc_wrd   = '0;

    logic [7:0] q_crc_r     = '0;   // received crc
    logic [7:0] q_crc_c     = '0;   // calculated crc

    logic       q_vld       = 0;
    logic       m_crc_rst   = 0;
    logic       q_err       = 0;
 
    reg [int'($ceil($clog2(N))):0] q_cnt = 0;
    reg [int'($ceil($clog2(N))):0] q_len = 0;

    enum logic [1:0]{

        S0 = 2'b00,
        // S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    
    } q_crnt_s = S0;
    
    initial begin

        s_axis.tvalid <= 1;
        s_axis.tready <= 1;
    
    end
    
     always_ff @(posedge i_clk) begin


        if (s_axis.tlast) begin

            q_crc_r <= s_axis.tdata;
            q_crc_c <= o_crc_res;

        end

        q_err <= (q_crc_r == q_crc_c) ? 0 : 1;

        if (i_rst) begin

            q_vld       <= 0;
            q_cnt       <= 0;
            q_crnt_s    <= S0;
        
        end 
        else 
            case (q_crnt_s)
            
                S0: begin

                    q_cnt       <= 0;
                    m_crc_rst   <= 1;
                    if (s_axis.tdata == 72)
                        q_crnt_s    <= S2; 

                end

                // S1: begin

                //         m_crc_rst   <= 1;
                //         q_crnt_s    <= S2;


                // end

                S2: begin

                    // if (!s_axis.tlast & s_axis.tvalid)
                        q_len <= s_axis.tdata;

                    q_vld       <= 1;
                    m_crc_rst   <= 0;
                    q_crnt_s    <= S3;

                end

                S3: begin

                    if (q_cnt < q_len - 1) begin
                        
                        i_crc_wrd   <= q_cnt;
                        q_cnt       <= q_cnt + 1;         

                    end          

                    if (q_cnt == q_len - 1) begin
                        
                        i_crc_wrd   <= 0;
                        q_vld       <= 0;
                        q_crnt_s    <= S0;

                    end

                    if (!q_len)
                        q_crnt_s <= S0; 
                    // if (s_axis.tlast)
                    //     q_crc_c <= o_crc_res;

                end
            
                default: q_crnt_s <= S0;

            endcase
        
        if (i_rd == 0) begin

            q_crc_c <= 0;
            q_crc_r <= 0;
            q_err   <= 0;

        end
    end

    CRC #(
		.POLY_WIDTH (W),                    // Size of The Polynomial Vector
		.WORD_WIDTH (W),                    // Size of The Input Words Vector
		.WORD_COUNT (0),                    // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5),                 // Polynomial Bit Vector
		.INIT_VALUE ('h01),                 // Initial Value
		.XOR_VECTOR ('0),                   // CRC Final Xor Vector
		.NUM_STAGES (1)                     // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc1 (
		.i_crc_a_clk_p (i_clk),             // Rising Edge Clock
		.i_crc_s_rst_p (m_crc_rst),         // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0),                // Input Initial Valid
		.i_crc_ini_dat ('0),                // Input Initial Value
		.i_crc_wrd_vld (q_vld),             // Word Data Valid Flag 
		.o_crc_wrd_rdy (),                  // Ready To Recieve Word Data
		.i_crc_wrd_dat (s_axis.tdata),      // Word Data
		.o_crc_res_vld (o_crc_res_vld),     // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (o_crc_res)          // Output CRC from Each Input Word
	);

endmodule