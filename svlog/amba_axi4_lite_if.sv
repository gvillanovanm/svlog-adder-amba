/**
 * amba_axi4_lite_if
 *
 * @version: 0.1
 * @author : Gabriel Villanova N. M.
 */

// address write channel
interface aw #(
	int unsigned SIZE_ADDR = 32
);

	logic VALID;
	logic READY;
	logic [SIZE_ADDR-1:0] ADDR;
	logic [2:0] PROT;

endinterface

// data write channel
interface w #(
	int unsigned SIZE_WORD = 32,
	int unsigned SIZE_STRB = SIZE_WORD/8
);
	import amba_axi4_lite_types_pkg::*;
	logic VALID;
	logic READY;
	logic [SIZE_WORD-1:0] DATA;
	logic [SIZE_STRB-1:0] STRB;
endinterface

// reponse channel
interface b();
	import amba_axi4_lite_types_pkg::*;

	logic VALID;
	logic READY;
	axi4_resp_el RESP;
endinterface

// address read channel
interface ar #(
	int unsigned SIZE_ADDR = 32
);
	import amba_axi4_lite_types_pkg::*;

	logic VALID;
	logic READY;
	logic [SIZE_ADDR-1:0] ADDR;
	logic [2:0] PROT;
endinterface

// read data channel
interface r #(
	int unsigned SIZE_WORD = 32
);
	import amba_axi4_lite_types_pkg::*;

	logic VALID;
	logic READY;
	logic [SIZE_WORD-1:0] DATA;
	axi4_resp_el RESP;
endinterface

// main interface
interface amba_axi4_lite_if# (
	int unsigned SIZE_WORD=32,
	int unsigned SIZE_STRB=SIZE_WORD/8,
	int unsigned SIZE_ADDR=SIZE_WORD
	)(
		input logic ACLK,
		input logic ARSTn
	);

	import amba_axi4_lite_types_pkg::*;
	
	// write channel
	aw #(SIZE_ADDR)            AW();
	w  #(SIZE_WORD, SIZE_STRB)  W();
	b                           B();

	// read channel
	ar #(SIZE_ADDR)            AR();
	r  #(SIZE_WORD)             R();
endinterface
