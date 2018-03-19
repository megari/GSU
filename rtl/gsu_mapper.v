module gsu_mapper(
	input [23:0] addr,
	output [20:0] rom_addr,
	output is_rom,
	output [16:0] sram_addr,
	output is_ram
);

/* ROM (max. 2 MB) at:
      Bank 0x00-0x3f, Offset 0000-7fff (ROM)
      Bank 0x00-0x3f, Offset 8000-ffff (ROM image 1)
      Bank 0x40-0x5f, Offset 0000-ffff (ROM image 2)

   (according to higan)
*/
assign is_rom = ((~|addr[23:22])
					|(!addr[23] & addr[22] & !addr[21]));


/* ROM addresses map to physical RAM 1 as follows:
		Bank 0x00-0x3f: address 00aa bbbb cxxx xxxx xxxx xxxx mapped to:
			000a abbb bxxx xxxx xxxx xxxx
		Bank 0x40-0x5f: address 010a bbbb xxxx xxxx xxxx xxxx mapped to:
			000a bbbb xxxx xxxx xxxx xxxx
*/
assign ROM_MASK = 24'hffffff;
assign rom_addr = (~|addr[23:22])
				? /* Bank 0x00-0x3f, Offsets 0000-7fff, 8000-ffff */
				  ({3'b000, addr[21:16], addr[14:0]} & ROM_MASK)
				: /* Bank 0x40-0x5f, Offset 0000-ffff */
				  ({3'b000, addr[20:0]} & ROM_MASK);

/* Gamepak RAM (max. 128 kB):
   higan maps the gamepak RAM at:
       Bank 0x60-0x7f, Offset 0000-ffff

   The mapping is actually just two banks wide, but it repeats:
       Bank 0x60-0x61,
       Bank 0x62-0x63,
       Bank 0x64-0x65,
       ...
       Bank 0x7c-0x7d,
       Bank 0x7e-0x7f
*/
assign is_ram = (addr[23:21] == 3'b011);

/* Gamepak RAM addresses map to physical RAM 2 as follows:
		Bank 0x60-0x7f: address 011a bbbc xxxx xxxx xxxx xxxx mapped to:
			0000 000c xxxx xxxx xxxx xxxx
*/
assign ram_addr = ({7'b0000000, addr[16:0]});

endmodule