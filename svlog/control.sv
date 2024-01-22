/**
 * control
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module control (
	input logic ACLK,
	input logic ARSTn,

	input logic i_start,
	input logic i_ip,
	
	output logic o_is_busy,
	output logic o_op,
	output logic o_en_ctrl_write,
	output logic o_rst_start
);

typedef enum logic [1:0]
{
	wait_start_bit,
	execute,
	wr_register
} STATE_E;

STATE_E STATE;

// assign
assign o_op = i_ip;

// always ff
always_ff @(posedge ACLK) begin
	if(!ARSTn) begin
        o_is_busy  <= 0;
		o_en_ctrl_write <= 0;
		o_rst_start <= 0;
        STATE <= wait_start_bit;
	end 
	else begin
		case(STATE)
			// wait start bit
			wait_start_bit: begin
				o_is_busy <= 0; // AMBA can write in rb
				o_en_ctrl_write <= 0;
				o_rst_start <= 0;
				if(i_start) begin
 					o_is_busy <= 1; // AMBA cannot write in rb
					STATE <= execute;
				end
			end

			// exec
			execute: begin
				o_is_busy <= 1; // AMBA cannot write in rb
				o_en_ctrl_write <= 1;
				o_rst_start <= 0;
				STATE <= wr_register;
			end

			// wr_reg
			wr_register: begin
				o_is_busy <= 1; // AMBA cannot write in rb
				o_en_ctrl_write <= 0;
				o_rst_start <= 1;
				STATE <= wait_start_bit;
			end
		endcase 
	end
end
endmodule