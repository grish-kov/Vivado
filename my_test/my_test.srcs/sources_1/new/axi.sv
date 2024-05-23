`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nikolay A. Sysoev
// 
// Create Date: 23/05/2019 10:00:30 PM
// Module Name: axi.sv
// Tool Versions: SV 2012/2017
// Description: Interface, package and macro declaration of AMBA® AXI4, AXI4-Lite, AXI4-Stream.
// 
// Dependencies: 
// 
// Revision:
// Revision 2.4 - update AXI4 & AXI4-Lite interfaces
// Additional Comments: Designed according AMBA® AXI and AXI4-Stream Protocol Specification.
//
//////////////////////////////////////////////////////////////////////////////////

// AXI package
package axi;

  // AXI4-Stream assignment macros
  // Example: `AXIS_ASSIGN(assign, s_axis., =, s_axis_); or `AXIS_ASSIGN(assign, m_axis_, =, m_axis.);
  `define AXIS_ASSIGN(statement, lhs, operator, rhs) \
    statement ``lhs``tvalid operator ``rhs``tvalid; \
    statement ``rhs``tready operator ``lhs``tready; \
    statement ``lhs``tdata  operator ``rhs``tdata; \
    statement ``lhs``tstrb  operator ``rhs``tstrb; \
    statement ``lhs``tkeep  operator ``rhs``tkeep; \
    statement ``lhs``tlast  operator ``rhs``tlast; \
    statement ``lhs``tid    operator ``rhs``tid; \
    statement ``lhs``tdest  operator ``rhs``tdest; \
    statement ``lhs``tuser  operator ``rhs``tuser;

  // AXI4 assignment macros
  // Example: `AXIF_ASSIGN(assign, s_axif., =, s_axif_); or `AXIF_ASSIGN(assign, m_axif_, =, m_axif.);
  `define AXIF_ASSIGN_WA(statement, lhs, operator, rhs) \
    statement ``lhs``awvalid operator ``rhs``awvalid; \
    statement ``rhs``awready operator ``lhs``awready; \
    statement ``lhs``awid operator ``rhs``awid; \
    statement ``lhs``awaddr operator ``rhs``awaddr; \
    statement ``lhs``awregion operator ``rhs``awregion; \
    statement ``lhs``awlen operator ``rhs``awlen; \
    statement ``lhs``awsize operator ``rhs``awsize; \
    statement ``lhs``awburst operator ``rhs``awburst; \
    statement ``lhs``awlock operator ``rhs``awlock; \
    statement ``lhs``awcache operator ``rhs``awcache; \
    statement ``lhs``awprot operator ``rhs``awprot; \
    statement ``lhs``awqos operator ``rhs``awqos; \
    statement ``lhs``awuser operator ``rhs``awuser;

  `define AXIF_ASSIGN_WD(statement, lhs, operator, rhs) \
    statement ``lhs``wvalid operator ``rhs``wvalid; \
    statement ``rhs``wready operator ``lhs``wready; \
    statement ``lhs``wdata operator ``rhs``wdata; \
    statement ``lhs``wstrb operator ``rhs``wstrb; \
    statement ``lhs``wlast operator ``rhs``wlast; \
    statement ``lhs``wuser operator ``rhs``wuser;

  `define AXIF_ASSIGN_WR(statement, lhs, operator, rhs) \
    statement ``lhs``bvalid operator ``rhs``bvalid; \
    statement ``rhs``bready operator ``lhs``bready; \
    statement ``lhs``bid operator ``rhs``bid; \
    statement ``lhs``bresp operator ``rhs``bresp; \
    statement ``lhs``buser operator ``rhs``buser;

  `define AXIF_ASSIGN_RA(statement, lhs, operator, rhs) \
    statement ``lhs``arvalid operator ``rhs``arvalid; \
    statement ``rhs``arready operator ``lhs``arready; \
    statement ``lhs``arid operator ``rhs``arid; \
    statement ``lhs``araddr operator ``rhs``araddr; \
    statement ``lhs``arregion operator ``rhs``arregion; \
    statement ``lhs``arlen operator ``rhs``arlen; \
    statement ``lhs``arsize operator ``rhs``arsize; \
    statement ``lhs``arburst operator ``rhs``arburst; \
    statement ``lhs``arlock operator ``rhs``arlock; \
    statement ``lhs``arcache operator ``rhs``arcache; \
    statement ``lhs``arprot operator ``rhs``arprot; \
    statement ``lhs``arqos operator ``rhs``arqos; \
    statement ``lhs``aruser operator ``rhs``aruser;

  `define AXIF_ASSIGN_RD(statement, lhs, operator, rhs) \
    statement ``lhs``rvalid operator ``rhs``rvalid; \
    statement ``rhs``rready operator ``lhs``rready; \
    statement ``lhs``rid operator ``rhs``rid; \
    statement ``lhs``rdata operator ``rhs``rdata; \
    statement ``lhs``rresp operator ``rhs``rresp; \
    statement ``lhs``rlast operator ``rhs``rlast; \
    statement ``lhs``ruser operator ``rhs``ruser;

  `define AXIF_ASSIGN_W(statement, lhs, operator, rhs) \
    `AXIF_ASSIGN_WA(statement, lhs, operator, rhs); \
    `AXIF_ASSIGN_WD(statement, lhs, operator, rhs); \
    `AXIF_ASSIGN_WR(statement, rhs, operator, lhs);

  `define AXIF_ASSIGN_R(statement, lhs, operator, rhs) \
    `AXIF_ASSIGN_RA(statement, lhs, operator, rhs); \
    `AXIF_ASSIGN_RD(statement, rhs, operator, lhs);

  `define AXIF_ASSIGN(statement, lhs, operator, rhs) \
    `AXIF_ASSIGN_W(statement, lhs, operator, rhs); \
    `AXIF_ASSIGN_R(statement, lhs, operator, rhs);

  // AXI4-Lite assignment macros
  // Example: `AXIL_ASSIGN(assign, s_axil., =, s_axil_); or `AXIL_ASSIGN(assign, m_axif_, =, m_axif.);
  `define AXIL_ASSIGN_WA(statement, lhs, operator, rhs) \
    statement ``lhs``awvalid operator ``rhs``awvalid; \
    statement ``rhs``awready operator ``lhs``awready; \
    statement ``lhs``awaddr operator ``rhs``awaddr; \
    statement ``lhs``awprot operator ``rhs``awprot;

  `define AXIL_ASSIGN_WD(statement, lhs, operator, rhs) \
    statement ``lhs``wvalid operator ``rhs``wvalid; \
    statement ``rhs``wready operator ``lhs``wready; \
    statement ``lhs``wdata operator ``rhs``wdata; \
    statement ``lhs``wstrb operator ``rhs``wstrb;

  `define AXIL_ASSIGN_WR(statement, lhs, operator, rhs) \
    statement ``lhs``bvalid operator ``rhs``bvalid; \
    statement ``rhs``bready operator ``lhs``bready; \
    statement ``lhs``bresp operator ``rhs``bresp;
    
  `define AXIL_ASSIGN_RA(statement, lhs, operator, rhs) \
    statement ``lhs``arvalid operator ``rhs``arvalid; \
    statement ``rhs``arready operator ``lhs``arready; \
    statement ``lhs``araddr operator ``rhs``araddr; \
    statement ``lhs``arprot operator ``rhs``arprot;

  `define AXIL_ASSIGN_RD(statement, lhs, operator, rhs) \
    statement ``lhs``rvalid operator ``rhs``rvalid; \
    statement ``rhs``rready operator ``lhs``rready; \
    statement ``lhs``rdata operator ``rhs``rdata; \
    statement ``lhs``rresp operator ``rhs``rresp;

  `define AXIL_ASSIGN_W(statement, lhs, operator, rhs) \
    `AXIL_ASSIGN_WA(statement, lhs, operator, rhs); \
    `AXIL_ASSIGN_WD(statement, lhs, operator, rhs); \
    `AXIL_ASSIGN_WR(statement, rhs, operator, lhs);
    
  `define AXIL_ASSIGN_R(statement, lhs, operator, rhs) \
    `AXIL_ASSIGN_RA(statement, lhs, operator, rhs); \
    `AXIL_ASSIGN_RD(statement, rhs, operator, lhs);

  `define AXIL_ASSIGN(statement, lhs, operator, rhs) \
    `AXIL_ASSIGN_W(statement, lhs, operator, rhs); \
    `AXIL_ASSIGN_R(statement, lhs, operator, rhs);
  
  // Types
  typedef logic [3:0] t_region;
  typedef logic [7:0] t_len;
  typedef logic [2:0] t_size;
  typedef logic [1:0] t_burst;
  typedef logic [0:0] t_lock;
  typedef logic [3:0] t_cache;
  typedef logic [2:0] t_prot;
  typedef logic [3:0] t_qos;
  typedef logic [1:0] t_resp;

  typedef logic [0:0] t_last;

  typedef struct packed { bit TDATA, TSTRB, TKEEP, TLAST; } t_axis_mask;

  typedef struct packed { bit AWREGION, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, WSTRB, BRESP, ARREGION, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, RRESP; } t_axif_mask;

  typedef struct packed { bit AWPROT, WSTRB, BRESP, ARPROT, RRESP; } t_axil_mask;

  // Constants
  localparam t_burst AXI_BURST_FIXED = 2'b00;
  localparam t_burst AXI_BURST_INCR = 2'b01;
  localparam t_burst AXI_BURST_WRAP = 2'b10;

  localparam t_resp AXI_RESP_OKAY = 2'b00;
  localparam t_resp AXI_RESP_EXOKAY = 2'b01;
  localparam t_resp AXI_RESP_SLVERR = 2'b10;
  localparam t_resp AXI_RESP_DECERR = 2'b11;
  
endpackage : axi

//  AXI4-Stream Parameters to Define the Signal Widths:
//    N - Data Bus Width in Bytes;
//    I - TID Width. Recommended Maximum is 8-bits;
//    D - TDEST Width. Recommended Maximum is 4-bits;
//    U - TUSER Width. Recommended Number of Bits is an Integer Multiple of the Width of the Interface in Bytes.
//    PAYMASK - Payload Mask: { TDATA, TSTRB, TKEEP, TLAST }

interface if_axis #( parameter int N = 4, I = 0, D = 0, U = 0, bit [0:3] PAYMASK = '1 ) ();

  import axi::*;

  localparam int C = N << 3;

  typedef logic [C-1:0] t_data;
  typedef logic [N-1:0] t_strb;
  typedef logic [N-1:0] t_keep;
  typedef logic [I-1:0] t_id;
  typedef logic [D-1:0] t_dest;
  typedef logic [U-1:0] t_user;

  // Check Parameters
  initial begin : check_param
    if ( N < 1 || N > 256 )
      $error("[%s %0d-%0d] TDATA bus width (%0d) in AXI4-Stream interface must be greater than or equal to 1 and less than or equal to 256. %m", "AXI", 1, 1, N);
    if ( I < 0 || I > 32 )
      $error("[%s %0d-%0d] TID bus width (%0d) in AXI4-Stream interface must be greater than or equal to 0 and less than or equal to 32. %m", "AXI", 1, 2, I);
    if ( D < 0 || D > 32 )
      $error("[%s %0d-%0d] TDEST bus width (%0d) in AXI4-Stream interface must be greater than or equal to 0 and less than or equal to 32. %m", "AXI", 1, 3, D);
    if ( U < 0 || U > 4096 )
      $error("[%s %0d-%0d] TUSER bus width (%0d) in AXI4-Stream interface must be greater than or equal to 0 and less than or equal to 4096. %m", "AXI", 1, 4, U);
  end : check_param

  // Signal List
  logic   tvalid;
  logic   tready;
  t_data  tdata;
  t_strb  tstrb;
  t_keep  tkeep;
  logic   tlast;
  t_id    tid;
  t_dest  tdest;
  t_user  tuser;

  // AXI4-Stream Payload
  typedef struct packed { bit TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER; } t_msk;

  localparam t_msk MASK = { PAYMASK, I != 0, D != 0, U != 0 };
  
  localparam int PAYLOAD = C*MASK.TDATA + N*MASK.TSTRB + N*MASK.TKEEP + 1*MASK.TLAST + I + D + U;

  localparam int TDATA_OFFSET = MASK.TDATA*C;
  localparam int TSTRB_OFFSET = MASK.TSTRB*N + TDATA_OFFSET;
  localparam int TKEEP_OFFSET = MASK.TKEEP*N + TSTRB_OFFSET;
  localparam int TLAST_OFFSET = MASK.TLAST*1 + TKEEP_OFFSET;
  localparam int TID_OFFSET = I + TLAST_OFFSET;
  localparam int TDEST_OFFSET = D + TID_OFFSET;

  function logic [PAYLOAD-1:0] payload();
    if ( MASK.TDATA ) payload = tdata;
    if ( MASK.TSTRB ) payload = tstrb << TDATA_OFFSET | payload;
    if ( MASK.TKEEP ) payload = tkeep << TSTRB_OFFSET | payload;
    if ( MASK.TLAST ) payload = tlast << TKEEP_OFFSET | payload;
    if ( MASK.TID ) payload = tid << TLAST_OFFSET | payload;
    if ( MASK.TDEST ) payload = tdest << TID_OFFSET | payload;
    if ( MASK.TUSER ) payload = tuser << TDEST_OFFSET | payload;
  endfunction : payload

  function void paymask( input logic [PAYLOAD-1:0] axis_payload );
    tdata = ( MASK.TDATA ) ? axis_payload : '0;
    tkeep = ( MASK.TKEEP ) ? axis_payload >> TSTRB_OFFSET : '1;
    tstrb = ( MASK.TSTRB ) ? axis_payload >> TDATA_OFFSET : tkeep;
    tlast = ( MASK.TLAST ) ? axis_payload >> TKEEP_OFFSET : '0;
    tid = ( MASK.TID ) ? axis_payload >> TLAST_OFFSET : '0;
    tdest = ( MASK.TDEST ) ? axis_payload >> TID_OFFSET : '0;
    tuser = ( MASK.TUSER ) ? axis_payload >> TDEST_OFFSET : '0;
  endfunction : paymask

  // Master Ports
  modport m ( input tready, output tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, import paymask );

  // Slave Ports
  modport s ( input tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, output tready, import payload );

endinterface : if_axis

//  AXI4 Memory Mapped (full) Parameters to Define the Signal Widths:
//    N - Data Bus Width in Bytes;
//    A - Address Width;
//    I - Identification Tag Width;
//    U - User Signal Width: { WA, WD, WR, RA, RD };
//    PAYMASK - Payload Mask: { AWREGION, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, WSTRB, BRESP, ARREGION, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, RRESP }

interface if_axif #( parameter int N = 8, A = 32, I = 0, int U [5] = '{default:0}, bit [0:18] PAYMASK = '1 ) ();

  import axi::*;

  localparam int C = N << 3;
  
  typedef logic [C-1:0] t_data;
  typedef logic [N-1:0] t_strb;
  typedef logic [I-1:0] t_id;
  typedef logic [A-1:0] t_addr;

  localparam int WAUW = U[0];
  localparam int WDUW = U[1];
  localparam int WRUW = U[2];
  localparam int RAUW = U[3];
  localparam int RDUW = U[4];

  typedef logic [WAUW-1:0] t_awuser;
  typedef logic [WDUW-1:0] t_wuser;
  typedef logic [WRUW-1:0] t_buser;
  typedef logic [RAUW-1:0] t_aruser;
  typedef logic [RDUW-1:0] t_ruser;

  // Check Parameters
  initial begin : check_param
    if ( !(N inside {4, 8, 16, 32, 64, 128}) )
      $error("[%s %0d-%0d] Write and read data bus width (%0d) in AXI4 interface must be equal to 4, 8, 16, 32, 64 or 128 bytes. %m", "AXI", 2, 1, N);
    if ( A < 1 || A > 64 )
      $error("[%s %0d-%0d] Write and read address bus width (%0d) in AXI4 interface must be greater than or equal to 1 and less than or equal to 64. %m", "AXI", 2, 2, A);
    if ( I < 0 || I > 32 )
      $error("[%s %0d-%0d] Identification tag bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 32. %m", "AXI", 2, 3, I);
    if ( WAUW < 0 || WAUW > 1024 )
      $error("[%s %0d-%0d] Address write user-defined signal bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 1024. %m", "AXI", 2, 4, WAUW);
    if ( WDUW < 0 || WDUW > 1024 )
      $error("[%s %0d-%0d] Write data user-defined signal bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 1024. %m", "AXI", 2, 5, WDUW);
    if ( WRUW < 0 || WRUW > 1024 )
      $error("[%s %0d-%0d] Write response user-defined signal bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 1024. %m", "AXI", 2, 6, WRUW);
    if ( RAUW < 0 || RAUW > 1024 )
      $error("[%s %0d-%0d] Read address user-defined signal bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 1024. %m", "AXI", 2, 7, RAUW);
    if ( RDUW < 0 || RDUW > 1024 )
      $error("[%s %0d-%0d] Read data user-defined signal bus width (%0d) in AXI4 interface must be greater than or equal to 0 and less than or equal to 1024. %m", "AXI", 2, 8, RDUW);
  end : check_param

  // Write Address Channel Signals
  logic     awvalid;
  logic     awready;
  t_id      awid;
  t_addr    awaddr;
  t_region  awregion;
  t_len     awlen;
  t_size    awsize;
  t_burst   awburst;
  t_lock    awlock;
  t_cache   awcache;
  t_prot    awprot;
  t_qos     awqos;
  t_awuser  awuser;

  // Write Data Channel Signals
  logic     wvalid;
  logic     wready;
  t_data    wdata;
  t_strb    wstrb;
  t_last    wlast;
  t_wuser   wuser;

  // Write Response Channel Signals
  logic     bvalid;
  logic     bready;
  t_id      bid;
  t_resp    bresp;
  t_buser   buser;

  // Read Address Channel Signals
  logic     arvalid;
  logic     arready;
  t_id      arid;
  t_addr    araddr;
  t_region  arregion;
  t_len     arlen;
  t_size    arsize;
  t_burst   arburst;
  t_lock    arlock;
  t_cache   arcache;
  t_prot    arprot;
  t_qos     arqos;
  t_aruser  aruser;

  // Read Data Channel Signals
  logic     rvalid;
  logic     rready;
  t_id      rid;
  t_data    rdata;
  t_resp    rresp;
  t_last    rlast;
  t_ruser   ruser;

  typedef struct packed { bit AWREGION, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, WSTRB, BRESP, ARREGION, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, RRESP, ID, AWUSER, WUSER, BUSER, ARUSER, RUSER; } t_msk;

  localparam t_msk MASK = { PAYMASK, I != 0, WAUW != 0, WDUW != 0, WRUW != 0, RAUW != 0, RDUW != 0 };

  // Write Address Payload
  localparam int WA_PAYLOAD = A + I + MASK.AWREGION*4 + MASK.AWLEN*8 + MASK.AWSIZE*3 + MASK.AWBURST*2 + MASK.AWLOCK*1 + MASK.AWCACHE*4 + MASK.AWPROT*3 + MASK.AWQOS*4 + WAUW;

  localparam int AWADDR_OFFSET = A;
  localparam int AWID_OFFSET = I + AWADDR_OFFSET;
  localparam int AWREGION_OFFSET = MASK.AWREGION*4 + AWID_OFFSET;
  localparam int AWLEN_OFFSET = MASK.AWLEN*8 + AWREGION_OFFSET;
  localparam int AWSIZE_OFFSET = MASK.AWSIZE*3 + AWLEN_OFFSET;
  localparam int AWBURST_OFFSET = MASK.AWBURST*2 + AWSIZE_OFFSET;
  localparam int AWLOCK_OFFSET = MASK.AWLOCK*1 + AWBURST_OFFSET;
  localparam int AWCACHE_OFFSET = MASK.AWCACHE*4 + AWLOCK_OFFSET;
  localparam int AWPROT_OFFSET = MASK.AWPROT*3 + AWCACHE_OFFSET;
  localparam int AWQOS_OFFSET = MASK.AWQOS*4 + AWPROT_OFFSET;

  function logic [WA_PAYLOAD-1:0] wa_payload();
    wa_payload = awaddr;
    if ( MASK.ID ) wa_payload = awid << AWADDR_OFFSET | wa_payload;
    if ( MASK.AWREGION ) wa_payload = awregion << AWID_OFFSET | wa_payload;
    if ( MASK.AWLEN ) wa_payload = awlen << AWREGION_OFFSET | wa_payload;
    if ( MASK.AWSIZE ) wa_payload = awsize << AWLEN_OFFSET | wa_payload;
    if ( MASK.AWBURST ) wa_payload = awburst << AWSIZE_OFFSET | wa_payload;
    if ( MASK.AWLOCK ) wa_payload = awlock << AWBURST_OFFSET | wa_payload;
    if ( MASK.AWCACHE ) wa_payload = awcache << AWLOCK_OFFSET | wa_payload;
    if ( MASK.AWPROT ) wa_payload = awprot << AWCACHE_OFFSET | wa_payload;
    if ( MASK.AWQOS ) wa_payload = awqos << AWPROT_OFFSET | wa_payload;
    if ( MASK.AWUSER ) wa_payload = awuser << AWQOS_OFFSET | wa_payload;
  endfunction : wa_payload

  function void wa_paymask( input logic [WA_PAYLOAD-1:0] payload );
    awaddr = payload;
    awid = ( MASK.ID ) ? payload >> AWADDR_OFFSET : '0;
    awregion = ( MASK.AWREGION ) ? payload >> AWID_OFFSET : '0;
    awlen = ( MASK.AWLEN ) ? payload >> AWREGION_OFFSET : '0;
    awsize = ( MASK.AWSIZE ) ? payload >> AWLEN_OFFSET : $clog2(N);
    awburst = ( MASK.AWBURST ) ? payload >> AWSIZE_OFFSET : AXI_BURST_INCR;
    awlock = ( MASK.AWLOCK ) ? payload >> AWBURST_OFFSET : '0;
    awcache = ( MASK.AWCACHE ) ? payload >> AWLOCK_OFFSET : '0;
    awprot = ( MASK.AWPROT ) ? payload >> AWCACHE_OFFSET : '0;
    awqos = ( MASK.AWQOS ) ? payload >> AWPROT_OFFSET : '0;
    awuser = ( MASK.AWUSER ) ? payload >> AWQOS_OFFSET : '0;
  endfunction : wa_paymask
  
  // Write Data Payload
  localparam int WD_PAYLOAD = C + I + MASK.WSTRB*N + 1 + WDUW;

  localparam int WDATA_OFFSET = C;
  localparam int WSTRB_OFFSET = MASK.WSTRB*N + WDATA_OFFSET;
  localparam int WLAST_OFFSET = 1 + WSTRB_OFFSET;

  function logic [WD_PAYLOAD-1:0] wd_payload();
    wd_payload = wdata;
    if ( MASK.WSTRB ) wd_payload = wstrb << WDATA_OFFSET | wd_payload;
    wd_payload = wlast << WSTRB_OFFSET | wd_payload;
    if ( MASK.WUSER ) wd_payload = wuser << WLAST_OFFSET | wd_payload;
  endfunction : wd_payload

  function void wd_paymask( input logic [WD_PAYLOAD-1:0] payload );
    wdata = payload;
    wstrb = ( MASK.WSTRB ) ? payload >> WDATA_OFFSET : '1;
    wlast = payload >> WSTRB_OFFSET;
    wuser = ( MASK.WUSER ) ? payload >> WLAST_OFFSET : '0;
  endfunction : wd_paymask

  // Write Response Payload
  localparam int WR_PAYLOAD = I + MASK.BRESP*2 + WRUW;

  localparam int BID_OFFSET = I;
  localparam int BRESP_OFFSET = MASK.BRESP*2 + BID_OFFSET;

  function void wr_paymask( input logic [WR_PAYLOAD-1:0] payload );
    bid = ( MASK.ID ) ? payload : '0;
    bresp = ( MASK.BRESP ) ? payload >> BID_OFFSET : AXI_RESP_OKAY;
    buser = ( MASK.BUSER ) ? payload >> BRESP_OFFSET : '0;
  endfunction : wr_paymask

  function logic [WR_PAYLOAD-1:0] wr_payload();
    if ( MASK.ID ) wr_payload = bid;
    if ( MASK.BRESP ) wr_payload = bresp << BID_OFFSET | wr_payload;
    if ( MASK.BUSER ) wr_payload = buser << BRESP_OFFSET | wr_payload;
  endfunction : wr_payload

  // Read Address Payload
  localparam int RA_PAYLOAD = A + I + MASK.ARREGION*4 + MASK.ARLEN*8 + MASK.ARSIZE*3 + MASK.ARBURST*2 + MASK.ARLOCK*1 + MASK.ARCACHE*4 + MASK.ARPROT*3 + MASK.ARQOS*4 + RAUW;

  localparam int ARADDR_OFFSET = A;
  localparam int ARID_OFFSET = I + ARADDR_OFFSET;
  localparam int ARREGION_OFFSET = MASK.ARREGION*4 + ARID_OFFSET;
  localparam int ARLEN_OFFSET = MASK.ARLEN*8 + ARREGION_OFFSET;
  localparam int ARSIZE_OFFSET = MASK.ARSIZE*3 + ARLEN_OFFSET;
  localparam int ARBURST_OFFSET = MASK.ARBURST*2 + ARSIZE_OFFSET;
  localparam int ARLOCK_OFFSET = MASK.ARLOCK*1 + ARBURST_OFFSET;
  localparam int ARCACHE_OFFSET = MASK.ARCACHE*4 + ARLOCK_OFFSET;
  localparam int ARPROT_OFFSET = MASK.ARPROT*3 + ARCACHE_OFFSET;
  localparam int ARQOS_OFFSET = MASK.ARQOS*4 + ARPROT_OFFSET;

  function logic [RA_PAYLOAD-1:0] ra_payload();
    ra_payload = araddr;
    if ( MASK.ID ) ra_payload = arid << ARADDR_OFFSET | ra_payload;
    if ( MASK.ARREGION ) ra_payload = arregion << ARID_OFFSET | ra_payload;
    if ( MASK.ARLEN ) ra_payload = arlen << ARREGION_OFFSET | ra_payload;
    if ( MASK.ARSIZE ) ra_payload = arsize << ARLEN_OFFSET | ra_payload;
    if ( MASK.ARBURST ) ra_payload = arburst << ARSIZE_OFFSET | ra_payload;
    if ( MASK.ARLOCK ) ra_payload = arlock << ARBURST_OFFSET | ra_payload;
    if ( MASK.ARCACHE ) ra_payload = arcache << ARLOCK_OFFSET | ra_payload;
    if ( MASK.ARPROT ) ra_payload = arprot << ARCACHE_OFFSET | ra_payload;
    if ( MASK.ARQOS ) ra_payload = arqos << ARPROT_OFFSET | ra_payload;
    if ( MASK.ARUSER ) ra_payload = aruser << ARQOS_OFFSET | ra_payload;
  endfunction : ra_payload

  function void ra_paymask( input logic [RA_PAYLOAD-1:0] payload );
    araddr = payload;
    arid = ( MASK.ID ) ? payload >> ARADDR_OFFSET : '0;
    arregion = ( MASK.ARREGION ) ? payload >> ARID_OFFSET : '0;
    arlen = ( MASK.ARLEN ) ? payload >> ARREGION_OFFSET : '0;
    arsize = ( MASK.ARSIZE ) ? payload >> ARLEN_OFFSET : $clog2(N);
    arburst = ( MASK.ARBURST ) ? payload >> ARSIZE_OFFSET : AXI_BURST_INCR;
    arlock = ( MASK.ARLOCK ) ? payload >> ARBURST_OFFSET : '0;
    arcache = ( MASK.ARCACHE ) ? payload >> ARLOCK_OFFSET : '0;
    arprot = ( MASK.ARPROT ) ? payload >> ARCACHE_OFFSET : '0;
    arqos = ( MASK.ARQOS ) ? payload >> ARPROT_OFFSET : '0;
    aruser = ( MASK.ARUSER ) ? payload >> ARQOS_OFFSET : '0;
  endfunction : ra_paymask

  // Read Data Payload
  localparam int RD_PAYLOAD = C + I + MASK.RRESP*2 + 1 + RDUW;

  localparam int RID_OFFSET = I;
  localparam int RDATA_OFFSET = C + RID_OFFSET;
  localparam int RRESP_OFFSET = MASK.RRESP*2 + RDATA_OFFSET;
  localparam int RLAST_OFFSET = 1 + RRESP_OFFSET;

  function void rd_paymask( input logic [RD_PAYLOAD-1:0] payload );
    rid = ( MASK.ID ) ? payload : '0;
    rdata = payload >> RID_OFFSET;
    rresp = ( MASK.RRESP ) ? payload >> RDATA_OFFSET : AXI_RESP_OKAY;
    rlast = payload >> RRESP_OFFSET;
    ruser = ( MASK.RUSER ) ? payload >> RLAST_OFFSET : '0;
  endfunction : rd_paymask

  function logic [RD_PAYLOAD-1:0] rd_payload();
    if ( MASK.ID ) rd_payload = rid;
    rd_payload = rdata << RID_OFFSET | rd_payload;
    if ( MASK.RRESP ) rd_payload = rresp << RDATA_OFFSET | rd_payload;
    rd_payload = rlast << RRESP_OFFSET | rd_payload;
    if ( MASK.RUSER ) rd_payload = ruser << RLAST_OFFSET | rd_payload;
  endfunction : rd_payload

  // AXI-Full payload
  localparam int PAYLOAD = WA_PAYLOAD + WD_PAYLOAD + WR_PAYLOAD + RA_PAYLOAD + RD_PAYLOAD;

  // Master Ports
  modport m (
    input awready, output awvalid, awid, awaddr, awregion, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, 
    input wready, output wvalid, wdata, wstrb, wlast, wuser, 
    output bready, input bvalid, bid, bresp, buser, 
    input arready, output arvalid, arid, araddr, arregion, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, 
    output rready, input rvalid, rid, rdata, rresp, rlast, ruser, 
    import wa_paymask, import wd_paymask, import wr_payload, import ra_paymask, import rd_payload 
  );

  modport m_wo (
    input awready, output awvalid, awid, awaddr, awregion, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, 
    input wready, output wvalid, wdata, wstrb, wlast, wuser, 
    output bready, input bvalid, bid, bresp, buser, 
    import wa_paymask, import wd_paymask, import wr_payload 
  );

  modport m_ro (
    input arready, output arvalid, arid, araddr, arregion, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, 
    output rready, input rvalid, rid, rdata, rresp, rlast, ruser, 
    import ra_paymask, import rd_payload 
  );

  // Slave Ports
  modport s (
    output awready, input awvalid, awid, awaddr, awregion, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, 
    output wready, input wvalid, wdata, wstrb, wlast, wuser, 
    input bready, output bvalid, bid, bresp, buser, 
    output arready, input arvalid, arid, araddr, arregion, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, 
    input rready, output rvalid, rid, rdata, rresp, rlast, ruser, 
    import wa_payload, import wd_payload, import wr_paymask, import ra_payload, import rd_paymask
  );

  modport s_wo (
    output awready, input awvalid, awid, awaddr, awregion, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, 
    output wready, input wvalid, wdata, wstrb, wlast, wuser, 
    input bready, output bvalid, bid, bresp, buser, 
    import wa_payload, import wd_payload, import wr_paymask
  );

  modport s_ro ( 
    output arready, input arvalid, arid, araddr, arregion, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, 
    input rready, output rvalid, rid, rdata, rresp, rlast, ruser, 
    import ra_payload, import rd_paymask
  );

endinterface : if_axif

//  AXI4 Memory Mapped (lite) Parameters to Define the Signal Widths:
//    N - Data Bus Width in Bytes;
//    A - Address Width;
//    PAYMASK - Payload Mask: { awprot, wstrb, bresp, arprot, rresp }

interface if_axil #( parameter int N = 8, A = 16, bit [0:4] PAYMASK = '1 ) ();

  import axi::*;

  localparam int C = N << 3;
  
  typedef logic [C-1:0] t_data;
  typedef logic [N-1:0] t_strb;
  typedef logic [A-1:0] t_addr;

  // Check Parameters
  initial begin : check_param
    if ( !(N inside {4, 8, 16}) )
      $error("[%s %0d-%0d] Write and read data bus width (%0d) in AXI4-Lite interface must be equal to 4, 8 or 16 bytes. %m", "AXI", 3, 1, N);
    if ( A < 1 || A > 64 )
      $error("[%s %0d-%0d] Write and read address bus width (%0d) in AXI4-Lite interface must be greater than or equal to 1 and less than or equal to 64. %m", "AXI", 3, 2, A);
  end : check_param

  // Write Address Channel Signals
  logic   awvalid;
  logic   awready;
  t_addr  awaddr;
  t_prot  awprot;

  // Write Data Channel Signals
  logic   wvalid;
  logic   wready;
  t_data  wdata;
  t_strb  wstrb;

  // Write Response Channel Signals
  logic   bvalid;
  logic   bready;
  t_resp  bresp;

  // Read Address Channel Signals
  logic   arvalid;
  logic   arready;
  t_addr  araddr;
  t_prot  arprot;

  // Read Data Channel Signals
  logic   rvalid;
  logic   rready;
  t_data  rdata;
  t_resp  rresp;

  typedef struct packed { bit AWPROT, WSTRB, BRESP, ARPROT, RRESP; } t_msk;

  localparam t_msk MASK = PAYMASK;

  // Write Address Payload
  localparam int WA_PAYLOAD = A + MASK.AWPROT*3;

  localparam int AWADDR_OFFSET = A;

  function logic [WA_PAYLOAD-1:0] wa_payload();
    wa_payload = awaddr;
    if ( MASK.AWPROT ) wa_payload = awprot << AWADDR_OFFSET | wa_payload;
  endfunction : wa_payload

  function void wa_paymask( input logic [WA_PAYLOAD-1:0] payload );
    awaddr = payload;
    awprot = ( MASK.AWPROT ) ? payload >> AWADDR_OFFSET : '0;
  endfunction : wa_paymask

  // Write Data Payload
  localparam int WD_PAYLOAD = C + MASK.WSTRB*N;

  localparam int WDATA_OFFSET = C;

  function logic [WD_PAYLOAD-1:0] wd_payload();
    wd_payload = wdata;
    if ( MASK.WSTRB ) wd_payload = wstrb << WDATA_OFFSET | wd_payload;
  endfunction : wd_payload

  function void wd_paymask( input logic [WD_PAYLOAD-1:0] payload );
    wdata = payload;
    wstrb = ( MASK.WSTRB ) ? payload >> WDATA_OFFSET : '1;
  endfunction : wd_paymask

  // Write Response Payload
  localparam int WR_PAYLOAD = MASK.BRESP*2;

  function void wr_paymask( input logic [WR_PAYLOAD-1:0] payload );
    bresp = ( MASK.BRESP ) ? payload : AXI_RESP_OKAY;
  endfunction : wr_paymask

  function logic [WR_PAYLOAD-1:0] wr_payload();
    if ( MASK.BRESP ) wr_payload = bresp;
  endfunction : wr_payload

  // Read Address Payload
  localparam int RA_PAYLOAD = A + MASK.ARPROT*3;

  localparam int ARADDR_OFFSET = A;

  function logic [RA_PAYLOAD-1:0] ra_payload();
    ra_payload = araddr;
    if ( MASK.ARPROT ) ra_payload = arprot << ARADDR_OFFSET | ra_payload;
  endfunction : ra_payload

  function void ra_paymask( input logic [RA_PAYLOAD-1:0] payload );
    araddr = payload;
    arprot = ( MASK.ARPROT ) ? payload >> ARADDR_OFFSET : '0;
  endfunction : ra_paymask

  // Read Data Payload
  localparam int RD_PAYLOAD = C + MASK.RRESP*2;

  localparam int RDATA_OFFSET = C;

  function void rd_paymask( input logic [RD_PAYLOAD-1:0] payload );
    rdata = payload;
    rresp = ( MASK.RRESP ) ? payload >> RDATA_OFFSET : AXI_RESP_OKAY;
  endfunction : rd_paymask

  function logic [RD_PAYLOAD-1:0] rd_payload();
    rd_payload = rdata;
    if ( MASK.RRESP ) rd_payload = rresp << RDATA_OFFSET | rd_payload;
  endfunction : rd_payload

  // AXI-Lite Payload
  localparam int PAYLOAD = WA_PAYLOAD + WD_PAYLOAD + WR_PAYLOAD + RA_PAYLOAD + RD_PAYLOAD;

  // Master Ports
  modport m (
    input awready, output awvalid, awaddr, awprot, 
    input wready, output wvalid, wdata, wstrb, 
    output bready, input bvalid, bresp, 
    input arready, output arvalid, araddr, arprot, 
    output rready, input rvalid, rdata, rresp, 
    import wa_paymask, import wd_paymask, import wr_payload, import ra_paymask, import rd_payload 
  );

  modport m_wo (
    input awready, output awvalid, awaddr, awprot, 
    input wready, output wvalid, wdata, wstrb, 
    output bready, input bvalid, bresp, 
    import wa_paymask, import wd_paymask, import wr_payload
  );
  
  modport m_ro (
    input arready, output arvalid, araddr, arprot, 
    output rready, input rvalid, rdata, rresp, 
    import ra_paymask, import rd_payload 
  );

  // Slave Ports
  modport s (
    output awready, input awvalid, awaddr, awprot, 
    output wready, input wvalid, wdata, wstrb, 
    input bready, output bvalid, bresp, 
    output arready, input arvalid, araddr, arprot, 
    input rready, output rvalid, rdata, rresp, 
    import wa_payload, import wd_payload, import wr_paymask, import ra_payload, import rd_paymask
  );

  modport s_wo (
    output awready, input awvalid, awaddr, awprot, 
    output wready, input wvalid, wdata, wstrb, 
    input bready, output bvalid, bresp, 
    import wa_payload, import wd_payload, import wr_paymask
  );

  modport s_ro (
    output arready, input arvalid, araddr, arprot, 
    input rready, output rvalid, rdata, rresp, 
    import ra_payload, import rd_paymask
  );

endinterface : if_axil
