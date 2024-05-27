`timescale 1ns / 1ps

module tb_lab5_top #(

    int G_RM_ADDR_W = 4, 	// AXIL xADDR bit width
	int G_RM_DATA_B = 4, 	// AXIL xDATA number of bytes (B)
	real dt = 1.0 			// clock period ns

    );

    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;
	localparam logic ena_rst = 1;

    logic i_rst 	= 0;
    logic i_clk 	= 1;

    reg [7 : 0] 				w_length;
	reg [2 : 0]					i_rst_pkt = '0;
	reg [C_RM_DATA_W - 1 : 0]	w_err;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
	typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

	if_axil #(
		.N		(G_RM_DATA_B), 
		.A		(G_RM_ADDR_W)
		) m_axil ();


    task t_axil_init;
		begin

			m_axil.awvalid = '0;
			m_axil.awaddr  = '0;
			m_axil.wvalid  = '0;
			m_axil.wdata   = '0;
			m_axil.wstrb   = '0;
			m_axil.bready  = '0;
			m_axil.arvalid = '0;
			m_axil.araddr  = '0;
			m_axil.rready  = '0;
			m_axil.rresp   = '0;
			
		end
	endtask : t_axil_init


    `define MACRO_AXIL_HSK(miso, mosi) \
		m_axil.``mosi``= '1; \
		do begin \
			#dt; \
		end while (!(m_axil.``miso`` && m_axil.``mosi``)); \
		m_axil.``mosi`` = '0; \


    task t_axil_wr;
		input t_xaddr ADDR;
		input t_xdata DATA;
		begin
		// write address
			m_axil.awaddr = ADDR;
			`MACRO_AXIL_HSK(awready, awvalid);
		// write data
			m_axil.wdata = DATA;
			m_axil.wstrb = '1;
			`MACRO_AXIL_HSK(wready, wvalid);
		// write response
			`MACRO_AXIL_HSK(bvalid, bready);
		end
	endtask : t_axil_wr   


    task t_axil_rd;
		input  t_xaddr ADDR;
		output t_xdata DATA;
		begin
		// read address
			m_axil.araddr = ADDR;
			`MACRO_AXIL_HSK(arready, arvalid);
		// read data
			m_axil.rresp = 2'b00;
			`MACRO_AXIL_HSK(rvalid, rready);
			DATA = m_axil.rdata;
		end
	endtask : t_axil_rd

    localparam t_xaddr LEN_ADDR		= 'h01; 
	localparam t_xaddr LEN1_ADDR	= 'h02; 
	localparam t_xaddr WRNG_ADDR 	= 'h03;  
	localparam t_xaddr ERR_ADDR	 	= 'h04;  

    always #(dt / 2) i_clk = ~i_clk;

    initial begin
        i_rst   = 1; 
        #2;
        i_rst   = 0;
	end

	if (ena_rst) begin

		always #(dt * 120) begin

			i_rst_pkt[0] = 1;
			#2 i_rst_pkt = 0;

		end

		always #(dt * 75) begin

			i_rst_pkt[1] = 1;
			#2 i_rst_pkt = 0;

		end

		always #(dt * 40) begin

			i_rst_pkt[2] = 1;
			#2 i_rst_pkt = 0;

		end

	end

    initial begin
		
        t_axil_init;
		w_length = 8;
		#5;
        
        t_axil_wr(.ADDR(LEN_ADDR), .DATA(w_length));
		w_length = 5;
		#10;
		
        t_axil_wr(.ADDR(LEN_ADDR), .DATA(w_length));
		
		w_length = 33;
		#10;
		
        t_axil_wr(.ADDR(LEN1_ADDR), .DATA(w_length));

		#10;
		t_axil_rd(.ADDR(WRNG_ADDR), .DATA(w_err));
		
		w_length = 0;

		#10;
		t_axil_rd(.ADDR(LEN_ADDR), .DATA(w_length));

	

	end

    lab5_top u_uut(

        .i_clk              (i_clk),
        .i_rst              (i_rst),
		.i_rst_pkt			(i_rst_pkt),

        .s_axil				(m_axil)
    );

endmodule
