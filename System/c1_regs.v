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

module c1_regs(
	input nICOMZONE,
	input RW,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	output nSDW
);

	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	
	// Z80 command read
	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
	
	// Z80 reply write
	always @(posedge nSDZ80W)	// No edge at all ?
	begin
		SDD_LATCH_REP <= SDD;
	end
	
	// REG_SOUND read
	assign M68K_DATA = (RW & ~nICOMZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	
	// REG_SOUND write
	assign nSDW = (RW | nICOMZONE);		// Tells Z80 that 68k sent a command
	
	// REG_SOUND write
	always @(negedge nICOMZONE or negedge nSDZ80CLR)		// Which one has priority ?
	begin
		if (!nSDZ80CLR)
		begin
			SDD_LATCH_CMD <= 8'b00000000;
		end
		else
		begin
			if (!RW)
				SDD_LATCH_CMD <= M68K_DATA;
		end
	end
	
endmodule
