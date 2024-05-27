`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nickolay A. Sysoev
// 
// Create Date: 22/07/2019 16:54:27 PM
// Module Name: axis_fifo_w
// Tool Versions: SV 2012 + Vivado 2018.3
// Description: AXI4-Stream FIFO Wrapper
// 
// Dependencies: axi.sv
// 
// Revision:
// Revision 1.0 - change axis interface
// Additional Comments: Wrap axis_fifo without using interfaces.
// 
//////////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY = "Yes" *)
module axis_fifo_w #(
    parameter   int       TDATA_W = 2, // AXI4-Stream TDATA width in bytes
    parameter   int       TID_W = 0, // AXI4-Stream TID width
    parameter   int       TDEST_W = 0, // AXI4-Stream TDEST width
    parameter   int       TUSER_W = 0, // AXI4-Stream TUSER width
    parameter   int       DEPTH = 16, // Depth of fifo, minimum is 16, actual depth will be displayed in the information of module
    parameter             PACKET_MODE = "False", // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
    parameter             MEM_STYLE = "Distributed", // Memory style: "Distributed" or "Block"
    parameter             DUAL_CLOCK = "False", // Dual clock fifo: "True" or "False"
    parameter   int       SYNC_STAGES = 2, // Number of synchronization stages in dual clock mode: [2, 3, 4]
    parameter             RESET_SYNC = "False", // Asynchronous reset synchronization: "True" or "False"
    parameter   bit [7:0] FEATURES = '0, // Advanced features: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ]
    parameter   int       PROG_FULL = 12, // Programmable full threshold
    parameter   int       PROG_EMPTY = 4, // Programmable empty threshold
    parameter   bit [0:3] PAYLOAD_MASK = '1, // Mask in which each bit: [tdata, tstrb, tkeep, tlast]
    localparam  int       CW = $clog2(DEPTH)+1 // Count DW
  )  (
    input   wire                 i_fifo_a_rst_n, // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

    // AXI4-Stream slave interface
    input   wire                 s_axis_a_clk_p,
    input   wire                 s_axis_a_rst_n,

    input   wire                 s_axis_tvalid,
    output  wire                 s_axis_tready,
    input   wire [8*TDATA_W-1:0] s_axis_tdata,
    input   wire [  TDATA_W-1:0] s_axis_tstrb,
    input   wire [  TDATA_W-1:0] s_axis_tkeep,
    input   wire                 s_axis_tlast,
    input   wire [    TID_W-1:0] s_axis_tid,
    input   wire [  TDEST_W-1:0] s_axis_tdest,
    input   wire [  TUSER_W-1:0] s_axis_tuser,

    // AXI4-Stream master interface
    input   wire                 m_axis_a_clk_p,
    input   wire                 m_axis_a_rst_n,

    output  wire                 m_axis_tvalid,
    input   wire                 m_axis_tready,
    output  wire [8*TDATA_W-1:0] m_axis_tdata,
    output  wire [  TDATA_W-1:0] m_axis_tstrb,
    output  wire [  TDATA_W-1:0] m_axis_tkeep,
    output  wire                 m_axis_tlast,
    output  wire [    TID_W-1:0] m_axis_tid,
    output  wire [  TDEST_W-1:0] m_axis_tdest,
    output  wire [  TUSER_W-1:0] m_axis_tuser,

    output  wire                 o_fifo_a_tfull, // Almost full flag
    output  wire                 o_fifo_p_tfull, // Programmable full flag
    output  wire [       CW-1:0] o_fifo_w_count, // Write data count

    output  wire                 o_fifo_a_empty, // Almost empty flag
    output  wire                 o_fifo_p_empty, // Programmable empty flag
    output  wire [       CW-1:0] o_fifo_r_count  // Read data count, if dual clock mode is false - output count is the same with write data count
  );

  import axi::*;

  if_axis #( .N (TDATA_W), .I (TID_W), .D (TDEST_W), .U (TUSER_W), .PAYMASK (PAYLOAD_MASK) ) s_axis (); // AXI4-Stream slave interface
  if_axis #( .N (TDATA_W), .I (TID_W), .D (TDEST_W), .U (TUSER_W), .PAYMASK (PAYLOAD_MASK) ) m_axis (); // AXI4-Stream master interface

  `AXIS_ASSIGN(assign, s_axis., =, s_axis_);

  `AXIS_ASSIGN(assign, m_axis_, =, m_axis.);

  axis_fifo #(
    .DEPTH          ( DEPTH ), // Depth of fifo, minimum is 16, actual depth will be displayed in the information of module
    .PACKET_MODE    ( PACKET_MODE ), // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
    .MEM_STYLE      ( MEM_STYLE ), // Memory style: "Distributed" or "Block"
    .DUAL_CLOCK     ( DUAL_CLOCK ), // Dual clock fifo: "True" or "False"
    .SYNC_STAGES    ( SYNC_STAGES ), // Number of synchronization stages in dual clock mode: [2, 3, 4]
    .RESET_SYNC     ( RESET_SYNC ), // Asynchronous reset synchronization: "True" or "False"
    .FEATURES       ( FEATURES ), // Advanced features: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ]
    .PROG_FULL      ( PROG_FULL ), // Programmable full threshold
    .PROG_EMPTY     ( PROG_EMPTY ) // Programmable empty threshold
  ) axis_fifo_inst (
    .i_fifo_a_rst_n ( i_fifo_a_rst_n ), // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

    .s_axis_a_clk_p ( s_axis_a_clk_p ), // Rising edge slave clock
    .s_axis_a_rst_n ( s_axis_a_rst_n ), // Reset synchronous to slave clock, connect only when reset synchronization is false, active low

    .s_axis         ( s_axis ), // AXI4-Stream slave interface
    
    .m_axis_a_clk_p ( m_axis_a_clk_p ), // Rising edge master clock
    .m_axis_a_rst_n ( m_axis_a_rst_n ), // Reset synchronous to master clock, connect only when reset synchronization is false, active low

    .m_axis         ( m_axis ), // AXI4-Stream master interface

    .o_fifo_a_tfull ( o_fifo_a_tfull ), // Almost full flag
    .o_fifo_p_tfull ( o_fifo_p_tfull ), // Programmable full flag
    .o_fifo_w_count ( o_fifo_w_count ), // Write data count

    .o_fifo_a_empty ( o_fifo_a_empty ), // Almost empty flag
    .o_fifo_p_empty ( o_fifo_p_empty ), // Programmable empty flag
    .o_fifo_r_count ( o_fifo_r_count )  // Read data count, if dual clock mode is false - output count is the same with write data count
  );

endmodule : axis_fifo_w