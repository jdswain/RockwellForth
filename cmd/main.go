package main

import (
	"os"
	"fmt"
	"sort"
)

type addrmode int64

const (
	Immediate addrmode = iota
	Absolute
	ZeroPage
	Accumulator
	Implied
	IndX  // (IND,X) 
	IndY  // (IND),Y
	ZeroPageX 
	AbsoluteX
	AbsoluteY
	Relative
	Indirect
	ZeroPageY // (IND,Y)
	BitAddress
)

type instr_info struct {
	opcode string
	mode addrmode
}

var instr = map[byte]instr_info {
	    0x00: {"BRK", Implied},
		0x01: {"ORA", IndX},
		0x02: {"$02", Implied},
		0x03: {"$03", Implied},
		0x04: {"$04", Implied},
		0x05: {"ORA", ZeroPage},
		0x06: {"ASL", ZeroPage},
		0x07: {"RMB 0,", ZeroPage},
		0x08: {"PHP", Implied},
		0x09: {"ORA", Immediate},
		0x0a: {"ASL", Accumulator},
		0x0b: {"$0B", Implied},
		0x0c: {"$0C", Implied},
		0x0d: {"ORA", Absolute},
		0x0e: {"ASL", Absolute},
		0x0f: {"BBR 0,", BitAddress},
		0x10: {"BPL", Relative},
		0x11: {"ORA", IndY},
		0x12: {"$12", Implied},
		0x13: {"$13", Implied},
		0x14: {"$14", Implied},
		0x15: {"ORA", ZeroPageX},
		0x16: {"ASL", ZeroPageX},
		0x17: {"RMB 1,", ZeroPage},
		0x18: {"CLC", Implied},
		0x19: {"ORA", AbsoluteY},
		0x1a: {"$1A", Implied},
		0x1b: {"$1B", Implied},
		0x1c: {"$1C", Implied},
		0x1d: {"ORA", AbsoluteX},
		0x1e: {"ASL", AbsoluteX},
		0x1f: {"BBR 1,", BitAddress},
		0x20: {"JSR", Absolute},
		0x21: {"AND", IndX},
		0x22: {"$22", Implied},
		0x23: {"$23", Implied},
		0x24: {"BIT", ZeroPage},
		0x25: {"AND", ZeroPage},
		0x26: {"ROL", ZeroPage},
		0x27: {"RMB 2,", ZeroPage},
		0x28: {"PLP", Implied},
		0x29: {"AND", Immediate},
		0x2a: {"ROL", Accumulator},
		0x2b: {"$2B", Implied},
		0x2c: {"BIT", Absolute},
		0x2d: {"AND", Absolute},
		0x2e: {"ROL", Absolute},
		0x2f: {"BBR 2,", BitAddress},
		0x30: {"BMI", Relative},
		0x31: {"AND", IndY},
		0x32: {"$32", Implied},
		0x33: {"$33", Implied},
		0x34: {"$34", Implied},
		0x35: {"AND", ZeroPageX},
		0x36: {"ROL", ZeroPageX},
		0x37: {"RMB 2,", ZeroPage},
		0x38: {"SEC", Implied},
		0x39: {"AND", Immediate},
		0x3a: {"ROL", Accumulator},
		0x3b: {"$2B", Implied},
		0x3c: {"BIT", Absolute},
		0x3d: {"AND", Absolute},
		0x3e: {"ROL", Absolute},
		0x3f: {"BBR 2,", BitAddress},
		0x40: {"RTI", Implied},
		0x41: {"EOR", IndX},
		0x42: {"DATA.b $42", Implied},
		0x43: {"$43", Implied},
		0x44: {"$44", Implied},
		0x45: {"EOR", ZeroPage},
		0x46: {"LSR", ZeroPage},
		0x47: {"RMB 4,", ZeroPage},
		0x48: {"PHA", Implied},
		0x49: {"EOR", Immediate},
		0x4a: {"LSR", Accumulator},
		0x4b: {"$4B", Implied},
		0x4c: {"JMP", Absolute},
		0x4d: {"EOR", Absolute},
		0x4e: {"LSR", Absolute},
		0x4f: {"BBR 4,", BitAddress},
		0x50: {"BVC", Relative},
		0x51: {"EOR", IndY},
		0x52: {"$52", Implied},
		0x53: {"$53", Implied},
		0x54: {"$54", Implied},
		0x55: {"EOR", ZeroPageX},
		0x56: {"LSR", ZeroPageX},
		0x57: {"RMB 5,", ZeroPage},
		0x58: {"CLI", Implied},
		0x59: {"EOR", AbsoluteY},
		0x5a: {"$5A", Implied},
		0x5b: {"$5B", Implied},
		0x5c: {"$5c", Implied},
		0x5d: {"EOR", AbsoluteX},
		0x5e: {"LSR", AbsoluteX},
		0x5f: {"BBR 5,", BitAddress},
		0x60: {"RTS", Implied},
		0x61: {"ADC", IndX},
		0x62: {"$62", Implied},
		0x63: {"$63", Implied},
		0x64: {"$64", Implied},
		0x65: {"ADC", ZeroPage},
		0x66: {"ROR", ZeroPage},
		0x67: {"RMB 6,", ZeroPage},
		0x68: {"PLA", Implied},
		0x69: {"ADC", Immediate},
		0x6a: {"ROR", Accumulator},
		0x6b: {"$6B", Implied},
		0x6c: {"JMP", Indirect},
		0x6d: {"ADC", Absolute},
		0x6e: {"ROR", Absolute},
		0x6f: {"BBR 6,", BitAddress},
		0x70: {"BVS", Relative},
		0x71: {"ADC", IndY},
		0x72: {"$72", Implied},
		0x73: {"$73", Implied},
		0x74: {"%74", Implied},
		0x75: {"ADC", ZeroPageX},
		0x76: {"ROR", ZeroPageX},
		0x77: {"RMB 7,", ZeroPage},
		0x78: {"SEI", Implied},
		0x79: {"ADC", AbsoluteY},
		0x7a: {"$7A", Implied},
		0x7b: {"$7B", Implied},
		0x7c: {"$7C", Implied},
		0x7d: {"ADC", AbsoluteX},
		0x7e: {"ROR", AbsoluteX},
		0x7f: {"BBR 7,", BitAddress},
		0x80: {"$80", Implied},
		0x81: {"STA", IndX},
		0x82: {"$82", Implied},
		0x83: {"$83", Implied},
		0x84: {"STY", ZeroPage},
		0x85: {"STA", ZeroPage},
		0x86: {"STX", ZeroPage},
		0x87: {"SMB 0,", ZeroPage},
		0x88: {"DEY", Implied},
		0x89: {"$89", Implied},
		0x8a: {"TXA", Implied},
		0x8b: {"$8B", Implied},
		0x8c: {"STY", Absolute},
		0x8d: {"STA", Absolute},
		0x8e: {"STX", Absolute},
		0x8f: {"BBS 0,", BitAddress},
		0x90: {"BCC", Relative},
		0x91: {"STA", IndY},
		0x92: {"$92", Implied},
		0x93: {"$93", Implied},
		0x94: {"STY", ZeroPageX},
		0x95: {"STA", ZeroPageX},
		0x96: {"STX", ZeroPageY},
		0x97: {"SMB 1,", ZeroPage},
		0x98: {"TYA", Implied},
		0x99: {"STA", AbsoluteY},
		0x9a: {"TXS", Implied},
		0x9b: {"$9B", Implied},
		0x9c: {"$9C", Implied},
		0x9d: {"STA", AbsoluteX},
		0x9e: {"$9E", Implied},
		0x9f: {"BBS 1,", BitAddress},
		0xa0: {"LDY", Immediate},
		0xa1: {"LDA", IndX},
		0xa2: {"LDX", Immediate},
		0xa3: {"$A3", Implied},
		0xa4: {"LDY", ZeroPage},
		0xa5: {"LDA", ZeroPage},
		0xa6: {"LDX", ZeroPage},
		0xa7: {"SMB 2,", ZeroPage},
		0xa8: {"TAY", Implied},
		0xa9: {"LDA", Immediate},
		0xaa: {"TAX", Implied},
		0xab: {"$AB", Implied},
		0xac: {"LDY", Absolute},
		0xad: {"LDA", Absolute},
		0xae: {"LDX", Absolute},
		0xaf: {"BBS 2,", BitAddress},
		0xb0: {"BCS", Relative},
		0xb1: {"LDA", IndY},
		0xb2: {"$B2", Implied},
		0xb3: {"$B3", Implied},
		0xb4: {"LDY", ZeroPageX},
		0xb5: {"LDA", ZeroPageX},
		0xb6: {"LDX", ZeroPageY},
		0xb7: {"SMB 3,", ZeroPage},
		0xb8: {"CLV", Implied},
		0xb9: {"LDA", AbsoluteY},
		0xba: {"TSX", Implied},
		0xbb: {"$BB", Implied},
		0xbc: {"LDY", AbsoluteX},
		0xbd: {"LDA", AbsoluteX},
		0xbe: {"LDX", AbsoluteY},
		0xbf: {"BBS 3,", BitAddress},
		0xc0: {"CPY", Immediate},
		0xc1: {"CMP", IndX},
		0xc2: {"$C2", Implied},
		0xc3: {"$C3", Implied},
		0xc4: {"CPY", ZeroPage},
		0xc5: {"CMP", ZeroPage},
		0xc6: {"DEC", ZeroPage},
		0xc7: {"SMB 4,", ZeroPage},
		0xc8: {"INY", Implied},
		0xc9: {"CMP", Immediate},
		0xca: {"DEX", Implied},
		0xcb: {"$CB", Implied},
		0xcc: {"CPY", Absolute},
		0xcd: {"CMP", Absolute},
		0xce: {"DEC", Absolute},
		0xcf: {"BBS 4,", BitAddress},
		0xd0: {"BNE", Relative},
		0xd1: {"CMP", IndY},
		0xd2: {"$D2", Implied},
		0xd3: {"$D3", Implied},
		0xd4: {"$D4", Implied},
		0xd5: {"CMP", ZeroPageX},
		0xd6: {"DEC", ZeroPageX},
		0xd7: {"SMB 5,", ZeroPage},
		0xd8: {"CLD", Implied},
		0xd9: {"CMP", AbsoluteY},
		0xda: {"$DA", Implied},
		0xdb: {"$DB", Implied},
		0xdc: {"$DC", Implied},
		0xdd: {"CMP", AbsoluteX},
		0xde: {"DEC", AbsoluteX},
		0xdf: {"BBS 5,", BitAddress},
		0xe0: {"CPX", Immediate},
		0xe1: {"SBC", IndX},
		0xe2: {"$E2", Implied},
		0xe3: {"$E3", Implied},
		0xe4: {"CPX", ZeroPage},
		0xe5: {"SBC", ZeroPage},
		0xe6: {"INC", ZeroPage},
		0xe7: {"SMB 6,", ZeroPage},
		0xe8: {"INX", Implied},
		0xe9: {"SBC", Immediate},
		0xea: {"NOP", Implied},
		0xeb: {"$EB", Implied},
		0xec: {"CPX", Absolute},
		0xed: {"SBC", Absolute},
		0xee: {"INC", Absolute},
		0xef: {"BBS 6,", BitAddress},
		0xf0: {"BEQ", Relative},
		0xf1: {"SBC", IndY},
		0xf2: {"$F2", Implied},
		0xf3: {"$F3", Implied},
		0xf4: {"$F4", Implied},
		0xf5: {"SBC", ZeroPageX},
		0xf6: {"INC", ZeroPageX},
		0xf7: {"SMB 7,", ZeroPage},
		0xf8: {"SED", Implied},
		0xf9: {"SBC", AbsoluteY},
		0xfa: {"$FA", Implied},
		0xfb: {"$FB", Implied},
		0xfc: {"$FC", Implied},
		0xfd: {"SBC", AbsoluteX},
		0xfe: {"INC", AbsoluteX},
		0xff: {"BBS 7,", BitAddress},

}

type datatype int64

const(
	Bytes datatype = iota
	String
	Address
	Word // A headless word
	WordDef
	NextWord
	Vector
	Register
	Code
	Label
)

type data struct {
	label string
	length int
	dt datatype
}

var undefined = data {"Undefined", 0x0001, Bytes}

var datalist = map[int]data {}

var kernel_datalist = map[int]data {
	0xf000: {"Unused", 0x0400, Bytes}, // Empty space at start

	0xf858: {"STORE", 0x0002, Word}, // ! PFA data
	0xfe7d: {"HASH", 0x0002, Word}, // # data
	0xfe5c: {"HASHGT", 0x0002, Word}, // #> data
	0xfea0: {"HASHS", 0x0002, Word}, // #S data
	0xf4d0: {"PLOOP", 0x0002, Word}, // (+LOOP) data
	0xfa31: {"PDOTQ", 0x0002, Word}, // (.") data
	0xf4f8: {"DO", 0x0002, Word}, // (DO) data
	0xf535: {"FIND", 0x0002, Word}, // (FIND) data
	0xf4af: {"LOOP", 0x0002, Word}, // (LOOP) data
	0xfb06: {"LTNUMBER", 0x0002, Word}, // <NUMBER) data
	0xfcb6: {"MUL", 0x0002, Word}, // * data
	0xfce8: {"MULDIV", 0x0002, Word}, // */ data
	0xfcdc: {"MULDIVMOD", 0x0002, Word}, // */MOD data
	0xf778: {"PLUS", 0x0002, Word}, // + data
	0xf930: {"SUB", 0x0002, Word}, // - data
	0xf818: {"PSTORE", 0x0002, Word}, // +! data
	0xfc36: {"PM", 0x0002, Word}, // +- data
	0xf9a5: {"SUBDUP", 0x0002, Word}, // -DUP data
	0xfa0b: {"SUBTRAILING", 0x0002, Word}, // -TRAILING data
	0xfee4: {"DOT", 0x0002, Word}, // . data
	0xfed8: {"DOTR", 0x0002, Word}, // .R data
	0xfcca: {"DIV_", 0x0002, Word}, // / data
	0xfcbe: {"DIVMOD", 0x0002, Word}, // /MOD data
	0xf8af: {"ZERO", 0x0004, Word}, // 0 data
	0xf76b: {"ZLT", 0x0002, Word}, // 0< data
	0xf75b: {"ZEQ", 0x0002, Word}, // 0= data
	0xf497: {"ZBRAN", 0x0002, Word}, // 0BRANCH data
	0xf8b3: {"ONE", 0x0004, Word}, // 1 data
	0xf8f8: {"ONEPLUS", 0x0002, Word}, // 1+ data
	0xf913: {"ONEMINUS", 0x0002, Word}, // 1- data
	0xf8b7: {"TWO", 0x0004, Word}, // 2 data
	0xf903: {"TWOPLUS", 0x0002, Word}, // 2+ data
	0xf920: {"TWOMINUS", 0x0002, Word}, // 2- data
	0xf7d1: {"TWODROP", 0x0002, Word}, // 2DROP data
	0xf7ef: {"TWODUP", 0x0002, Word}, // 2DUP data
	0xf8bb: {"THREE", 0x0004, Word}, // 3 data
	0xf8bf: {"FOUR", 0x0004, Word}, // 4 data
	0xf717: {"SEMIS", 0x0002, Word}, // ;s data
	0xf954: {"LESS", 0x0002, Word}, // < data
	0xfe52: {"LEQ", 0x0002, Word}, // <= data
	0xf938: {"EQUAL", 0x0002, Word}, // = data
	0xf96c: {"GT", 0x0002, Word}, // > data
	0xf734: {"GTR", 0x0002, Word}, // >R data
	0xfeec: {"Q", 0x0002, Word}, // ? data
	0xf60a: {"QTERM", 0x0002, Word}, // ?TERMINAL data
	0xf83b: {"AT", 0x0002, Word}, // @ data
	0xfc4e: {"ABS", 0x0002, Word}, // ABS data
	0xf6be: {"ANDD", 0x0002, Word}, // AND data
	0xff42: {"BANKCSTOR", 0x0002, Word}, // BANKC! data
	0xff4a: {"BANKCAT", 0x0002, Word}, // BANKC@ data
	0xff52: {"BANKEECS", 0x0002, Word}, // BANKEEC! data
	0xff5a: {"BANKEXEC", 0x0002, Word}, // BANKEXECUTE data
	0xf8d9: {"BASE", 0x0002, Word}, // BASE data
	0xf8c3: {"BL", 0x0002, Word}, // BL data
	0xfaec: {"BLANKS", 0x0002, Word}, // BLANKS data
	0xf803: {"BOUNDS", 0x0002, Word}, // BOUNDS data
	0xf480: {"BRAN", 0x0002, Word}, // BRANCH data
	0xf86b: {"CSTOR", 0x0002, Word}, // C! data
	0xf8e8: {"CL", 0x0002, Word}, // C/L data
	0xf84b: {"CAT", 0x0002, Word}, // C@ data
	0xf8dc: {"CLDWRM", 0x0002, Word}, // CLD/WRM data
	0xf458: {"CLIT", 0x0002, Word}, // CLIT data
	0xf626: {"CMOVE", 0x0002, Word}, // CMOVE data
	0xfb48: {"COLD", 0x0002, Word}, // COLD data
	0xf9e3: {"COUNT", 0x0002, Word}, // COUNT data
	0xf613: {"CR", 0x0002, Word}, // CR data
	0xf787: {"DPLUS", 0x0002, Word}, // D+ data

	0xfc42: {"DPLUS1", 0x0002, Word}, // D+1 data
	0xfece: {"DDOT", 0x0002, Word}, // D. data
	0xfeb0: {"DDOTR", 0x0002, Word}, // D.R data
	0xfc56: {"DABS", 0x0002, Word}, // DABS data
	0xf9bc: {"DECIMAL", 0x000b, Word},   // DECIMWord
	0xf50d: {"DIGIT", 0x0002, Word}, // DIGIT data
	0xfd08: {"DISK", 0x0002, Word}, // DISK data
	0xf7b5: {"DNEGATE", 0x0002, Word}, // DNEGATE data
	0xf8e2: {"DPL", 0x0002, Word}, // DPL data
	0xfD57: {"DREAD", 0x0002, Word}, // DREAD data
	0xf7cf: {"DROP", 0x0002, Word}, // DROP data
	0xf7e5: {"DUP", 0x0002, Word}, // DUP data
	0xfdbe: {"DWRITE", 0x0002, Word}, // DWRITE data
	0xfef4: {"EECSTORE", 0x0002, Word}, // EEC! data
	0xf5d4: {"EMIT", 0x0002, Word}, // EMIT data
	0xf591: {"ENCLOSE", 0x0002, Word}, // ENCLOSE data
	0xfae4: {"ERASE", 0x0002, Word}, // ERASE data
	0xf471: {"EXECUTE", 0x0002, Word}, // EXECUTE data
	0xfa45: {"EXPECT", 0x0002, Word}, // EXPECT data
	0xfabe: {"FILL_", 0x0002, Word}, // FILL data
	0xf9b1: {"HEX", 0x000b, Word},   // HEX data
	0xf8e5: {"HLD", 0x0002, Word}, // HLD data
	0xfaf4: {"HOLD", 0x0002, Word}, // HOLD data
	0xf8df: {"IN", 0x0002, Word}, // IN data
	0xfdf1: {"INIT", 0x0002, Word}, // INIT data
	0xf5f6: {"KEY", 0x0002, Word}, // KEY data
	0xf722: {"LEAVE", 0x0002, Word}, // LEWorda
	0xf40e: {"LIT", 0x0002, Word}, // LIT data
	0xfc7e: {"MMUL", 0x0002, Word}, // M* data
	0xfc94: {"MDIV", 0x0002, Word}, // M/ data
	0xfcf2: {"MDIVMOD", 0x0002, Word}, // M/MOD data
	0xfc63: {"MAX", 0x0002, Word}, // MAX data
	0xfc5e: {"MIN", 0x0002, Word}, // MIN data

	0xfcd4: {"MOD_", 0x0002, Word}, // MOD data
	0xf7a5: {"NEGATE", 0x0002, Word}, // NEGATE data
	0xf6ce: {"OR", 0x0002, Word}, // OR data
	0xf7c5: {"OVER", 0x0002, Word}, // OVER data
	0xf8f0: {"PAD", 0x0002, Word}, // PAD data
	0xf98f: {"PICK", 0x0002, Word}, // PICK data
	0xfaac: {"QUERY", 0x0002, Word}, // QUERY data
	0xf74c: {"R", 0x0002, Word}, // R data
	0xf73f: {"RFROM", 0x0002, Word}, // R> data
	0xf6fd: {"RPSTO", 0x0002, Word}, // RP! data
	0xf80c: {"RPAT", 0x0002, Word}, // RP@ data
	0xf8cd: {"RZ", 0x0002, Word}, // R0 data
	0xf974: {"ROT", 0x0002, Word}, // ROT data
	0xfc2c: {"STOD", 0x0002, Word}, // S->D data
	0xf8ca: {"SZ", 0x0002, Word}, // S0 data
	0xfe11: {"SEEK", 0x0002, Word}, // SEEK data
	0xfd43: {"SELECT", 0x0002, Word}, // SELECT data
	0xfe6c: {"SIGN", 0x0002, Word}, // SIGN data
	0xf6f3: {"SPSTORE", 0x0002, Word}, // SP! data
	0xf6ea: {"SPAT", 0x0002, Word}, // SP@ data
	0xf99d: {"SPACE", 0x0002, Word}, // SPACE data
	0xfe3a: {"SPACES", 0x0002, Word}, // SPACES data
	0xf7d3: {"SWAP", 0x0002, Word}, // SWAP data
	0xf8c7: {"TIB", 0x0002, Word}, // TIB data
	0xf830: {"TOGGL", 0x0002, Word}, // TOGGLE data
	0xf9ef: {"TYPE", 0x0002, Word}, // TYPE data
	0xf646: {"UMUL", 0x0002, Word}, // U* data
	0xf67b: {"UDIV", 0x0002, Word}, // U/ data
	0xf940: {"ULESS", 0x0002, Word}, // U< data
	0xf8d0: {"UCL", 0x0002, Word}, // UC/L data
	0xf8d3: {"UPAD", 0x0002, Word}, // UPAD data
	0xf8d6: {"URW", 0x0002, Word}, // UR/W data
	0xf6dc: {"XOR", 0x0002, Word}, // XOR data

	0xfbf5: {"unkn0", 0x0002, Word},
	0xfc01: {"unkn1", 0x0002, Word},
	0xfc0a: {"unkn2", 0x0002, Word},

	0xff2e: {"BANKPSH", 0x0002, Word},
	0xff3a: {"BANKPOP", 0x0002, Word},
	0xf719: {"SEMIS_C", 0x0002, Code},
	0xff62: {"unkn5", 0x0002, Code},
	0xff7f: {"unkn6", 0x0002, Code},

	0xffb6: {"unkna", 0x0002, Word},
	0xffca: {"MON", 0x0002, Word},

	0xfe03: {"SUB1", 0x0002, Code},
	0xfe0d: {"TAB1", 0x0004, Bytes},

	0xfdb5: {"DSTAT", 0x0002, Code},
	
	0xf70c: {"PUSHS", 0x0000, Word}, // Push stack pointer, not used 

	0xf6c9: {"BINARY", 0x0000, Label}, // 
	0xf508: {"POP", 0x0000, Label}, // 
	0xf506: {"POPTWO", 0x0000, Label}, // 
	0xf6ed: {"PUSHOA", 0x0000, Label}, // 
	0xf428: {"NEXT", 0x0000, Code}, // Executes next
	0xfb49: {"RESET", 0x0002, Code}, // RESET data

	0xf874: {"DOCOL", 0x0000, Code}, // COLON definition words 
	0xf8a0: {"DOUSE", 0x0000, Code}, // USER variable words
	0xf894: {"DOVAR", 0x0000, Code}, // VARIABLE words
	0xf889: {"DOCON", 0x0000, Code}, // CONSTANT words
	0xf9c5: {"DOES", 0x0000, Code}, // DOES> words
	0xf421: {"PUSH", 0x0000, Label}, 
	0xf423: {"PUT_", 0x0000, Label}, 
	// Next address signifies a code word
	
	0xfffa: {"NMIVEC", 0x0002, Vector}, // NMI
	0xfffc: {"RESETVEC", 0x0002, Vector}, // Reset
	0xfffe: {"IRQVEC", 0x0002, Vector}, // IRQ

	0xf400: {"INITVAR", 0x000d, Bytes}, // Initial value of vars UP..
	// Hardware Registers
	0x00: {"PortA", 0x0001, Register},
	0x01: {"PortB", 0x0001, Register},
	0x04: {"PortE", 0x0001, Register},
	0x05: {"PortF", 0x0001, Register},
	0x06: {"PortG", 0x0001, Register},
	0x10: {"ClearIntFlag", 0x0001, Register},
	0x11: {"IFR", 0x0001, Register},
	0x12: {"IER", 0x0001, Register},
	0x14: {"MCR", 0x0001, Register},
	0x15: {"SCCR", 0x0001, Register},
	0x16: {"SCSR", 0x0001, Register},
	0x17: {"SRDR", 0x0001, Register},
	0x18: {"LCACLR", 0x0001, Register},
	0x19: {"UCA", 0x0001, Register},
	0x1a: {"LCA", 0x0001, Register},
	0x1c: {"LCBCLR", 0x0001, Register},
	0x1d: {"UCB", 0x0001, Register},
	0x1e: {"LCB", 0x0001, Register},

	// Forth Registers
	0x0040: {"IRQSOFT", 0x0002, Register},
	0x0042: {"NMISOFT", 0x0002, Register},

	0x48: {"UP", 0x0002, Register}, // user area pointer(check)
	0x4a: {"INTFLAG", 0x0001, Register},
	0x4b: {"WM1",  0x0001, Register},
	0x4c: {"W",  0x0002, Register},
	0x4d: {"WP1",  0x0001, Register},
	0x4e: {"IP", 0x0002, Register},
	0x4f: {"IPP1", 0x0001, Register},
	0x50: {"NM1", 0x0001, Register},
	0x51: {"N", 0x0001, Register},
	0x52: {"NP1", 0x0001, Register},
	0x53: {"NP2", 0x0001, Register},
	0x54: {"NP3", 0x0001, Register},
	0x55: {"NP4", 0x0001, Register},
	0x56: {"NP5", 0x0001, Register},
	0x57: {"NP6", 0x0001, Register},
	0x58: {"NP7", 0x0001, Register},
	0x59: {"XSAVE", 0x0001, Register},

	0x5b: {"INTVEC", 0x0002, Register},
	0x5c: {"INTVECP1", 0x0001, Register},

	0x0300: {"TIB", 0x0001, Register}, // Terminal Input Buffer Address $0308
	0x0302: {"RO", 0x0001, Register}, // Return stack base address $00ff
	0x0304: {"SO", 0x0001, Register}, // Parameter stack base address $00c2
	0x0306: {"UC_L", 0x0001, Register}, // Number of characters per line $0050
	0x0308: {"UPAD", 0x0001, Register}, // Location of PAD in memory $037e
	0x030a: {"UR_W", 0x0001, Register}, // CFA of UR/W orphan word
	0x030c: {"BASE", 0x0001, Register}, // Current I/O base number $0010
	0x030e: {"CLD_WARM", 0x0001, Register}, // Cold/Warm reset flag
	0x0310: {"IN", 0x0001, Register}, // Byte offset in current input stream
	0x0312: {"DPL", 0x0001, Register}, // Number of decimals in double precision input
	0x0314: {"HLD", 0x0001, Register}, // Address of current output
	0x0316: {"DISKNO", 0x0001, Register}, // Number of selected disk drive
	0x0318: {"CYLINDER", 0x0004, Register}, // Track of each disk, 4 bytes, $ff
	0x031c: {"B_SIDE", 0x0001, Register},   // Blocks per side per disk, $80 (change to $320)
	
	// Disk Registers
	// For the R6501Q these are at E000 and E100
	0xe000: {"DSK_STATUS", 0x0001, Register},
	0xe101: {"DSK_TRACK", 0x0001, Register},
	0xe102: {"DSK_SECTOR", 0x0001, Register},
	0xe103: {"DSK_DATA", 0x0001, Register},
	0xe106: {"DSK_CTL", 0x0001, Register},

}

var development_datalist = map[int]data {
	0xc000: {"IDENT", 0x0002, Word}, 
	0xc002: {"START", 0x0002, Word},
	0xc004: {"UNKNOWN", 0x027, Bytes}, 

	0xc02c: {"_LIT", 0x0002, WordDef},
	0xc034: {"_CLIT", 0x0002, WordDef},
	0xc03d: {"_EXECUTE", 0x0002, WordDef},
	0xc049: {"_BRANCH", 0x0002, WordDef},
	0xc054: {"_ZBRANCH", 0x0002, WordDef},
	0xc060: {"_PLOOP", 0x0002, WordDef},
	0xc06b: {"_PPLOOP", 0x0002, WordDef},
	0xc077: {"_PDO", 0x0002, WordDef},
	0xc080: {"_I", 0x0002, WordDef},
	0xc088: {"_DIGIT", 0x0002, WordDef},
	0xc092: {"_PFIND", 0x0002, WordDef},
	0xc09d: {"_ENCLOSE", 0x0002, WordDef},
	0xc0a9: {"_EMIT", 0x0002, WordDef},
	0xc0b2: {"_KEY", 0x0002, WordDef},
	0xc0ba: {"_QTERMINAL", 0x0002, WordDef},
	0xc0c8: {"_CR", 0x0002, WordDef},
    0xc0cf: {"_XON", 0x0002, WordDef},
    0xc0d7: {"XON", 0x0002, Word},
    0xc0df: {"_XOFF", 0x0002, WordDef},
    0xc0e8: {"XOFF", 0x0002, Word},
    0xc0f0: {"_SOURCE", 0x0002, WordDef},
    0xc0fb: {"SOURCE", 0x0002, Word},
    0xc13d: {"_FINIS", 0x0002, WordDef},
    0xc147: {"FINIS", 0x0002, Word},
    0xc154: {"_CMOVE", 0x0002, WordDef},
    0xc15e: {"_UMUL", 0x0002, WordDef},
    0xc165: {"_UDIV", 0x0002, WordDef},
    0xc16c: {"_AND", 0x0002, WordDef},
    0xc174: {"_OR", 0x0002, WordDef},
    0xc17b: {"_XOR", 0x0002, WordDef},
    0xc183: {"_SPAT", 0x0002, WordDef},
    0xc18b: {"_SPSTOR", 0x0002, WordDef},
    0xc193: {"_RPSTOR", 0x0002, WordDef},
    0xc19b: {"_RPAT", 0x0002, WordDef},
    0xc1a3: {"_SEMIS", 0x0002, WordDef},	
    0xc1aa: {"_LEAVE", 0x0002, WordDef},
    0xc1b4: {"_GTR", 0x0002, WordDef},
    0xc1bb: {"_RGT", 0x0002, WordDef},
    0xc1c2: {"_R", 0x0002, WordDef},
    0xc1c8: {"_ZEQ", 0x0002, WordDef},
    0xc1cf: {"_NOT", 0x0002, WordDef},
	0xc1d9: {"_ZLT", 0x0002, WordDef},
    0xc1e0: {"_PLUS", 0x0002, WordDef},
    0xc1e6: {"_DPLUS", 0x0002, WordDef},
    0xc1ed: {"_NEGATE", 0x0002, WordDef},
    0xc1f8: {"_DNEGATE", 0x0002, WordDef},
    0xc204: {"_OVER", 0x0002, WordDef},
    0xc20d: {"_DROP", 0x0002, WordDef},
    0xc216: {"_TWODROP", 0x0002, WordDef},
    0xc220: {"_SWAP", 0x0002, WordDef},
    0xc229: {"_DUP", 0x0002, WordDef},
    0xc231: {"_TWODUP", 0x0002, WordDef},
    0xc23a: {"_BOUNDS", 0x0002, WordDef},
    0xc245: {"_PLUSSTOR", 0x0002, WordDef},
    0xc24c: {"_TOGGLE", 0x0002, WordDef},
    0xc257: {"_AT", 0x0002, WordDef},
    0xc25d: {"_CAT", 0x0002, WordDef},
    0xc264: {"_STOR", 0x0002, WordDef},
    0xc26a: {"_CSTOR", 0x0002, WordDef},
    0xc271: {"CSTOR", 0x0002, Word},
    0xc281: {"_COLON", 0x0020, WordDef},
    0xc287: {"COLON", 0x0002, Word},
    0xc29f: {"_SEMI", 0x0002, WordDef},
    0xc2a6: {"SEMI", 0x0002, Word},
    0xc2b3: {"_CONSTANT", 0x0002, WordDef},
    0xc2c0: {"CONSTANT", 0x0002, Word},
    0xc2ce: {"_VARIABLE", 0x0002, WordDef},
    0xc2db: {"VARIABLE", 0x0002, Word},
    0xc2e5: {"_CODE", 0x0002, WordDef},
    0xc2ee: {"CODE", 0x0002, Word},
    0xc2fb: {"PADVAR", 0x0001, Bytes},
    0xc2fc: {"_USER", 0x0002, WordDef},
    0xc305: {"USER", 0x0002, Word},
    0xc312: {"pad", 0x0001, Bytes},
    0xc313: {"_ZERO", 0x0002, WordDef},
    0xc319: {"_ONE", 0x0002, WordDef},
    0xc31f: {"_TWO", 0x0002, WordDef},
    0xc325: {"_THREE", 0x0002, WordDef},
    0xc32b: {"_FOUR", 0x0002, WordDef},
    0xc331: {"_BL", 0x0002, WordDef},
    0xc338: {"_TIB", 0x0002, WordDef},
    0xc340: {"_S0", 0x0002, WordDef},
    0xc347: {"_R0", 0x0002, WordDef},
    0xc34e: {"_UCL", 0x0002, WordDef},
    0xc357: {"_UPAD", 0x0002, WordDef},
    0xc360: {"_URW", 0x0002, WordDef},
    0xc369: {"_BASE", 0x0002, WordDef},
    0xc372: {"_CLDWRM", 0x0002, WordDef},
    0xc37e: {"_IN", 0x0002, WordDef},
    0xc385: {"_DPL", 0x0002, WordDef},
    0xc38d: {"_HLD", 0x0002, WordDef},
    0xc395: {"_DISKNO", 0x0002, WordDef},
    0xc3a0: {"DISKNO", 0x0002, Word},
	0xc3a3: {"_CYLINDER", 0x0002, WordDef},
	0xc3b0: {"CYLINDER", 0x0002, Word},
	0xc3b3: {"_BSIDE", 0x0002, WordDef},
	0xc3be: {"BSIDE", 0x0002, Word},
	0xc3c1: {"_UFIRST", 0x0002, WordDef},
	0xc3cc: {"UFIRST", 0x0002, Word},
    0xc3cf: {"_ULIMIT", 0x0002, WordDef},
    0xc3da: {"ULIMIT", 0x0002, Word},
    0xc3dd: {"_OFFSET", 0x0002, WordDef},
    0xc3e8: {"OFFSET", 0x0002, Word},
    0xc3eb: {"_WIDTH", 0x0002, WordDef},
    0xc3f5: {"WIDTH", 0x0002, Word},
    0xc3f8: {"_WARNING", 0x0002, WordDef},
    0xc404: {"WARNING", 0x0002, Word},
    0xc407: {"_FENCE", 0x0002, WordDef},
    0xc411: {"FENCE", 0x0002, Word},
    0xc414: {"_DP", 0x0002, WordDef},
    0xc41b: {"DP", 0x0002, Word},
    0xc41e: {"_HEADERLESS", 0x0002, WordDef},
    0xc42d: {"HEADERLESS", 0x0002, Word},
    0xc430: {"_VOCL", 0x0002, WordDef},
    0xc43d: {"VOCL", 0x0002, Word},
	0xc440: {"unk", 0x0006, Bytes},
	0xc446: {"_UABORT", 0x0002, WordDef},
	0xc451: {"UABORT", 0x0002, Word},
    0xc454: {"_USE", 0x0002, WordDef},
    0xc45c: {"USE", 0x0002, Word},
    0xc45f: {"_PREV", 0x0002, WordDef},
    0xc468: {"PREV", 0x0002, Word},
    0xc46b: {"_BLK", 0x0002, WordDef},
    0xc473: {"BLK", 0x0002, Word},
    0xc476: {"_SCR", 0x0002, WordDef},
    0xc47e: {"SCR", 0x0002, Word},
    0xc481: {"_CONTEXT", 0x0002, WordDef},
    0xc48d: {"CONTEXT", 0x0002, Word},
    0xc490: {"_CURRENT", 0x0002, WordDef},
    0xc49c: {"CURRENT", 0x0002, Word},
    0xc49f: {"_STATE", 0x0002, WordDef},
    0xc4a9: {"STATE", 0x0002, Word},
    0xc4ac: {"_CSP", 0x0002, WordDef},
    0xc4b4: {"CSP", 0x0002, Word},
    0xc4b7: {"_MODE", 0x0002, WordDef},
    0xc4c0: {"MODE", 0x0002, Word},
    0xc4c3: {"_KHZ", 0x0002, WordDef},
    0xc4cb: {"KHZ", 0x0002, Word},
    0xc4ce: {"CL", 0x0002, WordDef},
    0xc4d6: {"_FIRST", 0x0002, WordDef},
    0xc4e0: {"FIRST", 0x0002, Word},
    0xc4e8: {"_LIMIT", 0x0002, WordDef},
    0xc4f2: {"LIMIT", 0x0002, Word},
    0xc4fa: {"_PAD", 0x0002, WordDef},
    0xc502: {"_ONEPLUS", 0x0002, WordDef},
    0xc509: {"_2PLUS", 0x0002, WordDef},
    0xc510: {"_1SUB", 0x0002, WordDef},
    0xc517: {"_2SUB", 0x0002, WordDef},
    0xc51e: {"_DPDIV", 0x0002, WordDef},
    0xc526: {"DPDIV", 0x0002, Word},
    0xc536: {"_HEREDIV", 0x0002, WordDef},
    0xc540: {"HEREDIV", 0x0002, Word},
    0xc548: {"_ALLOTDIV", 0x0002, WordDef},
    0xc553: {"ALLOTDIV", 0x0002, Word},
    0xc55b: {"_COMMADIV", 0x0002, WordDef},
    0xc562: {"COMMADIV", 0x0002, Word},
    0xc56e: {"_HERE", 0x0002, WordDef},
    0xc577: {"HERE", 0x0002, Word},
    0xc57f: {"_ALLOT", 0x0002, WordDef},
    0xc589: {"ALLOT", 0x0002, Word},
    0xc591: {"_COMMA", 0x0002, WordDef},
    0xc597: {"COMMA", 0x0002, Word},
    0xc5a3: {"_CCOMMA", 0x0002, WordDef},
    0xc5aa: {"CCOMMA", 0x0002, Word},
    0xc5b6: {"_SUB", 0x0002, WordDef},
    0xc5bc: {"_EQ", 0x0002, WordDef},
    0xc5c2: {"_ULT", 0x0002, WordDef},
    0xc5c9: {"_LT", 0x0002, WordDef},
    0xc5cf: {"_GT", 0x0002, WordDef},
    0xc5d5: {"_ROT", 0x0002, WordDef},
    0xc5dd: {"_PICK", 0x0002, WordDef},
    0xc5e6: {"_SPACE", 0x0002, WordDef},
    0xc5f0: {"_SUBDUP", 0x0002, WordDef},
    0xc5f9: {"_TRAVERSE", 0x0002, WordDef},
    0xc606: {"TRAVERSE", 0x0002, Word},
    0xc621: {"_LATEST", 0x0002, WordDef},
    0xc62c: {"LATEST", 0x0002, Word},
    0xc636: {"_LFA", 0x0002, WordDef},
    0xc63e: {"LFA", 0x0002, Word},
    0xc640: {"_CFA", 0x0002, WordDef},
    0xc648: {"CFA", 0x0002, Word},
    0xc650: {"_NFA", 0x0002, WordDef},
    0xc658: {"NFA", 0x0002, Word},
    0xc667: {"_PFAPTR", 0x0002, WordDef},
    0xc672: {"PFAPTR", 0x0002, Word},
    0xc67f: {"_STORCSP", 0x0002, WordDef},
    0xc688: {"STORCSP", 0x0002, Word},
    0xc692: {"_QERROR", 0x0002, WordDef},
    0xc69d: {"QERROR", 0x0002, Word},
    0xc6ab: {"_QCOMP", 0x0002, WordDef},
    0xc6b5: {"QCOMP", 0x0002, Word},
    0xc6c4: {"_QEXEC", 0x0002, WordDef},
    0xc6ce: {"QEXEC", 0x0002, Word},
    0xc6db: {"_QPAIRS", 0x0002, WordDef},
    0xc6e6: {"QPAIRS", 0x0002, Word},
    0xc6f1: {"_QCSP", 0x0002, WordDef},
    0xc6fa: {"QCSP", 0x0002, Word},
    0xc70b: {"_COMPILE", 0x0002, WordDef},
    0xc717: {"COMPILE", 0x0002, Word},
    0xc729: {"_LBRAC", 0x0002, WordDef},
    0xc72f: {"LBRAC", 0x0002, Word},
    0xc739: {"_RBRAC", 0x0002, WordDef},
    0xc73f: {"RBRAC", 0x0002, Word},
    0xc74a: {"_SMUDGE", 0x0002, WordDef},
    0xc755: {"SMUDGE", 0x0002, Word},
    0xc75f: {"_HEX", 0x0002, WordDef},
    0xc767: {"_DECIMAL", 0x0002, WordDef},
    0xc773: {"_PSEMICODE", 0x0002, WordDef},
    0xc77f: {"PSEMICODE", 0x0002, Word},
    0xc78d: {"_SEMICODE", 0x0002, WordDef},
    0xc797: {"SEMICODE", 0x0002, Word},
    0xc7a5: {"_LTBUILDS", 0x0002, WordDef},
    0xc7b1: {"LTBUILDS", 0x0002, Word},
    0xc7b9: {"_DOESGT", 0x0002, WordDef},
    0xc7c3: {"DOESGT", 0x0002, Word},
    0xc7d5: {"_COUNT", 0x0002, WordDef},
    0xc7df: {"_TYPE", 0x0002, WordDef},
    0xc7e8: {"_SUBTRAILING", 0x0002, WordDef},
    0xc7f6: {"_PDOTQUOT", 0x0002, WordDef},
    0xc7ff: {"_DOTQUOT", 0x002d, WordDef},
    0xc806: {"DOTQUOT", 0x002d, Word},
    0xc815: {"PDOTQADDR", 0x0002, Bytes},
    0xc817: {"CONT", 0x0002, Word},
    0xc82d: {"EXPECT", 0x0002, WordDef},
    0xc838: {"_QUERY", 0x0002, WordDef},
	0xc842: {"_FX", 0x0002, WordDef},
	0xc848: {"FX", 0x0002, Word},
    0xc866: {"_FILL", 0x0002, WordDef},
    0xc86f: {"_ERASE", 0x0002, WordDef},
    0xc879: {"_BLANKS", 0x0002, WordDef},
    0xc884: {"_HOLD", 0x0002, WordDef},
    0xc88d: {"_FWORD", 0x0002, WordDef},
    0xc896: {"FWORD", 0x0002, Word},
    0xc8db: {"_PNUMBER", 0x0002, WordDef},
    0xc8e8: {"_NUMBER", 0x0002, WordDef},
    0xc8f3: {"NUMBER", 0x0002, Word},
    0xc941: {"_SUBFIND", 0x0002, WordDef},
    0xc94b: {"SUBFIND", 0x0002, Word},
    0xc96d: {"_PABORT", 0x0002, WordDef},
    0xc979: {"PABORT", 0x0002, Word},
    0xc983: {"_ERR", 0x0002, WordDef},
    0xc98d: {"ERR", 0x0002, Word},
    0xc9c2: {"_ID", 0x0002, WordDef},
    0xc9ca: {"ID", 0x0002, Word},
    0xc9e8: {"_CREATE", 0x0002, WordDef},
    0xc9f3: {"CREATE", 0x0002, Word},
    0xca88: {"_BRACCOMPILE", 0x0002, WordDef},
    0xca96: {"BRACCOMPILE", 0x0002, Word},
    0xcaa8: {"_LITERAL", 0x0002, WordDef},
    0xcab4: {"LITERAL", 0x0002, Word},
    0xcad2: {"CREATE5", 0x0002, Word},
    0xcad9: {"PAD_DDD", 0x0001, Bytes},
    0xcada: {"_DLITERAL", 0x0002, WordDef},
    0xcae7: {"DLITERAL", 0x0002, Word},
    0xcaf9: {"_QSTACK", 0x0002, WordDef},
    0xcb04: {"QSTACK", 0x0002, Word},
    0xcb21: {"_INTERPRET", 0x0002, WordDef},
    0xcb2f: {"INTERPRET", 0x0002, Word},
    0xcb71: {"_IMMEDIATE", 0x0002, WordDef},
    0xcb7f: {"IMMEDIATE", 0x0002, Word},
    0xcb8a: {"_VOCABULARY", 0x0002, WordDef},
    0xcb99: {"VOCABULARY", 0x0002, Word},
    0xcbc1: {"_FORTH", 0x0002, WordDef },
    0xcbcb: {"FORTH", 0x0002, Word},
    0xcbd5: {"_ASSEMBLER", 0x0002, WordDef},
    0xcbe3: {"ASSEMBLER", 0x0002, Word},
    0xcbeb: {"_DEFINITIONS", 0x0002, WordDef},
    0xcbfb: {"DEFINITIONS", 0x0002, Word},
    0xcc07: {"_OBRAC", 0x0002, WordDef},
    0xcc0d: {"OBRAC", 0x0002, Word},
    0xcc44: {"_OB", 0x0002, WordDef},
    0xcc4e: {"OB", 0x0002, Word},
    0xcc16: {"_QUIT", 0x0002, WordDef},
    0xcc1f: {"QUIT", 0x0002, Word},
    0xccb2: {"_COLD", 0x0002, WordDef},
    0xccbb: {"_STOD", 0x0002, WordDef},
    0xccc4: {"_PLUSMINUS", 0x0002, WordDef},
    0xcccb: {"_DPLUSMINUS", 0x0002, WordDef},
    0xccd3: {"_ABS", 0x0002, WordDef},
    0xccdb: {"_DABS", 0x0002, WordDef},
    0xcce4: {"_MIN", 0x0002, WordDef},
    0xccec: {"_MAX", 0x0002, WordDef},
    0xccf4: {"_MMUL", 0x0002, WordDef},
    0xccfb: {"_MDIV", 0x0002, WordDef},
    0xcd02: {"_MUL", 0x0002, WordDef},
    0xcd08: {"_DIVMOD", 0x0002, WordDef},
    0xcd11: {"_DIV", 0x0002, WordDef},
    0xcd17: {"_MOD", 0x0002, WordDef},
    0xcd1f: {"_MULDIVMOD", 0x0002, WordDef},
    0xcd29: {"_MULDIV", 0x0002, WordDef},
    0xcd30: {"_MMOD", 0x0002, WordDef},
    0xcd3a: {"_PLUSBUF", 0x0002, WordDef},
    0xcd43: {"PLUSBUF", 0x0002, Word},
    0xcd69: {"_UPDATE", 0x0002, WordDef},
    0xcd74: {"UPDATE", 0x0002, Word},
    0xcd8a: {"_EMPTYBUFFERS", 0x0002, WordDef},
    0xcd9c: {"EMPTYBUFFERS", 0x0002, Word},
    0xcdb6: {"_BUFFER", 0x0002, WordDef},
    0xcdc1: {"BUFFER", 0x0002, Word},
    0xce01: {"_BLOCK", 0x0002, WordDef},
    0xce0b: {"BLOCK", 0x0002, Word},
    0xce61: {"_FLUSH", 0x0002, WordDef},
    0xce6b: {"FLUSH", 0x0002, Word},
    0xce8d: {"_DUMP", 0x0002, WordDef},
    0xce96: {"DUMP", 0x0002, Word},
    0xcece: {"_PLINE", 0x0002, WordDef},
    0xced9: {"PLINE", 0x0002, Word},
    0xcef3: {"_DOTLINE", 0x0002, WordDef},
    0xcefd: {"DOTLINE", 0x0002, Word},
    0xcf07: {"_GTLINE", 0x0002, WordDef},
    0xcf11: {"GTLINE", 0x0002, Word},
    0xcf36: {"_FMESSAGE", 0x0002, WordDef},
    0xcf42: {"FMESSAGE", 0x0002, Word},
    0xcf92: {"_LOAD", 0x0002, WordDef},
    0xcf9b: {"LOAD", 0x0002, Word},
    0xcfc3: {"_ARROW", 0x0002, WordDef},
    0xcfcb: {"ARROW", 0x0002, Word},
    0xcfe6: {"_SUBBCD", 0x0002, WordDef},
    0xcfef: {"SUBBCD", 0x0002, Word},
    0xd001: {"_BBUF", 0x0002, WordDef},
    0xd00b: {"BBUF", 0x0002, Word},
    0xd00f: {"_BSCR", 0x0002, WordDef},
    0xd019: {"BSCR", 0x0002, Word},
    0xd01d: {"_RW", 0x0002, WordDef},
    0xd025: {"RW", 0x0002, Word},
    0xd02f: {"_DISK", 0x0002, WordDef},
    0xd038: {"_SELECT", 0x0002, WordDef},
    0xd043: {"_DREAD", 0x0002, WordDef},
    0xd04d: {"_DWRITE", 0x0002, WordDef},
    0xd058: {"_INIT", 0x0002, WordDef},
    0xd061: {"_SEEK", 0x0002, WordDef},
    0xd06a: {"_TICK", 0x0002, WordDef},
    0xd070: {"TICK", 0x0002, Word},
	0xd080: {"_HC", 0x0002, WordDef},
	0xd088: {"HC", 0x0002, Word},
    0xd0b4: {"_HWORD", 0x0002, WordDef},
    0xd0be: {"HWORD", 0x0002, Word},
    0xd106: {"_QKERNEL", 0x0002, WordDef},
    0xd112: {"QKERNEL", 0x0002, Word},
    0xd13d: {"_AUTOSTART", 0x0002, WordDef},
    0xd14b: {"AUTOSTART", 0x0002, Word},
    0xd17c: {"_FORGET", 0x0002, WordDef},
    0xd187: {"FORGET", 0x0002, Word},
	0xd21e: {"_BEGIN", 0x0002, WordDef},
    0xd228: {"BEGIN", 0x0002, Word},
	0xd232: {"_FENDIF", 0x0002, WordDef},
    0xd23c: {"FENDIF", 0x0002, Word},
    0xd250: {"_FTHEN", 0x0002, WordDef},
    0xd259: {"FTHEN", 0x0002, Word},
    0xd25f: {"_FDO", 0x0002, WordDef},
    0xd266: {"FDO", 0x0002, Word},
    0xd272: {"_LOOP", 0x0002, WordDef},
    0xd27b: {"LOOP", 0x0002, Word},
    0xd289: {"_PLOOP", 0x0002, WordDef},
    0xd293: {"PLOOP", 0x0002, Word},
	0xd2a1: {"_FUNTIL", 0x0002, WordDef},
    0xd2ab: {"FUNTIL", 0x0002, Word},
	0xd2b9: {"_FEND", 0x0002, WordDef},
    0xd2c1: {"FEND", 0x0002, Word},
	0xd2c7: {"_AGAIN", 0x0002, WordDef},
    0xd2d1: {"AGAIN", 0x0002, Word},
	0xd2df: {"_FREPEAT", 0x0002, WordDef},
    0xd2ea: {"FREPEAT", 0x0002, Word},
	0xd2fc: {"_FIF", 0x0002, WordDef},
	0xd303: {"FIF", 0x0002, Word},
	0xd313: {"_FELSE", 0x0002, WordDef},
	0xd31c: {"FELSE", 0x0002, Word},
	0xd336: {"_FWHILE", 0x0002, WordDef},
	0xd340: {"FWHILE", 0x0002, Word},
    0xd348: {"_SPACES", 0x0002, WordDef},
    0xd353: {"_LTNUM", 0x0002, WordDef},
    0xd35a: {"_NUMGT", 0x0002, WordDef},
    0xd361: {"_SIGN", 0x0002, WordDef},
    0xd36a: {"_NUM", 0x0002, WordDef},
    0xd370: {"_NUMS", 0x0002, WordDef},
    0xd377: {"_DDOTR", 0x0002, WordDef},
    0xd37f: {"_DDOT", 0x0002, WordDef},
    0xd386: {"_DOTR", 0x0002, WordDef},
    0xd38d: {"_DOT", 0x0002, WordDef},
    0xd393: {"_Q", 0x0002, WordDef},
    0xd399: {"_FLIST", 0x0002, WordDef},
    0xd3a2: {"FLIST", 0x0002, Word},
    0xd3e4: {"_INDEX", 0x0002, WordDef},
    0xd3ee: {"INDEX", 0x0002, Word},
    0xd453: {"_VLIST", 0x0002, WordDef},
    0xd45d: {"VLIST", 0x0002, Word},
    0xd499: {"_MON", 0x0002, WordDef},
    0xd4a1: {"MON", 0x0002, Word},
    0xd4a7: {"_DOTS", 0x0002, WordDef},
    0xd4ae: {"DOTS", 0x0002, Word},
    0xd4e7: {"_CCON", 0x0002, WordDef},
    0xd4f1: {"CCON", 0x0002, Word},
	0xd5e6: {"_SCDR", 0x0002, WordDef},
	0xd5ef: {"SCDR", 0x0002, Word},

	0xd5f3: {"QQQ", 0x0001, Bytes},
	
	0xd5f4: {"_MEMTOP", 0x0002, WordDef},
    0xd5ff: {"MEMTOP", 0x0002, Word},
    0xd615: {"_CASEPAD", 0x0001, Bytes},
    0xd616: {"_CASE", 0x0002, WordDef},
    0xd620: {"CASE", 0x0002, Word},
    0xd63a: {"_EECSTOR", 0x0002, WordDef},
    0xd643: {"_BANKCSTOR", 0x0002, WordDef},
    0xd64e: {"_BANKCAT", 0x0002, WordDef},
    0xd659: {"_BANKEECSTOR", 0x0002, WordDef},
    0xd666: {"_BANKEXECUTE", 0x0002, WordDef},
    0xd676: {"_FMTRK", 0x0002, WordDef},
    0xd680: {"FMTRK", 0x0002, Word},
    0xd7c6: {"_FORMAT", 0x0002, WordDef},
    0xd7d1: {"FORMAT", 0x0002, Word},
    0xd7ff: {"_DUMP", 0x0002, WordDef},
    0xd809: {"DUMP", 0x0002, Word},
    0xd83f: {"_ADMP", 0x0002, WordDef},
    0xd848: {"ADMP", 0x0002, Word},
    0xd891: {"CODE1", 0x0002, Word},
	0xd89b: {"CODE2", 0x0002, Word},
	0xd8ca: {"NAMES", 0x0011, String},
	0xd8db: {"Z1", 0x0001, Bytes},
	0xd8dc: {"CRIGHT", 0x0018, String},
    0xd8f4: {"_N", 0x0002, WordDef},
    0xd8fa: {"N", 0x0002, Word},
    0xd8fe: {"_IP", 0x0002, WordDef},
    0xd905: {"IP", 0x0002, Word},

    0xd909: {"_W", 0x0002, WordDef},
    0xd90f: {"W", 0x0002, Word},
    0xd913: {"_UP", 0x0002, WordDef},
    0xd91a: {"UP", 0x0002, Word},
    0xd91e: {"_XSAVE", 0x0002, WordDef},
    0xd928: {"XSAVE", 0x0002, Word},
    0xd92c: {"_NEXT", 0x0002, WordDef},
    0xd935: {"NEXT", 0x0002, Word},
    0xd939: {"_PUSH", 0x0002, WordDef},
    0xd942: {"PUSH", 0x0002, Word},
    0xd946: {"_PUT", 0x0002, WordDef},
    0xd94e: {"PUT", 0x0002, Word},
    0xd952: {"_POP", 0x0002, WordDef},
    0xd95a: {"POP", 0x0002, Word},
    0xd95e: {"_POPTWO", 0x0002, WordDef},
    0xd969: {"POPTWO", 0x0002, Word},
    0xd96d: {"_PUSH0A", 0x0002, WordDef},
    0xd978: {"PUSH0A", 0x0002, Word},
    0xd97c: {"_PUT0A", 0x0002, WordDef},
    0xd986: {"PUT0A", 0x0002, Word},
    0xd98a: {"_BINARY", 0x0002, WordDef},
    0xd995: {"BINARY", 0x0002, Word},
    0xd999: {"_SETUP", 0x0002, WordDef},
    0xd9a3: {"SETUP", 0x0002, Word},
	0xd9a7: {"UNK1", 0x0020, Bytes},
    0xd9c7: {"UNK2", 0x0002, Word},
    0xd9cf: {"DOTA", 0x0002, WordDef},
    0xd9ee: {"UNK3", 0x0002, Word},
    0xd9fa: {"UNK4", 0x0002, Word},
    0xda06: {"UNK5", 0x0002, Word},
    0xda12: {"UNK6", 0x0002, Word},
    0xda1e: {"UNK7", 0x0002, Word},
    0xda36: {"UNK8", 0x0002, Word},
    0xda3e: {"_SECC", 0x0002, WordDef},
    0xda46: {"SECC", 0x0002, Word},
    0xda4e: {"RP", 0x0002, Word},
    0xda60: {"UNK9", 0x0002, Word},
    0xdb1c: {"_BRKC", 0x0002, WordDef},
    0xdb25: {"BRKC", 0x0002, Word},
    // 0xdc42: {"OP", 0x0002, WordDef},
    0xdde9: {"UNKA_", 0x0001, Bytes},
    0xddea: {"_SMBC", 0x0002, WordDef},
    0xddf3: {"SMBC", 0x0002, Word},
    0xde22: {"_RMBC", 0x0002, WordDef},
    0xde2b: {"RMBC", 0x0002, Word},
    0xde70: {"_BITCLR", 0x0002, WordDef},
    0xde7b: {"BITCLR", 0x0002, Word},
    0xdea2: {"PADA2", 0x0001, Bytes},
    0xdea3: {"_FUNTIL", 0x0002, WordDef},
    0xdeae: {"FUNTIL", 0x0002, Word},
    0xdec4: {"_FWHILE", 0x0002, WordDef},
    0xdecf: {"FWHILE", 0x0002, Word},
    0xdedd: {"_AGAIN", 0x0002, WordDef},
    0xdee8: {"AGAIN", 0x0002, Word},
    0xdef2: {"_FREPEAT", 0x0002, WordDef},
    0xdefe: {"FREPEAT", 0x0002, Word},
    0xdf18: {"_FIF", 0x0002, WordDef},
    0xdf20: {"FIF", 0x0002, Word},
    0xdf2e: {"_FENDIF", 0x0002, WordDef},
    0xdf39: {"FENDIF", 0x0002, Word},
    0xdf5b: {"_THEN", 0x0002, WordDef},
    0xdf65: {"THEN", 0x0002, Word},
    0xdf6b: {"_FELSE", 0x0002, WordDef},
    0xdf75: {"FELSE", 0x0002, Word},
    0xdf95: {"_NOT", 0x0002, WordDef},
    0xdf9d: {"NOT", 0x0002, Word},
    0xdfa5: {"_CS", 0x0002, WordDef},
    0xdfac: {"CS", 0x0002, Word},
	0xdfb0: {"_VS", 0x0002, WordDef},
    0xdfb7: {"VS", 0x0002, Word},
	0xdfbb: {"_VS1", 0x0002, WordDef},
	0xdfc2: {"VS1", 0x0002, Word},
	0xdfc6: {"_VS2", 0x0002, WordDef},
	0xdfcd: {"VS2", 0x0002, Word},
    0xdfd1: {"_ENDCODE", 0x0002, WordDef},
    0xdfde: {"ENDCODE", 0x0002, Word},

	0xdff0: {"_TASK", 0x0002, WordDef},
	0xdff9: {"TASK", 0x0002, Word},

	0xdffd: {"PADDINGD", 0x0002, Bytes}, 

}

var f *os.File
var err error
var b byte
var w int
var a int
var addr int
var blockdata data
var dolabel bool
var lastword string // Bit of a cheat, but name of last word

var indXCount = 0
var indYCount = 0

var printaddr = true
var gosrc *os.File

func praddr() {
	 praddra(addr)
}

func praddra(a int) {
	if printaddr {
	   fmt.Printf("%04x: ", a)
	}
}

func prbyte() {
	label, ok := datalist[int(b)]
	if ok {
		fmt.Printf("%s", label.label)
	} else {
		label, ok = kernel_datalist[int(b)]
		if ok {
			fmt.Printf("K%s", label.label)
		} else {
			fmt.Printf("$%02x", b)
		}
	}
}

func prwordw(w int) {
	label, ok := datalist[w]
	if ok {
	   fmt.Printf("%s", label.label)
	} else {
		label, ok = kernel_datalist[w]
		if ok {
			fmt.Printf("K%s", label.label)
		} else {
			label, ok = kernel_datalist[w-2]
			if ok {
				fmt.Printf("K%s+2", label.label)
			} else {
				fmt.Printf("$%04x", w)
			}
		}
	}
}

func prword() {
	prwordw(w)
}

func offset(b byte) (int) {
	if b > 0x7f {
		return addr + 1 + int(b) - 0x100
	} else {
		return addr + 1 + int(b)
	}
}

func outln() {
	if blockdata.dt == NextWord {
		if ((b & 0xf0) == 0x80) {
			blockdata.dt = WordDef
		} else {
			blockdata.dt = Word
		}
	}
	if dolabel {
		if blockdata.dt == Word {
			for i := 0; i < 3; i++ {
				praddr(); fmt.Printf(";;\n")
			}
		}
		if blockdata.dt != WordDef {
			praddr(); fmt.Printf("%s: ", blockdata.label)
		}
	} else if datalist[addr].dt == Label { 
	    praddr(); fmt.Printf(";\n")
	    praddr(); fmt.Printf("%s: ", datalist[addr].label)
	} else if blockdata.dt != WordDef {
	  	praddr()
		fmt.Printf("          ")
	}
	
	switch blockdata.dt {
	case Bytes:
		for i := 0; i < blockdata.length; i++ {
			if (i % 16) == 0 {
				if i != 0 {
					fmt.Printf("\n")
					praddr();
				}
				fmt.Printf("        data.b $%02x", b)
			} else {
				fmt.Printf(", $%02x", b)
			}
			if i < blockdata.length-1 { next() }
		}
		fmt.Printf("\n")
		blockdata = undefined
	case String:
		fmt.Printf("data.b \"")
		for i := 0; i < blockdata.length; i++ {
			if b == 0x22 {
				fmt.Printf("\\\"")
			} else {
				fmt.Printf("%s", string(b))
			}
			if i < blockdata.length-1 { next() }
		}			
		fmt.Printf("\"\n")
	case Vector:
		fmt.Printf("        data.w ")
		word()
		prword()
		fmt.Println()
	case Address:
		fmt.Printf("data.w ")
		word()
		prword()
		fmt.Println()
	case Word:
		fmt.Printf("        data.w ")
		word()
		str := ""
		label, ok := datalist[w]
		if ok {
			str = label.label
		} else {
			label, ok = kernel_datalist[w]
			if ok {
				str = "K" + label.label
			} else {
				label, ok = kernel_datalist[w-2]
				if ok {
					str = "K" + label.label + "+2"
				} else {
					str = label.label
				}
			}
		}

		if ok {
			fmt.Printf("%s\n", str)
			if str == "KCLIT" {
				next()
				praddr()
				fmt.Printf("                  data.b $%02x\n", b)
			} else if str == "KBRAN" {
				next()
				praddr()
			    word()
				fmt.Printf("                  data.w $%04x\n", w)
			} else if str == "KZBRAN" {
				next()
			    praddr()
				word()
				fmt.Printf("                  data.w $%04x\n", w)
			} else if str == "KDOUSE" {
				next()
				praddr()
				fmt.Printf("                  data.b $%02x\n", b)
				blockdata.dt = WordDef
			} else if str == "KDOCON" {
				next()
				praddr()
				word()
				fmt.Printf("                  data.w $%04x\n", w)
				blockdata.dt = WordDef
			} else if str == "KPDOTQ" {
			    next()
				len := int(b)
				praddr()
				fmt.Printf("                  data.b $%02x, \"", b)
				next()
				for i := 0; i < len; i++ {
					fmt.Printf("%s", string(b))
					if i < len-1 { next() }
				}
				fmt.Printf("\"\n")
			} else if str == "KSEMIS" {
				blockdata.dt = NextWord
			}
		} else {
			prword()
			fmt.Println()
		}
		if dolabel && (w > addr) && (w < addr + 8) { // If we are in a close range assume code
			blockdata.dt = Code
		}
	case WordDef:
		saveaddr := addr
		def := b
		len := int(def) & 0xf
 		str := ""
		encstr := ""
		for i:=0; i<len; i++ {
			next()
			str += string(b & 0x7f)
			if (b & 0x7f) == 0x22 {
				encstr += "\\\""
			} else if (b & 0x7f) == 0x00 {
				encstr += "\\0"
			} else {
				encstr += string(b & 0x7f)
			}
		}
		next()
		praddra(saveaddr); fmt.Printf(";;\n")
		praddra(saveaddr); fmt.Printf(";;    %s\n", str)
		praddra(saveaddr); fmt.Printf(";;\n")
		 // def should have MSB set
		praddra(saveaddr); prwordw(saveaddr);
		fmt.Printf("             text.7 $%02x, \"%s\"\n", def, encstr)

		fmt.Fprintf(gosrc, "    0x%04x: {\"%s\", 0x0002, WordDef},\n", saveaddr+8, str)

		// link field
		praddr()
		word()
		fmt.Printf("                  data.w ")
		prword()
		fmt.Printf("    ; link to %s\n", lastword)
		lastword = str

		// pfaptr
		next()
		praddr()
		word()
		fmt.Printf("                  data.w ")
		prword()
		fmt.Printf("    ; PFAPTR\n")

		if w == (addr - 1) {
			blockdata.dt = Word
		} else if w == (addr + 3) {
			blockdata.dt = Word
		}
	case Code:
		opcode := instr[b].opcode
		fmt.Printf("%s ", opcode)
		switch instr[b].mode {
		case Immediate: // 2 bytes
			next()
			fmt.Printf("#$%02x\n", b)
		case Absolute: // 3 bytes
			next()
			word()
			prword()
			fmt.Println()
		case ZeroPage: // 2 bytes
			next()
			prbyte()
			fmt.Println()
		case Accumulator: // 1 byte
			fmt.Printf("A\n")
		case Implied: // 1 byte
			fmt.Printf("\n")
		case IndX: // 2 bytes
			next()
			fmt.Printf("(")
			prbyte()
			fmt.Printf(",X)\n")
			indXCount++
		case IndY: // 2 bytes
			next()
			fmt.Printf("(")
			prbyte()
			fmt.Printf("),Y\n")
			indYCount++
		case ZeroPageX: // 2 bytes
			next()
			prbyte()
			fmt.Printf(",X\n")
		case ZeroPageY: // 2 bytes
			next()
			fmt.Printf("(")
			prbyte()
			fmt.Printf(",Y)\n")
		case AbsoluteX: // 3 bytes
			next()
			word()
			prword()
			fmt.Printf(",X\n")
		case AbsoluteY: // 3 bytes
			next()
			word()
			prword()
			fmt.Printf(",Y\n")
		case Relative: // 2 bytes
			next()
			fmt.Printf("$%04x\n", offset(b))
		case Indirect: // 3 bytes
			next()
			word()
			fmt.Printf("(")
			prword()
			fmt.Printf(")\n", w)
		case BitAddress: // 3 bytes
			next()
			prbyte()
			next()
			fmt.Printf(", $%04x    ;$%02x\n", offset(b), b)
		}
	}
	dolabel = false
}

func next() {
	buf := make([]byte, 1)
	_, err = f.Read(buf)
	addr = addr + 1
	if err == nil { b = buf[0] }

}

func word() {
	w = int(b)
	next()
	w = w + int(b) << 8
}

func main()  {
	gosrc, _ = os.Create("cmd/gen.go")
	defer gosrc.Close()
	
	// org := 0xf000
	// rom := "roms/R65FK3P.BIN"
	// datalist = kernel_datalist
	
	org := 0xc000
	rom := "roms/R65FR3P.BIN"
	datalist = development_datalist
	lastword = "previous. Last link marked by zero."
	printaddr = false
	
	f, err = os.Open(rom)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	// Header
	fmt.Println("        cpu := \"R65C02\"\n\n")
	fmt.Printf("        org := $%04x\n\n", org)
	
	// Output registers
	keys := make([]int, 0, len(kernel_datalist))
 
    for k := range kernel_datalist{
        keys = append(keys, k)
    }
	sort.Slice(keys, func(i, j int) bool {
		return keys[i] < keys[j]
	})
    for _, key := range keys {
		val := kernel_datalist[key]
		//if val.dt == Register {
			fmt.Printf("        K%s := $%04x\n", val.label, key)
		//}
	}
	fmt.Printf("\n\n")
	
	addr = org - 1
	next()
	for err == nil {
		addrdata, ok := datalist[addr]
		if ok && addrdata.dt != Label {
			blockdata = addrdata
			dolabel = true
			//		} else {
			//			blockdata = undefined
			//			dolabel = true
		}
		//		fmt.Printf("$%04x: %s\n", addr, blockdata.label)
		outln()
		next()
	} 
	if printaddr {
	   fmt.Println(err)
	   	fmt.Printf("IndX: %d IndY: %d\n", indXCount, indYCount)
	}
}

