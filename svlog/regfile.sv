module regfile (
	input  logic ACLK,  
	input  logic ARSTn,
	input  logic [31:0] addr_in,
	input  logic [31:0] data_in,
	input  logic rw, // r: 0, w: 1
	output  logic [31:0] data_out,
	output logic [31:0] r0, 
	output logic [31:0] r1, 
	output logic [31:0] r2
);

logic[31:0] register[3];

always_ff @(posedge ACLK) begin
	if(!ARSTn) begin
		foreach(register[i])
			register[i] <= 0;
	end else begin
		// write
		if(rw == 1) begin
			if(addr_in == 0) register[0] = data_in;
			if(addr_in == 1) register[1] = data_in;
			if(addr_in == 2) register[2] = data_in;
		end

		// read
		if(rw == 0) begin
			if(addr_in == 0) data_out = register[0];
			if(addr_in == 1) data_out = register[1];
			if(addr_in == 2) data_out = register[2];
		end
	end
end

always_comb begin
	r0 = register[0];
	r1 = register[1];
	r2 = register[2];
end

endmodule