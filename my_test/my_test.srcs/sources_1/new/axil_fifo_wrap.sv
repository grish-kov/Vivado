`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nickolay A. Sysoev
// 
// Create Date: 29/07/2019 20:30:37 PM
// Module Name: axil_fifo_wrap
// Tool Versions: SV 2012, Vivado 2018.3
// Description: AXI4-Lite FIFO Wrapper
// 
// Dependencies: axi.sv, axil_fifo.sv
// 
// Revision:
// Revision 0.7.0 - fifo with axil interface
// Additional Comments: Wrap axil_fifo without using interfaces.
// 
//////////////////////////////////////////////////////////////////////////////////

(* keep_hierarchy = "Yes" *)
module axil_fifo_wrap #(
        parameter int       ADDR_WIDTH = 32, // AXI4-Lite address width [1-32]
        parameter int       DATA_WIDTH = 4, // AXI4-Lite data width in bytes [4, 8, 16]
        parameter           DUAL_CLOCK = "False", // Dual clock fifo: "True" or "False"
        parameter int       SYNC_STAGES = 2, // Number of synchronization stages in dual clock mode: [2, 3, 4]
        parameter           RESET_SYNC = "False", // Asynchronous reset synchronization: "True" or "False"
        parameter int       AW_DEPTH = 16, // Depth of write address channel fifo, minimum is 16, actual depth will be displayed in the information of module
        parameter int       W_DEPTH = 16, // Depth of write data channel fifo, minimum is 16, actual depth will be displayed in the information of module
        parameter int       B_DEPTH = 16, // Depth of write response channel fifo, minimum is 16, actual depth will be displayed in the information of module
        parameter int       AR_DEPTH = 16, // Depth of read address channel fifo, minimum is 16, actual depth will be displayed in the information of module
        parameter int       R_DEPTH = 16, // Depth of read data channel fifo, minimum is 16, actual depth will be displayed in the information of module
        parameter           AW_MEM_STYLE = "Distributed", // Write address channel memory style: "Distributed" or "Block"
        parameter           W_MEM_STYLE = "Distributed", // Write data channel memory style: "Distributed" or "Block"
        parameter           B_MEM_STYLE = "Distributed", // Write response channel memory style: "Distributed" or "Block"
        parameter           AR_MEM_STYLE = "Distributed", // Read address channel memory style: "Distributed" or "Block"
        parameter           R_MEM_STYLE = "Distributed", // Read data channel memory style: "Distributed" or "Block"
        parameter reg [9:0] AW_PAYLOAD_MASK = '1, // Write address channel mask in which each bit, when zero removes the data from the payload: [7 - awprot]
        parameter reg [2:0] W_PAYLOAD_MASK = '1, // Write data channel mask in which each bit, when zero removes the data from the payload: [0 - wstrb]
        parameter reg [2:0] B_PAYLOAD_MASK = '1, // Write response channel mask in which each bit, when zero removes the data from the payload: [1 - bresp]
        parameter reg [9:0] AR_PAYLOAD_MASK = '1, // Read address channel mask in which each bit, when zero removes the data from the payload: [7 - arprot]
        parameter reg [3:0] R_PAYLOAD_MASK = '1, // Read data channel mask in which each bit, when zero removes the data from the payload: [1 - rresp]
        parameter reg [7:0] AW_FEATURES = '0, // Write address channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        parameter reg [7:0] W_FEATURES = '0, // Write data channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        parameter reg [7:0] B_FEATURES = '0, // Write response channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        parameter reg [7:0] AR_FEATURES = '0, // Read address channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        parameter reg [7:0] R_FEATURES = '0, // Read data channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]        
        parameter int       AW_PROG_FULL = 12, // Write address channel programmable full threshold
        parameter int       W_PROG_FULL = 12, // Write data channel programmable full threshold
        parameter int       B_PROG_FULL = 12, // Write response channel programmable full threshold
        parameter int       AR_PROG_FULL = 12, // Read address channel programmable full threshold
        parameter int       R_PROG_FULL = 12, // Read data channel programmable full threshold
        parameter int       AW_PROG_EMPTY = 4, // Write address channel programmable empty threshold
        parameter int       W_PROG_EMPTY = 4, // Write data channel programmable empty threshold
        parameter int       B_PROG_EMPTY = 4, // Write response channel programmable empty threshold
        parameter int       AR_PROG_EMPTY = 4, // Read address channel programmable empty threshold
        parameter int       R_PROG_EMPTY = 4, // Read data channel programmable empty threshold
        parameter int       AW_CW = $clog2(AW_DEPTH)+1, // Write address channel count width
        parameter int       W_CW = $clog2(W_DEPTH)+1, // Write data channel count width
        parameter int       B_CW = $clog2(B_DEPTH)+1, // Write response channel count width
        parameter int       AR_CW = $clog2(AR_DEPTH)+1, // Read address channel count width
        parameter int       R_CW = $clog2(R_DEPTH)+1 // Read data channel count width
    )
    (
        input   logic                    i_axil_fifo_a_rst_n, // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

// AXI4-Lite slave interface
        input   logic                    s_axil_fifo_a_clk_p,
        input   logic                    s_axil_fifo_s_rst_n,

        input   logic                    s_axil_fifo_awvalid,
        output  logic                    s_axil_fifo_awready,
        input   logic [  ADDR_WIDTH-1:0] s_axil_fifo_awaddr,
        input   logic [             2:0] s_axil_fifo_awprot,
        input   logic                    s_axil_fifo_wvalid,
        output  logic                    s_axil_fifo_wready,
        input   logic [8*DATA_WIDTH-1:0] s_axil_fifo_wdata,
        input   logic [  DATA_WIDTH-1:0] s_axil_fifo_wstrb,
        output  logic                    s_axil_fifo_bvalid,
        input   logic                    s_axil_fifo_bready,
        output  logic [             1:0] s_axil_fifo_bresp,
        input   logic                    s_axil_fifo_arvalid,
        output  logic                    s_axil_fifo_arready,
        input   logic [  ADDR_WIDTH-1:0] s_axil_fifo_araddr,
        input   logic [             2:0] s_axil_fifo_arprot,
        output  logic                    s_axil_fifo_rvalid,
        input   logic                    s_axil_fifo_rready,
        output  logic [8*DATA_WIDTH-1:0] s_axil_fifo_rdata,
        output  logic [             1:0] s_axil_fifo_rresp,

// AXI4-Lite master interface
        input   logic                    m_axil_fifo_a_clk_p,
        input   logic                    m_axil_fifo_s_rst_n,

        output  logic                    m_axil_fifo_awvalid,
        input   logic                    m_axil_fifo_awready,
        output  logic [  ADDR_WIDTH-1:0] m_axil_fifo_awaddr,
        output  logic [             2:0] m_axil_fifo_awprot,
        output  logic                    m_axil_fifo_wvalid,
        input   logic                    m_axil_fifo_wready,
        output  logic [8*DATA_WIDTH-1:0] m_axil_fifo_wdata,
        output  logic [  DATA_WIDTH-1:0] m_axil_fifo_wstrb,
        input   logic                    m_axil_fifo_bvalid,
        output  logic                    m_axil_fifo_bready,
        input   logic [             1:0] m_axil_fifo_bresp,
        output  logic                    m_axil_fifo_arvalid,
        input   logic                    m_axil_fifo_arready,
        output  logic [  ADDR_WIDTH-1:0] m_axil_fifo_araddr,
        output  logic [             2:0] m_axil_fifo_arprot,
        input   logic                    m_axil_fifo_rvalid,
        output  logic                    m_axil_fifo_rready,
        input   logic [8*DATA_WIDTH-1:0] m_axil_fifo_rdata,
        input   logic [             1:0] m_axil_fifo_rresp,

        output  logic                    o_axil_fifo_aw_a_tfull, // Write address channel almost full flag
        output  logic                    o_axil_fifo_aw_p_tfull, // Write address channel programmable full flag
        output  logic [       AW_CW-1:0] o_axil_fifo_aw_w_count, // Write address channel write data count

        output  logic                    o_axil_fifo_aw_a_empty, // Write address channel almost empty flag
        output  logic                    o_axil_fifo_aw_p_empty, // Write address channel programmable empty flag
        output  logic [       AW_CW-1:0] o_axil_fifo_aw_r_count, // Write address channel read data count, if dual clock mode is false - output count is the same with write data count

        output  logic                    o_axil_fifo_w_a_tfull, // Write data channel almost full flag
        output  logic                    o_axil_fifo_w_p_tfull, // Write data channel programmable full flag
        output  logic [        W_CW-1:0] o_axil_fifo_w_w_count, // Write data channel write data count

        output  logic                    o_axil_fifo_w_a_empty, // Write data channel almost empty flag
        output  logic                    o_axil_fifo_w_p_empty, // Write data channel programmable empty flag
        output  logic [        W_CW-1:0] o_axil_fifo_w_r_count, // Write data channel read data count, if dual clock mode is false - output count is the same with write data count

        output  logic                    o_axil_fifo_b_a_tfull, // Write response channel almost full flag
        output  logic                    o_axil_fifo_b_p_tfull, // Write response channel programmable full flag
        output  logic [        B_CW-1:0] o_axil_fifo_b_w_count, // Write response channel write data count

        output  logic                    o_axil_fifo_b_a_empty, // Write response channel almost empty flag
        output  logic                    o_axil_fifo_b_p_empty, // Write response channel programmable empty flag
        output  logic [        B_CW-1:0] o_axil_fifo_b_r_count, // Write response channel read data count, if dual clock mode is false - output count is the same with write data count

        output  logic                    o_axil_fifo_ar_a_tfull, // Read address channel almost full flag
        output  logic                    o_axil_fifo_ar_p_tfull, // Read address channel programmable full flag
        output  logic [       AR_CW-1:0] o_axil_fifo_ar_w_count, // Read address channel write data count

        output  logic                    o_axil_fifo_ar_a_empty, // Read address channel almost empty flag
        output  logic                    o_axil_fifo_ar_p_empty, // Read address channel programmable empty flag
        output  logic [       AR_CW-1:0] o_axil_fifo_ar_r_count, // Read address channel read data count, if dual clock mode is false - output count is the same with write data count

        output  logic                    o_axil_fifo_r_a_tfull, // Read data channel almost full flag
        output  logic                    o_axil_fifo_r_p_tfull, // Read data channel programmable full flag
        output  logic [        R_CW-1:0] o_axil_fifo_r_w_count, // Read data channel write data count

        output  logic                    o_axil_fifo_r_a_empty, // Read data channel almost empty flag
        output  logic                    o_axil_fifo_r_p_empty, // Read data channel programmable empty flag
        output  logic [        R_CW-1:0] o_axil_fifo_r_r_count  // Read data channel read data count, if dual clock mode is false - output count is the same with write data count
    );

    iaxil #( .A(ADDR_WIDTH), .N(DATA_WIDTH) ) s_axil_fifo ( s_axil_fifo_a_clk_p, s_axil_fifo_s_rst_n, '1 );
    iaxil #( .A(ADDR_WIDTH), .N(DATA_WIDTH) ) m_axil_fifo ( m_axil_fifo_a_clk_p, m_axil_fifo_s_rst_n, '1 );

    assign s_axil_fifo_a_clk_p = s_axil_fifo.a_clk_p;
    assign s_axil_fifo_s_rst_n = s_axil_fifo.s_rst_n;
    assign s_axil_fifo.awvalid = s_axil_fifo_awvalid;
    assign s_axil_fifo_awready = s_axil_fifo.awready;
    assign s_axil_fifo.awaddr = s_axil_fifo_awaddr;
    assign s_axil_fifo.awprot = s_axil_fifo_awprot;
    assign s_axil_fifo.wvalid = s_axil_fifo_wvalid;
    assign s_axil_fifo_wready = s_axil_fifo.wready;
    assign s_axil_fifo.wdata = s_axil_fifo_wdata;
    assign s_axil_fifo.wstrb = s_axil_fifo_wstrb;
    assign s_axil_fifo_bvalid = s_axil_fifo.bvalid;
    assign s_axil_fifo.bready = s_axil_fifo_bready;
    assign s_axil_fifo_bresp = s_axil_fifo.bresp;
    assign s_axil_fifo.arvalid = s_axil_fifo_arvalid;
    assign s_axil_fifo_arready = s_axil_fifo.arready;
    assign s_axil_fifo.araddr = s_axil_fifo_araddr;
    assign s_axil_fifo.arprot = s_axil_fifo_arprot;
    assign s_axil_fifo_rvalid = s_axil_fifo.rvalid;
    assign s_axil_fifo.rready = s_axil_fifo_rready;
    assign s_axil_fifo_rdata = s_axil_fifo.rdata;
    assign s_axil_fifo_rresp = s_axil_fifo.rresp;

    assign m_axil_fifo_a_clk_p = m_axil_fifo.a_clk_p;
    assign m_axil_fifo_s_rst_n = m_axil_fifo.s_rst_n;
    assign m_axil_fifo_awvalid = m_axil_fifo.awvalid;
    assign m_axil_fifo.awready = m_axil_fifo_awready;
    assign m_axil_fifo_awaddr = m_axil_fifo.awaddr;
    assign m_axil_fifo_awprot = m_axil_fifo.awprot;
    assign m_axil_fifo_wvalid = m_axil_fifo.wvalid;
    assign m_axil_fifo.wready = m_axil_fifo_wready;
    assign m_axil_fifo_wdata = m_axil_fifo.wdata;
    assign m_axil_fifo_wstrb = m_axil_fifo.wstrb;
    assign m_axil_fifo.bvalid = m_axil_fifo_bvalid;
    assign m_axil_fifo_bready = m_axil_fifo.bready;
    assign m_axil_fifo.bresp = m_axil_fifo_bresp;
    assign m_axil_fifo_arvalid = m_axil_fifo.arvalid;
    assign m_axil_fifo.arready = m_axil_fifo_arready;
    assign m_axil_fifo_araddr = m_axil_fifo.araddr;
    assign m_axil_fifo_arprot = m_axil_fifo.arprot;
    assign m_axil_fifo.rvalid = m_axil_fifo_rvalid;
    assign m_axil_fifo_rready = m_axil_fifo.rready;
    assign m_axil_fifo.rdata = m_axil_fifo_rdata;
    assign m_axil_fifo.rresp = m_axil_fifo_rresp;

    axil_fifo #(
        .DUAL_CLOCK ( DUAL_CLOCK ), // Dual clock fifo: "True" or "False"
        .SYNC_STAGES ( SYNC_STAGES ), // Number of synchronization stages in dual clock mode: [2, 3, 4]
        .RESET_SYNC ( RESET_SYNC ), // Asynchronous reset synchronization: "True" or "False"
        .AW_DEPTH ( AW_DEPTH ), // Depth of write address channel fifo, minimum is 16, actual depth will be displayed in the information of module
        .W_DEPTH ( W_DEPTH ), // Depth of write data channel fifo, minimum is 16, actual depth will be displayed in the information of module
        .B_DEPTH ( B_DEPTH ), // Depth of write response channel fifo, minimum is 16, actual depth will be displayed in the information of module
        .AR_DEPTH ( AR_DEPTH ), // Depth of read address channel fifo, minimum is 16, actual depth will be displayed in the information of module
        .R_DEPTH ( R_DEPTH ), // Depth of read data channel fifo, minimum is 16, actual depth will be displayed in the information of module
        .AW_MEM_STYLE ( AW_MEM_STYLE ), // Write address channel memory style: "Distributed" or "Block"
        .W_MEM_STYLE ( W_MEM_STYLE ), // Write data channel memory style: "Distributed" or "Block"
        .B_MEM_STYLE ( B_MEM_STYLE ), // Write response channel memory style: "Distributed" or "Block"
        .AR_MEM_STYLE ( AR_MEM_STYLE ), // Read address channel memory style: "Distributed" or "Block"
        .R_MEM_STYLE ( R_MEM_STYLE ), // Read data channel memory style: "Distributed" or "Block"
        .AW_PAYLOAD_MASK ( AW_PAYLOAD_MASK ), // Write address channel mask in which each bit, when zero removes the data from the payload: [7 - awprot]
        .W_PAYLOAD_MASK ( W_PAYLOAD_MASK ), // Write data channel mask in which each bit, when zero removes the data from the payload: [0 - wstrb]
        .B_PAYLOAD_MASK ( B_PAYLOAD_MASK ), // Write response channel mask in which each bit, when zero removes the data from the payload: [1 - bresp]
        .AR_PAYLOAD_MASK ( AR_PAYLOAD_MASK ), // Read address channel mask in which each bit, when zero removes the data from the payload: [7 - arprot]
        .R_PAYLOAD_MASK ( R_PAYLOAD_MASK ), // Read data channel mask in which each bit, when zero removes the data from the payload: [1 - rresp]
        .AW_FEATURES ( AW_FEATURES ), // Write address channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        .W_FEATURES ( W_FEATURES ), // Write data channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        .B_FEATURES ( B_FEATURES ), // Write response channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        .AR_FEATURES ( AR_FEATURES ), // Read address channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
        .R_FEATURES ( R_FEATURES ), // Read data channel advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]        
        .AW_PROG_FULL ( AW_PROG_FULL ), // Write address channel programmable full threshold
        .W_PROG_FULL ( W_PROG_FULL ), // Write data channel programmable full threshold
        .B_PROG_FULL ( B_PROG_FULL ), // Write response channel programmable full threshold
        .AR_PROG_FULL ( AR_PROG_FULL ), // Read address channel programmable full threshold
        .R_PROG_FULL ( R_PROG_FULL ), // Read data channel programmable full threshold
        .AW_PROG_EMPTY ( AW_PROG_EMPTY ), // Write address channel programmable empty threshold
        .W_PROG_EMPTY ( W_PROG_EMPTY ), // Write data channel programmable empty threshold
        .B_PROG_EMPTY ( B_PROG_EMPTY ), // Write response channel programmable empty threshold
        .AR_PROG_EMPTY ( AR_PROG_EMPTY ), // Read address channel programmable empty threshold
        .R_PROG_EMPTY ( R_PROG_EMPTY ), // Read data channel programmable empty threshold
        .AW_CW ( AW_CW ), // Write address channel count width
        .W_CW ( W_CW ), // Write data channel count width
        .B_CW ( B_CW ), // Write response channel count width
        .AR_CW ( AR_CW ), // Read address channel count width
        .R_CW ( R_CW ) // Read data channel count width
    ) axil_fifo_inst (
        .i_axil_fifo_a_rst_n    ( i_axil_fifo_a_rst_n ), // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

        .s_axil_fifo            ( s_axil_fifo ), // AXI4-Lite slave interface
        .m_axil_fifo            ( m_axil_fifo ), // AXI4-Lite master interface

        .o_axil_fifo_aw_a_tfull ( o_axil_fifo_aw_a_tfull ), // Write address channel almost full flag
        .o_axil_fifo_aw_p_tfull ( o_axil_fifo_aw_p_tfull ), // Write address channel programmable full flag
        .o_axil_fifo_aw_w_count ( o_axil_fifo_aw_w_count ), // Write address channel write data count

        .o_axil_fifo_aw_a_empty ( o_axil_fifo_aw_a_empty ), // Write address channel almost empty flag
        .o_axil_fifo_aw_p_empty ( o_axil_fifo_aw_p_empty ), // Write address channel programmable empty flag
        .o_axil_fifo_aw_r_count ( o_axil_fifo_aw_r_count ), // Write address channel read data count, if dual clock mode is false - output count is the same with write data count

        .o_axil_fifo_w_a_tfull  ( o_axil_fifo_w_a_tfull ), // Write data channel almost full flag
        .o_axil_fifo_w_p_tfull  ( o_axil_fifo_w_p_tfull ), // Write data channel programmable full flag
        .o_axil_fifo_w_w_count  ( o_axil_fifo_w_w_count ), // Write data channel write data count

        .o_axil_fifo_w_a_empty  ( o_axil_fifo_w_a_empty ), // Write data channel almost empty flag
        .o_axil_fifo_w_p_empty  ( o_axil_fifo_w_p_empty ), // Write data channel programmable empty flag
        .o_axil_fifo_w_r_count  ( o_axil_fifo_w_r_count ), // Write data channel read data count, if dual clock mode is false - output count is the same with write data count

        .o_axil_fifo_b_a_tfull  ( o_axil_fifo_b_a_tfull ), // Write response channel almost full flag
        .o_axil_fifo_b_p_tfull  ( o_axil_fifo_b_p_tfull ), // Write response channel programmable full flag
        .o_axil_fifo_b_w_count  ( o_axil_fifo_b_w_count ), // Write response channel write data count

        .o_axil_fifo_b_a_empty  ( o_axil_fifo_b_a_empty ), // Write response channel almost empty flag
        .o_axil_fifo_b_p_empty  ( o_axil_fifo_b_p_empty ), // Write response channel programmable empty flag
        .o_axil_fifo_b_r_count  ( o_axil_fifo_b_r_count ), // Write response channel read data count, if dual clock mode is false - output count is the same with write data count

        .o_axil_fifo_ar_a_tfull ( o_axil_fifo_ar_a_tfull ), // Read address channel almost full flag
        .o_axil_fifo_ar_p_tfull ( o_axil_fifo_ar_p_tfull ), // Read address channel programmable full flag
        .o_axil_fifo_ar_w_count ( o_axil_fifo_ar_w_count ), // Read address channel write data count

        .o_axil_fifo_ar_a_empty ( o_axil_fifo_ar_a_empty ), // Read address channel almost empty flag
        .o_axil_fifo_ar_p_empty ( o_axil_fifo_ar_p_empty ), // Read address channel programmable empty flag
        .o_axil_fifo_ar_r_count ( o_axil_fifo_ar_r_count ), // Read address channel read data count, if dual clock mode is false - output count is the same with write data count

        .o_axil_fifo_r_a_tfull  ( o_axil_fifo_r_a_tfull ), // Read data channel almost full flag
        .o_axil_fifo_r_p_tfull  ( o_axil_fifo_r_p_tfull ), // Read data channel programmable full flag
        .o_axil_fifo_r_w_count  ( o_axil_fifo_r_w_count ), // Read data channel write data count

        .o_axil_fifo_r_a_empty  ( o_axil_fifo_r_a_empty ), // Read data channel almost empty flag
        .o_axil_fifo_r_p_empty  ( o_axil_fifo_r_p_empty ), // Read data channel programmable empty flag
        .o_axil_fifo_r_r_count  ( o_axil_fifo_r_r_count )  // Read data channel read data count, if dual clock mode is false - output count is the same with write data count
    );

endmodule