`timescale 1ns/1ns

module FD4(
	input CK,
	input D,
	input PR, CL,
	output reg Q = 1'b0,
	output nQ
);

	always @(negedge CK or negedge PR or negedge CL)	// negedge CK
	begin
		if (~PR)
			Q <= #1 1'b1;
		else if (~CL)
			Q <= #1 1'b0;
		else
			Q <= #1 D;
	end
	
	assign nQ = ~Q;

endmodule
