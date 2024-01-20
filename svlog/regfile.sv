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

	// datapath
	input  logic i_enable_ctrl_write,
	output logic o_start,
	input  logic [31:0] i_busr,
	output logic [31:0] o_r0, 
	output logic [31:0] o_r1
);

logic[31:0] register[4];

always_ff @(posedge ACLK) begin
	if(!ARSTn) begin
		foreach(register[i])
			register[i] <= 0;
	end else begin
		// write from amba
		if(i_en_amba_write) begin
			if(i_addr_wc == 0) register[0] <= i_data_wc; // r0
			if(i_addr_wc == 1) register[1] <= i_data_wc; // r1
			if(i_addr_wc == 2) register[2] <= i_data_wc; // r2
			if(i_addr_wc == 3) register[3] <= i_data_wc; // ctrl
		end

		// write from ctrl
		if(i_enable_ctrl_write) begin
			register[2] <= i_busr;
		end
	end
end

always_comb begin
	case (i_addr_rc[1:0])
		0: o_data_rc = register[0];
		1: o_data_rc = register[1];
		2: o_data_rc = register[2];
		3: o_data_rc = register[3];
	endcase

	// lsb
	o_start = register[3][0];
	o_r0 = register[0];
	o_r1 = register[1];
end

endmodule