`timescale 1ns/1ns

module FDRCell(
	input CK,
	input [3:0] D,
	input nCL,
	output reg [3:0] Q = 4'd0
);

	always @(posedge CK or negedge nCL)
	begin
		if (!nCL)
			Q <= #1 4'd0;
		else
			Q <= #1 D;
	end

endmodule
