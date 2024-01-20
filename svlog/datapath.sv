/**
 * datapath
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module datapath (
	input logic [31:0] i_busa,
	input logic [31:0] i_busb,
  input logic i_op,

	output logic [31:0] o_busr
);

  always_comb begin
    o_busr = (i_op) ? (i_busa + i_busb) : (i_busa - i_busb);
  end
endmodule