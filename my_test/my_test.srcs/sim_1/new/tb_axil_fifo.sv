`timescale 1ns / 1ps

module tb_axil_fifo #(
	int G_ADDR_W = 12, // AXIL xADDR bit width
	int G_DATA_B = 8, // AXIL xDATA number of bytes (B)
	
	real dt = 1.0 // clock period ns
);

// constants
localparam C_DATA_W = 8 * G_DATA_B; // AXIL xDATA bit width

// initialize TB signals
logic i_clk   = '0; // clock
logic i_rst_n = '1; // reset, active-low

always #(dt/2.0) i_clk = ~i_clk; // simulate clock

// simulate reset
initial begin
	i_rst_n = '1; #50;
	i_rst_n = '0; #10;
	i_rst_n = '1;
end



//  AXI4 Memory Mapped (lite) Parameters to Define the Signal Widths:
//    N - Data Bus Width in Bytes;
//    A - Address Width;
//    PAYMASK - Payload Mask: { awprot, wstrb, bresp, arprot, rresp }
if_axil #(.N(G_DATA_B), .A(G_ADDR_W), .PAYMASK(5'b01101)) s_axil (); // AXIL control interface
if_axil #(.N(G_DATA_B), .A(G_ADDR_W), .PAYMASK(5'b01101)) m_axil (); // AXIL control interface

typedef logic [G_ADDR_W-1:0] t_xaddr;
typedef logic [C_DATA_W-1:0] t_xdata;



// AXIL Manager

// initialize AXIL
task t_axil_m_init;
	begin
		s_axil.awvalid = '0;
		s_axil.awaddr  = '0;
		s_axil.wvalid  = '0;
		s_axil.wdata   = '0;
		s_axil.wstrb   = '0;
		s_axil.bready  = '0;
		s_axil.arvalid = '0;
		s_axil.araddr  = '0;
		s_axil.rready  = '0;
	end
endtask : t_axil_m_init

// AXIL basic handshake macro
`define MACRO_AXIL_HSK(name, miso, mosi) \
	``name``.``mosi``= '1; \
	do begin \
		#dt; \
	end while (!(``name``.``miso`` && ``name``.``mosi``)); \
	``name``.``mosi`` = '0; \

// AXIL write transaction
task t_axil_m_wr;
	input t_xaddr ADDR;
	input t_xdata DATA;
	begin
	// write address
		s_axil.awaddr = ADDR;
		`MACRO_AXIL_HSK(s_axil, awready, awvalid);
	// write data
		s_axil.wdata = DATA;
		s_axil.wstrb = '1;
		`MACRO_AXIL_HSK(s_axil, wready, wvalid);
	// write response
		`MACRO_AXIL_HSK(s_axil, bvalid, bready);
	end
endtask : t_axil_m_wr

// AXIL read transaction
task t_axil_m_rd;
	input  t_xaddr ADDR;
	begin
	// read address
		s_axil.araddr = ADDR;
		`MACRO_AXIL_HSK(s_axil, arready, arvalid);
	// read data
		`MACRO_AXIL_HSK(s_axil, rvalid, rready);
	end
endtask : t_axil_m_rd

localparam t_xaddr RW_TRN_ENA = 'h000; // 0 - truncation enable
localparam t_xaddr WR_TRN_TBL = 'h008; // truncation table: 31:24 - scan mode id, 23:0 - max period?
localparam t_xaddr RW_GLU_ENA = 'h100; // 0 - gluing enable
localparam t_xaddr RW_GLU_OFS = 'h108; // 7:0 - gluing offset for SId#0, 15:8 - gluing offset for SId#1, etc
localparam t_xaddr RW_DWS_PRM = 'h200; // 15:8 - decimation phase, 7:0 - decimation factor

// simulate read/write AXIL transactions
initial begin
	t_axil_m_init; #149.9;
	t_axil_m_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_m_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_m_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_m_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_m_rd(.ADDR(RW_DWS_PRM)); #10;
	
	t_axil_m_wr(.ADDR(RW_TRN_ENA), .DATA(1'b0)); #10; // 0 - truncation enable
	t_axil_m_wr(.ADDR(WR_TRN_TBL), .DATA({8'(0), 24'(625)})); #10; // truncation table: 31:24 - scan mode id, 23:0 - max period?
	t_axil_m_wr(.ADDR(RW_GLU_ENA), .DATA(1'b0)); #10; // 0 - gluing enable
//	t_axil_wr(.ADDR(RW_DWS_PRM), .DATA({8'(0), 8'(1)})); #10; // 15:8 - decimation phase, 7:0 - decimation factor
	
	t_axil_m_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_m_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_m_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_m_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_m_rd(.ADDR(RW_DWS_PRM)); #10;
end



// AXIL Subordinate

// initialize AXIL
task t_axil_s_init;
	begin
		m_axil.awready = '0;
		m_axil.wready  = '0;
		m_axil.bvalid  = '0;
		m_axil.bresp   = 2'b00;
		m_axil.arready = '0;
		m_axil.rvalid  = '0;
		m_axil.rresp   = '0;
		m_axil.rdata   = '0;
	end
endtask : t_axil_s_init

// AXIL write transaction
task t_axil_s_wr;
	begin
	// write address
		`MACRO_AXIL_HSK(m_axil, awvalid, awready);
	// write data
		`MACRO_AXIL_HSK(m_axil, wvalid, wready);
	// write response
		`MACRO_AXIL_HSK(m_axil, bready, bvalid);
	end
endtask : t_axil_s_wr

t_xaddr v_araddr;// = '0;

// AXIL read transaction
task t_axil_s_rd;
	begin
	// read address
		`MACRO_AXIL_HSK(m_axil, arvalid, arready);
		v_araddr = m_axil.araddr;
	// read data
		m_axil.rresp = 2'b00;
		case(v_araddr)
			RW_TRN_ENA: m_axil.rdata = 1; // 0 - truncation enable
			WR_TRN_TBL: m_axil.rdata = 2; // truncation table: 31:24 - scan mode id, 23:0 - max period?
			RW_GLU_ENA: m_axil.rdata = 3; // 0 - gluing enable
			RW_GLU_OFS: m_axil.rdata = 4; // 7:0 - gluing offset for SId#0, 15:8 - gluing offset for SId#1, etc
			RW_DWS_PRM: m_axil.rdata = 5; // 15:8 - decimation phase, 7:0 - decimation factor
		endcase
		`MACRO_AXIL_HSK(m_axil, rready, rvalid);
	end
endtask : t_axil_s_rd

// simulate read/write AXIL transactions
initial begin
	t_axil_s_init; #149.9;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	
	t_axil_s_wr; #10; // 0 - truncation enable
	t_axil_s_wr; #10; // truncation table: 31:24 - scan mode id, 23:0 - max period?
	t_axil_s_wr; #10; // 0 - gluing enable
	
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
	t_axil_s_rd; #10;
end





// Unit Under Test: AXIL FIFO
	axil_fifo
//		.FEATURES  ('{ '1,'1,'1,'1,'1 })
//		.PROG_FULL ('{ 1,1,1,1,1 })
	axil_fifo_uut(
		.s_axi_aclk_p (i_clk  ),
		.m_axi_aclk_p (i_clk  ),
		
		.s_axi_arst_n (i_rst_n),
		.m_axi_arst_n (i_rst_n),
		
		.s_axi        (s_axil ),
		.m_axi        (m_axil )
	);

endmodule : tb_axil_fifo
