module snes_mapper(
	input [23:0] addr,
	output [20:0] rom_addr,
	output is_rom,
	output [16:0] ram_addr,
	output is_ram,
	output [13:0] mmio_addr, // Could be trimmed down to [9:0]
	output is_mmio
);


/* ROM (max. 2 MB) at:
      Bank 0x00-0x3f, Offset 8000-ffff
      Bank 0x80-0xbf, Offset 8000-ffff
      Bank 0x40-0x5f, Offset 0000-ffff
		Bank 0xc0-0xdf, Offset 0000-ffff

   (according to higan)
*/
assign is_rom = (!addr[22] & addr[15]) | addr[22];

/* ROM addresses map to physical RAM 1 as follows:
		Bank 0x00-0x3f: address 00aa bbbb 1xxx xxxx xxxx xxxx mapped to:
			000a abbb bxxx xxxx xxxx xxxx
		Bank 0x80-0xbf: address 10aa bbbb 1xxx xxxx xxxx xxxx mapped to:
			000a abbb bxxx xxxx xxxx xxxx
		Bank 0x40-0x5f: address 010a bbbb xxxx xxxx xxxx xxxx mapped to:
			000a bbbb xxxx xxxx xxxx xxxx
		Bank 0xc0-0xdf: address 110a bbbb xxxx xxxx xxxx xxxx mapped to:
			000a bbbb xxxx xxxx xxxx xxxx
*/
wire [23:0] ROM_MASK = 24'hffffff;
assign rom_addr = (~|addr[23:22] | addr[23:22] == 2'b10)
				? /* Banks 0x00-0x3f and 0x80-0xbf, Offsets 8000-ffff */
				  ({3'b000, addr[21:16], addr[14:0]} & ROM_MASK)
				: /* Bank 0x40-0x5f and 0xc0-0xdf, Offset 0000-ffff */
				  ({3'b000, addr[20:0]} & ROM_MASK);

/* Gamepak RAM (max. 128 kB):
   higan maps the gamepak RAM at:
       Bank 0x00-0x3f, Offset 6000-7fff
		 Bank 0x80-0xbf, Offset 6000-7fff
		 Bank 0x70-0x71, Offset 0000-ffff
		 Bank 0xf0-0xf1, Offset 0000-ffff
*/
assign is_ram = (!addr[22] & addr[15:13] == 3'b011) | (addr[22:17] == 6'b111000);

/* Gamepak RAM addresses map to physical RAM 2 as follows:
		Bank 0x00-0x3f: address 00aa bbbb 011c xxxx xxxx xxxx mapped to:
			b bbbc xxxx xxxx xxxx
		Bank 0x80-0xbf: address 10aa bbbb 011c xxxx xxxx xxxx mapped to:
			b bbbc xxxx xxxx xxxx
		Bank 0x70-0x71: address 0111 000a xxxx xxxx xxxx xxxx mapped to:
			a xxxx xxxx xxxx xxxx
		Bank 0xf0-0xf1: address 1111 000a xxxx xxxx xxxx xxxx mapped to:
			a xxxx xxxx xxxx xxxx
*/
assign ram_addr = !addr[22]
					? ({addr[19:16], addr[12:0]})
					: (addr[16:0]);

/* GSU MMIO interface is at:
       Bank 0x00-0x3f, Offset 3000-32ff
       Bank 0x80-0xbf, Offset 3000-32ff */
assign is_mmio = (!addr[22] & (addr[15:10] == 6'b001100) & (!addr[9] | !addr[8]));

assign mmio_addr = addr[13:0];

endmodule