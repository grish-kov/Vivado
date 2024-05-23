`timescale 1ns / 1ps

module tb_axil_fifo #(
	int G_RM_ADDR_W = 12, // AXIL xADDR bit width
	int G_RM_DATA_B = 8, // AXIL xDATA number of bytes (B)
	
	int G_CG_L      = 39 * 8, // codogram length (L), bytes
	int G_USER_W    = 1, // sync-pulse-as-TUSER bit width (W)
	int G_CG_DATA_B = 1, // codogram TDATA number of bytes (B)
	int G_DG_DATA_B = 32, // datagram TDATA number of bytes (B)
	
	T_CLK = 1.0, 
	real dt = 1.0 // clock period ns
);

	// constants
	localparam C_RM_DATA_W = 8 * G_RM_DATA_B; // AXIL xDATA bit width
	localparam C_CG_DATA_W = 8 * G_CG_DATA_B; // codogram TDATA bit width
	localparam C_DG_DATA_W = 8 * G_DG_DATA_B; // datagram TDATA bit width

	reg [2 : 0] i_rst = 1;
	logic i_rst_n = '1;
	reg [C_CG_DATA_W-1:0] v_cdg_ram [0:8*G_CG_L-1];// = '{default: '0}; 
	logic i_fifo_reset;
	logic i_clk	= 1; 

	if_axil #(
		.N(G_RM_DATA_B), 
		.A(G_RM_ADDR_W)
		) s_axil ();

	if_axil #(
		.N(G_RM_DATA_B), 
		.A(G_RM_ADDR_W)
		) m_axil ();

	typedef logic [G_RM_ADDR_W-1:0] t_xaddr;
	typedef logic [C_RM_DATA_W-1:0] t_xdata;

	task t_axil_init;
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
			s_axil.rresp   = '0;
			
		end
	endtask : t_axil_init

	`define MACRO_AXIL_HSK(miso, mosi) \
		s_axil.``mosi``= '1; \
		do begin \
			#dt; \
		end while (!(s_axil.``miso`` && s_axil.``mosi``)); \
		s_axil.``mosi`` = '0; \

	task t_axil_wr;
		input t_xaddr ADDR;
		input t_xdata DATA;
		begin
		// write address
			s_axil.awaddr = ADDR;
			`MACRO_AXIL_HSK(awready, awvalid);
		// write data
			s_axil.wdata = DATA;
			s_axil.wstrb = '1;
			`MACRO_AXIL_HSK(wready, wvalid);
		// write response
			`MACRO_AXIL_HSK(bvalid, bready);
		end
	endtask : t_axil_wr

	task t_axil_rd;
		input  t_xaddr ADDR;
		//	output t_xdata DATA;
		begin
		// read address
			s_axil.araddr = ADDR;
			`MACRO_AXIL_HSK(arready, arvalid);
		// read data
			s_axil.rresp = 2'b00;
			`MACRO_AXIL_HSK(rvalid, rready);
		//	DATA = s_axil.rdata;
		end
	endtask : t_axil_rd

	localparam t_xaddr RW_TRN_ENA = 'h000; // 0 - truncation enable
	localparam t_xaddr WR_TRN_TBL = 'h008; // truncation table: 31:24 - scan mode id, 23:0 - max period?
	localparam t_xaddr RW_GLU_ENA = 'h100; // 0 - gluing enable
	localparam t_xaddr RW_GLU_OFS = 'h108; // 7:0 - gluing offset for SId#0, 15:8 - gluing offset for SId#1, etc
	localparam t_xaddr RW_DWS_PRM = 'h200; // 15:8 - decimation phase, 7:0 - decimation factor

	initial begin
	i_rst_n = '0; #5;
	i_rst_n = '1;
	end

	initial begin
		
		t_axil_init; #20;

		m_axil.bvalid <= 1;

		t_axil_wr(.ADDR(WR_TRN_TBL), .DATA({8'(0), 24'(625)})); #(dt); // truncation table: 31:24 - scan mode id, 23:0 - max period?
		t_axil_wr(.ADDR(WR_TRN_TBL), .DATA({8'(0), 24'(666)})); #(dt);
		t_axil_wr(.ADDR(RW_GLU_ENA), .DATA({8'(0), 24'(1)})); #(dt);

	end

	always #(T_CLK/2.0) i_clk = ~i_clk;

	if_axis #(.N(G_CG_DATA_B), .U(G_USER_W), .PAYMASK(4'b1001)) s_axis_cg (); // input codogram AXIS
	if_axis #(.N(G_DG_DATA_B), .U(G_USER_W), .PAYMASK(4'b1001)) s_axis_dg (); // input datagram AXIS

	// initialize AXIS
	`define MACRO_AXIS_INIT(if_suffix) \
		s_axis_``if_suffix``.tvalid = '0; \
		s_axis_``if_suffix``.tlast  = '0; \
		s_axis_``if_suffix``.tdata  = '0; \
		s_axis_``if_suffix``.tuser  = '0; \
		s_axis_``if_suffix``.tready = '1; \

	// AXIS handshake
	`define MACRO_AXIS_HSK(if_suffix, value, sync_en, tlast_en) \
		s_axis_``if_suffix``.tvalid = '1; \
		s_axis_``if_suffix``.tlast  = ``tlast_en``; \
		s_axis_``if_suffix``.tdata  = ``value``; \
		s_axis_``if_suffix``.tuser  = ``sync_en``; \
		do begin \
			#dt; \
		end while (!(s_axis_``if_suffix``.tvalid && s_axis_``if_suffix``.tready)); \
		s_axis_``if_suffix``.tvalid = '0; \
		s_axis_``if_suffix``.tlast  = '0; \
		s_axis_``if_suffix``.tuser  = '0; \
		v_``if_suffix``_cnt++; \

	logic [  C_CG_DATA_W-1:0] v_cg_data = '0;
	logic [2*C_CG_DATA_W-1:0] v_dg_len  = '0;
	int v_cg_cnt = 0;

	task t_axis_cg;
		input int k;
		begin
			for (int i = 0; i < G_CG_L; i++) begin
				v_cg_data = v_cdg_ram[G_CG_L * k + i];
				`MACRO_AXIS_HSK(cg, v_cg_data, (i == 0), (i == G_CG_L-1));
				if (i == 40)
					v_dg_len = v_cg_data;
				else if (i == 41)
					v_dg_len = v_cg_data << C_CG_DATA_W | v_dg_len;
			end
		end
	endtask : t_axis_cg

	localparam int C_RX_CHAN_N = C_DG_DATA_W / 32; // number of Rx channels
	logic [C_RX_CHAN_N-1:0][31:0] v_dg_data = '0;
	int v_dg_cnt = 0;

	task t_axis_dg;
		begin
			for (int n = 0; n < v_dg_len; n++) begin
				for (int j = 0; j < C_RX_CHAN_N; j++)
					v_dg_data[j] = C_RX_CHAN_N * n + j;
				`MACRO_AXIS_HSK(dg, v_dg_data, (n == 0), (n == v_dg_len-1));
				#(15*dt);
			end
		end
	endtask : t_axis_dg

	// simulate codograms and datagrams
	initial begin

		`MACRO_AXIS_INIT(cg);
		`MACRO_AXIS_INIT(dg); #500;
		for (int k = 0; k < 8; k++) begin
			t_axis_cg(k); #100;
			t_axis_dg; #100;
		end
		
	end

	if_axis #(.N(G_DG_DATA_B), .U(0), .PAYMASK(4'b1001)) m_axis (); // output package AXIS

	/*task send_packet;

		input int       i_len;
		input reg [6:0] i_set;
		
			// 0 - send header
			// 1 - lower tvalid after header
			// 2 - send length
			// 3 - lower tvalid after length
			// 4 - lower tvalid before crc
			// 5 - send fake crc
			// 6 - make tlast
		
		
		begin

			m_axis.tvalid <= 1;
			
			if (i_set[0]) begin
				
				m_axis.tdata <= 72;

				#(T_CLK);

				if (i_set[1]) begin
					m_axis.tvalid <= 0;
					#(T_CLK);
				end
			end
			
			m_axis.tvalid <= 1;

			if (i_set[2]) begin

				m_axis.tdata <= i_len;
				#(T_CLK);

				if (i_set[3]) begin
					m_axis.tvalid <= 0;
					#(T_CLK);
				end
			end

			m_axis.tvalid <= 1;

			for (int i = 1; i < i_len + 1; i ++) begin

				m_axis.tvalid <= 1;
				m_axis.tdata  <= i;

				#(T_CLK);
			
			end
			if (i_set[4]) begin
					m_axis.tvalid <= 0;
					#(T_CLK);
				end

			if (i_set[6]) 
				m_axis.tlast <= 1;

			if (i_set[5]) 
				m_axis.tdata <= tst_crc_arr [i_len - 1];
			else 
				m_axis.tdata <= tst_crc_arr [i_len]; 

			m_axis.tvalid <= 1;
			#(T_CLK);

			if (m_axis.tlast) 
				m_axis.tvalid <= 0;

			m_axis.tlast <= 0;
			
			#(T_CLK);

		end

	endtask
	
	#(T_CLK);
        send_packet(8, 7'b1000101); // true crc, no breaks

        #(T_CLK * 5);
        send_packet(8, 7'b1111111); // fake crc, with breaks

        #(T_CLK * 5);
        send_packet(12, 7'b0000101); // true crc, no breaks

        #(T_CLK * 5);
        send_packet(12, 7'b1011111); // true crc, with breaks

        #(T_CLK * 5);
        send_packet(10, 7'b1000000); // true crc, no header, no length, no breaks

        #(T_CLK * 5);
        send_packet(5, 7'b1111101); // fake crc, header without break, length & crc with breaks

        #(T_CLK * 5);
        send_packet(19, 7'b1110101);

        #(T_CLK * 5);
        send_packet(20, 7'b1110101);

        #(T_CLK * 5);
        send_packet(3, 7'b1000101);
		*/

        // m_axis.tvalid   <=  0;
        // m_axis.tdata    <= '0;
        // m_axis.tlast    <=  0;

	initial begin
	t_axil_init; #150;
	t_axil_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_rd(.ADDR(RW_DWS_PRM)); #10;
	
	t_axil_wr(.ADDR(RW_TRN_ENA), .DATA(1'b0)); #10; // 0 - truncation enable
	t_axil_wr(.ADDR(WR_TRN_TBL), .DATA({8'(0), 24'(625)})); #10; // truncation table: 31:24 - scan mode id, 23:0 - max period?
	t_axil_wr(.ADDR(RW_GLU_ENA), .DATA(1'b0)); #10; // 0 - gluing enable
//	t_axil_wr(.ADDR(RW_DWS_PRM), .DATA({8'(0), 8'(1)})); #10; // 15:8 - decimation phase, 7:0 - decimation factor
	
	t_axil_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_rd(.ADDR(RW_DWS_PRM)); #10;
end

	axil_fifo #(
		// .FEATURES			('{'1, '1, '1, '1, '1})
	) axil_uut (
		.s_axi_aclk_p      	(i_clk),
		.m_axi_aclk_p      	(i_clk),
		
		.s_axi_arst_n		(i_rst_n),
		.m_axi_arst_n		(i_rst_n),
		.i_fifo_rst_n		(i_fifo_reset),

		.s_axi				(s_axil),
		.m_axi				(m_axil)
	);

endmodule