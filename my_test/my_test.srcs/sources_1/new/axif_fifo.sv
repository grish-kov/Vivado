`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nickolay A. Sysoev
// 
// Create Date: 23/07/2019 16:42:27 PM
// Module Name: axif_fifo
// Tool Versions: SV 2012, Vivado 2018.3
// Description: AXI4-Full FIFO
// 
// Dependencies: axi.sv
// 
// Revision:
// Revision 1.1.0 - update axi & axi fifo 
// Additional Comments: Indexes of AXI channels:
//                        0 - Write address channel (AW)
//                        1 - Write data channel (W)
//                        2 - Write response channel (B)
//                        3 - Read address channel (AR)
//                        4 - Read data channel (R)
//
/////////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY = "Soft" *)
module axif_fifo #(
    parameter             DUAL_CLOCK = "False", // Dual clock fifo: "True" or "False"
    parameter   int       SYNC_STAGES = 2, // Number of synchronization stages in dual clock mode: [2, 3, 4]
    parameter             RESET_SYNC = "False", // Asynchronous reset synchronization: "True" or "False"
    parameter   int       DEPTH [5] = '{ 32, 512, 32, 32, 512 }, // Depth of fifos, minimum is 16, actual depth will be displayed in the information of module
    parameter             WA_MEM_STYLE = "Distributed", // Write address channel memory style: "Distributed" or "Block"
    parameter             WD_MEM_STYLE = "Distributed", // Write data channel memory style: "Distributed" or "Block"
    parameter             WR_MEM_STYLE = "Distributed", // Write response channel memory style: "Distributed" or "Block"
    parameter             RA_MEM_STYLE = "Distributed", // Read address channel memory style: "Distributed" or "Block"
    parameter             RD_MEM_STYLE = "Distributed", // Read data channel memory style: "Distributed" or "Block"
    parameter   bit [5:0] FEATURES [5] = '{ '0,'0,'0,'0,'0 }, // Advanced features: [ read count, prog. empty, almost empty, write count, prog. full, almost full ]     
    parameter   int       PROG_FULL [5] = '{ 12, 12, 12, 12, 12 }, // Programmable full threshold
    parameter   int       PROG_EMPTY [5] = '{ 4, 4, 4, 4, 4 }, // Programmable empty threshold
    localparam  int       CW [5] = { $clog2(DEPTH[0])+1, $clog2(DEPTH[1])+1, $clog2(DEPTH[2])+1, $clog2(DEPTH[3])+1, $clog2(DEPTH[4])+1 } // Count width
  )  (
    input   wire              i_fifo_rst_n, // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

    input   wire              s_axi_aclk_p, // Rising edge slave clock
    input   wire              s_axi_arst_n, // Reset synchronous to slave clock, connect only when reset synchronization is false, active low

    if_axif.s                 s_axi, // AXI4-Full slave interface

    input   wire              m_axi_aclk_p, // Rising edge master clock
    input   wire              m_axi_arst_n, // Reset synchronous to master clock, connect only when reset synchronization is false, active low

    if_axif.m                 m_axi, // AXI4-Full master interface

    output  wire              o_wa_a_tfull, // Write address channel almost full flag
    output  wire              o_wa_p_tfull, // Write address channel programmable full flag
    output  wire  [CW[0]-1:0] o_wa_w_count, // Write address channel write data count
    output  wire              o_wa_a_empty, // Write address channel almost empty flag
    output  wire              o_wa_p_empty, // Write address channel programmable empty flag
    output  wire  [CW[0]-1:0] o_wa_r_count, // Write address channel read data count, if dual clock mode is false - output count is the same with write data count

    output  wire              o_wd_a_tfull, // Write data channel almost full flag
    output  wire              o_wd_p_tfull, // Write data channel programmable full flag
    output  wire  [CW[1]-1:0] o_wd_w_count, // Write data channel write data count
    output  wire              o_wd_a_empty, // Write data channel almost empty flag
    output  wire              o_wd_p_empty, // Write data channel programmable empty flag
    output  wire  [CW[1]-1:0] o_wd_r_count, // Write data channel read data count, if dual clock mode is false - output count is the same with write data count

    output  wire              o_wr_a_tfull, // Write response channel almost full flag
    output  wire              o_wr_p_tfull, // Write response channel programmable full flag
    output  wire  [CW[2]-1:0] o_wr_w_count, // Write response channel write data count
    output  wire              o_wr_a_empty, // Write response channel almost empty flag
    output  wire              o_wr_p_empty, // Write response channel programmable empty flag
    output  wire  [CW[2]-1:0] o_wr_r_count, // Write response channel read data count, if dual clock mode is false - output count is the same with write data count

    output  wire              o_ra_a_tfull, // Read address channel almost full flag
    output  wire              o_ra_p_tfull, // Read address channel programmable full flag
    output  wire  [CW[3]-1:0] o_ra_w_count, // Read address channel write data count
    output  wire              o_ra_a_empty, // Read address channel almost empty flag
    output  wire              o_ra_p_empty, // Read address channel programmable empty flag
    output  wire  [CW[3]-1:0] o_ra_r_count, // Read address channel read data count, if dual clock mode is false - output count is the same with write data count

    output  wire              o_rd_a_tfull, // Read data channel almost full flag
    output  wire              o_rd_p_tfull, // Read data channel programmable full flag
    output  wire  [CW[4]-1:0] o_rd_w_count, // Read data channel write data count
    output  wire              o_rd_a_empty, // Read data channel almost empty flag
    output  wire              o_rd_p_empty, // Read data channel programmable empty flag
    output  wire  [CW[4]-1:0] o_rd_r_count  // Read data channel read data count, if dual clock mode is false - output count is the same with write data count
  );

  // Parameters Check
  initial begin : check_param    
    if ( s_axi.WA_PAYLOAD != m_axi.WA_PAYLOAD )
      $warning("[%s %0d-%0d] WA payload width between slave (%d) and master (%d) interfaces are different. %m", "AXIF_FIFO", 1, 1, s_axi.WA_PAYLOAD, m_axi.WA_PAYLOAD);
    if ( s_axi.WD_PAYLOAD != m_axi.WD_PAYLOAD )
      $warning("[%s %0d-%0d] WD payload width between slave (%d) and master (%d) interfaces are different. %m", "AXIF_FIFO", 1, 2, s_axi.WD_PAYLOAD, m_axi.WD_PAYLOAD);
    if ( s_axi.WR_PAYLOAD != m_axi.WR_PAYLOAD )
      $warning("[%s %0d-%0d] WR payload width between slave (%d) and master (%d) interfaces are different. %m", "AXIF_FIFO", 1, 3, s_axi.WR_PAYLOAD, m_axi.WR_PAYLOAD);
    if ( s_axi.RA_PAYLOAD != m_axi.RA_PAYLOAD )
      $warning("[%s %0d-%0d] RA payload width between slave (%d) and master (%d) interfaces are different. %m", "AXIF_FIFO", 1, 4, s_axi.RA_PAYLOAD, m_axi.RA_PAYLOAD);
    if ( s_axi.RD_PAYLOAD != m_axi.RD_PAYLOAD )
      $warning("[%s %0d-%0d] RD payload width between slave (%d) and master (%d) interfaces are different. %m", "AXIF_FIFO", 1, 5, s_axi.RD_PAYLOAD, m_axi.RD_PAYLOAD);
  end : check_param

  localparam int PW [5] = { s_axi.WA_PAYLOAD, s_axi.WD_PAYLOAD, s_axi.WR_PAYLOAD, s_axi.RA_PAYLOAD, s_axi.RD_PAYLOAD };

  // Write Address Channel
  logic [PW[0]-1:0] s_wa_payload; 
  always_comb
    s_wa_payload = s_axi.wa_payload();

  logic [PW[0]-1:0] m_wa_payload;
  always_comb
    m_axi.wa_paymask(m_wa_payload);

  fifo #(
    .DW ( PW[0] ),
    .DEPTH ( DEPTH[0] ),
    .FWFT ( "True" ),
    .MEM_STYLE ( WA_MEM_STYLE ),
    .DUAL_CLOCK ( DUAL_CLOCK ),
    .SYNC_STAGES ( SYNC_STAGES ),
    .RESET_SYNC ( RESET_SYNC ),
    .PROG_FULL ( PROG_FULL[0] ),
    .PROG_EMPTY ( PROG_EMPTY[0] ),
    .FEATURES ( { 1'b1, FEATURES[0][5:3], 1'b1, FEATURES[0][2:0] } ),
    .CW ( CW[0] )
  ) u_wa_fifo (
    .i_fifo_a_rst_p (!i_fifo_rst_n ),
    .i_fifo_w_rst_p (!s_axi_arst_n ),
    .i_fifo_w_clk_p ( s_axi_aclk_p ),
    .i_fifo_w_valid ( s_axi.awvalid ),
    .i_fifo_w_value ( s_wa_payload ),
    .o_fifo_w_tfull ( s_axi.awready ),
    .o_fifo_a_tfull ( o_wa_a_tfull ),
    .o_fifo_p_tfull ( o_wa_p_tfull ),
    .o_fifo_w_count ( o_wa_w_count ),
    .i_fifo_r_rst_p (!m_axi_arst_n ),
    .i_fifo_r_clk_p ( m_axi_aclk_p ),
    .i_fifo_r_query ( m_axi.awready ),
    .o_fifo_r_valid (  ),
    .o_fifo_r_value ( m_wa_payload ),
    .o_fifo_r_empty ( m_axi.awvalid ),
    .o_fifo_a_empty ( o_wa_a_empty ),
    .o_fifo_p_empty ( o_wa_p_empty ),
    .o_fifo_r_count ( o_wa_r_count ) 
  );

  // Write Data Channel
  logic [PW[1]-1:0] s_wd_payload; 
  always_comb
    s_wd_payload = s_axi.wd_payload();

  logic [PW[1]-1:0] m_wd_payload;
  always_comb
    m_axi.wd_paymask(m_wd_payload);

  fifo #(
    .DW ( PW[1] ),
    .DEPTH ( DEPTH[1] ),
    .FWFT ( "True" ),
    .MEM_STYLE ( WD_MEM_STYLE ),
    .DUAL_CLOCK ( DUAL_CLOCK ),
    .SYNC_STAGES ( SYNC_STAGES ),
    .RESET_SYNC ( RESET_SYNC ),
    .PROG_FULL ( PROG_FULL[1] ),
    .PROG_EMPTY ( PROG_EMPTY[1] ),
    .FEATURES ( { 1'b1, FEATURES[1][5:3], 1'b1, FEATURES[1][2:0] } ),
    .CW ( CW[1] )
  ) u_wd_fifo (
    .i_fifo_a_rst_p (!i_fifo_rst_n ),
    .i_fifo_w_rst_p (!s_axi_arst_n ),
    .i_fifo_w_clk_p ( s_axi_aclk_p ),
    .i_fifo_w_valid ( s_axi.wvalid ),
    .i_fifo_w_value ( s_wd_payload ),
    .o_fifo_w_tfull ( s_axi.wready ),
    .o_fifo_a_tfull ( o_wd_a_tfull ),
    .o_fifo_p_tfull ( o_wd_p_tfull ),
    .o_fifo_w_count ( o_wd_w_count ),
    .i_fifo_r_rst_p (!m_axi_arst_n ),
    .i_fifo_r_clk_p ( m_axi_aclk_p ),
    .i_fifo_r_query ( m_axi.wready ),
    .o_fifo_r_valid (  ),
    .o_fifo_r_value ( m_wd_payload ),
    .o_fifo_r_empty ( m_axi.wvalid ),
    .o_fifo_a_empty ( o_wd_a_empty ),
    .o_fifo_p_empty ( o_wd_p_empty ),
    .o_fifo_r_count ( o_wd_r_count ) 
  );

  // Write Response Channel
  logic [PW[2]-1:0] m_wr_payload;
  always_comb
    m_wr_payload = m_axi.wr_payload();

  logic [PW[2]-1:0] s_wr_payload;
  always_comb
    s_axi.wr_paymask(s_wr_payload);

  fifo #(
    .DW ( PW[2] ),
    .DEPTH ( DEPTH[2] ),
    .FWFT ( "True" ),
    .MEM_STYLE ( WR_MEM_STYLE ),
    .DUAL_CLOCK ( DUAL_CLOCK ),
    .SYNC_STAGES ( SYNC_STAGES ),
    .RESET_SYNC ( RESET_SYNC ),
    .PROG_FULL ( PROG_FULL[2] ),
    .PROG_EMPTY ( PROG_EMPTY[2] ),
    .FEATURES ( { 1'b1, FEATURES[2][5:3], 1'b1, FEATURES[2][2:0] } ),
    .CW ( CW[2] )
  ) u_wr_fifo (
    .i_fifo_a_rst_p (!i_fifo_rst_n ),
    .i_fifo_w_rst_p (!m_axi_arst_n ),
    .i_fifo_w_clk_p ( m_axi_aclk_p ),
    .i_fifo_w_valid ( m_axi.bvalid ),
    .i_fifo_w_value ( m_wr_payload ),
    .o_fifo_w_tfull ( m_axi.bready ),
    .o_fifo_a_tfull ( o_wr_a_tfull ),
    .o_fifo_p_tfull ( o_wr_p_tfull ),
    .o_fifo_w_count ( o_wr_w_count ),
    .i_fifo_r_rst_p (!s_axi_arst_n ),
    .i_fifo_r_clk_p ( s_axi_aclk_p ),
    .i_fifo_r_query ( s_axi.bready ),
    .o_fifo_r_valid (  ),
    .o_fifo_r_value ( s_wr_payload ),
    .o_fifo_r_empty ( s_axi.bvalid ),
    .o_fifo_a_empty ( o_wr_a_empty ),
    .o_fifo_p_empty ( o_wr_p_empty ),
    .o_fifo_r_count ( o_wr_r_count ) 
  );

  // Read Address Channel
  logic [PW[3]-1:0] s_ra_payload; 
  always_comb
    s_ra_payload = s_axi.ra_payload();

  logic [PW[3]-1:0] m_ra_payload;
  always_comb
    m_axi.ra_paymask(m_ra_payload);

  fifo #(
    .DW ( PW[3] ),
    .DEPTH ( DEPTH[3] ),
    .FWFT ( "True" ),
    .MEM_STYLE ( RA_MEM_STYLE ),
    .DUAL_CLOCK ( DUAL_CLOCK ),
    .SYNC_STAGES ( SYNC_STAGES ),
    .RESET_SYNC ( RESET_SYNC ),
    .PROG_FULL ( PROG_FULL[3] ),
    .PROG_EMPTY ( PROG_EMPTY[3] ),
    .FEATURES ( { 1'b1, FEATURES[3][5:3], 1'b1, FEATURES[3][2:0] } ),
    .CW ( CW[3] )
  ) u_ra_fifo (
    .i_fifo_a_rst_p (!i_fifo_rst_n ),
    .i_fifo_w_rst_p (!s_axi_arst_n ),
    .i_fifo_w_clk_p ( s_axi_aclk_p ),
    .i_fifo_w_valid ( s_axi.arvalid ),
    .i_fifo_w_value ( s_ra_payload ),
    .o_fifo_w_tfull ( s_axi.arready ),
    .o_fifo_a_tfull ( o_ra_a_tfull ),
    .o_fifo_p_tfull ( o_ra_p_tfull ),
    .o_fifo_w_count ( o_ra_w_count ),
    .i_fifo_r_rst_p (!m_axi_arst_n ),
    .i_fifo_r_clk_p ( m_axi_aclk_p ),
    .i_fifo_r_query ( m_axi.arready ),
    .o_fifo_r_valid (  ),
    .o_fifo_r_value ( m_ra_payload ),
    .o_fifo_r_empty ( m_axi.arvalid ),
    .o_fifo_a_empty ( o_ra_a_empty ),
    .o_fifo_p_empty ( o_ra_p_empty ),
    .o_fifo_r_count ( o_ra_r_count ) 
  );

  // Read Data Channel
  logic [PW[4]-1:0] m_rd_payload;
  always_comb
    m_rd_payload = m_axi.rd_payload();

  logic [PW[4]-1:0] s_rd_payload;
  always_comb
    s_axi.rd_paymask(s_rd_payload);

  fifo #(
    .DW ( PW[4] ),
    .DEPTH ( DEPTH[4] ),
    .FWFT ( "True" ),
    .MEM_STYLE ( RD_MEM_STYLE ),
    .DUAL_CLOCK ( DUAL_CLOCK ),
    .SYNC_STAGES ( SYNC_STAGES ),
    .RESET_SYNC ( RESET_SYNC ),
    .PROG_FULL ( PROG_FULL[4] ),
    .PROG_EMPTY ( PROG_EMPTY[4] ),
    .FEATURES ( { 1'b1, FEATURES[4][5:3], 1'b1, FEATURES[4][2:0] } ),
    .CW ( CW[4] )
  ) u_rd_fifo (
    .i_fifo_a_rst_p (!i_fifo_rst_n ),
    .i_fifo_w_rst_p (!m_axi_arst_n ),
    .i_fifo_w_clk_p ( m_axi_aclk_p ),
    .i_fifo_w_valid ( m_axi.rvalid ),
    .i_fifo_w_value ( m_rd_payload ),
    .o_fifo_w_tfull ( m_axi.rready ),
    .o_fifo_a_tfull ( o_rd_a_tfull ),
    .o_fifo_p_tfull ( o_rd_p_tfull ),
    .o_fifo_w_count ( o_rd_w_count ),
    .i_fifo_r_rst_p (!s_axi_arst_n ),
    .i_fifo_r_clk_p ( s_axi_aclk_p ),
    .i_fifo_r_query ( s_axi.rready ),
    .o_fifo_r_valid (  ),
    .o_fifo_r_value ( s_rd_payload ),
    .o_fifo_r_empty ( s_axi.rvalid ),
    .o_fifo_a_empty ( o_rd_a_empty ),
    .o_fifo_p_empty ( o_rd_p_empty ),
    .o_fifo_r_count ( o_rd_r_count ) 
  );

endmodule : axif_fifo