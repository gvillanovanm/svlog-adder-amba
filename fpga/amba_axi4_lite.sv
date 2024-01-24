/**
 * amba_axi4_lite
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module amba_axi4_lite #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 5
)(
    // standard if
    input logic  S_AXI_ACLK,
    input logic  S_AXI_ARESETN,

    input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input logic [2 : 0] S_AXI_AWPROT,
    input logic  S_AXI_AWVALID,
    output logic  S_AXI_AWREADY,

    input logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input logic  S_AXI_WVALID,
    output logic  S_AXI_WREADY,

    output logic [1 : 0] S_AXI_BRESP,
    output logic  S_AXI_BVALID,
    input logic  S_AXI_BREADY,

    input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input logic [2 : 0] S_AXI_ARPROT,
    input logic  S_AXI_ARVALID,
    output logic  S_AXI_ARREADY,

    output logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output logic [1 : 0] S_AXI_RRESP,
    output logic  S_AXI_RVALID,
    input logic  S_AXI_RREADY,
    
    // custom signals to ctrl module
    input logic i_is_busy,

    // custom signals to RB
    output logic o_en_amba_write,
    output logic [31:0] o_data_wc,
    output logic [31:0] o_addr_wc,
    output logic [3:0] o_strb, // bytes to enable (default 1111 -> 32 bytes)
    input logic [31:0] i_data_rc,
    output logic [31:0] o_addr_rc
);

// -------------------------------------------------------
// localparam and common types
// -------------------------------------------------------
localparam int unsigned SIZE_STRB = 4;
localparam int unsigned SIZE_ADDR = 32;

// -------------------------------------------------------
// typedefs
// -------------------------------------------------------

// write channel states
typedef enum logic[1:0] {
    wc_state_idle,
    wc_state_wait_addr,
    wc_state_wait_data,
    wc_state_exec
} WC_STATE_E;

// read channel states
typedef enum logic[1:0] {
    rc_state_idle,
    rc_state_wait_addr,
    rc_state_exec
} RC_STATE_E;

enum logic [1:0] {
    AXI4_RESP_L_OKAY,
    AXI4_RESP_L_EXOKAY, // not supported on AXI4-Lite
    AXI4_RESP_L_SLVERR,
    AXI4_RESP_L_DECERR
} axi4_resp_el;

// -------------------------------------------------------
// wires and internal variables
// -------------------------------------------------------
WC_STATE_E STATE_wc;
RC_STATE_E STATE_rc;

// write channel
logic [SIZE_ADDR-1:0]read_AWADDR;
logic [C_S_AXI_DATA_WIDTH-1:0]read_WDATA;
logic [SIZE_STRB-1:0]read_WSTRB;
logic w_en_amba_write_wc;
logic w_is_busy_wc;

// read channel
logic [2:0]read_ARPROT;
logic [SIZE_ADDR-1:0]read_ARADDR;
logic w_is_busy_rc;

// -------------------------------------------------------
// write channel
// -------------------------------------------------------
always_ff @(posedge S_AXI_ACLK) begin
    if(~S_AXI_ARESETN) begin
        STATE_wc           <= wc_state_idle;
        read_AWADDR        <= 0;
        read_WSTRB         <= 0;
        read_WDATA         <= 0;
        w_en_amba_write_wc <= 0;
    end  else begin
        case (STATE_wc)
            // idle
            wc_state_idle: begin
                STATE_wc           <= wc_state_wait_addr;
                w_en_amba_write_wc <= 0;
                w_is_busy_wc       <= 0;
            end

            // wait address
            wc_state_wait_addr: begin
                case({S_AXI_AWVALID,S_AXI_WVALID})
                    // address write is valid then wait data and get address
                    2'b10: begin
                        STATE_wc     <= wc_state_wait_data;
                        read_AWADDR  <= S_AXI_AWADDR;
                        w_is_busy_wc <= 0;
                    end

                    // address and data are valid
                    2'b11: begin
                        STATE_wc     <= wc_state_exec;
                        read_AWADDR  <= S_AXI_AWADDR;
                        read_WDATA   <= S_AXI_WDATA;
                        read_WSTRB   <= S_AXI_WSTRB;
                        w_is_busy_wc <= i_is_busy;
                    end
                    
                    default: w_is_busy_wc <= 0;
                endcase
                
				w_en_amba_write_wc <= 0;
            end
            
            // wait data
            wc_state_wait_data: begin
                if(S_AXI_WVALID) begin
                    STATE_wc       <= wc_state_exec;
                    read_WDATA     <= S_AXI_WDATA;
                    read_WSTRB     <= S_AXI_WSTRB;
                    w_is_busy_wc   <= i_is_busy;
                end else begin
                    w_is_busy_wc   <= 0;
                end
                
				w_en_amba_write_wc <= 0;
            end

            // exec
            wc_state_exec: begin
                if(S_AXI_BREADY) begin
                    STATE_wc <= wc_state_wait_addr;
                end
                
				w_en_amba_write_wc <= 1;
                w_is_busy_wc       <= i_is_busy;
            end
        endcase
    end
end

// define output of write channel based on states
always_comb  begin
    case (STATE_wc)
        // idle
        wc_state_idle: begin
			// amba
            S_AXI_AWREADY   = 0;
            S_AXI_WREADY    = 0;
            S_AXI_BVALID    = 0;
            S_AXI_BRESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // wait address
        wc_state_wait_addr: begin
            // amba
			S_AXI_AWREADY   = 1;
            S_AXI_WREADY    = 1;
            S_AXI_BVALID    = 0;
            S_AXI_BRESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // wait data
        wc_state_wait_data: begin
			// amba
            S_AXI_AWREADY   = 0;
            S_AXI_WREADY    = 1;
            S_AXI_BVALID    = 0;
            S_AXI_BRESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // exec
        wc_state_exec: begin
			// amba
            S_AXI_AWREADY = 0;
            S_AXI_WREADY = 0;

			// reg
            o_data_wc = read_WDATA;
            o_addr_wc = read_AWADDR;
            o_strb    = read_WSTRB;
            
            // ip is not busy and the adress is within the range
            if(!w_is_busy_wc && read_AWADDR[31:8] == 24'h000000 && read_AWADDR[7:0] < 8'h14) begin
                S_AXI_BRESP     = AXI4_RESP_L_OKAY;
                o_en_amba_write = (w_en_amba_write_wc) ? 0 : 1;
            
            // ip is busy and/or address is out of range
            end else begin
                S_AXI_BRESP     = AXI4_RESP_L_SLVERR;
                o_en_amba_write = 0;
            end

            // return answer whatever
            S_AXI_BVALID  = 1;
        end
    endcase
end 

// -------------------------------------------------------
// read channel
// -------------------------------------------------------
always_ff @(posedge S_AXI_ACLK) begin    
    if(~S_AXI_ARESETN) begin
        STATE_rc    <= rc_state_idle;
        read_ARPROT <= 0;
        read_ARADDR <= 0;
    end else begin
        case(STATE_rc)
            // idle
            rc_state_idle: begin
                STATE_rc     <= rc_state_wait_addr;
                w_is_busy_rc <= 0;
            end

            // wait addre
            rc_state_wait_addr: begin
                if(S_AXI_ARVALID) begin
                    read_ARADDR  <= S_AXI_ARADDR;
                    read_ARPROT  <= S_AXI_ARPROT;
                    STATE_rc     <= rc_state_exec;
                    w_is_busy_rc <= i_is_busy;
                end
            end

            // exec
            rc_state_exec: begin
                if(S_AXI_RREADY) begin
                    STATE_rc <= rc_state_wait_addr;
                end

                w_is_busy_rc <= i_is_busy;
            end
        endcase 
    end 
end

always_comb begin    
    case (STATE_rc)
		// idle
        rc_state_idle: begin
			S_AXI_ARREADY = 0;
			S_AXI_RVALID  = 0;
			S_AXI_RRESP	  = AXI4_RESP_L_OKAY;
			S_AXI_RDATA   = 0;
            o_addr_rc     = 0;
        end

        // wait addr
        rc_state_wait_addr: begin
            S_AXI_ARREADY = 1;
            S_AXI_RVALID  = 0;
            S_AXI_RRESP   = AXI4_RESP_L_OKAY;
            S_AXI_RDATA   = 0;
            o_addr_rc     = 0;
        end

        // exec
        rc_state_exec: begin
            S_AXI_ARREADY = 0;
            S_AXI_RVALID  = 1;
            o_addr_rc     = read_ARADDR;

            if(!w_is_busy_rc && read_ARADDR[31:8] == 0) begin
                S_AXI_RRESP = AXI4_RESP_L_OKAY;
                S_AXI_RDATA = i_data_rc;
            end else begin
                S_AXI_RRESP = AXI4_RESP_L_SLVERR;
                S_AXI_RDATA = 0;
            end
        end
    endcase
end

endmodule