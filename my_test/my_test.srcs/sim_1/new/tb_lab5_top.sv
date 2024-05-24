`timescale 1ns / 1ps

module tb_lab5_top #(

    int G_RM_ADDR_W = 4, // AXIL xADDR bit width
	int G_RM_DATA_B = 4, // AXIL xDATA number of bytes (B)
	real dt = 1.0 // clock period ns

    );

    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

    logic   i_rst_n = 1;
    logic   i_rst   = 0;
    logic   i_clk   = 1;

    reg [7 : 0] 					w_length;
	reg [C_RM_DATA_W - 1 : 0]		w_err;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
	typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

    if_axil #(
		.N		(G_RM_DATA_B), 
		.A		(G_RM_ADDR_W)
		) s_axil ();

	if_axil #(
		.N		(G_RM_DATA_B), 
		.A		(G_RM_ADDR_W)
		) m_axil ();


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
		output t_xdata DATA;
		begin
		// read address
			s_axil.araddr = ADDR;
			`MACRO_AXIL_HSK(arready, arvalid);
		// read data
			s_axil.rresp = 2'b00;
			`MACRO_AXIL_HSK(rvalid, rready);
			DATA = s_axil.rdata;
		end
	endtask : t_axil_rd

    localparam t_xaddr LEN_ADDR		= 'h00; 
	localparam t_xaddr LEN1_ADDR	= 'h02; 
	localparam t_xaddr ERR_ADDR	 	= 'h04;  

    always #(dt / 2) i_clk = ~i_clk;

    initial begin
        i_rst   = 1;
        i_rst_n = 0; 
        #2;
        i_rst   = 0;
        i_rst_n = 1;
	end

    initial begin
		
        t_axil_init; 
        #5;
        w_length = 5;
        t_axil_wr(.ADDR(LEN_ADDR), .DATA(w_length));
		// #10;
        // w_length = 8;
        // t_axil_wr(.ADDR(LEN1_ADDR), .DATA(w_length));
		// w_length = 0;
		// #10;
		// t_axil_rd(.ADDR(LEN_ADDR), .DATA(w_length));
		
		#10;
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));

	end

    lab5_top u_uut(

        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_err              (w_err),

        .s_axil				(s_axil),
		.m_axil				(m_axil)
    );

endmodule
