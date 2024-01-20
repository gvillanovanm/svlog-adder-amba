/**
 * amba_axi4_lite
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */
module datapath (
	input logic [31:0] i_busa,
	input logic [31:0] i_busb,
  input logic op,

	output logic [31:0] o_busr
);

  always_comb begin
    if(op)
      busR = busA + busB;
    else
      busR = busA - busB;
  end
endmodule