`timescale 1ns/1ns

module C43(
	input CK,
	input [3:0] D,
	input nL, EN, CI, nCL,
	output reg [3:0] Q = 4'd0,
	output CO
);

	always @(posedge CK or negedge nCL)
	begin
		if (!nCL)
		begin
			Q <= 4'd0;		// Clear
		end
		else
		begin
			if (!nL)
				Q <= D;			// Load
			else if (EN & CI)
				#1 Q <= Q + 1'b1;	// Count
			else
				Q <= Q;
		end
	end
	
	assign #3 CO = &{Q[3:0], CI};

endmodule
