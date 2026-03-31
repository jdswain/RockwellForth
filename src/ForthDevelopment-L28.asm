
	section "kernel"
	
	Include "ForthKernel-L28.asm"
	message org
	section "development"
	
    org := $a000

;;
;;	The kernel searches for this identifier on every 1k boundary.
;;
IDENT:         data.w $a55a
;;
;;	Then it starts executing at the address stored next
;;
START:          data.w KSTART
	
UNKNOWN:        data.w $ffff
				data.w $ffff
				data.w $0140
				data.w $17f8
				data.w $2000
				data.w $0000
				data.w $001f
				data.w $0000
				data.w $0404
				data.w $0411
				data.w $0000
				data.w $0000
				data.w $033c
				data.w $a081
				data.w $0404
				data.w $0000
				data.w $a081
				data.w _ENDCODE
				data.w $0336
				data.w ABORT
	
;;
;;    LIT
;;
_LIT            text.7 $83, "LIT"
    			data.w 0            ; link to previous. Last link marked by zero.
    			data.w LIT        ; PFAPTR
;;
;;    CLIT
;;
_CLIT          	text.7 $84, "CLIT"
    			data.w _LIT         ; link to LIT
    			data.w CLIT       ; PFAPTR
;;
;;    EXECUTE
;;
_EXECUTE       	text.7 $87, "EXECUTE"
    			data.w _CLIT    	; link to CLIT
    			data.w EXECUTE    ; PFAPTR
;;
;;    BRANCH
;;
_BRANCH         text.7 $86, "BRANCH"
    			data.w _EXECUTE     ; link to EXECUTE
    			data.w BRAN       ; PFAPTR
;;
;;    0BRANCH
;;
_ZBRANCH        text.7 $87, "0BRANCH"
                data.w _BRANCH      ; link to BRANCH
                data.w ZBRAN 	    ; PFAPTR

;;
;;    (LOOP)
;;
_PLOOP          text.7 $86, "(LOOP)"
    			data.w _ZBRANCH    ; link to 0BRANCH
    			data.w LOOP      ; PFAPTR

;;
;;    (+LOOP)
;;
_PPLOOP         text.7 $87, "(+LOOP)"
                data.w _PLOOP    ; link to (LOOP)
                data.w PLOOP    ; PFAPTR

;;
;;    (DO)
;;
_PDO            text.7 $84, "(DO)"
                data.w _PPLOOP    ; link to (+LOOP)
                data.w DO    ; PFAPTR

;;
;;    I
;;
_I             	text.7 $81, "I"
                data.w _PDO    ; link to (DO)
                data.w I    ; PFAPTR
I:	DATA.W (I+2)
			JMP R+2

;;
;;    DIGIT
;;
_DIGIT       	text.7 $85, "DIGIT"
                data.w _I    ; link to I
                data.w DIGIT    ; PFAPTR
;;
;;    (FIND)
;;
_PFIND          text.7 $86, "(FIND)"
                data.w _DIGIT    ; link to DIGIT
                data.w FIND    ; PFAPTR
;;
;;    ENCLOSE
;;
_ENCLOSE        text.7 $87, "ENCLOSE"
                data.w _PFIND    ; link to (FIND)
                data.w ENCLOSE    ; PFAPTR
;;
;;    EMIT
;;
_EMIT           text.7 $84, "EMIT"
                data.w _ENCLOSE    ; link to ENCLOSE
                data.w EMIT    ; PFAPTR
;;
;;    KEY
;;
_KEY            text.7 $83, "KEY"
                data.w _EMIT    ; link to EMIT
                data.w KEY    ; PFAPTR
;;
;;    ?TERMINAL
;;
_QTERMINAL      text.7 $89, "?TERMINAL"
                data.w _KEY    ; link to KEY
                data.w QTERM    ; PFAPTR
;;
;;    CR
;;
_CR             text.7 $82, "CR"
                data.w _QTERMINAL    ; link to ?TERMINAL
                data.w CR    ; PFAPTR
;;
;;    XON
;;
_XON            text.7 $83, "XON"
                data.w _CR    ; link to CR
                data.w XON    ; PFAPTR
;;
;;
;;
XON:	DATA.W (XON+2)
			PHI
    						JPI (PDOTQ)
    			data.b $01, ""
    						JPI (SEMIS)
;;
;;    XOFF
;;
_XOFF           text.7 $84, "XOFF"
                data.w _XON    ; link to XON
                data.w XOFF    ; PFAPTR
;;
;;
;;
XOFF:	DATA.W (XOFF+2)
			PHI
    						JPI (PDOTQ)
                data.b $01, ""
    						JPI (SEMIS)
;;
;;    SOURCE
;;
_SOURCE         text.7 $86, "SOURCE"
                data.w _XOFF    ; link to XOFF
                data.w SOURCE    ; PFAPTR
;;
;;
;;
SOURCE:	DATA.W (SOURCE+2)
			PHI
    						JPI (ZERO)
    						JPI (BLK)
    						JPI (STORE)
    						JPI (LBRAC)
L_SOURCE_3	JPI (RPSTO)
    						JPI (XON)
    						JPI (ZERO)
    						JPI (IN)
    						JPI (STORE)
    						JPI (TIB)
    						JPI (AT)
    						JPI (CLIT)
    			data.b $00, $50, $00
    						JPI (BOUNDS)
    						JPI (DO)
L_SOURCE_2	JPI (KEY)
    						JPI (DUP)
    						JPI (CLIT)
    			data.b $00, $0d, $00
    						JPI (EQUAL)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_SOURCE_1 - addr)
    						JPI (DROP)
    						JPI (ZERO)
    						JPI (LEAVE)
L_SOURCE_1	JPI (I)
    						JPI (CSTOR)
    						JPI (LOOP)
    						data.b $00
    						data.w (L_SOURCE_2 - addr)
    						JPI (XOFF)
    						JPI (INTERPRET)
    						JPI (BRAN)
    						data.b $00
    						data.w (L_SOURCE_3 - addr)
;;
;;    FINIS
;;
_FINIS          text.7 $85, "FINIS"
                data.w _SOURCE    ; link to SOURCE
                data.w FINIS    ; PFAPTR
;;
;;
;;
FINIS:	DATA.W (FINIS+2)
			PHI
    						JPI (CR)
    						JPI (PDOTQ)
    			data.b $02, "OK"
    						JPI (BRAN)
L225	data.b $00
			data.w L1684-L225
;;
;;    CMOVE
;;
_CMOVE          text.7 $85, "CMOVE"
                data.w _FINIS    ; link to FINIS
    			data.w CMOVE    ; PFAPTR
;;
;;    U*
;;
_UMUL           text.7 $82, "U*"
                data.w _CMOVE    ; link to CMOVE
                data.w USTAR    ; PFAPTR
;;
;;    U/
;;
_UDIV           text.7 $82, "U/"
                data.w _UMUL    ; link to U*
                data.w USLAS    ; PFAPTR
;;
;;    AND
;;
_AND            text.7 $83, "AND"
                data.w _UDIV    ; link to U/
                data.w ANDD    ; PFAPTR
;;
;;    OR
;;
_OR             text.7 $82, "OR"
                data.w _AND    ; link to AND
                data.w OR    ; PFAPTR
;;
;;    XOR
;;
_XOR            text.7 $83, "XOR"
                data.w _OR    ; link to OR
                data.w XOR    ; PFAPTR
;;
;;    SP@
;;
_SPAT           text.7 $83, "SP@"
                data.w _XOR    ; link to XOR
                data.w SPAT    ; PFAPTR
;;
;;    SP!
;;
_SPSTOR         text.7 $83, "SP!"
                data.w _SPAT    ; link to SP@
                data.w SPSTO    ; PFAPTR
;;
;;    RP!
;;
_RPSTOR         text.7 $83, "RP!"
                data.w _SPSTOR    ; link to SP!
                data.w RPSTO    ; PFAPTR
;;
;;    RP@
;;
_RPAT           text.7 $83, "RP@"
                data.w _RPSTOR    ; link to RP!
                data.w PUSHS    ; PFAPTR
;;
;;    ;S
;;
_SEMIS          text.7 $82, ";S"
                data.w _RPAT    ; link to RP@
                data.w SEMIS    ; PFAPTR
;;
;;    LEAVE
;;
_LEAVE          text.7 $85, "LEAVE"
                data.w _SEMIS    ; link to ;S
                data.w LEAVE    ; PFAPTR
;;
;;    >R
;;
_GTR            text.7 $82, ">R"
                data.w _LEAVE    ; link to LEAVE
                data.w GTR    ; PFAPTR
;;
;;    R>
;;
_RGT            text.7 $82, "R>"
                data.w _GTR    ; link to >R
                data.w RFROM    ; PFAPTR
;;
;;    R
;;
_R              text.7 $81, "R"
                data.w _RGT    ; link to R>
                data.w R    ; PFAPTR
;;
;;    0=
;;
_ZEQ            text.7 $82, "0="
                data.w _R    ; link to R
                data.w ZEQ    ; PFAPTR
;;
;;    NOT
;;
_NOT            text.7 $83, "NOT"
                data.w _ZEQ    ; link to 0=
                data.w _ZLT    ; PFAPTR
                JMP ZEQ+2
;;
;;    0<
;;
_ZLT            text.7 $82, "0<"
                data.w _NOT    ; link to NOT
                data.w ZLT    ; PFAPTR
;;
;;    +
;;
_PLUS           text.7 $81, "+"
                data.w _ZLT    ; link to 0<
                data.w PLUS    ; PFAPTR
;;
;;    D+
;;
_DPLUS          text.7 $82, "D+"
                data.w _PLUS    ; link to +
                data.w DPLUS    ; PFAPTR
;;
;;    NEGATE
;;
_NEGATE         text.7 $86, "NEGATE"
                data.w _DPLUS    ; link to D+
                data.w NEGATE    ; PFAPTR
;;
;;    DNEGATE
;;
_DNEGATE        text.7 $87, "DNEGATE"
                data.w _NEGATE    ; link to NEGATE
                data.w DNEGATE    ; PFAPTR
;;
;;    OVER
;;
_OVER           text.7 $84, "OVER"
                data.w _DNEGATE    ; link to DNEGATE
                data.w OVER    ; PFAPTR
;;
;;    DROP
;;
_DROP           text.7 $84, "DROP"
                data.w _OVER    ; link to OVER
                			JPI (TWODROP)
;;
;;    2DROP
;;
_TWODROP        text.7 $85, "2DROP"
                data.w _DROP    ; link to DROP
                			JPI (SWAP)
;;
;;    SWAP
;;
_SWAP           text.7 $84, "SWAP"
                data.w _TWODROP    ; link to 2DROP
                data.w SWAP    ; PFAPTR
;;
;;    DUP
;;
_DUP            text.7 $83, "DUP"
                data.w _SWAP    ; link to SWAP
                data.w DUP    ; PFAPTR
;;
;;    2DUP
;;
_TWODUP         text.7 $84, "2DUP"
                data.w _DUP    ; link to DUP
                data.w TWODUP    ; PFAPTR
;;
;;    BOUNDS
;;
_BOUNDS         text.7 $86, "BOUNDS"
                data.w _TWODUP    ; link to 2DUP
                data.w BOUNDS    ; PFAPTR
;;
;;    +!
;;
_PLUSSTOR       text.7 $82, "+!"
                data.w _BOUNDS    ; link to BOUNDS
                data.w PSTORE    ; PFAPTR
;;
;;    TOGGLE
;;
_TOGGLE         text.7 $86, "TOGGLE"
                data.w _PLUSSTOR    ; link to +!
                data.w TOGGL    ; PFAPTR
;;
;;    @
;;
_AT             text.7 $81, "@"
                data.w _TOGGLE    ; link to TOGGLE
                data.w AT    ; PFAPTR
;;
;;    C@
;;
_CAT            text.7 $82, "C@"
                data.w _AT    ; link to @
                data.w CAT    ; PFAPTR
;;
;;    !
;;
_STOR           text.7 $81, "!"
                data.w _CAT    ; link to C@
                data.w STORE    ; PFAPTR
;;
;;    C!
;;
_CSTOR          text.7 $82, "C!"
                data.w _STOR    ; link to !
                data.w CSTOR    ; PFAPTR
;;
;; ToDo: Not sure what this one is?
;;
DCSTOR:	DATA.W (DCSTOR+2)
			PHI
			JPI (LATEST)
			JPI (PFAPTR)
			JPI (CFA)
			JPI (DUP)
			JPI (TWOPLUS)
			JPI (OVER)
			JPI (STORE)
			JPI (TWOPLUS)
			JPI (DUP)
			JPI (LIT)
			data.b $00
			data.w $0020
			JPI (SWAP)
			JPI (CSTOR)
			JPI (ONEPLUS)
			JPI (STORE)
			JPI (RFROM)
			JPI (DROP)
			JPI (SEMIS)
;;
;;    :
;;
_COLON          text.7 $c1, ":"
                data.w _CSTOR    ; link to C!
                data.w COLON    ; PFAPTR
;;
;;
;;
COLON:	DATA.W (COLON+2)
			PHI
			JPI (QEXEC)
			JPI (STORCSP)
			JPI (CURRENT)
			JPI (AT)
			JPI (CONTEXT)
			JPI (STORE)
			JPI (CREATE)
			JPI (DROP)
			JPI (RBRAC)
			JPI (LIT)
			data.b $00
			data.w $00cb
			JPI (CCOMMA)
			JPI (SEMIS)

;;
;;    ;
;;
_SEMI           text.7 $c1, ";"
                data.w _COLON    ; link to :
                data.w DSEMI    ; PFAPTR

DSEMI:	DATA.W (DSEMI+2)
			PHI
                			JPI (QCSP)
                			JPI (COMPILE)
    						JPI (SEMIS)
                			JPI (SMUDGE)
                			JPI (LBRAC)
    						JPI (SEMIS)

;;
;;    CONSTANT
;;
_CONSTANT       text.7 $88, "CONSTANT"
                data.w _SEMI    ; link to ;
                data.w CONSTANT    ; PFAPTR
;;
;;
;;
CONSTANT:	DATA.W (CONSTANT+2)
			PHI
                			JPI (CREATE)
                			JPI (SMUDGE)
                			JPI (DROP)		; discard CFA addr left by CREATE
                			JPI (CLIT)
                			data.b $00, $20, $00	; JSR opcode
                			JPI (CCOMMA)
                			JPI (LIT)
                			data.b $00
                			data.w DOCON
                			JPI (COMMA)		; write DOCON address
                			JPI (COMMA)		; write constant value
                			JPI (SEMIS)
;;
;;    VARIABLE
;;
_VARIABLE       text.7 $88, "VARIABLE"
                data.w _CONSTANT    ; link to CONSTANT
                data.w VARIABLE    ; PFAPTR
;;
;;
;;
VARIABLE:	DATA.W (VARIABLE+2)
			PHI
                			JPI (CREATE)
                			JPI (SMUDGE)
                			JPI (DROP)		; discard CFA addr left by CREATE
                			JPI (CLIT)
                			data.b $00, $20, $00	; JSR opcode
                			JPI (CCOMMA)
                			JPI (LIT)
                			data.b $00
                			data.w DOVAR
                			JPI (COMMA)		; write DOVAR address
                			JPI (COMMA)		; write initial value from stack
                			JPI (SEMIS)
;;
;;    CODE
;;
_CODE           text.7 $c4, "CODE"
                data.w _VARIABLE    ; link to VARIABLE
                data.w CODE    ; PFAPTR
;;
;;
;;
CODE:	DATA.W (CODE+2)
			PHI
                			JPI (QEXEC)
                			JPI (CREATE)
                			JPI (ASSEMBLER)
    						JPI (MEM)
                			JPI (STORCSP)
    						JPI (SEMIS)

;;
;;    USER
;;
_USER           text.7 $84, "USER"
                data.w _CODE    ; link to CODE
                data.w USER    ; PFAPTR
;;
;;
;;
USER:	DATA.W (USER+2)
			PHI
                			JPI (CREATE)
                			JPI (SMUDGE)
                			JPI (DROP)		; discard CFA addr left by CREATE
                			JPI (CLIT)
                			data.b $00, $20, $00	; JSR opcode
                			JPI (CCOMMA)
                			JPI (LIT)
                			data.b $00
                			data.w DOUSE
                			JPI (COMMA)		; write DOUSE address
                			JPI (CCOMMA)		; write user variable offset
                			JPI (SEMIS)

;;
;;    0
;;
_ZERO           text.7 $81, "0"
                data.w _USER    ; link to USER
                data.w ZERO    ; PFAPTR
;;
;;    1
;;
_ONE            text.7 $81, "1"
                data.w _ZERO    ; link to 0
                data.w ONE    ; PFAPTR
;;
;;    2
;;
_TWO            text.7 $81, "2"
                data.w _ONE    ; link to 1
                data.w TWO    ; PFAPTR
;;
;;    3
;;
_THREE          text.7 $81, "3"
                data.w _TWO    ; link to 2
                data.w THREE    ; PFAPTR
;;
;;    4
;;
_FOUR           text.7 $81, "4"
                data.w _THREE    ; link to 3
                data.w FOUR    ; PFAPTR
;;
;;    BL
;;
_BL             text.7 $82, "BL"
                data.w _FOUR    ; link to 4
                data.w BL    ; PFAPTR
;;
;;    TIB
;;
_TIB            text.7 $83, "TIB"
                data.w _BL    ; link to BL
                data.w TIB    ; PFAPTR
;;
;;    S0
;;
_S0             text.7 $82, "S0"
                data.w _TIB    ; link to TIB
                data.w SZ    ; PFAPTR
;;
;;    R0
;;
_R0             text.7 $82, "R0"
                data.w _S0    ; link to S0
                data.w RZ    ; PFAPTR
;;
;;    UC/L
;;
_UCL            text.7 $84, "UC/L"
                data.w _R0    ; link to R0
                data.w UCL    ; PFAPTR
;;
;;    UPAD
;;
_UPAD           text.7 $84, "UPAD"
                data.w _UCL    ; link to UC/L
                data.w UPAD    ; PFAPTR
;;
;;    UR/W
;;
_URW            text.7 $84, "UR/W"
                data.w _UPAD    ; link to UPAD
                data.w URW    ; PFAPTR
;;
;;    BASE
;;
_BASE           text.7 $84, "BASE"
                data.w _URW    ; link to UR/W
                data.w BASE    ; PFAPTR
;;
;;    CLD/WRM
;;
_CLDWRM         text.7 $87, "CLD/WRM"
                data.w _BASE    ; link to BASE
                data.w CLDWRM    ; PFAPTR
;;
;;    IN
;;
_IN             text.7 $82, "IN"
                data.w _CLDWRM    ; link to CLD/WRM
                data.w IN    ; PFAPTR
;;
;;    DPL
;;
_DPL            text.7 $83, "DPL"
                data.w _IN    ; link to IN
                data.w DPL    ; PFAPTR
;;
;;    HLD
;;
_HLD            text.7 $83, "HLD"
                data.w _DPL    ; link to DPL
                data.w HLD    ; PFAPTR
;;
;;    DISKNO
;;
_DISKNO         text.7 $86, "DISKNO"
                data.w _HLD    ; link to HLD
                data.w DDISKNO    ; PFAPTR
;;
;;
;;
DDISKNO:	DATA.W (DDISKNO+2)
			JSR DOUSE	
                data.b $16
;;
;;    CYLINDER
;;
_CYLINDER       text.7 $88, "CYLINDER"
                data.w _DISKNO    ; link to DISKNO
                data.w DCYLINDER    ; PFAPTR
;;
;;
;;
DCYLINDER:	DATA.W (DCYLINDER+2)
			JSR DOUSE	
                data.b $18
;;
;;    B/SIDE
;;
_BSIDE          text.7 $86, "B/SIDE"
                data.w _CYLINDER    ; link to CYLINDER
                data.w BSIDE    ; PFAPTR
;;
;;
;;
BSIDE:	DATA.W (BSIDE+2)
			JSR DOUSE	
                data.b $1c
;;
;;    UFIRST
;;
_UFIRST         text.7 $86, "UFIRST"
                data.w _BSIDE    ; link to B/SIDE
                data.w UFIRST    ; PFAPTR
;;
;;
;;
UFIRST:	DATA.W (UFIRST+2)
			JSR DOUSE	
                data.b $1e
;;
;;    ULIMIT
;;
_ULIMIT         text.7 $86, "ULIMIT"
                data.w _UFIRST    ; link to UFIRST
                data.w ULIMIT    ; PFAPTR
;;
;;
;;
ULIMIT:	DATA.W (ULIMIT+2)
			JSR DOUSE	
                data.b $20
;;
;;    OFFSET
;;
_OFFSET         text.7 $86, "OFFSET"
                data.w _ULIMIT    ; link to ULIMIT
                data.w OFFSET    ; PFAPTR
;;
;;
;;
OFFSET:	DATA.W (OFFSET+2)
			JSR DOUSE	
                data.b $22
;;
;;    WIDTH
;;
_WIDTH          text.7 $85, "WIDTH"
                data.w _OFFSET    ; link to OFFSET
                data.w WIDTH    ; PFAPTR
;;
;;
;;
WIDTH:	DATA.W (WIDTH+2)
			JSR DOUSE	
                data.b $24
;;
;;    WARNING
;;
_WARNING        text.7 $87, "WARNING"
                data.w _WIDTH    ; link to WIDTH
                data.w WARNING    ; PFAPTR
;;
;;
;;
WARNING:	DATA.W (WARNING+2)
			JSR DOUSE	
                data.b $26
;;
;;    FENCE
;;
_FENCE          text.7 $85, "FENCE"
                data.w _WARNING    ; link to WARNING
                data.w FENCE    ; PFAPTR
;;
;;
;;
FENCE:	DATA.W (FENCE+2)
			JSR DOUSE	
                data.b $28
;;
;;    DP
;;
_DP             text.7 $82, "DP"
                data.w _FENCE    ; link to FENCE
                data.w DP    ; PFAPTR
;;
;;
;;
DP:	DATA.W (DP+2)
			JSR DOUSE	
                data.b $2a
;;
;;    HEADERLESS
;;
_HEADERLESS     text.7 $8a, "HEADERLESS"
                data.w _DP    ; link to DP
                data.w HEADERLESS    ; PFAPTR
;;
;;
;;
HEADERLESS:	DATA.W (HEADERLESS+2)
			JSR DOUSE	
                data.b $2e
;;
;;    VOC-LINK
;;
_VOCL           text.7 $88, "VOC-LINK"
                data.w _HEADERLESS    ; link to HEADERLESS
                data.w VOCL    ; (Doesn't seem right)
;;
;;
;;
VOCL:	DATA.W (VOCL+2)
			JSR DOUSE	
    			data.b $30
VOCL4:	DATA.W (VOCL4+2)
			JSR DOUSE	
				data.b $34
VOCL8:	DATA.W (VOCL8+2)
			JSR DOUSE	
				data.b $3a

;;
;;    UABORT
;;
_UABORT         text.7 $86, "UABORT"
    			data.w _VOCL    ; link to VOC-LINK
    			data.w UABORT    ; PFAPTR
;;
;;
;;
UABORT:	DATA.W (UABORT+2)
			JSR DOUSE	
    			data.b $3e
;;
;;    USE
;;
_USE            text.7 $83, "USE"
    			data.w _UABORT    ; link to UABORT
    			data.w USE    ; PFAPTR

USE:	DATA.W (USE+2)
			JSR DOUSE	
    			data.b $40

;;
;;    PREV
;;
_PREV           text.7 $84, "PREV"
                data.w _USE    ; link to USE
                data.w PREV    ; PFAPTR

PREV:	DATA.W (PREV+2)
			JSR DOUSE	
    			data.b $42

;;
;;    BLK
;;
_BLK            text.7 $83, "BLK"
    			data.w _PREV    ; link to PREV
    			data.w BLK    ; PFAPTR

BLK:	DATA.W (BLK+2)
			JSR DOUSE	
    			data.b $44

;;
;;    SCR
;;
_SCR            text.7 $83, "SCR"
    			data.w _BLK    ; link to BLK
    			data.w SCR    ; PFAPTR

SCR:	DATA.W (SCR+2)
			JSR DOUSE	
                data.b $46

;;
;;    CONTEXT
;;
_CONTEXT        text.7 $87, "CONTEXT"
    			data.w _SCR    ; link to SCR
    			data.w CONTEXT    ; PFAPTR

CONTEXT:	DATA.W (CONTEXT+2)
			JSR DOUSE	
    			data.b $48

;;
;;    CURRENT
;;
_CURRENT        text.7 $87, "CURRENT"
                data.w _CONTEXT    ; link to CONTEXT
    			data.w CURRENT    ; PFAPTR

CURRENT:	DATA.W (CURRENT+2)
			JSR DOUSE	
    			data.b $4a

;;
;;    STATE
;;
_STATE          text.7 $85, "STATE"
    			data.w _CURRENT    ; link to CURRENT
    			data.w STATE    ; PFAPTR

STATE:	DATA.W (STATE+2)
			JSR DOUSE	
                data.b $4c

;;
;;    CSP
;;
_CSP            text.7 $83, "CSP"
                data.w _STATE    ; link to STATE
                data.w CSP    ; PFAPTR

CSP:	DATA.W (CSP+2)
			JSR DOUSE	
    			data.b $4e
;;
;;    MODE
;;
_MODE           text.7 $84, "MODE"
    			data.w _CSP    ; link to CSP
    			data.w MODE    ; PFAPTR

MODE:	DATA.W (MODE+2)
			JSR DOUSE	
    			data.b $50
;;
;;    KHZ
;;
_KHZ            text.7 $83, "KHZ"
    			data.w _MODE    ; link to MODE
    			data.w KHZ    ; PFAPTR

KHZ:	DATA.W (KHZ+2)
			JSR DOUSE
    			data.b $52
;;
;;    C/L
;;
DCL             text.7 $83, "C/L"
    			data.w _KHZ    ; link to KHZ
    			data.w CL    ; PFAPTR
;;
;;    FIRST
;;
_FIRST          text.7 $85, "FIRST"
    			data.w DCL    ; link to C/L
    			data.w FIRST    ; PFAPTR

FIRST:	DATA.W (FIRST+2)
			PHI
    						JPI (UFIRST)
    						JPI (AT)
    						JPI (SEMIS)
;;
;;    LIMIT
;;
_LIMIT          text.7 $85, "LIMIT"
    			data.w _FIRST    ; link to FIRST
    			data.w LIMIT    ; PFAPTR

LIMIT:	DATA.W (LIMIT+2)
			PHI
    						JPI (ULIMIT)
    						JPI (AT)
    						JPI (SEMIS)
;;
;;    PAD
;;
_PAD            text.7 $83, "PAD"
    			data.w _LIMIT    ; link to LIMIT
    			data.w PAD    ; PFAPTR
;;
;;    1+
;;
_ONEPLUS        text.7 $82, "1+"
    			data.w _PAD    ; link to PAD
    			data.w ONEPLUS    ; PFAPTR
;;
;;    2+
;;
_2PLUS          text.7 $82, "2+"
    			data.w _ONEPLUS    ; link to 1+
    			data.w TWOPLUS    ; PFAPTR
;;
;;    1-
;;
_1SUB           text.7 $82, "1-"
                data.w _2PLUS    ; link to 2+
                data.w ONEMINUS    ; PFAPTR
;;
;;    2-
;;
_2SUB           text.7 $82, "2-"
                data.w _1SUB    ; link to 1-
                data.w TWOMINUS    ; PFAPTR
;;
;;    DP/
;;
_DPDIV          text.7 $83, "DP/"
                data.w _2SUB    ; link to 2-
                data.w DPDIV    ; PFAPTR

DPDIV:	DATA.W (DPDIV+2)
			PHI
    						JPI (DP)
    						JPI (HEADERLESS)
    						JPI (AT)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_DPDIV_1 - addr)
    						JPI (TWOPLUS)
L_DPDIV_1	JPI (SEMIS)
;;
;;    HERE/
;;
_HEREDIV        text.7 $85, "HERE/"
    			data.w _DPDIV    ; link to DP/
    			data.w HEREDIV    ; PFAPTR

HEREDIV:	DATA.W (HEREDIV+2)
			PHI
    						JPI (DPDIV)
    						JPI (AT)
    						JPI (SEMIS)
;;
;;    ALLOT/
;;
_ALLOTDIV       text.7 $86, "ALLOT/"
    			data.w _HEREDIV    ; link to HERE/
    			data.w ALLOTDIV    ; PFAPTR

ALLOTDIV:	DATA.W (ALLOTDIV+2)
			PHI
    						JPI (DPDIV)
    						JPI (PSTORE)
    						JPI (SEMIS)
;;
;;    ,/
;;
_COMMADIV       text.7 $82, ",/"
    			data.w _ALLOTDIV    ; link to ALLOT/
    			data.w COMMADIV    ; PFAPTR

COMMADIV:	DATA.W (COMMADIV+2)
			PHI
    						JPI (HEREDIV)
    						JPI (STORE)
    						JPI (TWO)
    						JPI (ALLOTDIV)
    						JPI (SEMIS)
;;
;;    HERE
;;
_HERE           text.7 $84, "HERE"
                data.w _COMMADIV    ; link to ,/
                data.w HERE    ; PFAPTR

HERE:	DATA.W (HERE+2)
			PHI
    						JPI (DP)
    						JPI (AT)
    						JPI (SEMIS)
;;
;;    ALLOT
;;
_ALLOT          text.7 $85, "ALLOT"
    			data.w _HERE    ; link to HERE
                data.w ALLOT    ; PFAPTR

ALLOT:	DATA.W (ALLOT+2)
			PHI
    						JPI (DP)
    						JPI (PSTORE)
    						JPI (SEMIS)
;;
;;    ,
;;
_COMMA          text.7 $81, ","
    			data.w _ALLOT    ; link to ALLOT
    			data.w COMMA    ; PFAPTR

COMMA:	DATA.W (COMMA+2)
			PHI
    						JPI (HERE)
    						JPI (STORE)
    						JPI (TWO)
    						JPI (ALLOT)
    						JPI (SEMIS)
;;
;;    C,
;;
_CCOMMA         text.7 $82, "C,"
    			data.w _COMMA    ; link to ,
    			data.w CCOMMA    ; PFAPTR

CCOMMA:	DATA.W (CCOMMA+2)
			PHI
    						JPI (HERE)
    						JPI (CSTOR)
    						JPI (ONE)
    						JPI (ALLOT)
    						JPI (SEMIS)
;;
;;    -
;;
_SUB            text.7 $81, "-"
    			data.w _CCOMMA    ; link to C,
    			data.w SUB    ; PFAPTR
;;
;;    =
;;
_EQ             text.7 $81, "="
    			data.w _SUB    ; link to -
    			data.w EQUAL    ; PFAPTR
;;
;;    U<
;;
_ULT           	text.7 $82, "U<"
    			data.w _EQ    ; link to =
    			data.w ULESS    ; PFAPTR
;;
;;    <
;;
_LT             text.7 $81, "<"
    			data.w _ULT    ; link to U<
    			data.w LESS    ; PFAPTR
;;
;;    >
;;
_GT             text.7 $81, ">"
    			data.w _LT    ; link to <
    			data.w GT    ; PFAPTR
;;
;;    ROT
;;
_ROT            text.7 $83, "ROT"
    			data.w _GT    ; link to >
    			data.w ROT    ; PFAPTR
;;
;;    PICK
;;
_PICK           text.7 $84, "PICK"
    			data.w _ROT    ; link to ROT
    			data.w PICK    ; PFAPTR
;;
;;    SPACE
;;
_SPACE          text.7 $85, "SPACE"
    			data.w _PICK    ; link to PICK
    			data.w SPACE    ; PFAPTR
;;
;;    -DUP
;;
_SUBDUP         text.7 $84, "-DUP"
    			data.w _SPACE    ; link to SPACE
    			data.w DDUP    ; PFAPTR
;;
;;    TRAVERSE
;;
_TRAVERSE       text.7 $88, "TRAVERSE"
    			data.w _SUBDUP    ; link to -DUP
    			data.w TRAVERSE    ; PFAPTR

TRAVERSE:	DATA.W (TRAVERSE+2)
			PHI
    						JPI (SWAP)
L_TRAVERSE_1	JPI (OVER)
    						JPI (PLUS)
    						JPI (CLIT)
    			data.b $00, $7f, $00
    						JPI (OVER)
    						JPI (CAT)
    						JPI (LESS)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_TRAVERSE_1 - addr)
    						JPI (SWAP)
    						JPI (DROP)
    						JPI (SEMIS)
;;
;;    LATEST
;;
_LATEST         text.7 $86, "LATEST"
    			data.w _TRAVERSE    ; link to TRAVERSE
    			data.w LATEST    ; PFAPTR

LATEST:	DATA.W (LATEST+2)
			PHI
    						JPI (CURRENT)
    						JPI (AT)
    						JPI (AT)
    						JPI (SEMIS)
;;
;;    LFA
;;
_LFA            text.7 $83, "LFA"
    			data.w _LATEST    ; link to LATEST
    			data.w LFA    ; PFAPTR

LFA:	DATA.W (LFA+2)
			JMP TWOMINUS+2
;;
;;    CFA
;;
_CFA            text.7 $83, "CFA"
    			data.w _LFA    ; link to LFA
    			data.w CFA    ; PFAPTR

CFA:	DATA.W (CFA+2)
			PHI
			JPI (AT)
			JPI (SEMIS)
;;
;;    NFA
;;
_NFA            text.7 $83, "NFA"
    			data.w _CFA    ; link to CFA
    			data.w NFA    ; PFAPTR

NFA:	DATA.W (NFA+2)
			PHI
    						JPI (CLIT)
    			data.b $00, $03, $00
    						JPI (SUB)
    						JPI (LIT)
    						data.b $00
    						data.w $ffff
    						JPI (TRAVERSE)
    						JPI (SEMIS)
;;
;;    PFAPTR
;;
_PFAPTR         text.7 $86, "PFAPTR"
    			data.w _NFA    ; link to NFA
    			data.w PFAPTR    ; PFAPTR
;;
;;
;;
PFAPTR:	DATA.W (PFAPTR+2)
			PHI
    						JPI (ONE)
    						JPI (TRAVERSE)
    						JPI (CLIT)
    			data.b $00, $03, $00
    						JPI (PLUS)
    						JPI (SEMIS)
;;
;;    !CSP
;;
_STORCSP        text.7 $84, "!CSP"
    			data.w _PFAPTR    ; link to PFAPTR
    			data.w STORCSP    ; PFAPTR

STORCSP:	DATA.W (STORCSP+2)
			PHI
    						JPI (SPAT)
    						JPI (CSP)
    						JPI (STORE)
    						JPI (SEMIS)
;;
;;    ?ERROR
;;
_QERROR         text.7 $86, "?ERROR"
                data.w _STORCSP    ; link to !CSP
                data.w QERROR    ; PFAPTR

QERROR:	DATA.W (QERROR+2)
			PHI
    						JPI (SWAP)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_QERROR_1 - addr)
    						JPI (ERR)
L_QERROR_1	JPI (DROP)
    						JPI (SEMIS)
;;
;;    ?COMP
;;
_QCOMP          text.7 $85, "?COMP"
    			data.w _QERROR    ; link to ?ERROR
    			data.w QCOMP    ; PFAPTR

QCOMP:	DATA.W (QCOMP+2)
			PHI
    						JPI (STATE)
    						JPI (AT)
    						JPI (ZEQ)
    						JPI (CLIT)
    			data.b $00, $11, $00
    						JPI (QERROR)
    						JPI (SEMIS)
;;
;;    ?EXEC
;;
_QEXEC          text.7 $85, "?EXEC"
    			data.w _QCOMP    ; link to ?COMP
    			data.w QEXEC    ; PFAPTR

QEXEC:	DATA.W (QEXEC+2)
			PHI
    						JPI (STATE)
    						JPI (AT)
    						JPI (CLIT)
    			data.b $00, $12, $00
    						JPI (QERROR)
    						JPI (SEMIS)
;;
;;    ?PAIRS
;;
_QPAIRS         text.7 $86, "?PAIRS"
    			data.w _QEXEC    ; link to ?EXEC
    			data.w QPAIRS    ; PFAPTR

QPAIRS:	DATA.W (QPAIRS+2)
			PHI
    						JPI (SUB)
    						JPI (CLIT)
    			data.b $00, $13, $00
    						JPI (QERROR)
    						JPI (SEMIS)
;;
;;    ?CSP
;;
_QCSP           text.7 $84, "?CSP"
                data.w _QPAIRS    ; link to ?PAIRS
    			data.w QCSP    ; PFAPTR

QCSP:	DATA.W (QCSP+2)
			PHI
    						JPI (SPAT)
    						JPI (CSP)
    						JPI (AT)
    						JPI (SUB)
    						JPI (CLIT)
    			data.b $00, $14, $00
    						JPI (QERROR)
    						JPI (SEMIS)
;;
;;    COMPILE
;;
_COMPILE        text.7 $87, "COMPILE"
    			data.w _QCSP    ; link to ?CSP
    			data.w COMPILE    ; PFAPTR

COMPILE:	DATA.W (COMPILE+2)
			PHI
			JPI (QCOMP)
			JPI (RFROM)
			JPI (DUP)
			JPI (LIT)
			data.b $00
			data.w $0003
			JPI (PLUS)
			JPI (GTR)
			JPI (LIT)
			data.b $00
			data.w $000c
			JPI (CCOMMA)
			JPI (ONEPLUS)
			JPI (AT)
			JPI (COMMA)
			JPI (SEMIS)
;;
;;    [
;;
_LBRAC          text.7 $c1, "["
    			data.w _COMPILE    ; link to COMPILE
    			data.w LBRAC    ; PFAPTR

LBRAC:	DATA.W (LBRAC+2)
			PHI
    						JPI (ZERO)
    						JPI (STATE)
    						JPI (STORE)
    						JPI (SEMIS)
;;
;;    ]
;;
_RBRAC          text.7 $81, "]"
    			data.w _LBRAC    ; link to [
    			data.w RBRAC    ; PFAPTR

RBRAC:	DATA.W (RBRAC+2)
			PHI
    						JPI (CLIT)
    			data.b $00, $c0, $00
    						JPI (STATE)
    						JPI (STORE)
    						JPI (SEMIS)
;;
;;    SMUDGE
;;
_SMUDGE         text.7 $86, "SMUDGE"
    			data.w _RBRAC    ; link to ]
    			data.w SMUDGE    ; PFAPTR

SMUDGE:	DATA.W (SMUDGE+2)
			PHI
    						JPI (LATEST)
    						JPI (BL)
    						JPI (TOGGL)
    						JPI (SEMIS)
;;
;;    HEX
;;
_HEX            text.7 $83, "HEX"
    			data.w _SMUDGE    ; link to SMUDGE
    			data.w HEX    ; PFAPTR
;;
;;    DECIMAL
;;
_DECIMAL             text.7 $87, "DECIMAL"
                  data.w _HEX    ; link to HEX
                  data.w DECIMAL    ; PFAPTR
;;
;;    (;CODE)
;;
_PSEMICODE             text.7 $87, "(;CODE)"
                  data.w _DECIMAL    ; link to DECIMAL
                  data.w PSEMICODE    ; PFAPTR
;;
;;
;;
PSEMICODE:	DATA.W (PSEMICODE+2)
			PHI
			JPI (RFROM)
			JPI (LATEST)
			JPI (PFAPTR)
			JPI (CFA)
			JPI (DUP)
			JPI (TWOPLUS)
			JPI (OVER)
			JPI (STORE)
			JPI (TWOPLUS)
			JPI (DUP)
			JPI (LIT)
			data.b $00
			data.w $004c
			JPI (SWAP)
			JPI (CSTOR)
			JPI (ONEPLUS)
			JPI (STORE)
			JPI (SEMIS)
;;
;;    ;CODE
;;
_SEMICODE             text.7 $c5, ";CODE"
                  data.w _PSEMICODE    ; link to (;CODE)
                  data.w SEMICODE    ; PFAPTR
;;
;;
;;
SEMICODE:	DATA.W (SEMICODE+2)
			PHI
                  			JPI (QCSP)
                  			JPI (COMPILE)
                  			JPI (PSEMICODE)
                  			JPI (LBRAC)
                  			JPI (ASSEMBLER)
                  			JPI (SEMIS)
;;
;;    <BUILDS
;;
_LTBUILDS             text.7 $87, "<BUILDS"
                  data.w _SEMICODE    ; link to ;CODE
                  data.w LTBUILDS    ; PFAPTR
;;
;;
;;
LTBUILDS:	DATA.W (LTBUILDS+2)
			PHI
                  			JPI (ZERO)
                  			JPI (CONSTANT)
                  			JPI (SEMIS)
;;
;;    DOES>
;;
_DOESGT             text.7 $85, "DOES>"
                  data.w _LTBUILDS    ; link to <BUILDS
                  data.w DOESGT    ; PFAPTR
;;
;;
;;
DOESGT:	DATA.W (DOESGT+2)
			PHI
                  			JPI (RFROM)
                  			JPI (LATEST)
                  			JPI (PFAPTR)
                  			JPI (AT)
                  			JPI (STORE)
                  			JPI (LIT)
                  			data.b $00
                  			data.w DOES
                  			JPI (DCSTOR)
;;
;;    COUNT
;;
_COUNT             text.7 $85, "COUNT"
                  data.w _DOESGT    ; link to DOES>
                  data.w COUNT    ; PFAPTR
;;
;;    TYPE
;;
_TYPE             text.7 $84, "TYPE"
                  data.w _COUNT    ; link to COUNT
                  data.w TYPE    ; PFAPTR
;;
;;    -TRAILING
;;
_SUBTRAILING             text.7 $89, "-TRAILING"
                  data.w _TYPE    ; link to TYPE
                  data.w DTRAI    ; PFAPTR
;;
;;    (.")
;;
_PDOTQUOT             text.7 $84, "(.\")"
                  data.w _SUBTRAILING    ; link to -TRAILING
                  data.w PDOTQ    ; PFAPTR
;;
;;    ."
;;
_DOTQUOT             text.7 $c2, ".\""
                  data.w _PDOTQUOT    ; link to (.")
                  data.w DDOTQUOT    ; PFAPTR
;;
;;
;;
DDOTQUOT:	DATA.W (DDOTQUOT+2)
			PHI
                			JPI (CLIT)
                data.b $00, $22, $00
                			JPI (STATE)
                			JPI (AT)
                			JPI (ZBRAN)
                			data.b $00
                			data.w (L_DDOTQUOT_1 - addr)
                			JPI (COMPILE)
    						JPI (PDOTQ)
;;
;;
;;
CONT:	JPI (FWORD)
    						JPI (HERE)
                  			JPI (CAT)
                  			JPI (ONEPLUS)
                  			JPI (ALLOT)
                  			JPI (SEMIS)
L_DDOTQUOT_1	JPI (FWORD)
    						JPI (HERE)
                  			JPI (COUNT)
                  			JPI (TYPE)
                  			JPI (SEMIS)
;;
;;    EXPECT
;;
DEXPECT           text.7 $86, "EXPECT"
                  data.w _DOTQUOT    ; link to ."
                  data.w EXPECT    ; PFAPTR
;;
;;    QUERY
;;
_QUERY             text.7 $85, "QUERY"
                  data.w DEXPECT    ; link to EXPECT
                  data.w QUERY    ; PFAPTR
;;
;;     
;;
_FX             text.7 $c1, "\0"
                  data.w _QUERY    ; link to QUERY
                  data.w FX    ; PFAPTR
;;
;;
;;
FX:	DATA.W (FX+2)
			PHI
                  			JPI (BLK)
                  			JPI (AT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FX_1 - addr)
                  			JPI (ONE)
                  			JPI (BLK)
                  			JPI (PSTORE)
                  			JPI (ZERO)
                  			JPI (IN)
                  			JPI (STORE)
                  			JPI (QEXEC)
L_FX_1	JPI (RFROM)
                  			JPI (DROP)
                  			JPI (SEMIS)
;;
;;    FILL
;;
_FILL             text.7 $84, "FILL"
                  data.w _FX    ; link to  
                  data.w FILL_    ; PFAPTR
;;
;;    ERASE
;;
_ERASE             text.7 $85, "ERASE"
                  data.w _FILL    ; link to FILL
                  data.w ERASE    ; PFAPTR
;;
;;    BLANKS
;;
_BLANKS             text.7 $86, "BLANKS"
                  data.w _ERASE    ; link to ERASE
                  data.w BLANKS    ; PFAPTR
;;
;;    HOLD
;;
_HOLD             text.7 $84, "HOLD"
                  data.w _BLANKS    ; link to BLANKS
                  data.w HOLD    ; PFAPTR
;;
;;    WORD
;;
_FWORD             text.7 $84, "WORD"
                  data.w _HOLD    ; link to HOLD
                  data.w FWORD    ; PFAPTR
;;
;;
;;
FWORD:	DATA.W (FWORD+2)
			PHI
                  			JPI (BLK)
                  			JPI (AT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FWORD_1 - addr)
                  			JPI (BLK)
                  			JPI (AT)
                  			JPI (BLOCK)
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_FWORD_2 - addr)
L_FWORD_1	JPI (TIB)
                  			JPI (AT)
L_FWORD_2	JPI (IN)
                  			JPI (AT)
                  			JPI (PLUS)
                  			JPI (SWAP)
                  			JPI (ENCLOSE)
                  			JPI (HERE)
                  			JPI (CLIT)
                  data.b $00, $22, $00
                  			JPI (BLANKS)
                  			JPI (IN)
                  			JPI (PSTORE)
    						JPI (OVER)
                  			JPI (SUB)
                  			JPI (GTR)
    						JPI (R)
                  			JPI (HERE)
                  			JPI (CSTOR)
                  			JPI (PLUS)
                  			JPI (HERE)
                  			JPI (ONEPLUS)
                  			JPI (RFROM)
                  			JPI (CMOVE)
                  			JPI (SEMIS)
;;
;;    (NUMBER)
;;
_PNUMBER             text.7 $88, "(NUMBER)"
                  data.w _FWORD    ; link to WORD
                  data.w LTNUMBER    ; PFAPTR
;;
;;    NUMBER
;;
_NUMBER             text.7 $86, "NUMBER"
                  data.w _PNUMBER    ; link to (NUMBER)
                  data.w NUMBER    ; PFAPTR
;;
;;
;;
NUMBER:	DATA.W (NUMBER+2)
			PHI
                  			JPI (ZERO)
                  			JPI (ZERO)
                  			JPI (ROT)
    						JPI (DUP)
                  			JPI (ONEPLUS)
                  			JPI (CAT)
                  			JPI (CLIT)
                  data.b $00, $2d, $00
                  			JPI (EQUAL)
    						JPI (DUP)
                  			JPI (GTR)
                  			JPI (PLUS)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $ffff
L_NUMBER_2	JPI (DPL)
                  			JPI (STORE)
                  			JPI (LTNUMBER)
    						JPI (DUP)
                  			JPI (CAT)
                  			JPI (BL)
                  			JPI (SUB)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_NUMBER_1 - addr)
    						JPI (DUP)
                  			JPI (CAT)
                  			JPI (CLIT)
                  data.b $00, $2e, $00
                  			JPI (SUB)
                  			JPI (ZERO)
                  			JPI (QERROR)
                  			JPI (ZERO)
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_NUMBER_2 - addr)
L_NUMBER_1	JPI (DROP)
                  			JPI (RFROM)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_NUMBER_3 - addr)
                  			JPI (DNEGATE)
L_NUMBER_3	JPI (SEMIS)
;;
;;    -FIND
;;
_SUBFIND             text.7 $85, "-FIND"
                  data.w _NUMBER    ; link to NUMBER
                  data.w SUBFIND    ; PFAPTR
;;
;;
;;
SUBFIND:	DATA.W (SUBFIND+2)
			PHI
                  			JPI (BL)
                  			JPI (FWORD)
                  			JPI (HERE)
                  			JPI (CONTEXT)
                  			JPI (AT)
                  			JPI (AT)
                  			JPI (FIND)
                  			JPI (DUP)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_SUBFIND_1 - addr)
                  			JPI (DROP)
                  			JPI (HERE)
                  			JPI (LATEST)
                  			JPI (FIND)
L_SUBFIND_1	JPI (SEMIS)
;;
;;    (ABORT)
;;
_PABORT             text.7 $87, "(ABORT)"
                  data.w _SUBFIND    ; link to -FIND
                  data.w PABORT    ; PFAPTR
;;
;;
;;
PABORT:	DATA.W (PABORT+2)
			PHI
                  			JPI (UABORT)
                  			JPI (AT)
                  			JPI (EXECUTE)
                  			JPI (SEMIS)
;;
;;    ERROR
;;
_ERR             text.7 $85, "ERROR"
                  data.w _PABORT    ; link to (ABORT)
                  data.w ERR    ; PFAPTR
;;
;;
;;
ERR:	DATA.W (ERR+2)
			PHI
                  			JPI (WARNING)
                  			JPI (AT)
                  			JPI (ZLT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_ERR_1 - addr)
                  			JPI (PABORT)
L_ERR_1	JPI (HERE)
                  			JPI (COUNT)
    						JPI (CR)
                  			JPI (TYPE)
                  			JPI (PDOTQ)
                  data.b $03, " ? "
                  			JPI (FMESSAGE)
                  			JPI (SPSTO)
                  			JPI (TWODROP)
                  			JPI (IN)
                  			JPI (AT)
                  			JPI (BLK)
                  			JPI (AT)
L1684
	if CONSOLE_MODE {
	JPI (LIT)
                  			data.b $00
                  			data.w CONKEY
	} else {
	JPI (LIT)
                  			data.b $00
                  			data.w L518
	}
                  			JPI (CLIT)
                  data.b $00, $44, $00
                  			JPI (STORE)
                  			JPI (QUIT)
;;
;;    ID.
;;
_ID             text.7 $83, "ID."
                  data.w _ERR    ; link to ERROR
                  data.w ID    ; PFAPTR
;;
;;
;;
ID:	DATA.W (ID+2)
			PHI
                  			JPI (COUNT)
                  			JPI (ONEMINUS)
                  			JPI (CLIT)
                  data.b $00, $1f, $00
                  			JPI (ANDD)
                  			JPI (TWODUP)
                  			JPI (TYPE)
                  			JPI (PLUS)
                  			JPI (AT)
                  			JPI (CLIT)
                  data.b $00, $7f, $00
                  			JPI (ANDD)
                  			JPI (EMIT)
                  			JPI (SPACE)
                  			JPI (SEMIS)
;;
;;    CREATE
;;
_CREATE             text.7 $86, "CREATE"
                  data.w _ID    ; link to ID.
                  data.w CREATE    ; PFAPTR
;;
;;
;;
CREATE:	DATA.W (CREATE+2)
			PHI
                  			JPI (FIRST)
                  			JPI (HEREDIV)
                  			JPI (CLIT)
                  data.b $00, $24, $00
                  			JPI (PLUS)
                  			JPI (ULESS)
                  			JPI (TWO)
                  			JPI (QERROR)
                  			JPI (FIRST)
                  			JPI (HERE)
                  			JPI (CLIT)
                  data.b $00, $a0, $00
                  			JPI (PLUS)
                  			JPI (ULESS)
                  			JPI (TWO)
                  			JPI (QERROR)
    						JPI (SUBFIND)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_CREATE_1 - addr)
                  			JPI (DROP)
    						JPI (CR)
                  			JPI (NFA)
                  			JPI (ID)
                  			JPI (PDOTQ)
                  data.b $0b, "NOT UNIQUE "
L_CREATE_1	JPI (HERE)
                  			JPI (HEREDIV)
    						JPI (OVER)
                  			JPI (CAT)
                  			JPI (ONEPLUS)
                  			JPI (CMOVE)
                  			JPI (HEREDIV)
                  			JPI (DUP)
                  			JPI (CAT)
                  			JPI (WIDTH)
                  			JPI (AT)
                  			JPI (MIN)
                  			JPI (ONEPLUS)
                  			JPI (ALLOTDIV)
                  			JPI (DP)
                  			JPI (CAT)
                  			JPI (CLIT)
                  data.b $00, $fd, $00
                  			JPI (EQUAL)
                  			JPI (ALLOT)
                  			JPI (DUP)
                  			JPI (CLIT)
                  data.b $00, $a0, $00
                  			JPI (TOGGL)
                  			JPI (HEREDIV)
                  			JPI (ONEMINUS)
                  			JPI (CLIT)
                  data.b $00, $80, $00
                  			JPI (TOGGL)
                  			JPI (LATEST)
                  			JPI (COMMADIV)
                  			JPI (CURRENT)
                  			JPI (AT)
                  			JPI (STORE)
                  			JPI (HERE)
                  			JPI (HEADERLESS)
                  			JPI (AT)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_CREATE_2 - addr)
                  			JPI (TWOPLUS)
L_CREATE_2	JPI (DUP)
                  			JPI (COMMADIV)
                  			JPI (HERE)
                  			JPI (TWOPLUS)
                  			JPI (COMMA)
                  			JPI (SEMIS)
;;
;;    [COMPILE]
;;
_BRACCOMPILE             text.7 $c9, "[COMPILE]"
                  data.w _CREATE    ; link to CREATE
                  data.w BRACCOMPILE    ; PFAPTR
;;
;;
;;
BRACCOMPILE:	DATA.W (BRACCOMPILE+2)
			PHI
			JPI (SUBFIND)
			JPI (ZEQ)
			JPI (ZERO)
			JPI (QERROR)
			JPI (DROP)
			JPI (LIT)
			data.b $00
			data.w $000c
			JPI (CCOMMA)
			JPI (CFA)
			JPI (COMMA)
			JPI (SEMIS)
;;
;;    LITERAL
;;
_LITERAL             text.7 $c7, "LITERAL"
                  data.w _BRACCOMPILE    ; link to [COMPILE]
                  data.w LITERAL    ; PFAPTR
;;
;;
;;
LITERAL:	DATA.W (LITERAL+2)
			PHI
			JPI (STATE)
			JPI (AT)
			JPI (ZBRAN)
			data.b $00
			data.w (L_LITERAL_1 - addr)
			JPI (DUP)
			JPI (LIT)
			data.b $00
			data.w $ff00
			JPI (ANDD)
			JPI (ZBRAN)
			data.b $00
			data.w (CREATE5 - addr)
			JPI (COMPILE)
			JPI (LIT)
			JPI (LIT)
			data.b $00
			data.w $0000
			JPI (CCOMMA)
			JPI (COMMA)
			JPI (SEMIS)
;;
;;
;;
CREATE5:	JPI (COMPILE)
			JPI (CLIT)
			JPI (LIT)
			data.b $00
			data.w $0000
			JPI (CCOMMA)
			JPI (CCOMMA)
			JPI (LIT)
			data.b $00
			data.w $0000
			JPI (CCOMMA)
L_LITERAL_1			JPI (SEMIS)
;;
;;    DLITERAL
;;
_DLITERAL       text.7 $c8, "DLITERAL"
    			data.w _LITERAL    ; link to LITERAL
    			data.w DLITERAL    ; PFAPTR
;;
;;
;;
DLITERAL:	DATA.W (DLITERAL+2)
			PHI
    						JPI (STATE)
    						JPI (AT)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_DLITERAL_1 - addr)
    						JPI (SWAP)
    						JPI (LITERAL)
    						JPI (LITERAL)
L_DLITERAL_1	JPI (SEMIS)
;;
;;    ?STACK
;;
_QSTACK         text.7 $86, "?STACK"
    			data.w _DLITERAL    ; link to DLITERAL
    			data.w QSTACK    ; PFAPTR

QSTACK:	DATA.W (QSTACK+2)
			PHI
    						JPI (SPAT)
    						JPI (LIT)
    			data.b $00
    			data.w $02c2
    						JPI (SWAP)
    						JPI (ULESS)
    						JPI (ONE)
    						JPI (QERROR)
    						JPI (SPAT)
    						JPI (LIT)
    			data.b $00
    			data.w $025d
    						JPI (ULESS)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (QERROR)
    						JPI (SEMIS)
;;
;;    INTERPRET
;;
_INTERPRET      text.7 $89, "INTERPRET"
    			data.w _QSTACK    ; link to ?STACK
    			data.w INTERPRET    ; PFAPTR
;;
;;
;;
INTERPRET:	DATA.W (INTERPRET+2)
			PHI
L_INTERPRET_7			JPI (SUBFIND)
			JPI (ZBRAN)
			data.b $00
			data.w (L_INTERPRET_1 - addr)
			JPI (STATE)
			JPI (AT)
			JPI (LESS)
			JPI (ZBRAN)
			data.b $00
			data.w (L_INTERPRET_2 - addr)
			JPI (LIT)
			data.b $00
			data.w $000c
			JPI (CCOMMA)
			JPI (CFA)
			JPI (COMMA)
			JPI (BRAN)
			data.b $00
			data.w (L_INTERPRET_3 - addr)
L_INTERPRET_2			JPI (CFA)
			JPI (EXECUTE)
L_INTERPRET_3			JPI (QSTACK)
			JPI (BRAN)
			data.b $00
			data.w (L_INTERPRET_4 - addr)
L_INTERPRET_1			JPI (HERE)
			JPI (NUMBER)
			JPI (DPL)
			JPI (AT)
			JPI (ONEPLUS)
			JPI (ZBRAN)
			data.b $00
			data.w (L_INTERPRET_5 - addr)
			JPI (DLITERAL)
			JPI (BRAN)
			data.b $00
			data.w (L_INTERPRET_6 - addr)
L_INTERPRET_5			JPI (DROP)
			JPI (LITERAL)
L_INTERPRET_6			JPI (QSTACK)
L_INTERPRET_4			JPI (BRAN)
			data.b $00
			data.w (L_INTERPRET_7 - addr)
_IMMEDIATE      text.7 $89, "IMMEDIATE"
    			data.w _INTERPRET    ; link to INTERPRET
    			data.w IMMEDIATE    ; PFAPTR

IMMEDIATE:	DATA.W (IMMEDIATE+2)
			PHI
                  			JPI (LATEST)
                  			JPI (CLIT)
                  data.b $00, $40, $00
                  			JPI (TOGGL)
                  			JPI (SEMIS)
;;
;;    VOCABULARY
;;
_VOCABULARY     text.7 $8a, "VOCABULARY"
    			data.w _IMMEDIATE    ; link to IMMEDIATE
    			data.w VOCABULARY    ; PFAPTR
;;
;;
;;
VOCABULARY:	DATA.W (VOCABULARY+2)
			PHI
                  			JPI (LTBUILDS)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $a081
                  			JPI (COMMA)
                  			JPI (CURRENT)
                  			JPI (AT)
                  			JPI (TWOMINUS)
                  			JPI (COMMA)
                  			JPI (HERE)
                  			JPI (VOCL)
                  			JPI (AT)
                  			JPI (COMMA)
                  			JPI (VOCL)
                  			JPI (STORE)
                  			JPI (DOESGT)
                  			JPI (TWOPLUS)
                  			JPI (CONTEXT)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    FORTH
;;
_FORTH             text.7 $c5, "FORTH"
                  data.w _VOCABULARY    ; link to VOCABULARY
                  data.w FORTH    ; PFAPTR

FORTH:	DATA.W (FORTH+2)
			PHI
                  			JPI (VOCL4)
L_FORTH_1	JPI (CONTEXT)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    ASSEMBLER
;;
_ASSEMBLER             text.7 $c9, "ASSEMBLER"
                  data.w _FORTH    ; link to FORTH
                  data.w ASSEMBLER    ; PFAPTR
;;
;;
;;
ASSEMBLER:	DATA.W (ASSEMBLER+2)
			PHI
                  			JPI (VOCL8)
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_FORTH_1 - addr)
;;
;;    DEFINITIONS
;;
_DEFINITIONS             text.7 $8b, "DEFINITIONS"
                  data.w _ASSEMBLER    ; link to ASSEMBLER
                  data.w DEFINITIONS    ; PFAPTR
;;
;;
;;
DEFINITIONS:	DATA.W (DEFINITIONS+2)
			PHI
                  			JPI (CONTEXT)
                  			JPI (AT)
                  			JPI (CURRENT)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    (
;;
_OBRAC             text.7 $c1, "("
                  data.w _DEFINITIONS    ; link to DEFINITIONS
                  data.w OBRAC    ; PFAPTR
;;
;;
;;
OBRAC:	DATA.W (OBRAC+2)
			PHI
                  			JPI (CLIT)
                  data.b $00, $29, $00
                  			JPI (FWORD)
                  			JPI (SEMIS)
;;
;;    QUIT
;;
_QUIT             text.7 $84, "QUIT"
                  data.w _OBRAC    ; link to (
                  data.w QUIT    ; PFAPTR
;;
;;
;;
QUIT:	DATA.W (QUIT+2)
			PHI
                  			JPI (ZERO)
                  			JPI (BLK)
                  			JPI (STORE)
                  			JPI (LBRAC)
L_QUIT_2	JPI (RPSTO)
    						JPI (CR)
                  			JPI (QUERY)
                  			JPI (INTERPRET)
                  			JPI (STATE)
                  			JPI (AT)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_QUIT_1 - addr)
                  			JPI (PDOTQ)
                  data.b $02, "OK"
L_QUIT_1	JPI (BRAN)
                  			data.b $00
                  			data.w (L_QUIT_2 - addr)
;;
;;    ABORT
;;
_ABORT          text.7 $85, "ABORT"
    			data.w _QUIT    ; link to QUIT
    			data.w ABORT    ; PFAPTR

ABORT:	DATA.W (ABORT+2)
			PHI
    						JPI (SPSTO)
    						JPI (CR)
    						JPI (PDOTQ)
    			data.b $0e, "RSC-FORTH V3.0"
    						JPI (FORTH)
    						JPI (DEFINITIONS)
    						JPI (QUIT)
KSTART:			PHI
			JPI (LIT)
							data.b $00
							data.w $a55a
                  			JPI (DUP)
    						JPI (CLDWRM)
                  			JPI (AT)
                  			JPI (EQUAL)
                  			JPI (ZEQ)
                  			JPI (CLIT)
                  data.b $00, $17, $00
                  			JPI (CAT)
                  			JPI (CLIT)
                  data.b $00, $12, $00
                  			JPI (EQUAL)
                  			JPI (OR)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_ABORT_1 - addr)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $037e
                  			JPI (UPAD)
                  			JPI (STORE)
                  			JPI (LIT)
                  			data.b $00
                  			data.w UNKNOWN
                  			JPI (DCYLINDER)
                  			JPI (CLIT)
                  data.b $00, $28, $00
                  			JPI (CMOVE)
                  			JPI (LIT)
                  			data.b $00
                  			data.w _CONTRAST
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0404
                  			JPI (CLIT)
                  data.b $00, $0d, $00	; NFA(9) + LFA(2) + PFAPTR(2) = 13
                  			JPI (CMOVE)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $a000
                  			JPI (MEMTOP)
L_ABORT_1	JPI (CLDWRM)
                  			JPI (STORE)
                  			JPI (ABORT)
;;
;;    COLD
;;
_COLD             text.7 $84, "COLD"
                  data.w _ABORT    ; link to ABORT
                  data.w COLD    ; PFAPTR
;;
;;    S->D
;;
_STOD             text.7 $84, "S->D"
                  data.w _COLD    ; link to COLD
                  data.w STOD    ; PFAPTR
;;
;;    +-
;;
_PLUSMINUS             text.7 $82, "+-"
                  data.w _STOD    ; link to S->D
                  data.w PM    ; PFAPTR
;;
;;    D+-
;;
_DPLUSMINUS             text.7 $83, "D+-"
                  data.w _PLUSMINUS    ; link to +-
                  data.w DPLUS1    ; PFAPTR
;;
;;    ABS
;;
_ABS             text.7 $83, "ABS"
                  data.w _DPLUSMINUS    ; link to D+-
                  data.w ABS    ; PFAPTR
;;
;;    DABS
;;
_DABS             text.7 $84, "DABS"
                  data.w _ABS    ; link to ABS
                  data.w DABS    ; PFAPTR
;;
;;    MIN
;;
_MIN             text.7 $83, "MIN"
                  data.w _DABS    ; link to DABS
                  data.w MIN    ; PFAPTR
;;
;;    MAX
;;
_MAX             text.7 $83, "MAX"
                  data.w _MIN    ; link to MIN
                  data.w $fc70    ; PFAPTR
;;
;;    M*
;;
_MMUL             text.7 $82, "M*"
                  data.w _MAX    ; link to MAX
                  data.w MMUL    ; PFAPTR
;;
;;    M/
;;
_MDIV             text.7 $82, "M/"
                  data.w _MMUL    ; link to M*
                  data.w MDIV    ; PFAPTR
;;
;;    *
;;
_MUL             text.7 $81, "*"
                  data.w _MDIV    ; link to M/
                  data.w MUL    ; PFAPTR
;;
;;    /MOD
;;
_DIVMOD             text.7 $84, "/MOD"
                  data.w _MUL    ; link to *
                  data.w DIVMOD    ; PFAPTR
;;
;;    /
;;
_DIV             text.7 $81, "/"
                  data.w _DIVMOD    ; link to /MOD
                  data.w DIV_    ; PFAPTR
;;
;;    MOD
;;
_MOD             text.7 $83, "MOD"
                  data.w _DIV    ; link to /
                  data.w MOD_    ; PFAPTR
;;
;;    */MOD
;;
_MULDIVMOD             text.7 $85, "*/MOD"
                  data.w _MOD    ; link to MOD
                  data.w MULDIVMOD    ; PFAPTR
;;
;;    */
;;
_MULDIV             text.7 $82, "*/"
                  data.w _MULDIVMOD    ; link to */MOD
                  data.w MULDIV    ; PFAPTR
;;
;;    M/MOD
;;
_MMOD             text.7 $85, "M/MOD"
                  data.w _MULDIV    ; link to */
                  data.w MDIVMOD    ; PFAPTR
;;
;;    +BUF
;;
_PLUSBUF             text.7 $84, "+BUF"
                  data.w _MMOD    ; link to M/MOD
                  data.w PLUSBUF    ; PFAPTR

PLUSBUF:	DATA.W (PLUSBUF+2)
			PHI
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0404
                  			JPI (PLUS)
                  			JPI (LIMIT)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0404
                  			JPI (SUB)
    						JPI (OVER)
                  			JPI (ULESS)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_PLUSBUF_1 - addr)
                  			JPI (DROP)
                  			JPI (FIRST)
L_PLUSBUF_1	JPI (DUP)
                  			JPI (PREV)
                  			JPI (AT)
                  			JPI (SUB)
                  			JPI (SEMIS)
;;
;;    UPDATE
;;
_UPDATE             text.7 $86, "UPDATE"
                  data.w _PLUSBUF    ; link to +BUF
                  data.w UPDATE    ; PFAPTR

UPDATE:	DATA.W (UPDATE+2)
			PHI
                  			JPI (PREV)
                  			JPI (AT)
                  			JPI (AT)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $8000
                  			JPI (OR)
                  			JPI (PREV)
                  			JPI (AT)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    EMPTY-BUFFERS
;;
_EMPTYBUFFERS             text.7 $8d, "EMPTY-BUFFERS"
                  data.w _UPDATE    ; link to UPDATE
                  data.w EMPTYBUFFERS    ; PFAPTR

EMPTYBUFFERS:	DATA.W (EMPTYBUFFERS+2)
			PHI
                  			JPI (FIRST)
                  			JPI (LIMIT)
                  			JPI (OVER)
                  			JPI (SUB)
                  			JPI (ERASE)
                  			JPI (FIRST)
                  			JPI (DUP)
                  			JPI (USE)
                  			JPI (STORE)
                  			JPI (PREV)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    BUFFER
;;
_BUFFER             text.7 $86, "BUFFER"
                  data.w _EMPTYBUFFERS    ; link to EMPTY-BUFFERS
                  data.w BUFFER    ; PFAPTR

BUFFER:	DATA.W (BUFFER+2)
			PHI
                  			JPI (USE)
                  			JPI (AT)
                  			JPI (DUP)
                  			JPI (GTR)
L_BUFFER_1	JPI (PLUSBUF)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_BUFFER_1 - addr)
                  			JPI (USE)
                  			JPI (STORE)
    						JPI (R)
                  			JPI (AT)
                  			JPI (ZLT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_BUFFER_2 - addr)
    						JPI (R)
                  			JPI (TWOPLUS)
                  			JPI (R)
                  			JPI (AT)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $7fff
                  			JPI (ANDD)
                  			JPI (ZERO)
                  			JPI (RW)
L_BUFFER_2	JPI (R)
                  			JPI (STORE)
                  			JPI (R)
                  			JPI (PREV)
                  			JPI (STORE)
                  			JPI (RFROM)
                  			JPI (TWOPLUS)
                  			JPI (SEMIS)
;;
;;    BLOCK
;;
_BLOCK             text.7 $85, "BLOCK"
                  data.w _BUFFER    ; link to BUFFER
                  data.w BLOCK    ; PFAPTR
;;
;;
;;
BLOCK:	DATA.W (BLOCK+2)
			PHI
                  			JPI (OFFSET)
                  			JPI (AT)
                  			JPI (PLUS)
                  			JPI (GTR)
                  			JPI (PREV)
                  			JPI (AT)
                  			JPI (DUP)
                  			JPI (AT)
                  			JPI (R)
                  			JPI (SUB)
                  			JPI (DUP)
                  			JPI (PLUS)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_BLOCK_1 - addr)
L_BLOCK_3	JPI (PLUSBUF)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_BLOCK_2 - addr)
                  			JPI (DROP)
                  			JPI (R)
                  			JPI (BUFFER)
                  			JPI (DUP)
                  			JPI (R)
                  			JPI (ONE)
                  			JPI (RW)
                  			JPI (TWOMINUS)
L_BLOCK_2	JPI (DUP)
                  			JPI (AT)
                  			JPI (R)
                  			JPI (SUB)
                  			JPI (DUP)
                  			JPI (PLUS)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_BLOCK_3 - addr)
                  			JPI (DUP)
                  			JPI (PREV)
                  			JPI (STORE)
L_BLOCK_1	JPI (RFROM)
                  			JPI (DROP)
                  			JPI (TWOPLUS)
                  			JPI (SEMIS)
;;
;;    FLUSH
;;
_FLUSH             text.7 $85, "FLUSH"
                  data.w _BLOCK    ; link to BLOCK
                  data.w FLUSH    ; PFAPTR
;;
;;
;;
FLUSH:	DATA.W (FLUSH+2)
			PHI
                  			JPI (LIMIT)
                  			JPI (FIRST)
                  			JPI (SUB)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0404
                  			JPI (DIV_)
                  			JPI (ONEPLUS)
                  			JPI (ZERO)
                  			JPI (DO)
L_FLUSH_1	JPI (LIT)
                  			data.b $00
                  			data.w $7fff
                  			JPI (BUFFER)
                  			JPI (DROP)
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_FLUSH_1 - addr)
                  			JPI (SEMIS)
;;
;;    DUMP
;;
_DDUMP             text.7 $84, "DUMP"
                  data.w _FLUSH    ; link to FLUSH
                  data.w DDUMP    ; PFAPTR
;;
;;
;;
DDUMP:	DATA.W (DDUMP+2)
			PHI
                  			JPI (ZERO)
                  			JPI (DO)
L_DDUMP_2	JPI (CR)
                  			JPI (DUP)
                  			JPI (ZERO)
                  			JPI (CLIT)
                  data.b $00, $05, $00
                  			JPI (DDOTR)
                  			JPI (SPACE)
                  			JPI (CLIT)
                  data.b $00, $08, $00
                  			JPI (SWAP)
                  			JPI (OVER)
                  			JPI (ZERO)
                  			JPI (DO)
L_DDUMP_1	JPI (DUP)
                  			JPI (CAT)
    						JPI (THREE)
                  			JPI (DOTR)
                  			JPI (ONEPLUS)
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_DDUMP_1 - addr)
                  			JPI (SWAP)
                  			JPI (PLOOP)
                  			data.b $00
                  			data.w (L_DDUMP_2 - addr)
                  			JPI (DROP)
                  			JPI (CR)
                  			JPI (SEMIS)
;;
;;    (LINE)
;;
_PLINE             text.7 $86, "(LINE)"
                  data.w _DDUMP    ; link to DUMP
                  data.w PLINE    ; PFAPTR
;;
;;
;;
PLINE:	DATA.W (PLINE+2)
			PHI
                  			JPI (GTR)
                  			JPI (CLIT)
                  data.b $00, $40, $00
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0400
                  			JPI (MULDIVMOD)
                  			JPI (RFROM)
                  			JPI (PLUS)
                  			JPI (BLOCK)
                  			JPI (PLUS)
                  			JPI (CLIT)
                  data.b $00, $40, $00
                  			JPI (SEMIS)
;;
;;    .LINE
;;
_DOTLINE             text.7 $85, ".LINE"
                  data.w _PLINE    ; link to (LINE)
                  data.w DOTLINE    ; PFAPTR
;;
;;
;;
DOTLINE:	DATA.W (DOTLINE+2)
			PHI
                  			JPI (PLINE)
                  			JPI (DTRAI)
                  			JPI (TYPE)
                  			JPI (SEMIS)
;;
;;    >LINE
;;
_GTLINE             text.7 $85, ">LINE"
                  data.w _DOTLINE    ; link to .LINE
                  data.w GTLINE    ; PFAPTR
;;
;;
;;
GTLINE:	DATA.W (GTLINE+2)
			PHI
                  			JPI (SCR)
                  			JPI (AT)
                  			JPI (PLINE)
                  			JPI (OVER)
                  			JPI (SWAP)
                  			JPI (BLANKS)
                  			JPI (ZERO)
                  			JPI (FWORD)
                  			JPI (HERE)
                  			JPI (COUNT)
                  			JPI (CLIT)
                  data.b $00, $40, $00
                  			JPI (MIN)
                  			JPI (ROT)
                  			JPI (SWAP)
                  			JPI (CMOVE)
                  			JPI (UPDATE)
                  			JPI (SEMIS)
;;
;;    MESSAGE
;;
_FMESSAGE             text.7 $87, "MESSAGE"
                  data.w _GTLINE    ; link to >LINE
                  data.w FMESSAGE    ; PFAPTR
;;
;;
;;
FMESSAGE:	DATA.W (FMESSAGE+2)
			PHI
                  			JPI (DDUP)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FMESSAGE_1 - addr)
                  			JPI (WARNING)
                  			JPI (AT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FMESSAGE_2 - addr)
                  			JPI (FOUR)
                  			JPI (OFFSET)
                  			JPI (AT)
                  			JPI (SUB)
                  			JPI (DOTLINE)
L_FMESSAGE_1	JPI (SEMIS)
L_FMESSAGE_2	JPI (DUP)
                  			JPI (ONE)
                  			JPI (EQUAL)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FMESSAGE_3 - addr)
                  			JPI (DROP)
                  			JPI (PDOTQ)
                  data.b $0b, "STACK EMPTY"
                  			JPI (SEMIS)
L_FMESSAGE_3	JPI (PDOTQ)
                  data.b $05, "MSG# "
                  			JPI (BASE)
                  			JPI (AT)
                  			JPI (DECIMAL)
                  			JPI (SWAP)
                  			JPI (DOT)
                  			JPI (BASE)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    LOAD
;;
_LOAD             text.7 $84, "LOAD"
                  data.w _FMESSAGE    ; link to MESSAGE
                  data.w LOAD    ; PFAPTR
;;
;;
;;
LOAD:	DATA.W (LOAD+2)
			PHI
                  			JPI (BLK)
                  			JPI (AT)
                  			JPI (GTR)
                  			JPI (IN)
                  			JPI (AT)
                  			JPI (GTR)
                  			JPI (ZERO)
                  			JPI (IN)
                  			JPI (STORE)
                  			JPI (BLK)
                  			JPI (STORE)
                  			JPI (INTERPRET)
                  			JPI (RFROM)
                  			JPI (IN)
                  			JPI (STORE)
                  			JPI (RFROM)
                  			JPI (BLK)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    -->
;;
_ARROW             text.7 $c3, "-->"
                  data.w _LOAD    ; link to LOAD
                  data.w ARROW    ; PFAPTR
;;
;;
;;
ARROW:	DATA.W (ARROW+2)
			PHI
                  			JPI (BLK)
                  			JPI (AT)
                  			JPI (ZEQ)
                  			JPI (CLIT)
                  data.b $00, $16, $00
                  			JPI (QERROR)
                  			JPI (ZERO)
                  			JPI (IN)
                  			JPI (STORE)
                  			JPI (ONE)
                  			JPI (BLK)
                  			JPI (PSTORE)
                  			JPI (SEMIS)
;;
;;    -BCD
;;
_SUBBCD             text.7 $84, "-BCD"
                  data.w _ARROW    ; link to -->
                  data.w SUBBCD    ; PFAPTR
;;
;;
;;
SUBBCD:	DATA.W (SUBBCD+2)
			PHI
                  			JPI (ZERO)
                  			JPI (CLIT)
                  data.b $00, $0a, $00
                  			JPI (USLAS)
                  			JPI (CLIT)
                  data.b $00, $10, $00
                  			JPI (MUL)
                  			JPI (OR)
                  			JPI (SEMIS)
;;
;;    B/BUF
;;
_BBUF             text.7 $85, "B/BUF"
                  data.w _SUBBCD    ; link to -BCD
                  data.w BBUF    ; PFAPTR
;;
;;
;;
BBUF:	DATA.W (BBUF+2)
			JSR DOCON	
                  data.w $0400
;;
;;    B/SCR
;;
_BSCR             text.7 $85, "B/SCR"
                  data.w _BBUF    ; link to B/BUF
                  data.w BSCR    ; PFAPTR
;;
;;
;;
BSCR:	DATA.W (BSCR+2)
			JSR DOCON	
                  data.w $0001
;;
;;    R/W
;;
_RW             text.7 $83, "R/W"
                  data.w _BSCR    ; link to B/SCR
                  data.w RW    ; PFAPTR
;;
;;
;;
RW:	DATA.W (RW+2)
			PHI
                  			JPI (URW)
                  			JPI (AT)
                  			JPI (EXECUTE)
                  			JPI (SEMIS)
;;
;;    DISK
;;
_DISK             text.7 $84, "DISK"
                  data.w _RW    ; link to R/W
                  data.w DISK    ; PFAPTR
;;
;;    SELECT
;;
_SELECT             text.7 $86, "SELECT"
                  data.w _DISK    ; link to DISK
                  data.w SELECT    ; PFAPTR
;;
;;    DREAD
;;
_DREAD             text.7 $85, "DREAD"
                  data.w _SELECT    ; link to SELECT
                  data.w DREAD    ; PFAPTR
;;
;;    DWRITE
;;
_DWRITE             text.7 $86, "DWRITE"
                  data.w _DREAD    ; link to DREAD
                  data.w DWRITE    ; PFAPTR
;;
;;    INIT
;;
_INIT             text.7 $84, "INIT"
                  data.w _DWRITE    ; link to DWRITE
                  data.w INIT    ; PFAPTR
;;
;;    SEEK
;;
_SEEK             text.7 $84, "SEEK"
                  data.w _INIT    ; link to INIT
                  data.w SEEK    ; PFAPTR
;;
;;    '
;;
_TICK             text.7 $c1, "'"
                  data.w _SEEK    ; link to SEEK
                  data.w TICK    ; PFAPTR
;;
;;
;;
TICK:	DATA.W (TICK+2)
			PHI
                  			JPI (SUBFIND)
                  			JPI (ZEQ)
                  			JPI (ZERO)
                  			JPI (QERROR)
                  			JPI (DROP)
                  			JPI (LITERAL)
                  			JPI (SEMIS)
;;
;;    H/C
;;
_HC             text.7 $83, "H/C"
                  data.w _TICK    ; link to '
                  data.w HC    ; PFAPTR
;;
;;
;;
HC:	DATA.W (HC+2)
			PHI
                  			JPI (ONE)
                  			JPI (HEADERLESS)
                  			JPI (STORE)
                  			JPI (DUP)
                  			JPI (DPDIV)
                  			JPI (STORE)
                  			JPI (CR)
                  			JPI (PDOTQ)
                  data.b $06, "HEADS/"
                  			JPI (DOT)
                  			JPI (CR)
                  			JPI (PDOTQ)
                  data.b $06, "CODES/"
                  			JPI (HERE)
                  			JPI (DOT)
                  			JPI (SEMIS)
;;
;;    HWORD
;;
_HWORD             text.7 $85, "HWORD"
                  data.w _HC    ; link to H/C
                  data.w HWORD    ; PFAPTR
;;
;;
;;
HWORD:	DATA.W (HWORD+2)
			PHI
                  			JPI (HEADERLESS)
                  			JPI (AT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_HWORD_1 - addr)
                  			JPI (LATEST)
                  			JPI (PFAPTR)
                  			JPI (CFA)
                  			JPI (TWOPLUS)
                  			JPI (DUP)
                  			JPI (CAT)
                  			JPI (DUP)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $0020
                  			JPI (EQUAL)
                  			JPI (SWAP)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $00cb
                  			JPI (EQUAL)
                  			JPI (OR)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_HWORD_2 - addr)
                  			JPI (HEREDIV)
                  			JPI (TWOPLUS)
                  			JPI (OVER)
                  			JPI (STORE)
L_HWORD_2	JPI (HERE)
                  			JPI (OVER)
                  			JPI (DUP)
                  			JPI (DP)
                  			JPI (STORE)
                  			JPI (SUB)
                  			JPI (HEREDIV)
                  			JPI (TWOPLUS)
                  			JPI (HEREDIV)
                  			JPI (TWOMINUS)
                  			JPI (STORE)
                  			JPI (HEREDIV)
                  			JPI (SWAP)
                  			JPI (DUP)
                  			JPI (ALLOTDIV)
L_HWORD_1	JPI (CMOVE)
                  			JPI (SEMIS)
;;
;;    ?KERNEL
;;
_QKERNEL             text.7 $87, "?KERNEL"
                  data.w _HWORD    ; link to HWORD
                  data.w QKERNEL    ; PFAPTR
;;
;;
;;
QKERNEL:	DATA.W (QKERNEL+2)
			PHI
                  			JPI (TICK)
                  			JPI (CFA)
                  			JPI (LIT)
                  			data.b $00
                  			data.w INITTAB
                  			JPI (ULESS)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_QKERNEL_1 - addr)
                  			JPI (PDOTQ)
                  data.b $08, "OUTSIDE "
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_QKERNEL_2 - addr)
L_QKERNEL_1	JPI (PDOTQ)
                  data.b $07, "INSIDE "
L_QKERNEL_2	JPI (SEMIS)
;;
;;    AUTOSTART
;;
_AUTOSTART             text.7 $89, "AUTOSTART"
                  data.w _QKERNEL    ; link to ?KERNEL
                  data.w AUTOSTART    ; PFAPTR
;;
;;
;;
AUTOSTART:	DATA.W (AUTOSTART+2)
			PHI
                  			JPI (TICK)
                  			JPI (AT)
                  			JPI (DUP)
                  			JPI (LIT)
                  			data.b $00
                  			data.w FX
                  			JPI (EQUAL)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_AUTOSTART_1 - addr)
                  			JPI (PDOTQ)
                  data.b $0a, "NAME ERROR"
                  			JPI (QUIT)
L_AUTOSTART_1	JPI (OVER)
                  			JPI (TWOPLUS)
                  			JPI (STORE)
                  			JPI (LIT)
                  			data.b $00
                  			data.w $a55a
                  			JPI (SWAP)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    FORGET
;;
_FORGET             text.7 $86, "FORGET"
                  data.w _AUTOSTART    ; link to AUTOSTART
                  data.w FORGET    ; PFAPTR
;;
;;
;;
FORGET:	DATA.W (FORGET+2)
			PHI
                  			JPI (TICK)
                  			JPI (NFA)
                  			JPI (DUP)
                  data.w $d1fe
                  			JPI (SWAP)
                  			JPI (FENCE)
                  			JPI (AT)
                  			JPI (ULESS)
                  			JPI (OR)
                  			JPI (CLIT)
                  data.b $00, $15, $00
                  			JPI (QERROR)
                  			JPI (GTR)
                  			JPI (VOCL)
                  			JPI (AT)
L_FORGET_2	JPI (R)
                  			JPI (OVER)
                  			JPI (ULESS)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FORGET_1 - addr)
                  			JPI (FORTH)
                  			JPI (DEFINITIONS)
                  			JPI (AT)
                  			JPI (DUP)
                  			JPI (VOCL)
                  			JPI (STORE)
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_FORGET_2 - addr)
L_FORGET_1	JPI (DUP)
                  			JPI (FOUR)
                  			JPI (SUB)
L_FORGET_3	JPI (PFAPTR)
                  			JPI (LFA)
                  			JPI (AT)
                  			JPI (DUP)
                  data.w $d1fe
                  			JPI (SWAP)
                  			JPI (R)
                  			JPI (ULESS)
                  			JPI (OR)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FORGET_3 - addr)
                  			JPI (OVER)
                  			JPI (TWOMINUS)
                  			JPI (STORE)
                  			JPI (AT)
                  			JPI (DDUP)
                  			JPI (ZEQ)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_FORGET_1 - addr)
                  			JPI (RFROM)
                  			JPI (DUP)
                  			JPI (PFAPTR)
                  			JPI (CFA)
                  			JPI (DP)
                  			JPI (STORE)
                  			JPI (DPDIV)
                  			JPI (STORE)
                  			JPI (SEMIS)
                  			PHI
                  			JPI (LIT)
                  			data.b $00
                  			data.w UNKNOWN
                  			JPI (OVER)
                  			JPI (ULESS)
                  			JPI (OVER)
                  			JPI (LIT)
                  			data.b $00
                  			data.w PADDINGD
                  			JPI (ULESS)
                  			JPI (ANDD)
                  			JPI (SEMIS)

UNK7:	DATA.W (UNK7+2)
			PHI
                  			JPI (HERE)
                  			JPI (SUB)
                  			JPI (COMMA)
                  			JPI (SEMIS)
;;
;;    BEGIN
;;
_BEGIN             text.7 $c5, "BEGIN"
                  data.w _FORGET    ; link to FORGET
                  data.w BEGIN    ; PFAPTR
;;
;;
;;
BEGIN:	DATA.W (BEGIN+2)
			PHI
                  			JPI (QCOMP)
                  			JPI (HERE)
                  			JPI (ONE)
                  			JPI (SEMIS)
;;
;;    ENDIF
;;
_FENDIF             text.7 $c5, "ENDIF"
                  data.w _BEGIN    ; link to BEGIN
                  data.w FENDIF    ; PFAPTR
;;
;;
;;
FENDIF:	DATA.W (FENDIF+2)
			PHI
                  			JPI (QCOMP)
                  			JPI (TWO)
                  			JPI (QPAIRS)
                  			JPI (HERE)
                  			JPI (OVER)
                  			JPI (SUB)
                  			JPI (SWAP)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    THEN
;;
_FTHEN             text.7 $c4, "THEN"
                  data.w _FENDIF    ; link to ENDIF
                  data.w FTHEN    ; PFAPTR
;;
;;
;;
FTHEN:	DATA.W (FTHEN+2)
			PHI
                  			JPI (FENDIF)
                  			JPI (SEMIS)
;;
;;    DO
;;
_FDO             text.7 $c2, "DO"
                  data.w _FTHEN    ; link to THEN
                  data.w FDO    ; PFAPTR
;;
;;
;;
FDO:	DATA.W (FDO+2)
			PHI
                  			JPI (COMPILE)
                  			JPI (DO)
                  			JPI (HERE)
                  			JPI (THREE)
                  			JPI (SEMIS)
;;
;;    LOOP
;;
_LOOP             text.7 $c4, "LOOP"
                  data.w _FDO    ; link to DO
                  data.w DLOOP    ; PFAPTR
;;
;;
;;
DLOOP:	DATA.W (DLOOP+2)
			PHI
                  			JPI (THREE)
                  			JPI (QPAIRS)
                  			JPI (COMPILE)
                  			JPI (LOOP)
                  			data.w UNK7
                  			JPI (SEMIS)
;;
;;    +LOOP
;;
_PLOOP             text.7 $c5, "+LOOP"
                  data.w _LOOP    ; link to LOOP
                  data.w DPLOOP    ; PFAPTR
;;
;;
;;
DPLOOP:	DATA.W (DPLOOP+2)
			PHI
                  			JPI (THREE)
                  			JPI (QPAIRS)
                  			JPI (COMPILE)
                  			JPI (PLOOP)
                  			data.w $fff6
                  			JPI (SEMIS)
;;
;;    UNTIL
;;
_FUNTIL             text.7 $c5, "UNTIL"
                  data.w _PLOOP    ; link to +LOOP
                  data.w FUNTIL    ; PFAPTR
;;
;;
;;
FUNTIL:	DATA.W (FUNTIL+2)
			PHI
                  			JPI (ONE)
                  			JPI (QPAIRS)
                  			JPI (COMPILE)
                  			JPI (ZBRAN)
                  			data.w $fff6
                  			JPI (SEMIS)
;;
;;    END
;;
_FEND             text.7 $c3, "END"
                  data.w _FUNTIL    ; link to UNTIL
                  data.w FEND    ; PFAPTR
;;
;;
;;
FEND:	DATA.W (FEND+2)
			PHI
                  			JPI (FUNTIL)
                  			JPI (SEMIS)
;;
;;    AGAIN
;;
_FAGAIN             text.7 $c5, "AGAIN"
                  data.w _FEND    ; link to END
                  data.w FAGAIN    ; PFAPTR
;;
;;
;;
FAGAIN:	DATA.W (FAGAIN+2)
			PHI
                  			JPI (ONE)
                  			JPI (QPAIRS)
                  			JPI (COMPILE)
                  			JPI (BRAN)
                  			data.w $fff6
                  			JPI (SEMIS)
;;
;;    REPEAT
;;
_FREPEAT             text.7 $c6, "REPEAT"
                  data.w _FAGAIN    ; link to AGAIN
                  data.w FREPEAT    ; PFAPTR
;;
;;
;;
FREPEAT:	DATA.W (FREPEAT+2)
			PHI
                  			JPI (GTR)
                  			JPI (GTR)
                  			JPI (FAGAIN)
                  			JPI (RFROM)
                  			JPI (RFROM)
                  			JPI (TWOMINUS)
                  			JPI (FENDIF)
                  			JPI (SEMIS)
;;
;;    IF
;;
_FIF             text.7 $c2, "IF"
                  data.w _FREPEAT    ; link to REPEAT
                  data.w FIF    ; PFAPTR
;;
;;
;;
FIF:	DATA.W (FIF+2)
			PHI
                  			JPI (COMPILE)
                  			JPI (ZBRAN)
                  			data.w $d214
                  			JPI (ZERO)
                  			JPI (COMMA)
                  			JPI (TWO)
                  			JPI (SEMIS)
;;
;;    ELSE
;;
_FELSE             text.7 $c4, "ELSE"
                  data.w _FIF    ; link to IF
                  data.w FELSE    ; PFAPTR
;;
;;
;;
FELSE:	DATA.W (FELSE+2)
			PHI
                  			JPI (TWO)
                  			JPI (QPAIRS)
                  			JPI (COMPILE)
                  			JPI (BRAN)
                  			data.w $d214
                  			JPI (ZERO)
                  			JPI (COMMA)
                  			JPI (SWAP)
                  			JPI (TWO)
                  			JPI (FENDIF)
                  			JPI (TWO)
                  			JPI (SEMIS)
;;
;;    WHILE
;;
_FWHILE             text.7 $c5, "WHILE"
                  data.w _FELSE    ; link to ELSE
                  data.w FWHILE    ; PFAPTR
;;
;;
;;
FWHILE:	DATA.W (FWHILE+2)
			PHI
                  			JPI (FIF)
                  			JPI (TWOPLUS)
                  			JPI (SEMIS)
;;
;;    SPACES
;;
_SPACES             text.7 $86, "SPACES"
                  data.w _FWHILE    ; link to WHILE
                  data.w SPACES    ; PFAPTR
;;
;;    <#
;;
_LTNUM             text.7 $82, "<#"
                  data.w _SPACES    ; link to SPACES
                  data.w LEQ    ; PFAPTR
;;
;;    #>
;;
_NUMGT             text.7 $82, "#>"
                  data.w _LTNUM    ; link to <#
                  data.w HASHGT    ; PFAPTR
;;
;;    SIGN
;;
_SIGN             text.7 $84, "SIGN"
                  data.w _NUMGT    ; link to #>
                  data.w SIGN    ; PFAPTR
;;
;;    #
;;
_NUM             text.7 $81, "#"
                  data.w _SIGN    ; link to SIGN
                  data.w DIG    ; PFAPTR
;;
;;    #S
;;
_NUMS             text.7 $82, "#S"
                  data.w _NUM    ; link to #
                  data.w HASHS    ; PFAPTR
;;
;;    D.R
;;
_DDOTR             text.7 $83, "D.R"
                  data.w _NUMS    ; link to #S
                  data.w DDOTR    ; PFAPTR
;;
;;    D.
;;
_DDOT             text.7 $82, "D."
                  data.w _DDOTR    ; link to D.R
                  data.w DDOT    ; PFAPTR
;;
;;    .R
;;
_DOTR             text.7 $82, ".R"
                  data.w _DDOT    ; link to D.
                  data.w DOTR    ; PFAPTR
;;
;;    .
;;
_DOT             text.7 $81, "."
                  data.w _DOTR    ; link to .R
                  data.w DOT    ; PFAPTR
;;
;;    ?
;;
_Q             text.7 $81, "?"
                  data.w _DOT    ; link to .
                  data.w Q    ; PFAPTR
;;
;;    LIST
;;
_FLIST             text.7 $84, "LIST"
                  data.w _Q    ; link to ?
                  data.w FLIST    ; PFAPTR

FLIST:	DATA.W (FLIST+2)
			PHI
                  			JPI (BASE)
                  			JPI (AT)
                  			JPI (SWAP)
                  			JPI (DECIMAL)
                  			JPI (CR)
                  			JPI (DUP)
                  			JPI (SCR)
                  			JPI (STORE)
                  			JPI (PDOTQ)
                  data.b $06, "SCR # "
                  			JPI (DOT)
                  			JPI (CLIT)
                  data.b $00, $10, $00
                  			JPI (ZERO)
                  			JPI (DO)
L_FLIST_1	JPI (CR)
    						JPI (I)
                  			JPI (THREE)
                  			JPI (DOTR)
                  			JPI (SPACE)
                  			JPI (I)
                  			JPI (SCR)
                  			JPI (AT)
                  			JPI (DOTLINE)
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_FLIST_1 - addr)
                  			JPI (BASE)
                  			JPI (STORE)
                  			JPI (CR)
                  			JPI (SEMIS)
;;
;;    INDEX
;;
_INDEX             text.7 $85, "INDEX"
                  data.w _FLIST    ; link to LIST
                  data.w INDEX    ; PFAPTR
;;
;;
;;
INDEX:	DATA.W (INDEX+2)
			PHI
    						JPI (CR)
    						JPI (ONEPLUS)
    						JPI (SWAP)
    						JPI (DO)
L_INDEX_2	JPI (CR)
    						JPI (I)
    						JPI (THREE)
    						JPI (DOTR)
    						JPI (SPACE)
    						JPI (ZERO)
    						JPI (I)
    						JPI (DOTLINE)
    						JPI (QTERM)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_INDEX_1 - addr)
    						JPI (LEAVE)
L_INDEX_1	JPI (LOOP)
    						data.b $00
    						data.w (L_INDEX_2 - addr)

FORMFEED:	JPI (PDOTQ)
    			data.b $01, ""
    						JPI (SEMIS)

INDEX1:	DATA.W (INDEX1+2)
			PHI
    						JPI (PFAPTR)
    						JPI (LFA)
    						JPI (AT)
    						JPI (DUP)
    						JPI (ZEQ)
    						JPI (QTERM)
    						JPI (OR)
    						JPI (ZEQ)
    						JPI (SEMIS)

INDEX2:	DATA.W (INDEX2+2)
			PHI
    						JPI (DUP)
    						JPI (TWODUP)
    						JPI (PFAPTR)
    						JPI (ZERO)
    						JPI (CLIT)
    			data.b $00, $05, $00
    						JPI (DDOTR)
    						JPI (SPACE)
    						JPI (ID)
    						JPI (CLIT)
    			data.b $00, $0c, $00
    						JPI (ROT)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $1f, $00
    						JPI (ANDD)
    						JPI (SUB)
    						JPI (SPACES)
    						JPI (SEMIS)
;;
;;    VLIST
;;
_VLIST             text.7 $85, "VLIST"
                  data.w _INDEX    ; link to INDEX
                  data.w VLIST    ; PFAPTR
;;
;;
;;
VLIST:	DATA.W (VLIST+2)
		PHI
	; Stack: ( saved-base nfa counter )
		JPI (BASE)
		JPI (AT)
		JPI (HEX)
		JPI (CR)
		JPI (CONTEXT)
		JPI (AT)
		JPI (AT)		; ( saved-base nfa )
		JPI (LIT)
		data.b $00
		data.w 19		; ( saved-base nfa 19 )
	; --- main loop: 2 entries per line ---
.VL_ROW:	JPI (SWAP)		; ( saved-base counter nfa )
		JPI (INDEX2)
		JPI (INDEX1)		; ( saved-base counter nfa' flag )
		JPI (ZBRAN)
		data.b $00
		data.w (.VL_QUIT - addr)
		JPI (INDEX2)
		JPI (CR)
		JPI (INDEX1)		; ( saved-base counter nfa' flag )
		JPI (ZBRAN)
		data.b $00
		data.w (.VL_QUIT - addr)
		JPI (SWAP)		; ( saved-base nfa counter )
		JPI (ONEMINUS)		; decrement line counter
		JPI (DUP)
		JPI (ZBRAN)		; counter = 0? → page full
		data.b $00
		data.w (.VL_PAGE - addr)
		JPI (BRAN)		; counter != 0 → next row
		data.b $00
		data.w (.VL_ROW - addr)
	; --- page full: prompt and wait ---
.VL_PAGE:	JPI (DROP)		; drop 0 counter
		JPI (PDOTQ)
		data.b $07, " more? "
		JPI (KEY)		; ( saved-base nfa key )
		JPI (DUP)
		JPI (LIT)
		data.b $00
		data.w $1B		; ESC
		JPI (EQUAL)
		JPI (SWAP)
		JPI (LIT)
		data.b $00
		data.w $51		; 'Q'
		JPI (EQUAL)
		JPI (OR)		; ( saved-base nfa quit? )
		JPI (ZBRAN)
		data.b $00
		data.w (.VL_CONT - addr)
	; --- quit: ( saved-base nfa ) ---
		JPI (LIT)
		data.b $00
		data.w $0D		; CR to column 0
		JPI (EMIT)
		JPI (PDOTQ)
		data.b $08, "        "	; overwrite " more? "
		JPI (CR)
		JPI (DROP)		; drop nfa
		JPI (BASE)
		JPI (STORE)		; restore base
		JPI (SEMIS)
	; --- continue: ( saved-base nfa ) ---
.VL_CONT:	JPI (LIT)
		data.b $00
		data.w $0D		; CR to column 0
		JPI (EMIT)
		JPI (PDOTQ)
		data.b $08, "        "	; overwrite " more? "
		JPI (LIT)
		data.b $00
		data.w $0D		; CR to column 0 again
		JPI (EMIT)
		JPI (LIT)
		data.b $00
		data.w 19		; push fresh counter
		JPI (BRAN)
		data.b $00
		data.w (.VL_ROW - addr)
	; --- end of dictionary: ( saved-base counter nfa ) ---
.VL_QUIT:	JPI (DROP)		; drop nfa
		JPI (DROP)		; drop counter
		JPI (BASE)
		JPI (STORE)		; restore base
		JPI (SEMIS)
;;
;;    MON
;;
_MON             text.7 $83, "MON"
                  data.w _VLIST    ; link to VLIST
                  data.w MON    ; PFAPTR
;;
;;
;;
MON:	DATA.W (MON+2)
			PHI
                  			JPI (MMON)
                  			JPI (SEMIS)
;;
;;    .S
;;
_DOTS             text.7 $82, ".S"
                  data.w _MON    ; link to MON
                  data.w DOTS    ; PFAPTR
;;
;;
;;
DOTS:	DATA.W (DOTS+2)
			PHI
                  			JPI (SZ)
                  			JPI (AT)
                  			JPI (SPAT)
                  			JPI (SUB)
                  			JPI (TWO)
                  			JPI (DIV_)
                  			JPI (DUP)
                  			JPI (ONE)
                  			JPI (GT)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_DOTS_1 - addr)
                  			JPI (ONE)
                  			JPI (DO)
L_DOTS_2	JPI (I)
                  			JPI (PICK)
                  			JPI (CR)
                  			JPI (DOT)
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_DOTS_2 - addr)
                  			JPI (SEMIS)
L_DOTS_1	JPI (CR)
                  			JPI (PDOTQ)
                  data.b $06, "EMPTY "
                  			JPI (DROP)
                  			JPI (SEMIS)
;;
;;    C,CON
;;
_CCON             text.7 $85, "C,CON"
                  data.w _DOTS    ; link to .S
                  data.w CCON    ; PFAPTR
;;
;;
;;
CCON:	DATA.W (CCON+2)
			PHI
    					JPI (LTBUILDS)
    					JPI (CCOMMA)
    					JPI (IMMEDIATE)
    					JPI (DOESGT)
L3375:	JPI (CAT)
						JPI (STATE)
    					JPI (AT)
    					JPI (ZBRAN)
    					data.b $00
    					data.w (L_CCON_1 - addr)
    					JPI (LIT)
    					data.b $00
    					data.w CLIT
    					JPI (COMMA)
						JPI (CCOMMA)
L_CCON_1	JPI (SEMIS)
	
_DINTFLG	text.7 $c6, "INTFLG"
			data.w _CCON
			data.w DINTFLG
	
DINTFLG:	DATA.W (DINTFLG+2)
			JSR DOES	
			data.w L3375
			data.b $4a

_FINTVEC:	text.7 $c6, "INTVEC"
			data.w _DINTFLG
			data.w FINTVEC

FINTVEC:	DATA.W (FINTVEC+2)
			JSR DOES	
			data.w L3375
			data.b $5b

_FIRQVEC:	text.7 $c6, "IRQVEC"
			data.w _FINTVEC
			data.w FIRQVEC

FIRQVEC:	DATA.W (FIRQVEC+2)
			JSR DOES	
			data.w L3375
			data.b $5b

_FNMIVEC:	text.7 $c6, "NMIVEC"
			data.w _FIRQVEC
			data.w FNMIVEC

FNMIVEC:	DATA.W (FNMIVEC+2)
			JSR DOES	
			data.w L3375
			data.b $42

_DPA		text.7 $c2, "PA"
			data.w _FNMIVEC
			data.w DPA

DPA:	DATA.W (DPA+2)
			JSR DOES	
			data.w L3375
			data.b PortA

_DPB		text.7 $c2, "PB"
			data.w _DPA
			data.w DPB

DPB:	DATA.W (DPB+2)
			JSR DOES	
			data.w L3375
			data.b PortB

_DPC		text.7 $c2, "PC"
			data.w _DPB
			data.w DPC

DPC:	DATA.W (DPC+2)
			JSR DOES	
			data.w L3375
			data.b PortC

_DPD		text.7 $c2, "PD"
			data.w _DPC
			data.w DPD

DPD:	DATA.W (DPD+2)
			JSR DOES	
			data.w L3375
			data.b PortD

_DPE		text.7 $c2, "PE"
			data.w _DPD
			data.w DPE

DPE:	DATA.W (DPE+2)
			JSR DOES	
			data.w L3375
			data.b PortE

_DPF		text.7 $c2, "PF"
			data.w _DPE
			data.w DPF

DPF:	DATA.W (DPF+2)
			JSR DOES	
			data.w L3375
			data.b 0			; PortF not available on L28

_DPG		text.7 $c2, "PG"
			data.w _DPF
			data.w DPG

DPG:	DATA.W (DPG+2)
			JSR DOES	
			data.w L3375
			data.b 0			; PortG not available on L28
	
_DSIR		text.7 $c3, "SIR"
			data.w _DPG
			data.w DSIR

DSIR:	DATA.W (DSIR+2)
			JSR DOES
			data.w L3375
			data.b SIR

_DSMR		text.7 $c3, "SMR"
			data.w _DSIR
			data.w DSMR

DSMR:	DATA.W (DSMR+2)
			JSR DOES
			data.w L3375
			data.b SMR

_DSLCR		text.7 $c4, "SLCR"
			data.w _DSMR
			data.w DSLCR

DSLCR:	DATA.W (DSLCR+2)
			JSR DOES
			data.w L3375
			data.b SLCR

_DSSR		text.7 $c3, "SSR"
			data.w _DSLCR
			data.w DSSR

DSSR:	DATA.W (DSSR+2)
			JSR DOES
			data.w L3375
			data.b SSR

_DSFR		text.7 $c3, "SFR"
			data.w _DSSR
			data.w DSFR

DSFR:	DATA.W (DSFR+2)
			JSR DOES
			data.w L3375
			data.b SFR

;;
;;    SOB - Serial Out Buffer / SIB - Serial In Buffer
;;
_DSOB        text.7 $c3, "SOB"
    		data.w _DSFR
    		data.w DSOB
;;
;;
;;
DSOB:	DATA.W (DSOB+2)
			JSR DOES
    		data.w L3375
    		data.b SOB

;;
;;    MEMTOP
;;
_MEMTOP         text.7 $86, "MEMTOP"
    			data.w _DSOB    ; link to SOB
    			data.w MEMTOP    ; PFAPTR
				data.b $db
;;
;;
;;
MEMTOP:	DATA.W (MEMTOP+2)
			PHI
    						JPI (DUP)
    						JPI (ULIMIT)
    						JPI (STORE)
    						JPI (LIT)
    						data.b $00
    						data.w $0808
    						JPI (SUB)
    						JPI (UFIRST)
    						JPI (STORE)
    						JPI (EMPTYBUFFERS)
    						JPI (SEMIS)
;;
;;    CASE:
;;
_CASE           text.7 $85, "CASE:"
    			data.w _MEMTOP    ; link to MEMTOP
    			data.w CASE     ; PFAPTR

CASE:	DATA.W (CASE+2)
			PHI
    						JPI (LTBUILDS)
    						JPI (SMUDGE)
    						JPI (STORCSP)
    						JPI (RBRAC)
    						JPI (LIT)
    						data.b $00
    						data.w $ff87
    						JPI (HERE)
    						JPI (TWOMINUS)
    						JPI (STORE)
    						JPI (LIT)
    						data.b $00
    						data.w DOES
    						JPI (DCSTOR)
;;
;;    BANKC!
;;
_BANKCSTOR      text.7 $86, "BANKC!"
    			data.w _CASE    ; link to CASE
    			data.w BANKCSTOR    ; PFAPTR
;;
;;    BANKC@
;;
_BANKCAT        text.7 $86, "BANKC@"
    			data.w _BANKCSTOR    ; link to BANKC!
    			data.w BANKCAT    ; PFAPTR
;;
;;    BANKCOPY!
;;
_BANKCOPY       text.7 $89, "BANKCOPY!"
    			data.w _BANKCAT    ; link to BANKC@
    			data.w BANKCOPY    ; PFAPTR
;;
;;    BANKEXECUTE
;;
_BANKEXECUTE    text.7 $8b, "BANKEXECUTE"
    			data.w _BANKCOPY    ; link to BANKCOPY!
    			data.w BANKEXEC    ; PFAPTR

	;; PSET is 65C816-only, not available on L28

;;
;;    SKEY
;;
_SKEY           text.7 $84, "SKEY"
    			data.w _BANKEXECUTE    ; link to BANKEXECUTE
    			data.w SKEY            ; PFAPTR
;;
;;    SEMIT
;;
_SEMIT          text.7 $85, "SEMIT"
    			data.w _SKEY           ; link to SKEY
    			data.w SEMIT           ; PFAPTR
;;
;;    SSTAT
;;
_SSTAT          text.7 $85, "SSTAT"
    			data.w _SEMIT          ; link to SEMIT
    			data.w SSTAT           ; PFAPTR
;;
;;    SCR
;;
_SCR            text.7 $83, "SCR"
    			data.w _SSTAT          ; link to SSTAT
    			data.w SCR             ; PFAPTR
;;
;;    STYPE
;;
_STYPE          text.7 $85, "STYPE"
    			data.w _SCR            ; link to SCR
    			data.w STYPE           ; PFAPTR
;;
;;    SEXPECT
;;
_SEXPECT        text.7 $87, "SEXPECT"
    			data.w _STYPE          ; link to STYPE
    			data.w SEXPECT         ; PFAPTR
;;
;;    SETSERIAL
;;
_SETSERIAL      text.7 $89, "SETSERIAL"
    			data.w _SEXPECT        ; link to SEXPECT
    			data.w SETSERIAL       ; PFAPTR
;;
;;    FMTRK
;;
_FMTRK          text.7 $85, "FMTRK"
    			data.w _SETSERIAL      ; link to SETSERIAL
    			data.w FMTRK         ; PFAPTR
;;
;;
;;
FMTRK:	DATA.W (FMTRK+2)
    			TYA 				; save Y (data stack pointer)
    			PHA
    			LDA #$02
    			JSR SETUP
    			LDA #$f4
    			LDY #$01
    			STA DSK_STATUS
    			LDX #$31
    			LDA #$4e
.L3648 			BIT DSK_CTL
    			BVS .L3648
    			STA DSK_DATA
    			DEX 
    			BNE .L3648
.L3653 			BIT DSK_CTL
    			BVS .L3653
    			STA DSK_DATA
    			LDX #$0b
    			LDA #$00
.L3658 			BIT DSK_CTL
    			BVS .L3658
    			STA DSK_DATA
    			DEX 
    			BNE .L3658
.L3663 			BIT DSK_CTL
    			BVS .L3663
    			STA DSK_DATA
    			LDX #$02
    			LDA #$f5
.Lfmt1 			BIT DSK_CTL
    			BVS .Lfmt1
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt1
.Lfmt2 			BIT DSK_CTL
    			BVS .Lfmt2
    			STA DSK_DATA
    			LDA #$fe
.Lfmt3 			BIT DSK_CTL
    			BVS .Lfmt3
    			STA DSK_DATA
    			LDA N
.Lfmt4 			BIT DSK_CTL
    			BVS .Lfmt4
    			STA DSK_DATA
    			LDA N+2
.Lfmt5 			BIT DSK_CTL
    			BVS .Lfmt5
    			STA DSK_DATA
.Lfmt6 			BIT DSK_CTL
    			BVS .Lfmt6
    			STY DSK_DATA
    			LDA #$01
.Lfmt7 			BIT DSK_CTL
    			BVS .Lfmt7
    			STA DSK_DATA
    			LDA #$f7
.Lfmt8 			BIT DSK_CTL
    			BVS .Lfmt8
    			STA DSK_DATA
    			LDX #$15
    			LDA #$4e
.Lfmt9 			BIT DSK_CTL
    			BVS .Lfmt9
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt9
.Lfmt10 			BIT DSK_CTL
    			BVS .Lfmt10
    			STA DSK_DATA
    			LDX #$0b
    			LDA #$00
.Lfmt11 			BIT DSK_CTL
    			BVS .Lfmt11
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt11
.Lfmt12 			BIT DSK_CTL
    			BVS .Lfmt12
    			STA DSK_DATA
    			LDX #$02
    			LDA #$f5
.Lfmt13 			BIT DSK_CTL
    			BVS .Lfmt13
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt13
.Lfmt14 			BIT DSK_CTL
    			BVS .Lfmt14
    			STA DSK_DATA
    			LDX #$ff
    			LDA #$fb
.Lfmt15 			BIT DSK_CTL
    			BVS .Lfmt15
    			STA DSK_DATA
    			LDA #$20
.Lfmt16 			BIT DSK_CTL
    			BVS .Lfmt16
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt16
.Lfmt17 			BIT DSK_CTL
    			BVS .Lfmt17
    			STA DSK_DATA
    			LDA #$f7
.Lfmt18 			BIT DSK_CTL
    			BVS .Lfmt18
    			STA DSK_DATA
    			LDX #$35
    			LDA #$4e
.Lfmt19 			BIT DSK_CTL
    			BVS .Lfmt19
    			STA DSK_DATA
    			DEX 
    			BNE .Lfmt19
.Lfmt20 			BIT DSK_CTL
    			BVS .Lfmt20
    			STA DSK_DATA
    			INY 
    			CPY #$11
    			BEQ .Lfmt23
.Lfmt21 			BIT DSK_CTL
    			BVS .Lfmt21
    			STX DSK_DATA
    			LDX #$09
    			LDA #$00
.Lfmt22 			BIT DSK_CTL
    			BVS .Lfmt22
    			STA DSK_DATA
    			JMP .L3658
.Lfmt23 			LDY #$4e
.Lfmt24 			BIT DSK_CTL
    			BVS .Lfmt24
    			BPL .Lfmt25
    			STY DSK_DATA
    			JMP .Lfmt24
.Lfmt25 			PLA
    			TAY 			; restore Y (data stack pointer)
    			JMP POPTWO
;;
;;    FORMAT
;;
_FORMAT         text.7 $86, "FORMAT"
    			data.w _FMTRK      ; link to FMTRK
    			data.w FORMAT    ; PFAPTR
;;
;;
;;
FORMAT:	DATA.W (FORMAT+2)
			PHI
    						JPI (TWO)
    						JPI (MUL)
                  			JPI (SWAP)
                  			JPI (ZERO)
                  			JPI (DO)
L_FORMAT_1	JPI (DUP)
                  			JPI (ONEPLUS)
                  			JPI (SELECT)
                  			JPI (R)
                  			JPI (SEEK)
                  			JPI (ONE)
                  			JPI (R)
                  			JPI (FMTRK)
                  			JPI (DUP)
                  			JPI (SELECT)
                  			JPI (ZERO)
                  			JPI (R)
                  			JPI (FMTRK)
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_FORMAT_1 - addr)
                  			JPI (DROP)
                  			JPI (SEMIS)
;;
;;    ;DUMP
;;
_DUMP             text.7 $85, ";DUMP"
                  data.w _FORMAT    ; link to FORMAT
                  data.w DUMP     ; PFAPTR
;;
;;
;;
DUMP:	DATA.W (DUMP+2)
			PHI
                  			JPI (PDOTQ)
                  data.b $01, ";"
                  			JPI (KHZ)
                  			JPI (AT)
                  			JPI (GTR)
                  			JPI (ZERO)
                  			JPI (KHZ)
                  			JPI (STORE)
                  			JPI (TWODUP)
                  data.w CODE2
                  data.w CODE1
                  			JPI (BOUNDS)
                  			JPI (DO)
L_DUMP_1	JPI (R)
                  			JPI (CAT)
                  data.w CODE2
                  			JPI (LOOP)
                  			data.b $00
                  			data.w (L_DUMP_1 - addr)
                  			JPI (KHZ)
                  			JPI (AT)
                  data.w CODE1
                  			JPI (CR)
                  			JPI (RFROM)
                  			JPI (KHZ)
                  			JPI (STORE)
                  			JPI (SEMIS)
;;
;;    ADMP
;;
_ADMP             text.7 $84, "ADMP"
                  data.w _DUMP     ; link to ;DUMP
                  data.w ADMP    ; PFAPTR

ADMP:	DATA.W (ADMP+2)
			PHI
                  			JPI (CR)
                  			JPI (ONE)
L_ADMP_2	JPI (GTR)
                  			JPI (TWODUP)
                  			JPI (ONEPLUS)
                  			JPI (SWAP)
                  			JPI (SUB)
                  			JPI (DDUP)
                  			JPI (ZBRAN)
                  			data.b $00
                  			data.w (L_ADMP_1 - addr)
                  			JPI (CLIT)
                  data.b $00, $18, $00
                  			JPI (MIN)
                  			JPI (GTR)
                  			JPI (OVER)
                  			JPI (R)
                  			JPI (DUMP)
                  			JPI (SWAP)
                  			JPI (RFROM)
                  			JPI (PLUS)
                  			JPI (SWAP)
                  			JPI (RFROM)
                  			JPI (ONEPLUS)
                  			JPI (BRAN)
                  			data.b $00
                  			data.w (L_ADMP_2 - addr)
L_ADMP_1	JPI (RFROM)
                  			JPI (PDOTQ)
                  data.b $01, ";"
                  			JPI (ZERO)
                  data.w CODE2
                  			JPI (DUP)
                  data.w CODE1
                  data.w CODE1
                  			JPI (CR)
                  			JPI (TWODROP)
                  			JPI (SEMIS)
;;
;;
;;
CODE1:
    			LDA stack+1,Y
    			JSR L3906
    			JMP CODE2
;;
;;
;;
CODE2:
    			LDA stack,Y
    			JSR L3906
    			JMP POP

L3906:			PHA 
    			LSR A
    			LSR A
    			LSR A
    			LSR A
    			JSR L3922
    			PLA 
    			PHA 
    			CLC 
    			ADC $0352
    			STA $0352
    			BCC .Lnc1
    			INC $0353
.Lnc1 			PLA 
    			AND #$0f
L3922:			ADD #$30
    			CMP #$3a
    			BCC .Lhex1
    			ADC #$06
.Lhex1 			JMP $f5ec

NAMES:    		data.b "M REARDON R DUMSE", $00
CRIGHT:   		data.b "COPYRIGHT 1983 ROCKWELL "
	
;;
;;    N
;;
_N 	            text.7 $81, "N"
    			data.w $0332    ; link to ADMP ToDo:
    			data.w FN      ; PFAPTR

FN:	DATA.W (FN+2)
			JSR DOCON	
    			data.w N
;;
;;    IP — pushes I register (instruction pointer) onto data stack
;;
_IP             text.7 $82, "IP"
    			data.w _N      ; link to N
    			data.w FIP    ; PFAPTR

FIP:	DATA.W (FIP+2)
			PHI	; push I to hardware stack (I_hi deep, I_lo top)
			TSX				; X = stack pointer
			LDA $0102,X			; A = I_hi (peek past I_lo)
			JMP PUSH			; PUSH: stores A=hi, PLA=I_lo to data stack
;;
;;    W
;;
_W             	text.7 $81, "W"
    			data.w _IP    ; link to IP
    			data.w FW    ; PFAPTR
;;
;;
;;
FW:	DATA.W (FW+2)
			JSR DOCON	
    			data.w W
;;
;;    UP
;;
_UP             text.7 $82, "UP"
    			data.w _W   	  ; link to W
    			data.w FUP      ; PFAPTR
;;
;;
;;
FUP:	DATA.W (FUP+2)
			JSR DOCON	
    			data.w UP
;;
;;    PUSH
;;
_PUSH           text.7 $84, "PUSH"
                data.w _UP    ; link to UP
                data.w DPUSH    ; PFAPTR

DPUSH:	DATA.W (DPUSH+2)
			JSR DOCON	
                data.w PUSH
;;
;;    PUT
;;
_PUT            text.7 $83, "PUT"
    			data.w _PUSH    ; link to PUSH
    			data.w DPUT    ; PFAPTR

DPUT:	DATA.W (DPUT+2)
			JSR DOCON	
    			data.w PUT_
;;
;;    POP
;;
_POP            text.7 $83, "POP"
    			data.w _PUT    ; link to PUT
    			data.w DPOP    ; PFAPTR
;;
;;
;;
DPOP:	DATA.W (DPOP+2)
			JSR DOCON	
    			data.w POP
;;
;;    POPTWO
;;
_POPTWO         text.7 $86, "POPTWO"
                data.w _POP    ; link to POP
                data.w DPOPTWO    ; PFAPTR
;;
;;
;;
DPOPTWO:	DATA.W (DPOPTWO+2)
			JSR DOCON	
                data.w POPTWO
;;
;;    PUSH0A
;;
_DPUSH0A        text.7 $86, "PUSH0A"
                data.w _POPTWO    ; link to POPTWO
                data.w DPUSH0A    ; PFAPTR

DPUSH0A:	DATA.W (DPUSH0A+2)
			JSR DOCON	
                data.w PUSH0A
;;
;;    PUT0A
;;
_PUT0A          text.7 $85, "PUT0A"
                data.w _DPUSH0A    ; link to PUSH0A
                data.w DPUT0A    ; PFAPTR

DPUT0A:	DATA.W (DPUT0A+2)
			JSR DOCON	
                data.w L929
;;
;;    BINARY
;;
_BINARY           	text.7 $86, "BINARY"
    				data.w _PUT0A    ; link to PUT0A
    				data.w DBINARY    ; PFAPTR

DBINARY:	DATA.W (DBINARY+2)
			JSR DOCON	
    				data.w BINARY
;;
;;    SETUP
;;
_SETUP       		text.7 $85, "SETUP"
    				data.w _BINARY    ; link to BINARY
    				data.w DSETUP    ; PFAPTR

DSETUP:	DATA.W (DSETUP+2)
			JSR DOCON	
    				data.w SETUP
	
AMODE_TBL:         		data.b $09, $09, $05, $15, $15, $01, $11, $80
					data.b $09, $80, $0d, $1d, $19, $80, $80, $80
    				data.b $80, $00, $04, $14, $14, $80, $80, $80,
					data.b $80, $80, $0c, $1c, $1c, $80, $80, $2c
;;
;;    SETMODE - assembler
;;
SETMODE:         	JPI (CAT)
    				JPI (MODE)
    				JPI (STORE)
    				JPI (SEMIS)
;;
;;    .A
;;
_DOTA           text.7 $82, ".A"
    			data.w _SETUP    ; link to SETUP
    			data.w DOTA    ; PFAPTR

DOTA:	DATA.W (DOTA+2)
			JSR DOES	
    			data.w SETMODE
				data.b $00
;;
;;    #
;; 
_DHASH:			text.7 $81, "#"
				data.w _DOTA
				data.w DHASH

DHASH:	DATA.W (DHASH+2)
			JSR DOES	
				data.w SETMODE
				data.b $01

;;
;;    MEM
;; 
_MEM:			text.7 $83, "MEM"
				data.w _DHASH
				data.w MEM

MEM:	DATA.W (MEM+2)
			JSR DOES	
				data.w SETMODE
				data.b $02

;;
;;    ,X
;; 
_COMMAX:		text.7 $82, ",X"
				data.w _MEM
				data.w COMMAX

COMMAX:	DATA.W (COMMAX+2)
			JSR DOES	
				data.w SETMODE
				data.b $03

;;
;;    ,Y
;; 
_COMMAY			text.7 $82, ",Y"
				data.w _COMMAX
				data.w COMMAY

COMMAY:	DATA.W (COMMAY+2)
			JSR DOES	
				data.w SETMODE
				data.b $04

;;
;;    I)
;;
_IBRAC:			text.7 $82, "I)"
				data.w _COMMAY
				data.w IBRAC

IBRAC:	DATA.W (IBRAC+2)
			JSR DOES	
				data.w SETMODE
				data.b $05

;;
;;    )X
;;
_BRACX			text.7 $82, ")X"
				data.w _IBRAC
				data.w BRACX

BRACX:	DATA.W (BRACX+2)
			JSR DOES	
				data.w SETMODE
				data.b $06
;;
;;    )
;; 
_MRBRAC:		text.7 $81, ")"
				data.w _BRACX
				data.w MRBRAC

MRBRAC:	DATA.W (MRBRAC+2)
			JSR DOES	
				data.w SETMODE
				data.b $0f

;;
;;    TOP
;;
_DTOP:			text.7 $83, "TOP"
				data.w _MRBRAC
				data.w DTOP

DTOP:	DATA.W (DTOP+2)
			PHI
			JPI (HERE)
    						JPI (ZERO)
    						JPI (SEMIS)
;;
;;    SEC
;;
_DSEC            text.7 $83, "SEC"
    			data.w _DTOP    ; link to .A
    			data.w DSEC    ; PFAPTR

DSEC:	DATA.W (DSEC+2)
			PHI
			JPI (HERE)
    						JPI (TWO)
    						JPI (SEMIS)

;;
;;    RP)
;;
_RP:         	text.7 $83, "RP)"
                data.w _DSEC
                data.w RP

RP:	DATA.W (RP+2)
			PHI
			JPI (HERE)
							JPI (LIT)
    						data.b $00
    						data.w $01
    						JPI (SEMIS)

;;
;;
;;
CHKMODE:	DATA.W (CHKMODE+2)
			PHI
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_1 - addr)
    						JPI (MODE)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $08, $00
    						JPI (ANDD)
    						JPI (ZEQ)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_1 - addr)
    						JPI (CLIT)
    			data.b $00, $08, $00
    						JPI (MODE)
    						JPI (PSTORE)
L_CHKMODE_1	JPI (ONE)
    						JPI (MODE)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $0f, $00
    						JPI (ANDD)
    						JPI (DDUP)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_2 - addr)
    						JPI (ZERO)
    						JPI (DO)
L_CHKMODE_DO	JPI (DUP)
    						JPI (PLUS)
    						JPI (LOOP)
    						data.b $00
    						data.w (L_CHKMODE_DO - addr)
L_CHKMODE_2	JPI (OVER)
    						JPI (ONEPLUS)
    						JPI (AT)
    						JPI (ANDD)
    						JPI (ZEQ)
    						JPI (SEMIS)
	
IMPLIED	JPI (CAT)
                			JPI (CCOMMA)
                			JPI (MEM)
    						JPI (SEMIS)
	
ASMOP:
    						JPI (DUP)
    						JPI (ONEPLUS)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $80, $00
    						JPI (ANDD)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_3 - addr)
    						JPI (CLIT)
    			data.b $00, $10, $00
    						JPI (MODE)
    						JPI (PSTORE)
L_CHKMODE_3	JPI (OVER)
    						JPI (LIT)
    						data.b $00
    						data.w $ff00
    						JPI (ANDD)
    						JPI (CHKMODE)
    						JPI (CHKMODE)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_4 - addr)
    						JPI (MEM)
    						JPI (CR)
    						JPI (LATEST)
    						JPI (ID)
    						JPI (THREE)
    						JPI (ERR)
L_CHKMODE_4	JPI (CAT)
    						JPI (MODE)
    						JPI (CAT)
    						JPI (LIT)
    						data.b $00
    						data.w AMODE_TBL
    						JPI (PLUS)
    						JPI (CAT)
    						JPI (PLUS)
    						JPI (CCOMMA)
    						JPI (MODE)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (ANDD)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_5 - addr)
    						JPI (MODE)
    						JPI (CAT)
    						JPI (CLIT)
    			data.b $00, $0f, $00
    						JPI (ANDD)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (LESS)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_CHKMODE_6 - addr)
    						JPI (CCOMMA)
    						JPI (BRAN)
    						data.b $00
    						data.w (L_CHKMODE_5 - addr)
L_CHKMODE_6	JPI (COMMA)
L_CHKMODE_5	JPI (MEM)
    						JPI (SEMIS)
;;
;;    BRK,
;;
_BRKC         	text.7 $84, "BRK,"
    			data.w _RP    ; link to SEC
    			data.w BRKC    ; PFAPTR

BRKC:	DATA.W (BRKC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $00

;; 
;;    CLC,
;; 	
_CLCC			text.7 $84, "CLC,"
				data.w _BRKC	; link to BRK,
				data.w	CLCC 

CLCC:	DATA.W (CLCC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $18

;;
;;    CLD,
;; 
_CLDC:			text.7 $84, "CLD,"
				data.w _CLCC					; link to CLCC
				data.w CLDC

CLDC:	DATA.W (CLDC+2)
			JSR DOES	
    			data.w IMPLIED
				data.b $d8

;;
;;    CLI,
;; 
_CLIC:			text.7 $84, "CLI,"
				data.w _CLDC					; link to CLDC
				data.w CLIC

CLIC:	DATA.W (CLIC+2)
			JSR DOES	
    			data.w IMPLIED
				data.b $58

;;
;;    CLV,
;; 
_CLVC:			text.7 $84, "CLV,"
				data.w _CLIC
				data.w CLVC
	
CLVC:	DATA.W (CLVC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $b8

;;
;;    DEC,
;; 
_DEXC:			text.7 $84, "DEX,"
				data.w _CLVC
				data.w DEXC
	
DEXC:	DATA.W (DEXC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $ca

;;
;;    DEY,
;; 
_DEYC:			text.7 $84, "DEY,"
				data.w _DEXC
				data.w DEYC
	
DEYC:	DATA.W (DEYC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $88

;;
;;    INX,
;; 
_INXC:			text.7 $84, "INX,"
				data.w _DEYC
				data.w INXC

INXC:	DATA.W (INXC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $e8

;;
;;    INY,
;; 
_INYC:			text.7 $84, "INY,"
				data.w _INXC
				data.w INYC

INYC:	DATA.W (INYC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $c8

;;
;;    NOP,
;;  
_NOPC:			text.7 $84, "NOP,"
				data.w _INYC
				data.w NOPC

NOPC:	DATA.W (NOPC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $ea

;;
;;    PHA,
;; 
_PHAC:			text.7 $84, "PHA,"
				data.w _NOPC
				data.w PHAC

PHAC:	DATA.W (PHAC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $48
;;
;;    PHP,
;;
_PHPC:			text.7 $84, "PHP,"
				data.w _PHAC
				data.w PHPC

PHPC:	DATA.W (PHPC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $08

;;
;;    PLA,
;;
_PLAC:			text.7 $84, "PLA,"
				data.w _PHPC
				data.w PLAC

PLAC:	DATA.W (PLAC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $68

;;
;;    PLP,
;;
_PLPC:			text.7 $84, "PLP,"
				data.w _PLAC
				data.w PLPC

PLPC:	DATA.W (PLPC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $28
;;
;;    RTI,
;;
_RTIC:			text.7 $84, "RTI,"
				data.w _PLPC
				data.w RTIC

RTIC:	DATA.W (RTIC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $40
;;
;;    RTS,
;; 
_RTSC:			text.7 $84, "RTS,"
				data.w _RTIC
				data.w RTSC

RTSC:	DATA.W (RTSC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $60
;;
;;    SEC,
;;
_SECC:			text.7 $84, "SEC,"
				data.w _RTSC
				data.w SECC

SECC:	DATA.W (SECC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $38
;;
;;    SED,
;;
_SEDC:			text.7 $84, "SED,"
				data.w _SECC
				data.w SEDC

SEDC:	DATA.W (SEDC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $f8
;;
;;    SEI,
;;
_SEIC:			text.7 $84, "SEI,"
				data.w _SEDC
				data.w SEIC

SEIC:	DATA.W (SEIC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $78
;;
;;    TAX,
;;
_TAXC:			text.7 $84, "TAX,"
				data.w _SEIC
				data.w TAXC

TAXC:	DATA.W (TAXC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $aa
;;
;;    TAY,
;;
_TAYC:			text.7 $84, "TAY,"
				data.w _TAXC
				data.w TAYC

TAYC:	DATA.W (TAYC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $a8
;;
;;    TSX,
;;
_TSXC:			text.7 $84, "TSX,"
				data.w _TAYC
				data.w TSXC

TSXC:	DATA.W (TSXC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $ba
;;
;;    TXA,
;;
_TXAC:			text.7 $84, "TXA,"
				data.w _TSXC
				data.w TXAC

TXAC:	DATA.W (TXAC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $8a
;;
;;    TYA,
;;
_TYAC:			text.7 $84, "TYA,"
				data.w _TXAC
				data.w TYAC

TYAC:	DATA.W (TYAC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $98
;;
;;    TXS,
;;
_TXSC:			text.7 $84, "TXS,"
				data.w _TYAC
				data.w TXSC

TXSC:	DATA.W (TXSC+2)
			JSR DOES	
				data.w IMPLIED
				data.b $9a
;;
;;
;;    ASR,
;;
_ASRC			text.7 $84, "ASR,"
			data.w _TXSC
			data.w ASRC

ASRC:	DATA.W (ASRC+2)
			JSR DOES
				data.w IMPLIED
				data.b $3a

;;
;;    CLW,
;;
_CLWC			text.7 $84, "CLW,"
			data.w _ASRC
			data.w CLWC

CLWC:	DATA.W (CLWC+2)
			JSR DOES
				data.w IMPLIED
				data.b $51

;;
;;    EXC,
;;
_EXCC			text.7 $84, "EXC,"
			data.w _CLWC
			data.w EXCC

EXCC:	DATA.W (EXCC+2)
			PHI
						JPI (CLIT)
			data.b $00, $d4, $00
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    INI,
;;
_INIC			text.7 $84, "INI,"
			data.w _EXCC
			data.w INIC

INIC:	DATA.W (INIC+2)
			JSR DOES
				data.w IMPLIED
				data.b $bb

;;
;;    JSB0,
;;
_JSB0C			text.7 $85, "JSB0,"
			data.w _INIC
			data.w JSB0C

JSB0C:	DATA.W (JSB0C+2)
			JSR DOES
				data.w IMPLIED
				data.b $0b

;;
;;    JSB1,
;;
_JSB1C			text.7 $85, "JSB1,"
			data.w _JSB0C
			data.w JSB1C

JSB1C:	DATA.W (JSB1C+2)
			JSR DOES
				data.w IMPLIED
				data.b $1b

;;
;;    JSB2,
;;
_JSB2C			text.7 $85, "JSB2,"
			data.w _JSB1C
			data.w JSB2C

JSB2C:	DATA.W (JSB2C+2)
			JSR DOES
				data.w IMPLIED
				data.b $2b

;;
;;    JSB3,
;;
_JSB3C			text.7 $85, "JSB3,"
			data.w _JSB2C
			data.w JSB3C

JSB3C:	DATA.W (JSB3C+2)
			JSR DOES
				data.w IMPLIED
				data.b $3b

;;
;;    JSB4,
;;
_JSB4C			text.7 $85, "JSB4,"
			data.w _JSB3C
			data.w JSB4C

JSB4C:	DATA.W (JSB4C+2)
			JSR DOES
				data.w IMPLIED
				data.b $4b

;;
;;    JSB5,
;;
_JSB5C			text.7 $85, "JSB5,"
			data.w _JSB4C
			data.w JSB5C

JSB5C:	DATA.W (JSB5C+2)
			JSR DOES
				data.w IMPLIED
				data.b $5b

;;
;;    JSB6,
;;
_JSB6C			text.7 $85, "JSB6,"
			data.w _JSB5C
			data.w JSB6C

JSB6C:	DATA.W (JSB6C+2)
			JSR DOES
				data.w IMPLIED
				data.b $6b

;;
;;    JSB7,
;;
_JSB7C			text.7 $85, "JSB7,"
			data.w _JSB6C
			data.w JSB7C

JSB7C:	DATA.W (JSB7C+2)
			JSR DOES
				data.w IMPLIED
				data.b $7b

;;
;;    LAB,
;;
_LABC			text.7 $84, "LAB,"
			data.w _JSB7C
			data.w LABC

LABC:	DATA.W (LABC+2)
			JSR DOES
				data.w IMPLIED
				data.b $13

;;
;;    LAI,
;;
_LAIC			text.7 $84, "LAI,"
			data.w _LABC
			data.w LAIC

LAIC:	DATA.W (LAIC+2)
			JSR DOES
				data.w IMPLIED
				data.b $eb

;;
;;    LAN,
;;
_LANC			text.7 $84, "LAN,"
			data.w _LAIC
			data.w LANC

LANC:	DATA.W (LANC+2)
			JSR DOES
				data.w IMPLIED
				data.b $ab

;;
;;    LII,
;;
_LIIC			text.7 $84, "LII,"
			data.w _LANC
			data.w LIIC

LIIC:	DATA.W (LIIC+2)
			JSR DOES
				data.w IMPLIED
				data.b $9b

;;
;;    MPA,
;;
_MPAC			text.7 $84, "MPA,"
			data.w _LIIC
			data.w MPAC

MPAC:	DATA.W (MPAC+2)
			JSR DOES
				data.w IMPLIED
				data.b $12

;;
;;    MPY,
;;
_MPYC			text.7 $84, "MPY,"
			data.w _MPAC
			data.w MPYC

MPYC:	DATA.W (MPYC+2)
			JSR DOES
				data.w IMPLIED
				data.b $02

;;
;;    NEG,
;;
_NEGC			text.7 $84, "NEG,"
			data.w _MPYC
			data.w NEGC

NEGC:	DATA.W (NEGC+2)
			JSR DOES
				data.w IMPLIED
				data.b $1a

;;
;;    NXT,
;;
_NXTC			text.7 $84, "NXT,"
			data.w _NEGC
			data.w NXTC

NXTC:	DATA.W (NXTC+2)
			JSR DOES
				data.w IMPLIED
				data.b $8b

;;
;;    PHI,
;;
_PHIC			text.7 $84, "PHI,"
			data.w _NXTC
			data.w PHIC

PHIC:	DATA.W (PHIC+2)
			JSR DOES
				data.w IMPLIED
				data.b $cb

;;
;;    PHW,
;;
_PHWC			text.7 $84, "PHW,"
			data.w _PHIC
			data.w PHWC

PHWC:	DATA.W (PHWC+2)
			JSR DOES
				data.w IMPLIED
				data.b $23

;;
;;    PHX,
;;
_PHXC			text.7 $84, "PHX,"
			data.w _PHWC
			data.w PHXC

PHXC:	DATA.W (PHXC+2)
			JSR DOES
				data.w IMPLIED
				data.b $da

;;
;;    PHY,
;;
_PHYC			text.7 $84, "PHY,"
			data.w _PHXC
			data.w PHYC

PHYC:	DATA.W (PHYC+2)
			JSR DOES
				data.w IMPLIED
				data.b $5a

;;
;;    PIA,
;;
_PIAC			text.7 $84, "PIA,"
			data.w _PHYC
			data.w PIAC

PIAC:	DATA.W (PIAC+2)
			JSR DOES
				data.w IMPLIED
				data.b $fb

;;
;;    PLI,
;;
_PLIC			text.7 $84, "PLI,"
			data.w _PIAC
			data.w PLIC

PLIC:	DATA.W (PLIC+2)
			JSR DOES
				data.w IMPLIED
				data.b $db

;;
;;    PLW,
;;
_PLWC			text.7 $84, "PLW,"
			data.w _PLIC
			data.w PLWC

PLWC:	DATA.W (PLWC+2)
			JSR DOES
				data.w IMPLIED
				data.b $33

;;
;;    PLX,
;;
_PLXC			text.7 $84, "PLX,"
			data.w _PLWC
			data.w PLXC

PLXC:	DATA.W (PLXC+2)
			JSR DOES
				data.w IMPLIED
				data.b $fa

;;
;;    PLY,
;;
_PLYC			text.7 $84, "PLY,"
			data.w _PLXC
			data.w PLYC

PLYC:	DATA.W (PLYC+2)
			JSR DOES
				data.w IMPLIED
				data.b $7a

;;
;;    PSH,
;;
_PSHC			text.7 $84, "PSH,"
			data.w _PLYC
			data.w PSHC

PSHC:	DATA.W (PSHC+2)
			JSR DOES
				data.w IMPLIED
				data.b $22

;;
;;    PUL,
;;
_PULC			text.7 $84, "PUL,"
			data.w _PSHC
			data.w PULC

PULC:	DATA.W (PULC+2)
			JSR DOES
				data.w IMPLIED
				data.b $32

;;
;;    RND,
;;
_RNDC			text.7 $84, "RND,"
			data.w _PULC
			data.w RNDC

RNDC:	DATA.W (RNDC+2)
			JSR DOES
				data.w IMPLIED
				data.b $42

;;
;;    TAW,
;;
_TAWC			text.7 $84, "TAW,"
			data.w _RNDC
			data.w TAWC

TAWC:	DATA.W (TAWC+2)
			JSR DOES
				data.w IMPLIED
				data.b $62

;;
;;    TIP,
;;
_TIPC			text.7 $84, "TIP,"
			data.w _TAWC
			data.w TIPC

TIPC:	DATA.W (TIPC+2)
			JSR DOES
				data.w IMPLIED
				data.b $03

;;
;;    TWA,
;;
_TWAC			text.7 $84, "TWA,"
			data.w _TIPC
			data.w TWAC

TWAC:	DATA.W (TWAC+2)
			JSR DOES
				data.w IMPLIED
				data.b $72

;;    ADC,
;;
_ADCC:		text.7 $84, "ADC,"
			data.w _TWAC
			data.w ADCC

ADCC:	DATA.W (ADCC+2)
			JSR DOES	
			data.w ASMOP
			data.b $60, $6e, $1c

;;
;;    AND,
;;
_ANDC:		text.7 $84, "AND,"
			data.w _ADCC
			data.w ANDC

ANDC:	DATA.W (ANDC+2)
			JSR DOES	
			data.w ASMOP
			data.b $20, $6e, $1c

;;
;;    CMP,
;;
_CMPC:		text.7 $84, "CMP,"
			data.w _ANDC
			data.w CMPC

CMPC:	DATA.W (CMPC+2)
			JSR DOES	
			data.w ASMOP
			data.b $c0, $6e, $1c

	;;
	;;    EOR,
	;;
_EORC:		text.7 $84, "EOR,"
			data.w _CMPC
			data.w EORC

EORC:	DATA.W (EORC+2)
			JSR DOES	
			data.w ASMOP
			data.b $40, $6e, $1c

	;;
	;;    LDA,
	;;
_LDAC:		text.7 $84, "LDA,"
			data.w _EORC
			data.w LDAC

LDAC:	DATA.W (LDAC+2)
			JSR DOES	
			data.w ASMOP
			data.b $a0, $6e, $1c

	;;
	;;    ORA,
	;;
_ORAC:		text.7 $84, "ORA,"
			data.w _LDAC
			data.w ORAC

ORAC:	DATA.W (ORAC+2)
			JSR DOES	
			data.w ASMOP
			data.b $00, $6e, $1c

	;;
	;;    SBC,
	;;
_SBCC:		text.7 $84, "SBC,"
			data.w _ORAC
			data.w SBCC

SBCC:	DATA.W (SBCC+2)
			JSR DOES	
			data.w ASMOP
			data.b $e0, $6e, $1c

	;;
	;;    STA,
	;;
_STAC:		text.7 $84, "STA,"
			data.w _SBCC
			data.w STAC

STAC:	DATA.W (STAC+2)
			JSR DOES	
			data.w ASMOP
			data.b $80, $6c, $1c

	;;
	;;    ASL,
	;;
_ASLC:		text.7 $84, "ASL,"
			data.w _STAC
			data.w ASLC

ASLC:	DATA.W (ASLC+2)
			JSR DOES	
			data.w ASMOP
			data.b $01, $0d, $0d

	;;
	;;    DEC,
	;;
_DECC:		text.7 $84, "DEC,"
			data.w _ASLC
			data.w DECC

DECC:	DATA.W (DECC+2)
			JSR DOES	
			data.w ASMOP
			data.b $c1, $0c, $0c

	;;
	;;    INC,
	;;
_INCC:		text.7 $84, "INC,"
			data.w _DECC
			data.w INCC

INCC:	DATA.W (INCC+2)
			JSR DOES	
			data.w ASMOP
			data.b $e1, $0c, $0c

	;;
	;;    LSR,
	;;
_LSRC:		text.7 $84, "LSR,"
			data.w _INCC
			data.w LSRC

LSRC:	DATA.W (LSRC+2)
			JSR DOES	
			data.w ASMOP
			data.b $41, $0d, $0d

	;;
	;;    ROL,
	;;
_ROLC:		text.7 $84, "ROL,"
			data.w _LSRC
			data.w ROLC

ROLC:	DATA.W (ROLC+2)
			JSR DOES	
			data.w ASMOP
			data.b $21, $0d, $0d

	;;
	;;    ROR,
	;;
_RORC:		text.7 $84, "ROR,"
			data.w _ROLC
			data.w RORC

RORC:	DATA.W (RORC+2)
			JSR DOES	
			data.w ASMOP
			data.b $61, $0d, $0d

	;;
	;;    STX,
	;;
_STXC:		text.7 $84, "STX,"
			data.w _RORC
			data.w STXC

STXC:	DATA.W (STXC+2)
			JSR DOES	
			data.w ASMOP
			data.b $81, $14, $04

	;;
	;;    CPX,
	;;
_CPXC:		text.7 $84, "CPX,"
			data.w _STXC
			data.w CPXC

CPXC:	DATA.W (CPXC+2)
			JSR DOES	
			data.w ASMOP
			data.b $e0, $86, $04

	;;
	;;    CPY,
	;;
_CPYC:		text.7 $84, "CPY,"
			data.w _CPXC
			data.w CPYC

CPYC:	DATA.W (CPYC+2)
			JSR DOES	
			data.w ASMOP
			data.b $c0, $86, $04

	;;
	;;    LDX,
	;;
_LDXC:		text.7 $84, "LDX,"
			data.w _CPYC
			data.w LDXC

LDXC:	DATA.W (LDXC+2)
			JSR DOES	
			data.w ASMOP
			data.b $a2, $96, $14

	;;
	;;    LDY,
	;;
_LDYC:		text.7 $84, "LDY,"
			data.w _LDXC
			data.w LDYC

LDYC:	DATA.W (LDYC+2)
			JSR DOES	
			data.w ASMOP
			data.b $a0, $8e, $0c

	;;
	;;    STY,
	;;
_STYC:		text.7 $84, "STY,"
			data.w _LDYC
			data.w STYC

STYC:	DATA.W (STYC+2)
			JSR DOES	
			data.w ASMOP
			data.b $80, $8c, $04

	;;
	;;    JSR,
	;;
_JSRC:		text.7 $84, "JSR,"
			data.w _STYC
			data.w JSRC

JSRC:	DATA.W (JSRC+2)
			JSR DOES	
			data.w ASMOP
			data.b $14, $80, $04

	;;
	;;    JMP,
	;;
_JMPC:		text.7 $84, "JMP,"
			data.w _JSRC
			data.w JMPC

JMPC:	DATA.W (JMPC+2)
			JSR DOES	
			data.w ASMOP
			data.b $40, $80, $84

	;;
	;;    BIT,
	;; 
_BITC:		text.7 $84, "BIT,"
			data.w _JMPC
			data.w BITC

BITC:	DATA.W (BITC+2)
			JSR DOES	
			data.w ASMOP
			data.b $20, $84, $04

;;
;;    SMB,
;;
_SMBC           text.7 $84, "SMB,"
    			data.w _BITC    ; link to BIT,
    			data.w SMBC   ; PFAPTR

SMBC:	DATA.W (SMBC+2)
			PHI
    						JPI (MODE)
    						JPI (AT)
    						JPI (MEM)
    						JPI (TWO)
    						JPI (EQUAL)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_SMBC_1 - addr)
    						JPI (CLIT)
    			data.b $00, $87, $00
L_SMBC_3	JPI (SWAP)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (ANDD)
    						JPI (CLIT)
    			data.b $00, $10, $00
    						JPI (MUL)
    						JPI (OR)
    						JPI (CCOMMA)
    						JPI (CCOMMA)
    						JPI (BRAN)
    						data.b $00
    						data.w (L_SMBC_2 - addr)
L_SMBC_1	JPI (THREE)
    						JPI (ERR)
L_SMBC_2	JPI (SEMIS)
;;
;;    RMB,
;;
_RMBC         	text.7 $84, "RMB,"
    			data.w _SMBC    ; link to SMB,
    			data.w RMBC 	; PFAPTR

RMBC:	DATA.W (RMBC+2)
			PHI
    						JPI (MODE)
    						JPI (AT)
    						JPI (MEM)
    						JPI (TWO)
    						JPI (EQUAL)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_SMBC_1 - addr)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (BRAN)
    						data.b $00
    						data.w (L_SMBC_3 - addr)

_BITSET:		text.7 $86, "BITSET"
				data.w _RMBC				; link to
				data.w BITSET				; PFAPTR

BITSET:	DATA.W (BITSET+2)
			PHI
							JPI (MODE)
							JPI (AT)
							JPI (TWO)
							JPI (EQUAL)
							JPI (ZBRAN)
							data.b $00
							data.w (L_SMBC_1 - addr)
							JPI (CLIT)
				data.b $00, $0f, $00
L_BITSET_1	JPI (SWAP)
    						JPI (CLIT)
    			data.b $00, $07, $00
    						JPI (ANDD)
    						JPI (CLIT)
    			data.b $00, $10, $00
    						JPI (MUL)
    						JPI (OR)
    						JPI (CCOMMA)
    						JPI (SEMIS)
;;
;;    BITCLR
;;
_BITCLR         text.7 $86, "BITCLR"
    			data.w _BITSET    ; link to RMB,
    			data.w BITCLR    ; PFAPTR

BITCLR:	DATA.W (BITCLR+2)
			PHI
    						JPI (MODE)
    						JPI (AT)
    						JPI (TWO)
    						JPI (EQUAL)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_SMBC_1 - addr)
    						JPI (CLIT)
    			data.b $00, $8f, $00
    						JPI (BRAN)
    						data.b $00
    						data.w (L_BITSET_1 - addr)

;;
;;    ADD,
;;
_ADDC_			text.7 $84, "ADD,"
			data.w _BITCLR
			data.w ADDC_    ; PFAPTR

ADDC_:	DATA.W (ADDC_+2)
			PHI
						JPI (MODE)
						JPI (CAT)
						JPI (DUP)
						JPI (ONE)
						JPI (EQUAL)
						JPI (ZBRAN)
						data.b $00
						data.w (.ADD_2 - addr)
						JPI (DROP)
						JPI (CLIT)
			data.b $00, $89, $00
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)
.ADD_2		JPI (DUP)
						JPI (TWO)
						JPI (EQUAL)
						JPI (ZBRAN)
						data.b $00
						data.w (.ADD_3 - addr)
						JPI (DROP)
						JPI (CLIT)
			data.b $00, $64, $00
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)
.ADD_3		JPI (THREE)
						JPI (EQUAL)
						JPI (ZBRAN)
						data.b $00
						data.w (.ADD_ERR - addr)
						JPI (CLIT)
			data.b $00, $74, $00
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)
.ADD_ERR	JPI (THREE)
						JPI (ERR)

;;
;;    STI,
;;
_STIC			text.7 $84, "STI,"
			data.w _ADDC_
			data.w STIC    ; PFAPTR

STIC:	DATA.W (STIC+2)
			PHI
						JPI (CLIT)
			data.b $00, $b2, $00
						JPI (CCOMMA)
						JPI (SWAP)
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    JMPX,
;;
_JMPXC			text.7 $85, "JMPX,"
			data.w _STIC
			data.w JMPXC    ; PFAPTR

JMPXC:	DATA.W (JMPXC+2)
			PHI
						JPI (CLIT)
			data.b $00, $7c, $00
						JPI (CCOMMA)
						JPI (COMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    RBA,
;;
_RBAC			text.7 $84, "RBA,"
			data.w _JMPXC
			data.w RBAC    ; PFAPTR

RBAC:	DATA.W (RBAC+2)
			PHI
						JPI (CLIT)
			data.b $00, $c2, $00
						JPI (CCOMMA)
						JPI (SWAP)
						JPI (COMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    SBA,
;;
_SBAC			text.7 $84, "SBA,"
			data.w _RBAC
			data.w SBAC    ; PFAPTR

SBAC:	DATA.W (SBAC+2)
			PHI
						JPI (CLIT)
			data.b $00, $d2, $00
						JPI (CCOMMA)
						JPI (SWAP)
						JPI (COMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    BAR,
;;
_BARC			text.7 $84, "BAR,"
			data.w _SBAC
			data.w BARC    ; PFAPTR

BARC:	DATA.W (BARC+2)
			PHI
						JPI (CLIT)
			data.b $00, $e2, $00
						JPI (CCOMMA)
						JPI (ROT)
						JPI (ROT)
						JPI (ROT)
						JPI (SWAP)
						JPI (ROT)
						JPI (COMMA)
						JPI (SWAP)
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

;;
;;    BAS,
;;
_BASC			text.7 $84, "BAS,"
			data.w _BARC
			data.w BASC    ; PFAPTR

BASC:	DATA.W (BASC+2)
			PHI
						JPI (CLIT)
			data.b $00, $f2, $00
						JPI (CCOMMA)
						JPI (ROT)
						JPI (ROT)
						JPI (ROT)
						JPI (SWAP)
						JPI (ROT)
						JPI (COMMA)
						JPI (SWAP)
						JPI (CCOMMA)
						JPI (CCOMMA)
						JPI (MEM)
						JPI (SEMIS)

_BEGINC:		text.7 $86,"BEGIN,"
				data.w _BASC
				data.w BEGINC

BEGINC:	DATA.W (BEGINC+2)
			PHI
							JPI (HERE)
							JPI (ONE)
							JPI (SEMIS)

;;
;;    UNTIL,
;;
_UNTILC        	text.7 $86, "UNTIL,"
                data.w _BEGINC    ; link to BEGIN
                data.w UNTILC    ; PFAPTR
;;
;;
;;
UNTILC:	DATA.W (UNTILC+2)
			PHI
    						JPI (GTR)
    						JPI (ONE)
    						JPI (QPAIRS)
    						JPI (RFROM)
    						JPI (CCOMMA)
    						JPI (HERE)
    						JPI (ONEPLUS)
    						JPI (SUB)
    						JPI (CCOMMA)
    						JPI (SEMIS)
;;
;;    WHILE,
;;
_WHILEC         text.7 $86, "WHILE,"
                data.w _UNTILC    ; link to UNTIL,
                data.w WHILEC    ; PFAPTR
;;
;;
;;
WHILEC:	DATA.W (WHILEC+2)
			PHI
    						JPI (CCOMMA)
    						JPI (HERE)
    						JPI (ZERO)
    						JPI (CCOMMA)
    						JPI (THREE)
    						JPI (SEMIS)
;;
;;    AGAIN,
;;
_AGAINC         text.7 $86, "AGAIN,"
    			data.w _WHILEC    ; link to WHILE,
    			data.w AGAINC    ; PFAPTR

AGAINC:	DATA.W (AGAINC+2)
			PHI
    						JPI (ONE)
    						JPI (QPAIRS)
    						JPI (JMPC)
    						JPI (SEMIS)
;;
;;    REPEAT,
;;
_REPEATC        text.7 $87, "REPEAT,"
    			data.w _AGAINC    ; link to AGAIN,
    			data.w REPEATC    ; PFAPTR

REPEATC:	DATA.W (REPEATC+2)
			PHI
    						JPI (THREE)
    						JPI (QPAIRS)
    						JPI (GTR)
    						JPI (AGAINC)
    						JPI (RFROM)
    						JPI (HERE)
    						JPI (OVER)
    						JPI (ONEPLUS)
    						JPI (SUB)
    						JPI (SWAP)
    						JPI (CSTOR)
    						JPI (SEMIS)
;;
;;    IF,
;;
_IFC            text.7 $83, "IF,"
    			data.w _REPEATC    ; link to REPEAT,
    			data.w IFC    ; PFAPTR

IFC:	DATA.W (IFC+2)
			PHI
    						JPI (CCOMMA)
    						JPI (HERE)
    						JPI (ZERO)
    						JPI (CCOMMA)
    						JPI (TWO)
    						JPI (SEMIS)
;;
;;    ENDIF,
;;
_ENDIFC         text.7 $86, "ENDIF,"
    			data.w _IFC    ; link to IF,
    			data.w ENDIFC    ; PFAPTR
;;
;;
;;
ENDIFC:	DATA.W (ENDIFC+2)
			PHI
    						JPI (TWO)
    						JPI (QPAIRS)
    						JPI (HERE)
    						JPI (OVER)
    						JPI (CAT)
    						JPI (ZBRAN)
    						data.b $00
    						data.w (L_ENDIFC_1 - addr)
    						JPI (SWAP)
    						JPI (STORE)
    						JPI (SEMIS)
L_ENDIFC_1	JPI (OVER)
    						JPI (ONEPLUS)
    						JPI (SUB)
    						JPI (SWAP)
    						JPI (CSTOR)
    						JPI (SEMIS)
;;
;;    THEN,
;;
_THENC          text.7 $85, "THEN,"
                data.w _ENDIFC    ; link to ENDIF,
                data.w THENC     ; PFAPTR
;;
;;
;;
THENC:	DATA.W (THENC+2)
			PHI
    						JPI (ENDIFC)
    						JPI (SEMIS)
;;
;;    ELSE,
;;
_ELSEC          text.7 $85, "ELSE,"
    			data.w _THENC      ; link to THEN,
    			data.w ELSEC    ; PFAPTR

ELSEC:	DATA.W (ELSEC+2)
			PHI
    						JPI (TWO)
    						JPI (QPAIRS)
    						JPI (HERE)
    						JPI (ONEPLUS)
    						JPI (ONE)
    						JPI (JMPC)
    						JPI (SWAP)
    						JPI (HERE)
    						JPI (OVER)
    						JPI (ONEPLUS)
    						JPI (SUB)
    						JPI (SWAP)
    						JPI (CSTOR)
    						JPI (TWO)
    						JPI (SEMIS)
;;
;;    NOT
;;
_NOT            text.7 $83, "NOT"
    			data.w _ELSEC    ; link to ELSE,
    			data.w NOT     ; PFAPTR

NOT:	DATA.W (NOT+2)
			PHI
    						JPI (BL)
    						JPI (XOR)
    						JPI (SEMIS)
;;
;;    CS
;;
_CS             text.7 $82, "CS"
    			data.w _NOT    ; link to NOT
    			data.w CS    ; PFAPTR

CS:	DATA.W (CS+2)
			JSR DOCON	
    			data.w $0090
;;
;;    VS
;;
_VS             text.7 $82, "VS"
    			data.w _CS    ; link to CS
    			data.w VS    ; PFAPTR

VS:	DATA.W (VS+2)
			JSR DOCON	
    			data.w $0050
;;
;;    0=
;;
_ZEQ            text.7 $82, "0="
    			data.w _VS    ; link to VS
    			data.w ZEQ    ; PFAPTR

ZEQ:	DATA.W (ZEQ+2)
			JSR DOCON	
    			data.w $00d0
;;
;;    0<
;;
_ZLESS          text.7 $82, "0<"
    			data.w _ZEQ    ; link to 0=
    			data.w ZLESS    ; PFAPTR

ZLESS:	DATA.W (ZLESS+2)
			JSR DOCON	
    			data.w $0010

;;
;;    END-CODE
;;
_ENDCODE        text.7 $c8, "END-CODE"
    			data.w _ZLESS    ; link to 0<
    			data.w ENDCODE    ; PFAPTR

ENDCODE:	DATA.W (ENDCODE+2)
			PHI
    						JPI (CURRENT)
    						JPI (AT)
    						JPI (CONTEXT)
    						JPI (STORE)
    						JPI (QEXEC)
    						JPI (QCSP)
    						JPI (SMUDGE)
    						JPI (SEMIS)
;;
;;    TASK
;;
_TASK           text.7 $84, "TASK"
    			data.w _ADMP    ; link to END-CODE
    			data.w TASK    ; PFAPTR

TASK:	DATA.W (TASK+2)
			PHI
    						JPI (SEMIS)

;;
;;    MOVETO
;;
_MOVETO         text.7 $86, "MOVETO"
    			data.w _TASK    ; link to TASK
    			data.w MOVETO    ; PFAPTR
;;
;;    LINETO
;;
_LINETO         text.7 $86, "LINETO"
    			data.w _MOVETO    ; link to MOVETO
    			data.w LINETO    ; PFAPTR
;;
;;    PIXEL ( x y c -- ) — set or clear a single LCD pixel
;;      x=0-239, y=0-63, c=0 clear / c=1 set
;;
_PIXEL          text.7 $85, "PIXEL"
    			data.w _LINETO    ; link to LINETO
    			data.w PIXEL      ; PFAPTR
;;
;;    FILLRECT ( x y w h c -- ) — fill an LCD rectangle
;;      x=0-239, y=0-159, w=width, h=height, c=0 clear / c=1 set
;;
_FILLRECT       text.7 $88, "FILLRECT"
    			data.w _PIXEL     ; link to PIXEL
    			data.w GFXFILL    ; PFAPTR
;;
;;    CONTRAST ( n -- ) — set LCD contrast
;;
_CONTRAST       text.7 $88, "CONTRAST"
    			data.w _FILLRECT  ; link to FILLRECT
    			data.w CONTRAST   ; PFAPTR

PADDINGD:       data.b $ff, $ff
                data.b $ff

