`timescale 1ns/1ns

// 120ns 2048*8bit RAM

module z80ram(
	input [10:0] ADDR,
	inout [7:0] DATA,
	input nCE,
	input nOE,
	input nWE
);

	wire [7:0] DATA_IN;
	wire [7:0] DATA_OUT;

	assign DATA = (nOE | nCE) ? 8'bzzzzzzzz : DATA_OUT;
	assign DATA_IN = DATA;
	
	z80ram_core RAM(
		nWE & nOE & nCE,
		~|{nWE, nCE},
		ADDR,
		DATA_IN,
		DATA_OUT
	);

endmodule
