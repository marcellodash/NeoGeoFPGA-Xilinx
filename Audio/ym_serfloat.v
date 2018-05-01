`timescale 1ns/1ns

module ym_serfloat(
	input [15:0] DATA_IN,
	input CLK,
	output LEFT,
	output RIGHT
);

	// See US pat. #5021785

	wire [14:9] RANGE;
	wire [2:0] SHIFT;
	wire [9:0] FLOAT_DATA;

	assign SIGN = ~DATA_IN[15];

	// Shift detection
	assign RANGE = DATA_IN[15] ? ~DATA_IN[14:9] : DATA_IN[14:9];
	
	assign SHIFT = (RANGE[14]) ? 0 :
							(RANGE[14:13] == 2'b01) ? 1 :
							(RANGE[14:12] == 3'b001) ? 2 :
							(RANGE[14:11] == 4'b0001) ? 3 :
							(RANGE[14:10] == 5'b00001) ? 4 :
							(RANGE[14:9] == 6'b000001) ? 5 :
							6;
	
	assign FLOAT_DATA = (P0) ? {SIGN, RANGE[14:6]} :
								(P1) ? {SIGN, RANGE[13:5]} :
								(P2) ? {SIGN, RANGE[12:4]} :
								(P3) ? {SIGN, RANGE[11:3]} :
								(P4) ? {SIGN, RANGE[10:2]} :
								(P5) ? {SIGN, RANGE[9:1]} :
								{SIGN, RANGE[8:0]};
	

	// nCS gating - Not sure if it's that simple
	assign nWR = nCS | nWR_RAW;
	assign nRD = nCS | nRD_RAW;
	
	// Timer
	wire [9:0] YMTIMER_TA_LOAD;
	wire [7:0] YMTIMER_TB_LOAD;
	wire [5:0] YMTIMER_CONFIG;
	reg FLAG_A_S, FLAG_B_S;
	
	always @(posedge PHI_M or negedge nRESET)
	begin
		if (!nRESET)
			P1 <= 1'b0;
		else
			P1 <= ~P1;
	end
	
	assign TICK_144 = (CLK_144_DIV == 143) ? 1'b1 : 1'b0;		// 143, not 0. Otherwise timers are goofy
	
	// TICK_144 gen (CLK/144)
	always @(posedge PHI_M)
	begin
		if (!nRESET)
			CLK_144_DIV <= 0;
		else
		begin
			if (CLK_144_DIV < 143)	// / 12 / 12 = / 144
				CLK_144_DIV <= CLK_144_DIV + 1'b1;
			else
				CLK_144_DIV <= 0;
		end
	end
	
	// Test

endmodule
