`timescale 1ns / 1ps

module lab4_sink #(
    parameter int   G_P_LEN     = 10,                             // Packet length  
                    G_BYT       = 1,                              // Amout of byte in data
                    G_BIT_WIDTH = 8 * G_BYT,                      // Amout of bit in data
                    G_CNT_WIDTH = ($ceil($clog2(G_P_LEN + 1)))    // Counter width
)(
    input       i_clk,
                i_rst,      // Reset, active - high
    if_axis.s   s_axis,
    output wire         o_err_crc,        
                        o_err_mis_tlast,  
                        o_err_unx_tlast
);

    reg [G_BIT_WIDTH - 1 : 0] o_crc_res;                // Result of calculated CRC
    reg [G_BIT_WIDTH - 1 : 0] q_data        = '0;       // Input for CRC

    reg [G_BIT_WIDTH - 1 : 0] q_crc_r       = '0;       // Received CRC
    reg [G_BIT_WIDTH - 1 : 0] q_crc_c       = '0;       // Calculated CRC

    reg [G_BIT_WIDTH - 1 : 0] q_len         =  1;       // Received packet length
    reg [G_BIT_WIDTH - 1 : 0] q_cnt         =  0;       // Data counter

    logic   q_vld       = 0;                            // Validity of data for CRC
    logic   m_crc_rst   = 0;                            // Reset for CRC, active - high
    logic   q_exp_tlast = 0;                            // Flag for expected tlast

    logic   q_err_crc           = 0;                    // CRC error, when received CRC != calculated CRC - 1, else - 0
    logic   q_err_mis_tlast     = 0;                    // Tlast error, when expected tlast, but not found - 1, else - 0
    logic   q_err_unx_tlast     = 0;                    // Tlast error, when unexpected tlast, but found - 1, else - 0


    logic   q_trd       = 0;                            // Simulated lower tready
 
    typedef enum{

        SS,
        S0,     // Init. state, find header
        S1,     // Get packet length
        S2,     // Write data to CRC
        S3      // Calculate CRC
    
    } t_fsm_s;

    t_fsm_s q_crnt_s = S0, w_nxt_s;

    always_comb begin

        w_nxt_s = q_crnt_s;

        case(q_crnt_s)

            SS: 
                w_nxt_s = S0;

            S0 : 
                w_nxt_s = (s_axis.tdata == 72 & s_axis.tvalid & s_axis.tready) ? S1 : S0;

            S1 : 
                w_nxt_s = (s_axis.tvalid & s_axis.tready) ? S2 : S1;

            S2 : 
                w_nxt_s = (s_axis.tvalid & s_axis.tlast & (q_cnt == q_len | q_cnt == q_len + 1)) ? S3 : S2;

            S3 : 
                w_nxt_s = SS;

            default : 
                w_nxt_s = S0;

        endcase

    end

    always_ff @(posedge i_clk) begin
        
        case (q_crnt_s)

            SS: begin

                    m_crc_rst       <= 0;
                    q_vld           <= 0;
                    s_axis.tready   <= 0;

            end  

            S0 : 
                s_axis.tready   <= 1;

            S1 :    
                q_len           <= s_axis.tdata;

            S2 : begin                 

                q_vld <= (s_axis.tvalid & s_axis.tready & !s_axis.tlast);

                if (s_axis.tvalid & s_axis.tready & s_axis.tlast)
                    m_crc_rst       <= 1; 

                if (s_axis.tlast)
                    s_axis.tready   <= 0;

            end

            S3 :    ;
                
            default : ;

        endcase
    
        q_data <= s_axis.tdata;

    end

    always_ff @(posedge i_clk) begin

        if (q_crnt_s == S3) begin

            q_err_crc           <= (q_data != o_crc_res);
            q_err_mis_tlast     <= 0;

        end

        if (q_crnt_s == S0)
            q_err_crc           <= 0;

        if ((q_cnt < q_len) & s_axis.tlast)
            q_err_unx_tlast   <= 1;
        else 
            q_err_unx_tlast   <= 0;

        if (s_axis.tready & s_axis.tvalid & q_crnt_s == S2)
            q_err_mis_tlast   <= (q_exp_tlast & !s_axis.tlast);

    end

    assign o_err_crc            = q_err_crc;      
    assign o_err_mis_tlast      = q_err_mis_tlast;  
    assign o_err_unx_tlast      = q_err_unx_tlast;
    
    always_ff @(posedge i_clk) begin
    
        if (q_cnt < q_len + 1 & q_crnt_s == S2 & s_axis.tready & s_axis.tvalid)
            q_cnt <= q_cnt + 1;

        if (q_cnt == q_len + 1 & q_crnt_s == S3)                    
            q_cnt <= 1;
            
        q_exp_tlast <= (q_cnt == q_len + 1);

    end

    always_ff @(posedge i_clk)
        q_crnt_s <= (i_rst) ? SS : w_nxt_s;

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
        .o_crc_wrd_rdy      (),             // Ready To Recieve Word Data 
		.i_crc_wrd_dat      (q_data),       // Word Data
        .o_crc_res_vld      (),             // Output Flag of Validity, Active High for Each WORD_COUNT Number
        .o_crc_res_dat      (o_crc_res)     // Output CRC from Each Input Word
	);

endmodule