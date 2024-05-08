`timescale 1ns / 1ps

interface if_axis #( 
    parameter   int N = 1, 
                    I = 0, 
                    D = 0, 
                    U = 0, 
                bit [0:3] PAYMASK = '1 ) 
();

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


module lab4_top #(
    parameter G_P_LEN     = 10, 
              G_BYT       = 1,
              G_BIT_WIDTH = 8 * G_BYT,
              G_CNT_WIDTH = ($ceil($clog2(G_P_LEN + 1)))
) (
    input   wire        i_clk,
    input   wire [2:0]  i_rst
);  

    logic q_err;

    if_axis #(.N(G_BYT)) mst_fifo();
    if_axis #(.N(G_BYT)) slv_fifo();

    (* keep_hierarchy="yes" *)
    lab4_source #(
        .G_P_LEN                (G_P_LEN)
    ) u_source (
        .i_clk                  (i_clk),
        .i_rst                  (i_rst[0]),
        .m_axis                 (mst_fifo)
        );

    (* keep_hierarchy="yes" *) 
    axis_fifo #(
        .PACKET_MODE            ("True"),
        .DEPTH                  (256),
        .FEATURES               (8'b01100111),
        .PROG_FULL              (32)
    ) u_fifo (
        .s_axis_a_clk_p         (i_clk),
        .m_axis_a_clk_p         (i_clk),
        .s_axis_a_rst_n         (i_rst[1]),
        .m_axis_a_rst_n         (i_rst[1]),

        .s_axis                 (mst_fifo),
        .m_axis                 (slv_fifo),

        .o_fifo_a_tfull         (o_fifo_a_tfull),
        .o_fifo_p_tfull         (o_fifo_p_tfull),
        .o_fifo_w_count         (o_fifo_w_count),
        
        .o_fifo_a_empty         (o_fifo_a_empty),
        .o_fifo_p_empty         (o_fifo_p_empty),
        .o_fifo_r_count         (o_fifo_r_count)
        );
        
    (* keep_hierarchy="yes" *) 
    lab4_sink #(
        .G_P_LEN                (G_P_LEN)
    ) u_sink (
        .i_clk                  (i_clk),   
        .i_rst                  (i_rst[2]),
        .s_axis                 (slv_fifo)
        );
   
endmodule