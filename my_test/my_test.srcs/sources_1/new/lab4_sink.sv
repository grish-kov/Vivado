`timescale 1ns / 1ps
module lab4_sink #(
    parameter int   G_P_LEN     = 8,                             // Packet length  
                    G_BYT       = 1,                              // Amout of byte in data
                    G_BIT_WIDTH = 8 * G_BYT,                      // Amout of bit in data
                    G_CNT_WIDTH = ($ceil($clog2(G_P_LEN + 1)))    // Counter width
)(
    input       i_clk,
                i_rst,      // Reset, active - high
    if_axis.s   s_axis
);

    logic [G_BIT_WIDTH - 1 : 0] o_crc_res   = '0;       // Result of calculated CRC
    logic [G_BIT_WIDTH - 1 : 0] i_crc_wrd   = '0;       // Input for CRC

    logic [G_BIT_WIDTH - 1 : 0] q_crc_r     = '0;       // Received CRC
    logic [G_BIT_WIDTH - 1 : 0] q_crc_c     = '0;       // Calculated CRC

    reg   [7 : 0]               q_len       = '0;       // Received packet length
    reg   [7 : 0]               q_cnt       = '0;       // Data counter
    
    logic   q_vld       = 0;                            // Validity of data for CRC
    logic   m_crc_rst   = 0;                            // Reset for CRC, active - high
    logic   q_err       = 0;                            // Logic error, when received CRC != calculated CRC - 1, else - 0
 
    enum logic [1:0]{

        S0,     // Init. state, find header
        S1,     // Get packet length
        S2      // Sending data to CRC
    
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

        if (i_rst) begin

            q_vld       <= 0;
            q_cnt       <= 0;
            q_crnt_s    <= S0;
        
        end 
        else 
            case (q_crnt_s)
            
                S0: begin

                    q_cnt       <= 0;
                    m_crc_rst   <= 0;

                    if (s_axis.tdata == 72 & s_axis.tvalid)
                        q_crnt_s    <= S1; 

                end

                S1: begin
 
                    q_len <= s_axis.tdata;

                    q_vld       <= 1;
                    q_crnt_s    <= S2;

                end

                S2: begin

                    if (q_cnt < q_len - 1) begin
                        
                        i_crc_wrd   <= q_cnt;
                        q_cnt       <= q_cnt + 1;         

                    end          

                    if (q_cnt == q_len - 1 | !q_len) begin
                        
                        i_crc_wrd   <= 0;
                        m_crc_rst   <= 1;
                        q_vld       <= 0;
                        q_crnt_s    <= S0;

                    end

                end
            
                default: q_crnt_s <= S0;

            endcase

            q_err <= (q_crc_r == q_crc_c) ? 0 : 1;
    end

    CRC #(
		.POLY_WIDTH         (G_BIT_WIDTH),  // Size of The Polynomial Vector
		.WORD_WIDTH         (G_BIT_WIDTH),  // Size of The Input Words Vector
		.WORD_COUNT         (0),            // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL         ('hD5),         // Polynomial Bit Vector
		.INIT_VALUE         ('h01),         // Initial Value
		.XOR_VECTOR         ('0),           // CRC Final Xor Vector
		.NUM_STAGES         (1)             // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) u_crc1 (
		.i_crc_a_clk_p      (i_clk),        // Rising Edge Clock
		.i_crc_s_rst_p      (m_crc_rst),    // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld      ('0),           // Input Initial Valid
		.i_crc_ini_dat      ('0),           // Input Initial Value
		.i_crc_wrd_vld      (q_vld),        // Word Data Valid Flag 
		.i_crc_wrd_dat      (s_axis.tdata), // Word Data
        .o_crc_res_dat      (o_crc_res)     // Output CRC from Each Input Word
	);

endmodule