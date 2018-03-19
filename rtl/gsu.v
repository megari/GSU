module GSU(
	input clkin,
	input [23:0] snes_addr,
	input [7:0] snes_data,
	input WR,
	input RD,
	input RESET,
	inout IRQ,
	output [16:0] sram_addr,
	inout [7:0] sram_data,
	output SRAM_OE,
	output SRAM_WE,
	output [20:0] rom_addr,
	inout [7:0] rom_data,
	output ROM_CE
);

/*
altpll_gsu pll(
	.c0(clk)
);
*/

gsu_cache cache(
	.douta(cache_outa),
	.dina(cache_in),
	.addra(cache_addra),
	.wea(cache_we),
	.doutb(cache_outb),
	.addrb(cache_addrb),
	.clk(clkin)
);

// Mapper for GSU-generated addresses.
gsu_mapper g_mapper(
	.addr(gsu_addr),
	.rom_addr(gsu_rom_addr),
	.is_rom(gsu_is_rom),
	.sram_addr(gsu_sram_addr),
	.is_ram(gsu_is_ram)
);

// Mapper for SNES-generated addresses.
snes_mapper s_mapper(
	.addr(snes_addr),
	.rom_addr(snes_rom_addr),
	.is_rom(snes_is_rom),
	.sram_addr(snes_sram_addr),
	.is_sram(snes_is_sram),
	.is_mmio(snes_is_mmio)
);

reg [15:0] regs [15:0]; // General purpose registers R0~R15
parameter
  RAP = 4'd14,
  PC  = 4'd15
;

// Status/flag register flags
reg [15:0] sfr;
wire z = sfr[1];    // Zero
wire cy = sfr[2];   // Carry
wire s = sfr[3];    // Sign
wire ov = sfr[4];   // Overflow
wire g = sfr[5];    // Go
wire r = sfr[6];    // Reading ROM using R14
wire alt1 = sfr[8]; // Mode flag for next insn
wire alt2 = sfr[9]; // Mode flag for next insn
wire il = sfr[10];  // Immediate lower
wire ih = sfr[11];  // Immediate higher
wire b = sfr[12];   // Instruction executed with WITH
wire irq = sfr[15]; // Interrupt
parameter
  Z    = 4'd1,
  CY   = 4'd2,
  S    = 4'd3,
  OV   = 4'd4,
  G    = 4'd5,
  R    = 4'd6,
  ALT1 = 4'd8,
  ALT2 = 4'd9,
  IL   = 4'd10,
  IH   = 4'd11,
  B    = 4'd12,
  IRQ_ = 4'd15
;

reg [7:0] pbr;   // Program bank register
reg [7:0] rombr; // Game Pak ROM bank register
reg rambr;       // Game Pak RAM bank register
reg [15:0] cbr;  // Cache base register. [3:0] are always 0.
                 // TODO: why not make the register only 12 bits wide?
reg [7:0] scbr;  // Screen base register
reg [5:0] scmr;  // Screen mode register
reg [7:0] colr;  // Color register
reg [4:0] por;   // Plot option register
reg bramr;       // Back-up RAM register
reg [7:0] vcr;   // Version code register
reg [7:0] cfgr;  // Config register
reg clsr;        // Clock select register

reg [3:0] src_reg;
reg [3:0] dst_reg;

/* ROM/RAM bus access flags */
assign ron = scmr[4];
assign ran = scmr[3];

/* Cache RAM and cache flags */
reg [31:0] cache_flags;
initial cache_flags = 32'h00000000;


endmodule