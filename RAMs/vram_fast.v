`timescale 1ns/1ns

// 35ns 2048*8bit RAM

module vram_fast(
	input [10:0] ADDR,
	inout [15:0] DATA,
	input nOE,
	input nWE
);

	wire [15:0] DATA_IN;
	wire [15:0] DATA_OUT;

	assign DATA = nOE ? 16'bzzzzzzzzzzzzzzzz : DATA_OUT;
	assign DATA_IN = DATA;
	
	fvram_core RAM(
		nWE & nOE,
		~nWE,
		ADDR,
		DATA_IN,
		DATA_OUT
	);
	
endmodule
