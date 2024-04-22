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
    
    logic q_err;
    
     always_ff @(posedge i_clk) begin
        s_axis.tready <= '1;
        
        
        
        
        
        if (s_axis.tdata == o_crc_res_dat) 
            q_err <= 1;
        else q_err <= 0;
        
    end
    
    assign o_err = q_err;
endmodule