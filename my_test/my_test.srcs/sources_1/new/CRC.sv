`timescale 1ns / 1ps

(* KEEP_HIERARCHY = "Yes" *)
module CRC #(
    parameter int                   POLY_WIDTH = 8, // Size of The Polynomial Vector
    parameter int                   WORD_WIDTH = 32, // Size of The Input Words Vector
    parameter int                   WORD_COUNT = 3, // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
    parameter bit [POLY_WIDTH-1:0]  POLYNOMIAL = '0, // Polynomial Bit Vector
    parameter bit [POLY_WIDTH-1:0]  INIT_VALUE = '1, // Initial Value
    parameter bit                   CRC_REF_IN = '0, // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
    parameter bit                   CRC_REFOUT = '0, // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
    parameter bit                   BYTES_RVRS = '0, // Input Word Byte Reverse
    parameter bit [POLY_WIDTH-1:0]  XOR_VECTOR = '0, // CRC Final Xor Vector
    parameter int                   NUM_STAGES = 1 // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
  )  (
    input   wire                    i_crc_a_clk_p, // Rising Edge Clock

    input   wire                    i_crc_s_rst_p, // Sync Reset, Active High. Reset CRC To Initial Value.

    input   wire                    i_crc_ini_vld, // Input Initial Valid
    input   wire  [POLY_WIDTH-1:0]  i_crc_ini_dat, // Input Initial Value

    input   wire                    i_crc_wrd_vld, // Word Data Valid Flag 
    output  wire                    o_crc_wrd_rdy, // Ready To Recieve Word Data
    input   wire  [WORD_WIDTH-1:0]  i_crc_wrd_dat, // Word Data

    output  wire                    o_crc_res_vld, // Output Flag of Validity, Active High for Each WORD_COUNT Number
    output  wire  [POLY_WIDTH-1:0]  o_crc_res_dat // Output CRC from Each Input Word
  );

  localparam int MAXI_WIDTH = ( WORD_WIDTH > POLY_WIDTH ) ? WORD_WIDTH : POLY_WIDTH;

  typedef logic [POLY_WIDTH-1:0] polyVector;
  typedef logic [WORD_WIDTH-1:0] wordVector;
  typedef logic [POLY_WIDTH-1:0][MAXI_WIDTH-1:0] polyMatrix;
  typedef logic [MAXI_WIDTH-1:0][POLY_WIDTH-1:0] maxiMatrix;

  // CRC Xor Matrix
  function polyMatrix crcXorMatrix( polyVector P );
    
    polyMatrix F;
    polyVector V;

    maxiMatrix M;
    polyMatrix X;

    polyVector Y;
    polyVector Z;
    
    F[0] = P;
    for ( int i = 1; i < POLY_WIDTH; i++ ) begin
      V = '0;
      V[POLY_WIDTH-i] = '1;
      F[i] = V;
    end
        
    M[MAXI_WIDTH-1] = P;
    for ( int i = 2; i <= MAXI_WIDTH; i++ ) begin
      Y = M[MAXI_WIDTH+1-i];
      Z = '0;
      for ( int j = 0; j < POLY_WIDTH; j++ ) begin
        if ( Y[POLY_WIDTH-1-j] ) begin
          Z = Z ^ F[j];
        end
      end
      M[MAXI_WIDTH-i] = Z;
    end

    if ( WORD_WIDTH < POLY_WIDTH )
      for ( int j = 0; j < WORD_WIDTH; j++ )
        M[j] = M[POLY_WIDTH-WORD_WIDTH+j];

    for ( int i = WORD_WIDTH-1; i < POLY_WIDTH; i++ ) begin
      M[i] = F[i-WORD_WIDTH+1];
    end

    for ( int i = 0; i < MAXI_WIDTH; i++ ) begin
      for ( int j = 0; j < POLY_WIDTH; j++ ) begin
        X[POLY_WIDTH-j-1][MAXI_WIDTH-i-1] = M[i][POLY_WIDTH-j-1]; // In The Future May Find a Way To Remove This Rotate Operation...
      end
    end

    return X;

  endfunction : crcXorMatrix

  initial begin : check_param

    if ( !(NUM_STAGES inside {[1:3]}) ) 
      $error("[%s %0d-%0d] Number of Stages is \"%d\", But Must Be Betwen 1 and 3!. %m", "CRC", 1, 1, NUM_STAGES);

  end : check_param

  // Input Data Assignment & Reset
  wire wordVector w_crc_r_bytes = ( BYTES_RVRS ) ? { << 8 {i_crc_wrd_dat} } : i_crc_wrd_dat;

  wire wordVector w_crc_ref_dat = ( CRC_REF_IN ) ? { << {{ << 8 {w_crc_r_bytes} }} } : w_crc_r_bytes;

  wire w_crc_s_rst_p;
  wire w_crc_wrd_vld;
  wire wordVector w_crc_wrd_dat;
  wire w_crc_ini_vld;
  wire polyVector w_crc_ini_dat;

  if ( NUM_STAGES == 3 ) begin : input_with_reg

    logic q_crc_s_rst_p = '0;
    logic q_crc_wrd_vld = '0;
    wordVector q_crc_wrd_dat = '0;
    logic q_crc_ini_vld = '0;
    polyVector q_crc_ini_dat = '0;

    always @(posedge i_crc_a_clk_p) q_crc_s_rst_p <= i_crc_s_rst_p;
    always @(posedge i_crc_a_clk_p) q_crc_wrd_vld <= i_crc_wrd_vld;
    always @(posedge i_crc_a_clk_p) q_crc_wrd_dat <= w_crc_ref_dat;
    always @(posedge i_crc_a_clk_p) q_crc_ini_vld <= i_crc_ini_vld;
    always @(posedge i_crc_a_clk_p) q_crc_ini_dat <= i_crc_ini_dat;

    assign w_crc_s_rst_p = q_crc_s_rst_p;
    assign w_crc_wrd_vld = q_crc_wrd_vld;
    assign w_crc_wrd_dat = q_crc_wrd_dat;
    assign w_crc_ini_vld = q_crc_ini_vld;
    assign w_crc_ini_dat = q_crc_ini_dat;

  end : input_with_reg else begin : input_wout_reg

    assign w_crc_s_rst_p = i_crc_s_rst_p;
    assign w_crc_wrd_vld = i_crc_wrd_vld;
    assign w_crc_wrd_dat = w_crc_ref_dat;
    assign w_crc_ini_vld = i_crc_ini_vld;
    assign w_crc_ini_dat = i_crc_ini_dat;

  end : input_wout_reg

  // Build CRC Xor Matrix for Design
  localparam polyMatrix c_crc_xor_mtx = crcXorMatrix(POLYNOMIAL);

  // CRC Calculation
  logic q_crc_xor_vld = '0;
  polyVector w_crc_xor_dat = '0;
  polyVector q_crc_xor_dat = INIT_VALUE;

  always_comb
    for ( int i = 0; i < POLY_WIDTH; i++ ) begin : crc_xor
      w_crc_xor_dat[i] = '0;
      for ( int j = MAXI_WIDTH-1; j >= MAXI_WIDTH - WORD_WIDTH; j-- )
        if ( w_crc_wrd_vld && c_crc_xor_mtx[i][j] )
          w_crc_xor_dat[i] = w_crc_xor_dat[i] ^ w_crc_wrd_dat[j - MAXI_WIDTH + WORD_WIDTH];
      for ( int j = MAXI_WIDTH-1; j >= MAXI_WIDTH - POLY_WIDTH; j-- )
        if ( w_crc_wrd_vld && c_crc_xor_mtx[i][j] )
          w_crc_xor_dat[i] = w_crc_xor_dat[i] ^ q_crc_xor_dat[j - MAXI_WIDTH + POLY_WIDTH];
    end : crc_xor

  wire w_crc_wrd_rdy;
  wire w_crc_dly_rdy;

  // Word Count Case
  if ( WORD_COUNT == 0 ) begin : zero_word_count

    assign w_crc_wrd_rdy = !i_crc_s_rst_p;

    if ( NUM_STAGES == 3 ) begin : ready_with_reg

      logic q_crc_dly_rdy = '0;

      always @(posedge i_crc_a_clk_p) q_crc_dly_rdy <= w_crc_wrd_rdy;

      assign w_crc_dly_rdy = q_crc_dly_rdy;

    end : ready_with_reg else begin : ready_wout_reg

      assign w_crc_dly_rdy = w_crc_wrd_rdy;

    end : ready_wout_reg

    always @(posedge i_crc_a_clk_p)
      if ( w_crc_s_rst_p )
        q_crc_xor_vld <= '0;
      else
        q_crc_xor_vld <= w_crc_wrd_vld;

  end : zero_word_count else if ( WORD_COUNT == 1 ) begin : single_word_count
    
    logic q_crc_wrd_rdy = '0;

    always @(posedge i_crc_a_clk_p)
      if ( i_crc_wrd_vld && q_crc_wrd_rdy )
        q_crc_wrd_rdy <= '0;
      else
        q_crc_wrd_rdy <= '1;

    assign w_crc_wrd_rdy = !i_crc_s_rst_p && q_crc_wrd_rdy;

    if ( NUM_STAGES == 3 ) begin : ready_with_reg

      logic q_crc_dly_rdy = '0;

      always @(posedge i_crc_a_clk_p) q_crc_dly_rdy <= w_crc_wrd_rdy;

      assign w_crc_dly_rdy = q_crc_dly_rdy;

    end : ready_with_reg else begin : ready_wout_reg

      assign w_crc_dly_rdy = w_crc_wrd_rdy;

    end : ready_wout_reg

    always @(posedge i_crc_a_clk_p)
      if ( w_crc_s_rst_p )
        q_crc_xor_vld <= '0;
      else if ( w_crc_wrd_vld && w_crc_dly_rdy )
        q_crc_xor_vld <= '1;
      else
        q_crc_xor_vld <= '0;

  end : single_word_count else if ( WORD_COUNT >= 2 ) begin : other_word_count

    logic [$clog2(WORD_COUNT)-1:0] q_crc_wrd_cnt = WORD_COUNT-1;

    always @(posedge i_crc_a_clk_p)
      if ( i_crc_s_rst_p || ( q_crc_wrd_cnt == 0 && i_crc_wrd_vld ) )
        q_crc_wrd_cnt <= WORD_COUNT-1;
      else if ( i_crc_wrd_vld && w_crc_wrd_rdy )
        q_crc_wrd_cnt <= q_crc_wrd_cnt-1;

    logic q_crc_wrd_rdy = '0;

    always @(posedge i_crc_a_clk_p)
      if ( !i_crc_s_rst_p && i_crc_wrd_vld && q_crc_wrd_cnt == 0 )
        q_crc_wrd_rdy <= '0;
      else
        q_crc_wrd_rdy <= '1;

    assign w_crc_wrd_rdy = !i_crc_s_rst_p && q_crc_wrd_rdy;

    wire [$clog2(WORD_COUNT)-1:0]  w_crc_dly_cnt;

    if ( NUM_STAGES == 3 ) begin : ready_with_reg

      logic q_crc_dly_rdy = '0;
      logic [$clog2(WORD_COUNT)-1:0]  q_crc_dly_cnt = '0;

      always @(posedge i_crc_a_clk_p) q_crc_dly_rdy <= w_crc_wrd_rdy;
      always @(posedge i_crc_a_clk_p) q_crc_dly_cnt <= q_crc_wrd_cnt;

      assign w_crc_dly_rdy = q_crc_dly_rdy;
      assign w_crc_dly_cnt = q_crc_dly_cnt;

    end : ready_with_reg else begin : ready_wout_reg

      assign w_crc_dly_rdy = w_crc_wrd_rdy;
      assign w_crc_dly_cnt = q_crc_wrd_cnt;

    end : ready_wout_reg

    always @(posedge i_crc_a_clk_p)
      if ( w_crc_s_rst_p )
        q_crc_xor_vld <= '0;
      else if ( w_crc_dly_cnt == 0 && w_crc_wrd_vld )
        q_crc_xor_vld <= '1;
      else
        q_crc_xor_vld <= '0;
  end : other_word_count

  // CRC Result
  always @(posedge i_crc_a_clk_p)
    if ( w_crc_s_rst_p || !w_crc_dly_rdy )
      q_crc_xor_dat <= INIT_VALUE;
    else if ( w_crc_ini_vld )
      q_crc_xor_dat <= w_crc_ini_dat;
    else if ( w_crc_wrd_vld )
      q_crc_xor_dat <= w_crc_xor_dat;

  // Xor Out Result
  wire w_xor_out_vld;
  wire polyVector w_xor_out_dat;

  if ( NUM_STAGES inside {[2:3]} ) begin : xor_out_with_reg

    logic q_xor_out_vld = '0;
    polyVector q_xor_out_dat = '0;

    always @(posedge i_crc_a_clk_p) q_xor_out_vld <= q_crc_xor_vld;
    always @(posedge i_crc_a_clk_p) q_xor_out_dat <= q_crc_xor_dat ^ XOR_VECTOR;

    assign w_xor_out_vld = q_xor_out_vld;
    assign w_xor_out_dat = q_xor_out_dat;

  end : xor_out_with_reg else begin : xor_out_wout_reg

    assign w_xor_out_vld = q_crc_xor_vld;
    assign w_xor_out_dat = q_crc_xor_dat ^ XOR_VECTOR;

  end : xor_out_wout_reg

  assign o_crc_wrd_rdy = w_crc_wrd_rdy;

  // Result To Output Assignment
  assign o_crc_res_vld = w_xor_out_vld;
  assign o_crc_res_dat = ( CRC_REFOUT ) ? { << {w_xor_out_dat} } : w_xor_out_dat;

endmodule : CRC