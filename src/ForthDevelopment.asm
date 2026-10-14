
	section "kernel"
	
	Include "ForthKernel.asm"
	message org
	section "development"
	
    org := $c000

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
				data.w $0140			; B/SIDE
				data.w BUF_FIRST		; FIRST
				data.w BUF_LIMIT		; LIMIT
				data.w $0000			; OFFSET
				data.w $001f			; WIDTH
				data.w $0000			; WARNING
				data.w DICT_BASE+$04	; FENCE
				data.w DICT_BASE+$11	; DP
				data.w $0000
				data.w $0000
				data.w USER_BASE+$3c	; VOC-LINK
				data.w $a081
				data.w DICT_BASE+$04
				data.w $0000
				data.w $a081
				data.w _ENDCODE
				data.w USER_BASE+$36
				data.w ABORT
	
;;
;;    LIT
;;
_LIT            text.7 $83, "LIT"
    			data.w 0            ; link to previous. Last link marked by zero.
    			data.w LIT+2        ; PFAPTR
;;
;;    CLIT
;;
_CLIT          	text.7 $84, "CLIT"
    			data.w _LIT         ; link to LIT
    			data.w CLIT+2       ; PFAPTR
;;
;;    EXECUTE
;;
_EXECUTE       	text.7 $87, "EXECUTE"
    			data.w _CLIT    	; link to CLIT
    			data.w EXECUTE+2    ; PFAPTR
;;
;;    BRANCH
;;
_BRANCH         text.7 $86, "BRANCH"
    			data.w _EXECUTE     ; link to EXECUTE
    			data.w BRAN+2       ; PFAPTR
;;
;;    0BRANCH
;;
_ZBRANCH        text.7 $87, "0BRANCH"
                data.w _BRANCH      ; link to BRANCH
                data.w ZBRAN+2 	    ; PFAPTR

;;
;;    (LOOP)
;;
_PLOOP          text.7 $86, "(LOOP)"
    			data.w _ZBRANCH    ; link to 0BRANCH
    			data.w LOOP+2      ; PFAPTR

;;
;;    (+LOOP)
;;
_PPLOOP         text.7 $87, "(+LOOP)"
                data.w _PLOOP    ; link to (LOOP)
                data.w PLOOP+2    ; PFAPTR

;;
;;    (DO)
;;
_PDO            text.7 $84, "(DO)"
                data.w _PPLOOP    ; link to (+LOOP)
                data.w DO+2    ; PFAPTR

;;
;;    I
;;
_I             	text.7 $81, "I"
                data.w _PDO    ; link to (DO)
                data.w _DIGIT    ; PFAPTR
I:				data.w R+2

;;
;;    DIGIT
;;
_DIGIT       	text.7 $85, "DIGIT"
                data.w _I    ; link to I
                data.w DIGIT+2    ; PFAPTR
;;
;;    (FIND)
;;
_PFIND          text.7 $86, "(FIND)"
                data.w _DIGIT    ; link to DIGIT
                data.w FIND+2    ; PFAPTR
;;
;;    ENCLOSE
;;
_ENCLOSE        text.7 $87, "ENCLOSE"
                data.w _PFIND    ; link to (FIND)
                data.w ENCLOSE+2    ; PFAPTR
;;
;;    EMIT
;;
_EMIT           text.7 $84, "EMIT"
                data.w _ENCLOSE    ; link to ENCLOSE
                data.w EMIT+2    ; PFAPTR
;;
;;    KEY
;;
_KEY            text.7 $83, "KEY"
                data.w _EMIT    ; link to EMIT
                data.w KEY+2    ; PFAPTR
;;
;;    ?TERMINAL
;;
_QTERMINAL      text.7 $89, "?TERMINAL"
                data.w _KEY    ; link to KEY
                data.w QTERM+2    ; PFAPTR
;;
;;    CR
;;
_CR             text.7 $82, "CR"
                data.w _QTERMINAL    ; link to ?TERMINAL
                data.w CR+2    ; PFAPTR
;;
;;    XON
;;
_XON            text.7 $83, "XON"
                data.w _CR    ; link to CR
                data.w XON+2    ; PFAPTR
;;
;;
;;
XON:  	      	data.w DOCOL
    			data.w PDOTQ
    			data.b $01, ""
    			data.w SEMIS
;;
;;    XOFF
;;
_XOFF           text.7 $84, "XOFF"
                data.w _XON    ; link to XON
                data.w XOFF+2    ; PFAPTR
;;
;;
;;
XOFF:         	data.w DOCOL
                data.w PDOTQ
                data.b $01, ""
                data.w SEMIS
;;
;;    SOURCE
;;
_SOURCE         text.7 $86, "SOURCE"
                data.w _XOFF    ; link to XOFF
                data.w SOURCE+2    ; PFAPTR
;;
;;
;;
SOURCE:         data.w DOCOL
    			data.w ZERO
    			data.w BLK
    			data.w STORE
    			data.w LBRAC
    			data.w RPSTO
    			data.w XON
    			data.w ZERO
    			data.w IN
    			data.w STORE
    			data.w TIB
    			data.w AT
    			data.w CLIT
    			data.b $50
    			data.w BOUNDS
    			data.w DO
    			data.w KEY
    			data.w DUP
    			data.w CLIT
    			data.b $0d
    			data.w EQUAL
    			data.w ZBRAN
    			data.w $0008
    			data.w DROP
    			data.w ZERO
    			data.w LEAVE
    			data.w I
    			data.w CSTOR
    			data.w LOOP
    			data.w $ffe7
    			data.w XOFF
    			data.w INTERPRET
    			data.w BRAN
    			data.w $ffca
;;
;;    FINIS
;;
_FINIS          text.7 $85, "FINIS"
                data.w _SOURCE    ; link to SOURCE
                data.w FINIS+2    ; PFAPTR
;;
;;
;;
FINIS:         	data.w DOCOL
    			data.w CR
    			data.w PDOTQ
    			data.b $02, "OK"
    			data.w BRAN
L225   			data.w L1684-L225 
;;
;;    CMOVE
;;
_CMOVE          text.7 $85, "CMOVE"
                data.w _FINIS    ; link to FINIS
    			data.w CMOVE+2    ; PFAPTR
;;
;;    U*
;;
_UMUL           text.7 $82, "U*"
                data.w _CMOVE    ; link to CMOVE
                data.w USTAR+2    ; PFAPTR
;;
;;    U/
;;
_UDIV           text.7 $82, "U/"
                data.w _UMUL    ; link to U*
                data.w USLAS+2    ; PFAPTR
;;
;;    AND
;;
_AND            text.7 $83, "AND"
                data.w _UDIV    ; link to U/
                data.w ANDD+2    ; PFAPTR
;;
;;    OR
;;
_OR             text.7 $82, "OR"
                data.w _AND    ; link to AND
                data.w OR+2    ; PFAPTR
;;
;;    XOR
;;
_XOR            text.7 $83, "XOR"
                data.w _OR    ; link to OR
                data.w XOR+2    ; PFAPTR
;;
;;    SP@
;;
_SPAT           text.7 $83, "SP@"
                data.w _XOR    ; link to XOR
                data.w SPAT+2    ; PFAPTR
;;
;;    SP!
;;
_SPSTOR         text.7 $83, "SP!"
                data.w _SPAT    ; link to SP@
                data.w SPSTO+2    ; PFAPTR
;;
;;    RP!
;;
_RPSTOR         text.7 $83, "RP!"
                data.w _SPSTOR    ; link to SP!
                data.w RPSTO+2    ; PFAPTR
;;
;;    RP@
;;
_RPAT           text.7 $83, "RP@"
                data.w _RPSTOR    ; link to RP!
                data.w PUSHS+2    ; PFAPTR
;;
;;    ;S
;;
_SEMIS          text.7 $82, ";S"
                data.w _RPAT    ; link to RP@
                data.w SEMIS+2    ; PFAPTR
;;
;;    LEAVE
;;
_LEAVE          text.7 $85, "LEAVE"
                data.w _SEMIS    ; link to ;S
                data.w LEAVE+2    ; PFAPTR
;;
;;    >R
;;
_GTR            text.7 $82, ">R"
                data.w _LEAVE    ; link to LEAVE
                data.w GTR+2    ; PFAPTR
;;
;;    R>
;;
_RGT            text.7 $82, "R>"
                data.w _GTR    ; link to >R
                data.w RFROM+2    ; PFAPTR
;;
;;    R
;;
_R              text.7 $81, "R"
                data.w _RGT    ; link to R>
                data.w R+2    ; PFAPTR
;;
;;    0=
;;
_ZEQ            text.7 $82, "0="
                data.w _R    ; link to R
                data.w ZEQ+2    ; PFAPTR
;;
;;    NOT
;;
_NOT            text.7 $83, "NOT"
                data.w _ZEQ    ; link to 0=
                data.w _ZLT    ; PFAPTR
                data.w ZEQ+2
;;
;;    0<
;;
_ZLT            text.7 $82, "0<"
                data.w _NOT    ; link to NOT
                data.w ZLT+2    ; PFAPTR
;;
;;    +
;;
_PLUS           text.7 $81, "+"
                data.w _ZLT    ; link to 0<
                data.w PLUS+2    ; PFAPTR
;;
;;    D+
;;
_DPLUS          text.7 $82, "D+"
                data.w _PLUS    ; link to +
                data.w DPLUS+2    ; PFAPTR
;;
;;    NEGATE
;;
_NEGATE         text.7 $86, "NEGATE"
                data.w _DPLUS    ; link to D+
                data.w NEGATE+2    ; PFAPTR
;;
;;    DNEGATE
;;
_DNEGATE        text.7 $87, "DNEGATE"
                data.w _NEGATE    ; link to NEGATE
                data.w DNEGATE+2    ; PFAPTR
;;
;;    OVER
;;
_OVER           text.7 $84, "OVER"
                data.w _DNEGATE    ; link to DNEGATE
                data.w OVER+2    ; PFAPTR
;;
;;    DROP
;;
_DROP           text.7 $84, "DROP"
                data.w _OVER    ; link to OVER
                data.w TWODROP    ; PFAPTR
;;
;;    2DROP
;;
_TWODROP        text.7 $85, "2DROP"
                data.w _DROP    ; link to DROP
                data.w SWAP    ; PFAPTR
;;
;;    SWAP
;;
_SWAP           text.7 $84, "SWAP"
                data.w _TWODROP    ; link to 2DROP
                data.w SWAP+2    ; PFAPTR
;;
;;    DUP
;;
_DUP            text.7 $83, "DUP"
                data.w _SWAP    ; link to SWAP
                data.w DUP+2    ; PFAPTR
;;
;;    2DUP
;;
_TWODUP         text.7 $84, "2DUP"
                data.w _DUP    ; link to DUP
                data.w TWODUP+2    ; PFAPTR
;;
;;    BOUNDS
;;
_BOUNDS         text.7 $86, "BOUNDS"
                data.w _TWODUP    ; link to 2DUP
                data.w BOUNDS+2    ; PFAPTR
;;
;;    +!
;;
_PLUSSTOR       text.7 $82, "+!"
                data.w _BOUNDS    ; link to BOUNDS
                data.w PSTORE+2    ; PFAPTR
;;
;;    TOGGLE
;;
_TOGGLE         text.7 $86, "TOGGLE"
                data.w _PLUSSTOR    ; link to +!
                data.w TOGGL+2    ; PFAPTR
;;
;;    @
;;
_AT             text.7 $81, "@"
                data.w _TOGGLE    ; link to TOGGLE
                data.w AT+2    ; PFAPTR
;;
;;    C@
;;
_CAT            text.7 $82, "C@"
                data.w _AT    ; link to @
                data.w CAT+2    ; PFAPTR
;;
;;    !
;;
_STOR           text.7 $81, "!"
                data.w _CAT    ; link to C@
                data.w STORE+2    ; PFAPTR
;;
;;    C!
;;
_CSTOR          text.7 $82, "C!"
                data.w _STOR    ; link to !
                data.w CSTOR+2    ; PFAPTR
;;
;; ToDo: Not sure what this one is?
;;
DCSTOR:         data.w DOCOL
                data.w LATEST
                data.w PFAPTR
                data.w CFA
                data.w STORE
                data.w RFROM
                data.w DROP
                data.w SEMIS
;;
;;    :
;;
_COLON          text.7 $c1, ":"
                data.w _CSTOR    ; link to C!
                data.w COLON+2    ; PFAPTR
;;
;;
;;
COLON:          data.w DOCOL
                data.w QEXEC
                data.w STORCSP
                data.w CURRENT
                data.w AT
                data.w CONTEXT
                data.w STORE
                data.w CREATE
                data.w RBRAC
                data.w LIT
                data.w DOCOL
                data.w DCSTOR

;;
;;    ;
;;
_SEMI           text.7 $c1, ";"
                data.w _COLON    ; link to :
                data.w DSEMI+2    ; PFAPTR

DSEMI:			data.w DOCOL
                data.w QCSP
                data.w COMPILE
                data.w SEMIS
                data.w SMUDGE
                data.w LBRAC
                data.w SEMIS

;;
;;    CONSTANT
;;
_CONSTANT       text.7 $88, "CONSTANT"
                data.w _SEMI    ; link to ;
                data.w CONSTANT+2    ; PFAPTR
;;
;;
;;
CONSTANT:       data.w DOCOL
                data.w CREATE
                data.w SMUDGE
                data.w COMMA
                data.w LIT
                data.w DOCON
                data.w DCSTOR
;;
;;    VARIABLE
;;
_VARIABLE       text.7 $88, "VARIABLE"
                data.w _CONSTANT    ; link to CONSTANT
                data.w VARIABLE+2    ; PFAPTR
;;
;;
;;
VARIABLE:       data.w DOCOL
                data.w CONSTANT
                data.w LIT
                data.w DOVAR
                data.w DCSTOR
;;
;;    CODE
;;
_CODE           text.7 $c4, "CODE"
                data.w _VARIABLE    ; link to VARIABLE
                data.w CODE+2    ; PFAPTR
;;
;;
;;
CODE:           data.w DOCOL
                data.w QEXEC
                data.w CREATE
                data.w ASSEMBLER
                data.w MEM
                data.w STORCSP
    			data.w SEMIS

;;
;;    USER
;;
_USER           text.7 $84, "USER"
                data.w _CODE    ; link to CODE
                data.w USER+2    ; PFAPTR
;;
;;
;;
USER:           data.w DOCOL
                data.w CREATE
                data.w SMUDGE
                data.w CCOMMA
                data.w LIT
                data.w DOUSE
                data.w DCSTOR

;;
;;    0
;;
_ZERO           text.7 $81, "0"
                data.w _USER    ; link to USER
                data.w ZERO+2    ; PFAPTR
;;
;;    1
;;
_ONE            text.7 $81, "1"
                data.w _ZERO    ; link to 0
                data.w ONE+2    ; PFAPTR
;;
;;    2
;;
_TWO            text.7 $81, "2"
                data.w _ONE    ; link to 1
                data.w TWO+2    ; PFAPTR
;;
;;    3
;;
_THREE          text.7 $81, "3"
                data.w _TWO    ; link to 2
                data.w THREE+2    ; PFAPTR
;;
;;    4
;;
_FOUR           text.7 $81, "4"
                data.w _THREE    ; link to 3
                data.w FOUR+2    ; PFAPTR
;;
;;    BL
;;
_BL             text.7 $82, "BL"
                data.w _FOUR    ; link to 4
                data.w BL+2    ; PFAPTR
;;
;;    TIB
;;
_TIB            text.7 $83, "TIB"
                data.w _BL    ; link to BL
                data.w TIB+2    ; PFAPTR
;;
;;    S0
;;
_S0             text.7 $82, "S0"
                data.w _TIB    ; link to TIB
                data.w SZ+2    ; PFAPTR
;;
;;    R0
;;
_R0             text.7 $82, "R0"
                data.w _S0    ; link to S0
                data.w RZ+2    ; PFAPTR
;;
;;    UC/L
;;
_UCL            text.7 $84, "UC/L"
                data.w _R0    ; link to R0
                data.w UCL+2    ; PFAPTR
;;
;;    UPAD
;;
_UPAD           text.7 $84, "UPAD"
                data.w _UCL    ; link to UC/L
                data.w UPAD+2    ; PFAPTR
;;
;;    UR/W
;;
_URW            text.7 $84, "UR/W"
                data.w _UPAD    ; link to UPAD
                data.w URW+2    ; PFAPTR
;;
;;    BASE
;;
_BASE           text.7 $84, "BASE"
                data.w _URW    ; link to UR/W
                data.w BASE+2    ; PFAPTR
;;
;;    CLD/WRM
;;
_CLDWRM         text.7 $87, "CLD/WRM"
                data.w _BASE    ; link to BASE
                data.w CLDWRM+2    ; PFAPTR
;;
;;    IN
;;
_IN             text.7 $82, "IN"
                data.w _CLDWRM    ; link to CLD/WRM
                data.w IN+2    ; PFAPTR
;;
;;    DPL
;;
_DPL            text.7 $83, "DPL"
                data.w _IN    ; link to IN
                data.w DPL+2    ; PFAPTR
;;
;;    HLD
;;
_HLD            text.7 $83, "HLD"
                data.w _DPL    ; link to DPL
                data.w HLD+2    ; PFAPTR
;;
;;    DISKNO
;;
_DISKNO         text.7 $86, "DISKNO"
                data.w _HLD    ; link to HLD
                data.w DDISKNO+2    ; PFAPTR
;;
;;
;;
DDISKNO:        data.w DOUSE
                data.b $16
;;
;;    CYLINDER
;;
_CYLINDER       text.7 $88, "CYLINDER"
                data.w _DISKNO    ; link to DISKNO
                data.w DCYLINDER+2    ; PFAPTR
;;
;;
;;
DCYLINDER:      data.w DOUSE
                data.b $18
;;
;;    B/SIDE
;;
_BSIDE          text.7 $86, "B/SIDE"
                data.w _CYLINDER    ; link to CYLINDER
                data.w BSIDE+2    ; PFAPTR
;;
;;
;;
BSIDE:          data.w DOUSE
                data.b $1c
;;
;;    UFIRST
;;
_UFIRST         text.7 $86, "UFIRST"
                data.w _BSIDE    ; link to B/SIDE
                data.w UFIRST+2    ; PFAPTR
;;
;;
;;
UFIRST:         data.w DOUSE
                data.b $1e
;;
;;    ULIMIT
;;
_ULIMIT         text.7 $86, "ULIMIT"
                data.w _UFIRST    ; link to UFIRST
                data.w ULIMIT+2    ; PFAPTR
;;
;;
;;
ULIMIT:         data.w DOUSE
                data.b $20
;;
;;    OFFSET
;;
_OFFSET         text.7 $86, "OFFSET"
                data.w _ULIMIT    ; link to ULIMIT
                data.w OFFSET+2    ; PFAPTR
;;
;;
;;
OFFSET:         data.w DOUSE
                data.b $22
;;
;;    WIDTH
;;
_WIDTH          text.7 $85, "WIDTH"
                data.w _OFFSET    ; link to OFFSET
                data.w WIDTH+2    ; PFAPTR
;;
;;
;;
WIDTH:          data.w DOUSE
                data.b $24
;;
;;    WARNING
;;
_WARNING        text.7 $87, "WARNING"
                data.w _WIDTH    ; link to WIDTH
                data.w WARNING+2    ; PFAPTR
;;
;;
;;
WARNING:        data.w DOUSE
                data.b $26
;;
;;    FENCE
;;
_FENCE          text.7 $85, "FENCE"
                data.w _WARNING    ; link to WARNING
                data.w FENCE+2    ; PFAPTR
;;
;;
;;
FENCE:          data.w DOUSE
                data.b $28
;;
;;    DP
;;
_DP             text.7 $82, "DP"
                data.w _FENCE    ; link to FENCE
                data.w DP+2    ; PFAPTR
;;
;;
;;
DP:         	data.w DOUSE
                data.b $2a
;;
;;    HEADERLESS
;;
_HEADERLESS     text.7 $8a, "HEADERLESS"
                data.w _DP    ; link to DP
                data.w HEADERLESS+2    ; PFAPTR
;;
;;
;;
HEADERLESS:     data.w DOUSE
                data.b $2e
;;
;;    VOC-LINK
;;
_VOCL           text.7 $88, "VOC-LINK"
                data.w _HEADERLESS    ; link to HEADERLESS
                data.w VOCL+2    ; (Doesn't seem right)
;;
;;
;;
VOCL:         	data.w DOUSE
    			data.b $30
VOCL4:			data.w DOUSE
				data.b $34
VOCL8:			data.w DOUSE
				data.b $3a

;;
;;    UABORT
;;
_UABORT         text.7 $86, "UABORT"
    			data.w _VOCL    ; link to VOC-LINK
    			data.w UABORT+2    ; PFAPTR
;;
;;
;;
UABORT:         data.w DOUSE
    			data.b $3e
;;
;;    USE
;;
_USE            text.7 $83, "USE"
    			data.w _UABORT    ; link to UABORT
    			data.w USE+2    ; PFAPTR

USE:         	data.w DOUSE
    			data.b $40

;;
;;    PREV
;;
_PREV           text.7 $84, "PREV"
                data.w _USE    ; link to USE
                data.w PREV+2    ; PFAPTR

PREV:         	data.w DOUSE
    			data.b $42

;;
;;    BLK
;;
_BLK            text.7 $83, "BLK"
    			data.w _PREV    ; link to PREV
    			data.w BLK+2    ; PFAPTR

BLK:         	data.w DOUSE
    			data.b $44

;;
;;    SCR
;;
_SCR            text.7 $83, "SCR"
    			data.w _BLK    ; link to BLK
    			data.w SCR+2    ; PFAPTR

SCR:         	data.w DOUSE
                data.b $46

;;
;;    CONTEXT
;;
_CONTEXT        text.7 $87, "CONTEXT"
    			data.w _SCR    ; link to SCR
    			data.w CONTEXT+2    ; PFAPTR

CONTEXT:        data.w DOUSE
    			data.b $48

;;
;;    CURRENT
;;
_CURRENT        text.7 $87, "CURRENT"
                data.w _CONTEXT    ; link to CONTEXT
    			data.w CURRENT+2    ; PFAPTR

CURRENT:        data.w DOUSE
    			data.b $4a

;;
;;    STATE
;;
_STATE          text.7 $85, "STATE"
    			data.w _CURRENT    ; link to CURRENT
    			data.w STATE+2    ; PFAPTR

STATE:         	data.w DOUSE
                data.b $4c

;;
;;    CSP
;;
_CSP            text.7 $83, "CSP"
                data.w _STATE    ; link to STATE
                data.w CSP+2    ; PFAPTR

CSP:         	data.w DOUSE
    			data.b $4e
;;
;;    MODE
;;
_MODE           text.7 $84, "MODE"
    			data.w _CSP    ; link to CSP
    			data.w MODE+2    ; PFAPTR

MODE:         	data.w DOUSE
    			data.b N-1
;;
;;    KHZ
;;
_KHZ            text.7 $83, "KHZ"
    			data.w _MODE    ; link to MODE
    			data.w KHZ+2    ; PFAPTR

KHZ:         	data.w DOUSE
    			data.b N+1
;;
;;    C/L
;;
DCL             text.7 $83, "C/L"
    			data.w _KHZ    ; link to KHZ
    			data.w CL+2    ; PFAPTR
;;
;;    FIRST
;;
_FIRST          text.7 $85, "FIRST"
    			data.w DCL    ; link to C/L
    			data.w FIRST+2    ; PFAPTR

FIRST:         	data.w DOCOL
    			data.w UFIRST
    			data.w AT
    			data.w SEMIS
;;
;;    LIMIT
;;
_LIMIT          text.7 $85, "LIMIT"
    			data.w _FIRST    ; link to FIRST
    			data.w LIMIT+2    ; PFAPTR

LIMIT:         	data.w DOCOL
    			data.w ULIMIT
    			data.w AT
    			data.w SEMIS
;;
;;    PAD
;;
_PAD            text.7 $83, "PAD"
    			data.w _LIMIT    ; link to LIMIT
    			data.w PAD+2    ; PFAPTR
;;
;;    1+
;;
_ONEPLUS        text.7 $82, "1+"
    			data.w _PAD    ; link to PAD
    			data.w ONEPLUS+2    ; PFAPTR
;;
;;    2+
;;
_2PLUS          text.7 $82, "2+"
    			data.w _ONEPLUS    ; link to 1+
    			data.w TWOPLUS+2    ; PFAPTR
;;
;;    1-
;;
_1SUB           text.7 $82, "1-"
                data.w _2PLUS    ; link to 2+
                data.w ONEMINUS+2    ; PFAPTR
;;
;;    2-
;;
_2SUB           text.7 $82, "2-"
                data.w _1SUB    ; link to 1-
                data.w TWOMINUS+2    ; PFAPTR
;;
;;    DP/
;;
_DPDIV          text.7 $83, "DP/"
                data.w _2SUB    ; link to 2-
                data.w DPDIV+2    ; PFAPTR

DPDIV:         	data.w DOCOL
    			data.w DP
    			data.w HEADERLESS
    			data.w AT
    			data.w ZBRAN
    			data.w $0004
    			data.w TWOPLUS
    			data.w SEMIS
;;
;;    HERE/
;;
_HEREDIV        text.7 $85, "HERE/"
    			data.w _DPDIV    ; link to DP/
    			data.w HEREDIV+2    ; PFAPTR

HEREDIV:        data.w DOCOL
    			data.w DPDIV
    			data.w AT
    			data.w SEMIS
;;
;;    ALLOT/
;;
_ALLOTDIV       text.7 $86, "ALLOT/"
    			data.w _HEREDIV    ; link to HERE/
    			data.w ALLOTDIV+2    ; PFAPTR

ALLOTDIV:       data.w DOCOL
    			data.w DPDIV
    			data.w PSTORE
    			data.w SEMIS
;;
;;    ,/
;;
_COMMADIV       text.7 $82, ",/"
    			data.w _ALLOTDIV    ; link to ALLOT/
    			data.w COMMADIV+2    ; PFAPTR

COMMADIV:       data.w DOCOL
    			data.w HEREDIV
    			data.w STORE
    			data.w TWO
    			data.w ALLOTDIV
    			data.w SEMIS
;;
;;    HERE
;;
_HERE           text.7 $84, "HERE"
                data.w _COMMADIV    ; link to ,/
                data.w HERE+2    ; PFAPTR

HERE:         	data.w DOCOL
    			data.w DP
    			data.w AT
    			data.w SEMIS
;;
;;    ALLOT
;;
_ALLOT          text.7 $85, "ALLOT"
    			data.w _HERE    ; link to HERE
                data.w ALLOT+2    ; PFAPTR

ALLOT:         	data.w DOCOL
    			data.w DP
    			data.w PSTORE
    			data.w SEMIS
;;
;;    ,
;;
_COMMA          text.7 $81, ","
    			data.w _ALLOT    ; link to ALLOT
    			data.w COMMA+2    ; PFAPTR

COMMA:         	data.w DOCOL
    			data.w HERE
    			data.w STORE
    			data.w TWO
    			data.w ALLOT
    			data.w SEMIS
;;
;;    C,
;;
_CCOMMA         text.7 $82, "C,"
    			data.w _COMMA    ; link to ,
    			data.w CCOMMA+2    ; PFAPTR

CCOMMA:         data.w DOCOL
    			data.w HERE
    			data.w CSTOR
    			data.w ONE
    			data.w ALLOT
    			data.w SEMIS
;;
;;    -
;;
_SUB            text.7 $81, "-"
    			data.w _CCOMMA    ; link to C,
    			data.w SUB+2    ; PFAPTR
;;
;;    =
;;
_EQ             text.7 $81, "="
    			data.w _SUB    ; link to -
    			data.w EQUAL+2    ; PFAPTR
;;
;;    U<
;;
_ULT           	text.7 $82, "U<"
    			data.w _EQ    ; link to =
    			data.w ULESS+2    ; PFAPTR
;;
;;    <
;;
_LT             text.7 $81, "<"
    			data.w _ULT    ; link to U<
    			data.w LESS+2    ; PFAPTR
;;
;;    >
;;
_GT             text.7 $81, ">"
    			data.w _LT    ; link to <
    			data.w GT+2    ; PFAPTR
;;
;;    ROT
;;
_ROT            text.7 $83, "ROT"
    			data.w _GT    ; link to >
    			data.w ROT+2    ; PFAPTR
;;
;;    PICK
;;
_PICK           text.7 $84, "PICK"
    			data.w _ROT    ; link to ROT
    			data.w PICK+2    ; PFAPTR
;;
;;    SPACE
;;
_SPACE          text.7 $85, "SPACE"
    			data.w _PICK    ; link to PICK
    			data.w SPACE+2    ; PFAPTR
;;
;;    -DUP
;;
_SUBDUP         text.7 $84, "-DUP"
    			data.w _SPACE    ; link to SPACE
    			data.w DDUP+2    ; PFAPTR
;;
;;    TRAVERSE
;;
_TRAVERSE       text.7 $88, "TRAVERSE"
    			data.w _SUBDUP    ; link to -DUP
    			data.w TRAVERSE+2    ; PFAPTR

TRAVERSE:       data.w DOCOL
    			data.w SWAP
    			data.w OVER
    			data.w PLUS
    			data.w CLIT
    			data.b $7f
    			data.w OVER
    			data.w CAT
    			data.w LESS
    			data.w ZBRAN
    			data.w $fff1
    			data.w SWAP
    			data.w DROP
    			data.w SEMIS
;;
;;    LATEST
;;
_LATEST         text.7 $86, "LATEST"
    			data.w _TRAVERSE    ; link to TRAVERSE
    			data.w LATEST+2    ; PFAPTR

LATEST:         data.w DOCOL
    			data.w CURRENT
    			data.w AT
    			data.w AT
    			data.w SEMIS
;;
;;    LFA
;;
_LFA            text.7 $83, "LFA"
    			data.w _LATEST    ; link to LATEST
    			data.w _CFA    ; PFAPTR

LFA:         	data.w TWOMINUS+2
;;
;;    CFA
;;
_CFA            text.7 $83, "CFA"
    			data.w _LFA    ; link to LFA
    			data.w CFA+2    ; PFAPTR

CFA:         	data.w DOCOL
    			data.w AT
    			data.w TWOMINUS
    			data.w SEMIS
;;
;;    NFA
;;
_NFA            text.7 $83, "NFA"
    			data.w _CFA    ; link to CFA
    			data.w NFA+2    ; PFAPTR

NFA:         	data.w DOCOL
    			data.w CLIT
    			data.b $03
    			data.w SUB
    			data.w LIT
    			data.w $ffff
    			data.w TRAVERSE
    			data.w SEMIS
;;
;;    PFAPTR
;;
_PFAPTR         text.7 $86, "PFAPTR"
    			data.w _NFA    ; link to NFA
    			data.w PFAPTR+2    ; PFAPTR
;;
;;
;;
PFAPTR:         data.w DOCOL
    			data.w ONE
    			data.w TRAVERSE
    			data.w CLIT
    			data.b $03
    			data.w PLUS
    			data.w SEMIS
;;
;;    !CSP
;;
_STORCSP        text.7 $84, "!CSP"
    			data.w _PFAPTR    ; link to PFAPTR
    			data.w STORCSP+2    ; PFAPTR

STORCSP:        data.w DOCOL
    			data.w SPAT
    			data.w CSP
    			data.w STORE
    			data.w SEMIS
;;
;;    ?ERROR
;;
_QERROR         text.7 $86, "?ERROR"
                data.w _STORCSP    ; link to !CSP
                data.w QERROR+2    ; PFAPTR

QERROR:         data.w DOCOL
    			data.w SWAP
    			data.w ZBRAN
    			data.w $0004
    			data.w ERR
    			data.w DROP
    			data.w SEMIS
;;
;;    ?COMP
;;
_QCOMP          text.7 $85, "?COMP"
    			data.w _QERROR    ; link to ?ERROR
    			data.w QCOMP+2    ; PFAPTR

QCOMP:         	data.w DOCOL
    			data.w STATE
    			data.w AT
    			data.w ZEQ
    			data.w CLIT
    			data.b $11
    			data.w QERROR
    			data.w SEMIS
;;
;;    ?EXEC
;;
_QEXEC          text.7 $85, "?EXEC"
    			data.w _QCOMP    ; link to ?COMP
    			data.w QEXEC+2    ; PFAPTR

QEXEC:         	data.w DOCOL
    			data.w STATE
    			data.w AT
    			data.w CLIT
    			data.b $12
    			data.w QERROR
    			data.w SEMIS
;;
;;    ?PAIRS
;;
_QPAIRS         text.7 $86, "?PAIRS"
    			data.w _QEXEC    ; link to ?EXEC
    			data.w QPAIRS+2    ; PFAPTR

QPAIRS:         data.w DOCOL
    			data.w SUB
    			data.w CLIT
    			data.b $13
    			data.w QERROR
    			data.w SEMIS
;;
;;    ?CSP
;;
_QCSP           text.7 $84, "?CSP"
                data.w _QPAIRS    ; link to ?PAIRS
    			data.w QCSP+2    ; PFAPTR

QCSP:         	data.w DOCOL
    			data.w SPAT
    			data.w CSP
    			data.w AT
    			data.w SUB
    			data.w CLIT
    			data.b $14
    			data.w QERROR
    			data.w SEMIS
;;
;;    COMPILE
;;
_COMPILE        text.7 $87, "COMPILE"
    			data.w _QCSP    ; link to ?CSP
    			data.w COMPILE+2    ; PFAPTR

COMPILE:        data.w DOCOL
    			data.w QCOMP
    			data.w RFROM
    			data.w DUP
    			data.w TWOPLUS
    			data.w GTR
    			data.w AT
    			data.w COMMA
    			data.w SEMIS
;;
;;    [
;;
_LBRAC          text.7 $c1, "["
    			data.w _COMPILE    ; link to COMPILE
    			data.w LBRAC+2    ; PFAPTR

LBRAC:         	data.w DOCOL
    			data.w ZERO
    			data.w STATE
    			data.w STORE
    			data.w SEMIS
;;
;;    ]
;;
_RBRAC          text.7 $81, "]"
    			data.w _LBRAC    ; link to [
    			data.w RBRAC+2    ; PFAPTR

RBRAC:         	data.w DOCOL
    			data.w CLIT
    			data.b $c0
    			data.w STATE
    			data.w STORE
    			data.w SEMIS
;;
;;    SMUDGE
;;
_SMUDGE         text.7 $86, "SMUDGE"
    			data.w _RBRAC    ; link to ]
    			data.w SMUDGE+2    ; PFAPTR

SMUDGE:         data.w DOCOL
    			data.w LATEST
    			data.w BL
    			data.w TOGGL
    			data.w SEMIS
;;
;;    HEX
;;
_HEX            text.7 $83, "HEX"
    			data.w _SMUDGE    ; link to SMUDGE
    			data.w HEX+2    ; PFAPTR
;;
;;    DECIMAL
;;
_DECIMAL             text.7 $87, "DECIMAL"
                  data.w _HEX    ; link to HEX
                  data.w DECIMAL+2    ; PFAPTR
;;
;;    (;CODE)
;;
_PSEMICODE             text.7 $87, "(;CODE)"
                  data.w _DECIMAL    ; link to DECIMAL
                  data.w PSEMICODE+2    ; PFAPTR
;;
;;
;;
PSEMICODE:         data.w DOCOL
                  data.w RFROM
                  data.w LATEST
                  data.w PFAPTR
                  data.w CFA
                  data.w STORE
                  data.w SEMIS
;;
;;    ;CODE
;;
_SEMICODE             text.7 $c5, ";CODE"
                  data.w _PSEMICODE    ; link to (;CODE)
                  data.w SEMICODE+2    ; PFAPTR
;;
;;
;;
SEMICODE:         data.w DOCOL
                  data.w QCSP
                  data.w COMPILE
                  data.w PSEMICODE
                  data.w LBRAC
                  data.w ASSEMBLER
                  data.w SEMIS
;;
;;    <BUILDS
;;
_LTBUILDS             text.7 $87, "<BUILDS"
                  data.w _SEMICODE    ; link to ;CODE
                  data.w LTBUILDS+2    ; PFAPTR
;;
;;
;;
LTBUILDS:         data.w DOCOL
                  data.w ZERO
                  data.w CONSTANT
                  data.w SEMIS
;;
;;    DOES>
;;
_DOESGT             text.7 $85, "DOES>"
                  data.w _LTBUILDS    ; link to <BUILDS
                  data.w DOESGT+2    ; PFAPTR
;;
;;
;;
DOESGT:         data.w DOCOL
                  data.w RFROM
                  data.w LATEST
                  data.w PFAPTR
                  data.w AT
                  data.w STORE
                  data.w LIT
                  data.w DOES
                  data.w DCSTOR
;;
;;    COUNT
;;
_COUNT             text.7 $85, "COUNT"
                  data.w _DOESGT    ; link to DOES>
                  data.w COUNT+2    ; PFAPTR
;;
;;    TYPE
;;
_TYPE             text.7 $84, "TYPE"
                  data.w _COUNT    ; link to COUNT
                  data.w TYPE+2    ; PFAPTR
;;
;;    -TRAILING
;;
_SUBTRAILING             text.7 $89, "-TRAILING"
                  data.w _TYPE    ; link to TYPE
                  data.w DTRAI+2    ; PFAPTR
;;
;;    (.")
;;
_PDOTQUOT             text.7 $84, "(.\")"
                  data.w _SUBTRAILING    ; link to -TRAILING
                  data.w PDOTQ+2    ; PFAPTR
;;
;;    ."
;;
_DOTQUOT             text.7 $c2, ".\""
                  data.w _PDOTQUOT    ; link to (.")
                  data.w DDOTQUOT+2    ; PFAPTR
;;
;;
;;
DDOTQUOT:       data.w DOCOL
                data.w CLIT
                data.b $22
                data.w STATE
                data.w AT
                data.w ZBRAN
                data.w $0012
                data.w COMPILE
    			data.w PDOTQ
;;
;;
;;
CONT:         data.w FWORD
                  data.w HERE
                  data.w CAT
                  data.w ONEPLUS
                  data.w ALLOT
                  data.w SEMIS
                  data.w FWORD
                  data.w HERE
                  data.w COUNT
                  data.w TYPE
                  data.w SEMIS
;;
;;    EXPECT
;;
DEXPECT           text.7 $86, "EXPECT"
                  data.w _DOTQUOT    ; link to ."
                  data.w EXPECT+2    ; PFAPTR
;;
;;    QUERY
;;
_QUERY             text.7 $85, "QUERY"
                  data.w DEXPECT    ; link to EXPECT
                  data.w QUERY+2    ; PFAPTR
;;
;;     
;;
_FX             text.7 $c1, "\0"
                  data.w _QUERY    ; link to QUERY
                  data.w FX+2    ; PFAPTR
;;
;;
;;
FX:         data.w DOCOL
                  data.w BLK
                  data.w AT
                  data.w ZBRAN
                  data.w $0010
                  data.w ONE
                  data.w BLK
                  data.w PSTORE
                  data.w ZERO
                  data.w IN
                  data.w STORE
                  data.w QEXEC
                  data.w RFROM
                  data.w DROP
                  data.w SEMIS
;;
;;    FILL
;;
_FILL             text.7 $84, "FILL"
                  data.w _FX    ; link to  
                  data.w FILL_+2    ; PFAPTR
;;
;;    ERASE
;;
_ERASE             text.7 $85, "ERASE"
                  data.w _FILL    ; link to FILL
                  data.w ERASE+2    ; PFAPTR
;;
;;    BLANKS
;;
_BLANKS             text.7 $86, "BLANKS"
                  data.w _ERASE    ; link to ERASE
                  data.w BLANKS+2    ; PFAPTR
;;
;;    HOLD
;;
_HOLD             text.7 $84, "HOLD"
                  data.w _BLANKS    ; link to BLANKS
                  data.w HOLD+2    ; PFAPTR
;;
;;    WORD
;;
_FWORD             text.7 $84, "WORD"
                  data.w _HOLD    ; link to HOLD
                  data.w FWORD+2    ; PFAPTR
;;
;;
;;
FWORD:         data.w DOCOL
                  data.w BLK
                  data.w AT
                  data.w ZBRAN
                  data.w $000c
                  data.w BLK
                  data.w AT
                  data.w BLOCK
                  data.w BRAN
                  data.w $0006
                  data.w TIB
                  data.w AT
                  data.w IN
                  data.w AT
                  data.w PLUS
                  data.w SWAP
                  data.w ENCLOSE
                  data.w HERE
                  data.w CLIT
                  data.b $22
                  data.w BLANKS
                  data.w IN
                  data.w PSTORE
                  data.w OVER
                  data.w SUB
                  data.w GTR
                  data.w R
                  data.w HERE
                  data.w CSTOR
                  data.w PLUS
                  data.w HERE
                  data.w ONEPLUS
                  data.w RFROM
                  data.w CMOVE
                  data.w SEMIS
;;
;;    (NUMBER)
;;
_PNUMBER             text.7 $88, "(NUMBER)"
                  data.w _FWORD    ; link to WORD
                  data.w LTNUMBER+2    ; PFAPTR
;;
;;    NUMBER
;;
_NUMBER             text.7 $86, "NUMBER"
                  data.w _PNUMBER    ; link to (NUMBER)
                  data.w NUMBER+2    ; PFAPTR
;;
;;
;;
NUMBER:         data.w DOCOL
                  data.w ZERO
                  data.w ZERO
                  data.w ROT
                  data.w DUP
                  data.w ONEPLUS
                  data.w CAT
                  data.w CLIT
                  data.b $2d
                  data.w EQUAL
                  data.w DUP
                  data.w GTR
                  data.w PLUS
                  data.w LIT
                  data.w $ffff
                  data.w DPL
                  data.w STORE
                  data.w LTNUMBER
                  data.w DUP
                  data.w CAT
                  data.w BL
                  data.w SUB
                  data.w ZBRAN
                  data.w $0015
                  data.w DUP
                  data.w CAT
                  data.w CLIT
                  data.b $2e
                  data.w SUB
                  data.w ZERO
                  data.w QERROR
                  data.w ZERO
                  data.w BRAN
                  data.w $ffdd
                  data.w DROP
                  data.w RFROM
                  data.w ZBRAN
                  data.w $0004
                  data.w DNEGATE
                  data.w SEMIS
;;
;;    -FIND
;;
_SUBFIND             text.7 $85, "-FIND"
                  data.w _NUMBER    ; link to NUMBER
                  data.w SUBFIND+2    ; PFAPTR
;;
;;
;;
SUBFIND:         data.w DOCOL
                  data.w BL
                  data.w FWORD
                  data.w HERE
                  data.w CONTEXT
                  data.w AT
                  data.w AT
                  data.w FIND
                  data.w DUP
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $000a
                  data.w DROP
                  data.w HERE
                  data.w LATEST
                  data.w FIND
                  data.w SEMIS
;;
;;    (ABORT)
;;
_PABORT             text.7 $87, "(ABORT)"
                  data.w _SUBFIND    ; link to -FIND
                  data.w PABORT+2    ; PFAPTR
;;
;;
;;
PABORT:         data.w DOCOL
                  data.w UABORT
                  data.w AT
                  data.w EXECUTE
                  data.w SEMIS
;;
;;    ERROR
;;
_ERR             text.7 $85, "ERROR"
                  data.w _PABORT    ; link to (ABORT)
                  data.w ERR+2    ; PFAPTR
;;
;;
;;
ERR:         data.w DOCOL
                  data.w WARNING
                  data.w AT
                  data.w ZLT
                  data.w ZBRAN
                  data.w $0004
                  data.w PABORT
                  data.w HERE
                  data.w COUNT
                  data.w CR
                  data.w TYPE
                  data.w PDOTQ
                  data.b $03, " ? "
                  data.w FMESSAGE
                  data.w SPSTO
                  data.w TWODROP
                  data.w IN
                  data.w AT
                  data.w BLK
                  data.w AT
L1684             data.w LIT
                  data.w XKEY
                  data.w CLIT
                  data.b $44
                  data.w STORE
                  data.w QUIT
;;
;;    ID.
;;
_ID             text.7 $83, "ID."
                  data.w _ERR    ; link to ERROR
                  data.w ID+2    ; PFAPTR
;;
;;
;;
ID:         data.w DOCOL
                  data.w COUNT
                  data.w ONEMINUS
                  data.w CLIT
                  data.b $1f
                  data.w ANDD
                  data.w TWODUP
                  data.w TYPE
                  data.w PLUS
                  data.w AT
                  data.w CLIT
                  data.b $7f
                  data.w ANDD
                  data.w EMIT
                  data.w SPACE
                  data.w SEMIS
;;
;;    CREATE
;;
_CREATE             text.7 $86, "CREATE"
                  data.w _ID    ; link to ID.
                  data.w CREATE+2    ; PFAPTR
;;
;;
;;
CREATE:         data.w DOCOL
                  data.w FIRST
                  data.w HEREDIV
                  data.w CLIT
                  data.b $24
                  data.w PLUS
                  data.w ULESS
                  data.w TWO
                  data.w QERROR
                  data.w FIRST
                  data.w HERE
                  data.w CLIT
                  data.b $a0
                  data.w PLUS
                  data.w ULESS
                  data.w TWO
                  data.w QERROR
                  data.w SUBFIND
                  data.w ZBRAN
                  data.w $0018
                  data.w DROP
                  data.w CR
                  data.w NFA
                  data.w ID
                  data.w PDOTQ
                  data.b $0b, "NOT UNIQUE "
                  data.w HERE
                  data.w HEREDIV
                  data.w OVER
                  data.w CAT
                  data.w ONEPLUS
                  data.w CMOVE
                  data.w HEREDIV
                  data.w DUP
                  data.w CAT
                  data.w WIDTH
                  data.w AT
                  data.w MIN
                  data.w ONEPLUS
                  data.w ALLOTDIV
                  data.w DP
                  data.w CAT
                  data.w CLIT
                  data.b $fd
                  data.w EQUAL
                  data.w ALLOT
                  data.w DUP
                  data.w CLIT
                  data.b $a0
                  data.w TOGGL
                  data.w HEREDIV
                  data.w ONEMINUS
                  data.w CLIT
                  data.b $80
                  data.w TOGGL
                  data.w LATEST
                  data.w COMMADIV
                  data.w CURRENT
                  data.w AT
                  data.w STORE
                  data.w HERE
                  data.w TWOPLUS
                  data.w HEADERLESS
                  data.w AT
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $0004
                  data.w TWOPLUS
                  data.w DUP
                  data.w COMMADIV
                  data.w COMMA
                  data.w SEMIS
;;
;;    [COMPILE]
;;
_BRACCOMPILE             text.7 $c9, "[COMPILE]"
                  data.w _CREATE    ; link to CREATE
                  data.w BRACCOMPILE+2    ; PFAPTR
;;
;;
;;
BRACCOMPILE:         data.w DOCOL
                  data.w SUBFIND
                  data.w ZEQ
                  data.w ZERO
                  data.w QERROR
                  data.w DROP
                  data.w CFA
                  data.w COMMA
                  data.w SEMIS
;;
;;    LITERAL
;;
_LITERAL             text.7 $c7, "LITERAL"
                  data.w _BRACCOMPILE    ; link to [COMPILE]
                  data.w LITERAL+2    ; PFAPTR
;;
;;
;;
LITERAL:         data.w DOCOL
                  data.w STATE
                  data.w AT
                  data.w ZBRAN
                  data.w $001c
                  data.w DUP
                  data.w LIT
                  data.w $ff00
                  data.w ANDD
                  data.w ZBRAN
                  data.w $000a
                  data.w COMPILE
                  data.w LIT
                  data.w COMMA
                  data.w SEMIS
;;
;;
;;
CREATE5:        data.w COMPILE
                data.w CLIT
                data.b $aa
    			data.b $c5
				data.w SEMIS
;;
;;    DLITERAL
;;
_DLITERAL       text.7 $c8, "DLITERAL"
    			data.w _LITERAL    ; link to LITERAL
    			data.w DLITERAL+2    ; PFAPTR
;;
;;
;;
DLITERAL:       data.w DOCOL
    			data.w STATE
    			data.w AT
    			data.w ZBRAN
    			data.w $0008
    			data.w SWAP
    			data.w LITERAL
    			data.w LITERAL
    			data.w SEMIS
;;
;;    ?STACK
;;
_QSTACK         text.7 $86, "?STACK"
    			data.w _DLITERAL    ; link to DLITERAL
    			data.w QSTACK+2    ; PFAPTR

QSTACK:         data.w DOCOL
    			data.w SPAT
    			data.w CLIT
    			data.b $c2
    			data.w SWAP
    			data.w ULESS
    			data.w ONE
    			data.w QERROR
    			data.w SPAT
    			data.w CLIT
    			data.b $5d
    			data.w ULESS
    			data.w CLIT
    			data.b $07
    			data.w QERROR
    			data.w SEMIS
;;
;;    INTERPRET
;;
_INTERPRET      text.7 $89, "INTERPRET"
    			data.w _QSTACK    ; link to ?STACK
    			data.w INTERPRET+2    ; PFAPTR
;;
;;
;;
INTERPRET:      data.w DOCOL
                  data.w SUBFIND
                  data.w ZBRAN
                  data.w $001e
                  data.w STATE
                  data.w AT
                  data.w LESS
                  data.w ZBRAN
                  data.w $000a
                  data.w CFA
                  data.w COMMA
                  data.w BRAN
                  data.w $0006
                  data.w CFA
                  data.w EXECUTE
                  data.w QSTACK
                  data.w BRAN
                  data.w $001c
                  data.w HERE
                  data.w NUMBER
                  data.w DPL
                  data.w AT
                  data.w ONEPLUS
                  data.w ZBRAN
                  data.w $0008
                  data.w DLITERAL
                  data.w BRAN
                  data.w $0006
                  data.w DROP
                  data.w LITERAL
                  data.w QSTACK
                  data.w BRAN
                  data.w $ffc2
;;
;;    IMMEDIATE
;;
_IMMEDIATE      text.7 $89, "IMMEDIATE"
    			data.w _INTERPRET    ; link to INTERPRET
    			data.w IMMEDIATE+2    ; PFAPTR

IMMEDIATE:      data.w DOCOL
                  data.w LATEST
                  data.w CLIT
                  data.b $40
                  data.w TOGGL
                  data.w SEMIS
;;
;;    VOCABULARY
;;
_VOCABULARY     text.7 $8a, "VOCABULARY"
    			data.w _IMMEDIATE    ; link to IMMEDIATE
    			data.w VOCABULARY+2    ; PFAPTR
;;
;;
;;
VOCABULARY:         data.w DOCOL
                  data.w LTBUILDS
                  data.w LIT
                  data.w $a081
                  data.w COMMA
                  data.w CURRENT
                  data.w AT
                  data.w TWOMINUS
                  data.w COMMA
                  data.w HERE
                  data.w VOCL
                  data.w AT
                  data.w COMMA
                  data.w VOCL
                  data.w STORE
                  data.w DOESGT
                  data.w TWOPLUS
                  data.w CONTEXT
                  data.w STORE
                  data.w SEMIS
;;
;;    FORTH
;;
_FORTH             text.7 $c5, "FORTH"
                  data.w _VOCABULARY    ; link to VOCABULARY
                  data.w FORTH+2    ; PFAPTR

FORTH:         data.w DOCOL
                  data.w VOCL4
                  data.w CONTEXT
                  data.w STORE
                  data.w SEMIS
;;
;;    ASSEMBLER
;;
_ASSEMBLER             text.7 $c9, "ASSEMBLER"
                  data.w _FORTH    ; link to FORTH
                  data.w ASSEMBLER+2    ; PFAPTR
;;
;;
;;
ASSEMBLER:         data.w DOCOL
                  data.w VOCL8
                  data.w BRAN
                  data.w $ffe6
;;
;;    DEFINITIONS
;;
_DEFINITIONS             text.7 $8b, "DEFINITIONS"
                  data.w _ASSEMBLER    ; link to ASSEMBLER
                  data.w DEFINITIONS+2    ; PFAPTR
;;
;;
;;
DEFINITIONS:         data.w DOCOL
                  data.w CONTEXT
                  data.w AT
                  data.w CURRENT
                  data.w STORE
                  data.w SEMIS
;;
;;    (
;;
_OBRAC             text.7 $c1, "("
                  data.w _DEFINITIONS    ; link to DEFINITIONS
                  data.w OBRAC+2    ; PFAPTR
;;
;;
;;
OBRAC:         data.w DOCOL
                  data.w CLIT
                  data.b $29
                  data.w FWORD
                  data.w SEMIS
;;
;;    QUIT
;;
_QUIT             text.7 $84, "QUIT"
                  data.w _OBRAC    ; link to (
                  data.w QUIT+2    ; PFAPTR
;;
;;
;;
QUIT:         data.w DOCOL
                  data.w ZERO
                  data.w BLK
                  data.w STORE
                  data.w LBRAC
                  data.w RPSTO
                  data.w CR
                  data.w QUERY
                  data.w INTERPRET
                  data.w STATE
                  data.w AT
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $0007
                  data.w PDOTQ
                  data.b $02, "OK"
                  data.w BRAN
                  data.w $ffe7
;;
;;    ABORT
;;
_ABORT          text.7 $85, "ABORT"
    			data.w _QUIT    ; link to QUIT
    			data.w ABORT+2    ; PFAPTR

ABORT:          data.w DOCOL
    			data.w SPSTO
    			data.w CR
    			data.w PDOTQ
    			data.b $0f, " RSC-FORTH V2.0"
    			data.w FORTH
    			data.w DEFINITIONS
    			data.w QUIT
    			data.w DOCOL
KSTART:			data.w LIT
				data.w $a55a
                  data.w DUP
                  data.w CLDWRM
                  data.w AT
                  data.w EQUAL
                  data.w ZEQ
                  data.w CLIT
                  data.b $17
                  data.w CAT
                  data.w CLIT
                  data.b $12
                  data.w EQUAL
                  data.w OR
                  data.w ZBRAN
                  data.w $0022
                  data.w LIT
                  data.w USER_BASE+$7e
                  data.w UPAD
                  data.w STORE
                  data.w LIT
                  data.w UNKNOWN
                  data.w DCYLINDER
                  data.w CLIT
                  data.b $28
                  data.w CMOVE
                  data.w LIT
                  data.w _TASK
                  data.w LIT
                  data.w DICT_BASE+$04
                  data.w CLIT
                  data.b $0b
                  data.w CMOVE
                  data.w CLDWRM
                  data.w STORE
                  data.w ABORT
;;
;;    COLD
;;
_COLD             text.7 $84, "COLD"
                  data.w _ABORT    ; link to ABORT
                  data.w COLD+2    ; PFAPTR
;;
;;    S->D
;;
_STOD             text.7 $84, "S->D"
                  data.w _COLD    ; link to COLD
                  data.w STOD+2    ; PFAPTR
;;
;;    +-
;;
_PLUSMINUS             text.7 $82, "+-"
                  data.w _STOD    ; link to S->D
                  data.w PM+2    ; PFAPTR
;;
;;    D+-
;;
_DPLUSMINUS             text.7 $83, "D+-"
                  data.w _PLUSMINUS    ; link to +-
                  data.w DPLUS1+2    ; PFAPTR
;;
;;    ABS
;;
_ABS             text.7 $83, "ABS"
                  data.w _DPLUSMINUS    ; link to D+-
                  data.w ABS+2    ; PFAPTR
;;
;;    DABS
;;
_DABS             text.7 $84, "DABS"
                  data.w _ABS    ; link to ABS
                  data.w DABS+2    ; PFAPTR
;;
;;    MIN
;;
_MIN             text.7 $83, "MIN"
                  data.w _DABS    ; link to DABS
                  data.w MIN+2    ; PFAPTR
;;
;;    MAX
;;
_MAX             text.7 $83, "MAX"
                  data.w _MIN    ; link to MIN
                  data.w R_FC70    ; PFAPTR
;;
;;    M*
;;
_MMUL             text.7 $82, "M*"
                  data.w _MAX    ; link to MAX
                  data.w MMUL+2    ; PFAPTR
;;
;;    M/
;;
_MDIV             text.7 $82, "M/"
                  data.w _MMUL    ; link to M*
                  data.w MDIV+2    ; PFAPTR
;;
;;    *
;;
_MUL             text.7 $81, "*"
                  data.w _MDIV    ; link to M/
                  data.w MUL+2    ; PFAPTR
;;
;;    /MOD
;;
_DIVMOD             text.7 $84, "/MOD"
                  data.w _MUL    ; link to *
                  data.w DIVMOD+2    ; PFAPTR
;;
;;    /
;;
_DIV             text.7 $81, "/"
                  data.w _DIVMOD    ; link to /MOD
                  data.w DIV_+2    ; PFAPTR
;;
;;    MOD
;;
_MOD             text.7 $83, "MOD"
                  data.w _DIV    ; link to /
                  data.w MOD_+2    ; PFAPTR
;;
;;    */MOD
;;
_MULDIVMOD             text.7 $85, "*/MOD"
                  data.w _MOD    ; link to MOD
                  data.w MULDIVMOD+2    ; PFAPTR
;;
;;    */
;;
_MULDIV             text.7 $82, "*/"
                  data.w _MULDIVMOD    ; link to */MOD
                  data.w MULDIV+2    ; PFAPTR
;;
;;    M/MOD
;;
_MMOD             text.7 $85, "M/MOD"
                  data.w _MULDIV    ; link to */
                  data.w MDIVMOD+2    ; PFAPTR
;;
;;    +BUF
;;
_PLUSBUF             text.7 $84, "+BUF"
                  data.w _MMOD    ; link to M/MOD
                  data.w PLUSBUF+2    ; PFAPTR

PLUSBUF:         data.w DOCOL
                  data.w LIT
                  data.w $0404
                  data.w PLUS
                  data.w LIMIT
                  data.w LIT
                  data.w $0404
                  data.w SUB
                  data.w OVER
                  data.w ULESS
                  data.w ZBRAN
                  data.w $0006
                  data.w DROP
                  data.w FIRST
                  data.w DUP
                  data.w PREV
                  data.w AT
                  data.w SUB
                  data.w SEMIS
;;
;;    UPDATE
;;
_UPDATE             text.7 $86, "UPDATE"
                  data.w _PLUSBUF    ; link to +BUF
                  data.w UPDATE+2    ; PFAPTR

UPDATE:         data.w DOCOL
                  data.w PREV
                  data.w AT
                  data.w AT
                  data.w LIT
                  data.w $8000
                  data.w OR
                  data.w PREV
                  data.w AT
                  data.w STORE
                  data.w SEMIS
;;
;;    EMPTY-BUFFERS
;;
_EMPTYBUFFERS             text.7 $8d, "EMPTY-BUFFERS"
                  data.w _UPDATE    ; link to UPDATE
                  data.w EMPTYBUFFERS+2    ; PFAPTR

EMPTYBUFFERS:         data.w DOCOL
                  data.w FIRST
                  data.w LIMIT
                  data.w OVER
                  data.w SUB
                  data.w ERASE
                  data.w FIRST
                  data.w DUP
                  data.w USE
                  data.w STORE
                  data.w PREV
                  data.w STORE
                  data.w SEMIS
;;
;;    BUFFER
;;
_BUFFER             text.7 $86, "BUFFER"
                  data.w _EMPTYBUFFERS    ; link to EMPTY-BUFFERS
                  data.w BUFFER+2    ; PFAPTR

BUFFER:         data.w DOCOL
                  data.w USE
                  data.w AT
                  data.w DUP
                  data.w GTR
                  data.w PLUSBUF
                  data.w ZBRAN
                  data.w $fffc
                  data.w USE
                  data.w STORE
                  data.w R
                  data.w AT
                  data.w ZLT
                  data.w ZBRAN
                  data.w $0014
                  data.w R
                  data.w TWOPLUS
                  data.w R
                  data.w AT
                  data.w LIT
                  data.w $7fff
                  data.w ANDD
                  data.w ZERO
                  data.w RW
                  data.w R
                  data.w STORE
                  data.w R
                  data.w PREV
                  data.w STORE
                  data.w RFROM
                  data.w TWOPLUS
                  data.w SEMIS
;;
;;    BLOCK
;;
_BLOCK             text.7 $85, "BLOCK"
                  data.w _BUFFER    ; link to BUFFER
                  data.w BLOCK+2    ; PFAPTR
;;
;;
;;
BLOCK:         data.w DOCOL
                  data.w OFFSET
                  data.w AT
                  data.w PLUS
                  data.w GTR
                  data.w PREV
                  data.w AT
                  data.w DUP
                  data.w AT
                  data.w R
                  data.w SUB
                  data.w DUP
                  data.w PLUS
                  data.w ZBRAN
                  data.w $0032
                  data.w PLUSBUF
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $0012
                  data.w DROP
                  data.w R
                  data.w BUFFER
                  data.w DUP
                  data.w R
                  data.w ONE
                  data.w RW
                  data.w TWOMINUS
                  data.w DUP
                  data.w AT
                  data.w R
                  data.w SUB
                  data.w DUP
                  data.w PLUS
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $ffd8
                  data.w DUP
                  data.w PREV
                  data.w STORE
                  data.w RFROM
                  data.w DROP
                  data.w TWOPLUS
                  data.w SEMIS
;;
;;    FLUSH
;;
_FLUSH             text.7 $85, "FLUSH"
                  data.w _BLOCK    ; link to BLOCK
                  data.w FLUSH+2    ; PFAPTR
;;
;;
;;
FLUSH:         data.w DOCOL
                  data.w LIMIT
                  data.w FIRST
                  data.w SUB
                  data.w LIT
                  data.w $0404
                  data.w DIV_
                  data.w ONEPLUS
                  data.w ZERO
                  data.w DO
                  data.w LIT
                  data.w $7fff
                  data.w BUFFER
                  data.w DROP
                  data.w LOOP
                  data.w $fff6
                  data.w SEMIS
;;
;;    DUMP
;;
_DDUMP             text.7 $84, "DUMP"
                  data.w _FLUSH    ; link to FLUSH
                  data.w DDUMP+2    ; PFAPTR
;;
;;
;;
DDUMP:         data.w DOCOL
                  data.w ZERO
                  data.w DO
                  data.w CR
                  data.w DUP
                  data.w ZERO
                  data.w CLIT
                  data.b $05
                  data.w DDOTR
                  data.w SPACE
                  data.w CLIT
                  data.b $10
                  data.w SWAP
                  data.w OVER
                  data.w ZERO
                  data.w DO
                  data.w DUP
                  data.w CAT
                  data.w THREE
                  data.w DOTR
                  data.w ONEPLUS
                  data.w LOOP
                  data.w $fff4
                  data.w SWAP
                  data.w PLOOP
                  data.w $ffd6
                  data.w DROP
                  data.w CR
                  data.w SEMIS
;;
;;    (LINE)
;;
_PLINE             text.7 $86, "(LINE)"
                  data.w _DDUMP    ; link to DUMP
                  data.w PLINE+2    ; PFAPTR
;;
;;
;;
PLINE:         data.w DOCOL
                  data.w GTR
                  data.w CLIT
                  data.b $40
                  data.w LIT
                  data.w $0400
                  data.w MULDIVMOD
                  data.w RFROM
                  data.w PLUS
                  data.w BLOCK
                  data.w PLUS
                  data.w CLIT
                  data.b $40
                  data.w SEMIS
;;
;;    .LINE
;;
_DOTLINE             text.7 $85, ".LINE"
                  data.w _PLINE    ; link to (LINE)
                  data.w DOTLINE+2    ; PFAPTR
;;
;;
;;
DOTLINE:         data.w DOCOL
                  data.w PLINE
                  data.w DTRAI
                  data.w TYPE
                  data.w SEMIS
;;
;;    >LINE
;;
_GTLINE             text.7 $85, ">LINE"
                  data.w _DOTLINE    ; link to .LINE
                  data.w GTLINE+2    ; PFAPTR
;;
;;
;;
GTLINE:         data.w DOCOL
                  data.w SCR
                  data.w AT
                  data.w PLINE
                  data.w OVER
                  data.w SWAP
                  data.w BLANKS
                  data.w ZERO
                  data.w FWORD
                  data.w HERE
                  data.w COUNT
                  data.w CLIT
                  data.b $40
                  data.w MIN
                  data.w ROT
                  data.w SWAP
                  data.w CMOVE
                  data.w UPDATE
                  data.w SEMIS
;;
;;    MESSAGE
;;
_FMESSAGE             text.7 $87, "MESSAGE"
                  data.w _GTLINE    ; link to >LINE
                  data.w FMESSAGE+2    ; PFAPTR
;;
;;
;;
FMESSAGE:         data.w DOCOL
                  data.w DDUP
                  data.w ZBRAN
                  data.w $0014
                  data.w WARNING
                  data.w AT
                  data.w ZBRAN
                  data.w $000e
                  data.w FOUR
                  data.w OFFSET
                  data.w AT
                  data.w SUB
                  data.w DOTLINE
                  data.w SEMIS
                  data.w DUP
                  data.w ONE
                  data.w EQUAL
                  data.w ZBRAN
                  data.w $0014
                  data.w DROP
                  data.w PDOTQ
                  data.b $0b, "STACK EMPTY"
                  data.w SEMIS
                  data.w PDOTQ
                  data.b $05, "MSG# "
                  data.w BASE
                  data.w AT
                  data.w DECIMAL
                  data.w SWAP
                  data.w DOT
                  data.w BASE
                  data.w STORE
                  data.w SEMIS
;;
;;    LOAD
;;
_LOAD             text.7 $84, "LOAD"
                  data.w _FMESSAGE    ; link to MESSAGE
                  data.w LOAD+2    ; PFAPTR
;;
;;
;;
LOAD:         data.w DOCOL
                  data.w BLK
                  data.w AT
                  data.w GTR
                  data.w IN
                  data.w AT
                  data.w GTR
                  data.w ZERO
                  data.w IN
                  data.w STORE
                  data.w BLK
                  data.w STORE
                  data.w INTERPRET
                  data.w RFROM
                  data.w IN
                  data.w STORE
                  data.w RFROM
                  data.w BLK
                  data.w STORE
                  data.w SEMIS
;;
;;    -->
;;
_ARROW             text.7 $c3, "-->"
                  data.w _LOAD    ; link to LOAD
                  data.w ARROW+2    ; PFAPTR
;;
;;
;;
ARROW:         data.w DOCOL
                  data.w BLK
                  data.w AT
                  data.w ZEQ
                  data.w CLIT
                  data.b $16
                  data.w QERROR
                  data.w ZERO
                  data.w IN
                  data.w STORE
                  data.w ONE
                  data.w BLK
                  data.w PSTORE
                  data.w SEMIS
;;
;;    -BCD
;;
_SUBBCD             text.7 $84, "-BCD"
                  data.w _ARROW    ; link to -->
                  data.w SUBBCD+2    ; PFAPTR
;;
;;
;;
SUBBCD:         data.w DOCOL
                  data.w ZERO
                  data.w CLIT
                  data.b $0a
                  data.w USLAS
                  data.w CLIT
                  data.b $10
                  data.w MUL
                  data.w OR
                  data.w SEMIS
;;
;;    B/BUF
;;
_BBUF             text.7 $85, "B/BUF"
                  data.w _SUBBCD    ; link to -BCD
                  data.w BBUF+2    ; PFAPTR
;;
;;
;;
BBUF:         data.w DOCON
                  data.w $0400
;;
;;    B/SCR
;;
_BSCR             text.7 $85, "B/SCR"
                  data.w _BBUF    ; link to B/BUF
                  data.w BSCR+2    ; PFAPTR
;;
;;
;;
BSCR:         data.w DOCON
                  data.w $0001
;;
;;    R/W
;;
_RW             text.7 $83, "R/W"
                  data.w _BSCR    ; link to B/SCR
                  data.w RW+2    ; PFAPTR
;;
;;
;;
RW:         data.w DOCOL
                  data.w URW
                  data.w AT
                  data.w EXECUTE
                  data.w SEMIS
;;
;;    DISK
;;
_DISK             text.7 $84, "DISK"
                  data.w _RW    ; link to R/W
                  data.w DISK+2    ; PFAPTR
;;
;;    SELECT
;;
_SELECT             text.7 $86, "SELECT"
                  data.w _DISK    ; link to DISK
                  data.w SELECT+2    ; PFAPTR
;;
;;    DREAD
;;
_DREAD             text.7 $85, "DREAD"
                  data.w _SELECT    ; link to SELECT
                  data.w DREAD+2    ; PFAPTR
;;
;;    DWRITE
;;
_DWRITE             text.7 $86, "DWRITE"
                  data.w _DREAD    ; link to DREAD
                  data.w DWRITE+2    ; PFAPTR
;;
;;    INIT
;;
_INIT             text.7 $84, "INIT"
                  data.w _DWRITE    ; link to DWRITE
                  data.w INIT+2    ; PFAPTR
;;
;;    SEEK
;;
_SEEK             text.7 $84, "SEEK"
                  data.w _INIT    ; link to INIT
                  data.w SEEK+2    ; PFAPTR
;;
;;    '
;;
_TICK             text.7 $c1, "'"
                  data.w _SEEK    ; link to SEEK
                  data.w TICK+2    ; PFAPTR
;;
;;
;;
TICK:         data.w DOCOL
                  data.w SUBFIND
                  data.w ZEQ
                  data.w ZERO
                  data.w QERROR
                  data.w DROP
                  data.w LITERAL
                  data.w SEMIS
;;
;;    H/C
;;
_HC             text.7 $83, "H/C"
                  data.w _TICK    ; link to '
                  data.w HC+2    ; PFAPTR
;;
;;
;;
HC:         data.w DOCOL
                  data.w ONE
                  data.w HEADERLESS
                  data.w STORE
                  data.w DUP
                  data.w DPDIV
                  data.w STORE
                  data.w CR
                  data.w PDOTQ
                  data.b $06, "HEADS/"
                  data.w DOT
                  data.w CR
                  data.w PDOTQ
                  data.b $06, "CODES/"
                  data.w HERE
                  data.w DOT
                  data.w SEMIS
;;
;;    HWORD
;;
_HWORD             text.7 $85, "HWORD"
                  data.w _HC    ; link to H/C
                  data.w HWORD+2    ; PFAPTR
;;
;;
;;
HWORD:         data.w DOCOL
                  data.w HEADERLESS
                  data.w AT
                  data.w ZBRAN
                  data.w $003e
                  data.w LATEST
                  data.w PFAPTR
                  data.w CFA
                  data.w DUP
                  data.w AT
                  data.w OVER
                  data.w TWOPLUS
                  data.w EQUAL
                  data.w ZBRAN
                  data.w $000a
                  data.w HEREDIV
                  data.w TWOPLUS
                  data.w OVER
                  data.w STORE
                  data.w HERE
                  data.w OVER
                  data.w DUP
                  data.w DP
                  data.w STORE
                  data.w SUB
                  data.w HEREDIV
                  data.w TWOPLUS
                  data.w HEREDIV
                  data.w TWOMINUS
                  data.w STORE
                  data.w HEREDIV
                  data.w SWAP
                  data.w DUP
                  data.w ALLOTDIV
                  data.w CMOVE
                  data.w SEMIS
;;
;;    ?KERNEL
;;
_QKERNEL             text.7 $87, "?KERNEL"
                  data.w _HWORD    ; link to HWORD
                  data.w QKERNEL+2    ; PFAPTR
;;
;;
;;
QKERNEL:         data.w DOCOL
                  data.w TICK
                  data.w CFA
                  data.w LIT
                  data.w INITTAB
                  data.w ULESS
                  data.w ZBRAN
                  data.w $0011
                  data.w PDOTQ
                  data.b $08, "OUTSIDE "
                  data.w BRAN
                  data.w $000c
                  data.w PDOTQ
                  data.b $07, "INSIDE "
                  data.w SEMIS
;;
;;    AUTOSTART
;;
_AUTOSTART             text.7 $89, "AUTOSTART"
                  data.w _QKERNEL    ; link to ?KERNEL
                  data.w AUTOSTART+2    ; PFAPTR
;;
;;
;;
AUTOSTART:         data.w DOCOL
                  data.w TICK
                  data.w AT
                  data.w DUP
                  data.w LIT
                  data.w FX+2
                  data.w EQUAL
                  data.w ZBRAN
                  data.w $0011
                  data.w PDOTQ
                  data.b $0a, "NAME ERROR"
                  data.w QUIT
                  data.w OVER
                  data.w TWOPLUS
                  data.w STORE
                  data.w LIT
                  data.w $a55a
                  data.w SWAP
                  data.w STORE
                  data.w SEMIS
;;
;;    FORGET
;;
_FORGET             text.7 $86, "FORGET"
                  data.w _AUTOSTART    ; link to AUTOSTART
                  data.w FORGET+2    ; PFAPTR
;;
;;
;;
FORGET:         data.w DOCOL
                  data.w TICK
                  data.w NFA
                  data.w DUP
                  data.w R_D1FE
                  data.w SWAP
                  data.w FENCE
                  data.w AT
                  data.w ULESS
                  data.w OR
                  data.w CLIT
                  data.b $15
                  data.w QERROR
                  data.w GTR
                  data.w VOCL
                  data.w AT
                  data.w R
                  data.w OVER
                  data.w ULESS
                  data.w ZBRAN
                  data.w $0012
                  data.w FORTH
                  data.w DEFINITIONS
                  data.w AT
                  data.w DUP
                  data.w VOCL
                  data.w STORE
                  data.w BRAN
                  data.w $ffe8
                  data.w DUP
                  data.w FOUR
                  data.w SUB
                  data.w PFAPTR
                  data.w LFA
                  data.w AT
                  data.w DUP
                  data.w R_D1FE
                  data.w SWAP
                  data.w R
                  data.w ULESS
                  data.w OR
                  data.w ZBRAN
                  data.w $ffec
                  data.w OVER
                  data.w TWOMINUS
                  data.w STORE
                  data.w AT
                  data.w DDUP
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $ffd6
                  data.w RFROM
                  data.w DUP
                  data.w PFAPTR
                  data.w CFA
                  data.w DP
                  data.w STORE
                  data.w DPDIV
                  data.w STORE
                  data.w SEMIS
R_D1FE: 	data.w DOCOL
                  data.w LIT
                  data.w UNKNOWN
                  data.w OVER
                  data.w ULESS
                  data.w OVER
                  data.w LIT
                  data.w PADDINGD
                  data.w ULESS
                  data.w ANDD
                  data.w SEMIS

UNK7:			  data.w DOCOL
                  data.w HERE
                  data.w SUB
                  data.w COMMA
                  data.w SEMIS
;;
;;    BEGIN
;;
_BEGIN             text.7 $c5, "BEGIN"
                  data.w _FORGET    ; link to FORGET
                  data.w BEGIN+2    ; PFAPTR
;;
;;
;;
BEGIN:         data.w DOCOL
                  data.w QCOMP
                  data.w HERE
                  data.w ONE
                  data.w SEMIS
;;
;;    ENDIF
;;
_FENDIF             text.7 $c5, "ENDIF"
                  data.w _BEGIN    ; link to BEGIN
                  data.w FENDIF+2    ; PFAPTR
;;
;;
;;
FENDIF:         data.w DOCOL
                  data.w QCOMP
                  data.w TWO
                  data.w QPAIRS
                  data.w HERE
                  data.w OVER
                  data.w SUB
                  data.w SWAP
                  data.w STORE
                  data.w SEMIS
;;
;;    THEN
;;
_FTHEN             text.7 $c4, "THEN"
                  data.w _FENDIF    ; link to ENDIF
                  data.w FTHEN+2    ; PFAPTR
;;
;;
;;
FTHEN:         data.w DOCOL
                  data.w FENDIF
                  data.w SEMIS
;;
;;    DO
;;
_FDO             text.7 $c2, "DO"
                  data.w _FTHEN    ; link to THEN
                  data.w FDO+2    ; PFAPTR
;;
;;
;;
FDO:         data.w DOCOL
                  data.w COMPILE
                  data.w DO
                  data.w HERE
                  data.w THREE
                  data.w SEMIS
;;
;;    LOOP
;;
_LOOP             text.7 $c4, "LOOP"
                  data.w _FDO    ; link to DO
                  data.w DLOOP+2    ; PFAPTR
;;
;;
;;
DLOOP:         data.w DOCOL
                  data.w THREE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w LOOP
                  data.w UNK7
                  data.w SEMIS
;;
;;    +LOOP
;;
_PLUSLOOP            text.7 $c5, "+LOOP"
                  data.w _LOOP    ; link to LOOP
                  data.w DPLOOP+2    ; PFAPTR
;;
;;
;;
DPLOOP:         data.w DOCOL
                  data.w THREE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w PLOOP
                  data.w UNK7
                  data.w SEMIS
;;
;;    UNTIL
;;
_FUNTIL             text.7 $c5, "UNTIL"
                  data.w _PLUSLOOP    ; link to +LOOP
                  data.w FUNTIL+2    ; PFAPTR
;;
;;
;;
FUNTIL:         data.w DOCOL
                  data.w ONE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w ZBRAN
                  data.w UNK7
                  data.w SEMIS
;;
;;    END
;;
_FEND             text.7 $c3, "END"
                  data.w _FUNTIL    ; link to UNTIL
                  data.w FEND+2    ; PFAPTR
;;
;;
;;
FEND:         data.w DOCOL
                  data.w FUNTIL
                  data.w SEMIS
;;
;;    AGAIN
;;
_FAGAIN             text.7 $c5, "AGAIN"
                  data.w _FEND    ; link to END
                  data.w FAGAIN+2    ; PFAPTR
;;
;;
;;
FAGAIN:         data.w DOCOL
                  data.w ONE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w BRAN
                  data.w UNK7
                  data.w SEMIS
;;
;;    REPEAT
;;
_FREPEAT             text.7 $c6, "REPEAT"
                  data.w _FAGAIN    ; link to AGAIN
                  data.w FREPEAT+2    ; PFAPTR
;;
;;
;;
FREPEAT:         data.w DOCOL
                  data.w GTR
                  data.w GTR
                  data.w FAGAIN
                  data.w RFROM
                  data.w RFROM
                  data.w TWOMINUS
                  data.w FENDIF
                  data.w SEMIS
;;
;;    IF
;;
_FIF             text.7 $c2, "IF"
                  data.w _FREPEAT    ; link to REPEAT
                  data.w FIF+2    ; PFAPTR
;;
;;
;;
FIF:         data.w DOCOL
                  data.w COMPILE
                  data.w ZBRAN
                  data.w HERE
                  data.w ZERO
                  data.w COMMA
                  data.w TWO
                  data.w SEMIS
;;
;;    ELSE
;;
_FELSE             text.7 $c4, "ELSE"
                  data.w _FIF    ; link to IF
                  data.w FELSE+2    ; PFAPTR
;;
;;
;;
FELSE:         data.w DOCOL
                  data.w TWO
                  data.w QPAIRS
                  data.w COMPILE
                  data.w BRAN
                  data.w HERE
                  data.w ZERO
                  data.w COMMA
                  data.w SWAP
                  data.w TWO
                  data.w FENDIF
                  data.w TWO
                  data.w SEMIS
;;
;;    WHILE
;;
_FWHILE             text.7 $c5, "WHILE"
                  data.w _FELSE    ; link to ELSE
                  data.w FWHILE+2    ; PFAPTR
;;
;;
;;
FWHILE:         data.w DOCOL
                  data.w FIF
                  data.w TWOPLUS
                  data.w SEMIS
;;
;;    SPACES
;;
_SPACES             text.7 $86, "SPACES"
                  data.w _FWHILE    ; link to WHILE
                  data.w SPACES+2    ; PFAPTR
;;
;;    <#
;;
_LTNUM             text.7 $82, "<#"
                  data.w _SPACES    ; link to SPACES
                  data.w LEQ+2    ; PFAPTR
;;
;;    #>
;;
_NUMGT             text.7 $82, "#>"
                  data.w _LTNUM    ; link to <#
                  data.w HASHGT+2    ; PFAPTR
;;
;;    SIGN
;;
_SIGN             text.7 $84, "SIGN"
                  data.w _NUMGT    ; link to #>
                  data.w SIGN+2    ; PFAPTR
;;
;;    #
;;
_NUM             text.7 $81, "#"
                  data.w _SIGN    ; link to SIGN
                  data.w DIG+2    ; PFAPTR
;;
;;    #S
;;
_NUMS             text.7 $82, "#S"
                  data.w _NUM    ; link to #
                  data.w HASHS+2    ; PFAPTR
;;
;;    D.R
;;
_DDOTR             text.7 $83, "D.R"
                  data.w _NUMS    ; link to #S
                  data.w DDOTR+2    ; PFAPTR
;;
;;    D.
;;
_DDOT             text.7 $82, "D."
                  data.w _DDOTR    ; link to D.R
                  data.w DDOT+2    ; PFAPTR
;;
;;    .R
;;
_DOTR             text.7 $82, ".R"
                  data.w _DDOT    ; link to D.
                  data.w DOTR+2    ; PFAPTR
;;
;;    .
;;
_DOT             text.7 $81, "."
                  data.w _DOTR    ; link to .R
                  data.w DOT+2    ; PFAPTR
;;
;;    ?
;;
_Q             text.7 $81, "?"
                  data.w _DOT    ; link to .
                  data.w Q+2    ; PFAPTR
;;
;;    LIST
;;
_FLIST             text.7 $84, "LIST"
                  data.w _Q    ; link to ?
                  data.w FLIST+2    ; PFAPTR

FLIST:         data.w DOCOL
                  data.w BASE
                  data.w AT
                  data.w SWAP
                  data.w DECIMAL
                  data.w CR
                  data.w DUP
                  data.w SCR
                  data.w STORE
                  data.w PDOTQ
                  data.b $06, "SCR # "
                  data.w DOT
                  data.w CLIT
                  data.b $10
                  data.w ZERO
                  data.w DO
                  data.w CR
                  data.w I
                  data.w THREE
                  data.w DOTR
                  data.w SPACE
                  data.w I
                  data.w SCR
                  data.w AT
                  data.w DOTLINE
                  data.w LOOP
                  data.w $ffec
                  data.w BASE
                  data.w STORE
                  data.w CR
                  data.w SEMIS
;;
;;    INDEX
;;
_INDEX             text.7 $85, "INDEX"
                  data.w _FLIST    ; link to LIST
                  data.w INDEX+2    ; PFAPTR
;;
;;
;;
INDEX:          data.w DOCOL
    			data.w CR
    			data.w ONEPLUS
    			data.w SWAP
    			data.w DO
    			data.w CR
    			data.w I
    			data.w THREE
    			data.w DOTR
    			data.w SPACE
    			data.w ZERO
    			data.w I
    			data.w DOTLINE
    			data.w QTERM
    			data.w ZBRAN
    			data.w $0004
    			data.w LEAVE
    			data.w LOOP
    			data.w $ffe6

FORMFEED:		data.w PDOTQ
    			data.b $01, ""
    			data.w SEMIS

INDEX1:			data.w DOCOL
    			data.w PFAPTR
    			data.w LFA
    			data.w AT
    			data.w DUP
    			data.w ZEQ
    			data.w QTERM
    			data.w OR
    			data.w ZEQ
    			data.w SEMIS

INDEX2:			data.w DOCOL
    			data.w DUP
    			data.w TWODUP
    			data.w PFAPTR
    			data.w ZERO
    			data.w CLIT
    			data.b $05
    			data.w DDOTR
    			data.w SPACE
    			data.w ID
    			data.w CLIT
    			data.b $0c
    			data.w ROT
    			data.w CAT
    			data.w CLIT
    			data.b $1f
    			data.w ANDD
    			data.w SUB
    			data.w SPACES
    			data.w SEMIS
;;
;;    VLIST
;;
_VLIST             text.7 $85, "VLIST"
                  data.w _INDEX    ; link to INDEX
                  data.w VLIST+2    ; PFAPTR
;;
;;
;;
VLIST:         data.w DOCOL
                  data.w BASE
                  data.w AT
                  data.w HEX
                  data.w CR
                  data.w CONTEXT
                  data.w AT
                  data.w AT
                  data.w INDEX2
                  data.w INDEX1
                  data.w ZBRAN
                  data.w $001e
                  data.w INDEX2
                  data.w INDEX1
                  data.w ZBRAN
                  data.w $0016
                  data.w INDEX2
                  data.w INDEX1
                  data.w ZBRAN
                  data.w $000e
                  data.w INDEX2
                  data.w CR
                  data.w INDEX1
                  data.w ZEQ
                  data.w ZBRAN
                  data.w $ffde
                  data.w DROP
                  data.w BASE
                  data.w STORE
                  data.w SEMIS
;;
;;    MON
;;
_MON             text.7 $83, "MON"
                  data.w _VLIST    ; link to VLIST
                  data.w MON+2    ; PFAPTR
;;
;;
;;
MON:         data.w DOCOL
                  data.w MMON
                  data.w SEMIS
;;
;;    .S
;;
_DOTS             text.7 $82, ".S"
                  data.w _MON    ; link to MON
                  data.w DOTS+2    ; PFAPTR
;;
;;
;;
DOTS:         data.w DOCOL
                  data.w SZ
                  data.w AT
                  data.w SPAT
                  data.w SUB
                  data.w TWO
                  data.w DIV_
                  data.w DUP
                  data.w ONE
                  data.w GT
                  data.w ZBRAN
                  data.w $0014
                  data.w ONE
                  data.w DO
                  data.w I
                  data.w PICK
                  data.w CR
                  data.w DOT
                  data.w LOOP
                  data.w $fff6
                  data.w SEMIS
                  data.w CR
                  data.w PDOTQ
                  data.b $06, "EMPTY "
                  data.w DROP
                  data.w SEMIS
;;
;;    C,CON
;;
_CCON             text.7 $85, "C,CON"
                  data.w _DOTS    ; link to .S
                  data.w CCON+2    ; PFAPTR
;;
;;
;;
CCON:       data.w DOCOL
    		data.w LTBUILDS
    		data.w CCOMMA
    		data.w IMMEDIATE
    		data.w DOESGT
L3375:		data.w CAT
			data.w STATE
    		data.w AT
    		data.w ZBRAN
    		data.w $000a
    		data.w LIT
    		data.w CLIT
    		data.w COMMA
			data.w CCOMMA
			data.w SEMIS
	
_DINTFLG	text.7 $c6, "INTFLG"
			data.w _CCON
			data.w DINTFLG+2
	
DINTFLG:	data.w DOES
			data.w L3375
			data.b $4a

_FINTVEC:	text.7 $c6, "INTVEC"
			data.w _DINTFLG
			data.w FINTVEC+2

FINTVEC:	data.w DOES
			data.w L3375
			data.b $5b

_FIRQVEC:	text.7 $c6, "IRQVEC"
			data.w _FINTVEC
			data.w FIRQVEC+2

FIRQVEC:	data.w DOES
			data.w L3375
			data.b $5b

_FNMIVEC:	text.7 $c6, "NMIVEC"
			data.w _FIRQVEC
			data.w FNMIVEC+2

FNMIVEC:	data.w DOES
			data.w L3375
			data.b $42

_DPA		text.7 $c2, "PA"
			data.w _FNMIVEC
			data.w DPA+2

DPA:		data.w DOES
			data.w L3375
			data.b PortA

_DPB		text.7 $c2, "PB"
			data.w _DPA
			data.w DPB+2

DPB:		data.w DOES
			data.w L3375
			data.b PortB

_DPC		text.7 $c2, "PC"
			data.w _DPB
			data.w DPC+2

DPC:		data.w DOES
			data.w L3375
			data.b PortC

_DPD		text.7 $c2, "PD"
			data.w _DPC
			data.w DPD+2

DPD:		data.w DOES
			data.w L3375
			data.b PortD

_DPE		text.7 $c2, "PE"
			data.w _DPD
			data.w DPE+2

DPE:		data.w DOES
			data.w L3375
			data.b PortE

_DPF		text.7 $c2, "PF"
			data.w _DPE
			data.w DPF+2

DPF:		data.w DOES
			data.w L3375
			data.b PortF

_DPG		text.7 $c2, "PG"
			data.w _DPF
			data.w DPG+2

DPG:		data.w DOES
			data.w L3375
			data.b PortG
	
_DIFR		text.7 $c3, "IFR"
			data.w _DPG
			data.w DIFR+2

DIFR:		data.w DOES
			data.w L3375
			data.b IFR

_DIER		text.7 $c3, "IER"
			data.w _DIFR
			data.w DIER+2

DIER:		data.w DOES
			data.w L3375
			data.b IER

_DMCR		text.7 $c3, "MCR"
			data.w _DIER
			data.w DMCR+2

DMCR:		data.w DOES
			data.w L3375
			data.b MCR

_DSCCR		text.7 $c4, "SCCR"
			data.w _DMCR
			data.w DSCCR+2

DSCCR:		data.w DOES
			data.w L3375
			data.b SCCR

_DSCSR		text.7 $c4, "SCSR"
			data.w _DSCCR
			data.w DSCSR+2

DSCSR:		data.w DOES
			data.w L3375
			data.b SCSR

;;
;;    SCDR
;;
_DSCDR       text.7 $c4, "SCDR"
    		data.w _DSCSR    ; link to C,CON
    		data.w DSCDR+2    ; PFAPTR
;;
;;
;;
DSCDR:      data.w DOES
    		data.w L3375
    		data.b $17

;;
;;    MEMTOP
;;
_MEMTOP         text.7 $86, "MEMTOP"
    			data.w _DSCDR    ; link to SCDR
    			data.w MEMTOP+2    ; PFAPTR
				data.b $db
;;
;;
;;
MEMTOP:         data.w DOCOL
    			data.w DUP
    			data.w ULIMIT
    			data.w STORE
    			data.w LIT
    			data.w $0808
    			data.w SUB
    			data.w UFIRST
    			data.w STORE
    			data.w EMPTYBUFFERS
    			data.w SEMIS
;;
;;    CASE:
;;
_CASE           text.7 $85, "CASE:"
    			data.w _MEMTOP    ; link to MEMTOP
    			data.w CASE+2     ; PFAPTR

CASE:         	data.w DOCOL
    			data.w LTBUILDS
    			data.w SMUDGE
    			data.w STORCSP
    			data.w RBRAC
    			data.w LIT
    			data.w R_FF87
    			data.w HERE
    			data.w TWOMINUS
    			data.w STORE
    			data.w LIT
    			data.w DOES
    			data.w DCSTOR
;;
;;    EEC!
;;
_EECSTOR        text.7 $84, "EEC!"
    			data.w _CASE    ; link to CASE:
    			data.w EECSTORE+2    ; PFAPTR
;;
;;    BANKC!
;;
_BANKCSTOR      text.7 $86, "BANKC!"
    			data.w _EECSTOR    ; link to EEC!
    			data.w BANKCSTOR+2    ; PFAPTR
;;
;;    BANKC@
;;
_BANKCAT        text.7 $86, "BANKC@"
    			data.w _BANKCSTOR    ; link to BANKC!
    			data.w BANKCAT+2    ; PFAPTR
;;
;;    BANKEEC!
;;
_BANKEECSTOR    text.7 $88, "BANKEEC!"
    			data.w _BANKCAT    ; link to BANKC@
    			data.w BANKEECS+2    ; PFAPTR
;;
;;    BANKEXECUTE
;;
_BANKEXECUTE    text.7 $8b, "BANKEXECUTE"
    			data.w _BANKEECSTOR    ; link to BANKEEC!
    			data.w BANKEXEC+2    ; PFAPTR

if machine == machine_65C816 {

_PSET:			text.7 $84, "PSET"
				data.w _BANKEXECUTE
				data.w PSET+2
	(*

	func pset(x, y) {

	// Calc byte to AND
	andval = 0x01				;
	loopval = xlo & 0x07
	while loopval > 0
	  lsl andval
	  loopval--
	Store it in N+x
	

	}

	0 01  0000 0000 -> 0000 0001 
	1 02  0000 0001 -> 0000 0010
	2 04  0000 0010 -> 0000 0100
	3 08  0000 0011 -> 0000 1000
	4 10  0000 0100 -> 0001 0000
	5 20  0000 0101 -> 0010 0000
	6 40  0000 0110 -> 0100 0000
	7 80  0000 0111 -> 1000 0000
	
	
	*)

	(*
	N	byte address
	N+2	byte mask
	*)
PSET:			data.w PSET+2

	;; Calculate byte value and store in N+2
				LDA 2,x			; x low byte
				AND #$07
				TAY
				INY
				LDA #0
				SEC
L3640			ROR
				DEY
				CPY #0
				BNE L3640
				STA N+2

	;; Calculate address
				REP #$20
				longa=on

				LDA 0,x			; Move x to N	
				LDY #06			; Multiply x by 64
L3658			ASL
				DEY
				CPY #0
				BNE L3658
				STA N			; Temp

				LDA 0,x			; Multiply by 16
				LDY #04
L3666			ASL
				DEY
				CPY #0
				BNE L3666

				CLC
				ADC N			; And add together to get * 80
				STA N

				LDA 2,x
				LSR
				LSR
				LSR
				ADC N
	
				STX XSAVE
				REP #$30
				longi=on
				TAX

				SEP #$20
				longa=off
	
				LDA $fd0000,x
				ORA N+2
				STA $fd0000,x

				SEP #$30
				longi=off
				LDX XSAVE
				JMP POPTWO

PCLR:		
}
	
;;
;;    FMTRK
;;
_FMTRK          text.7 $85, "FMTRK"
if machine == machine_65C816 {
    			data.w _PSET           ; link to PSET
} else {
if machine == machine_T20K {
    			data.w _BANKAT         ; link to BANK@, in the kernel ROM
} else {
    			data.w _BANKEXECUTE    ; link to BANKEXECUTE
}
}
    			data.w FMTRK+2         ; PFAPTR
;;
;;
;;
FMTRK:         	data.w FMTRK+2
    			TXA 
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
FM3658 			BIT DSK_CTL
    			BVS FM3658
    			STA DSK_DATA
    			DEX 
    			BNE FM3658
.L3663 			BIT DSK_CTL
    			BVS .L3663
    			STA DSK_DATA
    			LDX #$02
    			LDA #$f5
R_D6C2: 	BIT DSK_CTL
    			BVS R_D6C2
    			STA DSK_DATA
    			DEX 
    			BNE $d6c2
R_D6CD: 	BIT DSK_CTL
    			BVS R_D6CD
    			STA DSK_DATA
    			LDA #$fe
R_D6D7: 	BIT DSK_CTL
    			BVS R_D6D7
    			STA DSK_DATA
    			LDA N
R_D6E1: 	BIT DSK_CTL
    			BVS R_D6E1
    			STA DSK_DATA
    			LDA N+2
R_D6EB: 	BIT DSK_CTL
    			BVS R_D6EB
    			STA DSK_DATA
R_D6F3: 	BIT DSK_CTL
    			BVS R_D6F3
    			STY DSK_DATA
    			LDA #$01
R_D6FD: 	BIT DSK_CTL
    			BVS R_D6FD
    			STA DSK_DATA
    			LDA #$f7
R_D707: 	BIT DSK_CTL
    			BVS R_D707
    			STA DSK_DATA
    			LDX #$15
    			LDA #$4e
R_D713: 	BIT DSK_CTL
    			BVS R_D713
    			STA DSK_DATA
    			DEX 
    			BNE $d713
R_D71E: 	BIT DSK_CTL
    			BVS R_D71E
    			STA DSK_DATA
    			LDX #$0b
    			LDA #$00
R_D72A: 	BIT DSK_CTL
    			BVS R_D72A
    			STA DSK_DATA
    			DEX 
    			BNE $d72a
R_D735: 	BIT DSK_CTL
    			BVS R_D735
    			STA DSK_DATA
    			LDX #$02
    			LDA #$f5
R_D741: 	BIT DSK_CTL
    			BVS R_D741
    			STA DSK_DATA
    			DEX 
    			BNE $d741
R_D74C: 	BIT DSK_CTL
    			BVS R_D74C
    			STA DSK_DATA
    			LDX #$ff
    			LDA #$fb
R_D758: 	BIT DSK_CTL
    			BVS R_D758
    			STA DSK_DATA
    			LDA #$20
R_D762: 	BIT DSK_CTL
    			BVS R_D762
    			STA DSK_DATA
    			DEX 
    			BNE $d762
R_D76D: 	BIT DSK_CTL
    			BVS R_D76D
    			STA DSK_DATA
    			LDA #$f7
R_D777: 	BIT DSK_CTL
    			BVS R_D777
    			STA DSK_DATA
    			LDX #$35
    			LDA #$4e
R_D783: 	BIT DSK_CTL
    			BVS R_D783
    			STA DSK_DATA
    			DEX 
    			BNE $d783
R_D78E: 	BIT DSK_CTL
    			BVS R_D78E
    			STA DSK_DATA
    			INY 
    			CPY #$11
    			BEQ R_D7B2
R_D79B: 	BIT DSK_CTL
    			BVS R_D79B
    			STX DSK_DATA
    			LDX #$09
    			LDA #$00
R_D7A7: 	BIT DSK_CTL
    			BVS R_D7A7
    			STA DSK_DATA
    			JMP FM3658
R_D7B2: 	LDY #$4e
R_D7B4: 	BIT DSK_CTL
    			BVS R_D7B4
    			BPL R_D7C1
    			STY DSK_DATA
    			JMP $d7b4
R_D7C1: 	PLA 
    			TAX 
    			JMP POPTWO
;;
;;    FORMAT
;;
_FORMAT         text.7 $86, "FORMAT"
    			data.w _FMTRK      ; link to FMTRK
    			data.w FORMAT+2    ; PFAPTR
;;
;;
;;
FORMAT:         data.w DOCOL
    			data.w TWO
    			data.w MUL
                  data.w SWAP
                  data.w ZERO
                  data.w DO
                  data.w DUP
                  data.w ONEPLUS
                  data.w SELECT
                  data.w R
                  data.w SEEK
                  data.w ONE
                  data.w R
                  data.w FMTRK
                  data.w DUP
                  data.w SELECT
                  data.w ZERO
                  data.w R
                  data.w FMTRK
                  data.w LOOP
                  data.w $ffe4
                  data.w DROP
                  data.w SEMIS
;;
;;    ;DUMP
;;
_DUMP             text.7 $85, ";DUMP"
                  data.w _FORMAT    ; link to FORMAT
                  data.w DUMP+2     ; PFAPTR
;;
;;
;;
DUMP:             data.w DOCOL
                  data.w PDOTQ
                  data.b $01, ";"
                  data.w KHZ
                  data.w AT
                  data.w GTR
                  data.w ZERO
                  data.w KHZ
                  data.w STORE
                  data.w TWODUP
                  data.w CODE2
                  data.w CODE1
                  data.w BOUNDS
                  data.w DO
                  data.w R
                  data.w CAT
                  data.w CODE2
                  data.w LOOP
                  data.w $fff8
                  data.w KHZ
                  data.w AT
                  data.w CODE1
                  data.w CR
                  data.w RFROM
                  data.w KHZ
                  data.w STORE
                  data.w SEMIS
;;
;;    ADMP
;;
_ADMP             text.7 $84, "ADMP"
                  data.w _DUMP     ; link to ;DUMP
                  data.w ADMP+2    ; PFAPTR

ADMP:             data.w DOCOL
                  data.w CR
                  data.w ONE
                  data.w GTR
                  data.w TWODUP
                  data.w ONEPLUS
                  data.w SWAP
                  data.w SUB
                  data.w DDUP
                  data.w ZBRAN
                  data.w $001f
                  data.w CLIT
                  data.b $18
                  data.w MIN
                  data.w GTR
                  data.w OVER
                  data.w R
                  data.w DUMP
                  data.w SWAP
                  data.w RFROM
                  data.w PLUS
                  data.w SWAP
                  data.w RFROM
                  data.w ONEPLUS
                  data.w BRAN
                  data.w $ffd5
                  data.w RFROM
                  data.w PDOTQ
                  data.b $01, ";"
                  data.w ZERO
                  data.w CODE2
                  data.w DUP
                  data.w CODE1
                  data.w CODE1
                  data.w CR
                  data.w TWODROP
                  data.w SEMIS
;;
;;
;;
CODE1:         	data.w CODE1+2
    			LDA 1,X
    			JSR L3906
    			JMP CODE2+2
;;
;;
;;
CODE2:         	data.w CODE2+2
    			LDA 0,X
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
    			ADC USER_BASE+$52
    			STA USER_BASE+$52
    			BCC R_D8BB
    			INC USER_BASE+$53
R_D8BB: 	PLA 
    			AND #$0f
L3922:			CLC 
    			ADC #$30
    			CMP #$3a
    			BCC R_D8C7
    			ADC #$06
R_D8C7: 	JMP L506

NAMES:    		data.b "M REARDON R DUMSE", $00
CRIGHT:   		data.b "COPYRIGHT 1983 ROCKWELL "
	
;;
;;    N
;;
_N 	            text.7 $81, "N"
    			data.w USER_BASE+$32    ; link to ADMP ToDo:
    			data.w FN+2      ; PFAPTR

FN:        		data.w DOCON
    			data.w N
;;
;;    IP
;;
_IP             text.7 $82, "IP"
    			data.w _N      ; link to N
    			data.w FIP+2    ; PFAPTR

FIP:         	data.w DOCON
    			data.w IP
;;
;;    W
;;
_W             	text.7 $81, "W"
    			data.w _IP    ; link to IP
    			data.w FW+2    ; PFAPTR
;;
;;
;;
FW:         		data.w DOCON
    			data.w W
;;
;;    UP
;;
_UP             text.7 $82, "UP"
    			data.w _W   	  ; link to W
    			data.w FUP+2      ; PFAPTR
;;
;;
;;
FUP:         	data.w DOCON
    			data.w UP
;;
;;    XSAVE
;;
_XSAVE          text.7 $85, "XSAVE"
    			data.w _UP    ; link to UP
    			data.w DXSAVE+2    ; PFAPTR
;;
;;
;;
DXSAVE:        	data.w DOCON
    			data.w XSAVE
;;
;;    NEXT
;;
_NEXT           text.7 $84, "NEXT"
    			data.w _XSAVE    ; link to XSAVE
    			data.w DNEXT+2    ; PFAPTR
;;
;;
;;
DNEXT:         	data.w DOCON
    			data.w NEXT
;;
;;    PUSH
;;
_PUSH           text.7 $84, "PUSH"
                data.w _NEXT    ; link to NEXT
                data.w DPUSH+2    ; PFAPTR

DPUSH:          data.w DOCON
                data.w PUSH
;;
;;    PUT
;;
_PUT            text.7 $83, "PUT"
    			data.w _PUSH    ; link to PUSH
    			data.w DPUT+2    ; PFAPTR

DPUT:           data.w DOCON
    			data.w PUT_
;;
;;    POP
;;
_POP            text.7 $83, "POP"
    			data.w _PUT    ; link to PUT
    			data.w DPOP+2    ; PFAPTR
;;
;;
;;
DPOP:         	data.w DOCON
    			data.w POP
;;
;;    POPTWO
;;
_POPTWO         text.7 $86, "POPTWO"
                data.w _POP    ; link to POP
                data.w DPOPTWO+2    ; PFAPTR
;;
;;
;;
DPOPTWO:        data.w DOCON
                data.w POPTWO
;;
;;    PUSH0A
;;
_DPUSH0A        text.7 $86, "PUSH0A"
                data.w _POPTWO    ; link to POPTWO
                data.w DPUSH0A+2    ; PFAPTR

DPUSH0A:        data.w DOCON
                data.w PUSH0A
;;
;;    PUT0A
;;
_PUT0A          text.7 $85, "PUT0A"
                data.w _DPUSH0A    ; link to PUSH0A
                data.w DPUT0A+2    ; PFAPTR

DPUT0A:         data.w DOCON
                data.w L929
;;
;;    BINARY
;;
_BINARY           	text.7 $86, "BINARY"
    				data.w _PUT0A    ; link to PUT0A
    				data.w DBINARY+2    ; PFAPTR

DBINARY:         	data.w DOCON
    				data.w BINARY
;;
;;    SETUP
;;
_SETUP       		text.7 $85, "SETUP"
    				data.w _BINARY    ; link to BINARY
    				data.w DSETUP+2    ; PFAPTR

DSETUP:        		data.w DOCON
    				data.w SETUP
	
UNK1:         		data.b $09, $09, $05, $15, $15, $01, $11, $80
					data.b $09, $80, $0d, $1d, $19, $80, $80, $80
    				data.b $80, $00, $04, $14, $14, $80, $80, $80
					data.b $80, $80, $0c, $1c, $1c, $80, $80, $2c
;;
;;    SETMODE - assembler
;;
SETMODE:         	data.w CAT
    				data.w MODE
    				data.w STORE
    				data.w SEMIS
;;
;;    .A
;;
_DOTA           text.7 $82, ".A"
    			data.w _SETUP    ; link to SETUP
    			data.w DOTA+2    ; PFAPTR

DOTA:			data.w DOES
    			data.w SETMODE
				data.b $00
;;
;;    #
;; 
_DHASH:			text.7 $81, "#"
				data.w _DOTA
				data.w DHASH+2

DHASH:			data.w DOES
				data.w SETMODE
				data.b $01

;;
;;    MEM
;; 
_MEM:			text.7 $83, "MEM"
				data.w _DHASH
				data.w MEM+2

MEM:			data.w DOES
				data.w SETMODE
				data.b $02

;;
;;    ,X
;; 
_COMMAX:		text.7 $82, ",X"
				data.w _MEM
				data.w COMMAX+2

COMMAX:			data.w DOES
				data.w SETMODE
				data.b $03

;;
;;    ,Y
;; 
_COMMAY			text.7 $82, ",Y"
				data.w _COMMAX
				data.w COMMAY+2

COMMAY:			data.w DOES
				data.w SETMODE
				data.b $04

;;
;;    X)
;;	
_XBRAC:			text.7 $82, "X)"
				data.w _COMMAY
				data.w XBRAC+2

XBRAC:			data.w DOES
				data.w SETMODE
				data.b $05

;;
;;    )Y
;; 
_BRACY			text.7 $82, ")Y"
				data.w _XBRAC
				data.w BRACY+2

BRACY:			data.w DOES
				data.w SETMODE
				data.b $06
;;
;;    )
;; 
_MRBRAC:		text.7 $81, ")"
				data.w _BRACY
				data.w MRBRAC+2

MRBRAC:			data.w DOES
				data.w SETMODE
				data.b $0f

;;
;;    TOP
;;
_DTOP:			text.7 $83, "TOP"
				data.w _MRBRAC
				data.w DTOP+2

DTOP:			data.w DOCOL	
    			data.w COMMAX 	; ToDo: UNK4
    			data.w ZERO
    			data.w SEMIS
;;
;;    SEC
;;
_DSEC            text.7 $83, "SEC"
    			data.w _DTOP    ; link to .A
    			data.w DSEC+2    ; PFAPTR

DSEC:         	data.w DOCOL
    			data.w COMMAX	; ToDo: UNK4
    			data.w TWO
    			data.w SEMIS

;;
;;    RP)
;;
_RP:         	text.7 $83, "RP)"
                data.w _DSEC
                data.w RP+2

RP:				data.w DOCOL
    			data.w COMMAX	; ToDo: UNK4
				data.w LIT
    			data.w $01
    			data.w SEMIS

;;
;;
;;
UNK9:         	data.w DOCOL
    			data.w ZBRAN
    			data.w $0018
    			data.w MODE
    			data.w CAT
    			data.w CLIT
    			data.b $08
    			data.w ANDD
    			data.w ZEQ
    			data.w ZBRAN
    			data.w $0009
    			data.w CLIT
    			data.b $08
    			data.w MODE
    			data.w PSTORE
    			data.w ONE
    			data.w MODE
    			data.w CAT
    			data.w CLIT
    			data.b $0f
    			data.w ANDD
    			data.w DDUP
    			data.w ZBRAN
    			data.w $000e
    			data.w ZERO
    			data.w DO
    			data.w DUP
    			data.w PLUS
    			data.w LOOP
    			data.w $fffa		; branch offset
    			data.w OVER
    			data.w ONEPLUS
    			data.w AT
    			data.w ANDD
    			data.w ZEQ
    			data.w SEMIS
	
IMPLIED		    data.w CAT
                data.w CCOMMA
                data.w MEM
    			data.w SEMIS
	
IMPLIED2:		data.w DUP
    			data.w ONEPLUS
    			data.w CAT
    			data.w CLIT
    			data.b $80
    			data.w ANDD
    			data.w ZBRAN
    			data.w $0009
    			data.w CLIT
    			data.b $10
    			data.w MODE
    			data.w PSTORE
    			data.w OVER
    			data.w LIT
    			data.w $ff00
    			data.w ANDD
    			data.w UNK9
    			data.w UNK9
    			data.w ZBRAN
    			data.w $000e
    			data.w MEM
    			data.w CR
    			data.w LATEST
    			data.w ID
    			data.w THREE
    			data.w ERR
    			data.w CAT
    			data.w MODE
    			data.w CAT
    			data.w LIT
    			data.w UNK1
    			data.w PLUS
    			data.w CAT
    			data.w PLUS
    			data.w CCOMMA
    			data.w MODE
    			data.w CAT
    			data.w CLIT
    			data.b $07
    			data.w ANDD
    			data.w ZBRAN
    			data.w $001c
    			data.w MODE
    			data.w CAT
    			data.w CLIT
    			data.b $0f
    			data.w ANDD
    			data.w CLIT
    			data.b $07
    			data.w LESS
    			data.w ZBRAN
    			data.w $0008
    			data.w CCOMMA
    			data.w BRAN
    			data.w $0004
    			data.w COMMA
    			data.w MEM
    			data.w SEMIS
;;
;;    BRK,
;;
_BRKC         	text.7 $84, "BRK,"
    			data.w _RP    ; link to SEC
    			data.w BRKC+2    ; PFAPTR

BRKC:         	data.w DOES
				data.w IMPLIED
				data.b $00

;; 
;;    CLC,
;; 	
_CLCC			text.7 $84, "CLC,"
				data.w _BRKC	; link to BRK,
				data.w	CLCC+2 

CLCC:			data.w DOES
				data.w IMPLIED
				data.b $18

;;
;;    CLD,
;; 
_CLDC:			text.7 $84, "CLD,"
				data.w _CLCC					; link to CLCC
				data.w CLDC+2

CLDC:			data.w DOES
    			data.w IMPLIED
				data.b $d8

;;
;;    CLI,
;; 
_CLIC:			text.7 $84, "CLI,"
				data.w _CLDC					; link to CLDC
				data.w CLIC+2

CLIC:			data.w DOES
    			data.w IMPLIED
				data.b $58

;;
;;    CLV,
;; 
_CLVC:			text.7 $84, "CLV,"
				data.w _CLIC
				data.w CLVC+2
	
CLVC:			data.w DOES
				data.w IMPLIED
				data.b $b8

;;
;;    DEC,
;; 
_DEXC:			text.7 $84, "DEX,"
				data.w _CLVC
				data.w DEXC+2
	
DEXC:			data.w DOES
				data.w IMPLIED
				data.b $ca

;;
;;    DEY,
;; 
_DEYC:			text.7 $84, "DEY,"
				data.w _DEXC
				data.w DEYC+2
	
DEYC:			data.w DOES
				data.w IMPLIED
				data.b $88

;;
;;    INX,
;; 
_INXC:			text.7 $84, "INX,"
				data.w _DEYC
				data.w INXC+2

INXC:			data.w DOES
				data.w IMPLIED
				data.b $e8

;;
;;    INY,
;; 
_INYC:			text.7 $84, "INY,"
				data.w _INXC
				data.w INYC+2

INYC:			data.w DOES
				data.w IMPLIED
				data.b $c8

;;
;;    NOP,
;;  
_NOPC:			text.7 $84, "NOP,"
				data.w _INYC
				data.w NOPC+2

NOPC:			data.w DOES
				data.w IMPLIED
				data.b $ea

;;
;;    PHA,
;; 
_PHAC:			text.7 $84, "PHA,"
				data.w _NOPC
				data.w PHAC+2

PHAC:			data.w DOES
				data.w IMPLIED
				data.b $48
;;
;;    PHP,
;;
_PHPC:			text.7 $84, "PHP,"
				data.w _PHAC
				data.w PHPC+2

PHPC:			data.w DOES
				data.w IMPLIED
				data.b $08

;;
;;    PLA,
;;
_PLAC:			text.7 $84, "PLA,"
				data.w _PHPC
				data.w PLAC+2

PLAC:			data.w DOES
				data.w IMPLIED
				data.b $68

;;
;;    PLP,
;;
_PLPC:			text.7 $84, "PLP,"
				data.w _PLAC
				data.w PLPC+2

PLPC:			data.w DOES
				data.w IMPLIED
				data.b $28
;;
;;    RTI,
;;
_RTIC:			text.7 $84, "RTI,"
				data.w _PLPC
				data.w RTIC+2

RTIC:			data.w DOES
				data.w IMPLIED
				data.b $40
;;
;;    RTS,
;; 
_RTSC:			text.7 $84, "RTS,"
				data.w _RTIC
				data.w RTSC+2

RTSC:			data.w DOES
				data.w IMPLIED
				data.b $60
;;
;;    SEC,
;;
_SECC:			text.7 $84, "SEC,"
				data.w _RTSC
				data.w SECC+2

SECC:			data.w DOES
				data.w IMPLIED
				data.b $38
;;
;;    SED,
;;
_SEDC:			text.7 $84, "SED,"
				data.w _SECC
				data.w SEDC+2

SEDC:			data.w DOES
				data.w IMPLIED
				data.b $f8
;;
;;    SEI,
;;
_SEIC:			text.7 $84, "SEI,"
				data.w _SEDC
				data.w SEIC+2

SEIC:			data.w DOES
				data.w IMPLIED
				data.b $78
;;
;;    TAX,
;;
_TAXC:			text.7 $84, "TAX,"
				data.w _SEIC
				data.w TAXC+2

TAXC:			data.w DOES
				data.w IMPLIED
				data.b $aa
;;
;;    TAY,
;;
_TAYC:			text.7 $84, "TAY,"
				data.w _TAXC
				data.w TAYC+2

TAYC:			data.w DOES
				data.w IMPLIED
				data.b $a8
;;
;;    TSX,
;;
_TSXC:			text.7 $84, "TSX,"
				data.w _TAYC
				data.w TSXC+2

TSXC:			data.w DOES
				data.w IMPLIED
				data.b $ba
;;
;;    TXA,
;;
_TXAC:			text.7 $84, "TXA,"
				data.w _TSXC
				data.w TXAC+2

TXAC:			data.w DOES
				data.w IMPLIED
				data.b $8a
;;
;;    TYA,
;;
_TYAC:			text.7 $84, "TYA,"
				data.w _TXAC
				data.w TYAC+2

TYAC:			data.w DOES
				data.w IMPLIED
				data.b $98
;;
;;    TXS,
;;
_TXSC:			text.7 $84, "TXS,"
				data.w _TYAC
				data.w TXSC+2

TXSC:			data.w DOES
				data.w IMPLIED
				data.b $9a
;;
;;    ADC,
;;
_ADCC:		text.7 $84, "ADC,"
			data.w _TXSC
			data.w ADCC+2

ADCC:		data.w DOES
			data.w IMPLIED2
			data.b $60, $6e, $1c

;;
;;    AND,
;;
_ANDC:		text.7 $84, "AND,"
			data.w _ADCC
			data.w ANDC+2

ANDC:		data.w DOES
			data.w IMPLIED2
			data.b $20, $6e, $1c

;;
;;    CMP,
;;
_CMPC:		text.7 $84, "CMP,"
			data.w _ANDC
			data.w CMPC+2

CMPC:		data.w DOES
			data.w IMPLIED2
			data.b $c0, $6e, $1c

	;;
	;;    EOR,
	;;
_EORC:		text.7 $84, "EOR,"
			data.w _CMPC
			data.w EORC+2

EORC:		data.w DOES
			data.w IMPLIED2
			data.b $40, $6e, $1c

	;;
	;;    LDA,
	;;
_LDAC:		text.7 $84, "LDA,"
			data.w _EORC
			data.w LDAC+2

LDAC:		data.w DOES
			data.w IMPLIED2
			data.b $a0, $6e, $1c

	;;
	;;    ORA,
	;;
_ORAC:		text.7 $84, "ORA,"
			data.w _LDAC
			data.w ORAC+2

ORAC:		data.w DOES
			data.w IMPLIED2
			data.b $00, $6e, $1c

	;;
	;;    SBC,
	;;
_SBCC:		text.7 $84, "SBC,"
			data.w _ORAC
			data.w SBCC+2

SBCC:		data.w DOES
			data.w IMPLIED2
			data.b $e0, $6e, $1c

	;;
	;;    STA,
	;;
_STAC:		text.7 $84, "STA,"
			data.w _SBCC
			data.w STAC+2

STAC:		data.w DOES
			data.w IMPLIED2
			data.b $80, $6c, $1c

	;;
	;;    ASL,
	;;
_ASLC:		text.7 $84, "ASL,"
			data.w _STAC
			data.w ASLC+2

ASLC:		data.w DOES
			data.w IMPLIED2
			data.b $01, $0d, $0d

	;;
	;;    DEC,
	;;
_DECC:		text.7 $84, "DEC,"
			data.w _ASLC
			data.w DECC+2

DECC:		data.w DOES
			data.w IMPLIED2
			data.b $c1, $0c, $0c

	;;
	;;    INC,
	;;
_INCC:		text.7 $84, "INC,"
			data.w _DECC
			data.w INCC+2

INCC:		data.w DOES
			data.w IMPLIED2
			data.b $e1, $0c, $0c

	;;
	;;    LSR,
	;;
_LSRC:		text.7 $84, "LSR,"
			data.w _INCC
			data.w LSRC+2

LSRC:		data.w DOES
			data.w IMPLIED2
			data.b $41, $0d, $0d

	;;
	;;    ROL,
	;;
_ROLC:		text.7 $84, "ROL,"
			data.w _LSRC
			data.w ROLC+2

ROLC:		data.w DOES
			data.w IMPLIED2
			data.b $21, $0d, $0d

	;;
	;;    ROR,
	;;
_RORC:		text.7 $84, "ROR,"
			data.w _ROLC
			data.w RORC+2

RORC:		data.w DOES
			data.w IMPLIED2
			data.b $61, $0d, $0d

	;;
	;;    STX,
	;;
_STXC:		text.7 $84, "STX,"
			data.w _RORC
			data.w STXC+2

STXC:		data.w DOES
			data.w IMPLIED2
			data.b $81, $14, $04

	;;
	;;    CPX,
	;;
_CPXC:		text.7 $84, "CPX,"
			data.w _STXC
			data.w CPXC+2

CPXC:		data.w DOES
			data.w IMPLIED2
			data.b $e0, $86, $04

	;;
	;;    CPY,
	;;
_CPYC:		text.7 $84, "CPY,"
			data.w _CPXC
			data.w CPYC+2

CPYC:		data.w DOES
			data.w IMPLIED2
			data.b $c0, $86, $04

	;;
	;;    LDX,
	;;
_LDXC:		text.7 $84, "LDX,"
			data.w _CPYC
			data.w LDXC+2

LDXC:		data.w DOES
			data.w IMPLIED2
			data.b $a2, $96, $14

	;;
	;;    LDY,
	;;
_LDYC:		text.7 $84, "LDY,"
			data.w _LDXC
			data.w LDYC+2

LDYC:		data.w DOES
			data.w IMPLIED2
			data.b $a0, $8e, $0c

	;;
	;;    STY,
	;;
_STYC:		text.7 $84, "STY,"
			data.w _LDYC
			data.w STYC+2

STYC:		data.w DOES
			data.w IMPLIED2
			data.b $80, $8c, $04

	;;
	;;    JSR,
	;;
_JSRC:		text.7 $84, "JSR,"
			data.w _STYC
			data.w JSRC+2

JSRC:		data.w DOES
			data.w IMPLIED2
			data.b $14, $80, $04

	;;
	;;    JMP,
	;;
_JMPC:		text.7 $84, "JMP,"
			data.w _JSRC
			data.w JMPC+2

JMPC:		data.w DOES
			data.w IMPLIED2
			data.b $40, $80, $84

	;;
	;;    BIT,
	;; 
_BITC:		text.7 $84, "BIT,"
			data.w _JMPC
			data.w BITC+2

BITC:		data.w DOES
			data.w IMPLIED2
			data.b $20, $84, $04

;;
;;    SMB,
;;
_SMBC           text.7 $84, "SMB,"
    			data.w _BITC    ; link to BIT,
    			data.w SMBC+2   ; PFAPTR

SMBC:         	data.w DOCOL
    			data.w MODE
    			data.w AT
    			data.w MEM
    			data.w TWO
    			data.w EQUAL
    			data.w ZBRAN
    			data.w $001b
    			data.w CLIT
    			data.b $87
    			data.w SWAP
    			data.w CLIT
    			data.b $07
    			data.w ANDD
    			data.w CLIT
    			data.b $10
    			data.w MUL
    			data.w OR
    			data.w CCOMMA
    			data.w CCOMMA
    			data.w BRAN
    			data.w $0006
    			data.w THREE
    			data.w ERR
    			data.w SEMIS
;;
;;    RMB,
;;
_RMBC         	text.7 $84, "RMB,"
    			data.w _SMBC    ; link to SMB,
    			data.w RMBC+2 	; PFAPTR

RMBC: 	        data.w DOCOL
    			data.w MODE
    			data.w AT
    			data.w MEM
    			data.w TWO
    			data.w EQUAL
    			data.w ZBRAN
    			data.w $ffe3
    			data.w CLIT
    			data.b $07
    			data.w BRAN
    			data.w $ffc6

_BITSET:		text.7 $86, "BITSET"
				data.w _RMBC				; link to
				data.w BITSET+2				; PFAPTR

BITSET:			data.w DOCOL
				data.w MODE
				data.w AT
				data.w TWO
				data.w EQUAL
				data.w ZBRAN
				data.w $ffc3
				data.w CLIT
				data.b $0f	
    			data.w SWAP
    			data.w CLIT
    			data.b $07
    			data.w ANDD
    			data.w CLIT
    			data.b $10
    			data.w MUL
    			data.w OR
    			data.w CCOMMA
    			data.w SEMIS
;;
;;    BITCLR
;;
_BITCLR         text.7 $86, "BITCLR"
    			data.w _BITSET    ; link to RMB,
    			data.w BITCLR+2    ; PFAPTR

BITCLR:         data.w DOCOL
    			data.w MODE
    			data.w AT
    			data.w TWO
    			data.w EQUAL
    			data.w ZBRAN
    			data.w $ff95
    			data.w CLIT
    			data.b $8f
    			data.w BRAN
    			data.w $ffd0

_BEGINC:		text.7 $86,"BEGIN,"
				data.w _BITCLR
				data.w BEGINC+2

BEGINC:			data.w DOCOL
				data.w HERE
				data.w ONE
				data.w SEMIS

;;
;;    UNTIL,
;;
_UNTILC        	text.7 $86, "UNTIL,"
                data.w _BEGINC    ; link to BEGIN
                data.w UNTILC+2    ; PFAPTR
;;
;;
;;
UNTILC:         data.w DOCOL
    			data.w GTR
    			data.w ONE
    			data.w QPAIRS
    			data.w RFROM
    			data.w CCOMMA
    			data.w HERE
    			data.w ONEPLUS
    			data.w SUB
    			data.w CCOMMA
    			data.w SEMIS
;;
;;    WHILE,
;;
_WHILEC         text.7 $86, "WHILE,"
                data.w _UNTILC    ; link to UNTIL,
                data.w WHILEC+2    ; PFAPTR
;;
;;
;;
WHILEC:         data.w DOCOL
    			data.w CCOMMA
    			data.w HERE
    			data.w ZERO
    			data.w CCOMMA
    			data.w THREE
    			data.w SEMIS
;;
;;    AGAIN,
;;
_AGAINC         text.7 $86, "AGAIN,"
    			data.w _WHILEC    ; link to WHILE,
    			data.w AGAINC+2    ; PFAPTR

AGAINC:        	data.w DOCOL
    			data.w ONE
    			data.w QPAIRS
    			data.w JMPC
    			data.w SEMIS
;;
;;    REPEAT,
;;
_REPEATC        text.7 $87, "REPEAT,"
    			data.w _AGAINC    ; link to AGAIN,
    			data.w REPEATC+2    ; PFAPTR

REPEATC:        data.w DOCOL
    			data.w THREE
    			data.w QPAIRS
    			data.w GTR
    			data.w AGAINC
    			data.w RFROM
    			data.w HERE
    			data.w OVER
    			data.w ONEPLUS
    			data.w SUB
    			data.w SWAP
    			data.w CSTOR
    			data.w SEMIS
;;
;;    IF,
;;
_IFC            text.7 $83, "IF,"
    			data.w _REPEATC    ; link to REPEAT,
    			data.w IFC+2    ; PFAPTR

IFC:         	data.w DOCOL
    			data.w CCOMMA
    			data.w HERE
    			data.w ZERO
    			data.w CCOMMA
    			data.w TWO
    			data.w SEMIS
;;
;;    ENDIF,
;;
_ENDIFC         text.7 $86, "ENDIF,"
    			data.w _IFC    ; link to IF,
    			data.w ENDIFC+2    ; PFAPTR
;;
;;
;;
ENDIFC:         data.w DOCOL
    			data.w TWO
    			data.w QPAIRS
    			data.w HERE
    			data.w OVER
    			data.w CAT
    			data.w ZBRAN
    			data.w $0008
    			data.w SWAP
    			data.w STORE
    			data.w SEMIS
    			data.w OVER
    			data.w ONEPLUS
    			data.w SUB
    			data.w SWAP
    			data.w CSTOR
    			data.w SEMIS
;;
;;    THEN,
;;
_THENC          text.7 $85, "THEN,"
                data.w _ENDIFC    ; link to ENDIF,
                data.w THENC+2     ; PFAPTR
;;
;;
;;
THENC:         	data.w DOCOL
    			data.w ENDIFC
    			data.w SEMIS
;;
;;    ELSE,
;;
_ELSEC          text.7 $85, "ELSE,"
    			data.w _THENC      ; link to THEN,
    			data.w ELSEC+2    ; PFAPTR

ELSEC:          data.w DOCOL
    			data.w TWO
    			data.w QPAIRS
    			data.w HERE
    			data.w ONEPLUS
    			data.w ONE
    			data.w JMPC
    			data.w SWAP
    			data.w HERE
    			data.w OVER
    			data.w ONEPLUS
    			data.w SUB
    			data.w SWAP
    			data.w CSTOR
    			data.w TWO
    			data.w SEMIS
;;
;;    NOT
;;
_NOTC           text.7 $83, "NOT"
    			data.w _ELSEC    ; link to ELSE,
    			data.w NOT+2     ; PFAPTR

NOT:         	data.w DOCOL
    			data.w BL
    			data.w XOR
    			data.w SEMIS
;;
;;    CS
;;
_CS             text.7 $82, "CS"
    			data.w _NOTC    ; link to NOT
    			data.w CS+2    ; PFAPTR

CS:         	data.w DOCON
    			data.w $0090
;;
;;    VS
;;
_VS             text.7 $82, "VS"
    			data.w _CS    ; link to CS
    			data.w VS+2    ; PFAPTR

VS:         	data.w DOCON
    			data.w $0050
;;
;;    0=
;;
_ZEQC           text.7 $82, "0="
    			data.w _VS    ; link to VS
    			data.w ZEQC+2    ; PFAPTR

ZEQC:         	data.w DOCON
    			data.w $00d0
;;
;;    0<
;;
_ZLESS          text.7 $82, "0<"
    			data.w _ZEQC    ; link to 0=
    			data.w ZLESS+2    ; PFAPTR

ZLESS:         	data.w DOCON
    			data.w $0010

;;
;;    END-CODE
;;
_ENDCODE        text.7 $c8, "END-CODE"
    			data.w _ZLESS    ; link to 0<
    			data.w ENDCODE+2    ; PFAPTR

ENDCODE:        data.w DOCOL
    			data.w CURRENT
    			data.w AT
    			data.w CONTEXT
    			data.w STORE
    			data.w QEXEC
    			data.w QCSP
    			data.w SMUDGE
    			data.w SEMIS
;;
;;    TASK
;;
_TASK           text.7 $84, "TASK"
    			data.w _ADMP    ; link to END-CODE
    			data.w TASK+2    ; PFAPTR

TASK:         	data.w DOCOL
    			data.w SEMIS

PADDINGD:       data.b $ff, $ff
                data.b $ff

if machine == machine_T20K {
;;
;;	Headers of the words the T20K kernel adds. The development ROM is full,
;;	so they go in the space the kernel leaves in its own ROM.
;;
	section "extension"

    org := EXT_BASE
;;
;;    BANK!
;;
_BANKSTOR       text.7 $85, "BANK!"
    			data.w _BANKEXECUTE    ; link to BANKEXECUTE
    			data.w BANKSTOR+2    ; PFAPTR
;;
;;    BANK@
;;
_BANKAT         text.7 $85, "BANK@"
    			data.w _BANKSTOR    ; link to BANK!
    			data.w BANKAT+2    ; PFAPTR

	errorif org > EXT_BASE+ext_size, "extension headers overflow: raise ext_size"
}
