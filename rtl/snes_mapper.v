module snes_mapper(
	input [23:0] addr,
	output [20:0] rom_addr,
	output is_rom,
	output [16:0] sram_addr,
	output is_sram,
	output is_mmio
);

/* GSU MMIO interface is at:
       Bank 0x00-0x3f, Offset 3000-32ff
       Bank 0x80-0xbf, Offset 3000-32ff */
assign is_mmio = (!addr[22] & (addr[15:10] == 6'b001100) & (!addr[9] | !addr[8]));

endmodule