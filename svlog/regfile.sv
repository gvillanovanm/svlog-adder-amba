/**
 * amba_axi4_lite
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module regfile (
	input logic ACLK,  
	input logic ARSTn,

	// amba write channel
	input logic [31:0] i_addr_wc,
	input logic [31:0] i_data_wc,

	// amba read channel
	input logic [31:0] i_addr_rc,
	output logic [31:0] o_data_rc,

	// amba ctrl
	input logic i_en_amba_write,
	input logic i_rst_start,

	// datapath
	input  logic i_enable_ctrl_write,
	output logic o_start,
	output logic o_op,
	input  logic [31:0] i_busr,
	output logic [31:0] o_r0, 
	output logic [31:0] o_r1,
	output logic [3:0] o_leds	
);

logic[31:0] register[5];

always_ff @(posedge ACLK) begin
	if(!ARSTn) begin
		foreach(register[i])
			register[i] <= 0;
	end else begin
		// write from amba
		if(i_en_amba_write) begin
			// it is word addressable, not byte.
			case (i_addr_wc[7:2])
				6'h0: register[0] <= i_data_wc; // r0 	0000_00?? 00-03
				6'h1: register[1] <= i_data_wc; // r1 	0000_01?? 04...
				6'h2: register[2] <= i_data_wc; // r2 	0000_10?? 08 
				6'h3: register[3] <= i_data_wc; // ctrl 0000_11?? 0C
				6'h4: register[4] <= i_data_wc; // leds 0001_00?? 10
			endcase
		end

		// write from ctrl
		if(i_enable_ctrl_write) begin
			register[2] <= i_busr;
		end

		// reset start bit
		if(i_rst_start) begin
			register[3][0] <= 0;
		end
	end
end

always_comb begin
	case (i_addr_rc[7:2])
		6'h0: o_data_rc = register[0];
		6'h1: o_data_rc = register[1];
		6'h2: o_data_rc = register[2];
		6'h3: o_data_rc = register[3];
		6'h4: o_data_rc = register[4];
	endcase

	// lsb
	o_start = register[3][0];
	o_op = register[3][1];
	o_r0 = register[0];
	o_r1 = register[1];
	o_leds = register[4][3:0];
end

endmodule