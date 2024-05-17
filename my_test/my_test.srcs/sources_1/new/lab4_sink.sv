`timescale 1ns / 1ps

module lab4_sink #(
    parameter int   G_P_LEN     = 10,                             // Packet length  
                    G_BYT       = 1,                              // Amout of byte in data
                    G_BIT_WIDTH = 8 * G_BYT,                      // Amout of bit in data
                    G_CNT_WIDTH = ($ceil($clog2(G_P_LEN + 1)))    // Counter width
)(
    input       i_clk,
                i_rst,      // Reset, active - high
    if_axis.s   s_axis
);

    reg [G_BIT_WIDTH - 1 : 0] o_crc_res     = '0;       // Result of calculated CRC
    reg [G_BIT_WIDTH - 1 : 0] q_data        = '0;       // Input for CRC

    reg [G_BIT_WIDTH - 1 : 0] q_crc_r       = '0;       // Received CRC
    reg [G_BIT_WIDTH - 1 : 0] q_crc_c       = '0;       // Calculated CRC

    reg [G_BIT_WIDTH - 1 : 0] q_len         = '0;       // Received packet length
    reg [G_BIT_WIDTH - 1 : 0] q_cnt1        = '0;       // Data counter
    reg [G_BIT_WIDTH - 1 : 0] q_cnt2        = '0;       // Data counter

    logic   q_vld       = 0;                            // Validity of data for CRC
    logic   m_crc_rst   = 0;                            // Reset for CRC, active - high
    logic   q_err       = 0;                            // Logic error, when received CRC != calculated CRC - 1, else - 0

    logic   q_trd       = 0;
 
    typedef enum{

        S0,     // Init. state, find header
        S1,     // Get packet length
        S2,     // Write data to CRC
        S3      // Calculate CRC
    
    } t_fsm_s;

    t_fsm_s q_crnt_s = S0, w_nxt_s;
    
    initial begin

        s_axis.tvalid <= 1;
        s_axis.tready <= 1;
    
    end

    always_comb begin

        w_nxt_s = q_crnt_s;

        case(q_crnt_s)

            S0 : 
                w_nxt_s = (q_data == 72 & s_axis.tvalid & s_axis.tready) ? S1 : S0;

            S1 : 
                w_nxt_s = S2;

            S2 : 
                w_nxt_s = (s_axis.tvalid & s_axis.tready & s_axis.tlast) ? S3 : S2;

            S3 : 
                w_nxt_s = S0;

            default : 
                w_nxt_s = S0;

        endcase

    end

    always_ff @(posedge i_clk) begin
        
        case (q_crnt_s)

            S0 : begin

                if (s_axis.tvalid & s_axis.tready) begin

                    m_crc_rst   <= 0;
                    q_vld       <= 0;

                end

            end

            S1 :    q_len       <= s_axis.tdata;

            S2 : begin                 

                q_vld <= (s_axis.tvalid & s_axis.tready & !s_axis.tlast & i_clk);

                if (s_axis.tvalid & s_axis.tready & s_axis.tlast)
                    m_crc_rst   <= 1; 

            end

            S3 :    ;
        
            default : ;

        endcase
    
        q_data <= s_axis.tdata;

        if (q_trd) 
            s_axis.tready <= 0;
        else 
            s_axis.tready <= 1;

    end

    always_ff @(posedge i_clk) begin

        if (s_axis.tlast)
            q_crc_r <= s_axis.tdata;

        if (q_crnt_s == S3)  
            q_crc_c <= o_crc_res;

        q_err <= (q_crc_r == q_crc_c) ? 0 : 1;

    end

    always_ff @(posedge i_clk)
        q_crnt_s <= (i_rst) ? S0 : w_nxt_s;

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
		.i_crc_wrd_dat      (q_data),       // Word Data
        .o_crc_res_dat      (o_crc_res)     // Output CRC from Each Input Word
	);

endmodule