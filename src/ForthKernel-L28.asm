********************************************************************************
*                                                                              *
*                            Rockwell Forth Kernel                             *
*                                                                              *
*                      Based on FIG-FORTH with extensions.                     *
*                          L28 MCU Port                                        *
*                                                                              *
********************************************************************************
;
;                        Through the courtesy of
;
;                         FORTH INTEREST GROUP
;                            P.O. BOX  2154
;                         OAKLAND, CALIFORNIA
;                                94621
;
;
;                             Release 1.1
;
;                        with compiler security
;                                  and
;                        variable length names
;
;    Further distribution must include the above notice.
;    The FIG installation Manual is required as it contains
;    the model of FORTH and glossary of the system.
;    Available from FIG at the above address for **.** postpaid.
;
;    Translated from the FIG model by W.F. Ragsdale with input-
;    output given for the Rockwell System-65. Transportation to
;    other systems requires only the alteration of :
;                 XEMIT, XKEY, XQTER, XCR, AND RSLW
;
;    Equates giving memory assignments, machine
;    registers, and disk parameters.
;

; This version targets the L28 (Conexant) MCU. It uses the L28's Threaded
; Interpretive (TI) instructions for the inner interpreter and moves the
; data stack to page 2 indexed by Y, freeing X for general use.
;
; Key differences from the R65C19 version:
;   - I register replaces IP zero-page variable
;   - JPI dispatches words, TIP returns
;   - PHI/PLI replace manual IP push/pull
;   - LAN replaces LDA (IP),Y for inline byte fetch
;   - Y register is data stack pointer (was X)
;   - Data stack at $0200 (page 2), indexed by Y (was zero page, indexed by X)
;   - X is free for scratch and (zp),X indexing
;   - (zp,X) becomes (zp) plain indirect (no pre-indexing)
;   - (zp),Y becomes (zp),X post-indexed by X
;   - No XSAVE needed (X is free)
;   - JPI-threaded code (JTC): primitives have no CFA
;   - Colon defs use DV+PHI, constants use DV+JSR DOCON, etc.

	cpu := "RC19"			; L28 uses same instruction set identifier
	machine := "L2800"

	;; Console mode: 1 = keyboard matrix input, 0 = serial terminal input
	;; Change to 1 for console mode build.
	CONSOLE_MODE := 1

	message "Assembling Forth Kernel for L28 MCU"



* L28 Hardware Registers

	;; $00-$0F - internal ports

    	PortA := $0000
        PortB := $0001 			; Output only
        PortC := $0002
        PortD := $0003			; Complicated
        PortA_Dir := $0004
        PortB_Sel := $0005
        PortC_Dir := $0006
		PortE := $0007
		MOR := $0008				; Mask Option Register, read only
	PortE_Dir := $0008			; (write-only, shares addr with MOR)
	LPR := $0009				; Low Power Register
	EIR := $000a				; External Interrupt Register
	CIR := $000b				; Clear Interrupt Register

	;; PTG B
	PBM := $000c				; PTG B Mode
	PBB := $000d				; PTG B Buffer
	PBUL := $000e				; PTG B Upper Latch

	BSR0 := $0018
	BSR1 := $0019
	BSR2 := $001a
	BSR3 := $001b
	BSR4 := $001c
	BSR5 := $001d
	BSR6 := $001e
	BSR7 := $001f

	;; $10-$17 - Timer A/B
	TAM := $0010				; Timer A Mode
	TALL := $0011				; Timer A Lower Latch
	TAUL := $0012				; Timer A Upper Latch
	TBM := $0014				; Timer B Mode
	TBLL := $0015				; Timer B Lower Latch
	TBUL := $0016				; Timer B Upper Latch

	;; Legacy aliases (used in kernel code)
	LCBCLR := BSR4
	LCB := BSR6

	;; $20-$32 - Host/FIFO Interface

	;; Host General Purpose Mode
	FIFO_BUF := $0020			; TX/RX FIFO Buffer
	GPFS := $002e				; GP FIFO Status
	HHR := $002f				; Host Handshake Register
	TXFSR := $0030				; Transmitter FIFO Status
	RXFSR := $0031				; Receiver FIFO Status
	HCR := $0032				; Host Control Register

	;; Host 16550 Emulation Mode
	H_LSR := $0021				; Line Status Register
	H_MSR := $0022				; Modem Status Register
	H_LCR := $0023				; Line Control Register
	H_MCR := $0024				; Modem Control Register
	H_FCR := $0025				; FIFO Control Register
	H_DLL := $0028				; Divisor Latch LSB
	H_DLM := $0029				; Divisor Latch MSB
	H_FSR := $0030				; FIFO Status Register
	H_FIER := $0031			; FIFO Interrupt Enable

	;; $33 - ES Speed
	ESS := $0033				; ES Speed Control

	;; $34-$36 - PTG A
	PAM := $0034				; PTG A Mode
	PAB := $0035				; PTG A Buffer
	PAUL := $0036				; PTG A Upper Latch

	;; $38-$3F - USART
	SIB := $0038				; Serial In Buffer (read)
	SOB := $0038				; Serial Out Buffer (write)
	SIR := $0039				; Serial Interrupt Enable
	SMR := $003a				; Serial Mode Register
	SLCR := $003b				; Serial Line Control Register
	SSR := $003c				; Serial Status Register
	SFR := $003d				; Serial Form Register
	SODL := $003e				; SOUT Divider Latch (write-only)
	SIDL := $003f				; SIN Divider Latch (write-only)

	;; Zero page RAM usage
	;; Note: XSAVE is no longer needed (X is free).
	;; Note: W-1 JMP trick is no longer needed (NXT does direct threading).

        IRQVEC := $0040			; User IRQ vector, points to (COLD)
        NMIVEC := IRQVEC+2		; User NMI vector, points to (COLD)
		UKEY := NMIVEC+2		; User keyboard input vector, points to (IN)
		UEMIT := UKEY+2			; User output vector, points to (OUT)
    	UP := UEMIT+2			; user area pointer.
    	INTFLAG := UP+2
        W := INTFLAG+2			; code field pointer.
	;; W-1 trick is gone — NXT replaces JMP (W)
        N := W+2				; N is general purpose scratch area
	;; XSAVE is gone — X is free
    	INTVEC := N+8
		TOS := INTVEC+2			; Top of data stack, in zero page.

	;; Keyboard ring buffer variables (zero page)
	KBUF_HEAD := $005A		; ring buffer write index
	KBUF_TAIL := $005B		; ring buffer read index

	;; LCD cursor state (zero page for fast access)
	LCD_COL := $005C		; current text column (0-39)
	LCD_ROW := $005D		; current text row (0-19)
	LCD_TOPPAGE := $005E		; UC1608 page number for top visible row (0-19)
	LCD_INITED := $005F		; nonzero if LCD already initialized

	;; Graphics cursor (zero page)
	GFX_X := $0060			; pixel X position (0-239)
	GFX_Y := $0061			; pixel Y position (0-159)

	;; Data stack is in page 2, indexed by Y
	stack := $0200

	;; Keyboard ring buffer in RAM (page 4)
	KBUF := $0480			; 16-byte ring buffer
	KBUF_MASK := $0F		; mask for 16-entry buffer

	;; Page 1 RAM usage - hardware return stack (unchanged)

	;; Page 2 RAM usage - data stack (new for L28)
	;; $0200-$02FF indexed by Y register

	;; Page 3 RAM usage - User variables

    	TIBX := $0300			; Terminal Input Buffer address
        RO := TIBX+2				; Return stack base address
        SO := RO+2				; Parameter stack base address
        UC_L := SO+2			; Number of characters per line
        UPAD := UC_L+2			; Location of PAD in memory
        UR_W := UPAD+2			; CFA of UR/W orphan word
        BASE := UR_W+2			; Current I/O base number
        CLD_WARM := BASE+2		; Cold/Warm reset flag
        IN := CLD_WARM+2		; Byte offset in current input stream
        DPL := IN+2				; Number of decimals in double precision input
        HLD := DPL+2			; Address of current output
        DISKNO := HLD+2			; Number of selected disk drive
        CYLINDER := DISKNO+2	; Track of each disk
        B_SIDE := CYLINDER+4	; Blocks per side per disk

	;; 31E - 37E used by development ROM
	;; 380 - 3FF TIB

(*
	Disk controller registers.
*)
		DSK_BASE := $0640
    		DSK_STATUS := DSK_BASE
    		DSK_TRACK := DSK_BASE + 1
    		DSK_SECTOR := DSK_BASE + 2
    		DSK_DATA := DSK_BASE + 3
            DSK_CTL := DSK_BASE + 6

(*
	Page 5 registers (DMA, Timer C, CRC)
*)
	;; DMA registers ($05D0-$05EF, active when DSR0=1)
	DMA_ENAB := $05d0			; DMA Enable
	DMA_CHAR1 := $05d1			; DMA Character 1
	DMA_CHAR2 := $05d2			; DMA Character 2
	DMA_CHAR3 := $05d3			; DMA Character 3
	DMA_LWM := $05d4			; Low Water Mark
	DMA_HWM := $05d5			; High Water Mark
	DXM_L := $05d6				; TX Message Pointer Low
	DXM_H := $05d7				; TX Message Pointer High
	DXB_L := $05d8				; TX Buffer Pointer Low
	DXB_H := $05d9				; TX Buffer Pointer High
	DXZ_L := $05da				; TX Message Size Low
	DXZ_H := $05db				; TX Message Size High
	RXI_L := $05dc				; RX Input Pointer Low
	RXI_H := $05dd				; RX Input Pointer High
	RXO_L := $05de				; RX Output Pointer Low
	RXO_H := $05df				; RX Output Pointer High
	DMA_ROFF := $05e5			; ROFF Water Mark
	DRM_L := $05e6				; RX Message Pointer Low
	DRM_H := $05e7				; RX Message Pointer High
	DRB_L := $05e8				; RX Buffer Pointer Low
	DRB_H := $05e9				; RX Buffer Pointer High
	DRZ_L := $05ea				; RX Message Size Low
	DRZ_H := $05eb				; RX Message Size High
	RRI_L := $05ec				; RX RX Input Pointer Low
	RRI_H := $05ed				; RX RX Input Pointer High
	RRO_L := $05ee				; RX RX Output Pointer Low
	RRO_H := $05ef				; RX RX Output Pointer High

	;; Timer C (Snooze Timer) - $05F0-$05F3
	TCM := $05f0				; Timer C Mode
	TCLL := $05f1				; Timer C Lower Latch
	TCUL := $05f2				; Timer C Upper Latch

	;; DMA Status - $05F4-$05F6
	DGR := $05f4				; DMA Get/Put Register
	DFR := $05f5				; DMA Flag Register
	DSR := $05f6				; DMA Status Register

	;; CRC - $05FE-$05FF
	CRC_L := $05fe				; CRC Low (read) / CRC Data In (write)
	CRC_H := $05ff				; CRC High (read) / CRC Init (write)

(*
	ST7586S LCD controller registers (8080-style parallel interface)
	A0 selects command/data: $0600 = command/status, $0601 = data
*)
	LCD_CMD := $0600			; Write: command byte, Read: status byte
	LCD_DATA := $0601			; Write: data to display RAM, Read: data from RAM
	COL_OFFSET = 4				; byte column offset for ST7586S panel (8 pixels / 2)

(*
	This is an 8k ROM starting at $E000.
*)

    		ORG := $e000


;; Data table of initial values for registers, used by INIT
;; Offsets: TIBX(0) RO(2) SO(4) UC_L(6) UPAD(8) UR_W(10) BASE(12)
INITTAB:    DATA.W $0380, $02c2, $00ff, $0050
			DATA.W $037e, DISK, $000a
;;
;;    LIT — push next inline 16-bit value from thread to data stack
;;    Uses LAN to fetch bytes through I register
;;
LIT:	DATA.W (LIT+2)		; DV
		INI 				; skip data slot filler byte
			LAN 				; low byte from (I), I+1
    		PHA
			LAN 				; high byte from (I), I+1
L31    		NOP 				; placeholder for branch target alignment
    		BRA PUSH
;;
;; PUSH — allocate cell on data stack and store A(hi):PLA(lo)
;;
PUSH:		DEY
    		DEY
;;
;; PUT_ — store A(hi) and PLA(lo) to TOS
;;
PUT_: 		STA stack+1,Y	
    		PLA
    		STA stack,Y
		TIP
;;
;; NEXT — the address interpreter that moves from machine
;;         level word to word. Uses L28 NXT instruction.
;;
;; -- NEXT routine removed (JTC uses JPI/TIP) --
;; Interrupt check moved to SEMIS
;;     		BMI HANDLEINT
;; NOINT  		NXT 				; (I) -> PC, I + 2 -> I
;;
;; HANDLEINT:	BVS NOINT			; Are interrupts disabled?
;;     		LDA INTVEC
;;     		STA W				; Jump to int vector
;;     		LDA INTVEC+1
;;     		STA W+1
;;     		STI #$40, INTFLAG
;;     		JMP (W)
;;
;;    CLIT pushes the next inline byte to data stack
;;
CLIT:	DATA.W (CLIT+2)		; DV
		INI 				; skip data slot filler byte
		LAN 				; byte from (I), I+1
    		PHA
		INI 				; skip data slot padding byte
    		LDA #0				; high byte is zero
    		BRA L31				; branch into LIT to push
;;
;;
SETUP:		ASL A
    		STA N-1
			LDX #0				; X is index into N workspace
L63    		LDA stack,Y
    		STA N,X
    		INY
    		INX
    		CPX N-1
    		BNE L63
    		LDX #0
    		RTS
;;
;;    EXECUTE
;;
EXECUTE:	DATA.W (EXECUTE+2)
		LDA stack,Y
    		STA W
    		LDA stack+1,Y
    		STA W+1
    		INY
    		INY
		;; W = CFA = DV address; dereference DV to get code address
		LDA (W)			; code_addr low from DV
		PHA
		LDX #1
		LDA (W),X		; code_addr high from DV+1
		STA W+1
		PLA
		STA W
    		JMP (W)
;;
;;    BRANCH — add signed offset from thread to I
;;
BRAN:	DATA.W (BRAN+2)		; DV
		INI 				; skip data slot filler byte
				PHI 				; save I (pointing at offset bytes)
    		LAN 				; offset lo from thread, I advances
    		STA N
    		LAN 				; offset hi from thread, I advances
    		STA N+1
    		PLA 				; saved I_lo (original, before LANs)
    		ADD N				; I_lo + offset_lo
    		STA N+2
    		PLA 				; saved I_hi
    		ADC N+1				; I_hi + offset_hi + carry
    		PHA 				; push new_hi (for PLI)
    		LDA N+2
    		PHA 				; push new_lo (for PLI)
    		PLI 				; I = target address
    		TIP
;;
;;    0BRANCH
;;
ZBRAN:	DATA.W (ZBRAN+2)	; DV
		INY	
    		INY
    		LDA stack-2,Y
    		ORA stack-1,Y
    		BEQ BRAN+2			; if zero, take branch
;;
;; BUMP — skip over 2-byte branch offset in thread
BUMP   		INI 				; skip filler byte
			INI 				; skip offset lo ; skip high byte
			INI 				; skip offset hi (3-byte data slot)
   			TIP
;;
;;    LOOP
;;
LOOP:	DATA.W (LOOP+2)
		TSX	
    		INC $101,X
    		BNE L311
    		INC $102,X
L311   		CLC
    		LDA $103,X
    		SBC $101,X
    		LDA $104,X
    		SBC $102,X
L316		BPL BRAN+2
    		BVS BRAN+2
    		INX
    		INX
    		INX
    		INX
    		TXS
    		BVC BUMP
;;
;;    (LOOP) - +LOOP
;;
PLOOP:	DATA.W (PLOOP+2)
		LDA stack+1,Y	
    		PHA
    		PHA
    		LDA stack,Y
			INY
			INY
    		TSX
    		INX
    		INX
    		CLC
    		ADC $101,X
    		STA $101,X
    		PLA
    		ADC $102,X
    		STA $102,X
    		PLA
    		BPL L311
    		CLC
    		LDA $101,X
    		SBC $103,X
    		LDA $102,X
    		SBC $104,X
    		JMP L316
;;
;;    DO
;;
DO:	DATA.W (DO+2)
		LDA stack+3,Y	
    		PHA
    		LDA stack+2,Y
    		PHA
    		LDA stack+1,Y
    		PHA
    		LDA stack,Y
    		PHA
;
POPTWO: 	INY
    		INY
;
POP: 		INY
    		INY
    		TIP
;;
;;
;;
DIGIT:	DATA.W (DIGIT+2)
		SEC	
    		LDA stack+2,Y
    		SBC #$30
    		BMI L391
    		CMP #$0a
    		BMI L386
    		SEC
    		SBC #$07
    		CMP #$0a
    		BMI L391
L386   		CMP stack,Y
    		BPL L391
    		STA stack+2,Y
    		LDA #$01
    		PHA
   			LDA #0
    		JMP PUT_			; exit true with converted value
L391    	LDA #0
    		PHA
    		INY
    		INY
    		JMP PUT_			; exit false with bad conversion
;;
;;    FIND
;;
FIND:	DATA.W (FIND+2)
		LDA #$02	
    		JSR SETUP
L249   		LDX #$00
    		LDA (N),X
    		EOR (N+2),X
;;
    		AND #$3f
    		BNE L281
L254   		INX
    		LDA (N),X
    		EOR (N+2),X
    		ASL A
    		BNE L280
    		BCC L254
    		;; Found — push results
    		DEY
    		DEY
    		DEY
    		DEY
    		CLC
    		TXA
    		ADC #$03
    		ADC N
    		STA stack+2,Y
    		LDX #$00
    		LDA #0
    		ADC N+1
    		STA stack+3,Y
    		LDA #0
    		STA stack+1,Y
    		LDA (N)
    		STA stack,Y
    		LDA #$01
    		PHA
    		JMP PUSH
L280   		BCS L284
L281   		INX
    		LDA (N),X
    		BPL L281
L284   		INX
    		LDA (N),X			; link low byte
    		STA N+6				; temp
    		INX
    		LDA (N),X			; link high byte
    		STA N+1
    		LDA N+6
    		STA N
    		ORA N+1
    		BNE L249			; follow link if nonzero
    		;; Not found — push false
    		LDA #$00
    		PHA
    		JMP PUSH			; exit false upon reading null link

;;
;;    ENCLOSE
;;
ENCLOSE:	DATA.W (ENCLOSE+2)
		LDA #$02	
    		JSR SETUP
    		;; Now N has delimiter, N+2:N+3 has string address
    		;; Original used X as stack pointer and Y as scan index
    		;; On L28: Y is stack pointer, X is free for scanning
    		DEY
    		DEY
    		DEY
    		DEY
    		DEY
    		DEY
    		DEY
    		DEY 				; allocate 4 cells (8 bytes)
    		LDA #0
    		STA stack+3,Y
    		STA stack+1,Y
    		LDX #0				; X is scan index
    		BRA L474			; always branch (original BNE relied on Z=0 from TAX)
L468   		INX
    		BNE L474
    		INC N+3
    		LDA stack+1,Y
    		ADD #1
    		STA stack+1,Y
    		LDA stack+3,Y
    		ADD #1
    		STA stack+3,Y
    		LDA stack+5,Y
    		ADD #1
    		STA stack+5,Y
L474   		LDA (N+2),X
    		CMP N
    		BEQ L468
    		TXA
    		STA stack+4,Y
L478   		LDA (N+2),X
    		BNE L487
    		TXA
    		STA stack+2,Y
    		STA stack,Y
    		CMP stack+4,Y
    		BNE L486
    		LDA stack+2,Y
    		ADD #1
    		STA stack+2,Y
L486   		TIP
L487   		PHA 				; save the char we just loaded
    		TXA
    		STA stack+2,Y		; store scan position
    		INX
    		PLA 				; restore char
    		CMP N				; is it the delimiter?
    		BNE L478
    		TXA
    		STA stack,Y
    		TIP
;;
;;    EMIT
;;
EMIT:	DATA.W (EMIT+2)
		LDA stack,Y	
    		CMP #8
    		BNE L504
    		JSR L506
    		LDA #$20
    		JSR L506
    		LDA #8
L504   		JSR L506
    		JMP POP
L506   		JMP (UEMIT)
XEMIT  		PHA
.TXWAIT		LDA SSR				; check L28 serial status
    		AND #$20			; bit 5 = BE (buffer empty)
    		BEQ .TXWAIT			; loop until TX ready
    		PLA
    		STA SOB				; write character
    		RTS
;;
;;    KEY
;;
KEY:	DATA.W (KEY+2)
		JSR L517	
    		JMP PUSH0A
L517   		JMP (UKEY)
L518   		LDA SSR				; check L28 serial status
    		AND #$01			; bit 0 = BF (buffer full)
    		BEQ L518			; loop until RX data available
    		LDA SIB				; read character
    		RTS
;;
;;    ?TERMINAL
;;
QTERM:	DATA.W (QTERM+2)
		LDA KBUF_HEAD
		CMP KBUF_TAIL
		BNE .QT_HAS
		LDA SSR
    		AND #$01			; bit 0 = BF
    		JMP PUSH0A
.QT_HAS:	LDA #$01
		JMP PUSH0A
;;
;;    CR
;;
CR:	DATA.W (CR+2)
		LDA #$0d	
    		JSR L506
    		LDA #$0a
    		JSR L506
    		LDA #0				; was TYA (Y was 0), now Y is stack ptr
    		JSR L506
    		TIP
;;
;;    CMOVE
;;
CMOVE:	DATA.W (CMOVE+2)
		LDA #3	
    		JSR SETUP
    		;; N = count, N+2 = dest, N+4 = src
    		;; X is free for (N+4),X / (N+2),X byte copy
    		LDX #0
L547   		CPX N
    		BNE L552
    		DEC N+1
    		BPL L552
    		TIP
L552   		LDA (N+4),X
    		STA (N+2),X
    		INX
    		BNE L547
    		INC N+5
    		INC N+3
    		JMP L547
;;
;;    U*
;;    32-bit = 16-bit * 16-bit unsigned multiply
;;    On L28: can't use ASL abs,Y or ROL abs,Y — need load/shift/store
;;
USTAR:	DATA.W (USTAR+2)
		LDA stack+2,Y	
    		STA N
    		LDA #0
    		STA stack+2,Y
    		LDA stack+3,Y
    		STA N+1
    		LDA #0
    		STA stack+3,Y
    		LDX #$10
L570   		;; ASL stack+2,Y / ROL stack+3,Y — not available, use A
    		LDA stack+2,Y
    		ASL A
    		STA stack+2,Y
    		LDA stack+3,Y
    		ROL A
    		STA stack+3,Y
    		LDA stack,Y
    		ROL A
    		STA stack,Y
    		LDA stack+1,Y
    		ROL A
    		STA stack+1,Y
    		BCC L586
    		CLC
    		LDA N
    		ADC stack+2,Y
    		STA stack+2,Y
    		LDA N+1
    		ADC stack+3,Y
    		STA stack+3,Y
    		BCC L586
    		;; INC stack,Y not available — load/inc/store
    		LDA stack,Y
    		ADC #0				; carry is set
    		STA stack,Y
    		BNE L586
    		LDA stack+1,Y
    		ADC #0
    		STA stack+1,Y
L586   		DEX
    		BNE L570
    		TIP
;;
;;    U/
;;
    		;; Swap stack+4 with stack+2, shifting the latter left
USLAS:	DATA.W (USLAS+2)
		LDA stack+2,Y	
    		STA N+2				; temp = old stack+2
    		LDA stack+4,Y
    		ASL A				; shift into result
    		STA stack+2,Y
    		LDA N+2
    		STA stack+4,Y		; old stack+2 -> stack+4
    		LDA stack+3,Y
    		STA N+2				; temp = old stack+3
    		LDA stack+5,Y
    		ROL A
    		STA stack+3,Y
    		LDA N+2
    		STA stack+5,Y		; old stack+3 -> stack+5
    		STI #$10, N
L433   		;; ROL stack+4,Y / ROL stack+5,Y not available
    		LDA stack+4,Y
    		ROL A
    		STA stack+4,Y
    		LDA stack+5,Y
    		ROL A
    		STA stack+5,Y
    		PHP
    		SEC
    		LDA stack+4,Y
    		SBC stack,Y
    		STA N+2				; temp save low result
    		LDA stack+5,Y
    		SBC stack+1,Y
    		BCC L620
    		PHA 				; save hi result
    		LDA N+2
    		STA stack+4,Y
    		PLA
    		STA stack+5,Y
L617   		PLP
    		SEC
    		BCS L624
L620   		PLP
    		BCC L624
    		PHA
    		LDA N+2
    		STA stack+4,Y
    		PLA
    		STA stack+5,Y
L624   		;; ROL stack+2,Y / ROL stack+3,Y not available
    		LDA stack+2,Y
    		ROL A
    		STA stack+2,Y
    		LDA stack+3,Y
    		ROL A
    		STA stack+3,Y
    		DEC N
    		BNE L433
    		JMP POP
;;
;;    AND
;;
ANDD:	DATA.W (ANDD+2)
		LDA stack,Y	
    		AND stack+2,Y
    		PHA
    		LDA stack+1,Y
    		AND stack+3,Y
;
BINARY: 	INY
    		INY
    		JMP PUT_
;;
;;    OR
;;
OR:	DATA.W (OR+2)
		LDA stack,Y	
    		ORA stack+2,Y
    		PHA
    		LDA stack+1,Y
    		ORA stack+3,Y
    		JMP BINARY
;;
;;    XOR
;;
XOR:	DATA.W (XOR+2)
		LDA stack,Y	
    		EOR stack+2,Y
    		PHA
    		LDA stack+1,Y
    		EOR stack+3,Y
    		JMP BINARY
;;
;;    SP@
;;
SPAT:	DATA.W (SPAT+2)
		TYA	; Y is data stack pointer (was TXA)
    		PHA
    		LDA #>stack	; high byte = $02
    		JMP PUSH
;
PUSH0A: 	PHA
    		LDA #0
    		JMP PUSH
;;
;;    SP!
;;
SPSTO:	DATA.W (SPSTO+2)
		LDX #2	; offset of S0 in user area
    		LDA (UP),X			; load data stack pointer from S0
    		TAY 				; Y is data stack pointer (was TAX)
    		TIP
;;
;;    RP!
;;
RPSTO:	DATA.W (RPSTO+2)
		LDX #$04	; offset of R0 in user area
    		LDA (UP),X
    		TAX
    		TXS
    		TIP
;;
;;    S (return stack pointer to data stack)
;;
PUSHS:	DATA.W (PUSHS+2)
		TSX	
    		TXA
    		JMP PUSH0A
;;
;;    ;S (SEMIS) — exit colon definition
;;    Uses PLI to restore I from return stack
;;
;;
;;    ;S (SEMIS) -- exit colon definition
;;    JTC: PLI + TIP with cooperative interrupt check
;;
SEMIS:	DATA.W (SEMIS+2)	; DV
		BIT INTFLAG			; Check interrupt flag
		BMI .handle_int
		PLI 				; restore I from return stack
		TIP 				; return to caller
.handle_int:
		BVS .no_int			; interrupts disabled?
		LDA INTVEC
		STA W
		LDA INTVEC+1
		STA W+1
		STI #$40, INTFLAG
		JMP (W)
.no_int		PLI
		TIP
;;
;;    LEAVE
;;
LEAVE:	DATA.W (LEAVE+2)
		TSX	
    		LDA $101,X
    		STA $103,X
    		LDA $102,X
    		STA $104,X
    		TIP
;;
;;    >R
;;
GTR:	DATA.W (GTR+2)
		LDA stack+1,Y	
    		PHA
    		LDA stack,Y
    		PHA
    		JMP POP
;;
;;    R>
;;
RFROM:	DATA.W (RFROM+2)
		DEY	
    		DEY
    		PLA
    		STA stack,Y
    		PLA
    		STA stack+1,Y
    		TIP
;;
;;    R (I) — copy top of return stack to data stack
;;
R:	DATA.W (R+2)
		TSX	
    		LDA $101,X
    		PHA
    		LDA $102,X
    		JMP PUSH
;;
;;    0=
;;
ZEQ:	DATA.W (ZEQ+2)
		LDA stack+1,Y	; hi byte
    		ORA stack,Y			; OR with lo byte
    		BNE L760			; nonzero -> false
    		LDA #1				; zero -> true (1)
    		STA stack,Y
    		LDA #0
    		STA stack+1,Y
    		TIP
L760   		LDA #0				; nonzero -> false (0)
    		STA stack,Y
    		STA stack+1,Y
    		TIP
;;
;;    0<
;;
ZLT:	DATA.W (ZLT+2)
		LDA stack+1,Y	; get high byte (sign)
    		ASL A				; shift sign into carry
    		LDA #0
    		ROL A				; carry into bit 0
    		STA stack,Y
    		LDA #0
    		STA stack+1,Y
    		TIP
;;
;;    +
;;
PLUS:	DATA.W (PLUS+2)
		CLC	
    		LDA stack,Y
    		ADC stack+2,Y
    		PHA
    		LDA stack+1,Y
    		ADC stack+3,Y
    		JMP BINARY
;;
;;    D+
;;
DPLUS:	DATA.W (DPLUS+2)
		CLC	
    		LDA stack+2,Y
    		ADC stack+6,Y
    		STA stack+6,Y
    		LDA stack+3,Y
    		ADC stack+7,Y
    		STA stack+7,Y
    		LDA stack,Y
    		ADC stack+4,Y
    		STA stack+4,Y
    		LDA stack+1,Y
    		ADC stack+5,Y
    		STA stack+5,Y
    		JMP POPTWO
;;
;;    NEGATE
;;
NEGATE:	DATA.W (NEGATE+2)
		SEC	
L806   		LDA #0
    		SBC stack,Y
    		STA stack,Y
    		LDA #0
    		SBC stack+1,Y
    		STA stack+1,Y
    		TIP
;;
;;    DNEGATE
;;
DNEGATE:	DATA.W (DNEGATE+2)
		SEC	
    		LDA #0
    		SBC stack+2,Y
    		STA stack+2,Y
    		LDA #0
    		SBC stack+3,Y
    		STA stack+3,Y
    		JMP L806
;;
;;    OVER
;;
OVER:	DATA.W (OVER+2)
		LDA stack+2,Y	
    		PHA
    		LDA stack+3,Y
    		JMP PUSH
;;
;;    DROP
;;
DROP:	DATA.W (DROP+2)
		JMP POP	
;;
;;    2DROP
;;
TWODROP:	DATA.W (TWODROP+2)
		JMP POPTWO	
;;
;;    SWAP
;;
SWAP:	DATA.W (SWAP+2)
		LDA stack+2,Y	
    		PHA
    		LDA stack,Y
    		STA stack+2,Y
    		LDA stack+3,Y
    		PHA
    		LDA stack+1,Y
    		STA stack+3,Y
    		PLA
    		JMP PUT_
;;
;;    DUP
;;
DUP:	DATA.W (DUP+2)
		LDA stack,Y	
    		PHA
    		LDA stack+1,Y
    		JMP PUSH
;;
;;    2DUP
;;
TWODUP:	DATA.W (TWODUP+2)
		DEY	
    		DEY
    		LDA stack+4,Y
    		STA stack,Y
    		LDA stack+5,Y
    		STA stack+1,Y
    		LDA stack+2,Y
    		PHA
    		LDA stack+3,Y
    		JMP PUSH
;;
;;    BOUNDS ( addr n -- addr+n addr )
;;
BOUNDS:	DATA.W (BOUNDS+2)
		LDX stack+3,Y	
    		LDA stack+2,Y
    		PHA
    		CLC
    		ADC stack,Y
    		STA stack+2,Y
    		TXA
    		ADC stack+1,Y
    		STA stack+3,Y
    		TXA 				; A = saved addr_hi
    		;; PUT_ stores A -> stack+1,Y, PLA -> stack,Y
    		;; Result: TOS = original addr, NOS = addr+n
    		JMP PUT_
;;
;;    +!
;;
    		;; ( n addr -- ) : mem[addr] += n
    		;; Original used (0,X) which is (zp,X) pre-indexed indirect
    		;; On L28: (zp) plain indirect. Copy address to N first.
PSTORE:	DATA.W (PSTORE+2)
		LDA stack,Y	; addr lo
    		STA N
    		LDA stack+1,Y		; addr hi
    		STA N+1
    		CLC
    		LDA (N)				; mem[addr] lo
    		ADC stack+2,Y		; + n lo
    		STA (N)
    		INC N
    		BNE L868
    		INC N+1
L868   		LDA (N)				; mem[addr+1]
    		ADC stack+3,Y		; + n hi (carry from lo add)
    		STA (N)
    		JMP POPTWO
;;
;;    TOGGLE
;;
    		;; ( mask addr -- ) : mem[addr] ^= mask
    		;; Original used (2,X) which is (zp,X) pre-indexed indirect
    		;; Copy addr from stack+2 to N
TOGGL:	DATA.W (TOGGL+2)
		LDA stack+2,Y	
    		STA N
    		LDA stack+3,Y
    		STA N+1
    		LDA (N)
    		EOR stack,Y
    		STA (N)
    		JMP POPTWO
;;
;;    @ (fetch)
;;
    		;; ( addr -- n ) : push mem[addr]
    		;; Original used (0,X) pre-indexed indirect
    		;; Copy address to N, use (N) and (N),X
AT:	DATA.W (AT+2)
		LDA stack,Y	
    		STA N
    		LDA stack+1,Y
    		STA N+1
    		LDA (N)				; low byte
    		PHA
    		LDX #1
    		LDA (N),X			; high byte
    		JMP PUT_
;;
;;    C@ (character fetch)
;;
CAT:	DATA.W (CAT+2)
		LDA stack,Y	
    		STA N
    		LDA stack+1,Y
    		STA N+1
    		LDA (N)
L929   		STA stack,Y
    		LDA #$00
    		STA stack+1,Y
    		TIP
;;
;;    ! (store)
;;
    		;; ( n addr -- )
STORE:	DATA.W (STORE+2)
		LDA stack,Y	; addr lo
    		STA N
    		LDA stack+1,Y		; addr hi
    		STA N+1
    		LDA stack+2,Y		; value lo
    		STA (N)
    		LDX #1
    		LDA stack+3,Y		; value hi
    		STA (N),X
    		JMP POPTWO
;;
;;    C! (character store)
;;
CSTOR:	DATA.W (CSTOR+2)
		LDA stack,Y	; addr lo
    		STA N
    		LDA stack+1,Y		; addr hi
    		STA N+1
    		LDA stack+2,Y		; char
    		STA (N)
    		JMP POPTWO
;;
;;    DOCOL — enter colon definition
;;    R65C19 JSR pushes full return address (not PC-1 like 6502)
;;    so PFA = return address directly, no +1 needed
;;
DOCOL:		PLA 				; PFA_lo (JSR pushed return addr = PFA)
    		TAX 				; save PFA_lo in X
    		PLA 				; PFA_hi
    		PHI 				; save current I on return stack
    		PHA 				; push PFA_hi (for PLI)
    		TXA
    		PHA 				; push PFA_lo (for PLI)
    		PLI 				; I = PFA (parameter field)
    		TIP
;;
;;    DOCON — push constant value
;;
DOCON:		PLA 				; PFA_lo
    		STA N
    		PLA 				; PFA_hi
    		STA N+1
    		LDA (N)				; const lo
    		PHA
    		LDX #1
    		LDA (N),X			; const hi
    		JMP PUSH
;;
;;    DOVAR — push variable address (W+2)
;;
DOVAR:		PLA 				; PFA_lo
    		STA N
    		PLA 				; PFA_hi
    		DEY
    		DEY
    		STA stack+1,Y		; push PFA_hi
    		LDA N
    		STA stack,Y			; push PFA_lo
    		TIP
;;
;;    DOUSE — push user variable address
;;
DOUSE:		PLA 				; PFA_lo
    		STA N
    		PLA 				; PFA_hi
    		STA N+1
    		CLC
    		LDA (N)				; offset byte
    		ADC UP				; add user area base lo
    		PHA 				; result lo for PUSH
    		LDA #$00
    		ADC UP+1			; result hi
    		JMP PUSH
;;
;;
;;
ZERO:	DATA.W (ZERO+2)
		JSR DOCON	
            DATA.W 0
;;
;;
;;
ONE:	DATA.W (ONE+2)
		JSR DOCON	
            DATA.W 1
;;
;;
;;
TWO:	DATA.W (TWO+2)
		JSR DOCON	
            DATA.W 2
;;
;;
;;
THREE:	DATA.W (THREE+2)
		JSR DOCON	
            DATA.W 3
;;
;;
;;
FOUR:	DATA.W (FOUR+2)
		JSR DOCON	
            DATA.W 4
;;
;;
;;
BL:	DATA.W (BL+2)
		JSR DOCON	
            DATA.W $0020
;;
;;
;;
TIB:	DATA.W (TIB+2)
		JSR DOUSE	
    		DATA.B $00
;;
;;
;;
SZ:	DATA.W (SZ+2)
		JSR DOUSE	
    		DATA.B $02
;;
;;
;;
RZ:	DATA.W (RZ+2)
		JSR DOUSE	
    		DATA.B $04
;;
;;
;;
UCL:	DATA.W (UCL+2)
		JSR DOUSE	
    		DATA.B $06
;;
;;
;;
UPAD:	DATA.W (UPAD+2)
		JSR DOUSE	
    		DATA.B $08
;;
;;
;;
URW:	DATA.W (URW+2)
		JSR DOUSE	
    		DATA.B $0a
;;
;;
;;
BASE:	DATA.W (BASE+2)
		JSR DOUSE	
    		DATA.B $0c
;;
;;
;;
CLDWRM:	DATA.W (CLDWRM+2)
		JSR DOUSE	
    		DATA.B $0e
;;
;;
;;
IN:	DATA.W (IN+2)
		JSR DOUSE	
    		DATA.B $10
;;
;;
;;
DPL:	DATA.W (DPL+2)
		JSR DOUSE	
    		DATA.B $12
;;
;;
;;
HLD:	DATA.W (HLD+2)
		JSR DOUSE	
    		DATA.B $14
;;
;;
;;
CL:	DATA.W (CL+2)
		PHI
            JPI (UCL)
            JPI (AT)
            JPI (SEMIS)
;;
;;
;;
PAD:	DATA.W (PAD+2)
		PHI
            JPI (UPAD)
            JPI (AT)
            JPI (SEMIS)
;;
;;    1+
;;
    		;; INC abs,Y not available — load/inc/store
ONEPLUS:	DATA.W (ONEPLUS+2)
		LDA stack,Y	
    		ADD #1
    		STA stack,Y
    		BCC L1091
    		LDA stack+1,Y
    		ADC #0
    		STA stack+1,Y
L1091  		TIP
;;
;;    2+
;;
TWOPLUS:	DATA.W (TWOPLUS+2)
		CLC	
    		LDA stack,Y
    		ADC #$02
    		STA stack,Y
    		BCC L1102
    		LDA stack+1,Y
    		ADC #0
    		STA stack+1,Y
L1102  		TIP
;;
;;    1-
;;
ONEMINUS:	DATA.W (ONEMINUS+2)
		LDA stack,Y	
    		BNE L1110
    		LDA stack+1,Y
    		SEC
    		SBC #1
    		STA stack+1,Y
L1110  		LDA stack,Y
    		SEC
    		SBC #1
    		STA stack,Y
  			TIP
;;
;;    2-
;;
TWOMINUS:	DATA.W (TWOMINUS+2)
		SEC	
    		LDA stack,Y
    		SBC #$02
    		STA stack,Y
    		BCS L1122
    		LDA stack+1,Y
    		SBC #0
    		STA stack+1,Y
L1122  		TIP
;;
;;    -
;;
SUB:	DATA.W (SUB+2)
		PHI
            JPI (NEGATE)
            JPI (PLUS)
            JPI (SEMIS)
;;
;;    =
;;
EQUAL:	DATA.W (EQUAL+2)
		PHI
            JPI (SUB)
            JPI (ZEQ)
            JPI (SEMIS)
;;
;;    U<
;;
ULESS:	DATA.W (ULESS+2)
		SEC	
    		LDA stack+2,Y
    		SBC stack,Y
    		LDA stack+3,Y
    		SBC stack+1,Y
    		LDA #0
    		ROL A
    		EOR #$01
    		INY
    		INY
    		JMP L929
;;
;;    <
;;
LESS:	DATA.W (LESS+2)
		LDA stack+2,Y	
    		CMP stack,Y
    		LDA stack+3,Y
    		SBC stack+1,Y			; N,V flags reflect sign of (a - b)
    		BVC L1163
    		EOR #$80				; correct for overflow
L1163  		BPL L1165
    		LDA #1
    		BNE L1165A
L1165  		LDA #0
L1165A 		STA stack+2,Y
    		LDA #0
    		STA stack+3,Y			; clear high byte (moved after flag check)
    		JMP POP
;;
;;    >
;;
GT:	DATA.W (GT+2)
		PHI
            JPI (SWAP)
            JPI (LESS)
            JPI (SEMIS)
;;
;;    ROT
;;
ROT:	DATA.W (ROT+2)
		LDA stack+4,Y	
    		PHA
    		LDA stack+2,Y
    		STA stack+4,Y
    		LDA stack,Y
    		STA stack+2,Y
    		LDX stack+5,Y
    		LDA stack+3,Y
    		STA stack+5,Y
    		LDA stack+1,Y
    		STA stack+3,Y
    		TXA
    		JMP PUT_
;;
;;    PICK
;;
PICK:	DATA.W (PICK+2)
		PHI
		JPI (DUP)
		JPI (PLUS)
		JPI (SPAT)
		JPI (PLUS)
		JPI (AT)
		JPI (SEMIS)
;;
;;    SPACE
;;
SPACE:	DATA.W (SPACE+2)
		PHI
    		JPI (BL)
    		JPI (EMIT)
    		JPI (SEMIS)
;;
;;    -DUP
;;
DDUP:	DATA.W (DDUP+2)
		PHI
    		JPI (DUP)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DDUP_1 - addr)
    		JPI (DUP)
.DDUP_1	JPI (SEMIS)
;;
;;    HEX
;;
HEX:	DATA.W (HEX+2)
		PHI
    		JPI (CLIT)
    		DATA.B $00, $10, $00
L1170	JPI (BASE)
    		JPI (STORE)
    		JPI (SEMIS)
;;
;;    DECIMAL
;;
DECIMAL:	DATA.W (DECIMAL+2)
		PHI
    		JPI (CLIT)
    		DATA.B $00, $0a, $00
    		JPI (BRAN)
    				DATA.B $00
    				DATA.W (L1170 - addr)

;;
;;    DOES>
;;
DOES:		PLA 				; PFA_lo
    		STA N
    		PLA 				; PFA_hi
    		STA N+1				; N = PFA (DOES> body ptr location)
    		PHI 				; save current I on return stack
    		;; Read DOES> body IP from (N)
    		LDX #1
    		LDA (N),X			; body_hi
    		PHA
    		LDA (N)				; body_lo
    		PHA
    		PLI 				; I = DOES> body address
    		;; Push PFA+2 (parameter field) onto data stack
    		CLC
    		LDA N
    		ADC #2
    		PHA 				; param_lo for PUSH
    		LDA N+1
    		ADC #0				; param_hi
    		JMP PUSH
;;
;;    COUNT
;;
COUNT:	DATA.W (COUNT+2)
		PHI
            JPI (DUP)
            JPI (ONEPLUS)
            JPI (SWAP)
            JPI (CAT)
            JPI (SEMIS)
;;
;;    TYPE
;;
TYPE:	DATA.W (TYPE+2)
		PHI
            JPI (DDUP)
            JPI (ZBRAN)
L1639	DATA.B $00
		DATA.W (L1651 - addr)
    		JPI (BOUNDS)
    		JPI (DO)
.TYPE_1	JPI (R)
    		JPI (CAT)
    		JPI (EMIT)
    		JPI (LOOP)
    				DATA.B $00
    				DATA.W (.TYPE_1 - addr)
    		JPI (SEMIS)
L1651	JPI (DROP)
    		JPI (SEMIS)
;;
;;    -TRAILING
;;
DTRAI:	DATA.W (DTRAI+2)
		PHI
    		JPI (DUP)
    		JPI (ZERO)
    		JPI (DO)
.DTRAI_3	JPI (TWODUP)
    		JPI (PLUS)
    		JPI (ONEMINUS)
    		JPI (CAT)
    		JPI (BL)
    		JPI (SUB)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DTRAI_1 - addr)
    		JPI (LEAVE)
    		JPI (BRAN)
    				DATA.B $00
    				DATA.W (.DTRAI_2 - addr)
.DTRAI_1	JPI (ONEMINUS)
.DTRAI_2	JPI (LOOP)
					DATA.B $00
					DATA.W (.DTRAI_3 - addr)
    		JPI (SEMIS)
;;
;;
;;
PDOTQ:	DATA.W (PDOTQ+2)
		PHI
    		JPI (R)
    		JPI (COUNT)
    		JPI (DUP)
    		JPI (ONEPLUS)
    		JPI (RFROM)
    		JPI (PLUS)
    		JPI (GTR)
    		JPI (TYPE)
    		JPI (SEMIS)
;;
;;
;;
EXPECT:	DATA.W (EXPECT+2)
		PHI
    		JPI (OVER)
    		JPI (PLUS)
    		JPI (OVER)
.EXPECT_5	JPI (ZERO)
    		JPI (OVER)
    		JPI (STORE)
			JPI (KEY)
    		JPI (DUP)
    		JPI (CLIT)
    		DATA.B $00, $0d, $00			; Return
    		JPI (EQUAL)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_1 - addr)
    		JPI (DROP)
    		JPI (SPACE)
    		JPI (ONE)
    		JPI (BRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_2 - addr)
.EXPECT_1	JPI (DUP)
			JPI (CLIT)
    		DATA.B $00, $7f, $00			; DEL
    		JPI (EQUAL)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_3 - addr)
    		JPI (DROP)
    		JPI (THREE)
    		JPI (PICK)
    		JPI (OVER)
    		JPI (ULESS)
    		JPI (NEGATE)
    		JPI (DUP)
    		JPI (NEGATE)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_4 - addr)
    		JPI (CLIT)
    		DATA.B $00, $08, $00			; Backspace
    		JPI (EMIT)
    		JPI (BRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_4 - addr)
.EXPECT_3	JPI (TWODUP)
    		JPI (SWAP)
    		JPI (CSTOR)
    		JPI (EMIT)
    		JPI (ONE)
.EXPECT_4	JPI (PLUS)
			JPI (TWODUP)
			JPI (EQUAL)
.EXPECT_2	JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.EXPECT_5 - addr)
    		JPI (TWODROP)
    		JPI (DROP)
    		JPI (SEMIS)
;;
;;
;;
QUERY:	DATA.W (QUERY+2)
		PHI
    		JPI (TIB)
    		JPI (AT)
    		JPI (CL)
    		JPI (EXPECT)
    		JPI (ZERO)
    		JPI (IN)
    		JPI (STORE)
    		JPI (SEMIS)
;;
;;
;;
FILL_:	DATA.W (FILL_+2)
		PHI
    		JPI (SWAP)
    		JPI (DUP)
    		JPI (ONE)
    		JPI (LESS)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.FILL__1 - addr)
    		JPI (TWODROP)
    		JPI (DROP)
    		JPI (SEMIS)
.FILL__1	JPI (GTR)
			JPI (OVER)
    		JPI (CSTOR)
    		JPI (DUP)
    		JPI (ONEPLUS)
    		JPI (RFROM)
    		JPI (ONEMINUS)
    		JPI (CMOVE)
    		JPI (SEMIS)
;;
;;
;;
ERASE:	DATA.W (ERASE+2)
		PHI
    		JPI (ZERO)
    		JPI (FILL_)
    		JPI (SEMIS)
;;
;;
;;
BLANKS:	DATA.W (BLANKS+2)
		PHI
    		JPI (BL)
    		JPI (FILL_)
    		JPI (SEMIS)
;;
;;
;;
HOLD:	DATA.W (HOLD+2)
		PHI
    		JPI (LIT)
    				DATA.B $00
    				DATA.W $ffff
    		JPI (HLD)
    		JPI (PSTORE)
    		JPI (HLD)
    		JPI (AT)
    		JPI (CSTOR)
    		JPI (SEMIS)
;;
;;
;;
LTNUMBER:	DATA.W (LTNUMBER+2)
		PHI
.LTNUMBER_3	JPI (ONEPLUS)
    		JPI (DUP)
    		JPI (GTR)
    		JPI (CAT)
    		JPI (BASE)
    		JPI (AT)
    		JPI (DIGIT)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.LTNUMBER_1 - addr)
    		JPI (SWAP)
    		JPI (BASE)
    		JPI (AT)
    		JPI (USTAR)
    		JPI (DROP)
    		JPI (ROT)
    		JPI (BASE)
    		JPI (AT)
    		JPI (USTAR)
    		JPI (DPLUS)
    		JPI (DPL)
    		JPI (AT)
    		JPI (ONEPLUS)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.LTNUMBER_2 - addr)
    		JPI (ONE)
    		JPI (DPL)
    		JPI (PSTORE)
.LTNUMBER_2	JPI (RFROM)
			JPI (BRAN)
    				DATA.B $00
    				DATA.W (.LTNUMBER_3 - addr)
.LTNUMBER_1	JPI (RFROM)
			JPI (SEMIS)
;;
;;    COLD
;;
COLD:	LDA #0
    		STA CLD_WARM

RESET:		LDX #$ff
    		TXS
    		CLD
    		CLC
    		STI #0, INTFLAG
    		;; Initialize Timer B for baud rate generation
    		;; 115200 bps at 8 MHz: UIB = ø2/[(n+1)(l+1)]
    		;; n=2 (TIMB), l=22 (SIDL/SODL): 8000000/(3*23) = 115942 Hz (0.64% error)
    		STI #$00, TBM			; interval timer, no prescale, no interrupts
    		STI #$02, TBLL			; Timer B lower latch = $02
    		STI #$00, TBUL			; Timer B upper latch = $00 (loads counter)

    		;; Initialize L28 USART
    		STI #$E0, SMR			; enable TXD (6), RXD (7), Timer B timing (5)
    		STI #$03, SLCR			; 8 data bits, 1 stop bit, no parity
    		STI #$00, SFR			; normal operation
    		STI #$16, SIDL			; TXD baud rate divider = 22 decimal
    		STI #$16, SODL			; RXD baud rate divider = 22 decimal

    		STI #<XEMIT, UEMIT
    		STI #>XEMIT, UEMIT+1

    		;; Initialize keyboard ring buffer (always, cheap)
    		STI #0, KBUF_HEAD
    		STI #0, KBUF_TAIL

		if CONSOLE_MODE {
    		    ;; Console mode: keyboard input
    		    STI #<CONKEY, UKEY
    		    STI #>CONKEY, UKEY+1

    		    ;; Configure keyboard hardware
    		    STI #$00, PortC_Dir		; Port C all inputs (column read)
    		    STI #$00, PortD			; Port D all low (no row driven)
    		    ;; Enable PA0 edge detect → IRQ0
    		    LDA EIR
    		    ORA #$01			; bit 0 = PA0 edge detect enable
    		    STA EIR
    		    ;; Clear any pending PA0 flag
    		    LDA CIR
    		    AND #$BF			; clear bit 6 (PA0 edge flag)
    		    STA CIR

    		    ;; Initialize LCD and redirect output
    		    JSR LCD_INIT
    		    STI #<LCD_XEMIT, UEMIT
    		    STI #>LCD_XEMIT, UEMIT+1
		} else {
    		    ;; Terminal mode: serial input (default)
    		    STI #<L518, UKEY
    		    STI #>L518, UKEY+1
		}

    		STI #0, UP
    		STI #3, UP+1
    		LDX #5
    		JSR L1549
    		LDA CLD_WARM
    		CMP #$5a
    		BNE L1505
    		LDA CLD_WARM+1
    		CMP #$a5
    		BEQ L1515
L1505		LDA #<COLD
  			STA IRQVEC
    		STA NMIVEC
    		STA INTVEC
  			LDA #>COLD
    		STA IRQVEC+1
    		STA NMIVEC+1
    		STA INTVEC+1
    		LDX #$0d
    		JSR L1549
	; Initialize KHZ user variable to 8000 ($1F40) for 8 MHz clock
		LDX #$52
		LDA #$40
		STA (UP),X		; KHZ low byte
		INX
		LDA #$1F
		STA (UP),X		; KHZ high byte
L1515  		;; Set up I register as IP pointing to DSKBOOT
			LDA #>DSKBOOT
			PHA
    		LDA #<DSKBOOT
			PHA
			PLI 				; I = DSKBOOT address
    		CLI
    		LDY #$c2		 	; Y is data stack pointer (was LDX)
    		;; ROM scan: look for $5AA5 signature
    		STI #$04, TOS+1			; Start at $0400
    		STI #0, TOS
L1525  		LDA (TOS)			; Check for $5A
    		CMP #$5a
    		BNE L1540
    		LDX #1
    		LDA (TOS),X			; Check for $A5
    		CMP #$a5
    		BNE L1540
    		LDX #2
    		LDA (TOS),X			; ROM IP low
    		STA N				; temp
    		LDX #3
    		LDA (TOS),X			; ROM IP high
    		;; Set I register to ROM start address
    		PHA 				; hi
    		LDA N
    		PHA 				; lo
    		PLI 				; I = ROM IP
L1539		TIP
L1540  		LDA TOS+1			; Add 4 to high byte (1k pages)
    		ADD #4
    		BEQ L1539			; Wrapped = not found, start DSKBOOT
    		STA TOS+1
    		STI #0, TOS
    		BRA L1525
L1549  		LDA INITTAB,X
    		STA (UP),X			; (zp),X on L28
    		DEX
    		BPL L1549
    		RTS
;;
;;
;;
DSKBOOT:	JPI (CR)
            JPI (PDOTQ)
NOROMSTR:	DATA.B $06, "NO ROM"
    		JPI (CTLRQ)
    		JPI (ZERO)
    		JPI (L2149)
    		JPI (ZERO)
    		JPI (SEEK)
		JPI (unkn2)			; continue to ROM loader
;;
;;
;;
unkn2:		DATA.W unkn2+2
    		STI #$df, N
    		STI #$ff, N+1
    		STI #1, N+2
    		LDA #$80
    		JSR DSTAT
    		LDX #$80
    		JSR L1826
    		BNE L1601
    		JMP $005f 			; Appears to be a value on the stack
L1601  		JMP RESET
;;
;;    S->D - Single to double precision
;;
STOD:	DATA.W (STOD+2)
		PHI
    		JPI (DUP)
    		JPI (ZLT)
    		JPI (NEGATE)
    		JPI (SEMIS)
;;
;;
;;
PM:	DATA.W (PM+2)
		PHI
    		JPI (ZLT)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.PM_1 - addr)
    		JPI (NEGATE)
.PM_1	JPI (SEMIS)
;;
;;
;;
DPLUS1:	DATA.W (DPLUS1+2)
		PHI
    		JPI (ZLT)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DPLUS1_1 - addr)
    		JPI (DNEGATE)
.DPLUS1_1	JPI (SEMIS)
;;
;;
;;
ABS:	DATA.W (ABS+2)
		PHI
    		JPI (DUP)
    		JPI (PM)
    		JPI (SEMIS)
;;
;;
;;
DABS:	DATA.W (DABS+2)
		PHI
    		JPI (DUP)
    		JPI (DPLUS1)
    		JPI (SEMIS)
;;
;;    MIN
;;
MIN:	DATA.W (MIN+2)
		PHI
    		JPI (TWODUP)
    		JPI (GT)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.MIN_1 - addr)
    		JPI (SWAP)
.MIN_1	JPI (DROP)
			JPI (SEMIS)
;;
;;    MAX
;;
MAX:	DATA.W (MAX+2)
		PHI
    		JPI (TWODUP)
    		JPI (LESS)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.MAX_1 - addr)
    		JPI (SWAP)
.MAX_1	JPI (DROP)
			JPI (SEMIS)
;;
;;
;;
MMUL:	DATA.W (MMUL+2)
		PHI
    		JPI (TWODUP)
    		JPI (XOR)
    		JPI (GTR)
    		JPI (ABS)
    		JPI (SWAP)
    		JPI (ABS)
    		JPI (USTAR)
    		JPI (RFROM)
    		JPI (DPLUS1)
    		JPI (SEMIS)
;;
;;
;;
MDIV:	DATA.W (MDIV+2)
		PHI
    		JPI (OVER)
    		JPI (GTR)
    		JPI (GTR)
    		JPI (DABS)
    		JPI (R)
    		JPI (ABS)
    		JPI (USLAS)
    		JPI (RFROM)
    		JPI (R)
    		JPI (XOR)
    		JPI (PM)
    		JPI (SWAP)
    		JPI (RFROM)
    		JPI (PM)
    		JPI (SWAP)
    		JPI (SEMIS)
;;
;;
;;
MUL:	DATA.W (MUL+2)
		LDA stack+2,Y	; n1_lo
    		STA N
    		LDA stack+3,Y		; n1_hi
    		STA N+1
    		LDA stack,Y		; n2_lo
    		STA N+2
    		LDA stack+1,Y		; n2_hi
    		STA N+3
    		INY			; pop one cell
    		INY
    		STY N+7			; save stack pointer (Y used by MPY)
    		;; Main product: n1_lo × n2_lo
    		LDA N			; n1_lo
    		LDY N+2			; n2_lo
    		MPY			; A(hi):Y(lo) = signed(n1_lo × n2_lo)
    		STY N+4			; result_lo
    		STA N+5			; result_hi (signed, needs correction)
    		;; Unsigned correction: add other operand to hi byte
    		;; when an operand has bit 7 set (signed vs unsigned)
    		LDA N			; n1_lo
    		BPL .c1
    		LDA N+5
    		ADD N+2			; result_hi += n2_lo
    		STA N+5
.c1:		LDA N+2			; n2_lo
    		BPL .c2
    		LDA N+5
    		ADD N			; result_hi += n1_lo
    		STA N+5
.c2:		;; Cross product: n1_hi × n2_lo (low byte only)
    		LDA N+1			; n1_hi
    		LDY N+2			; n2_lo
    		MPY
    		TYA			; low byte of cross product
    		ADD N+5			; result_hi += cross1_lo
    		STA N+5
    		;; Cross product: n1_lo × n2_hi (low byte only)
    		LDA N			; n1_lo
    		LDY N+3			; n2_hi
    		MPY
    		TYA			; low byte of cross product
    		ADD N+5			; result_hi += cross2_lo
    		;; Store result and restore stack pointer
    		LDY N+7
    		STA stack+1,Y		; result_hi
    		LDA N+4
    		STA stack,Y		; result_lo
    		TIP
;;
;;
;;
DIVMOD:	DATA.W (DIVMOD+2)
		PHI
    		JPI (GTR)
    		JPI (STOD)
    		JPI (RFROM)
    		JPI (MDIV)
    		JPI (SEMIS)
;;
;;
;;
DIV_:	DATA.W (DIV_+2)
		PHI
    		JPI (DIVMOD)
    		JPI (SWAP)
    		JPI (DROP)
    		JPI (SEMIS)
;;
;;
;;
MOD_:	DATA.W (MOD_+2)
		PHI
    		JPI (DIVMOD)
    		JPI (DROP)
    		JPI (SEMIS)
;;
;;
;;
MULDIVMOD:	DATA.W (MULDIVMOD+2)
		PHI
    		JPI (GTR)
    		JPI (MMUL)
    		JPI (RFROM)
    		JPI (MDIV)
    		JPI (SEMIS)
;;
;;
;;
MULDIV:	DATA.W (MULDIV+2)
		PHI
    		JPI (MULDIVMOD)
    		JPI (SWAP)
    		JPI (DROP)
    		JPI (SEMIS)
;;
;;
;;
MDIVMOD:	DATA.W (MDIVMOD+2)
		PHI
    		JPI (GTR)
    		JPI (ZERO)
    		JPI (R)
    		JPI (USLAS)
    		JPI (RFROM)
    		JPI (SWAP)
    		JPI (GTR)
    		JPI (USLAS)
    		JPI (RFROM)
    		JPI (SEMIS)
;;
;;
;;
DISK:	DATA.W (DISK+2)
		PHI
    		JPI (SWAP)
    		JPI (LIT)
    				DATA.B $00
    				DATA.W B_SIDE
    		JPI (AT)
    		JPI (DIVMOD)
    		JPI (L2149)
    		JPI (FOUR)
    		JPI (DIVMOD)
    		JPI (SEEK)
    		JPI (SWAP)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DISK_1 - addr)
    		JPI (DREAD)
    		JPI (BRAN)
    				DATA.B $00
    				DATA.W (.DISK_2 - addr)
.DISK_1	JPI (DWRITE)
.DISK_2	JPI (DDUP)
			JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DISK_3 - addr)
    		JPI (PDOTQ)
    		DATA.B $0c, "DISK ERROR #"
    		JPI (DOT)
.DISK_3	JPI (SEMIS)
;;
;;    SELECT
;;
SELECT:	DATA.W (SELECT+2)
		LDA stack,Y	
    		LSR A
    		STA DISKNO
    		LDA #0
    		STA DISKNO+1
    		JSR L1886
    		STA DSK_CTL
    		JMP POP
;;
;; DREAD (addr n --- err )
;;
DREAD:	DATA.W (DREAD+2)
		JSR CALCSEC	
.RDSEC		JSR DRSETUP
    		LDA #$90
    		JSR DSTAT
    		JSR L1826
    		AND #$bf
    		BEQ DRDONE
    		DEC N+3
    		BNE .RDSEC
DRDONE:		INY
    		INY
    		JMP L929
;;
;; CALCSEC: compute sector from block number
;; On L28: stack,Y replaces 0,X. Can't use ASL abs,Y — load/shift/store.
;;
CALCSEC:	LDA stack,Y			; n
    		ASL A
    		ASL A
    		ADD #1				; 4n + 1
    		STA stack,Y
    		STI #5, N+3
    		RTS
;;
;; DRSETUP: set up for disk read/write
;;
DRSETUP:	LDA #4
    		STA N+2
    		LDA stack+2,Y
    		STA N
    		LDA stack+3,Y
    		STA N+1
    		LDA stack,Y
    		STA DSK_SECTOR
    		JMP L1836
;;
;; Disk read transfer loop
;; On L28: (N),Y becomes (N),X with X as byte counter
;;
L1826  		BIT DSK_CTL
    		BVS L1826
    		BPL L1838
    		LDA DSK_DATA
    		STA (N),X
    		INX
    		BNE L1826
    		INC N+1
    		DEC N+2
    		BNE L1826
L1836  		LDA #$d4
L1837  		JSR DSTAT
L1838  		LDA DSK_STATUS
    		LSR A
    		BCS L1838
    		ROL A
    		RTS
DSTAT:		STA DSK_STATUS
    		LDX #8
.WAILOOP:	DEX
    		BNE .WAILOOP
    		RTS
;;
;;    DWRITE
;;
DWRITE:	DATA.W (DWRITE+2)
		JSR CALCSEC	
L1853  		JSR DRSETUP
    		LDA #$b0
    		JSR DSTAT
    		JSR L1862
    		AND #$fd
    		BEQ L1861
    		DEC N+3
    		BNE L1853
L1861  		JMP DRDONE
;;
;; Disk write transfer loop — (N),X with X as byte counter
;;
L1862  		BIT DSK_CTL
    		BVS L1862
    		BPL L1838
    		LDA (N),X
    		STA DSK_DATA
    		INX
    		BNE L1862
    		INC N+1
    		DEC N+2
    		BNE L1862
    		JMP L1836
;;
;;    INIT
;;
INIT:	DATA.W (INIT+2)
		LDA DSK_STATUS	
    		LDA #$ff
    		LDX #$03
L1880  		STA CYLINDER,X
    		DEX
    		BPL L1880
    		TIP
SUB1: 		NOP
    		NOP
L1886  		TAX
    		LDA #0
    		ROL A
    		ORA TAB1,X
    		RTS
TAB1:       DATA.B $22, $24, $28, $30
;;
;;    SEEK
;;
SEEK:	DATA.W (SEEK+2)
		LDX DISKNO	
    		LDA CYLINDER,X
    		CMP #$50
    		BCC L1903
    		LDA #3
    		JSR L1837
    		LDA #0
L1903  		STA DSK_TRACK
    		LDA stack,Y
    		STA DSK_DATA
    		LDX DISKNO
    		STA CYLINDER,X
    		LDA #$13
    		JSR L1837
    		JMP POP
;;
;;
;;
SPACES:	DATA.W (SPACES+2)
		PHI
    		JPI (ZERO)
    		JPI (MAX)
    		JPI (DDUP)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.SPACES_1 - addr)
    		JPI (ZERO)
    		JPI (DO)
.SPACES_2	JPI (SPACE)
    		JPI (LOOP)
    				DATA.B $00
    				DATA.W (.SPACES_2 - addr)
.SPACES_1	JPI (SEMIS)
;;
;;
;;
LEQ:	DATA.W (LEQ+2)
		PHI
    		JPI (PAD)
    		JPI (HLD)
    		JPI (STORE)
    		JPI (SEMIS)
;;
;;
;;
HASHGT:	DATA.W (HASHGT+2)
		PHI
    		JPI (TWODROP)
    		JPI (HLD)
    		JPI (AT)
    		JPI (PAD)
    		JPI (OVER)
    		JPI (SUB)
    		JPI (SEMIS)
;;
;;
;;
SIGN:	DATA.W (SIGN+2)
		PHI
    		JPI (ROT)
    		JPI (ZLT)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.SIGN_1 - addr)
    		JPI (CLIT)
    		DATA.B $00, '-', $00
    		JPI (HOLD)
.SIGN_1	JPI (SEMIS)
;;
;;
;;
DIG:	DATA.W (DIG+2)
		PHI
    		JPI (BASE)
    		JPI (AT)
    		JPI (MDIVMOD)
    		JPI (ROT)
    		JPI (CLIT)
    		DATA.B $00, $09, $00
    		JPI (OVER)
    		JPI (LESS)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.DIG_1 - addr)
    		JPI (CLIT)
    		DATA.B $00, $07, $00
    		JPI (PLUS)
.DIG_1	JPI (CLIT)
			DATA.B $00, $30, $00
    		JPI (PLUS)
    		JPI (HOLD)
    		JPI (SEMIS)
;;
;;
;;
HASHS:	DATA.W (HASHS+2)
		PHI
.HASHS_1	JPI (DIG)
    		JPI (TWODUP)
    		JPI (OR)
    		JPI (ZEQ)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.HASHS_1 - addr)
    		JPI (SEMIS)
;;
;;
;;
DDOTR:	DATA.W (DDOTR+2)
		PHI
    		JPI (GTR)
    		JPI (SWAP)
    		JPI (OVER)
    		JPI (DABS)
    		JPI (LEQ)
    		JPI (HASHS)
    		JPI (SIGN)
    		JPI (HASHGT)
    		JPI (RFROM)
    		JPI (OVER)
    		JPI (SUB)
    		JPI (SPACES)
    		JPI (TYPE)
    		JPI (SEMIS)
;;
;;    D. - Print double precision
;;
DDOT:	DATA.W (DDOT+2)
		PHI
    		JPI (ZERO)
    		JPI (DDOTR)
    		JPI (SPACE)
    		JPI (SEMIS)
;;
;;    .R
;;
DOTR:	DATA.W (DOTR+2)
		PHI
    		JPI (GTR)
    		JPI (STOD)
    		JPI (RFROM)
    		JPI (DDOTR)
    		JPI (SEMIS)
;;
;;    . - Print number
;;
DOT:	DATA.W (DOT+2)
		PHI
    		JPI (STOD)
    		JPI (DDOT)
    		JPI (SEMIS)
;;
;;
;;
Q:	DATA.W (Q+2)
		PHI
    		JPI (AT)
    		JPI (DOT)
    		JPI (SEMIS)
;;    BANKCOPY! - copy 8K bank between ICs
;;    ( src_ic src_bank dst_ic dst_bank -- )
;;    IC: 0=ES0(RAM) 2=ES2(flash) 3=ES3(flash)
;;    Zero-page usage: N+0=src_bsr, N+1=dst_mask, N+2=dst_bsr,
;;                     N+3=dst_ic, N+4:N+5=addr_ptr, N+6=temp
;;
BANKCOPY:	DATA.W (BANKCOPY+2)
	; Compute source BSR: IC_TABLE[src_ic] | src_bank
		LDX stack+6,Y	; src_ic
		LDA .IC_TABLE,X
		ORA stack+4,Y	; src_bank
		STA N		; N+0 = source BSR4 value
	; Compute dest BSR mask and full value
		LDX stack+2,Y	; dst_ic
		LDA .IC_TABLE,X
		STA N+1		; N+1 = dest IC BSR mask (no page)
		ORA stack,Y	; dst_bank
		STA N+2		; N+2 = dest BSR4 value (mask|page)
	; Save dest IC type (0=RAM, 2/3=flash)
		LDA stack+2,Y
		STA N+3		; N+3 = dest IC
	; Drop 4 cells from data stack
		TYA
		CLC
		ADC #8
		TAY
	; If dest is flash, erase two 4K sectors
		LDA N+3
		BEQ .copy	; IC 0 = RAM, skip erase
		JSR .erase_lo
		JSR .erase_hi
	; Init address pointer to $8000 (start of BSR4 window)
.copy:		LDA #$00
		STA N+4		; addr low = $00
		LDA #$80
		STA N+5		; addr high = $80
.byte_loop:
	; Read source byte
		LDA N		; source BSR4
		STA BSR4
		LDA (N+4)	; read byte from source window
		STA N+6		; save data byte
	; Branch on dest type
		LDA N+3
		BNE .flash_prog
	; RAM write: direct store
		LDA N+2		; dest BSR4
		STA BSR4
		LDA N+6
		STA (N+4)	; write to dest window
		BRA .advance
	; Flash write: unlock + program byte
.flash_prog:	JSR .unlock
		LDA N+1
		ORA #2
		STA BSR4
		LDA #$A0
		STA $9555	; program setup command
		LDA N+2		; dest BSR4 (target page)
		STA BSR4
		LDA N+6
		STA (N+4)	; write data byte to flash
	; Poll DQ7 for completion
.fpoll:		LDA (N+4)
		EOR N+6
		AND #$80
		BNE .fpoll
	; Advance address pointer
.advance:	INC N+4
		BNE .byte_loop
		INC N+5		; next page
		LDA N+5
		CMP #$A0	; past $9FFF?
		BNE .byte_loop
	; Restore BSR4 to default and return
		LDA #$54
		STA BSR4
		TIP
;
; Unlock subroutine: AA->$5555, 55->$2AAA
.unlock:	LDA N+1
		ORA #2		; dest IC, page 2
		STA BSR4
		LDA #$AA
		STA $9555
		LDA N+1
		ORA #1		; dest IC, page 1
		STA BSR4
		LDA #$55
		STA $8AAA
		RTS
;
; Erase lower 4K sector ($8000-$8FFF)
.erase_lo:	JSR .unlock
		LDA N+1
		ORA #2
		STA BSR4
		LDA #$80
		STA $9555	; erase setup
		JSR .unlock
		LDA N+2		; target page
		STA BSR4
		LDA #$30
		STA $8000	; erase lower sector
.epoll_lo:	LDA $8000
		BPL .epoll_lo	; wait for DQ7=1
		RTS
;
; Erase upper 4K sector ($9000-$9FFF)
.erase_hi:	JSR .unlock
		LDA N+1
		ORA #2
		STA BSR4
		LDA #$80
		STA $9555
		JSR .unlock
		LDA N+2
		STA BSR4
		LDA #$30
		STA $9000	; erase upper sector
.epoll_hi:	LDA $9000
		BPL .epoll_hi
		RTS
;
; IC-to-BSR-mask lookup table
.IC_TABLE:	data.b $C0	; IC 0 = ES0
		data.b $00	; IC 1 = unused
		data.b $90	; IC 2 = ES2
		data.b $50	; IC 3 = ES3
;;
;;
;;
BANKPSH:	DATA.W (BANKPSH+2)
	; ( bank -- ) Save BSR4, switch $8000-$9FFF to ES0 page 'bank'
		LDA BSR4	; read current BSR4
		PHA		; save on hardware stack
		LDA stack,Y	; get bank number (TOS)
		AND #$0F	; mask to pages 0-15
		ORA #$C0	; ES3=1,ES2=1,A17=0,ES0=0(active)
		STA BSR4	; switch $8000-$9FFF to ES0 page
		JMP POP		; drop bank number, return
;;
;;
;;
BANKPOP:	DATA.W (BANKPOP+2)	; DV
		PLA		; restore saved BSR4
		STA BSR4	; switch bank back
		PLI		; restore I_reg
		TIP
;;
;;
;;
BANKCSTOR:	DATA.W (BANKCSTOR+2)
		PHI
    		JPI (BANKPSH)
    		JPI (CSTOR)
    		JPI (BANKPOP)
;;
;;
;;
BANKCAT:	DATA.W (BANKCAT+2)
		PHI
    		JPI (BANKPSH)
    		JPI (CAT)
    		JPI (BANKPOP)
;;
;;
;;
BANKEXEC:	DATA.W (BANKEXEC+2)
		PHI
    		JPI (BANKPSH)
    		JPI (EXECUTE)
    		JPI (BANKPOP)
;;
;;    SKEY - blocking serial input, bypasses UKEY vector
;;    ( -- c )
SKEY:		DATA.W (SKEY+2)
		JSR L518		; reuse existing serial poll+read
		JMP PUSH0A		; push char to data stack
;;
;;    SEMIT - serial output, bypasses UEMIT vector
;;    ( c -- )
SEMIT:		DATA.W (SEMIT+2)
		LDA stack,Y
		JSR XEMIT		; reuse existing serial send
		JMP POP
;;
;;    SSTAT - serial status (non-blocking)
;;    ( -- flag )  1 = data available, 0 = not
SSTAT:		DATA.W (SSTAT+2)
		LDA SSR
		AND #$01		; BF bit
		JMP PUSH0A
;;
;;    SCR - send CR LF NUL to serial
;;    ( -- )
SCR:		DATA.W (SCR+2)
		LDA #$0D
		JSR XEMIT
		LDA #$0A
		JSR XEMIT
		LDA #$00
		JSR XEMIT
		TIP
;;
;;    STYPE - type string to serial port
;;    ( addr n -- )
STYPE:		DATA.W (STYPE+2)
		PHI
		JPI (DDUP)		; -DUP: dup count if nonzero
		JPI (ZBRAN)
			DATA.B $00
			DATA.W (.ST_END - addr)
		JPI (BOUNDS)		; ( addr+n addr )
		JPI (DO)
.ST_LP		JPI (R)			; loop index = current addr
		JPI (CAT)		; fetch byte
		JPI (SEMIT)		; send to serial
		JPI (LOOP)
			DATA.B $00
			DATA.W (.ST_LP - addr)
		JPI (SEMIS)
.ST_END		JPI (DROP)		; drop addr when count=0
		JPI (SEMIS)
;;
;;    SEXPECT - read n bytes from serial into buffer (no echo)
;;    ( addr n -- )
SEXPECT:	DATA.W (SEXPECT+2)
		PHI
		JPI (DDUP)		; -DUP count
		JPI (ZBRAN)
			DATA.B $00
			DATA.W (.SE_END - addr)
		JPI (BOUNDS)		; ( addr+n addr )
		JPI (DO)
.SE_LP		JPI (SKEY)		; blocking read from serial
		JPI (R)			; loop index = current addr
		JPI (CSTOR)		; store byte at addr
		JPI (LOOP)
			DATA.B $00
			DATA.W (.SE_LP - addr)
		JPI (SEMIS)
.SE_END		JPI (DROP)
		JPI (SEMIS)
;;
;;    SETSERIAL - configure serial port
;;    ( bps parity bits stop -- )
;;    parity: 0=none 1=odd 2=even  bits: 5-8  stop: 1-2
SETSERIAL:	DATA.W (SETSERIAL+2)
	; stack,Y=stop  stack+2,Y=bits  stack+4,Y=parity  stack+6,Y=bps
	;
	; --- Build SLCR register value ---
		LDA stack,Y		; stop (1 or 2)
		SEC
		SBC #1			; 0 or 1
		ASL A
		ASL A			; 0 or 4 (bit 2)
		STA N			; save stop bits
		LDA stack+2,Y		; bits (5-8)
		SEC
		SBC #5			; 0-3
		ORA N
		STA N			; N = stop|bits
		LDA stack+4,Y		; parity
		BEQ .ss_nopar		; 0 = none
		LDA N
		ORA #$08		; bit 3 = parity enable
		STA N
		LDA stack+4,Y
		CMP #2
		BNE .ss_nopar		; 1=odd (bit 3 only), 2=even
		LDA N
		ORA #$10		; bit 4 = even
		STA N
.ss_nopar:	LDA N
		STA SLCR
	;
	; --- 16×16→32 multiply: KHZ * 1000 ---
	; Multiplier (KHZ) in N+2:N+3, result in N+4:N+5:N+6:N+7
		LDX #$52
		LDA (UP),X		; KHZ low
		STA N+2
		INX
		LDA (UP),X		; KHZ high
		STA N+3
		STI #0, N+4
		STI #0, N+5
		STI #0, N+6
		STI #0, N+7
		LDX #16
.ss_mul:	ASL N+4			; shift 32-bit result left
		ROL N+5
		ROL N+6
		ROL N+7
		ASL N+2			; shift multiplier MSB into carry
		ROL N+3
		BCC .ss_madd
		CLC			; add 1000 ($03E8) to result
		LDA N+4
		ADC #$E8
		STA N+4
		LDA N+5
		ADC #$03
		STA N+5
		BCC .ss_madd
		INC N+6
		BNE .ss_madd
		INC N+7
.ss_madd:	DEX
		BNE .ss_mul
	;
	; --- 32÷16 divide: (KHZ*1000) / bps ---
	; Dividend in N+4..N+7, divisor = bps (stack+6,Y : stack+7,Y)
	; Quotient → N+0:N+1, remainder → N+2:N+3
		STI #0, N
		STI #0, N+1
		STI #0, N+2
		STI #0, N+3
		LDX #32
.ss_div:	ASL N+4			; shift dividend left into remainder
		ROL N+5
		ROL N+6
		ROL N+7
		ROL N+2
		ROL N+3
		LDA N+2			; trial subtract divisor
		SEC
		SBC stack+6,Y		; bps lo
		STA TOS
		LDA N+3
		SBC stack+7,Y		; bps hi
		BCC .ss_dsk		; remainder < divisor
		STA N+3			; commit subtraction
		LDA TOS
		STA N+2
.ss_dsk:	ROL N			; shift carry into quotient
		ROL N+1
		DEX
		BNE .ss_div
	; N+0:N+1 = total divisor
	;
	; --- Factor divisor into (n+1)*(l+1), l ≤ 255 ---
		LDA N+1
		BEQ .ss_small		; high byte 0 → divisor ≤ 255
		CMP #1
		BNE .ss_fact
		LDA N
		BEQ .ss_small		; divisor = 256
.ss_fact:
	; n+1 = ceil(divisor/256)
	; = high byte, +1 if low byte nonzero
		LDA N+1			; high byte
		LDX N			; low byte
		BEQ .ss_noinc		; exact multiple of 256
		CLC
		ADC #1			; round up
.ss_noinc:	STA N+2			; N+2 = n+1
	; Divide N+0:N+1 by N+2 (8-bit) → quotient = l+1
	; Save divisor on hardware stack for safety
		LDA N+1
		PHA
		LDA N
		PHA
	; 16÷8 division: dividend N+0:N+1, divisor N+2
		LDA #0			; remainder
		LDX #16
.ss_d8:		ASL N
		ROL N+1
		ROL A
		CMP N+2
		BCC .ss_d8s
		SBC N+2
.ss_d8s:	DEX
		BNE .ss_d8
	; Quotient shifted into N+0 (low 8 bits of quotient)
	; N+0 = l+1
		LDA N			; l+1
		SEC
		SBC #1
		STA N+4			; l
		LDA N+2
		SEC
		SBC #1
		STA N+5			; n
	; Restore divisor (not needed, but clean up stack)
		PLA			; discard saved lo
		PLA			; discard saved hi
		BRA .ss_setreg
.ss_small:
	; divisor ≤ 256: n=0, l=divisor-1
		LDA N
		SEC
		SBC #1
		STA N+4			; l
		STI #0, N+5		; n = 0
.ss_setreg:
	; N+4 = l, N+5 = n
		STI #$00, TBM		; interval timer mode
		LDA N+5
		STA TBLL		; Timer B lower latch = n
		STI #$00, TBUL		; upper latch = 0 (triggers reload)
		LDA N+4
		STA SIDL		; RX divider = l
		STA SODL		; TX divider = l
		STI #$E0, SMR		; enable TXD, RXD, Timer B
		STI #$00, SFR		; normal operation
	; Drop 4 cells from stack
		TYA
		CLC
		ADC #8
		TAY
		TIP

unkn5: 		STA W
    		STI #0, W+1
    		PLA
    		STA TOS
    		PLA
    		STA TOS+1
    		INC TOS
    		BNE L2134
    		INC TOS+1
L2134  		;; Set I = unkn6
    		LDA #>unkn6
    		PHA
    		LDA #<unkn6
    		PHA
    		PLI
    		JMP (W)

unkn6:      DATA.W $005d	; WARNING: JTC indirect semantics differ from DTC

NMIJMP		JMP ($0042)
IRQJMP		JMP ($0040)
    		JPI (OVER)
			JPI (PLUS)
			JPI (PLUS)
			JPI (AT)
    		JPI (EXECUTE)
    		JPI (SEMIS)

L2149:	DATA.W (L2149+2)	; DV
		LDA #$20	
    		BIT DSK_CTL
    		BEQ L2161
    		STA DSK_CTL
    		STI #0, TOS			; outer counter (was Y in original)
    		STI #0, TOS+1			; inner counter (was TOS in original)
L2157  		DEC TOS+1
    		BNE L2157
    		DEC TOS
    		BNE L2157
L2161  		JSR L1836
    		JMP SELECT+2
XKEY:		LDA #0
    		STA DSK_CTL
    		JMP (UKEY)			; → L518 (terminal) or CONKEY (console)
;;
;;    CTLRQ - check for control-R
;;
CTLRQ:	DATA.W (CTLRQ+2)
		PHI
    		JPI (CR)
    		JPI (LIT)
    				DATA.B $00
    				DATA.W SIB
    		JPI (CAT)
    		JPI (CLIT)
    		DATA.B $00, $12, $00			; Control-R
    		JPI (EQUAL)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.CTLRQ_1 - addr)
    		JPI (MMON)
.CTLRQ_1	JPI (SEMIS)
;;
;;    MMON - the micro monitor
;;
MMON:	DATA.W (MMON+2)
		PHI
.MMON_1	JPI (CR)
    		JPI (CLIT)
    		DATA.B $00, '>', $00
    		JPI (EMIT)
    		JPI (HEX)
    		JPI (QUERY)
    		JPI (ZERO)
    		JPI (ZERO)
    		JPI (TIB)
    		JPI (AT)
    		JPI (LTNUMBER)
    		JPI (TWODROP)
    		JPI (TIB)
    		JPI (AT)
    		JPI (CAT)
    		JPI (CLIT)
    		DATA.B $00, 'W', $00
    		JPI (EQUAL)
    		JPI (ZBRAN)
    				DATA.B $00
    				DATA.W (.MMON_2 - addr)
    		JPI (EXECUTE)
.MMON_2	JPI (BRAN)
					DATA.B $00
					DATA.W (.MMON_1 - addr)

;;
;; CONKEY — console keyboard input (reads from ring buffer)
;;
CONKEY:		LDA #0
		STA DSK_CTL		; deselect disk
.KWAIT:		LDA KBUF_HEAD
		CMP KBUF_TAIL
		BEQ .KWAIT		; spin until buffer has data
		LDX KBUF_TAIL
		LDA KBUF,X		; read character
		PHA			; save character
		INX
		TXA
		AND #KBUF_MASK
		STA KBUF_TAIL		; advance tail
		PLA			; restore character
		RTS

;;
;; KBDISR — Keyboard Interrupt Service Routine
;;   Scans matrix via Port D (rows) / Port C (columns).
;;   Uses 8x BBS for fast column decode (no loop).
;;   Called via IRQ0 vector ($FFF0) — PA0 edge detect.
;;
KBDISR:		PHA
		PHX			; save registers
		;; Scan rows: drive each row via Port D, read Port C
		LDX #0			; row index
		STI #$01, PortD		; drive row 0
		LDA PortC
		BNE .KB_FOUND
		LDX #1
		STI #$02, PortD		; drive row 1
		LDA PortC
		BNE .KB_FOUND
		LDX #2
		STI #$04, PortD		; drive row 2
		LDA PortC
		BNE .KB_FOUND
		LDX #3
		STI #$08, PortD		; drive row 3
		LDA PortC
		BNE .KB_FOUND
		LDX #4
		STI #$10, PortD		; drive row 4
		LDA PortC
		BNE .KB_FOUND
		LDX #5
		STI #$20, PortD		; drive row 5
		LDA PortC
		BNE .KB_FOUND
		LDX #6
		STI #$40, PortD		; drive row 6
		LDA PortC
		BNE .KB_FOUND
		LDX #7
		STI #$80, PortD		; drive row 7
		LDA PortC
		BNE .KB_FOUND
		BRA .KB_DONE		; no key found (spurious IRQ)
.KB_FOUND:
		;; A = column bits, X = row number
		;; Use BBS to find column — fast, no loop
		STA N			; save column bits in zp scratch
		TXA
		ASL
		ASL
		ASL			; A = row * 8 (base scancode)
		TAX			; X = base scancode
		BBS 0, N, .KB_GOTCOL
		INX
		BBS 1, N, .KB_GOTCOL
		INX
		BBS 2, N, .KB_GOTCOL
		INX
		BBS 3, N, .KB_GOTCOL
		INX
		BBS 4, N, .KB_GOTCOL
		INX
		BBS 5, N, .KB_GOTCOL
		INX
		BBS 6, N, .KB_GOTCOL
		INX
.KB_GOTCOL:
		;; X = scancode (row*8 + col)
		;; Check modifiers: drive row 6, check SHIFT/CTRL
		STI #$40, PortD
		BBS 0, PortC, .KB_SHIFT
		BBS 1, PortC, .KB_CTRL
		;; No modifier — unshifted lookup
		LDA KEYMAP_NORMAL,X
		BRA .KB_STORE
.KB_SHIFT:
		LDA KEYMAP_SHIFTED,X
		BRA .KB_STORE
.KB_CTRL:
		LDA KEYMAP_NORMAL,X	; get base char
		AND #$1F		; convert to control char
.KB_STORE:
		;; Store character in ring buffer if non-zero
		BEQ .KB_DONE		; skip null entries (modifier keys)
		PHX
		LDX KBUF_HEAD
		STA KBUF,X		; store in buffer
		INX
		TXA
		AND #KBUF_MASK
		STA KBUF_HEAD		; advance head
		PLX
.KB_DONE:
		;; Clear PA0 interrupt flag (CIR bit 6)
		LDA CIR
		AND #$BF		; clear bit 6 (PA0 edge flag)
		STA CIR
		STI #$00, PortD		; deselect all rows
		PLX
		PLA
		RTI

;;
;; Keyboard lookup tables (64 bytes each)
;;
KEYMAP_NORMAL:
	DATA.B '1', '2', '3', '4', '5', '6', '7', '8'
	DATA.B '9', '0', '-', '=', $08, $09, '.', '/'
	DATA.B 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'
	DATA.B 'O', 'P', '[', ']', $0D, 'A', 'S', 'D'
	DATA.B 'F', 'G', 'H', 'J', 'K', 'L', ';', $27
	DATA.B 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ','
	DATA.B $00, $00, '`', '\', ' ', $1B, $7F, $00
	DATA.B $00, $00, $00, $00, $00, $00, $00, $00

KEYMAP_SHIFTED:
	DATA.B '!', '@', '#', '$', '%', '^', '&', '*'
	DATA.B '(', ')', '_', '+', $08, $09, '>', '?'
	DATA.B 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'
	DATA.B 'o', 'p', '{', '}', $0D, 'a', 's', 'd'
	DATA.B 'f', 'g', 'h', 'j', 'k', 'l', ':', '"'
	DATA.B 'z', 'x', 'c', 'v', 'b', 'n', 'm', '<'
	DATA.B $00, $00, '~', '|', ' ', $1B, $7F, $00
	DATA.B $00, $00, $00, $00, $00, $00, $00, $00

;;
;; ============================================================================
;; ST7586S LCD Display Driver (240x160, 40x20 text via 5x7 font in 6x8 cells)
;; ============================================================================
;;

;;
;; LCD_INIT — Initialize ST7586S controller and clear display
;;   Called from COLD in console mode.
;;
LCD_INIT:
		LDA LCD_INITED			; skip if already initialized
		BEQ .LCD_DOINIT			; not yet — go initialize
		RTS
.LCD_DOINIT:	;; Sleep Out
		LDA #$11
		STA LCD_CMD
		;; Display OFF (while configuring)
		LDA #$28
		STA LCD_CMD
		;; Vop = 0x0145
		LDA #$C0
		STA LCD_CMD
		LDA #$45
		STA LCD_DATA
		LDA #$01
		STA LCD_DATA
		;; BIAS = 1/14
		LDA #$C3
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		;; Booster = x8
		LDA #$C4
		STA LCD_CMD
		LDA #$07
		STA LCD_DATA
		;; Enable Analog Circuit
		LDA #$D0
		STA LCD_CMD
		LDA #$1D
		STA LCD_DATA
		;; N-Line = 0
		LDA #$B5
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		;; Monochrome Mode (idle on)
		LDA #$39
		STA LCD_CMD
		;; DDRAM interface = 2 pixels/byte
		LDA #$3A
		STA LCD_CMD
		LDA #$02
		STA LCD_DATA
		;; Scan Direction: MY=0, MX=0 (normal orientation)
		LDA #$36
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		;; Duty = 160
		LDA #$B0
		STA LCD_CMD
		LDA #$9F
		STA LCD_DATA
		;; Inversion OFF
		LDA #$20
		STA LCD_CMD
		;; Scroll Area: TFA=0, VSA=160, BFA=0
		LDA #$33
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA			; TFA hi
		LDA #$00
		STA LCD_DATA			; TFA lo
		LDA #$00
		STA LCD_DATA			; VSA hi
		LDA #$A0
		STA LCD_DATA			; VSA lo (160)
		LDA #$00
		STA LCD_DATA			; BFA hi
		LDA #$00
		STA LCD_DATA			; BFA lo
		;; Scroll Start = 0
		LDA #$37
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		;; Default contrast
		LDA #$C7
		STA LCD_CMD
		LDA #$28
		STA LCD_DATA
		;; Clear cursor state
		STI #0, LCD_COL
		STI #0, LCD_ROW
		STI #0, LCD_TOPPAGE
		;; Clear display
		JSR LCD_CLR
		;; Display ON
		LDA #$29
		STA LCD_CMD
		LDA #$FF
		STA LCD_INITED
		RTS

;;
;; LCD_CLR — Clear visible display RAM (120 cols x 160 rows)
;;   Clobbers A, X
;;
LCD_CLR:
		;; Set column window: COL_OFFSET to COL_OFFSET+119
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA			; SC hi
		LDA #COL_OFFSET
		STA LCD_DATA			; SC lo
		LDA #$00
		STA LCD_DATA			; EC hi
		LDA #(COL_OFFSET+119)
		STA LCD_DATA			; EC lo
		;; Set row window: 0 to 159
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA			; SR hi
		LDA #$00
		STA LCD_DATA			; SR lo
		LDA #$00
		STA LCD_DATA			; ER hi
		LDA #159
		STA LCD_DATA			; ER lo
		;; Write 19,200 = 160 * 120 zero bytes
		LDA #$2C
		STA LCD_CMD
		LDX #160
.CLR_ROW:	PHX
		LDX #120
		LDA #$00
.CLR_BYTE:	STA LCD_DATA
		DEX
		BNE .CLR_BYTE
		PLX
		DEX
		BNE .CLR_ROW
		RTS

;;
;; LCD_SETPOS — Set ST7586S window for character cell, issue 0x2C
;;   Page = (LCD_TOPPAGE + LCD_ROW) mod 20
;;   Byte column = LCD_COL * 3 + COL_OFFSET
;;   Clobbers A, N, N+1
;;
LCD_SETPOS:
		;; RAM row = ((LCD_TOPPAGE + LCD_ROW) mod 20) * 8
		LDA LCD_TOPPAGE
		CLC
		ADC LCD_ROW
		CMP #20
		BCC .SP_OK
		SBC #20
.SP_OK:		ASL A
		ASL A
		ASL A				; * 8 = RAM row start
		STA N				; row_start
		;; Byte column = LCD_COL * 3 + COL_OFFSET
		LDA LCD_COL
		STA N+1
		ASL A				; *2
		CLC
		ADC N+1				; *3
		CLC
		ADC #COL_OFFSET
		STA N+1				; byte_col_start
		;; Column Address Set (0x2A)
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N+1
		STA LCD_DATA			; col start
		LDA #$00
		STA LCD_DATA
		LDA N+1
		CLC
		ADC #2
		STA LCD_DATA			; col end (start + 2)
		;; Row Address Set (0x2B)
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA			; row start
		LDA #$00
		STA LCD_DATA
		LDA N
		CLC
		ADC #7
		STA LCD_DATA			; row end (start + 7)
		;; Memory Write
		LDA #$2C
		STA LCD_CMD
		RTS

;; Pixel pair lookup: index = (left_bit << 1) | right_bit
;; Maps 2-bit pair to ST7586S byte encoding
PIX_PAIR:	DATA.B $00, $18, $C0, $D8

;;
;; LCD_PUTCH — Write character glyph at current cursor position
;;   A = character code (0-255)
;;   Preserves Y (data stack pointer)
;;   Clobbers A, X, N, N+1, W
;;
LCD_PUTCH:
		PHA				; save character
		JSR LCD_SETPOS			; set window + 0x2C
		PLA				; restore character
		;; Calculate font address: FONT5X7 + (char & $7F) * 8
		AND #$7F			; clamp to 0-127
		STA N
		STI #0, N+1
		ASL A
		ROL N+1
		ASL A
		ROL N+1
		ASL A
		ROL N+1				; A:N+1 = char * 8 (lo in A)
		CLC
		ADC #<FONT5X7
		STA N
		LDA N+1
		ADC #>FONT5X7
		STA N+1				; N:N+1 = font row address
		;; Row loop: 8 rows using X as index (RC19 uses (zp),X not (zp),Y)
		PHY				; save data stack pointer
		LDX #0				; row index
.ROW:		LDA (N),X			; load row byte (bit4=col0 ... bit0=col4)
		STA W				; save for reuse
		PHX				; save row counter
		;; Pair 0 (cols 0,1): (row >> 3) & 3
		LSR A
		LSR A
		LSR A
		AND #$03
		TAX
		LDA PIX_PAIR,X
		STA LCD_DATA
		;; Pair 1 (cols 2,3): (row >> 1) & 3
		LDA W
		LSR A
		AND #$03
		TAX
		LDA PIX_PAIR,X
		STA LCD_DATA
		;; Pair 2 (col 4, blank=0): (row & 1) << 1
		LDA W
		AND #$01
		ASL A
		TAX
		LDA PIX_PAIR,X
		STA LCD_DATA
		;; Next row
		PLX				; restore row counter
		INX
		CPX #8
		BNE .ROW
		PLY				; restore data stack pointer
		RTS

;;
;; LCD_XEMIT — Character output for LCD (UEMIT vector target)
;;   On entry: A = character
;;   Preserves Y (data stack pointer)
;;   Returns via RTS
;;
LCD_XEMIT:
		CMP #$0D			; carriage return?
		BEQ .LX_CR
		CMP #$0A			; line feed?
		BEQ .LX_LF
		CMP #$08			; backspace?
		BEQ .LX_BS
		CMP #$00			; null? (CR word sends CR,LF,NUL)
		BEQ .LX_NUL
		;; Normal printable character
		JSR LCD_PUTCH
		;; Advance cursor column
		INC LCD_COL
		LDA LCD_COL
		CMP #40
		BCS .LX_WRAP			; column overflow
		RTS
.LX_WRAP:	;; Column overflow — wrap to next line
		STI #0, LCD_COL
		BRA .LX_LF
.LX_CR:		STI #0, LCD_COL			; carriage return: column = 0
		RTS
.LX_BS:		;; Backspace: move cursor left (EMIT handles erase)
		LDA LCD_COL
		BEQ .LX_NUL			; already at column 0, return
		DEC LCD_COL
.LX_NUL:	RTS				; ignore null bytes / return
.LX_LF:	;; Line feed: advance to next row
		INC LCD_ROW
		LDA LCD_ROW
		CMP #20
		BCC .LX_RET			; still on screen
		;; Scroll: row 19 stays, advance top page
		LDA #19
		STA LCD_ROW
		INC LCD_TOPPAGE
		LDA LCD_TOPPAGE
		CMP #20				; mod 20
		BCC .LX_NOWRAP
		LDA #0
.LX_NOWRAP:	STA LCD_TOPPAGE
		;; Set scroll start = LCD_TOPPAGE * 8
		ASL A
		ASL A
		ASL A
		PHA
		LDA #$37			; Set Scroll Start Address
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA			; VSP hi
		PLA
		STA LCD_DATA			; VSP lo
		;; Clear the new bottom row
		JSR LCD_CLR_ROW
		;; Clear ghost row above visible
		LDA LCD_TOPPAGE
		SEC
		SBC #1
		BPL .LX_GHOST
		LDA #19				; wrap 0 → 19
.LX_GHOST:	;; Calculate ghost RAM row = page * 8
		ASL A
		ASL A
		ASL A
		STA N
		;; Set window for ghost row clear
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA #COL_OFFSET
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA #(COL_OFFSET+119)
		STA LCD_DATA
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA N
		CLC
		ADC #7
		STA LCD_DATA
		LDA #$2C
		STA LCD_CMD
		LDX #8
.LX_GR:	PHX
		LDX #120
		LDA #$00
.LX_GB:	STA LCD_DATA
		DEX
		BNE .LX_GB
		PLX
		DEX
		BNE .LX_GR
.LX_RET:	RTS

;;
;; LCD_CLR_ROW — Clear current bottom text row (8 pixel rows)
;;   Clobbers A, X, N
;;
LCD_CLR_ROW:
		LDA LCD_TOPPAGE
		CLC
		ADC LCD_ROW
		CMP #20				; mod 20
		BCC .LCR_OK
		SBC #20
.LCR_OK:	ASL A
		ASL A
		ASL A				; row_start
		STA N
		;; Set window: full width, 8 rows
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA #COL_OFFSET
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA #(COL_OFFSET+119)
		STA LCD_DATA
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA N
		CLC
		ADC #7
		STA LCD_DATA
		;; Write 120*8 = 960 zero bytes
		LDA #$2C
		STA LCD_CMD
		LDX #8
.LCR_ROW:	PHX
		LDX #120
		LDA #$00
.LCR_BYTE:	STA LCD_DATA
		DEX
		BNE .LCR_BYTE
		PLX
		DEX
		BNE .LCR_ROW
		RTS

;;
;; LCDCLR — Forth word: clear LCD and reset cursor ( -- )
;;
LCDCLR:		DATA.W (LCDCLR+2)
		STI #0, LCD_COL
		STI #0, LCD_ROW
		STI #0, LCD_TOPPAGE
		;; Reset scroll start to 0
		LDA #$37
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		JSR LCD_CLR
		TIP

;;
;; LCDAT — Forth word: set LCD cursor position ( col row -- )
;;
LCDAT:		DATA.W (LCDAT+2)
		LDA stack,Y			; row (low byte)
		STA LCD_ROW
		LDA stack+2,Y			; col (low byte)
		STA LCD_COL
		JMP POPTWO

;;
;;    CONTRAST ( n -- ) — set LCD contrast via ST7586S Vop offset
;;
CONTRAST:	DATA.W (CONTRAST+2)
		LDA #$C7
		STA LCD_CMD
		LDA stack,Y			; contrast value
		STA LCD_DATA
		JMP POP

; 5x7 Font Table — Row-based format for ST7586S
; 128 characters x 8 bytes = 1024 bytes (chars 0-127, LCD_PUTCH masks with $7F)
; Each byte is one row: bit4=col0, bit3=col1, bit2=col2, bit1=col3, bit0=col4
;
FONT5X7:
	DATA.B $00, $00, $00, $00, $00, $00, $00, $00  ;   0
	DATA.B $0E, $1F, $15, $1F, $1B, $11, $0E, $00  ;   1
	DATA.B $0E, $1F, $15, $1F, $11, $1B, $0E, $00  ;   2
	DATA.B $00, $0A, $1F, $1F, $1F, $0E, $04, $00  ;   3
	DATA.B $00, $04, $0E, $1F, $1F, $0E, $04, $00  ;   4
	DATA.B $0E, $0A, $1F, $15, $1F, $04, $0E, $00  ;   5
	DATA.B $04, $0E, $1F, $1F, $1F, $04, $0E, $00  ;   6
	DATA.B $00, $00, $04, $0E, $0E, $04, $00, $00  ;   7
	DATA.B $1F, $1F, $1B, $11, $11, $1B, $1F, $1F  ;   8
	DATA.B $00, $00, $04, $0A, $0A, $04, $00, $00  ;   9
	DATA.B $1F, $1F, $1B, $15, $15, $1B, $1F, $1F  ;  10
	DATA.B $00, $07, $03, $0D, $14, $14, $08, $00  ;  11
	DATA.B $0E, $11, $11, $0E, $04, $1F, $04, $00  ;  12
	DATA.B $0F, $09, $0F, $08, $08, $08, $18, $00  ;  13
	DATA.B $0F, $09, $0F, $09, $09, $0B, $18, $00  ;  14
	DATA.B $04, $15, $0E, $1B, $1B, $0E, $15, $04  ;  15
	DATA.B $10, $18, $1E, $1F, $1E, $18, $10, $00  ;  16
	DATA.B $01, $03, $0F, $1F, $0F, $03, $01, $00  ;  17
	DATA.B $04, $0E, $15, $04, $15, $0E, $04, $00  ;  18
	DATA.B $1B, $1B, $1B, $1B, $1B, $00, $1B, $00  ;  19
	DATA.B $0F, $15, $15, $0D, $05, $05, $05, $00  ;  20
	DATA.B $06, $09, $0A, $05, $02, $09, $09, $06  ;  21
	DATA.B $00, $00, $00, $00, $00, $1F, $1F, $00  ;  22
	DATA.B $04, $0E, $15, $04, $15, $0E, $04, $1F  ;  23
	DATA.B $00, $04, $0E, $15, $04, $04, $04, $00  ;  24
	DATA.B $00, $04, $04, $04, $15, $0E, $04, $00  ;  25
	DATA.B $00, $04, $02, $1F, $02, $04, $00, $00  ;  26
	DATA.B $00, $04, $08, $1F, $08, $04, $00, $00  ;  27
	DATA.B $00, $10, $10, $10, $1F, $00, $00, $00  ;  28
	DATA.B $00, $0A, $1F, $1F, $0A, $00, $00, $00  ;  29
	DATA.B $00, $04, $04, $0E, $1F, $1F, $00, $00  ;  30
	DATA.B $00, $1F, $1F, $0E, $04, $04, $00, $00  ;  31
	DATA.B $00, $00, $00, $00, $00, $00, $00, $00  ;  32 ' '
	DATA.B $04, $04, $04, $04, $04, $00, $04, $00  ;  33 '!'
	DATA.B $0A, $0A, $0A, $00, $00, $00, $00, $00  ;  34 '"'
	DATA.B $0A, $0A, $1F, $0A, $1F, $0A, $0A, $00  ;  35 '#'
	DATA.B $04, $0F, $14, $0E, $05, $1E, $04, $00  ;  36 '$'
	DATA.B $18, $19, $02, $04, $08, $13, $03, $00  ;  37 '%'
	DATA.B $08, $14, $14, $08, $15, $12, $0D, $00  ;  38 '&'
	DATA.B $06, $06, $04, $08, $00, $00, $00, $00  ;  39 '''
	DATA.B $02, $04, $08, $08, $08, $04, $02, $00  ;  40 '('
	DATA.B $08, $04, $02, $02, $02, $04, $08, $00  ;  41 ')'
	DATA.B $04, $15, $0E, $1F, $0E, $15, $04, $00  ;  42 '*'
	DATA.B $00, $04, $04, $1F, $04, $04, $00, $00  ;  43 '+'
	DATA.B $00, $00, $00, $00, $06, $06, $04, $08  ;  44 ','
	DATA.B $00, $00, $00, $1F, $00, $00, $00, $00  ;  45 '-'
	DATA.B $00, $00, $00, $00, $00, $06, $06, $00  ;  46 '.'
	DATA.B $00, $01, $02, $04, $08, $10, $00, $00  ;  47 '/'
	DATA.B $0E, $11, $13, $15, $19, $11, $0E, $00  ;  48 '0'
	DATA.B $04, $0C, $04, $04, $04, $04, $0E, $00  ;  49 '1'
	DATA.B $0E, $11, $01, $0E, $10, $10, $1F, $00  ;  50 '2'
	DATA.B $1F, $01, $02, $06, $01, $11, $0E, $00  ;  51 '3'
	DATA.B $02, $06, $0A, $12, $1F, $02, $02, $00  ;  52 '4'
	DATA.B $1F, $10, $1E, $01, $01, $11, $0E, $00  ;  53 '5'
	DATA.B $07, $08, $10, $1E, $11, $11, $0E, $00  ;  54 '6'
	DATA.B $1F, $01, $01, $02, $04, $08, $10, $00  ;  55 '7'
	DATA.B $0E, $11, $11, $0E, $11, $11, $0E, $00  ;  56 '8'
	DATA.B $0E, $11, $11, $0F, $01, $02, $1C, $00  ;  57 '9'
	DATA.B $00, $00, $04, $00, $04, $00, $00, $00  ;  58 ':'
	DATA.B $00, $00, $04, $00, $04, $04, $08, $00  ;  59 ';'
	DATA.B $01, $02, $04, $08, $04, $02, $01, $00  ;  60 '<'
	DATA.B $00, $00, $1F, $00, $1F, $00, $00, $00  ;  61 '='
	DATA.B $08, $04, $02, $01, $02, $04, $08, $00  ;  62 '>'
	DATA.B $0E, $11, $01, $06, $04, $00, $04, $00  ;  63 '?'
	DATA.B $0E, $11, $15, $17, $16, $10, $0F, $00  ;  64 '@'
	DATA.B $04, $0A, $11, $11, $1F, $11, $11, $00  ;  65 'A'
	DATA.B $1E, $11, $11, $1E, $11, $11, $1E, $00  ;  66 'B'
	DATA.B $0E, $11, $10, $10, $10, $11, $0E, $00  ;  67 'C'
	DATA.B $1E, $11, $11, $11, $11, $11, $1E, $00  ;  68 'D'
	DATA.B $1F, $10, $10, $1E, $10, $10, $1F, $00  ;  69 'E'
	DATA.B $1F, $10, $10, $1E, $10, $10, $10, $00  ;  70 'F'
	DATA.B $0F, $11, $10, $10, $13, $11, $0F, $00  ;  71 'G'
	DATA.B $11, $11, $11, $1F, $11, $11, $11, $00  ;  72 'H'
	DATA.B $0E, $04, $04, $04, $04, $04, $0E, $00  ;  73 'I'
	DATA.B $07, $02, $02, $02, $02, $12, $0C, $00  ;  74 'J'
	DATA.B $11, $12, $14, $18, $14, $12, $11, $00  ;  75 'K'
	DATA.B $10, $10, $10, $10, $10, $10, $1F, $00  ;  76 'L'
	DATA.B $11, $1B, $15, $15, $15, $11, $11, $00  ;  77 'M'
	DATA.B $11, $11, $19, $15, $13, $11, $11, $00  ;  78 'N'
	DATA.B $0E, $11, $11, $11, $11, $11, $0E, $00  ;  79 'O'
	DATA.B $1E, $11, $11, $1E, $10, $10, $10, $00  ;  80 'P'
	DATA.B $0E, $11, $11, $11, $15, $12, $0D, $00  ;  81 'Q'
	DATA.B $1E, $11, $11, $1E, $14, $12, $11, $00  ;  82 'R'
	DATA.B $0E, $11, $10, $0E, $01, $11, $0E, $00  ;  83 'S'
	DATA.B $1F, $15, $04, $04, $04, $04, $04, $00  ;  84 'T'
	DATA.B $11, $11, $11, $11, $11, $11, $0E, $00  ;  85 'U'
	DATA.B $11, $11, $11, $11, $11, $0A, $04, $00  ;  86 'V'
	DATA.B $11, $11, $11, $15, $15, $15, $0A, $00  ;  87 'W'
	DATA.B $11, $11, $0A, $04, $0A, $11, $11, $00  ;  88 'X'
	DATA.B $11, $11, $0A, $04, $04, $04, $04, $00  ;  89 'Y'
	DATA.B $1F, $01, $02, $0E, $08, $10, $1F, $00  ;  90 'Z'
	DATA.B $0F, $08, $08, $08, $08, $08, $0F, $00  ;  91 '['
	DATA.B $00, $10, $08, $04, $02, $01, $00, $00  ;  92 '\'
	DATA.B $0F, $01, $01, $01, $01, $01, $0F, $00  ;  93 ']'
	DATA.B $04, $0A, $11, $00, $00, $00, $00, $00  ;  94 '^'
	DATA.B $00, $00, $00, $00, $00, $00, $1F, $00  ;  95 '_'
	DATA.B $0C, $0C, $04, $02, $00, $00, $00, $00  ;  96 '`'
	DATA.B $00, $00, $0C, $02, $0E, $12, $0F, $00  ;  97 'a'
	DATA.B $10, $10, $16, $19, $11, $19, $16, $00  ;  98 'b'
	DATA.B $00, $00, $0E, $11, $10, $11, $0E, $00  ;  99 'c'
	DATA.B $01, $01, $0D, $13, $11, $13, $0D, $00  ; 100 'd'
	DATA.B $00, $00, $0E, $11, $1F, $10, $0E, $00  ; 101 'e'
	DATA.B $02, $05, $04, $0E, $04, $04, $04, $00  ; 102 'f'
	DATA.B $00, $00, $0E, $13, $13, $0D, $01, $0E  ; 103 'g'
	DATA.B $10, $10, $16, $19, $11, $11, $11, $00  ; 104 'h'
	DATA.B $04, $00, $0C, $04, $04, $04, $0E, $00  ; 105 'i'
	DATA.B $02, $00, $02, $02, $02, $12, $0C, $00  ; 106 'j'
	DATA.B $10, $10, $12, $14, $18, $14, $12, $00  ; 107 'k'
	DATA.B $0C, $04, $04, $04, $04, $04, $0E, $00  ; 108 'l'
	DATA.B $00, $00, $1A, $15, $15, $15, $15, $00  ; 109 'm'
	DATA.B $00, $00, $16, $19, $11, $11, $11, $00  ; 110 'n'
	DATA.B $00, $00, $0E, $11, $11, $11, $0E, $00  ; 111 'o'
	DATA.B $00, $00, $16, $19, $19, $16, $10, $10  ; 112 'p'
	DATA.B $00, $00, $0D, $13, $13, $0D, $01, $01  ; 113 'q'
	DATA.B $00, $00, $16, $19, $10, $10, $10, $00  ; 114 'r'
	DATA.B $00, $00, $0F, $10, $0E, $01, $1E, $00  ; 115 's'
	DATA.B $04, $04, $1F, $04, $04, $05, $02, $00  ; 116 't'
	DATA.B $00, $00, $11, $11, $11, $13, $0D, $00  ; 117 'u'
	DATA.B $00, $00, $11, $11, $11, $0A, $04, $00  ; 118 'v'
	DATA.B $00, $00, $11, $11, $15, $15, $0A, $00  ; 119 'w'
	DATA.B $00, $00, $11, $0A, $04, $0A, $11, $00  ; 120 'x'
	DATA.B $00, $00, $11, $11, $0F, $01, $11, $0E  ; 121 'y'
	DATA.B $00, $00, $1F, $02, $04, $08, $1F, $00  ; 122 'z'
	DATA.B $02, $04, $04, $08, $04, $04, $02, $00  ; 123 '{'
	DATA.B $04, $04, $04, $00, $04, $04, $04, $00  ; 124 '|'
	DATA.B $08, $04, $04, $02, $04, $04, $08, $00  ; 125 '}'
	DATA.B $08, $15, $02, $00, $00, $00, $00, $00  ; 126 '~'
	DATA.B $04, $0E, $1B, $11, $11, $1F, $00, $00  ; 127
; End of font table (1024 bytes, chars 0-127)

;; ============================================================================
;; Graphics drawing primitives (ST7586S windowed read-modify-write)
;; ============================================================================

;;
;; LCD_SETPIXEL — Set a single pixel on the LCD
;;   Reads GFX_X (0-239) and GFX_Y (0-159)
;;   Uses windowed read-modify-write for ST7586S
;;   Preserves: Y (data stack pointer)
;;   Clobbers: A, X, N, N+1
;;
LCD_SETPIXEL:
		;; byte_col = GFX_X / 2 + COL_OFFSET
		LDA GFX_X
		LSR A
		CLC
		ADC #COL_OFFSET
		STA N			; byte_col
		;; pixel_pos = GFX_X & 1
		LDA GFX_X
		AND #$01
		STA N+1			; 0=left, 1=right
		;; Set single-byte window
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA		; col start
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA		; col end = col start
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA		; row start
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA		; row end = row start
		;; Read current byte (0x2E + dummy + actual)
		LDA #$2E
		STA LCD_CMD
		LDA LCD_DATA		; dummy read
		LDA LCD_DATA		; actual byte
		;; OR in the pixel
		LDX N+1
		BNE .SP_R
		ORA #$C0		; left pixel: set bits 7:6
		BRA .SP_W
.SP_R:		ORA #$18		; right pixel: set bits 4:3
		;; Re-set window and write back
.SP_W:		PHA
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		LDA #$2C
		STA LCD_CMD
		PLA
		STA LCD_DATA
		RTS

;;
;; MOVETO ( x y -- ) — set graphics cursor position
;;
MOVETO:		DATA.W (MOVETO+2)
		LDA stack,Y		; y
		STA GFX_Y
		LDA stack+2,Y		; x
		STA GFX_X
		JMP POPTWO

;;
;; LINETO ( x y -- ) — draw line from cursor to (x,y), update cursor
;;   Uses Bresenham's algorithm with fast paths for H and V lines.
;;   N area: N+0=dx, N+1=abs_dy, N+2=sx, N+3=sy, N+4/5=err(16), N+6=x1, N+7=y1
;;   W area: W/W+1 used as e2 temporary (safe in code words)
;;
LINETO:		DATA.W (LINETO+2)
		;; Save target coordinates, pop stack
		LDA stack,Y		; y1
		STA N+7
		LDA stack+2,Y		; x1
		STA N+6
		INY			; pop two cells
		INY
		INY
		INY
		;; Check for horizontal line (y0 == y1)
		LDA N+7
		CMP GFX_Y
		BNE .LT_not_h
		JMP .LT_hline
.LT_not_h:
		;; Check for vertical line (x0 == x1)
		LDA N+6
		CMP GFX_X
		BNE .LT_not_v
		JMP .LT_vline
.LT_not_v:
		;; ---- General Bresenham ----
		;; Compute dx = abs(x1 - x0), sx
		LDA N+6
		SEC
		SBC GFX_X
		BCC .LT_sx_neg
		STA N+0			; dx
		STI #1, N+2		; sx = +1
		BRA .LT_comp_dy
.LT_sx_neg:	EOR #$FF
		CLC
		ADC #1
		STA N+0			; dx = abs(x1-x0)
		STI #$FF, N+2		; sx = -1
.LT_comp_dy:	;; Compute abs_dy = abs(y1 - y0), sy
		LDA N+7
		SEC
		SBC GFX_Y
		BCC .LT_sy_neg
		STA N+1			; abs_dy
		STI #1, N+3		; sy = +1
		BRA .LT_comp_err
.LT_sy_neg:	EOR #$FF
		CLC
		ADC #1
		STA N+1			; abs_dy = abs(y1-y0)
		STI #$FF, N+3		; sy = -1
.LT_comp_err:	;; err = dx - abs_dy (16-bit signed)
		SEC
		LDA N+0
		SBC N+1
		STA N+4			; err_lo
		LDA #0
		SBC #0
		STA N+5			; err_hi
		;; ---- Bresenham loop ----
.LT_loop:	JSR LCD_SETPIXEL
		;; Done check: GFX_X == x1 && GFX_Y == y1
		LDA GFX_X
		CMP N+6
		BNE .LT_step
		LDA GFX_Y
		CMP N+7
		BEQ .LT_done
.LT_step:	;; e2 = 2 * err, store in W:W+1
		LDA N+4
		ASL A
		STA W			; e2_lo
		LDA N+5
		ROL A
		STA W+1			; e2_hi
		;; Test: e2 >= -abs_dy (i.e., e2 + abs_dy >= 0)
		CLC
		LDA W			; e2_lo
		ADC N+1			; + abs_dy (unsigned, <=63)
		LDA W+1			; e2_hi
		ADC #0			; + carry
		BMI .LT_skip_x		; negative -> skip X step
		;; err -= abs_dy
		SEC
		LDA N+4
		SBC N+1
		STA N+4
		BCS .LT_no_bx
		DEC N+5
.LT_no_bx:	;; x0 += sx
		LDA GFX_X
		CLC
		ADC N+2			; sx (+1 or $FF=-1)
		STA GFX_X
.LT_skip_x:	;; Test: e2 <= dx (i.e., dx - e2 >= 0)
		SEC
		LDA N+0			; dx_lo
		SBC W			; - e2_lo
		LDA #0			; dx_hi = 0
		SBC W+1			; - e2_hi
		BMI .LT_skip_y		; negative -> skip Y step
		;; err += dx
		CLC
		LDA N+4
		ADC N+0
		STA N+4
		BCC .LT_no_cy
		INC N+5
.LT_no_cy:	;; y0 += sy
		LDA GFX_Y
		CLC
		ADC N+3			; sy (+1 or $FF=-1)
		STA GFX_Y
.LT_skip_y:	JMP .LT_loop
.LT_done:	TIP

		;; ---- Horizontal line (y0 == y1) ----
.LT_hline:	LDA N+6
		CMP GFX_X
		BCS .LT_hright
.LT_hleft:	JSR LCD_SETPIXEL
		LDA GFX_X
		CMP N+6
		BEQ .LT_hdone
		DEC GFX_X
		BRA .LT_hleft
.LT_hright:	JSR LCD_SETPIXEL
		LDA GFX_X
		CMP N+6
		BEQ .LT_hdone
		INC GFX_X
		BRA .LT_hright
.LT_hdone:	LDA N+6
		STA GFX_X
		TIP

		;; ---- Vertical line (x0 == x1) ----
.LT_vline:	LDA N+7
		CMP GFX_Y
		BCS .LT_vdown
.LT_vup:	JSR LCD_SETPIXEL
		LDA GFX_Y
		CMP N+7
		BEQ .LT_vdone
		DEC GFX_Y
		BRA .LT_vup
.LT_vdown:	JSR LCD_SETPIXEL
		LDA GFX_Y
		CMP N+7
		BEQ .LT_vdone
		INC GFX_Y
		BRA .LT_vdown
.LT_vdone:	LDA N+7
		STA GFX_Y
		TIP

;;
;;    PIXEL ( x y c -- ) — set or clear a single LCD pixel
;;      x=0-239, y=0-159, c=0 clear / c=1 set
;;      Uses ST7586S windowed read-modify-write
;;
PIXEL:	DATA.W (PIXEL+2)
		LDA stack,Y		; c
		STA W			; save c
		LDA stack+2,Y		; y
		STA GFX_Y
		LDA stack+4,Y		; x
		STA GFX_X
		INY			; pop 3 cells
		INY
		INY
		INY
		INY
		INY
		;; byte_col = GFX_X / 2 + COL_OFFSET
		LDA GFX_X
		LSR A
		CLC
		ADC #COL_OFFSET
		STA N			; byte_col
		;; pixel_pos = GFX_X & 1
		LDA GFX_X
		AND #$01
		STA N+1			; 0=left, 1=right
		;; Pixel mask: left=$C0, right=$18
		LDX N+1
		BNE .PX_RMASK
		LDA #$C0
		BRA .PX_HMASK
.PX_RMASK:	LDA #$18
.PX_HMASK:	STA N+2			; pixel mask
		;; Set single-byte window
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		;; Read current byte
		LDA #$2E
		STA LCD_CMD
		LDA LCD_DATA		; dummy
		LDA LCD_DATA		; actual
		;; Set or clear
		LDX W			; check c
		BNE .PX_SET
		;; Clear: A = A AND ~mask
		EOR #$FF
		ORA N+2
		EOR #$FF
		BRA .PX_WR
.PX_SET:	ORA N+2			; Set: A = A OR mask
.PX_WR:	PHA
		;; Re-set window for write
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA N
		STA LCD_DATA
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA
		LDA #$2C
		STA LCD_CMD
		PLA
		STA LCD_DATA
		TIP

;;
;;    FILLRECT ( x y w h c -- ) — fill an LCD rectangle
;;      x=0-239, y=0-159, w=width, h=height, c=0 clear / c=1 set
;;      Row-based: processes each pixel row, writes full byte columns.
;;
GFXFILL:	DATA.W (GFXFILL+2)
		;; Pop ( x y w h c -- )
		LDA stack,Y		; c
		STA N
		LDA stack+2,Y		; h
		STA N+7
		LDA stack+4,Y		; w
		STA N+3
		LDA stack+6,Y		; y
		STA GFX_Y
		LDA stack+8,Y		; x
		STA GFX_X
		;; Pop 5 cells = 10 bytes
		INY
		INY
		INY
		INY
		INY
		INY
		INY
		INY
		INY
		INY
		;; x_end = x + w - 1
		LDA GFX_X
		CLC
		ADC N+3
		SEC
		SBC #1
		STA N+3			; x_end (pixel)
		;; y_end = y + h - 1
		LDA GFX_Y
		CLC
		ADC N+7
		SEC
		SBC #1
		STA N+4			; y_end
		;; Fill byte: $D8 (both pixels on) for set, $00 for clear
		LDA N
		BEQ .FR_FCLR
		LDA #$D8
		BRA .FR_FS
.FR_FCLR:	LDA #$00
.FR_FS:		STA N+5			; fill_byte
		;; byte_col_start = GFX_X / 2 + COL_OFFSET
		LDA GFX_X
		LSR A
		CLC
		ADC #COL_OFFSET
		STA N+1			; byte_col_start
		;; byte_col_end = x_end / 2 + COL_OFFSET
		LDA N+3
		LSR A
		CLC
		ADC #COL_OFFSET
		STA N+2			; byte_col_end
		;; Set window covering the byte columns x row range
		LDA #$2A
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA N+1
		STA LCD_DATA		; col start
		LDA #$00
		STA LCD_DATA
		LDA N+2
		STA LCD_DATA		; col end
		LDA #$2B
		STA LCD_CMD
		LDA #$00
		STA LCD_DATA
		LDA GFX_Y
		STA LCD_DATA		; row start
		LDA #$00
		STA LCD_DATA
		LDA N+4
		STA LCD_DATA		; row end
		;; Write fill data
		LDA #$2C
		STA LCD_CMD
		;; Outer: rows (GFX_Y to y_end)
.FR_RLOOP:	;; Inner: byte columns (N+1 to N+2)
		LDA N+1
		STA N+6			; cur_col
.FR_CLOOP:	LDA N+5			; fill_byte
		STA LCD_DATA
		INC N+6
		LDA N+6
		CMP N+2
		BCC .FR_CLOOP
		BEQ .FR_CLOOP
		;; Next row
		INC GFX_Y
		LDA GFX_Y
		CMP N+4
		BCC .FR_RLOOP
		BEQ .FR_RLOOP
		TIP

			FILL ($FFE0 - addr), $FF	; pad to vectors

	;;  FFE0
JSB0:		DATA.W NMIJMP
JSB1:		DATA.W NMIJMP
JSB2:		DATA.W NMIJMP
JSB3:		DATA.W NMIJMP
JSB4:		DATA.W NMIJMP
JSB5:		DATA.W NMIJMP
JSB6:		DATA.W NMIJMP
JSB7:		DATA.W NMIJMP

	;; FFF0 - FFFB
	if CONSOLE_MODE {
IRQ0:	    DATA.W KBDISR		; PA0 edge detect → keyboard ISR
	} else {
IRQ0:	    DATA.W IRQJMP
	}
IRQ1:	    DATA.W IRQJMP
IRQ2:	    DATA.W IRQJMP
IRQ3:	    DATA.W IRQJMP
IRQ4:	    DATA.W IRQJMP
IRQ5:	    DATA.W IRQJMP
	
NMIVEC_:    DATA.W NMIJMP ; FFFC
RESETVEC:	DATA.W RESET  ; FFFE

	;; ELF entry point for em16 emulator
	entry := RESET
