`timescale 1ns / 1ps
module lab4_sink #(
    parameter   N = 8,
    int         B = 1, 
    int         W = 8 * B
)(
    input       i_clk, 
    input       i_rst,
    output      o_err,
    if_axis.s   s_axis
);
        logic       m_vld = 0;
        logic [1:0] q_cnt_vld = '0;
        logic [7:0] o_crc_res_dat = '0;
        logic [7:0] i_crc_wrd_dat = '0;
        logic       q_vld = '0;
        logic       m_crc_rst = '0;
        logic       q_err;
        logic [7:0] q_tdata_last = '0;
        logic [7:0] q_tdata = '0;

        reg [int'($ceil($clog2(N + 3))):0] q_cnt;

        enum logic [3:0]{

        S0 /*  READY     */ = 4'b0001,
        S1 /*  PAYLOAD   */ = 4'b0010,
        S2 /*  CRC_PAUSE */ = 4'b0100,
        S3 /*  CRC       */ = 4'b1000
        
        } q_crnt_s;

      CRC #(
		.POLY_WIDTH (W),          // Size of The Polynomial Vector
		.WORD_WIDTH (W),          // Size of The Input Words Vector
		.WORD_COUNT (0),          // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5),       // Polynomial Bit Vector
		.INIT_VALUE ('h01),       // Initial Value
//		.CRC_REF_IN ('0),         // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
//		.CRC_REFOUT ('0),         // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
//		.BYTES_RVRS ('0),         // Input Word Byte Reverse
		.XOR_VECTOR ('0),         // CRC Final Xor Vector
		.NUM_STAGES (2)           // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc1 (
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

    initial begin
        s_axis.tvalid <= '1;
        s_axis.tready  <= '1;
    end

    
     always_ff @(posedge i_clk) begin
        
        s_axis.tready <= '1;
        
        if (i_rst) begin

            q_crnt_s <= S0;
            q_cnt <= 0;
            s_axis.tvalid <= '0;
            s_axis.tready <= '1;
            s_axis.tlast  <= '0;

        end else 
            case (q_crnt_s)
            
                S0: begin   // init state
                    
                    q_cnt <= 0;
                    q_cnt_vld = 0;
                    q_crnt_s <= S1;

                end
                S1: begin   // read payload
                    
                    if (!(s_axis.tvalid & s_axis.tready))
                        q_cnt_vld = q_cnt_vld + 1; 

                    if (q_cnt_vld == 2 & q_cnt == 4)
                        q_vld <= 1;
                    else if (q_cnt_vld > 2) begin
                        q_cnt_vld = 0;
                        q_vld <= 0;
                    end

                    if ((q_cnt < N + 4) & !s_axis.tlast) begin
                        i_crc_wrd_dat <= s_axis.tdata;
                        q_cnt <= q_cnt + 1;

                    end 
                    else
                        q_crnt_s <= S2;

                end
                S2: begin   // crc

                    if (s_axis.tlast) begin
                        
                        q_vld <= 0;
                        m_crc_rst <= 1;
                        q_tdata_last <= s_axis.tdata;
                        q_crnt_s <= S3;
                    
                    end

                end
                S3: begin   // compare crc

                        q_tdata <= o_crc_res_dat;
                        m_crc_rst <= 0;
                        q_crnt_s <= S0;

                end
            
                default: q_crnt_s <= S0;

            endcase
        
        if (q_tdata_last == q_tdata) 
            q_err <= 0;
        else 
            q_err <= 1;
        
    end
    
    assign o_err = q_err;
endmodule