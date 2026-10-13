********************************************************************************
* Console driver for the Tang Nano 20K 65C816 board                            *
*                                                                              *
* Taken from MiniMon's console.asm. Output goes to both the serial port and    *
* the 80x30 text display; input comes from the serial port or an ADB keyboard, *
* whichever has something first.                                               *
*                                                                              *
* The display side understands CR, LF, BS and the VT100 cursor sequences       *
* ESC [ A/B/C/D and ESC [ K. The screen is 30 rows of 80 cells at $700000, two *
* bytes per cell: character then attribute (low nibble ink, high nibble        *
* paper). The cursor is a cell with its attribute inverted. Scrolling and      *
* clearing are done by the blitter, whose addresses are in pixels (byte        *
* address times two).                                                          *
*                                                                              *
* The driver itself runs with an 8 bit accumulator and 16 BIT INDEX REGISTERS; *
* the Forth runs with both 8 bit. CON_INIT, CON_EMIT and CON_KEY are the only  *
* entry points the Forth uses, and they switch the index width on the way in   *
* and restore it on the way out.                                               *
*                                                                              *
* Zero page $E0-$F9 is used. The Forth's data stack tops out at $C2 and its    *
* return stack is in page one on this machine, so $C2-$FF is free.             *
********************************************************************************

 		ser_base = $0200
		ser_data = ser_base + 0
		ser_status = ser_base + 1	;bit 3 receiver full, bit 4 transmitter empty
		ser_command = ser_base + 2
		ser_control = ser_base + 3

	;; Entry points, called with 8 bit registers.
CON_INIT:	php
		rep #$10
		longi=on
		jsr con_init
		plp
		rts

	;; Character in A. Preserves A, X and Y.
CON_EMIT:	php
		rep #$10
		jsr con_putc
		plp
		rts

	;; Waits for a character and returns it in A. Preserves X and Y.
CON_KEY:	php
		rep #$10
		jsr con_getc
		plp
		rts

	;; Character in A
ser_putc	pha
ser_putc0	lda ser_status
        	and #$10
        	beq ser_putc0
		pla
        	sta ser_data
		rts

		vid_mode  = $0380	;bit 0: 1 = text mode

		con_ptr   = $00e0	;24 bit pointer to the screen
		con_col   = $00e6	;16 bit, 0..79
		con_row   = $00e8	;16 bit, 0..29
		con_pos   = $00ea	;16 bit offset of the cursor cell
		con_tmp   = $00ec	;16 bit scratch
		con_state = $00ee	;0 normal, 1 after ESC, 2 after ESC [
		con_char  = $00ef

		kbd_pend  = $00f0	;bytes of an ESC [ x sequence still to return
		kbd_final = $00f1	;its final letter
		kbd_next  = $00f2	;second event of a packet, $ff if none
		kbd_mods  = $00f3	;modifier keys held, kbd_m_* bits
		kbd_busy  = $00f4	;non-zero: a poll is in flight
		kbd_code  = $00f6	;16 bit: key code, for use as an index
		kbd_event = $00f8

		blt_base   = $03c0	;blitter registers, 19 bytes
		blt_ctrl   = blt_base + $12	;read: bit 7 = busy

		adb_base   = $0280
		adb_cmd    = adb_base + 0	;write starts a transaction
		adb_status = adb_base + 1	;busy, done, timeout, srq, count[3:0]
		adb_ctrl   = adb_base + 3	;read: bit 0 = collision
		adb_data   = adb_base + 8

		adb_talk0  = $2c	;device 2, Talk, register 0

		kbd_m_lshift = $01
		kbd_m_rshift = $02
		kbd_m_lctrl  = $04
		kbd_m_rctrl  = $08
		kbd_m_caps   = $10

		con_cols  = 80
		con_rows  = 30
		con_rowb  = con_cols*2		;bytes per row
		con_size  = con_rows*con_rowb
		con_attr  = $07			;grey on black
		con_blank = con_attr*256+$20	;a blank cell, as a word

	;; Clears the screen, homes the cursor and switches the display to text.
con_init	lda #$ff
		sta ser_status		;programmed reset
		lda #$02
		sta ser_command		;no receive interrupt: the Forth runs with IRQs on
		stz con_ptr
		stz con_ptr+1
		stz con_state
		stz kbd_pend
		stz kbd_mods
		stz kbd_busy
		stz kbd_code+1		;the index's high byte is always 0
		lda #$ff
		sta kbd_next
		lda #$70
		sta con_ptr+2
		rep #$20
		longa=on
		stz con_col
		stz con_row
		sep #$20
		longa=off
		ldy #0			;blank the top row by hand...
		jsr con_clrrow
		ldx #blt_spread		;...and have the blitter copy it down
		jsr con_blit
		lda #1
		sta vid_mode
		jsr con_setpos
		jmp con_cursor

	;; Waits for a character from the serial port or the keyboard and
	;; returns it in A. Preserves X and Y, as ser_getc does.
con_getc	phx
		phy
		jsr con_get
		ply
		plx
		rts

con_get		lda kbd_pend		;part-way through a cursor key?
		beq con_get0
		dec kbd_pend
		beq con_get_fin
		lda #'['
		rts
con_get_fin	lda kbd_final
		rts

con_get0	lda kbd_next		;second event of the last packet
		cmp #$ff
		beq con_get1
		pha
		lda #$ff
		sta kbd_next
		pla
		jsr kbd_key
		bcc con_get0
		rts

con_get1	lda ser_status		;serial first: it cannot wait
		and #$08
		beq con_get2
		lda ser_data
		rts

con_get2	lda adb_status
		bmi con_get1		;transaction in flight
		lda kbd_busy
		beq con_get3
		stz kbd_busy		;one has just finished: is it a key packet?
		lda adb_status
		and #$6f		;done, timeout, count
		cmp #$42		;done, no timeout, exactly two bytes
		bne con_get3
		lda adb_ctrl
		and #$01		;collision: not to be trusted
		bne con_get3
		lda adb_data+1
		sta kbd_next
		lda adb_data
		jsr kbd_key
		bcc con_get0
		rts
con_get3	lda #adb_talk0		;start the next poll
		sta adb_cmd
		inc kbd_busy
		bra con_get1

	;; Handles one key event (bit 7 set = key up, low 7 bits = key code).
	;; Returns carry set and a character in A if it produced one.
kbd_key		sta kbd_event
		and #$7f
		sta kbd_code
		cmp #$38
		bne kbd_key1
		lda #kbd_m_lshift
		bra kbd_mod
kbd_key1	cmp #$7b
		bne kbd_key2
		lda #kbd_m_rshift
		bra kbd_mod
kbd_key2	cmp #$36
		bne kbd_key3
		lda #kbd_m_lctrl
		bra kbd_mod
kbd_key3	cmp #$7d
		bne kbd_key4
		lda #kbd_m_rctrl
		bra kbd_mod
kbd_key4	cmp #$39
		bne kbd_key5
		lda #kbd_m_caps		;the key latches: down = on, up = off

	;; A modifier: set its bit on key down, clear it on key up.
kbd_mod		bit kbd_event
		bmi kbd_mod_up
		ora kbd_mods
		sta kbd_mods
		bra kbd_none
kbd_mod_up	eor #$ff
		and kbd_mods
		sta kbd_mods
kbd_none	clc
		rts

kbd_key5	lda kbd_event
		bmi kbd_none		;other keys only act on the way down
		ldx kbd_code
		lda kbd_mods
		and #kbd_m_lshift | kbd_m_rshift
		bne kbd_key6
		lda.w kbd_plain,x
		bra kbd_key7
kbd_key6	lda.w kbd_shift,x
kbd_key7	beq kbd_none		;no character on this key
		bpl kbd_key8
		and #$7f		;cursor key: ESC now, then [ and the letter
		sta kbd_final
		lda #2
		sta kbd_pend
		lda #$1b
		sec
		rts

kbd_key8	sta kbd_event		;reuse as the character being built
		ora #$20
		cmp #'a'
		bcc kbd_key9
		cmp #'z'+1
		bcs kbd_key9
		lda kbd_mods		;a letter: caps lock swaps its case
		and #kbd_m_caps
		beq kbd_key9
		lda kbd_event
		eor #$20
		sta kbd_event
kbd_key9	lda kbd_mods
		and #kbd_m_lctrl | kbd_m_rctrl
		beq kbd_key10
		lda kbd_event
		cmp #$40
		bcc kbd_key10		;control only applies to @ A-Z [ \ ] ^ _ etc.
		and #$1f
		sec
		rts
kbd_key10	lda kbd_event
		sec
		rts

	;; Character in A. Preserves A, X and Y, as ser_putc does.
con_putc	jsr ser_putc
		pha
		phx
		phy
		jsr con_vput
		ply
		plx
		pla
		rts

	;; Display side of con_putc.
con_vput	sta con_char
		jsr con_cursor		;cursor off
		lda con_state
		beq con_norm
		cmp #1
		beq con_esc1

		;; In a sequence: parameter bytes, then a final byte >= $40.
		lda con_char
		cmp #$40
		bcc con_done
		stz con_state
		cmp #'A'
		beq con_up
		cmp #'B'
		beq con_down
		cmp #'C'
		beq con_right
		cmp #'D'
		beq con_left
		cmp #'K'
		bne con_done
		jsr con_clreol
		bra con_done

con_esc1	stz con_state
		lda con_char
		cmp #'['
		bne con_done
		lda #2
		sta con_state
		bra con_done

con_up		lda con_row
		beq con_done
		dec con_row
		bra con_done

con_down	lda con_row
		cmp #con_rows-1
		beq con_done
		inc con_row
		bra con_done

con_left	lda con_col
		beq con_done
		dec con_col

con_done	jsr con_setpos
		jmp con_cursor		;cursor back on

con_norm	lda con_char
		cmp #$1b
		bne con_norm1
		lda #1
		sta con_state
		bra con_done
con_norm1	cmp #$0d
		bne con_norm2
		stz con_col
		bra con_done
con_norm2	cmp #$0a
		beq con_lf
		cmp #$08
		beq con_left
		cmp #$20
		bcc con_done		;other control characters do nothing
		ldy con_pos
		sta [con_ptr],y

con_right	inc con_col
		lda con_col
		cmp #con_cols
		bne con_done
		stz con_col		;wrap onto the next line

con_lf		lda con_row
		cmp #con_rows-1
		beq con_lf1
		inc con_row
		bra con_done
con_lf1		jsr con_scroll
		bra con_done

	;; Sets con_pos from con_row and con_col: row * 160 + col * 2.
con_setpos	rep #$20
		longa=on
		lda con_row
		asl a
		asl a
		asl a
		asl a
		asl a
		sta con_tmp		;row * 32
		asl a
		asl a			;row * 128
		clc
		adc con_tmp
		adc con_col
		adc con_col
		sta con_pos
		sep #$20
		longa=off
		rts

	;; Inverts the attribute of the cell at con_pos.
con_cursor	ldy con_pos
		iny
		lda [con_ptr],y
		eor #$77
		sta [con_ptr],y
		rts

	;; Blanks from the cursor to the end of its row.
con_clreol	rep #$20
		longa=on
		lda con_pos
		sec
		sbc con_col
		sbc con_col		;start of this row
		clc
		adc #con_rowb
		sta con_tmp		;start of the next
		ldy con_pos
		lda #con_blank
con_clreol0	sta [con_ptr],y
		iny
		iny
		cpy con_tmp
		bne con_clreol0
		sep #$20
		longa=off
		rts

	;; Moves everything up one row and blanks the last.
con_scroll	ldx #blt_scroll
		jsr con_blit
		ldy #con_size-con_rowb

	;; Blanks the row whose offset is in Y.
con_clrrow	rep #$20
		longa=on
		tya
		clc
		adc #con_rowb
		sta con_tmp		;where the row ends
		lda #con_blank
con_clrrow0	sta [con_ptr],y
		iny
		iny
		cpy con_tmp
		bne con_clrrow0
		sep #$20
		longa=off
		rts

	;; Loads the 19 blitter registers from the block at X -- the last is the
	;; control register, which starts it -- and waits for it to finish.
con_blit	ldy #0
con_blit0	lda.w 0,x
		sta.w blt_base,y
		inx
		iny
		cpy #$13
		bne con_blit0
con_blit1	lda blt_ctrl
		bmi con_blit1
		rts

	;; Blitter register blocks: SRC(3) - DST(3) - SRC_STRIDE(2) DST_STRIDE(2)
	;; WIDTH(2) HEIGHT(2) OP COLOUR CONTROL. A row is 320 pixels.

	;; Scroll: rows 1-29 to rows 0-28, top down, so each row is read
	;; before it is overwritten.
blt_scroll	data.b $40,$01,$e0,$00
		data.b $00,$00,$e0,$00
		data.b $40,$01,$40,$01
		data.b $40,$01,con_rows-1,$00
		data.b $03,$00,$01

	;; Clear: row 0 to row 1, then row 1 to row 2, and so on down. Here the
	;; overlap is the point -- each line copies the one just written.
blt_spread	data.b $00,$00,$e0,$00
		data.b $40,$01,$e0,$00
		data.b $40,$01,$40,$01
		data.b $40,$01,con_rows-1,$00
		data.b $03,$00,$01

********************************************************************************
* ADB key code -> character tables, US layout                                  *
*                                                                              *
* Indexed by the 7 bit key code. 0 means the key produces nothing (modifiers   *
* are handled before the lookup). A value with bit 7 set is a cursor key: the  *
* low 7 bits are the final letter of the sequence ESC [ <letter>.              *
*                                                                              *
* Return and keypad Enter give CR, Delete gives $7F (which readline treats as  *
* backspace) and forward Delete gives ctrl-D, readline's delete-forward.       *
********************************************************************************

kbd_plain
		data.b $61,$73,$64,$66,$68,$67,$7a,$78	;$00
		data.b $63,$76,$00,$62,$71,$77,$65,$72	;$08
		data.b $79,$74,$31,$32,$33,$34,$36,$35	;$10
		data.b $3d,$39,$37,$2d,$38,$30,$5d,$6f	;$18
		data.b $75,$5b,$69,$70,$0d,$6c,$6a,$27	;$20
		data.b $6b,$3b,$5c,$2c,$2f,$6e,$6d,$2e	;$28
		data.b $09,$20,$60,$7f,$00,$1b,$00,$00	;$30
		data.b $00,$00,$00,$c4,$c3,$c2,$c1,$00	;$38
		data.b $00,$2e,$00,$2a,$00,$2b,$00,$00	;$40
		data.b $00,$00,$00,$2f,$0d,$00,$2d,$00	;$48
		data.b $00,$3d,$30,$31,$32,$33,$34,$35	;$50
		data.b $36,$37,$00,$38,$39,$00,$00,$00	;$58
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$60
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$68
		data.b $00,$00,$00,$00,$00,$04,$00,$00	;$70
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$78

kbd_shift
		data.b $41,$53,$44,$46,$48,$47,$5a,$58	;$00
		data.b $43,$56,$00,$42,$51,$57,$45,$52	;$08
		data.b $59,$54,$21,$40,$23,$24,$5e,$25	;$10
		data.b $2b,$28,$26,$5f,$2a,$29,$7d,$4f	;$18
		data.b $55,$7b,$49,$50,$0d,$4c,$4a,$22	;$20
		data.b $4b,$3a,$7c,$3c,$3f,$4e,$4d,$3e	;$28
		data.b $09,$20,$7e,$7f,$00,$1b,$00,$00	;$30
		data.b $00,$00,$00,$c4,$c3,$c2,$c1,$00	;$38
		data.b $00,$2e,$00,$2a,$00,$2b,$00,$00	;$40
		data.b $00,$00,$00,$2f,$0d,$00,$2d,$00	;$48
		data.b $00,$3d,$30,$31,$32,$33,$34,$35	;$50
		data.b $36,$37,$00,$38,$39,$00,$00,$00	;$58
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$60
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$68
		data.b $00,$00,$00,$00,$00,$04,$00,$00	;$70
		data.b $00,$00,$00,$00,$00,$00,$00,$00	;$78

		longi=off
