// NeoGeo logic definition (simulation only)
// Copyright (C) 2018 Sean Gonsalves
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

`timescale 1ns/1ns

module fast_cycle(
	input CLK_24M,
	input LSPC_12M,
	input LSPC_6M,
	input LSPC_3M,
	input LSPC_1_5M,
	input RESETP,
	input nVRAM_WRITE_REQ,
	input [15:0] VRAM_ADDR,
	input [15:0] VRAM_WRITE,
	input REG_VRAMADDR_MSB,
	input FLIP, nFLIP,
	input [8:0] PIXELC,
	input [8:0] RASTERC,
	input P50_CO,
	output nCPU_WR_HIGH,
	output [3:0] HSHRINK,
	output [15:0] PIPE_C,
	output [15:0] VRAM_HIGH_READ,
	output [7:0] ACTIVE_RD,
	output R91_Q,
	output R91_nQ,
	input T140_Q,
	input T58A_OUT,
	input T73A_OUT,
	input U129A_Q,
	input T125A_OUT,
	output CLK_ACTIVE_RD,
	output ACTIVE_RD_PRE8,
	output [8:0] SPR_Y,
	output [7:0] YSHRINK,
	output SPR_SIZE0,
	output SPR_SIZE5,
	output O159_QB
);

	wire [10:0] C;
	wire [15:0] F_IN;
	wire [15:0] F_OUT;
	wire [8:0] PARSE_Y;
	wire [5:0] PARSE_SIZE;
	wire [3:0] J102_Q;
	wire [3:0] E175_Q;
	wire [7:0] ACTIVE_RD_PRE;
	wire [3:0] J127_Q;
	wire [8:0] PARSE_INDEX;
	wire [3:0] T102_Q;
	wire [7:0] PARSE_LOOKAHEAD;
	wire [8:0] PARSE_ADD_Y;
	wire [5:0] PARSE_ADD_SIZE;
	wire [7:0] ACTIVE_RD_ADDR;	// Bit 7 unused
	wire [15:0] PIPE_A;
	wire [15:0] PIPE_B;
	wire [3:0] O141_Q;
	wire [3:0] G152_Q;
	wire [3:0] G152_Q_DELAYED;
	wire [3:0] J87_Q;
	wire [3:0] J87_Q_DELAYED;
	wire [7:0] ACTIVE_WR_ADDR;	// Bit 7 unused
	wire [10:0] A_TOP;
	wire [10:0] B_TOP;
	wire [10:0] C_TOP;
	wire [10:0] D_TOP;
	wire [10:0] A_BOT;
	wire [10:0] B_BOT;
	wire [10:0] C_BOT;
	wire [10:0] D_BOT;
	
	// CPU read
	// L251 L269 L233 K249
	FDS16bit L251(~CLK_CPU_READ_HIGH, F_OUT, VRAM_HIGH_READ);

	// Y parsing read
	// N214 M214 M178 L190
	FDS16bit N214(O109A_OUT, F_OUT, {PARSE_Y, PARSE_CHAIN, PARSE_SIZE});

	// Y Rendering read
	FDSCell M250(N98_QC, F_OUT[15:12], SPR_Y[8:5]);
	FDSCell M269(N98_QC, F_OUT[11:8], SPR_Y[4:1]);
	FDSCell M233(N98_QC, {F_OUT[7:5], F_OUT[0]}, {SPR_Y[0], SPR_CHAIN, SPR_SIZE5, SPR_SIZE0});

	// Active list read
	FDSCell J117(H125A_OUT, F_OUT[7:4], ACTIVE_RD_PRE[7:4]);
	FDSCell J178(H125A_OUT, F_OUT[3:0], ACTIVE_RD_PRE[3:0]);
	// Next step
	FDSCell I32(CLK_ACTIVE_RD, ACTIVE_RD_PRE[7:4], ACTIVE_RD[7:4]);
	FDSCell H165(CLK_ACTIVE_RD, ACTIVE_RD_PRE[3:0], ACTIVE_RD[3:0]);
	
	// Shrink read
	FDSCell O141(N98_QB, F_OUT[11:8], O141_Q);
	FDSCell O123(N98_QB, F_OUT[7:4], YSHRINK[7:4]);
	FDSCell K178(N98_QB, F_OUT[3:0], YSHRINK[3:0]);
	
	// Data output
	// O171B O171A O173B O173A
	// B178B B173B B171B C180B
	// C146B C144B C142B C149B
	// E207B E207A E209B E209A
	assign F_IN = CLK_CPU_READ_HIGH ? VRAM_WRITE : {7'b0000000, J194_Q, J102_Q, E175_Q};
	
	//assign F = CWE ? 16'bzzzzzzzzzzzzzzzz : F_OUT_MUX;
	
	
	assign O112B_OUT = O109A_OUT;		// 2x inverter
	
	FDSCell G152(PARSE_INDEX_INC_CLK, PARSE_INDEX[3:0], G152_Q);
	assign #5 G152_Q_DELAYED = G152_Q;	// 4x BD3
	FDSCell J87(PARSE_INDEX_INC_CLK, PARSE_INDEX[7:4], J87_Q);
	assign #5 J87_Q_DELAYED = J87_Q;		// 4x BD3
	
	FDRCell E175(O109A_OUT, G152_Q_DELAYED, nPARSING_DONE, E175_Q);
	FDRCell J102(O109A_OUT, J87_Q_DELAYED, nPARSING_DONE, J102_Q);
	FDM J231(PARSE_INDEX_INC_CLK, PARSE_INDEX[8], J231_Q, );
	BD3 J235A(J231_Q, J231_Q_DELAYED);
	FDPCell J194(O112B_OUT, J231_Q_DELAYED, 1'b1, nPARSING_DONE, J194_Q, );
	
	
	// CWE output
	assign O107A_OUT = VRAM_HIGH_ADDR_SB & nCPU_WR_HIGH;	// OK
	assign T146A_OUT = ~|{T129A_nQ, T148_Q};
	assign CWE = O107A_OUT | T146A_OUT;		// OK
	// O103A
	assign VRAM_HIGH_ADDR_SB = ~&{WR_ACTIVE, O98_Q};
	BD3 O84A(N98_QD, N98_QD_DELAYED);
	FDPCell O98(T125A_OUT, N98_QD_DELAYED, 1'b1, RESETP, O98_Q, CLK_CPU_READ_HIGH);
	FDPCell N93(N98_QD, F58A_OUT, CLK_CPU_READ_HIGH, 1'b1, nCPU_WR_HIGH, );
	
	assign F58A_OUT = ~REG_VRAMADDR_MSB | nVRAM_WRITE_REQ;
	FDM I148(H125A_OUT, F_OUT[8], ACTIVE_RD_PRE8, );
	assign H125A_OUT = CLK_ACTIVE_RD;
	
	
	// Parsing end detection
	assign I145_OUT = ~&{PARSE_INDEX[6:1], PARSE_INDEX[8]};
	assign R113A_OUT = I145_OUT & nPARSING_DONE;
	FDPCell R109(O109A_OUT, R113A_OUT, nNEW_LINE, 1'b1, nPARSING_DONE, );
	
	// Active list full detection
	assign S109B_OUT = S111_Q & nACTIVE_FULL;
	FDPCell S111(O109A_OUT, S109B_OUT, nNEW_LINE, 1'b1, S111_Q, S111_nQ);
	assign S109A_OUT = S111_Q & nNEW_LINE;
	
	// Write to fast VRAM enable
	assign T95A_OUT = IS_ACTIVE & T102_Q[0];
	assign R107A_OUT = nPARSING_DONE | S111_nQ;
	FDPCell R103(O109A_OUT, T95A_OUT, R107A_OUT, S109A_OUT, WR_ACTIVE, );
	
	
	FD2 T129A(CLK_24M, T126B_OUT, , T129A_nQ);
	assign T126B_OUT = ~&{T66_Q, T140_Q};
	FDM T66(LSPC_12M, T58A_OUT, T66_Q, );
	
	assign P49A_OUT = PIXELC[8];
	FDM S67(LSPC_3M, P49A_OUT, , S67_nQ);
	assign S70B_OUT = ~&{S67_nQ, P49A_OUT};
	BD3 S71A(S70B_OUT, S71A_OUT);
	FDM S74(LSPC_6M, S71A_OUT, S74_Q, );
	// S107A Used for test mode
	assign nNEW_LINE = 1'b1 & S74_Q;
	
	FDM T148(CLK_24M, T128B_OUT, T148_Q, );
	assign T128B_OUT = ~&{T73A_OUT, U129A_Q};
	
	// T181A
	assign IS_ACTIVE = PARSE_CHAIN ? T90A_OUT : M176A_OUT;
	
	assign M176A_OUT = PARSE_MATCH | PARSE_SIZE[5];
	BD3 S105(VRAM_HIGH_ADDR_SB, S105_OUT);
	FDRCell T102(O109A_OUT, {1'b0, T102_Q[1], T102_Q[0], S105_OUT}, nNEW_LINE, T102_Q);
	assign T94_OUT = ~&{T102_Q[1:0], O102B_OUT};
	assign T92_OUT = ~&{~T102_Q[2], ~T102_Q[1], T102_Q[0], VRAM_HIGH_ADDR_SB};
	assign T90A_OUT = ~&{T94_OUT, T92_OUT};
	
	
	C43 H198(O110B_OUT, 4'b0000, 1'b1, 1'b1, 1'b1, nNEW_LINE, ACTIVE_WR_ADDR[3:0], H198_CO);
	// Used for test mode
	assign H222A_OUT = H198_CO | 1'b0;
	C43 I189(O110B_OUT, 4'b0000, 1'b1, 1'b1, H222A_OUT, nNEW_LINE, ACTIVE_WR_ADDR[7:4], );
	assign nACTIVE_FULL = ~&{ACTIVE_WR_ADDR[6:5]};	// J100B
	assign O110B_OUT = O109A_OUT | VRAM_HIGH_ADDR_SB;
	
	
	FS3 N98(T125A_OUT, 4'b0000, R91_nQ, RESETP, {N98_QD, N98_QC, N98_QB, N98_QA});
	assign CLK_ACTIVE_RD = ~K131B_OUT;
	
	FDM R91(LSPC_12M, LSPC_1_5M, R91_Q, R91_nQ);
	
	// Address mux
	// I213 I218 G169A G164 G182A G194A G200 G205A I175A I182A
	// J62 J72A I104 I109A J205A J200 J49 J54A H28A H34 I13 I18A
	assign A_TOP = {N98_QC, J36_OUT, ACTIVE_RD_PRE8, ACTIVE_RD_PRE};
	assign B_TOP = {3'b110, H293B_OUT, ACTIVE_RD_ADDR[6:0]};
	assign C_TOP = {3'b110, H293B_OUT, ACTIVE_RD_ADDR[6:0]};
	assign D_TOP = {N98_QC, J36_OUT, ACTIVE_RD_PRE8, ACTIVE_RD_PRE};
	
	assign A_BOT = {3'b110, I237A_OUT, ACTIVE_WR_ADDR[6:0]};
	assign B_BOT = VRAM_ADDR[10:0];
	assign C_BOT = VRAM_ADDR[10:0];
	assign D_BOT = {2'b01, PARSE_INDEX};
	
	// L110B_OUT  A
	// ~VRAM_HIGH_ADDR_SB B
	// M95B_OUT   C
	// ABC:
	assign C = 	M95B_OUT ?
						~VRAM_HIGH_ADDR_SB ?
							L110B_OUT ? C_TOP : A_TOP		// 111 - 110
						:
							L110B_OUT ? B_TOP : D_TOP		// 101 - 100
					:
						~VRAM_HIGH_ADDR_SB ?
							L110B_OUT ? C_BOT : A_BOT		// 011 - 010
						:
							L110B_OUT ? B_BOT : D_BOT;		// 001 - 000
/*
	assign C = 	L110B_OUT ?
						~VRAM_HIGH_ADDR_SB ?
							M95B_OUT ? C_TOP : A_TOP		// 111 - 110
						:
							M95B_OUT ? B_TOP : D_TOP		// 101 - 100
					:
						~VRAM_HIGH_ADDR_SB ?
							M95B_OUT ? C_BOT : A_BOT		// 011 - 010
						:
							M95B_OUT ? B_BOT : D_BOT;		// 001 - 000
							*/
	
	assign K131B_OUT = ~N98_QA;
	assign M95B_OUT = ~|{N98_QD, O98_Q};
	assign L110B_OUT = ~|{L110A_OUT, O98_Q};
	assign L110A_OUT = ~|{K131B_OUT, N98_QD};
	assign I237A_OUT = FLIP;
	assign K260B_OUT = FLIP;
	assign H293B_OUT = nFLIP;
	assign J36_OUT = N98_QB ^ N98_QC;
	
	
	// Active list read counter
	assign #1 P39A_OUT = ~PIXELC[8];
	assign nRELOAD_RD_ACTIVE = ~&{PIXELC[6], P50_CO, P39A_OUT};	// O55A
	C43 I151(CLK_ACTIVE_RD, 4'b0000, nRELOAD_RD_ACTIVE, 1'b1, 1'b1, 1'b1, ACTIVE_RD_ADDR[3:0], I151_CO);
	assign J176A_OUT = I151_CO | 1'b0;	// Used for test mode
	C43 J151(CLK_ACTIVE_RD, 4'b0000, nRELOAD_RD_ACTIVE, 1'b1, J176A_OUT, 1'b1, ACTIVE_RD_ADDR[7:4], );
	
	
	// Parsing counter
	assign PARSE_INDEX_INC_CLK = O102B_OUT | O109A_OUT;	// O105B
	C43 H127(PARSE_INDEX_INC_CLK, 4'b0000, 1'b1, 1'b1, 1'b1, nNEW_LINE, PARSE_INDEX[3:0], H127_CO);
	assign H125B_OUT = H127_CO | 1'b0;	// Used for test mode
	C43 I121(PARSE_INDEX_INC_CLK, 4'b0000, 1'b1, H125B_OUT, 1'b1, nNEW_LINE, PARSE_INDEX[7:4], I121_CO);
	C43 J127(PARSE_INDEX_INC_CLK, 4'b0000, 1'b1, H125B_OUT, I121_CO, nNEW_LINE, J127_Q, );
	assign PARSE_INDEX[8] = J127_Q[0];
	
	assign O109A_OUT = T125A_OUT | CLK_CPU_READ_HIGH;
	assign O102B_OUT = WR_ACTIVE & O98_Q;
	
	
	// Y parse matching
	// L200 O200
	assign PARSE_LOOKAHEAD = 8'd2 + {RASTERC[7:1], K260B_OUT};
	// M190 N190
	assign PARSE_ADD_Y = PARSE_LOOKAHEAD + PARSE_Y[7:0];
	assign N186_OUT = ~^{PARSE_ADD_Y[8], PARSE_Y[8]};
	// K195 M151
	assign PARSE_ADD_SIZE = {N186_OUT, ~PARSE_ADD_Y[7:4]} + PARSE_SIZE[4:0];
	assign PARSE_MATCH = PARSE_ADD_SIZE[5];
	
	
	// Pipe for x position and h-shrink
	// O159 P131 O87 N131
	FDS16bit O159(N98_QD, {2'b00, SPR_CHAIN, O141_Q, F_OUT[15:7]}, PIPE_A);
	assign O159_QB = PIPE_A[13];
	// P165 P121 P87 N121
	FDS16bit P165(N98_QD, PIPE_A, PIPE_B);
	// P155 P141 P104 N141
	FDS16bit P155(N98_QD, PIPE_B, PIPE_C);
	assign HSHRINK = PIPE_C[12:9];
	
	//vram_fast FVRAM(C, F, 1'b0, CWE);
	//vram_fast_u VRAMUU(C, F[15:8], 1'b0, 1'b0, CWE);
	//vram_fast_l VRAMUL(C, F[7:0], 1'b0, 1'b0, CWE);
	
	fvram_core RAM(
		CWE,
		~CWE,
		C,
		F_IN,
		F_OUT
	);

endmodule
