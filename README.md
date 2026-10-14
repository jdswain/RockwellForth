# Rockwell Forth

RSC-FORTH, the FIG-Forth derivative Rockwell shipped in ROM for the R65F11 and
R65F12 microcontrollers, as assembler source that builds for several 65xx
machines. The original ROM images are in `roms/` and the R6501Q build still
reproduces them.

The Forth is two ROMs:

* **Kernel** (4 KB, `$F000`-`$FFFF`): the inner interpreter, the primitive
  words, terminal and disk I/O, and the reset code. It runs on its own with
  minimal functionality, as a headerless system with a tiny monitor.
* **Development ROM** (8 KB, `$C000`-`$DFFF`): the dictionary headers for the
  kernel's words, the outer interpreter and compiler, the disk words and a
  6502 assembler. The kernel finds it at reset by looking for the
  signature `$5A $A5` on a 1 KB boundary.

The development source includes the kernel source, so one assembly produces
both and the two always agree on addresses.

## Source files

All in `src/`.

| File | What it is |
|------|------------|
| `ForthKernel.asm`, `ForthDevelopment.asm` | The main source. One file pair, several target machines, chosen with `-Dmachine=`. |
| `ForthConsole-T20K.asm` | Display, keyboard and serial driver for the Tang Nano 20K target. Included by the kernel for that target only. |
| `ForthKernel-Rockwell.asm`, `ForthDevelopment-Rockwell.asm` | The original disassembly, kept as the reference. |
| `ForthKernel-RC19.asm` | Kernel for the Rockwell R65C19 family. |
| `ForthKernel-L28.asm`, `ForthDevelopment-L28.asm` | The L28 microcontroller version, with its LCD and keyboard. Built by `src/Makefile`. |

## Target machines

| `machine` | Processor | Console | Status |
|-----------|-----------|---------|--------|
| `R6501Q` | R6501Q, stack in page zero | On-chip serial port | Assembles byte-for-byte to the Rockwell ROMs, apart from two deliberate edits (a fix to `0=` and the version string). |
| `65C02` | 65C02, or a 65C816 left in emulation mode | R6501-style serial registers at `$15`-`$17` | Working. Tested on the Tang Nano 20K FPGA board in its Forth memory map. |
| `T20K` | 65C816 in native mode, on the Tang Nano 20K FPGA board | 80x30 text display and serial port; serial or ADB keyboard | Working. See below. |
| `65C816` | 65C816 emulator | Unfinished | Incomplete: the cold start does not set up the machine. Left as it was. |

## Building

The assembler is `as` from the 65Tools repository, expected at
`../65Tools/bin/as`. It writes an ELF file when the output name has no
extension, and always writes a listing (`.lst`) beside the source, which is the
place to look up addresses.

    cd src
    ../../65Tools/bin/as -o ForthDevelopment-T20K -Dmachine='"T20K"' ForthDevelopment.asm

Substitute `R6501Q` or `65C02` for the other targets. To build a kernel on its
own, assemble `ForthKernel.asm` the same way.

The ELF file has two sections, `kernel` and `development`, each with its load
address.

The L28 version has its own build: `make` in `src/`.

### The vector check

The kernel is padded at the front so that the interrupt vectors land at
`$FFFA`. The padding is a constant per machine (`start_offset`), and the build
fails with `vectors are not at $FFFA: adjust start_offset` if a change to the
kernel moves them. Add or subtract the difference; the listing shows where
`NMI` ended up.

## The Tang Nano 20K target

The board is the 65C816 system-on-chip in the Verilog65C816 repository. Its
Makefile builds the Forth and the bitstream that contains it:

    cd ../Verilog65C816/fpga
    make forth          # assemble the ROM image, rom/forth.mem
    make forth-bit      # build the bitstream
    make prog           # load it into the FPGA (lost at power-off)

`make flash` writes it to the board's flash instead, so that it boots at
power-on.

The Forth comes up on the monitor and on the serial port (115200 baud, 8N1)
with

     RSC-FORTH V2.0

and takes input from either the serial port or an ADB keyboard. Lines end with
CR. Words are upper case.

    HEX 1F 2 + .                    21 OK
    : SQ DUP * ; 7 SQ .             49 OK
    VLIST

### Memory map

| Address | Use |
|---------|-----|
| `$0040`-`$005C` | Interpreter registers: `IP`, `W`, `UP`, `N`, the I/O vectors |
| `$005D`-`$00C1` | Data stack, growing down from `$C2` |
| `$00E0`-`$00F9` | Console driver variables |
| `$0100`-`$01FF` | Return stack |
| `$0200`-`$0FFF` | The board's I/O block |
| `$1000`-`$107F` | User variables |
| `$1080`-`$10FF` | Terminal input buffer |
| `$1100`-`$B7F7` | Dictionary |
| `$B7F8`-`$BFFF` | Two disk buffers |
| `$C000`-`$DFFF` | Development ROM |
| `$E000`-`$FFFF` | Console driver and kernel, with about 4 KB free |

The original keeps its user variables in page 3 and starts the dictionary at
`$0400`. Both had to move because that is the board's I/O block. The addresses
are the symbols `USER_BASE`, `DICT_BASE`, `BUF_FIRST` and `BUF_LIMIT` at the top
of `ForthKernel.asm`.

### Reaching memory above 64 KB

The board has 8 MB of RAM and the display is at `$70_0000`, but Forth addresses
are 16 bits. Two words take a bank number as well:

    BANKC@  ( addr bank -- b )
    BANKC!  ( b addr bank -- )

    HEX 41 0 70 BANKC!      puts an A in the top left corner of the screen

On the Rockwell parts these words switch a bank latch. Here the bank is the top
byte of a 24-bit address.

### How it differs from the 6502 versions

The processor runs in native mode with 8-bit registers, so the kernel is still
6502 code. Native mode differs from a 6502 in two ways that mattered:

* Direct page indexing does not wrap at the end of the page. `0BRANCH` and
  `(+LOOP)` read the stack with `$FE,X` after dropping an item, which relies on
  the wrap.
* `TXS` with an 8-bit X register clears the high byte of the stack pointer,
  which would move the return stack into page zero. `(LOOP)`, `RP!` and the
  cold start set the stack pointer.

Those five places are assembled differently when `native` is set.

### Not done yet

* **No disk.** The disk registers point at eight zero bytes at the start of the
  ROM, so the disk words return instead of hanging. `LOAD`, `LIST` and the
  editor have nothing to work on.
* **`?TERMINAL`** looks at the serial port only, not the keyboard.
* **The Control-R check at start-up** (which forces a cold start) still reads
  the R6501 serial data register at `$17`. On this board that is ordinary RAM.
* **No 16-bit `BANK@` and `BANK!`**, and `BANKEXECUTE` and `BANKEEC!` do
  nothing.
* **The interpreter is not optimised for the 65C816.** `NEXT` and the
  arithmetic words still work a byte at a time.
* **The ADB keyboard is untested on hardware.** It works against a model in
  simulation.
* The words for the R6501's own ports and timers (`PA`, `PB`, `MCR`, `IFR` and
  so on) are still in the dictionary and address page zero.

## Changes made to the original source

These apply to every target.

* **Raw addresses are now labels.** The development ROM referred to about fifty
  places in itself and in the kernel by number (`JMP $F5EC`, `data.w $FC70`),
  which were only right for the R6501Q layout. The kernel can now change size
  without breaking the development ROM.
* **Two branch offsets had been written as labels** (`data.w NMI` for `$FFFA`,
  `data.w RESET` for `$FFFC`) and are numbers again.
* **The 65C02 and T20K cold starts clear `INTFLAG`**, which `NEXT` tests on
  every word.
* **Duplicate labels are gone.** The addresses of some user variables had the
  same names as the words that return them (`BASE`, `IN`, `DPL`, `HLD`, `UPAD`);
  the addresses are now `UV_BASE` and so on. The header labels of `+LOOP` and
  of the assembler's own `NOT` and `0=` clashed with `(LOOP)`, `NOT` and `0=`;
  they are now `_PLUSLOOP`, `_NOTC` and `_ZEQC`.

## Other documentation

`doc/` has the Rockwell manual text (`RockwellForth.txt`), the FIG-Forth 6502
listing this descends from (`FIG6502.ASM`), notes on the assembler and the
emulator (`AS.md`, `EM16.md`), and the L28 material.
