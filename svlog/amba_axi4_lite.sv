/**
 * amba_axi4_lite
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module amba_axi4_lite (
    // standard if
    amba_axi4_lite_if amba,
    
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
import amba_axi4_lite_types_pkg::*;
localparam int unsigned SIZE_WORD = 32;
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

// -------------------------------------------------------
// wires and internal variables
// -------------------------------------------------------
WC_STATE_E STATE_wc;
RC_STATE_E STATE_rc;

// write channel
logic [SIZE_ADDR-1:0]read_AWADDR;
logic [SIZE_WORD-1:0]read_WDATA;
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
always_ff @(posedge amba.ACLK) begin
    if(~amba.ARSTn) begin
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
                case({amba.AW.VALID,amba.W.VALID})
                    // address write is valid then wait data and get address
                    2'b10: begin
                        STATE_wc     <= wc_state_wait_data;
                        read_AWADDR  <= amba.AW.ADDR;
                        w_is_busy_wc <= 0;
                    end

                    // address and data are valid
                    2'b11: begin
                        STATE_wc     <= wc_state_exec;
                        read_AWADDR  <= amba.AW.ADDR;
                        read_WDATA   <= amba.W.DATA;
                        read_WSTRB   <= amba.W.STRB;
                        w_is_busy_wc <= i_is_busy;
                    end
                    
                    default: w_is_busy_wc <= 0;
                endcase
                
				w_en_amba_write_wc <= 0;
            end
            
            // wait data
            wc_state_wait_data: begin
                if(amba.W.VALID) begin
                    STATE_wc       <= wc_state_exec;
                    read_WDATA     <= amba.W.DATA;
                    read_WSTRB     <= amba.W.STRB;
                    w_is_busy_wc   <= i_is_busy;
                end else begin
                    w_is_busy_wc   <= 0;
                end
                
				w_en_amba_write_wc <= 0;
            end

            // exec
            wc_state_exec: begin
                if(amba.B.READY) begin
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
            amba.AW.READY   = 0;
            amba.W.READY    = 0;
            amba.B.VALID    = 0;
            amba.B.RESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // wait address
        wc_state_wait_addr: begin
            // amba
			amba.AW.READY   = 1;
            amba.W.READY    = 1;
            amba.B.VALID    = 0;
            amba.B.RESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // wait data
        wc_state_wait_data: begin
			// amba
            amba.AW.READY   = 0;
            amba.W.READY    = 1;
            amba.B.VALID    = 0;
            amba.B.RESP     = AXI4_RESP_L_OKAY;

			// reg
			o_en_amba_write = 0;
            o_data_wc       = 0;
            o_addr_wc       = 0;
            o_strb          = 0;
        end

        // exec
        wc_state_exec: begin
			// amba
            amba.AW.READY = 0;
            amba.W.READY = 0;

			// reg
            o_data_wc = read_WDATA;
            o_addr_wc = read_AWADDR;
            o_strb    = read_WSTRB;
            
            // ip is not busy and the adress is within the range
            if(!w_is_busy_wc && read_AWADDR[31:8] == 24'h000000 && read_AWADDR[7:0] < 8'h14) begin
                amba.B.RESP     = AXI4_RESP_L_OKAY;
                o_en_amba_write = (w_en_amba_write_wc) ? 0 : 1;
            
            // ip is busy and/or address is out of range
            end else begin
                amba.B.RESP     = AXI4_RESP_L_SLVERR;
                o_en_amba_write = 0;
            end

            // return answer whatever
            amba.B.VALID  = 1;
        end
    endcase
end 

// -------------------------------------------------------
// read channel
// -------------------------------------------------------
always_ff @(posedge amba.ACLK) begin    
    if(~amba.ARSTn) begin
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
                if(amba.AR.VALID) begin
                    read_ARADDR  <= amba.AR.ADDR;
                    read_ARPROT  <= amba.AR.PROT;
                    STATE_rc     <= rc_state_exec;
                    w_is_busy_rc <= i_is_busy;
                end
            end

            // exec
            rc_state_exec: begin
                if(amba.R.READY) begin
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
			amba.AR.READY = 0;
			amba.R.VALID  = 0;
			amba.R.RESP	  = AXI4_RESP_L_OKAY;
			amba.R.DATA   = 0;
            o_addr_rc     = 0;
        end

        // wait addr
        rc_state_wait_addr: begin
            amba.AR.READY = 1;
            amba.R.VALID  = 0;
            amba.R.RESP   = AXI4_RESP_L_OKAY;
            amba.R.DATA   = 0;
            o_addr_rc     = 0;
        end

        // exec
        rc_state_exec: begin
            amba.AR.READY = 0;
            amba.R.VALID  = 1;
            o_addr_rc     = read_ARADDR;

            if(!w_is_busy_rc && read_ARADDR[31:8] == 0) begin
                amba.R.RESP = AXI4_RESP_L_OKAY;
                amba.R.DATA = i_data_rc;
            end else begin
                amba.R.RESP = AXI4_RESP_L_SLVERR;
                amba.R.DATA = 0;
            end
        end
    endcase
end

endmodule