`timescale 1ns/1ns

// 16K palette RAM (2x 100ns 8192*8bit RAM)

module palram(
	input [12:0] ADDR,
	inout [15:0] DATA,
	input nWE
);

	//palram_l PRAML(ADDR, PC[7:0], 1'b0, 1'b0, nPALWE);
	//palram_u PRAMU(ADDR, PC[15:8], 1'b0, 1'b0, nPALWE);
	
	wire [15:0] DATA_IN;
	wire [15:0] DATA_OUT;

	assign DATA = (~nWE) ? 16'bzzzzzzzzzzzzzzzz : DATA_OUT;
	assign DATA_IN = DATA;
	
	palram_core RAM(
		nWE,
		~nWE,
		ADDR,
		DATA_IN,
		DATA_OUT
	);

endmodule
