`timescale 1ns/1ns

module FDPCell(
	input CK,
	input D,
	input S, R,
	output reg Q = 1'b0,
	output nQ
);

	always @(posedge CK or negedge S or negedge R)
	begin
		if (!S)
			Q <= 1'b1;
		else if (!R)
			Q <= 1'b0;
		else
			Q <= #1 D;
	end
	
	assign nQ = ~Q;

endmodule
