`timescale 1ns / 1ps

module lab5_reg_map # (

    int G_RM_ADDR_W = 4, // AXIL xADDR bit width
	int G_RM_DATA_B = 4 // AXIL xDATA number of bytes (B)

)(
    input logic             i_err_crc,        
                            i_err_mis_tlast,  
                            i_err_unx_tlast,
                            i_clk,
                            i_rst,
    input reg   [(G_RM_DATA_B * 8) - 1 : 0] i_length,

    output reg  [(G_RM_DATA_B * 8) - 1 : 0] o_length,
                [(G_RM_DATA_B * 8) - 1 : 0] o_err,

    if_axil.s   s_axil,
    if_axil.m   m_axil
    
    );

    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
	typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

    localparam t_xaddr LEN_ADDR	    = 'h00; 
    localparam t_xaddr LEN1_ADDR	= 'h02;
	localparam t_xaddr ERR_ADDR     = 'h04;
    t_xaddr ADDR;  
    
    reg [31 : 0]    RG_LEN,
                    RG_STAT;

    reg [7 : 0] w_len = '0;

    typedef enum{

        S0,     
        S1,
        S2,
        S3
        
    } t_fsm_s;

    t_fsm_s q_crnt_s = S0;

    assign o_length         = w_len;
    assign RG_STAT[0]       = i_err_crc;
    assign RG_STAT[8]       = i_err_mis_tlast;
    assign RG_STAT[16]      = i_err_unx_tlast;

    task t_axil_init; 
        begin

            s_axil.awready = 0;
            s_axil.wready  = 0;
            s_axil.bvalid  = 0;
            s_axil.arready = 0;
            s_axil.rvalid  = 0;
            s_axil.bvalid  = 0;
            s_axil.bresp   = 0;

        end
    endtask : t_axil_init
    
    `define MACRO_AXIL_HSK(miso, mosi) \
        if ((s_axil.``miso`` && s_axil.``mosi``)) \
            s_axil.``miso`` = '0; \
        else  \
            s_axil.``miso`` = '1; \
    
    task t_axil_rd;
        output t_xaddr ADDR;
        output t_xdata DATA;
            begin
            
            ADDR = s_axil.awaddr;
            `MACRO_AXIL_HSK(awready, awvalid);
            DATA = s_axil.wdata;
            `MACRO_AXIL_HSK(wready, wvalid);
            s_axil.bresp = '0;
            `MACRO_AXIL_HSK(bvalid, bready);

        end
    endtask : t_axil_rd

    task t_axil_wr;
        output t_xaddr ADDR;
		begin

			ADDR = s_axil.araddr;
			`MACRO_AXIL_HSK(arready, arvalid);
            `MACRO_AXIL_HSK(rvalid, rready);
            case(ADDR)

                LEN_ADDR :
                    s_axil.rdata = RG_LEN [7 : 0];

                LEN1_ADDR :
                    s_axil.rdata = RG_LEN [15 : 8];

                ERR_ADDR :
                    s_axil.rdata = RG_STAT;

                default : 
                    s_axil.rdata = '1;

            endcase
			

		end
    endtask : t_axil_wr
    
    always_ff @(posedge i_clk) begin

        t_axil_rd(.ADDR(ADDR),.DATA(w_len));

        case(ADDR)

            LEN_ADDR :

                RG_LEN [7 : 0] = w_len;

            LEN1_ADDR : 

                RG_LEN [15 : 8] = w_len;

        endcase
    
        t_axil_wr(.ADDR(ADDR));

        if (i_rst) 
            t_axil_init;
    
    end

endmodule
