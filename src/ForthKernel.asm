********************************************************************************
*                                                                              *
*                            Rockwell Forth Kernel                             *
*                                                                              *
*                      Based on FIG-FORTH with extensions.                     *
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

; This version targets the R6501Q microcontroller. It has the same instruction
; set as the R65F11 and R65F12 but the memory layout is different.
	
    	cpu := "R65C02"

* R6501Q Hardware Registers 	

	;; $00-$0F - internal ports
	
    	PortA := $0000
        PortB := $0001
        PortC := $0002
        PortD := $0003
        PortE := $0004
        PortF := $0005
        PortG := $0006

	;; $10-$1F- internal registers

    	ClearIntFlag := $0010
        IFR := $0011
        IER := $0012
        MCR := $0014
        SCCR := $0015
        SCSR := $0016
        SRDR := $0017
        LCACLR := $0018
        UCA := $0019
        LCA := $001a
        LCBCLR := $001c
        UCB := $001d
    	LCB := $001e

	;; Zero page RAM usage (Note that the R6501Q stack is also in zero page)
	
        IRQVEC := $0040			; User IRQ vector, points to (COLD)
        NMIVEC := IRQVEC+2		; User NMI vector, points to (COLD)
		UKEY := NMIVEC+2		; User keyboard input vector, points to (IN)
		UEMIT := UKEY+2			; User output vector, points to (OUT)
    	UP := UEMIT+2			; user area pointer.
    	INTFLAG := UP+2
	 ;; W-1 := $004b 	        ; Contains $6C to make W a jump location
        W := INTFLAG+2			; code field pointer.
        IP := W+2				; interpretive pointer.
	;;  N-1 := $0050
        N := IP+3				; N is general purpose scratch area
        XSAVE := N+8
    	INTVEC := XSAVE+2
		TOS := INTVEC+2			; Top of data stack, in zero page.

	;; 5D to C1 is parameter (data) stack (100 bytes).
	;; C2 to FF is return stack.

	;; Page 1 RAM usage

	;;  For R65F11 and R65F12 the disk registers are at 100-106,
	;;  for the R6501Q these registers are at E000 and E100.
	
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
	Disk controller registers. For the R6501Q the disk registers must be available
	at both $E000 and $E100.
*)
    	DSK_STATUS := $e000
        DSK_TRACK := $e101
        DSK_SECTOR := $e102
        DSK_DATA := $e103
        DSK_CTL := $e106

(*
	This is a 4k ROM starting at $F400, but the first $400 bytes are not used
*)

    		ORG := $f000
 			FILL.B $400, $ff

;; Data table of initial values for registers, used by INIT 
INITTAB:    DATA.B $80, $03, $c2, $00, $ff, $00, $50, $00,
			DATA.B $7e, $03, $08, $fd, $0a, $00
;;
;;    LIT
;;
LIT:		DATA.W LIT+2
  			LDA (IP),Y
    		PHA 
    		INC IP
    		BNE L30
    		INC IP+1
L30    		LDA (IP),Y
L31    		INC IP
    		BNE PUSH
    		INC IP+1
;
PUSH:		DEX 
    		DEX 
;
PUT_: 		STA 1,X
    		PLA 
    		STA 0,X
;
;    NEXT is the address interpreter that moves from machine
;    level word to word.
;
NEXT: 		BIT INTFLAG			; Check if INTFLAG is set
    		BMI HANDLEINT
NOINT  		LDY #$01
    		LDA (IP),Y			; Fetch code field address pointed
    		STA W+1				; to by IP.
    		DEY 
    		LDA (IP),Y
    		STA W
    		CLC 				; Increment IP by two.
    		LDA IP
    		ADC #2
    		STA IP
    		BCC L54
    		INC IP+1
L54    		JMP W-1				; Jump to an indirect jump (W) which
;                                 vectors to code pointed to by a code
;                                 field. 
HANDLEINT:	BVS NOINT			; Are interrupts disabled?
    		LDA INTVEC
    		STA W				; Jump to int vector
    		LDA INTVEC+1
    		STA W+1
    		LDA #$40
    		STA INTFLAG
    		LDY #0
    		JMP W-1
;;
;;    CLIT pushes the next inline byte to data stack
;;
CLIT:		DATA.W CLIT+2
    		LDA (IP),Y
    		PHA 
    		TYA 
    		BEQ L31				; a forced branch into LIT
;;
;; 
SETUP:		ASL A
    		STA N-1
L63    		LDA 0,X
    		STA N,Y
    		INX 
    		INY 
    		CPY N-1
    		BNE L63
    		LDY #$00
    		RTS 
;;
;;    EXECUTE
;;
EXECUTE:    DATA.W EXECUTE+2
    		LDA 0,X
    		STA W
    		LDA 1,X
    		STA W+1
    		INX 
    		INX 
    		JMP W-1				; to JMP (W) in z-page
;;
;;    BRANCH
;;
BRAN:		DATA.W BRAN+4		; CLC is start of BRANCH, 
   			LDX XSAVE			; Restore X is used internally
   			CLC 
    		LDA (IP),Y
    		ADC IP
    		PHA 
    		INY 
    		LDA (IP),Y
    		ADC IP+1
    		STA IP+1
    		PLA 
    		STA IP
    		JMP NEXT
;;
;;    0BRANCH
;;
ZBRAN:      DATA.W ZBRAN+2
    		INX 
    		INX 
    		LDA $fe,X
    		ORA $ff,X
    		BEQ BRAN+4
;; 
BUMP   		CLC 
    		LDA IP
    		ADC #2
    		STA IP
    		BCC L301
    		INC IP+1
L301   		JMP NEXT
;;
;;    LOOP
;;
LOOP:       DATA.W LOOP+2
    		STX XSAVE
    		TSX 
    		INC 1,X
    		BNE L311
    		INC 2,X
L311   		CLC 
    		LDA 3,X
    		SBC 1,X
    		LDA 4,X
    		SBC 2,X
L316   		BPL BRAN+2
    		BVS BRAN+2
    		INX 
    		INX 
    		INX 
    		INX 
    		TXS 
    		LDX XSAVE
    		BVC BUMP
;;
;;    (LOOP) - this is different to FIG-Forth
;;
PLOOP:      DATA.W PLOOP+2
    		INX 
    		INX 
    		STX XSAVE
    		LDA $ff,X
    		PHA 
    		PHA 
    		LDA $fe,X
    		TSX 
    		INX 
    		INX 
    		CLC 
    		ADC 1,X
    		STA 1,X
    		PLA 
    		ADC 2,X
    		STA 2,X
    		PLA 
    		BPL L311
    		CLC 
    		LDA 1,X
    		SBC 3,X
    		LDA 2,X
    		SBC 4,X
    		JMP L316
;;
;;
;;
DO:         DATA.W DO+2
    		LDA 3,X
    		PHA 
    		LDA 2,X
    		PHA 
    		LDA 1,X
    		PHA 
    		LDA 0,X
    		PHA 
;
POPTWO: 	INX 
    		INX 
;
POP: 		INX 
    		INX 
    		JMP NEXT
(*;;
	;;
          BMI L234
          CMP #$A
          BMI L227
          SEC
          SBC #7
          CMP #$A
          BMI L234
L227      CMP 0,X
          BPL L234
          STA 2,X
          LDA #1
          PHA
          TYA
          JMP PUT        ; exit true with converted value
L234      TYA
          PHA
          INX
          INX
          JMP PUT        ; exit false with bad conversion
*)
;;
DIGIT:      DATA.W DIGIT+2
    		SEC 
    		LDA 2,X
    		SBC #$30
    		BMI L391
    		CMP #$0a
    		BMI L386
    		SEC 
    		SBC #$07
    		CMP #$0a
    		BMI L391
L386   		CMP 0,X
    		BPL L391
    		STA 2,X
    		LDA #$01
    		PHA 
   			TYA 
    		JMP PUT_			; exit true with converted value
L391    	TYA 
    		PHA 
    		INX 
    		INX 
    		JMP PUT_			; exit false with bad conversion
;;
;;
;;
FIND:       DATA.W FIND+2
    		LDA #$02
    		JSR SETUP
    		STX XSAVE
L249   		LDY #$00
    		LDA (N),Y
    		EOR (N+2),Y
;;
;; 
    		AND #$3f
    		BNE L281
L254   		INY 
    		LDA (N),Y
    		EOR (N+2),Y
    		ASL A
    		BNE L280
    		BCC L254
    		LDX XSAVE
    		DEX 
    		DEX 
    		DEX 
    		DEX 
    		CLC 
    		TYA 
    		ADC #$03
    		ADC N
    		STA 2,X
    		LDY #$00
    		TYA 
    		ADC N+1
    		STA 3,X
    		STY 1,X
    		LDA (N),Y
    		STA 0,X
    		LDA #$01
    		PHA 
    		JMP PUSH
L280   		BCS L284
L281   		INY 
    		LDA (N),Y
    		BPL L281
L284   		INY 
    		LDA (N),Y
    		TAX 
    		INY 
    		LDA (N),Y
    		STA N+1
    		STX N
    		ORA N
    		BNE L249
    		LDX XSAVE
    		LDA #$00
    		PHA 
    		JMP PUSH			; exit false upon reading null link
;;
;;    ENCLOSE
;;
ENCLOSE:    DATA.W ENCLOSE+2
    		LDA #$02
    		JSR SETUP
    		TXA 
    		SEC 
    		SBC #8
    		TAX 
    		STY 3,X
    		STY 1,X
    		BNE L474
L468   		INY 
    		BNE L474
    		INC N+3
    		INC 1,X
    		INC 3,X
    		INC 5,X
L474   		LDA (N+2),Y
    		CMP N
    		BEQ L468
    		STY 4,X
L478   		LDA (N+2),Y
    		BNE L487
    		STY 2,X
    		STY 0,X
    		TYA 
    		CMP 4,X
    		BNE L486
    		INC 2,X
L486   		JMP NEXT
L487   		STY 2,X
    		INY 
    		CMP N
    		BNE L478
    		STY 0,X
    		JMP NEXT
;;
;;    EMIT
;;
EMIT:       DATA.W EMIT+2
    		LDA 0,X
    		CMP #8
    		BNE L504
    		JSR L506
    		LDA #$20
    		JSR L506
    		LDA #8
L504   		JSR L506
    		JMP POP
L506   		JMP (UEMIT)
XEMIT  		BIT SCSR
    		BVC XEMIT
    		STA SRDR
    		RTS 
;;
;;    KEY
;;
KEY:        DATA.W KEY+2
    		JSR L517
    		JMP PUSHOA
L517   		JMP (UKEY)
L518   		LDA SCSR
    		AND #1
    		BEQ L518
    		LDA SRDR
    		RTS 
;;
;;    ?TERMINAL
;;
QTERM:      DATA.W QTERM+2
    		LDA SCSR
    		AND #1
    		JMP PUSHOA
;;
;;    CR
;;
CR:         DATA.W CR+2
    		LDA #$0d
    		JSR L506
    		LDA #$0a
    		JSR L506
    		TYA 
    		JSR L506
    		JMP NEXT
;;
;;    CMOVE
;;
CMOVE:      DATA.W CMOVE+2
    		LDA #3
    		JSR SETUP
L547   		CPY N
    		BNE L552
    		DEC N+1
    		BPL L552
    		JMP NEXT
L552   		LDA (N+4),Y
    		STA (N+2),Y
    		INY 
    		BNE L547
    		INC N+5
    		INC N+3
    		JMP L547
;;
;;    U*
;;
USTAR:      DATA.W USTAR+2
    		LDA 2,X
    		STA N
    		STY 2,X
    		LDA 3,X
    		STA N+1
    		STY 3,X
    		LDY #$10
L570   		ASL 2,X
    		ROL 3,X
    		ROL 0,X
    		ROL 1,X
    		BCC L586
    		CLC 
    		LDA N
    		ADC 2,X
    		STA 2,X
    		LDA N+1
    		ADC 3,X
    		STA 3,X
    		BCC L586
    		INC 0,X
    		BNE L586
    		INC 1,X
L586   		DEY 
    		BNE L570
    		JMP NEXT
;;
;;    U/
;;
USLAS:      DATA.W USLAS+2
    		LDA 4,X
    		LDY 2,X
    		STY 4,X
    		ASL A
    		STA 2,X
    		LDA 5,X
    		LDY 3,X
    		STY 5,X
    		ROL A
    		STA 3,X
    		LDA #$10
    		STA N
L433   		ROL 4,X
    		ROL 5,X
    		PHP 
    		SEC 
    		LDA 4,X
    		SBC 0,X
    		TAY 
    		LDA 5,X
    		SBC 1,X
    		BCC L620
    		STY 4,X
    		STA 5,X
L617   		PLP 
    		SEC 
    		BCS L624
L620   		PLP 
    		BCC L624
    		STY 4,X
    		STA 5,X
L624   		ROL 2,X
    		ROL 3,X
    		DEC N
    		BNE L433
    		JMP POP
;;
;;    AND
;;
ANDD:       DATA.W ANDD+2
    		LDA 0,X
    		AND 2,X
    		PHA 
    		LDA 1,X
    		AND 3,X
;
BINARY: 	INX 
    		INX 
    		JMP PUT_
;;
;;    OR
;;
OR:         DATA.W OR+2
    		LDA 0,X
    		ORA 2,X
    		PHA 
    		LDA 1,X
    		ORA 3,X
    		JMP BINARY
;;
;;    XOR
;;
XOR:        DATA.W XOR+2
    		LDA 0,X
    		EOR 2,X
    		PHA 
    		LDA 1,X
    		EOR 3,X
    		JMP BINARY
;;
;;    SP@
;;
SPAT:     	DATA.W SPAT+2
    		TXA 
;
PUSHOA: 	PHA 
    		LDA #0
    		JMP PUSH
;;
;;    SP!
;;
SPSTO:    DATA.W SPSTO+2
    		LDY #2
    		LDA (UP),Y			; load data stack pointer (X reg) from
    		TAX 				; silent user variable S0.
    		JMP NEXT
;;
;;    RP!
;;
RPSTO:      DATA.W RPSTO+2
    		STX XSAVE
    		LDY #$04
    		LDA (UP),Y
    		TAX 
    		TXS 
    		LDX XSAVE
    		JMP NEXT
;;
;;
;;
PUSHS:      DATA.W PUSHS+2
    		STX XSAVE
    		TSX 
    		TXA 
    		LDX XSAVE
    		JMP PUSHOA
;;
;;
;;
SEMIS:      DATA.W SEMIS+2
 			PLA 
    		STA IP
    		PLA 
    		STA IP+1
    		JMP NEXT
;;
;;
;;
LEAVE:      DATA.W LEAVE+2
    		STX XSAVE
    		TSX 
    		LDA 1,X
    		STA 3,X
    		LDA 2,X
    		STA 4,X
    		LDX XSAVE
    		JMP NEXT
;;
;;
;;
GTR:        DATA.W GTR+2
    		LDA 1,X
    		PHA 
    		LDA 0,X
    		PHA 
    		JMP POP
;;
;;
;;
RFROM:      DATA.W RFROM+2
    		DEX 
    		DEX 
    		PLA 
    		STA 0,X
    		PLA 
    		STA 1,X
    		JMP NEXT
;;
;;
;;
R:          DATA.W R+2
    		STX XSAVE
    		TSX 
    		LDA 1,X
    		PHA 
    		LDA 2,X
    		LDX XSAVE
    		JMP PUSH
;;
;;
;;
ZEQ:        DATA.W ZEQ+2
    		LDA 0,X
    		ORA 1,X
    		STY 1,X
    		BNE L760
    		INY 
L760   		STY 0,X
    		JMP NEXT
;;
;;
;;
ZLT:        DATA.W ZLT+2
    		ASL 1,X
    		TYA 
    		ROL A
    		STY 1,X
    		STA 0,X
    		JMP NEXT
;;
;;
;;
PLUS:       DATA.W PLUS+2
    		CLC 
    		LDA 0,X
    		ADC 2,X
    		PHA 
    		LDA 1,X
    		ADC 3,X
    		JMP BINARY
;;
;;
;;
DPLUS:      DATA.W DPLUS+2
    		CLC 
    		LDA 2,X
    		ADC 6,X
    		STA 6,X
    		LDA 3,X
    		ADC 7,X
    		STA 7,X
    		LDA 0,X
    		ADC 4,X
    		STA 4,X
    		LDA 1,X
    		ADC 5,X
    		STA 5,X
    		JMP POPTWO
;;
;;
;;
NEGATE:     DATA.W NEGATE+2
    		SEC 
L806   		TYA 
    		SBC 0,X
    		STA 0,X
    		TYA 
    		SBC 1,X
    		STA 1,X
    		JMP NEXT
;;
;;
;;
DNEGATE:    DATA.W DNEGATE+2
    		SEC 
    		TYA 
    		SBC 2,X
    		STA 2,X
    		TYA 
    		SBC 3,X
    		STA 3,X
    		JMP L806
;;
;;
;;
OVER:       DATA.W OVER+2
    		LDA 2,X
    		PHA 
    		LDA 3,X
    		JMP PUSH
;;
;;
;;
DROP:       DATA.W POP
;;
;;
;;
TWODROP:    DATA.W POPTWO
;;
;;
;;
SWAP:       DATA.W SWAP+2
    		LDA 2,X
    		PHA 
    		LDA 0,X
    		STA 2,X
    		LDA 3,X
    		LDY 1,X
    		STY 3,X
    		JMP PUT_
;;
;;
;;
DUP:        DATA.W DUP+2
    		LDA 0,X
    		PHA 
    		LDA 1,X
    		JMP PUSH
;;
;;
;;
TWODUP:     DATA.W TWODUP+2
    		DEX 
    		DEX 
    		LDA 4,X
    		STA 0,X
    		LDA 5,X
    		STA 1,X
    		LDA 2,X
    		PHA 
    		LDA 3,X
    		JMP PUSH
;;
;;
;;
BOUNDS:     DATA.W BOUNDS+2
    		LDY 3,X
    		LDA 2,X
    		PHA 
    		CLC 
    		ADC 0,X
    		STA 2,X
    		TYA 
    		ADC 1,X
    		STA 3,X
    		TYA 
    		JMP PUT_
;;
;;
;;
PSTORE:     DATA.W PSTORE+2
    		CLC 
    		LDA (0,X)
    		ADC 2,X
    		STA (0,X)
    		INC 0,X
    		BNE $f827
    		INC 1,X
    		LDA (0,X)
    		ADC 3,X
    		STA (0,X)
    		JMP POPTWO
;;
;;
;;
TOGGL:      DATA.W TOGGL+2
    		LDA (2,X)
    		EOR 0,X
    		STA (2,X)
    		JMP POPTWO
;;
;;
;;
AT:         DATA.W AT+2
    		LDA (0,X)
    		PHA 
    		INC 0,X
    		BNE L922
    		INC 1,X
L922   		LDA (0,X)
    		JMP PUT_
;;
;;
;;
CAT:        DATA.W CAT+2
    		LDA (0,X)
L929   		STA 0,X
    		LDY #$00
    		STY 1,X
    		JMP NEXT
;;
;;
;;
STORE:      DATA.W STORE+2
    		LDA 2,X
    		STA (0,X)
    		INC 0,X
    		BNE L942
    		INC 1,X
L942   		LDA 3,X
    		STA (0,X)
    		JMP POPTWO
;;
;;
;;
CSTOR:      DATA.W CSTOR+2
    		LDA 2,X
    		STA (0,X)
    		JMP POPTWO
;;
;;
;; 
DOCOL: 		LDA IP+1
    		PHA 
    		LDA IP
    		PHA 
    		CLC 
    		LDA W
    		ADC #$02
    		STA IP
    		TYA 
    		ADC W+1
    		STA IP+1
    		JMP NEXT
;;
;;
;; 
DOCON: 		LDY #$02
    		LDA (W),Y
    		PHA 
    		INY 
    		LDA (W),Y
    		JMP PUSH
;;
;;
;; 
DOVAR: 		CLC 
    		LDA W
    		ADC #$02
    		PHA 
    		TYA 
    		ADC W+1
    		JMP PUSH
;;
;;
;; 
DOUSE: 		LDY #$02
    		CLC 
    		LDA (W),Y
    		ADC UP
    		PHA 
    		LDA #$00
    		ADC UP+1
    		JMP PUSH
;;
;;
;;
ZERO:       DATA.W DOCON
            DATA.W 0
;;
;;
;;
ONE:        DATA.W DOCON
            DATA.W 1
;;
;;
;;
TWO:        DATA.W DOCON
            DATA.W 2
;;
;;
;;
THREE:      DATA.W DOCON
            DATA.W 3
;;
;;
;;
FOUR:       DATA.W DOCON
            DATA.W 4
;;
;;
;;
BL:         DATA.W DOCON
            DATA.W $0020
;;
;;
;;
TIB:        DATA.W DOUSE
    		DATA.B $00
;;
;;
;;
SZ:         DATA.W DOUSE
    		DATA.B $02
;;
;;
;;
RZ:         DATA.W DOUSE
    		DATA.B $04
;;
;;
;;
UCL:        DATA.W DOUSE
    		DATA.B $06
;;
;;
;;
UPAD:       DATA.W DOUSE
    		DATA.B $08
;;
;;
;;
URW:        DATA.W DOUSE
    		DATA.B $0a
;;
;;
;;
BASE:       DATA.W DOUSE
    		DATA.B $0c
;;
;;
;;
CLDWRM:     DATA.W DOUSE
    		DATA.B $0e
;;
;;
;;
IN:         DATA.W DOUSE
    		DATA.B $10
;;
;;
;;
DPL:        DATA.W DOUSE
    		DATA.B $12
;;
;;
;;
HLD:        DATA.W DOUSE
    		DATA.B $14
;;
;;
;;
CL:         DATA.W DOCOL
            DATA.W UCL
            DATA.W AT
            DATA.W SEMIS
;;
;;
;;
PAD:        DATA.W DOCOL
            DATA.W UPAD
            DATA.W AT
            DATA.W SEMIS
;;
;;
;;
ONEPLUS:    DATA.W ONEPLUS+2
    		INC 0,X
    		BNE L1091
    		INC 1,X
L1091  		JMP NEXT
;;
;;
;;
TWOPLUS:    DATA.W TWOPLUS+2
    		CLC 
    		LDA 0,X
    		ADC #$02
    		STA 0,X
    		BCC L1102
    		INC 1,X
L1102  		JMP NEXT
;;
;;
;;
ONEMINUS:   DATA.W ONEMINUS+2
    		LDA 0,X
    		BNE L1110
    		DEC 1,X
L1110  		DEC 0,X
  			JMP NEXT
;;
;;
;;
TWOMINUS:   DATA.W TWOMINUS+2
    		SEC 
    		LDA 0,X
    		SBC #$02
    		STA 0,X
    		BCS L1122
    		DEC 1,X
L1122  		JMP NEXT
;;
;;
;;
SUB:        DATA.W DOCOL
            DATA.W NEGATE
            DATA.W PLUS
            DATA.W SEMIS
;;
;;
;;
EQUAL:      DATA.W DOCOL
            DATA.W SUB
            DATA.W ZEQ
            DATA.W SEMIS
;;
;;
;;
ULESS:      DATA.W ULESS+2
    		SEC 
    		LDA 2,X
    		SBC 0,X
    		LDA 3,X
    		SBC 1,X
    		TYA 
    		ROL A
    		EOR #$01
    		INX 
    		INX 
    		JMP L929
;;
;;
;;
LESS:       DATA.W LESS+2
    		LDA 2,X
    		CMP 0,X
    		LDA 3,X
    		SBC 1,X
    		STY 3,X
    		BVC L1163
    		EOR #$80
L1163  		BPL L1165
    		INY 
L1165  		STY 2,X
    		JMP POP
;;
;;
;;
GT:         DATA.W DOCOL
            DATA.W SWAP
            DATA.W LESS
            DATA.W SEMIS
;;
;;
;;
ROT:        DATA.W ROT+2
    		LDA 4,X
    		PHA 
    		LDA 2,X
    		STA 4,X
    		LDA 0,X
    		STA 2,X
    		LDY 5,X
    		LDA 3,X
    		STA 5,X
    		LDA 1,X
    		STA 3,X
    		TYA 
    		JMP PUT_
;;
;;
;;
PICK:       DATA.W DOCOL
    		DATA.W DUP
    		DATA.W PLUS
    		DATA.W SPAT
    		DATA.W PLUS
    		DATA.W AT
    		DATA.W SEMIS
;;
;;    SPACE
;;
SPACE: 	   	DATA.W DOCOL
    		DATA.W BL
    		DATA.W EMIT
    		DATA.W SEMIS
;;
;;    -DUP
;;
DDUP:       DATA.W DOCOL
    		DATA.W DUP
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W DUP
            DATA.W SEMIS
;;
;;    HEX
;;
HEX:        DATA.W DOCOL
    		DATA.W CLIT
    		DATA.B $10
L1170  		DATA.W BASE
    		DATA.W STORE
    		DATA.W SEMIS
;;
;;    DECIMAL
;;
DECIMAL:    DATA.W DOCOL
    		DATA.W CLIT
    		DATA.B $0a
    		DATA.W BRAN
    		DATA.W $fff3		; L1170
;;
;;    DOES>
;; 
DOES: 		LDA IP+1
    		PHA 
    		LDA IP
    		PHA 
    		LDY #$02
    		LDA (W),Y
    		STA IP
    		INY 
    		LDA (W),Y
    		STA IP+1
    		CLC 
    		LDA W
    		ADC #$04
    		PHA 
    		LDA W+1
    		ADC #$00
    		JMP PUSH
;;
;;    COUNT
;;
COUNT:      DATA.W DOCOL
            DATA.W DUP
            DATA.W ONEPLUS
            DATA.W SWAP
            DATA.W CAT
            DATA.W SEMIS
;;
;;    TYPE
;; 
TYPE:		DATA.W DOCOL
            DATA.W DDUP
            DATA.W ZBRAN
L1639  		DATA.W $0012		;L1651-L1639
    		DATA.W BOUNDS
    		DATA.W DO
    		DATA.W R
    		DATA.W CAT
    		DATA.W EMIT
    		DATA.W LOOP
    		DATA.W $fff8
    		DATA.W SEMIS
L1651  		DATA.W DROP
    		DATA.W SEMIS
;;
;;    -TRAILING
;;
DTRAI:      DATA.W DOCOL
    		DATA.W DUP
    		DATA.W ZERO
    		DATA.W DO
    		DATA.W TWODUP
    		DATA.W PLUS
    		DATA.W ONEMINUS
    		DATA.W CAT
    		DATA.W BL
    		DATA.W SUB
    		DATA.W ZBRAN
    		DATA.W $0008
    		DATA.W LEAVE
    		DATA.W BRAN
    		DATA.W $0004
    		DATA.W ONEMINUS
    		DATA.W LOOP
    		DATA.W $ffe6
    		DATA.W SEMIS
;;
;;
;;
PDOTQ:      DATA.W DOCOL
    		DATA.W R
    		DATA.W COUNT
    		DATA.W DUP
    		DATA.W ONEPLUS
    		DATA.W RFROM
    		DATA.W PLUS
    		DATA.W GTR
    		DATA.W TYPE
    		DATA.W SEMIS
;;
;;
;;
EXPECT:     DATA.W DOCOL
    		DATA.W OVER
    		DATA.W PLUS
    		DATA.W OVER
    		DATA.W ZERO
    		DATA.W OVER
    		DATA.W STORE
    		DATA.W KEY
    		DATA.W DUP
    		DATA.W CLIT
    		DATA.B $0d			; Return
    		DATA.W EQUAL
    		DATA.W ZBRAN
    		DATA.W $000c
    		DATA.W DROP
    		DATA.W SPACE
    		DATA.W ONE
    		DATA.W BRAN
    		DATA.W $003a
    		DATA.W DUP
    		DATA.W CLIT
    		DATA.B $7f			; DEL
    		DATA.W EQUAL
    		DATA.W ZBRAN
    		DATA.W $001f
    		DATA.W DROP
    		DATA.W THREE
    		DATA.W PICK
    		DATA.W OVER
    		DATA.W ULESS
    		DATA.W NEGATE
    		DATA.W DUP
    		DATA.W NEGATE
    		DATA.W ZBRAN
    		DATA.W $0015
    		DATA.W CLIT
    		DATA.B $08			; Backspace
    		DATA.W EMIT
    		DATA.W BRAN
    		DATA.W $000c
    		DATA.W TWODUP
    		DATA.W SWAP
    		DATA.W CSTOR
    		DATA.W EMIT
    		DATA.W ONE
    		DATA.W PLUS
    		DATA.W TWODUP
    		DATA.W EQUAL
    		DATA.W ZBRAN
    		DATA.W $ffa9
    		DATA.W TWODROP
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
QUERY:      DATA.W DOCOL
    		DATA.W TIB
    		DATA.W AT
    		DATA.W CL
    		DATA.W EXPECT
    		DATA.W ZERO
    		DATA.W IN
    		DATA.W STORE
    		DATA.W SEMIS
;;
;;
;;
FILL_:      DATA.W DOCOL
    		DATA.W SWAP
    		DATA.W DUP
    		DATA.W ONE
    		DATA.W LESS
    		DATA.W ZBRAN
    		DATA.W $0008
    		DATA.W TWODROP
    		DATA.W DROP
    		DATA.W SEMIS
    		DATA.W GTR
    		DATA.W OVER
    		DATA.W CSTOR
    		DATA.W DUP
    		DATA.W ONEPLUS
    		DATA.W RFROM
    		DATA.W ONEMINUS
    		DATA.W CMOVE
    		DATA.W SEMIS
;;
;;
;;
ERASE:      DATA.W DOCOL
    		DATA.W ZERO
    		DATA.W FILL_
    		DATA.W SEMIS
;;
;;
;;
BLANKS:     DATA.W DOCOL
    		DATA.W BL
    		DATA.W FILL_
    		DATA.W SEMIS
;;
;;
;;
HOLD:       DATA.W DOCOL
    		DATA.W LIT
    		DATA.W $ffff
    		DATA.W HLD
    		DATA.W PSTORE
    		DATA.W HLD
    		DATA.W AT
    		DATA.W CSTOR
    		DATA.W SEMIS
;;
;;
;;
LTNUMBER:   DATA.W DOCOL
    		DATA.W ONEPLUS
    		DATA.W DUP
    		DATA.W GTR
    		DATA.W CAT
    		DATA.W BASE
    		DATA.W AT
    		DATA.W DIGIT
    		DATA.W ZBRAN
    		DATA.W $002c
    		DATA.W SWAP
    		DATA.W BASE
    		DATA.W AT
    		DATA.W USTAR
    		DATA.W DROP
    		DATA.W ROT
    		DATA.W BASE
    		DATA.W AT
    		DATA.W USTAR
    		DATA.W DPLUS
    		DATA.W DPL
    		DATA.W AT
    		DATA.W ONEPLUS
    		DATA.W ZBRAN
    		DATA.W $0008
    		DATA.W ONE
    		DATA.W DPL
    		DATA.W PSTORE
    		DATA.W RFROM
    		DATA.W BRAN
    		DATA.W $ffc6
    		DATA.W RFROM
    		DATA.W SEMIS
;;
;;
;;
COLD:       DATA.W COLD+2
    		STY CLD_WARM
L1485  		LDX #$ff
    		TXS 
    		CLD 
    		CLC 
    		LDA #0
    		STA MCR				; Full address mode
    		LDA #0
    		STA IFR
    		STA IER
    		LDA #$c4
    		STA SCCR
    		LDA #$34
    		STA LCACLR
    		LDA #$00
    		STA LCA
    		STA SCSR
    		STA INTFLAG
    		LDA #$6c
    		STA W-1
    		LDA #<XEMIT
    		STA UEMIT
    		LDA #>XEMIT
    		STA UEMIT+1
    		LDA #$ae			; Disk
    		STA UKEY
    		LDA #$ff
    		STA UKEY+1
    		LDA #0
    		STA UP
    		LDA #3
    		STA UP+1
    		LDY #5
    		JSR L1549
    		LDA CLD_WARM
    		CMP #$5a
    		BNE L1505
    		LDA CLD_WARM+1
    		CMP #$a5
    		BEQ L1515
L1505  		LDA #<(COLD+2)
  			STA IRQVEC
    		STA NMIVEC
    		STA INTVEC
  			LDA #>(COLD+2)
    		STA IRQVEC+1
    		STA NMIVEC+1
    		STA INTVEC+1
    		LDY #$0d
    		JSR L1549
L1515  		LDA #>DSKBOOT
    		STA IP+1
    		LDA #<DSKBOOT
    		STA IP
    		CLI 
    		LDX #$c2
    		LDA #$04			; Load $0400 into TOS to start ROM search
    		STA TOS+1
    		LDY #0
    		STY TOS
L1525  		TYA 
    		LDA (TOS),Y			; Do we have $5aa5
    		CMP #$5a
    		BNE L1540
    		INY 
    		LDA (TOS),Y
    		CMP #$a5
    		BNE L1540
    		INY 
    		LDA (TOS),Y
    		STA IP
    		INY 
    		LDA (TOS),Y
    		STA IP+1
L1539		JMP NEXT
L1540  		LDY TOS+1			; Add 8 to high byte (1k)
    		INY 
    		INY 
    		INY    
    		INY 
    		BEQ L1539			; Not found, start DSKBOOT word 
    		STY TOS+1
    		LDY #0
    		BEQ L1525
L1549  		LDA INITTAB,Y
    		STA (UP),Y
    		DEY 
    		BPL L1549
    		RTS 
;;
;;
;;
DSKBOOT:	DATA.W CR
            DATA.W PDOTQ
    		DATA.B $06, "NO ROM"
    		DATA.W CTLRQ
    		DATA.W ZERO
    		DATA.W L2149
    		DATA.W ZERO
    		DATA.W SEEK
;;
;;
;;
unkn2:      DATA.W unkn2+2
			DATA.W unkn2+4
    		LDA #$df
			STA N
    		LDA #$ff
    		STA N+1
    		LDA #1
    		STA N+2
    		LDA #$80
    		JSR DSTAT
    		LDY #$80
    		JSR L1826
    		BNE L1601
    		JMP $005f 			; Appears to be a value on the stack
L1601  		JMP L1485
;;
;;    S->D - Single to double precision
;;
STOD:       DATA.W DOCOL
    		DATA.W DUP
    		DATA.W ZLT
    		DATA.W NEGATE
    		DATA.W SEMIS
;;
;;
;;
PM:         DATA.W DOCOL
    		DATA.W ZLT
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W NEGATE
    		DATA.W SEMIS
;;
;;
;;
DPLUS1:     DATA.W DOCOL
    		DATA.W ZLT
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W DNEGATE
    		DATA.W SEMIS
;;
;;
;;
ABS:        DATA.W DOCOL
    		DATA.W DUP
    		DATA.W PM
    		DATA.W SEMIS
;;
;;
;;
DABS:       DATA.W DOCOL
    		DATA.W DUP
    		DATA.W DPLUS1
    		DATA.W SEMIS
;;
;;
;;
MIN:        DATA.W DOCOL
    		DATA.W TWODUP
    		DATA.W GT
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W SWAP
    		DATA.W DROP
    		DATA.W SEMIS
    		DATA.W DOCOL
    		DATA.W TWODUP
    		DATA.W LESS
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W SWAP
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
MMUL:       DATA.W DOCOL
    		DATA.W TWODUP
    		DATA.W XOR
    		DATA.W GTR
    		DATA.W ABS
    		DATA.W SWAP
    		DATA.W ABS
    		DATA.W USTAR
    		DATA.W RFROM
    		DATA.W DPLUS1
    		DATA.W SEMIS
;;
;;
;;
MDIV:       DATA.W DOCOL
    		DATA.W OVER
    		DATA.W GTR
    		DATA.W GTR
    		DATA.W DABS
    		DATA.W R
    		DATA.W ABS
    		DATA.W USLAS
    		DATA.W RFROM
    		DATA.W R
    		DATA.W XOR
    		DATA.W PM
    		DATA.W SWAP
    		DATA.W RFROM
    		DATA.W PM
    		DATA.W SWAP
    		DATA.W SEMIS
;;
;;
;;
MUL:        DATA.W DOCOL
    		DATA.W USTAR
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
DIVMOD:     DATA.W DOCOL
    		DATA.W GTR
    		DATA.W STOD
    		DATA.W RFROM
    		DATA.W MDIV
    		DATA.W SEMIS
;;
;;
;;
DIV_:       DATA.W DOCOL
    		DATA.W DIVMOD
    		DATA.W SWAP
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
MOD_:       DATA.W DOCOL
    		DATA.W DIVMOD
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
MULDIVMOD:  DATA.W DOCOL
    		DATA.W GTR
    		DATA.W MMUL
    		DATA.W RFROM
    		DATA.W MDIV
    		DATA.W SEMIS
;;
;;
;;
MULDIV:     DATA.W DOCOL
    		DATA.W MULDIVMOD
    		DATA.W SWAP
    		DATA.W DROP
    		DATA.W SEMIS
;;
;;
;;
MDIVMOD:    DATA.W DOCOL
    		DATA.W GTR
    		DATA.W ZERO
    		DATA.W R
    		DATA.W USLAS
    		DATA.W RFROM
    		DATA.W SWAP
    		DATA.W GTR
    		DATA.W USLAS
    		DATA.W RFROM
    		DATA.W SEMIS
;;
;;
;;
DISK:       DATA.W DOCOL
    		DATA.W SWAP
    		DATA.W LIT
    		DATA.W B_SIDE
    		DATA.W AT
    		DATA.W DIVMOD
    		DATA.W L2149
    		DATA.W FOUR
    		DATA.W DIVMOD
    		DATA.W SEEK
    		DATA.W SWAP
    		DATA.W ZBRAN
    		DATA.W $0008
    		DATA.W DREAD
    		DATA.W BRAN
    		DATA.W $0004
    		DATA.W DWRITE
    		DATA.W DDUP
    		DATA.W ZBRAN
    		DATA.W $0013
    		DATA.W PDOTQ
    		DATA.B $0c, "DISK ERROR #"
    		DATA.W DOT
    		DATA.W SEMIS
;;
;;
;;
SELECT:     DATA.W SELECT+2
  			LDA 0,X
    		LSR A
    		STA DISKNO
    		STY DISKNO+1
    		JSR L1886
    		STA DSK_CTL
    		JMP POP
;;
;;
;;
DREAD:      DATA.W DREAD+2
    		JSR L1811
L1800  		JSR L1817
    		LDA #$90
    		JSR DSTAT
    		JSR L1826
    		AND #$bf
    		BEQ L1808
    		DEC N+3
    		BNE L1800
L1808  		INX 
    		INX 
    		JMP L929
L1811  		ASL 0,X
    		ASL 0,X
    		INC 0,X
    		LDA #5
    		STA N+3
    		RTS 
L1817  		LDA #4
    		STA N+2
    		LDA 2,X
    		STA N
    		LDA 3,X
    		STA N+1
    		LDA 0,X
    		STA DSK_SECTOR
    		JMP L1836
L1826  		BIT DSK_CTL
    		BVS L1826
    		BPL L1838
    		LDA DSK_DATA
    		STA (N),Y
    		INY 
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
DSTAT: 		STA DSK_STATUS
    		LDY #8
L1845  		DEY 
    		BNE L1845
    		RTS 
;;
;;
;;
DWRITE:     DATA.W DWRITE+2
    		JSR L1811
L1853  		JSR L1817
    		LDA #$b0
    		JSR DSTAT
    		JSR L1862
    		AND #$fd
    		BEQ L1861
    		DEC N+3
    		BNE L1853
L1861  		JMP L1808
L1862  		BIT DSK_CTL
    		BVS L1862
    		BPL L1838
    		LDA (N),Y
    		STA DSK_DATA
    		INY 
    		BNE L1862
    		INC N+1
    		DEC N+2
    		BNE L1862
    		JMP L1836
;;
;;
;;
INIT:       DATA.W INIT+2
    		LDA DSK_STATUS
    		LDA #$ff
    		LDY #$03
L1880  		STA CYLINDER,Y
    		DEY 
    		BPL L1880
    		JMP NEXT
SUB1: 		NOP 
    		NOP 
L1886  		TAY 
    		LDA #0
    		ROL A
    		ORA TAB1,Y
    		RTS 
TAB1:       DATA.B $22, $24, $28, $30
;;
;;
;;
SEEK:       DATA.W SEEK+2
    		LDY DISKNO
    		LDA CYLINDER,Y
    		CMP #$50
    		BCC L1903
    		LDA #3
    		JSR L1837
    		LDA #0
L1903  		STA DSK_TRACK
    		LDA 0,X
    		STA DSK_DATA
    		LDY DISKNO
    		STA CYLINDER,Y
    		LDA #$13
    		JSR L1837
    		JMP POP
;;
;;
;;
SPACES:     DATA.W DOCOL
    		DATA.W ZERO
    		DATA.W $fc6e
    		DATA.W DDUP
    		DATA.W ZBRAN
    		DATA.W $000c
    		DATA.W ZERO
    		DATA.W DO
    		DATA.W SPACE
    		DATA.W LOOP
    		DATA.W RESET
    		DATA.W SEMIS
;;
;;
;;
LEQ:        DATA.W DOCOL
    		DATA.W PAD
    		DATA.W HLD
    		DATA.W STORE
    		DATA.W SEMIS
;;
;;
;;
HASHGT:     DATA.W DOCOL
    		DATA.W TWODROP
    		DATA.W HLD
    		DATA.W AT
    		DATA.W PAD
    		DATA.W OVER
    		DATA.W SUB
    		DATA.W SEMIS
;;
;;
;;
SIGN:       DATA.W DOCOL
    		DATA.W ROT
    		DATA.W ZLT
    		DATA.W ZBRAN
    		DATA.W $0007
    		DATA.W CLIT
    		DATA.B '-'
    		DATA.W HOLD
    		DATA.W SEMIS
;;
;;
;;
DIG:        DATA.W DOCOL
    		DATA.W BASE
    		DATA.W AT
    		DATA.W MDIVMOD
    		DATA.W ROT
    		DATA.W CLIT
    		DATA.B $09		
    		DATA.W OVER
    		DATA.W LESS
    		DATA.W ZBRAN
    		DATA.W $0007
    		DATA.W CLIT
    		DATA.B $07			
    		DATA.W PLUS
    		DATA.W CLIT
    		DATA.B $30
    		DATA.W PLUS
    		DATA.W HOLD
    		DATA.W SEMIS
;;
;;
;;
HASHS:      DATA.W DOCOL
    		DATA.W DIG
    		DATA.W TWODUP
    		DATA.W OR
    		DATA.W ZEQ
    		DATA.W ZBRAN
    		DATA.W $fff6
    		DATA.W SEMIS
;;
;;
;;
DDOTR:      DATA.W DOCOL
    		DATA.W GTR
    		DATA.W SWAP
    		DATA.W OVER
    		DATA.W DABS
    		DATA.W LEQ
    		DATA.W HASHS
    		DATA.W SIGN
    		DATA.W HASHGT
    		DATA.W RFROM
    		DATA.W OVER
    		DATA.W SUB
    		DATA.W SPACES
    		DATA.W TYPE
    		DATA.W SEMIS
;;
;;    D. - Print double precision
;;
DDOT:       DATA.W DOCOL
    		DATA.W ZERO
    		DATA.W DDOTR
    		DATA.W SPACE
    		DATA.W SEMIS
;;
;;    .R
;;
DOTR:       DATA.W DOCOL
    		DATA.W GTR
    		DATA.W STOD
    		DATA.W RFROM
    		DATA.W DDOTR
    		DATA.W SEMIS
;;
;;    . - Print number
;;
DOT:        DATA.W DOCOL
    		DATA.W STOD
    		DATA.W DDOT
    		DATA.W SEMIS
;;
;;
;;
Q:          DATA.W DOCOL
    		DATA.W AT
    		DATA.W DOT
    		DATA.W SEMIS
;;
;;    EEC! - works only with R65F11 and R65F12
;;
EECSTORE:   DATA.W EECSTORE+2
    		LDY #4
    		LDA 3,X
L2046  		ROR A
    		ROR 2,X
    		DEY 
    		BNE L2046
    		LDY 2,X
    		STY PortD
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
    		LDA 4,X
    		RMB 7, PortC
    		STA PortD
    		LDA 0,X
    		STA LCBCLR
    		LDA 1,X
    		STA LCB
L2071  		BBR 5, IFR, L2071
    		SMB 5, PortC
    		LDA #$e0
    		NOP 
    		NOP 
    		INX 
    		INX 
    		JMP POPTWO
;;
;;
;;
BANKPSH:    DATA.W BANKPSH+2
    		LDA PortB
    		PHA 
    		LDA 0,X
    		STA PortB
    		JMP POP
;;
;;
;;
BANKPOP:    DATA.W BANKPOP+2
    		PLA 
    		STA PortB
    		JMP SEMIS+2
;;
;;
;;
BANKCSTOR:  DATA.W DOCOL
    		DATA.W BANKPSH
    		DATA.W CSTOR
    		DATA.W BANKPOP
;;
;;
;;
BANKCAT:    DATA.W DOCOL
    		DATA.W BANKPSH
    		DATA.W CAT
    		DATA.W BANKPOP
;;
;;
;;
BANKEECS:   DATA.W DOCOL
    		DATA.W BANKPSH
    		DATA.W EECSTORE
    		DATA.W BANKPOP
;;
;;
;;
BANKEXEC:   DATA.W DOCOL
    		DATA.W BANKPSH
    		DATA.W EXECUTE
    		DATA.W BANKPOP

unkn5: 		STA W
    		STY W+1
    		LDY #0
    		PLA 
    		STA TOS
    		PLA 
    		STA TOS+1
    		INC TOS
    		BNE L2134
    		INC TOS+1
L2134  		LDA #<unkn6
    		STA IP
    		LDA #>unkn6
    		STA IP+1
    		JMP W-1
	
unkn6:      DATA.W $005d
NMIJMP		JMP ($0042)
IRQJMP		JMP ($0040)
    		DATA.W OVER
			DATA.W PLUS
			DATA.W PLUS
			DATA.W AT
    		DATA.W EXECUTE
    		DATA.W SEMIS 
	
L2149  		DATA.W L2149+2
    		LDA #$20
    		BIT DSK_CTL
    		BEQ L2161
    		STA DSK_CTL
    		STY TOS
L2157  		DEC TOS
    		BNE L2157
    		DEY 
    		BNE L2157
L2161  		JSR L1836
    		JMP SELECT+2
    		LDA #0
    		STA DSK_CTL
    		JMP L518
;;
;;    CTLRQ - check for control-R
;;
CTLRQ:      DATA.W DOCOL
    		DATA.W CR			; Output CR
    		DATA.W CLIT			; Read from serial port
    		DATA.B SRDR
    		DATA.W CAT
    		DATA.W CLIT
    		DATA.B $12			; Control-R
    		DATA.W EQUAL		; Do we have a Control-R character?
    		DATA.W ZBRAN
    		DATA.W $ffcb
    		DATA.W MMON
;;
;;    MMON - the micro monitor
;;
MMON:       DATA.W DOCOL
    		DATA.W CR
    		DATA.W CLIT
    		DATA.B '>'			
    		DATA.W EMIT
    		DATA.W HEX
    		DATA.W QUERY
    		DATA.W ZERO
    		DATA.W ZERO
    		DATA.W TIB
    		DATA.W AT
    		DATA.W LTNUMBER
    		DATA.W TWODROP
    		DATA.W TIB
    		DATA.W AT
    		DATA.W CAT
    		DATA.W CLIT
    		DATA.B 'W'
    		DATA.W EQUAL
    		DATA.W ZBRAN
    		DATA.W $0004
    		DATA.W EXECUTE
    		DATA.W BRAN
    		DATA.W $ffd6
	
    		DATA.W $ffff		; Padding
	
NMI:     	DATA.W NMIJMP
RESET:   	DATA.W COLD+5
IRQ:	    DATA.W IRQJMP
