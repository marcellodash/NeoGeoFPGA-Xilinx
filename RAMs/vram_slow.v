`timescale 1ns/1ns

// 120ns 32768*8bit RAM

module vram_slow(
	input [14:0] ADDR,
	inout [15:0] DATA,
	input nOE,
	input nWE
);

	wire [15:0] DATA_IN;
	wire [15:0] DATA_OUT;

	assign DATA = nOE ? 16'bzzzzzzzzzzzzzzzz : DATA_OUT;
	assign DATA_IN = DATA;
	
	svram_core RAM(
		nWE & nOE,
		~nWE,
		ADDR,
		DATA_IN,
		DATA_OUT
	);

endmodule
