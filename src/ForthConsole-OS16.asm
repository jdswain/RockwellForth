********************************************************************************
* Console for OS16                                                             *
*                                                                              *
* OS16 runs the Forth as a command of its shell, in a Terminal window: the     *
* module Forth (OS16's app/forth/Forth.Mod) gives it a bank of its own, loads  *
* the image there and calls FENTER from the command's process. With OS16's     *
* banked direct page and stack (D's high byte the bank of both) the Forth's    *
* direct page is page 0 of its bank and its return stack page 1, and its data  *
* and program banks are that bank too, so the Forth runs at the T20K's         *
* addresses as it does on the board.                                           *
*                                                                              *
* The terminal is Forth.Mod's: os_call goes back to the process's own direct   *
* page and stack, as FENTER found them, calls Forth.Service and returns. KEY   *
* asks it for the next key, waiting; EMIT collects the output in out_buf,      *
* which is written to the terminal at a line feed, when it is full, and        *
* before a key is read or looked for. os_leave returns from FENTER: BYE, or a *
* key wanted after the end of the input (the terminal closed).                 *
*                                                                              *
* None of the code is written to: Service is reached by an RTL to its address, *
* which is data.                                                               *
*                                                                              *
* Control-C. When one is typed, Forth.Mod sets bit 7 of INTFLAG, which NEXT    *
* tests before every word, and NEXT runs BREAK (INTVEC): the stacks emptied,   *
* back to QUIT. So a loop that never reads a key is stopped too.               *
*                                                                              *
* CON_INIT, CON_EMIT, CON_KEY, CON_QTERM and CON_BYE are the entry points the  *
* Forth uses, called with 8 bit registers, as for the T20K's console.          *
* Zero page $E0 is used.                                                       *
********************************************************************************

	;; Forth.Mod's services, the number in A for os_call
		SV_KEY = 1		;the next key, waited for; $FFFF at the end of the input
		SV_OUT = 2		;out_buf written to the terminal
		SV_QUERY = 3		;not 0 if a key is waiting
		SV_BLOCK = 4		;os_arg: f, blk, addr: R/W on the blocks file; not 0 failed
		SV_USING = 5		;os_arg: a counted name: the blocks file; not 0 failed
		SV_INCLUDE = 6		;os_arg: a counted name, opened: its line buffer, 0 failed
		SV_LINE = 7		;its next line into the buffer: 0 at its end, then closed
		SV_RESET = 8		;the files being included closed, where they were said

		OUTSIZE = 128		;out_buf's size

		con_a = $00e0		;L506's character

	;; The link, at FORTH_BASE+$2008: Forth.Mod has these offsets (L...).
LINK:		data.w FENTER		;+0  the entry, for Forth.Mod's JSL
os_bd:		data.w 0		;+2  the Forth's D: its bank * 256 (page 0)
os_svc:		data.w 0, 0		;+4  Forth.Service: its address and bank
out_n:		data.b 0		;+8  the characters in out_buf
		data.b 0		;+9
os_res:		data.w 0		;+10 a service's result
		data.w INTFLAG		;+12 INTFLAG's address: Forth.Mod sets bit 7 at a Control-C
		data.w BUF_FIRST	;+14 the block buffers, written when the Forth leaves
		data.w BUF_LIMIT	;+16
os_arg:		data.w 0, 0, 0		;+18 a service's arguments: the data stack's top three
		fill.b 8, 0		;+24
out_buf:	fill.b OUTSIZE, 0	;+32 the output not yet written
		errorif LINK != FORTH_BASE+$2008, "the link is not at FORTH_BASE+$2008"
		errorif os_arg-LINK != 18, "the link's arguments are not at +18"
		errorif out_buf-LINK != 32, "the link's output is not at +32"

os_d:		data.w 0		;the process's D and S, as FENTER found them
os_s:		data.w 0
os_fs:		data.w 0		;the Forth's S during a service
os_n:		data.w 0		;the service

	;; Entry from Forth.Mod: a JSL from its process, 16 bit registers. The
	;; process's P, data bank and D are kept on its stack, which os_leave
	;; returns to. A cold start: Forth.Mod has zeroed the bank, CLD_WARM
	;; with it.
		longa=on
		longi=on
FENTER:		php
		phb
		phd
		phk
		plb			;the Forth's data bank
		tsc
		sta os_s
		tdc
		sta os_d
		sei			;D then S, nothing on the stack between
		lda os_bd
		tcd
		ldx #stack_base+$ff
		txs
		cli
		sep #$30
		longa=off
		longi=off
		jmp COLD+5

	;; Back to Forth.Mod, from FENTER, from anywhere in the Forth: its
	;; stack is left as it is.
os_leave:	rep #$30
		longa=on
		longi=on
		sei
		lda os_d
		tcd
		lda os_s
		tcs
		pld
		plb
		plp			;the process's P: its I, the widths
		rtl
		longa=off
		longi=off

	;; Service number A of Forth.Mod's, on the process's direct page and
	;; stack: Service(n, bank). Returns its result in A (os_res, 16 bits);
	;; X and Y are kept.
os_call:	php
		rep #$30
		longa=on
		longi=on
		phx
		phy
		and #$00ff
		sta os_n
		tsc
		sta os_fs
		sei
		lda os_d
		tcd
		lda os_s
		tcs
		cli
		phk			;the return, as a JSL leaves it
		per os_back-1
		sep #$20
		longa=off
		lda os_svc+2		;Service's address as an RTL takes it
		pha
		rep #$20
		longa=on
		lda os_svc
		dec a
		pha
		lda os_n
		sta $02			;Service(n, bank): oc816's R0 and R1
		lda os_bd+1
		and #$00ff
		sta $04
		pea $0000
		plb
		plb			;Oberon's data bank
		rtl
os_back:	rep #$30
		phk
		plb
		lda $02			;its result
		sta os_res
		sei
		lda os_bd
		tcd
		lda os_fs
		tcs
		cli
		ply
		plx
		plp
		longa=off
		longi=off
		lda os_res
		rts

	;; Entry points, called with 8 bit registers.
CON_INIT:	stz out_n
		rts

	;; Character in A, collected in out_buf. Preserves A, X and Y. A NUL
	;; (CR's last) is left out.
CON_EMIT:	cmp #0
		beq con_e2
		phx
		ldx out_n
		sta out_buf,x
		inx
		stx out_n
		cpx #OUTSIZE
		bcs con_e0
		cmp #$0a
		bne con_e1
con_e0:		jsr con_flush
con_e1:		plx
con_e2:		rts

	;; Waits for a key and returns it in A. Preserves X and Y. Backspace
	;; is Delete, which EXPECT erases with.
CON_KEY:	jsr con_flush
		lda #SV_KEY
		jsr os_call
		lda os_res+1
		bne con_gone		;the end of the input
		lda os_res
		cmp #$08
		bne con_k1
		lda #$7f
con_k1:		rts

	;; Service A with the data stack's top three cells (0,X to 5,X) as its
	;; arguments, the output written first: the result in os_res (and
	;; A). Preserves X and Y.
CON_SVC:	jsr con_flush
		pha
		rep #$20
		longa=on
		lda 0,x
		sta os_arg
		lda 2,x
		sta os_arg+2
		lda 4,x
		sta os_arg+4
		sep #$20
		longa=off
		pla
		jmp os_call

	;; A not 0 if a key is waiting. Preserves X and Y.
CON_QTERM:	jsr con_flush
		lda #SV_QUERY
		jsr os_call
		rts

	;; BYE: the line ended, and back to the shell
CON_BYE:	lda #$0d
		jsr CON_EMIT
		lda #$0a
		jsr CON_EMIT		;written, at the line feed
con_gone:	jmp os_leave

	;; out_buf written to the terminal, if there is anything in it.
	;; Preserves A, X and Y.
con_flush:	pha
		lda out_n
		beq con_f1
		lda #SV_OUT
		jsr os_call
		stz out_n
con_f1:		pla
		rts
