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

	;; 6551 ACIA (L28 I/O at $0000-$003F)
	ACIA_DATA := $0000			; Data register (read/write)
	ACIA_STATUS := $0001		; Status register (read)
	ACIA_CMD := $0002			; Command register (write)
	ACIA_CTL := $0003			; Control register (write)
	;; Status register bits:
	;;   Bit 4: TDRE — Transmitter Data Register Empty (1=ready)
	;;   Bit 3: RDRF — Receiver Data Register Full (1=data available)

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

	;; Data stack is in page 2, indexed by Y
	stack := $0200

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
		DSK_BASE := $0800
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
	This is a 4k ROM starting at $F400, but the first $400 bytes are not used
*)

    		ORG := $f000


;; Data table of initial values for registers, used by INIT
;; Offsets: TIBX(0) RO(2) SO(4) UC_L(6) UPAD(8) UR_W(10) BASE(12)
INITTAB:    DATA.W $0380, $00c2, $00ff, $0050
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
.TXWAIT		LDA ACIA_STATUS		; check 6551 status
    		AND #$10			; bit 4 = TDRE
    		BEQ .TXWAIT			; loop until TX ready
    		PLA
    		STA ACIA_DATA		; write character
    		RTS
;;
;;    KEY
;;
KEY:	DATA.W (KEY+2)
		JSR L517	
    		JMP PUSH0A
L517   		JMP (UKEY)
L518   		LDA ACIA_STATUS		; check 6551 status
    		AND #$08			; bit 3 = RDRF
    		BEQ L518			; loop until RX data available
    		LDA ACIA_DATA		; read character
    		RTS
;;
;;    ?TERMINAL
;;
QTERM:	DATA.W (QTERM+2)
		LDA ACIA_STATUS	
    		AND #$08			; bit 3 = RDRF
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
    		;; Initialize 6551 ACIA
    		LDA ACIA_STATUS		; soft reset (read status clears)
    		STI #$0B, ACIA_CMD		; command: no parity, RTS low, TX enabled,
    						;          DTR low, RX IRQ disabled
    		STI #$1E, ACIA_CTL		; control: 8 data bits, 1 stop bit, 9600 baud

    		STI #<XEMIT, UEMIT
    		STI #>XEMIT, UEMIT+1
    		STI #<XKEY, UKEY
    		STI #>XKEY, UKEY+1
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
;;
;;    EEC! - placeholder for L28
;;
EECSTORE:	DATA.W (EECSTORE+2)
		LDX #4	
    		LDA stack+3,Y
L2046  		ROR A
    		PHA
    		LDA stack+2,Y
    		ROR A
    		STA stack+2,Y
    		PLA
    		DEX
    		BNE L2046
    		LDX stack+2,Y
    		STX PortD
    		ROR A
    		ROR A
    		PHP
    		LSR A
    		PLP
    		ROR A
    		SEC
    		ROR A
    		STA PortC
    		LDA #$60
    		NOP
    		NOP
    		LDA stack+4,Y
		NOP
		NOP
    		STA PortD
    		LDA stack,Y
    		STA LCBCLR
    		LDA stack+1,Y
    		STA LCB
	L2071  	NOP
		NOP
		NOP
    	NOP
		NOP
    		LDA #$e0
    		NOP
    		NOP
    		INY
    		INY
    		JMP POPTWO
;;
;;
;;
BANKPSH:	DATA.W (BANKPSH+2)
		JMP POP	
;;
;;
;;
BANKPOP:	DATA.W (BANKPOP+2)	; DV
		PLI
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
BANKEECS:	DATA.W (BANKEECS+2)
		PHI
    		JPI (BANKPSH)
    		JPI (EECSTORE)
    		JPI (BANKPOP)
;;
;;
;;
BANKEXEC:	DATA.W (BANKEXEC+2)
		PHI
    		JPI (BANKPSH)
    		JPI (EXECUTE)
    		JPI (BANKPOP)

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
    		JMP L518
;;
;;    CTLRQ - check for control-R
;;
CTLRQ:	DATA.W (CTLRQ+2)
		PHI
    		JPI (CR)
    		JPI (LIT)
    				DATA.B $00
    				DATA.W ACIA_DATA
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
IRQ0:	    DATA.W IRQJMP
IRQ1:	    DATA.W IRQJMP
IRQ2:	    DATA.W IRQJMP
IRQ3:	    DATA.W IRQJMP
IRQ4:	    DATA.W IRQJMP
IRQ5:	    DATA.W IRQJMP
	
NMI:        DATA.W NMIJMP ; FFFC
RESET:		DATA.W RESET  ; FFFE

	;; ELF entry point for em16 emulator
	entry := COLD
