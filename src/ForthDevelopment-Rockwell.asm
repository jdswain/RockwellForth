        cpu := "R65C02"


        org := $c000

        KPortA := $0000
        KPortB := $0001
        KPortE := $0004
        KPortF := $0005
        KPortG := $0006
        KClearIntFlag := $0010
        KIFR := $0011
        KIER := $0012
        KMCR := $0014
        KSCCR := $0015
        KSCSR := $0016
        KSRDR := $0017
        KLCACLR := $0018
        KUCA := $0019
        KLCA := $001a
        KLCBCLR := $001c
        KUCB := $001d
        KLCB := $001e
        KIRQSOFT := $0040
        KNMISOFT := $0042
        KUP := $0048
        KINTFLAG := $004a
        KWM1 := $004b
        KW := $004c
        KWP1 := $004d
        KIP := $004e
        KIPP1 := $004f
        KNM1 := $0050
        KN := $0051
        KNP1 := $0052
        KNP2 := $0053
        KNP3 := $0054
        KNP4 := $0055
        KNP5 := $0056
        KNP6 := $0057
        KNP7 := $0058
        KXSAVE := $0059
        KINTVEC := $005b
        KINTVECP1 := $005c
        KTIB := $0300
        KRO := $0302
        KSO := $0304
        KUC_L := $0306
        KUPAD := $0308
        KUR_W := $030a
        KBASE := $030c
        KCLD_WARM := $030e
        KIN := $0310
        KDPL := $0312
        KHLD := $0314
        KDISKNO := $0316
        KCYLINDER := $0318
        KB_SIDE := $031c
        KDSK_STATUS := $e000
        KDSK_TRACK := $e101
        KDSK_SECTOR := $e102
        KDSK_DATA := $e103
        KDSK_CTL := $e106
        KUnused := $f000
        KINITVAR := $f400
        KLIT := $f40e
        KPUSH := $f421
        KPUT_ := $f423
        KNEXT := $f428
        KCLIT := $f458
        KEXECUTE := $f471
        KBRAN := $f480
        KZBRAN := $f497
        KLOOP := $f4af
        KPLOOP := $f4d0
        KDO := $f4f8
        KPOPTWO := $f506
        KPOP := $f508
        KDIGIT := $f50d
        KFIND := $f535
        KENCLOSE := $f591
        KEMIT := $f5d4
        KKEY := $f5f6
        KQTERM := $f60a
        KCR := $f613
        KCMOVE := $f626
        KUMUL := $f646
        KUDIV := $f67b
        KANDD := $f6be
        KBINARY := $f6c9
        KOR := $f6ce
        KXOR := $f6dc
        KSPAT := $f6ea
        KPUSHOA := $f6ed
        KSPSTORE := $f6f3
        KRPSTO := $f6fd
        KPUSHS := $f70c
        KSEMIS := $f717
        KSEMIS_C := $f719
        KLEAVE := $f722
        KGTR := $f734
        KRFROM := $f73f
        KR := $f74c
        KZEQ := $f75b
        KZLT := $f76b
        KPLUS := $f778
        KDPLUS := $f787
        KNEGATE := $f7a5
        KDNEGATE := $f7b5
        KOVER := $f7c5
        KDROP := $f7cf
        KTWODROP := $f7d1
        KSWAP := $f7d3
        KDUP := $f7e5
        KTWODUP := $f7ef
        KBOUNDS := $f803
        KRPAT := $f80c
        KPSTORE := $f818
        KTOGGL := $f830
        KAT := $f83b
        KCAT := $f84b
        KSTORE := $f858
        KCSTOR := $f86b
        KDOCOL := $f874
        KDOCON := $f889
        KDOVAR := $f894
        KDOUSE := $f8a0
        KZERO := $f8af
        KONE := $f8b3
        KTWO := $f8b7
        KTHREE := $f8bb
        KFOUR := $f8bf
        KBL := $f8c3
        KTIB := $f8c7
        KSZ := $f8ca
        KRZ := $f8cd
        KUCL := $f8d0
        KUPAD := $f8d3
        KURW := $f8d6
        KBASE := $f8d9
        KCLDWRM := $f8dc
        KIN := $f8df
        KDPL := $f8e2
        KHLD := $f8e5
        KCL := $f8e8
        KPAD := $f8f0
        KONEPLUS := $f8f8
        KTWOPLUS := $f903
        KONEMINUS := $f913
        KTWOMINUS := $f920
        KSUB := $f930
        KEQUAL := $f938
        KULESS := $f940
        KLESS := $f954
        KGT := $f96c
        KROT := $f974
        KPICK := $f98f
        KSPACE := $f99d
        KSUBDUP := $f9a5
        KHEX := $f9b1
        KDECIMAL := $f9bc
        KDOES := $f9c5
        KCOUNT := $f9e3
        KTYPE := $f9ef
        KSUBTRAILING := $fa0b
        KPDOTQ := $fa31
        KEXPECT := $fa45
        KQUERY := $faac
        KFILL_ := $fabe
        KERASE := $fae4
        KBLANKS := $faec
        KHOLD := $faf4
        KLTNUMBER := $fb06
        KCOLD := $fb48
        KRESET := $fb49
        Kunkn0 := $fbf5
        Kunkn1 := $fc01
        Kunkn2 := $fc0a
        KSTOD := $fc2c
        KPM := $fc36
        KDPLUS1 := $fc42
        KABS := $fc4e
        KDABS := $fc56
        KMIN := $fc5e
        KMAX := $fc63
        KMMUL := $fc7e
        KMDIV := $fc94
        KMUL := $fcb6
        KDIVMOD := $fcbe
        KDIV_ := $fcca
        KMOD_ := $fcd4
        KMULDIVMOD := $fcdc
        KMULDIV := $fce8
        KMDIVMOD := $fcf2
        KDISK := $fd08
        KSELECT := $fd43
        KDREAD := $fd57
        KDSTAT := $fdb5
        KDWRITE := $fdbe
        KINIT := $fdf1
        KSUB1 := $fe03
        KTAB1 := $fe0d
        KSEEK := $fe11
        KSPACES := $fe3a
        KLEQ := $fe52
        KHASHGT := $fe5c
        KSIGN := $fe6c
        KHASH := $fe7d
        KHASHS := $fea0
        KDDOTR := $feb0
        KDDOT := $fece
        KDOTR := $fed8
        KDOT := $fee4
        KQ := $feec
        KEECSTORE := $fef4
        KBANKPSH := $ff2e
        KBANKPOP := $ff3a
        KBANKCSTOR := $ff42
        KBANKCAT := $ff4a
        KBANKEECS := $ff52
        KBANKEXEC := $ff5a
        Kunkn5 := $ff62
        Kunkn6 := $ff7f
        Kunkna := $ffb6
        KMON := $ffca
        KNMIVEC := $fffa
        KRESETVEC := $fffc
        KIRQVEC := $fffe


;;
;;
;;
IDENT:         data.w $a55a
;;
;;
;;
START:         data.w $cc6e
UNKNOWN:         data.b $ff, $ff, $ff, $ff, $40, $01, $f8, $17, $00, $20, $00, $00, $1f, $00, $00, $00
        data.b $04, $04, $11, $04, $00, $00, $00, $00, $3c, $03, $81, $a0, $04, $04, $00, $00
        data.b $81, $a0, $d1, $df, $36, $03, $4e
                  data.b $cc
;;
;;    LIT
;;
_LIT             text.7 $83, "LIT"
                  data.w KPortA    ; link to previous. Last link marked by zero.
                  data.w KLIT+2    ; PFAPTR
;;
;;    CLIT
;;
_CLIT             text.7 $84, "CLIT"
                  data.w _LIT    ; link to LIT
                  data.w KCLIT+2    ; PFAPTR
;;
;;    EXECUTE
;;
_EXECUTE             text.7 $87, "EXECUTE"
                  data.w _CLIT    ; link to CLIT
                  data.w KEXECUTE+2    ; PFAPTR
;;
;;    BRANCH
;;
_BRANCH             text.7 $86, "BRANCH"
                  data.w _EXECUTE    ; link to EXECUTE
                  data.w KBRAN+2    ; PFAPTR
;;
;;    0BRANCH
;;
_ZBRANCH             text.7 $87, "0BRANCH"
                  data.w _BRANCH    ; link to BRANCH
                  data.w KZBRAN+2    ; PFAPTR
;;
;;    (LOOP)
;;
_PLOOP             text.7 $86, "(LOOP)"
                  data.w _ZBRANCH    ; link to 0BRANCH
                  data.w KLOOP+2    ; PFAPTR
;;
;;    (+LOOP)
;;
_PPLOOP             text.7 $87, "(+LOOP)"
                  data.w _PLOOP    ; link to (LOOP)
                  data.w KPLOOP+2    ; PFAPTR
;;
;;    (DO)
;;
_PDO             text.7 $84, "(DO)"
                  data.w _PPLOOP    ; link to (+LOOP)
                  data.w KDO+2    ; PFAPTR
;;
;;    I
;;
_I             text.7 $81, "I"
                  data.w _PDO    ; link to (DO)
                  data.w _DIGIT    ; PFAPTR
                  data.w KR+2
;;
;;    DIGIT
;;
_DIGIT             text.7 $85, "DIGIT"
                  data.w _I    ; link to I
                  data.w KDIGIT+2    ; PFAPTR
;;
;;    (FIND)
;;
_PFIND             text.7 $86, "(FIND)"
                  data.w _DIGIT    ; link to DIGIT
                  data.w KFIND+2    ; PFAPTR
;;
;;    ENCLOSE
;;
_ENCLOSE             text.7 $87, "ENCLOSE"
                  data.w _PFIND    ; link to (FIND)
                  data.w KENCLOSE+2    ; PFAPTR
;;
;;    EMIT
;;
_EMIT             text.7 $84, "EMIT"
                  data.w _ENCLOSE    ; link to ENCLOSE
                  data.w KEMIT+2    ; PFAPTR
;;
;;    KEY
;;
_KEY             text.7 $83, "KEY"
                  data.w _EMIT    ; link to EMIT
                  data.w KKEY+2    ; PFAPTR
;;
;;    ?TERMINAL
;;
_QTERMINAL             text.7 $89, "?TERMINAL"
                  data.w _KEY    ; link to KEY
                  data.w KQTERM+2    ; PFAPTR
;;
;;    CR
;;
_CR             text.7 $82, "CR"
                  data.w _QTERMINAL    ; link to ?TERMINAL
                  data.w KCR+2    ; PFAPTR
;;
;;    XON
;;
_XON             text.7 $83, "XON"
                  data.w _CR    ; link to CR
                  data.w $c0d9    ; PFAPTR
;;
;;
;;
XON:         data.w KDOCOL
                  data.w KPDOTQ
                  data.b $01, ""
                  data.w KSEMIS
;;
;;    XOFF
;;
_XOFF             text.7 $84, "XOFF"
                  data.w _XON    ; link to XON
                  data.w $c0ea    ; PFAPTR
;;
;;
;;
XOFF:         data.w KDOCOL
                  data.w KPDOTQ
                  data.b $01, ""
                  data.w KSEMIS
;;
;;    SOURCE
;;
_SOURCE             text.7 $86, "SOURCE"
                  data.w _XOFF    ; link to XOFF
                  data.w $c0fd    ; PFAPTR
;;
;;
;;
SOURCE:         data.w KDOCOL
                  data.w KZERO
                  data.w BLK
                  data.w KSTORE
                  data.w LBRAC
                  data.w KRPSTO
                  data.w XON
                  data.w KZERO
                  data.w KIN
                  data.w KSTORE
                  data.w KTIB
                  data.w KAT
                  data.w KCLIT
                  data.b $50
                  data.w KBOUNDS
                  data.w KDO
                  data.w KKEY
                  data.w KDUP
                  data.w KCLIT
                  data.b $0d
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $0008
                  data.w KDROP
                  data.w KZERO
                  data.w KLEAVE
                  data.w $c086
                  data.w KCSTOR
                  data.w KLOOP
                  data.w $ffe7
                  data.w XOFF
                  data.w INTERPRET
                  data.w KBRAN
                  data.w $ffca
;;
;;    FINIS
;;
_FINIS             text.7 $85, "FINIS"
                  data.w _SOURCE    ; link to SOURCE
                  data.w $c149    ; PFAPTR
;;
;;
;;
FINIS:         data.w KDOCOL
                  data.w KCR
                  data.w KPDOTQ
                  data.b $02, "OK"
                  data.w KBRAN
                  data.w $0865
;;
;;    CMOVE
;;
_CMOVE             text.7 $85, "CMOVE"
                  data.w _FINIS    ; link to FINIS
                  data.w KCMOVE+2    ; PFAPTR
;;
;;    U*
;;
_UMUL             text.7 $82, "U*"
                  data.w _CMOVE    ; link to CMOVE
                  data.w KUMUL+2    ; PFAPTR
;;
;;    U/
;;
_UDIV             text.7 $82, "U/"
                  data.w _UMUL    ; link to U*
                  data.w KUDIV+2    ; PFAPTR
;;
;;    AND
;;
_AND             text.7 $83, "AND"
                  data.w _UDIV    ; link to U/
                  data.w KANDD+2    ; PFAPTR
;;
;;    OR
;;
_OR             text.7 $82, "OR"
                  data.w _AND    ; link to AND
                  data.w KOR+2    ; PFAPTR
;;
;;    XOR
;;
_XOR             text.7 $83, "XOR"
                  data.w _OR    ; link to OR
                  data.w KXOR+2    ; PFAPTR
;;
;;    SP@
;;
_SPAT             text.7 $83, "SP@"
                  data.w _XOR    ; link to XOR
                  data.w KSPAT+2    ; PFAPTR
;;
;;    SP!
;;
_SPSTOR             text.7 $83, "SP!"
                  data.w _SPAT    ; link to SP@
                  data.w KSPSTORE+2    ; PFAPTR
;;
;;    RP!
;;
_RPSTOR             text.7 $83, "RP!"
                  data.w _SPSTOR    ; link to SP!
                  data.w KRPSTO+2    ; PFAPTR
;;
;;    RP@
;;
_RPAT             text.7 $83, "RP@"
                  data.w _RPSTOR    ; link to RP!
                  data.w KPUSHS+2    ; PFAPTR
;;
;;    ;S
;;
_SEMIS             text.7 $82, ";S"
                  data.w _RPAT    ; link to RP@
                  data.w KSEMIS_C    ; PFAPTR
;;
;;    LEAVE
;;
_LEAVE             text.7 $85, "LEAVE"
                  data.w _SEMIS    ; link to ;S
                  data.w KLEAVE+2    ; PFAPTR
;;
;;    >R
;;
_GTR             text.7 $82, ">R"
                  data.w _LEAVE    ; link to LEAVE
                  data.w KGTR+2    ; PFAPTR
;;
;;    R>
;;
_RGT             text.7 $82, "R>"
                  data.w _GTR    ; link to >R
                  data.w KRFROM+2    ; PFAPTR
;;
;;    R
;;
_R             text.7 $81, "R"
                  data.w _RGT    ; link to R>
                  data.w KR+2    ; PFAPTR
;;
;;    0=
;;
_ZEQ             text.7 $82, "0="
                  data.w _R    ; link to R
                  data.w KZEQ+2    ; PFAPTR
;;
;;    NOT
;;
_NOT             text.7 $83, "NOT"
                  data.w _ZEQ    ; link to 0=
                  data.w _ZLT    ; PFAPTR
                  data.w KZEQ+2
;;
;;    0<
;;
_ZLT             text.7 $82, "0<"
                  data.w _NOT    ; link to NOT
                  data.w KZLT+2    ; PFAPTR
;;
;;    +
;;
_PLUS             text.7 $81, "+"
                  data.w _ZLT    ; link to 0<
                  data.w KPLUS+2    ; PFAPTR
;;
;;    D+
;;
_DPLUS             text.7 $82, "D+"
                  data.w _PLUS    ; link to +
                  data.w KDPLUS+2    ; PFAPTR
;;
;;    NEGATE
;;
_NEGATE             text.7 $86, "NEGATE"
                  data.w _DPLUS    ; link to D+
                  data.w KNEGATE+2    ; PFAPTR
;;
;;    DNEGATE
;;
_DNEGATE             text.7 $87, "DNEGATE"
                  data.w _NEGATE    ; link to NEGATE
                  data.w KDNEGATE+2    ; PFAPTR
;;
;;    OVER
;;
_OVER             text.7 $84, "OVER"
                  data.w _DNEGATE    ; link to DNEGATE
                  data.w KOVER+2    ; PFAPTR
;;
;;    DROP
;;
_DROP             text.7 $84, "DROP"
                  data.w _OVER    ; link to OVER
                  data.w KTWODROP    ; PFAPTR
;;
;;    2DROP
;;
_TWODROP             text.7 $85, "2DROP"
                  data.w _DROP    ; link to DROP
                  data.w KSWAP    ; PFAPTR
;;
;;    SWAP
;;
_SWAP             text.7 $84, "SWAP"
                  data.w _TWODROP    ; link to 2DROP
                  data.w KSWAP+2    ; PFAPTR
;;
;;    DUP
;;
_DUP             text.7 $83, "DUP"
                  data.w _SWAP    ; link to SWAP
                  data.w KDUP+2    ; PFAPTR
;;
;;    2DUP
;;
_TWODUP             text.7 $84, "2DUP"
                  data.w _DUP    ; link to DUP
                  data.w KTWODUP+2    ; PFAPTR
;;
;;    BOUNDS
;;
_BOUNDS             text.7 $86, "BOUNDS"
                  data.w _TWODUP    ; link to 2DUP
                  data.w KBOUNDS+2    ; PFAPTR
;;
;;    +!
;;
_PLUSSTOR             text.7 $82, "+!"
                  data.w _BOUNDS    ; link to BOUNDS
                  data.w KPSTORE+2    ; PFAPTR
;;
;;    TOGGLE
;;
_TOGGLE             text.7 $86, "TOGGLE"
                  data.w _PLUSSTOR    ; link to +!
                  data.w KTOGGL+2    ; PFAPTR
;;
;;    @
;;
_AT             text.7 $81, "@"
                  data.w _TOGGLE    ; link to TOGGLE
                  data.w KAT+2    ; PFAPTR
;;
;;    C@
;;
_CAT             text.7 $82, "C@"
                  data.w _AT    ; link to @
                  data.w KCAT+2    ; PFAPTR
;;
;;    !
;;
_STOR             text.7 $81, "!"
                  data.w _CAT    ; link to C@
                  data.w KSTORE+2    ; PFAPTR
;;
;;    C!
;;
_CSTOR             text.7 $82, "C!"
                  data.w _STOR    ; link to !
                  data.w KCSTOR+2    ; PFAPTR
;;
;;
;;
CSTOR:         data.w KDOCOL
                  data.w LATEST
                  data.w PFAPTR
                  data.w CFA
                  data.w KSTORE
                  data.w KRFROM
                  data.w KDROP
                  data.w KSEMIS
;;
;;    :
;;
_COLON             text.7 $c1, ":"
                  data.w _CSTOR    ; link to C!
                  data.w $c289    ; PFAPTR
;;
;;
;;
COLON:         data.w KDOCOL
                  data.w QEXEC
                  data.w STORCSP
                  data.w CURRENT
                  data.w KAT
                  data.w CONTEXT
                  data.w KSTORE
                  data.w CREATE
                  data.w RBRAC
                  data.w KLIT
                  data.w KDOCOL
                  data.w CSTOR
;;
;;    ;
;;
_SEMI             text.7 $c1, ";"
                  data.w _COLON    ; link to :
                  data.w $c2a7    ; PFAPTR
                  data.w KDOCOL
                  data.w QCSP
                  data.w COMPILE
                  data.w KSEMIS
                  data.w SMUDGE
                  data.w LBRAC
                  data.w KSEMIS
;;
;;    CONSTANT
;;
_CONSTANT             text.7 $88, "CONSTANT"
                  data.w _SEMI    ; link to ;
                  data.w $c2c2    ; PFAPTR
;;
;;
;;
CONSTANT:         data.w KDOCOL
                  data.w CREATE
                  data.w SMUDGE
                  data.w COMMA
                  data.w KLIT
                  data.w KDOCON
                  data.w $c271
;;
;;    VARIABLE
;;
_VARIABLE             text.7 $88, "VARIABLE"
                  data.w _CONSTANT    ; link to CONSTANT
                  data.w $c2dd    ; PFAPTR
;;
;;
;;
VARIABLE:         data.w KDOCOL
                  data.w CONSTANT
                  data.w KLIT
                  data.w KDOVAR
                  data.w CSTOR
;;
;;    CODE
;;
_CODE             text.7 $c4, "CODE"
                  data.w _VARIABLE    ; link to VARIABLE
                  data.w $c2f0    ; PFAPTR
;;
;;
;;
CODE:         data.w KDOCOL
                  data.w QEXEC
                  data.w CREATE
                  data.w ASSEMBLER
                  data.w UNK3
                  data.w STORCSP
                  data.w KSEMIS
;;
;;    USER
;;
_USER             text.7 $84, "USER"
                  data.w _CODE    ; link to CODE
                  data.w $c307    ; PFAPTR
;;
;;
;;
USER:         data.w KDOCOL
                  data.w CREATE
                  data.w SMUDGE
                  data.w CCOMMA
                  data.w KLIT
                  data.w KDOUSE
                  data.b $71
pad:         data.b $c2
;;
;;    0
;;
_ZERO             text.7 $81, "0"
                  data.w _USER    ; link to USER
                  data.w KZERO+2    ; PFAPTR
;;
;;    1
;;
_ONE             text.7 $81, "1"
                  data.w _ZERO    ; link to 0
                  data.w KONE+2    ; PFAPTR
;;
;;    2
;;
_TWO             text.7 $81, "2"
                  data.w _ONE    ; link to 1
                  data.w KTWO+2    ; PFAPTR
;;
;;    3
;;
_THREE             text.7 $81, "3"
                  data.w _TWO    ; link to 2
                  data.w KTHREE+2    ; PFAPTR
;;
;;    4
;;
_FOUR             text.7 $81, "4"
                  data.w _THREE    ; link to 3
                  data.w KFOUR+2    ; PFAPTR
;;
;;    BL
;;
_BL             text.7 $82, "BL"
                  data.w _FOUR    ; link to 4
                  data.w KBL+2    ; PFAPTR
;;
;;    TIB
;;
_TIB             text.7 $83, "TIB"
                  data.w _BL    ; link to BL
                  data.w KTIB+2    ; PFAPTR
;;
;;    S0
;;
_S0             text.7 $82, "S0"
                  data.w _TIB    ; link to TIB
                  data.w KSZ+2    ; PFAPTR
;;
;;    R0
;;
_R0             text.7 $82, "R0"
                  data.w _S0    ; link to S0
                  data.w KRZ+2    ; PFAPTR
;;
;;    UC/L
;;
_UCL             text.7 $84, "UC/L"
                  data.w _R0    ; link to R0
                  data.w KUCL+2    ; PFAPTR
;;
;;    UPAD
;;
_UPAD             text.7 $84, "UPAD"
                  data.w _UCL    ; link to UC/L
                  data.w KUPAD+2    ; PFAPTR
;;
;;    UR/W
;;
_URW             text.7 $84, "UR/W"
                  data.w _UPAD    ; link to UPAD
                  data.w KURW+2    ; PFAPTR
;;
;;    BASE
;;
_BASE             text.7 $84, "BASE"
                  data.w _URW    ; link to UR/W
                  data.w KBASE+2    ; PFAPTR
;;
;;    CLD/WRM
;;
_CLDWRM             text.7 $87, "CLD/WRM"
                  data.w _BASE    ; link to BASE
                  data.w KCLDWRM+2    ; PFAPTR
;;
;;    IN
;;
_IN             text.7 $82, "IN"
                  data.w _CLDWRM    ; link to CLD/WRM
                  data.w KIN+2    ; PFAPTR
;;
;;    DPL
;;
_DPL             text.7 $83, "DPL"
                  data.w _IN    ; link to IN
                  data.w KDPL+2    ; PFAPTR
;;
;;    HLD
;;
_HLD             text.7 $83, "HLD"
                  data.w _DPL    ; link to DPL
                  data.w KHLD+2    ; PFAPTR
;;
;;    DISKNO
;;
_DISKNO             text.7 $86, "DISKNO"
                  data.w _HLD    ; link to HLD
                  data.w $c3a2    ; PFAPTR
;;
;;
;;
DISKNO:         data.w KDOUSE
                  data.b $16
;;
;;    CYLINDER
;;
_CYLINDER             text.7 $88, "CYLINDER"
                  data.w _DISKNO    ; link to DISKNO
                  data.w $c3b2    ; PFAPTR
;;
;;
;;
CYLINDER:         data.w KDOUSE
                  data.b $18
;;
;;    B/SIDE
;;
_BSIDE             text.7 $86, "B/SIDE"
                  data.w _CYLINDER    ; link to CYLINDER
                  data.w $c3c0    ; PFAPTR
;;
;;
;;
BSIDE:         data.w KDOUSE
                  data.b $1c
;;
;;    UFIRST
;;
_UFIRST             text.7 $86, "UFIRST"
                  data.w _BSIDE    ; link to B/SIDE
                  data.w $c3ce    ; PFAPTR
;;
;;
;;
UFIRST:         data.w KDOUSE
                  data.b $1e
;;
;;    ULIMIT
;;
_ULIMIT             text.7 $86, "ULIMIT"
                  data.w _UFIRST    ; link to UFIRST
                  data.w $c3dc    ; PFAPTR
;;
;;
;;
ULIMIT:         data.w KDOUSE
                  data.b $20
;;
;;    OFFSET
;;
_OFFSET             text.7 $86, "OFFSET"
                  data.w _ULIMIT    ; link to ULIMIT
                  data.w $c3ea    ; PFAPTR
;;
;;
;;
OFFSET:         data.w KDOUSE
                  data.b $22
;;
;;    WIDTH
;;
_WIDTH             text.7 $85, "WIDTH"
                  data.w _OFFSET    ; link to OFFSET
                  data.w $c3f7    ; PFAPTR
;;
;;
;;
WIDTH:         data.w KDOUSE
                  data.b $24
;;
;;    WARNING
;;
_WARNING             text.7 $87, "WARNING"
                  data.w _WIDTH    ; link to WIDTH
                  data.w $c406    ; PFAPTR
;;
;;
;;
WARNING:         data.w KDOUSE
                  data.b $26
;;
;;    FENCE
;;
_FENCE             text.7 $85, "FENCE"
                  data.w _WARNING    ; link to WARNING
                  data.w $c413    ; PFAPTR
;;
;;
;;
FENCE:         data.w KDOUSE
                  data.b $28
;;
;;    DP
;;
_DP             text.7 $82, "DP"
                  data.w _FENCE    ; link to FENCE
                  data.w $c41d    ; PFAPTR
;;
;;
;;
DP:         data.w KDOUSE
                  data.b $2a
;;
;;    HEADERLESS
;;
_HEADERLESS             text.7 $8a, "HEADERLESS"
                  data.w _DP    ; link to DP
                  data.w $c42f    ; PFAPTR
;;
;;
;;
HEADERLESS:         data.w KDOUSE
                  data.b $2e
;;
;;    VOC-LINK
;;
_VOCL             text.7 $88, "VOC-LINK"
                  data.w _HEADERLESS    ; link to HEADERLESS
                  data.w $c43f    ; PFAPTR
;;
;;
;;
VOCL:         data.w KDOUSE
                  data.b $30
unk:         data.b $a0, $f8, $34, $a0, $f8, $3a
;;
;;    UABORT
;;
_UABORT             text.7 $86, "UABORT"
                  data.w _VOCL    ; link to VOC-LINK
                  data.w $c453    ; PFAPTR
;;
;;
;;
UABORT:         data.w KDOUSE
                  data.b $3e
;;
;;    USE
;;
_USE             text.7 $83, "USE"
                  data.w _UABORT    ; link to UABORT
                  data.w $c45e    ; PFAPTR
;;
;;
;;
USE:         data.w KDOUSE
                  data.b $40
;;
;;    PREV
;;
_PREV             text.7 $84, "PREV"
                  data.w _USE    ; link to USE
                  data.w $c46a    ; PFAPTR
;;
;;
;;
PREV:         data.w KDOUSE
                  data.b $42
;;
;;    BLK
;;
_BLK             text.7 $83, "BLK"
                  data.w _PREV    ; link to PREV
                  data.w $c475    ; PFAPTR
;;
;;
;;
BLK:         data.w KDOUSE
                  data.b $44
;;
;;    SCR
;;
_SCR             text.7 $83, "SCR"
                  data.w _BLK    ; link to BLK
                  data.w $c480    ; PFAPTR
;;
;;
;;
SCR:         data.w KDOUSE
                  data.b $46
;;
;;    CONTEXT
;;
_CONTEXT             text.7 $87, "CONTEXT"
                  data.w _SCR    ; link to SCR
                  data.w $c48f    ; PFAPTR
;;
;;
;;
CONTEXT:         data.w KDOUSE
                  data.b $48
;;
;;    CURRENT
;;
_CURRENT             text.7 $87, "CURRENT"
                  data.w _CONTEXT    ; link to CONTEXT
                  data.w $c49e    ; PFAPTR
;;
;;
;;
CURRENT:         data.w KDOUSE
                  data.b $4a
;;
;;    STATE
;;
_STATE             text.7 $85, "STATE"
                  data.w _CURRENT    ; link to CURRENT
                  data.w $c4ab    ; PFAPTR
;;
;;
;;
STATE:         data.w KDOUSE
                  data.b $4c
;;
;;    CSP
;;
_CSP             text.7 $83, "CSP"
                  data.w _STATE    ; link to STATE
                  data.w $c4b6    ; PFAPTR
;;
;;
;;
CSP:         data.w KDOUSE
                  data.b $4e
;;
;;    MODE
;;
_MODE             text.7 $84, "MODE"
                  data.w _CSP    ; link to CSP
                  data.w $c4c2    ; PFAPTR
;;
;;
;;
MODE:         data.w KDOUSE
                  data.b $50
;;
;;    KHZ
;;
_KHZ             text.7 $83, "KHZ"
                  data.w _MODE    ; link to MODE
                  data.w $c4cd    ; PFAPTR
;;
;;
;;
KHZ:         data.w KDOUSE
                  data.b $52
;;
;;    C/L
;;
CL             text.7 $83, "C/L"
                  data.w _KHZ    ; link to KHZ
                  data.w KCL+2    ; PFAPTR
;;
;;    FIRST
;;
_FIRST             text.7 $85, "FIRST"
                  data.w CL    ; link to C/L
                  data.w $c4e2    ; PFAPTR
;;
;;
;;
FIRST:         data.w KDOCOL
                  data.w UFIRST
                  data.w KAT
                  data.w KSEMIS
;;
;;    LIMIT
;;
_LIMIT             text.7 $85, "LIMIT"
                  data.w _FIRST    ; link to FIRST
                  data.w $c4f4    ; PFAPTR
;;
;;
;;
LIMIT:         data.w KDOCOL
                  data.w ULIMIT
                  data.w KAT
                  data.w KSEMIS
;;
;;    PAD
;;
_PAD             text.7 $83, "PAD"
                  data.w _LIMIT    ; link to LIMIT
                  data.w KPAD+2    ; PFAPTR
;;
;;    1+
;;
_ONEPLUS             text.7 $82, "1+"
                  data.w _PAD    ; link to PAD
                  data.w KONEPLUS+2    ; PFAPTR
;;
;;    2+
;;
_2PLUS             text.7 $82, "2+"
                  data.w _ONEPLUS    ; link to 1+
                  data.w KTWOPLUS+2    ; PFAPTR
;;
;;    1-
;;
_1SUB             text.7 $82, "1-"
                  data.w _2PLUS    ; link to 2+
                  data.w KONEMINUS+2    ; PFAPTR
;;
;;    2-
;;
_2SUB             text.7 $82, "2-"
                  data.w _1SUB    ; link to 1-
                  data.w KTWOMINUS+2    ; PFAPTR
;;
;;    DP/
;;
_DPDIV             text.7 $83, "DP/"
                  data.w _2SUB    ; link to 2-
                  data.w $c528    ; PFAPTR
;;
;;
;;
DPDIV:         data.w KDOCOL
                  data.w DP
                  data.w HEADERLESS
                  data.w KAT
                  data.w KZBRAN
                  data.w $0004
                  data.w KTWOPLUS
                  data.w KSEMIS
;;
;;    HERE/
;;
_HEREDIV             text.7 $85, "HERE/"
                  data.w _DPDIV    ; link to DP/
                  data.w $c542    ; PFAPTR
;;
;;
;;
HEREDIV:         data.w KDOCOL
                  data.w DPDIV
                  data.w KAT
                  data.w KSEMIS
;;
;;    ALLOT/
;;
_ALLOTDIV             text.7 $86, "ALLOT/"
                  data.w _HEREDIV    ; link to HERE/
                  data.w $c555    ; PFAPTR
;;
;;
;;
ALLOTDIV:         data.w KDOCOL
                  data.w DPDIV
                  data.w KPSTORE
                  data.w KSEMIS
;;
;;    ,/
;;
_COMMADIV             text.7 $82, ",/"
                  data.w _ALLOTDIV    ; link to ALLOT/
                  data.w $c564    ; PFAPTR
;;
;;
;;
COMMADIV:         data.w KDOCOL
                  data.w HEREDIV
                  data.w KSTORE
                  data.w KTWO
                  data.w ALLOTDIV
                  data.w KSEMIS
;;
;;    HERE
;;
_HERE             text.7 $84, "HERE"
                  data.w _COMMADIV    ; link to ,/
                  data.w $c579    ; PFAPTR
;;
;;
;;
HERE:         data.w KDOCOL
                  data.w DP
                  data.w KAT
                  data.w KSEMIS
;;
;;    ALLOT
;;
_ALLOT             text.7 $85, "ALLOT"
                  data.w _HERE    ; link to HERE
                  data.w $c58b    ; PFAPTR
;;
;;
;;
ALLOT:         data.w KDOCOL
                  data.w DP
                  data.w KPSTORE
                  data.w KSEMIS
;;
;;    ,
;;
_COMMA             text.7 $81, ","
                  data.w _ALLOT    ; link to ALLOT
                  data.w $c599    ; PFAPTR
;;
;;
;;
COMMA:         data.w KDOCOL
                  data.w HERE
                  data.w KSTORE
                  data.w KTWO
                  data.w ALLOT
                  data.w KSEMIS
;;
;;    C,
;;
_CCOMMA             text.7 $82, "C,"
                  data.w _COMMA    ; link to ,
                  data.w $c5ac    ; PFAPTR
;;
;;
;;
CCOMMA:         data.w KDOCOL
                  data.w HERE
                  data.w KCSTOR
                  data.w KONE
                  data.w ALLOT
                  data.w KSEMIS
;;
;;    -
;;
_SUB             text.7 $81, "-"
                  data.w _CCOMMA    ; link to C,
                  data.w KSUB+2    ; PFAPTR
;;
;;    =
;;
_EQ             text.7 $81, "="
                  data.w _SUB    ; link to -
                  data.w KEQUAL+2    ; PFAPTR
;;
;;    U<
;;
_ULT             text.7 $82, "U<"
                  data.w _EQ    ; link to =
                  data.w KULESS+2    ; PFAPTR
;;
;;    <
;;
_LT             text.7 $81, "<"
                  data.w _ULT    ; link to U<
                  data.w KLESS+2    ; PFAPTR
;;
;;    >
;;
_GT             text.7 $81, ">"
                  data.w _LT    ; link to <
                  data.w KGT+2    ; PFAPTR
;;
;;    ROT
;;
_ROT             text.7 $83, "ROT"
                  data.w _GT    ; link to >
                  data.w KROT+2    ; PFAPTR
;;
;;    PICK
;;
_PICK             text.7 $84, "PICK"
                  data.w _ROT    ; link to ROT
                  data.w KPICK+2    ; PFAPTR
;;
;;    SPACE
;;
_SPACE             text.7 $85, "SPACE"
                  data.w _PICK    ; link to PICK
                  data.w KSPACE+2    ; PFAPTR
;;
;;    -DUP
;;
_SUBDUP             text.7 $84, "-DUP"
                  data.w _SPACE    ; link to SPACE
                  data.w KSUBDUP+2    ; PFAPTR
;;
;;    TRAVERSE
;;
_TRAVERSE             text.7 $88, "TRAVERSE"
                  data.w _SUBDUP    ; link to -DUP
                  data.w $c608    ; PFAPTR
;;
;;
;;
TRAVERSE:         data.w KDOCOL
                  data.w KSWAP
                  data.w KOVER
                  data.w KPLUS
                  data.w KCLIT
                  data.b $7f
                  data.w KOVER
                  data.w KCAT
                  data.w KLESS
                  data.w KZBRAN
                  data.w $fff1
                  data.w KSWAP
                  data.w KDROP
                  data.w KSEMIS
;;
;;    LATEST
;;
_LATEST             text.7 $86, "LATEST"
                  data.w _TRAVERSE    ; link to TRAVERSE
                  data.w $c62e    ; PFAPTR
;;
;;
;;
LATEST:         data.w KDOCOL
                  data.w CURRENT
                  data.w KAT
                  data.w KAT
                  data.w KSEMIS
;;
;;    LFA
;;
_LFA             text.7 $83, "LFA"
                  data.w _LATEST    ; link to LATEST
                  data.w _CFA    ; PFAPTR
;;
;;
;;
LFA:         data.w KTWOMINUS+2
;;
;;    CFA
;;
_CFA             text.7 $83, "CFA"
                  data.w _LFA    ; link to LFA
                  data.w $c64a    ; PFAPTR
;;
;;
;;
CFA:         data.w KDOCOL
                  data.w KAT
                  data.w KTWOMINUS
                  data.w KSEMIS
;;
;;    NFA
;;
_NFA             text.7 $83, "NFA"
                  data.w _CFA    ; link to CFA
                  data.w $c65a    ; PFAPTR
;;
;;
;;
NFA:         data.w KDOCOL
                  data.w KCLIT
                  data.b $03
                  data.w KSUB
                  data.w KLIT
                  data.w $ffff
                  data.w TRAVERSE
                  data.w KSEMIS
;;
;;    PFAPTR
;;
_PFAPTR             text.7 $86, "PFAPTR"
                  data.w _NFA    ; link to NFA
                  data.w $c674    ; PFAPTR
;;
;;
;;
PFAPTR:         data.w KDOCOL
                  data.w KONE
                  data.w TRAVERSE
                  data.w KCLIT
                  data.b $03
                  data.w KPLUS
                  data.w KSEMIS
;;
;;    !CSP
;;
_STORCSP             text.7 $84, "!CSP"
                  data.w _PFAPTR    ; link to PFAPTR
                  data.w $c68a    ; PFAPTR
;;
;;
;;
STORCSP:         data.w KDOCOL
                  data.w KSPAT
                  data.w CSP
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    ?ERROR
;;
_QERROR             text.7 $86, "?ERROR"
                  data.w _STORCSP    ; link to !CSP
                  data.w $c69f    ; PFAPTR
;;
;;
;;
QERROR:         data.w KDOCOL
                  data.w KSWAP
                  data.w KZBRAN
                  data.w $0004
                  data.w ERR
                  data.w KDROP
                  data.w KSEMIS
;;
;;    ?COMP
;;
_QCOMP             text.7 $85, "?COMP"
                  data.w _QERROR    ; link to ?ERROR
                  data.w $c6b7    ; PFAPTR
;;
;;
;;
QCOMP:         data.w KDOCOL
                  data.w STATE
                  data.w KAT
                  data.w KZEQ
                  data.w KCLIT
                  data.b $11
                  data.w QERROR
                  data.w KSEMIS
;;
;;    ?EXEC
;;
_QEXEC             text.7 $85, "?EXEC"
                  data.w _QCOMP    ; link to ?COMP
                  data.w $c6d0    ; PFAPTR
;;
;;
;;
QEXEC:         data.w KDOCOL
                  data.w STATE
                  data.w KAT
                  data.w KCLIT
                  data.b $12
                  data.w QERROR
                  data.w KSEMIS
;;
;;    ?PAIRS
;;
_QPAIRS             text.7 $86, "?PAIRS"
                  data.w _QEXEC    ; link to ?EXEC
                  data.w $c6e8    ; PFAPTR
;;
;;
;;
QPAIRS:         data.w KDOCOL
                  data.w KSUB
                  data.w KCLIT
                  data.b $13
                  data.w QERROR
                  data.w KSEMIS
;;
;;    ?CSP
;;
_QCSP             text.7 $84, "?CSP"
                  data.w _QPAIRS    ; link to ?PAIRS
                  data.w $c6fc    ; PFAPTR
;;
;;
;;
QCSP:         data.w KDOCOL
                  data.w KSPAT
                  data.w CSP
                  data.w KAT
                  data.w KSUB
                  data.w KCLIT
                  data.b $14
                  data.w QERROR
                  data.w KSEMIS
;;
;;    COMPILE
;;
_COMPILE             text.7 $87, "COMPILE"
                  data.w _QCSP    ; link to ?CSP
                  data.w $c719    ; PFAPTR
;;
;;
;;
COMPILE:         data.w KDOCOL
                  data.w QCOMP
                  data.w KRFROM
                  data.w KDUP
                  data.w KTWOPLUS
                  data.w KGTR
                  data.w KAT
                  data.w COMMA
                  data.w KSEMIS
;;
;;    [
;;
_LBRAC             text.7 $c1, "["
                  data.w _COMPILE    ; link to COMPILE
                  data.w $c731    ; PFAPTR
;;
;;
;;
LBRAC:         data.w KDOCOL
                  data.w KZERO
                  data.w STATE
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    ]
;;
_RBRAC             text.7 $81, "]"
                  data.w _LBRAC    ; link to [
                  data.w $c741    ; PFAPTR
;;
;;
;;
RBRAC:         data.w KDOCOL
                  data.w KCLIT
                  data.b $c0
                  data.w STATE
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    SMUDGE
;;
_SMUDGE             text.7 $86, "SMUDGE"
                  data.w _RBRAC    ; link to ]
                  data.w $c757    ; PFAPTR
;;
;;
;;
SMUDGE:         data.w KDOCOL
                  data.w LATEST
                  data.w KBL
                  data.w KTOGGL
                  data.w KSEMIS
;;
;;    HEX
;;
_HEX             text.7 $83, "HEX"
                  data.w _SMUDGE    ; link to SMUDGE
                  data.w KHEX+2    ; PFAPTR
;;
;;    DECIMAL
;;
_DECIMAL             text.7 $87, "DECIMAL"
                  data.w _HEX    ; link to HEX
                  data.w KDECIMAL+2    ; PFAPTR
;;
;;    (;CODE)
;;
_PSEMICODE             text.7 $87, "(;CODE)"
                  data.w _DECIMAL    ; link to DECIMAL
                  data.w $c781    ; PFAPTR
;;
;;
;;
PSEMICODE:         data.w KDOCOL
                  data.w KRFROM
                  data.w LATEST
                  data.w PFAPTR
                  data.w CFA
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    ;CODE
;;
_SEMICODE             text.7 $c5, ";CODE"
                  data.w _PSEMICODE    ; link to (;CODE)
                  data.w $c799    ; PFAPTR
;;
;;
;;
SEMICODE:         data.w KDOCOL
                  data.w QCSP
                  data.w COMPILE
                  data.w PSEMICODE
                  data.w LBRAC
                  data.w ASSEMBLER
                  data.w KSEMIS
;;
;;    <BUILDS
;;
_LTBUILDS             text.7 $87, "<BUILDS"
                  data.w _SEMICODE    ; link to ;CODE
                  data.w $c7b3    ; PFAPTR
;;
;;
;;
LTBUILDS:         data.w KDOCOL
                  data.w KZERO
                  data.w CONSTANT
                  data.w KSEMIS
;;
;;    DOES>
;;
_DOESGT             text.7 $85, "DOES>"
                  data.w _LTBUILDS    ; link to <BUILDS
                  data.w $c7c5    ; PFAPTR
;;
;;
;;
DOESGT:         data.w KDOCOL
                  data.w KRFROM
                  data.w LATEST
                  data.w PFAPTR
                  data.w KAT
                  data.w KSTORE
                  data.w KLIT
                  data.w KDOES
                  data.w CSTOR
;;
;;    COUNT
;;
_COUNT             text.7 $85, "COUNT"
                  data.w _DOESGT    ; link to DOES>
                  data.w KCOUNT+2    ; PFAPTR
;;
;;    TYPE
;;
_TYPE             text.7 $84, "TYPE"
                  data.w _COUNT    ; link to COUNT
                  data.w KTYPE+2    ; PFAPTR
;;
;;    -TRAILING
;;
_SUBTRAILING             text.7 $89, "-TRAILING"
                  data.w _TYPE    ; link to TYPE
                  data.w KSUBTRAILING+2    ; PFAPTR
;;
;;    (.")
;;
_PDOTQUOT             text.7 $84, "(.\")"
                  data.w _SUBTRAILING    ; link to -TRAILING
                  data.w KPDOTQ+2    ; PFAPTR
;;
;;    ."
;;
_DOTQUOT             text.7 $c2, ".\""
                  data.w _PDOTQUOT    ; link to (.")
                  data.w $c808    ; PFAPTR
;;
;;
;;
DOTQUOT:         data.w KDOCOL
                  data.w KCLIT
                  data.b $22
                  data.w STATE
                  data.w KAT
                  data.w KZBRAN
                  data.w $0012
                  data.w COMPILE
PDOTQADDR:         data.b $31, $fa
;;
;;
;;
CONT:         data.w FWORD
                  data.w HERE
                  data.w KCAT
                  data.w KONEPLUS
                  data.w ALLOT
                  data.w KSEMIS
                  data.w FWORD
                  data.w HERE
                  data.w KCOUNT
                  data.w KTYPE
                  data.w KSEMIS
;;
;;    EXPECT
;;
EXPECT             text.7 $86, "EXPECT"
                  data.w _DOTQUOT    ; link to ."
                  data.w KEXPECT+2    ; PFAPTR
;;
;;    QUERY
;;
_QUERY             text.7 $85, "QUERY"
                  data.w EXPECT    ; link to EXPECT
                  data.w KQUERY+2    ; PFAPTR
;;
;;     
;;
_FX             text.7 $c1, "\0"
                  data.w _QUERY    ; link to QUERY
                  data.w $c84a    ; PFAPTR
;;
;;
;;
FX:         data.w KDOCOL
                  data.w BLK
                  data.w KAT
                  data.w KZBRAN
                  data.w $0010
                  data.w KONE
                  data.w BLK
                  data.w KPSTORE
                  data.w KZERO
                  data.w KIN
                  data.w KSTORE
                  data.w QEXEC
                  data.w KRFROM
                  data.w KDROP
                  data.w KSEMIS
;;
;;    FILL
;;
_FILL             text.7 $84, "FILL"
                  data.w _FX    ; link to  
                  data.w KFILL_+2    ; PFAPTR
;;
;;    ERASE
;;
_ERASE             text.7 $85, "ERASE"
                  data.w _FILL    ; link to FILL
                  data.w KERASE+2    ; PFAPTR
;;
;;    BLANKS
;;
_BLANKS             text.7 $86, "BLANKS"
                  data.w _ERASE    ; link to ERASE
                  data.w KBLANKS+2    ; PFAPTR
;;
;;    HOLD
;;
_HOLD             text.7 $84, "HOLD"
                  data.w _BLANKS    ; link to BLANKS
                  data.w KHOLD+2    ; PFAPTR
;;
;;    WORD
;;
_FWORD             text.7 $84, "WORD"
                  data.w _HOLD    ; link to HOLD
                  data.w $c898    ; PFAPTR
;;
;;
;;
FWORD:         data.w KDOCOL
                  data.w BLK
                  data.w KAT
                  data.w KZBRAN
                  data.w $000c
                  data.w BLK
                  data.w KAT
                  data.w BLOCK
                  data.w KBRAN
                  data.w $0006
                  data.w KTIB
                  data.w KAT
                  data.w KIN
                  data.w KAT
                  data.w KPLUS
                  data.w KSWAP
                  data.w KENCLOSE
                  data.w HERE
                  data.w KCLIT
                  data.b $22
                  data.w KBLANKS
                  data.w KIN
                  data.w KPSTORE
                  data.w KOVER
                  data.w KSUB
                  data.w KGTR
                  data.w KR
                  data.w HERE
                  data.w KCSTOR
                  data.w KPLUS
                  data.w HERE
                  data.w KONEPLUS
                  data.w KRFROM
                  data.w KCMOVE
                  data.w KSEMIS
;;
;;    (NUMBER)
;;
_PNUMBER             text.7 $88, "(NUMBER)"
                  data.w _FWORD    ; link to WORD
                  data.w KLTNUMBER+2    ; PFAPTR
;;
;;    NUMBER
;;
_NUMBER             text.7 $86, "NUMBER"
                  data.w _PNUMBER    ; link to (NUMBER)
                  data.w $c8f5    ; PFAPTR
;;
;;
;;
NUMBER:         data.w KDOCOL
                  data.w KZERO
                  data.w KZERO
                  data.w KROT
                  data.w KDUP
                  data.w KONEPLUS
                  data.w KCAT
                  data.w KCLIT
                  data.b $2d
                  data.w KEQUAL
                  data.w KDUP
                  data.w KGTR
                  data.w KPLUS
                  data.w KLIT
                  data.w $ffff
                  data.w KDPL
                  data.w KSTORE
                  data.w KLTNUMBER
                  data.w KDUP
                  data.w KCAT
                  data.w KBL
                  data.w KSUB
                  data.w KZBRAN
                  data.w $0015
                  data.w KDUP
                  data.w KCAT
                  data.w KCLIT
                  data.b $2e
                  data.w KSUB
                  data.w KZERO
                  data.w QERROR
                  data.w KZERO
                  data.w KBRAN
                  data.w $ffdd
                  data.w KDROP
                  data.w KRFROM
                  data.w KZBRAN
                  data.w $0004
                  data.w KDNEGATE
                  data.w KSEMIS
;;
;;    -FIND
;;
_SUBFIND             text.7 $85, "-FIND"
                  data.w _NUMBER    ; link to NUMBER
                  data.w $c94d    ; PFAPTR
;;
;;
;;
SUBFIND:         data.w KDOCOL
                  data.w KBL
                  data.w FWORD
                  data.w HERE
                  data.w CONTEXT
                  data.w KAT
                  data.w KAT
                  data.w KFIND
                  data.w KDUP
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $000a
                  data.w KDROP
                  data.w HERE
                  data.w LATEST
                  data.w KFIND
                  data.w KSEMIS
;;
;;    (ABORT)
;;
_PABORT             text.7 $87, "(ABORT)"
                  data.w _SUBFIND    ; link to -FIND
                  data.w $c97b    ; PFAPTR
;;
;;
;;
PABORT:         data.w KDOCOL
                  data.w UABORT
                  data.w KAT
                  data.w KEXECUTE
                  data.w KSEMIS
;;
;;    ERROR
;;
_ERR             text.7 $85, "ERROR"
                  data.w _PABORT    ; link to (ABORT)
                  data.w $c98f    ; PFAPTR
;;
;;
;;
ERR:         data.w KDOCOL
                  data.w WARNING
                  data.w KAT
                  data.w KZLT
                  data.w KZBRAN
                  data.w $0004
                  data.w PABORT
                  data.w HERE
                  data.w KCOUNT
                  data.w KCR
                  data.w KTYPE
                  data.w KPDOTQ
                  data.b $03, " ? "
                  data.w FMESSAGE
                  data.w KSPSTORE
                  data.w KTWODROP
                  data.w KIN
                  data.w KAT
                  data.w BLK
                  data.w KAT
                  data.w KLIT
                  data.w $ffae
                  data.w KCLIT
                  data.b $44
                  data.w KSTORE
                  data.w QUIT
;;
;;    ID.
;;
_ID             text.7 $83, "ID."
                  data.w _ERR    ; link to ERROR
                  data.w $c9cc    ; PFAPTR
;;
;;
;;
ID:         data.w KDOCOL
                  data.w KCOUNT
                  data.w KONEMINUS
                  data.w KCLIT
                  data.b $1f
                  data.w KANDD
                  data.w KTWODUP
                  data.w KTYPE
                  data.w KPLUS
                  data.w KAT
                  data.w KCLIT
                  data.b $7f
                  data.w KANDD
                  data.w KEMIT
                  data.w KSPACE
                  data.w KSEMIS
;;
;;    CREATE
;;
_CREATE             text.7 $86, "CREATE"
                  data.w _ID    ; link to ID.
                  data.w $c9f5    ; PFAPTR
;;
;;
;;
CREATE:         data.w KDOCOL
                  data.w FIRST
                  data.w HEREDIV
                  data.w KCLIT
                  data.b $24
                  data.w KPLUS
                  data.w KULESS
                  data.w KTWO
                  data.w QERROR
                  data.w FIRST
                  data.w HERE
                  data.w KCLIT
                  data.b $a0
                  data.w KPLUS
                  data.w KULESS
                  data.w KTWO
                  data.w QERROR
                  data.w SUBFIND
                  data.w KZBRAN
                  data.w $0018
                  data.w KDROP
                  data.w KCR
                  data.w NFA
                  data.w ID
                  data.w KPDOTQ
                  data.b $0b, "NOT UNIQUE "
                  data.w HERE
                  data.w HEREDIV
                  data.w KOVER
                  data.w KCAT
                  data.w KONEPLUS
                  data.w KCMOVE
                  data.w HEREDIV
                  data.w KDUP
                  data.w KCAT
                  data.w WIDTH
                  data.w KAT
                  data.w KMIN
                  data.w KONEPLUS
                  data.w ALLOTDIV
                  data.w DP
                  data.w KCAT
                  data.w KCLIT
                  data.b $fd
                  data.w KEQUAL
                  data.w ALLOT
                  data.w KDUP
                  data.w KCLIT
                  data.b $a0
                  data.w KTOGGL
                  data.w HEREDIV
                  data.w KONEMINUS
                  data.w KCLIT
                  data.b $80
                  data.w KTOGGL
                  data.w LATEST
                  data.w COMMADIV
                  data.w CURRENT
                  data.w KAT
                  data.w KSTORE
                  data.w HERE
                  data.w KTWOPLUS
                  data.w HEADERLESS
                  data.w KAT
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $0004
                  data.w KTWOPLUS
                  data.w KDUP
                  data.w COMMADIV
                  data.w COMMA
                  data.w KSEMIS
;;
;;    [COMPILE]
;;
_BRACCOMPILE             text.7 $c9, "[COMPILE]"
                  data.w _CREATE    ; link to CREATE
                  data.w $ca98    ; PFAPTR
;;
;;
;;
BRACCOMPILE:         data.w KDOCOL
                  data.w SUBFIND
                  data.w KZEQ
                  data.w KZERO
                  data.w QERROR
                  data.w KDROP
                  data.w CFA
                  data.w COMMA
                  data.w KSEMIS
;;
;;    LITERAL
;;
_LITERAL             text.7 $c7, "LITERAL"
                  data.w _BRACCOMPILE    ; link to [COMPILE]
                  data.w $cab6    ; PFAPTR
;;
;;
;;
LITERAL:         data.w KDOCOL
                  data.w STATE
                  data.w KAT
                  data.w KZBRAN
                  data.w $001c
                  data.w KDUP
                  data.w KLIT
                  data.w $ff00
                  data.w KANDD
                  data.w KZBRAN
                  data.w $000a
                  data.w COMPILE
                  data.w KLIT
                  data.w COMMA
                  data.w KSEMIS
;;
;;
;;
CREATE5:         data.w COMPILE
                  data.w KCLIT
                  data.b $aa
                  data.w $17c5
PAD_DDD:         data.b $f7
;;
;;    DLITERAL
;;
_DLITERAL             text.7 $c8, "DLITERAL"
                  data.w _LITERAL    ; link to LITERAL
                  data.w $cae9    ; PFAPTR
;;
;;
;;
DLITERAL:         data.w KDOCOL
                  data.w STATE
                  data.w KAT
                  data.w KZBRAN
                  data.w $0008
                  data.w KSWAP
                  data.w LITERAL
                  data.w LITERAL
                  data.w KSEMIS
;;
;;    ?STACK
;;
_QSTACK             text.7 $86, "?STACK"
                  data.w _DLITERAL    ; link to DLITERAL
                  data.w $cb06    ; PFAPTR
;;
;;
;;
QSTACK:         data.w KDOCOL
                  data.w KSPAT
                  data.w KCLIT
                  data.b $c2
                  data.w KSWAP
                  data.w KULESS
                  data.w KONE
                  data.w QERROR
                  data.w KSPAT
                  data.w KCLIT
                  data.b $5d
                  data.w KULESS
                  data.w KCLIT
                  data.b $07
                  data.w QERROR
                  data.w KSEMIS
;;
;;    INTERPRET
;;
_INTERPRET             text.7 $89, "INTERPRET"
                  data.w _QSTACK    ; link to ?STACK
                  data.w $cb31    ; PFAPTR
;;
;;
;;
INTERPRET:         data.w KDOCOL
                  data.w SUBFIND
                  data.w KZBRAN
                  data.w $001e
                  data.w STATE
                  data.w KAT
                  data.w KLESS
                  data.w KZBRAN
                  data.w $000a
                  data.w CFA
                  data.w COMMA
                  data.w KBRAN
                  data.w $0006
                  data.w CFA
                  data.w KEXECUTE
                  data.w QSTACK
                  data.w KBRAN
                  data.w $001c
                  data.w HERE
                  data.w NUMBER
                  data.w KDPL
                  data.w KAT
                  data.w KONEPLUS
                  data.w KZBRAN
                  data.w $0008
                  data.w DLITERAL
                  data.w KBRAN
                  data.w $0006
                  data.w KDROP
                  data.w LITERAL
                  data.w QSTACK
                  data.w KBRAN
                  data.w $ffc2
;;
;;    IMMEDIATE
;;
_IMMEDIATE             text.7 $89, "IMMEDIATE"
                  data.w _INTERPRET    ; link to INTERPRET
                  data.w $cb81    ; PFAPTR
;;
;;
;;
IMMEDIATE:         data.w KDOCOL
                  data.w LATEST
                  data.w KCLIT
                  data.b $40
                  data.w KTOGGL
                  data.w KSEMIS
;;
;;    VOCABULARY
;;
_VOCABULARY             text.7 $8a, "VOCABULARY"
                  data.w _IMMEDIATE    ; link to IMMEDIATE
                  data.w $cb9b    ; PFAPTR
;;
;;
;;
VOCABULARY:         data.w KDOCOL
                  data.w LTBUILDS
                  data.w KLIT
                  data.w $a081
                  data.w COMMA
                  data.w CURRENT
                  data.w KAT
                  data.w KTWOMINUS
                  data.w COMMA
                  data.w HERE
                  data.w VOCL
                  data.w KAT
                  data.w COMMA
                  data.w VOCL
                  data.w KSTORE
                  data.w DOESGT
                  data.w KTWOPLUS
                  data.w CONTEXT
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    FORTH
;;
_FORTH             text.7 $c5, "FORTH"
                  data.w _VOCABULARY    ; link to VOCABULARY
                  data.w $cbcd    ; PFAPTR
;;
;;
;;
FORTH:         data.w KDOCOL
                  data.w unk
                  data.w CONTEXT
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    ASSEMBLER
;;
_ASSEMBLER             text.7 $c9, "ASSEMBLER"
                  data.w _FORTH    ; link to FORTH
                  data.w $cbe5    ; PFAPTR
;;
;;
;;
ASSEMBLER:         data.w KDOCOL
                  data.w $c443
                  data.w KBRAN
                  data.w $ffe6
;;
;;    DEFINITIONS
;;
_DEFINITIONS             text.7 $8b, "DEFINITIONS"
                  data.w _ASSEMBLER    ; link to ASSEMBLER
                  data.w $cbfd    ; PFAPTR
;;
;;
;;
DEFINITIONS:         data.w KDOCOL
                  data.w CONTEXT
                  data.w KAT
                  data.w CURRENT
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    (
;;
_OBRAC             text.7 $c1, "("
                  data.w _DEFINITIONS    ; link to DEFINITIONS
                  data.w $cc0f    ; PFAPTR
;;
;;
;;
OBRAC:         data.w KDOCOL
                  data.w KCLIT
                  data.b $29
                  data.w FWORD
                  data.w KSEMIS
;;
;;    QUIT
;;
_QUIT             text.7 $84, "QUIT"
                  data.w _OBRAC    ; link to (
                  data.w $cc21    ; PFAPTR
;;
;;
;;
QUIT:         data.w KDOCOL
                  data.w KZERO
                  data.w BLK
                  data.w KSTORE
                  data.w LBRAC
                  data.w KRPSTO
                  data.w KCR
                  data.w KQUERY
                  data.w INTERPRET
                  data.w STATE
                  data.w KAT
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $0007
                  data.w KPDOTQ
                  data.b $02, "OK"
                  data.w KBRAN
                  data.w $ffe7
;;
;;    ABORT
;;
_OB             text.7 $85, "ABORT"
                  data.w _QUIT    ; link to QUIT
                  data.w $cc50    ; PFAPTR
;;
;;
;;
OB:         data.w KDOCOL
                  data.w KSPSTORE
                  data.w KCR
                  data.w KPDOTQ
                  data.b $0f, " RSC-FORTH V1.6"
                  data.w FORTH
                  data.w DEFINITIONS
                  data.w QUIT
                  data.w KDOCOL
                  data.w KLIT
                  data.w $a55a
                  data.w KDUP
                  data.w KCLDWRM
                  data.w KAT
                  data.w KEQUAL
                  data.w KZEQ
                  data.w KCLIT
                  data.b $17
                  data.w KCAT
                  data.w KCLIT
                  data.b $12
                  data.w KEQUAL
                  data.w KOR
                  data.w KZBRAN
                  data.w $0022
                  data.w KLIT
                  data.w $037e
                  data.w KUPAD
                  data.w KSTORE
                  data.w KLIT
                  data.w UNKNOWN
                  data.w CYLINDER
                  data.w KCLIT
                  data.b $28
                  data.w KCMOVE
                  data.w KLIT
                  data.w _TASK
                  data.w KLIT
                  data.w $0404
                  data.w KCLIT
                  data.b $0b
                  data.w KCMOVE
                  data.w KCLDWRM
                  data.w KSTORE
                  data.w OB
;;
;;    COLD
;;
_COLD             text.7 $84, "COLD"
                  data.w _OB    ; link to ABORT
                  data.w KCOLD+2    ; PFAPTR
;;
;;    S->D
;;
_STOD             text.7 $84, "S->D"
                  data.w _COLD    ; link to COLD
                  data.w KSTOD+2    ; PFAPTR
;;
;;    +-
;;
_PLUSMINUS             text.7 $82, "+-"
                  data.w _STOD    ; link to S->D
                  data.w KPM+2    ; PFAPTR
;;
;;    D+-
;;
_DPLUSMINUS             text.7 $83, "D+-"
                  data.w _PLUSMINUS    ; link to +-
                  data.w KDPLUS1+2    ; PFAPTR
;;
;;    ABS
;;
_ABS             text.7 $83, "ABS"
                  data.w _DPLUSMINUS    ; link to D+-
                  data.w KABS+2    ; PFAPTR
;;
;;    DABS
;;
_DABS             text.7 $84, "DABS"
                  data.w _ABS    ; link to ABS
                  data.w KDABS+2    ; PFAPTR
;;
;;    MIN
;;
_MIN             text.7 $83, "MIN"
                  data.w _DABS    ; link to DABS
                  data.w KMIN+2    ; PFAPTR
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
                  data.w KMMUL+2    ; PFAPTR
;;
;;    M/
;;
_MDIV             text.7 $82, "M/"
                  data.w _MMUL    ; link to M*
                  data.w KMDIV+2    ; PFAPTR
;;
;;    *
;;
_MUL             text.7 $81, "*"
                  data.w _MDIV    ; link to M/
                  data.w KMUL+2    ; PFAPTR
;;
;;    /MOD
;;
_DIVMOD             text.7 $84, "/MOD"
                  data.w _MUL    ; link to *
                  data.w KDIVMOD+2    ; PFAPTR
;;
;;    /
;;
_DIV             text.7 $81, "/"
                  data.w _DIVMOD    ; link to /MOD
                  data.w KDIV_+2    ; PFAPTR
;;
;;    MOD
;;
_MOD             text.7 $83, "MOD"
                  data.w _DIV    ; link to /
                  data.w KMOD_+2    ; PFAPTR
;;
;;    */MOD
;;
_MULDIVMOD             text.7 $85, "*/MOD"
                  data.w _MOD    ; link to MOD
                  data.w KMULDIVMOD+2    ; PFAPTR
;;
;;    */
;;
_MULDIV             text.7 $82, "*/"
                  data.w _MULDIVMOD    ; link to */MOD
                  data.w KMULDIV+2    ; PFAPTR
;;
;;    M/MOD
;;
_MMOD             text.7 $85, "M/MOD"
                  data.w _MULDIV    ; link to */
                  data.w KMDIVMOD+2    ; PFAPTR
;;
;;    +BUF
;;
_PLUSBUF             text.7 $84, "+BUF"
                  data.w _MMOD    ; link to M/MOD
                  data.w $cd45    ; PFAPTR
;;
;;
;;
PLUSBUF:         data.w KDOCOL
                  data.w KLIT
                  data.w $0404
                  data.w KPLUS
                  data.w LIMIT
                  data.w KLIT
                  data.w $0404
                  data.w KSUB
                  data.w KOVER
                  data.w KULESS
                  data.w KZBRAN
                  data.w $0006
                  data.w KDROP
                  data.w FIRST
                  data.w KDUP
                  data.w PREV
                  data.w KAT
                  data.w KSUB
                  data.w KSEMIS
;;
;;    UPDATE
;;
_UPDATE             text.7 $86, "UPDATE"
                  data.w _PLUSBUF    ; link to +BUF
                  data.w $cd76    ; PFAPTR
;;
;;
;;
UPDATE:         data.w KDOCOL
                  data.w PREV
                  data.w KAT
                  data.w KAT
                  data.w KLIT
                  data.w $8000
                  data.w KOR
                  data.w PREV
                  data.w KAT
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    EMPTY-BUFFERS
;;
_EMPTYBUFFERS             text.7 $8d, "EMPTY-BUFFERS"
                  data.w _UPDATE    ; link to UPDATE
                  data.w $cd9e    ; PFAPTR
;;
;;
;;
EMPTYBUFFERS:         data.w KDOCOL
                  data.w FIRST
                  data.w LIMIT
                  data.w KOVER
                  data.w KSUB
                  data.w KERASE
                  data.w FIRST
                  data.w KDUP
                  data.w USE
                  data.w KSTORE
                  data.w PREV
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    BUFFER
;;
_BUFFER             text.7 $86, "BUFFER"
                  data.w _EMPTYBUFFERS    ; link to EMPTY-BUFFERS
                  data.w $cdc3    ; PFAPTR
;;
;;
;;
BUFFER:         data.w KDOCOL
                  data.w USE
                  data.w KAT
                  data.w KDUP
                  data.w KGTR
                  data.w PLUSBUF
                  data.w KZBRAN
                  data.w $fffc
                  data.w USE
                  data.w KSTORE
                  data.w KR
                  data.w KAT
                  data.w KZLT
                  data.w KZBRAN
                  data.w $0014
                  data.w KR
                  data.w KTWOPLUS
                  data.w KR
                  data.w KAT
                  data.w KLIT
                  data.w $7fff
                  data.w KANDD
                  data.w KZERO
                  data.w RW
                  data.w KR
                  data.w KSTORE
                  data.w KR
                  data.w PREV
                  data.w KSTORE
                  data.w KRFROM
                  data.w KTWOPLUS
                  data.w KSEMIS
;;
;;    BLOCK
;;
_BLOCK             text.7 $85, "BLOCK"
                  data.w _BUFFER    ; link to BUFFER
                  data.w $ce0d    ; PFAPTR
;;
;;
;;
BLOCK:         data.w KDOCOL
                  data.w OFFSET
                  data.w KAT
                  data.w KPLUS
                  data.w KGTR
                  data.w PREV
                  data.w KAT
                  data.w KDUP
                  data.w KAT
                  data.w KR
                  data.w KSUB
                  data.w KDUP
                  data.w KPLUS
                  data.w KZBRAN
                  data.w $0032
                  data.w PLUSBUF
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $0012
                  data.w KDROP
                  data.w KR
                  data.w BUFFER
                  data.w KDUP
                  data.w KR
                  data.w KONE
                  data.w RW
                  data.w KTWOMINUS
                  data.w KDUP
                  data.w KAT
                  data.w KR
                  data.w KSUB
                  data.w KDUP
                  data.w KPLUS
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $ffd8
                  data.w KDUP
                  data.w PREV
                  data.w KSTORE
                  data.w KRFROM
                  data.w KDROP
                  data.w KTWOPLUS
                  data.w KSEMIS
;;
;;    FLUSH
;;
_FLUSH             text.7 $85, "FLUSH"
                  data.w _BLOCK    ; link to BLOCK
                  data.w $ce6d    ; PFAPTR
;;
;;
;;
FLUSH:         data.w KDOCOL
                  data.w LIMIT
                  data.w FIRST
                  data.w KSUB
                  data.w KLIT
                  data.w $0404
                  data.w KDIV_
                  data.w KONEPLUS
                  data.w KZERO
                  data.w KDO
                  data.w KLIT
                  data.w $7fff
                  data.w BUFFER
                  data.w KDROP
                  data.w KLOOP
                  data.w $fff6
                  data.w KSEMIS
;;
;;    DUMP
;;
_DUMP             text.7 $84, "DUMP"
                  data.w _FLUSH    ; link to FLUSH
                  data.w $ce98    ; PFAPTR
;;
;;
;;
DUMP:         data.w KDOCOL
                  data.w KZERO
                  data.w KDO
                  data.w KCR
                  data.w KDUP
                  data.w KZERO
                  data.w KCLIT
                  data.b $05
                  data.w KDDOTR
                  data.w KSPACE
                  data.w KCLIT
                  data.b $10
                  data.w KSWAP
                  data.w KOVER
                  data.w KZERO
                  data.w KDO
                  data.w KDUP
                  data.w KCAT
                  data.w KTHREE
                  data.w KDOTR
                  data.w KONEPLUS
                  data.w KLOOP
                  data.w $fff4
                  data.w KSWAP
                  data.w KPLOOP
                  data.w $ffd6
                  data.w KDROP
                  data.w KCR
                  data.w KSEMIS
;;
;;    (LINE)
;;
_PLINE             text.7 $86, "(LINE)"
                  data.w _DUMP    ; link to DUMP
                  data.w $cedb    ; PFAPTR
;;
;;
;;
PLINE:         data.w KDOCOL
                  data.w KGTR
                  data.w KCLIT
                  data.b $40
                  data.w KLIT
                  data.w $0400
                  data.w KMULDIVMOD
                  data.w KRFROM
                  data.w KPLUS
                  data.w BLOCK
                  data.w KPLUS
                  data.w KCLIT
                  data.b $40
                  data.w KSEMIS
;;
;;    .LINE
;;
_DOTLINE             text.7 $85, ".LINE"
                  data.w _PLINE    ; link to (LINE)
                  data.w $ceff    ; PFAPTR
;;
;;
;;
DOTLINE:         data.w KDOCOL
                  data.w PLINE
                  data.w KSUBTRAILING
                  data.w KTYPE
                  data.w KSEMIS
;;
;;    >LINE
;;
_GTLINE             text.7 $85, ">LINE"
                  data.w _DOTLINE    ; link to .LINE
                  data.w $cf13    ; PFAPTR
;;
;;
;;
GTLINE:         data.w KDOCOL
                  data.w SCR
                  data.w KAT
                  data.w PLINE
                  data.w KOVER
                  data.w KSWAP
                  data.w KBLANKS
                  data.w KZERO
                  data.w FWORD
                  data.w HERE
                  data.w KCOUNT
                  data.w KCLIT
                  data.b $40
                  data.w KMIN
                  data.w KROT
                  data.w KSWAP
                  data.w KCMOVE
                  data.w UPDATE
                  data.w KSEMIS
;;
;;    MESSAGE
;;
_FMESSAGE             text.7 $87, "MESSAGE"
                  data.w _GTLINE    ; link to >LINE
                  data.w $cf44    ; PFAPTR
;;
;;
;;
FMESSAGE:         data.w KDOCOL
                  data.w KSUBDUP
                  data.w KZBRAN
                  data.w $0014
                  data.w WARNING
                  data.w KAT
                  data.w KZBRAN
                  data.w $000e
                  data.w KFOUR
                  data.w OFFSET
                  data.w KAT
                  data.w KSUB
                  data.w DOTLINE
                  data.w KSEMIS
                  data.w KDUP
                  data.w KONE
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $0014
                  data.w KDROP
                  data.w KPDOTQ
                  data.b $0b, "STACK EMPTY"
                  data.w KSEMIS
                  data.w KPDOTQ
                  data.b $05, "MSG# "
                  data.w KBASE
                  data.w KAT
                  data.w KDECIMAL
                  data.w KSWAP
                  data.w KDOT
                  data.w KBASE
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    LOAD
;;
_LOAD             text.7 $84, "LOAD"
                  data.w _FMESSAGE    ; link to MESSAGE
                  data.w $cf9d    ; PFAPTR
;;
;;
;;
LOAD:         data.w KDOCOL
                  data.w BLK
                  data.w KAT
                  data.w KGTR
                  data.w KIN
                  data.w KAT
                  data.w KGTR
                  data.w KZERO
                  data.w KIN
                  data.w KSTORE
                  data.w BLK
                  data.w KSTORE
                  data.w INTERPRET
                  data.w KRFROM
                  data.w KIN
                  data.w KSTORE
                  data.w KRFROM
                  data.w BLK
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    -->
;;
_ARROW             text.7 $c3, "-->"
                  data.w _LOAD    ; link to LOAD
                  data.w $cfcd    ; PFAPTR
;;
;;
;;
ARROW:         data.w KDOCOL
                  data.w BLK
                  data.w KAT
                  data.w KZEQ
                  data.w KCLIT
                  data.b $16
                  data.w QERROR
                  data.w KZERO
                  data.w KIN
                  data.w KSTORE
                  data.w KONE
                  data.w BLK
                  data.w KPSTORE
                  data.w KSEMIS
;;
;;    -BCD
;;
_SUBBCD             text.7 $84, "-BCD"
                  data.w _ARROW    ; link to -->
                  data.w $cff1    ; PFAPTR
;;
;;
;;
SUBBCD:         data.w KDOCOL
                  data.w KZERO
                  data.w KCLIT
                  data.b $0a
                  data.w KUDIV
                  data.w KCLIT
                  data.b $10
                  data.w KMUL
                  data.w KOR
                  data.w KSEMIS
;;
;;    B/BUF
;;
_BBUF             text.7 $85, "B/BUF"
                  data.w _SUBBCD    ; link to -BCD
                  data.w $d00d    ; PFAPTR
;;
;;
;;
BBUF:         data.w KDOCON
                  data.w $0400
;;
;;    B/SCR
;;
_BSCR             text.7 $85, "B/SCR"
                  data.w _BBUF    ; link to B/BUF
                  data.w $d01b    ; PFAPTR
;;
;;
;;
BSCR:         data.w KDOCON
                  data.w $0001
;;
;;    R/W
;;
_RW             text.7 $83, "R/W"
                  data.w _BSCR    ; link to B/SCR
                  data.w $d027    ; PFAPTR
;;
;;
;;
RW:         data.w KDOCOL
                  data.w KURW
                  data.w KAT
                  data.w KEXECUTE
                  data.w KSEMIS
;;
;;    DISK
;;
_DISK             text.7 $84, "DISK"
                  data.w _RW    ; link to R/W
                  data.w KDISK+2    ; PFAPTR
;;
;;    SELECT
;;
_SELECT             text.7 $86, "SELECT"
                  data.w _DISK    ; link to DISK
                  data.w KSELECT+2    ; PFAPTR
;;
;;    DREAD
;;
_DREAD             text.7 $85, "DREAD"
                  data.w _SELECT    ; link to SELECT
                  data.w KDREAD+2    ; PFAPTR
;;
;;    DWRITE
;;
_DWRITE             text.7 $86, "DWRITE"
                  data.w _DREAD    ; link to DREAD
                  data.w KDWRITE+2    ; PFAPTR
;;
;;    INIT
;;
_INIT             text.7 $84, "INIT"
                  data.w _DWRITE    ; link to DWRITE
                  data.w KINIT+2    ; PFAPTR
;;
;;    SEEK
;;
_SEEK             text.7 $84, "SEEK"
                  data.w _INIT    ; link to INIT
                  data.w KSEEK+2    ; PFAPTR
;;
;;    '
;;
_TICK             text.7 $c1, "'"
                  data.w _SEEK    ; link to SEEK
                  data.w $d072    ; PFAPTR
;;
;;
;;
TICK:         data.w KDOCOL
                  data.w SUBFIND
                  data.w KZEQ
                  data.w KZERO
                  data.w QERROR
                  data.w KDROP
                  data.w LITERAL
                  data.w KSEMIS
;;
;;    H/C
;;
_HC             text.7 $83, "H/C"
                  data.w _TICK    ; link to '
                  data.w $d08a    ; PFAPTR
;;
;;
;;
HC:         data.w KDOCOL
                  data.w KONE
                  data.w HEADERLESS
                  data.w KSTORE
                  data.w KDUP
                  data.w DPDIV
                  data.w KSTORE
                  data.w KCR
                  data.w KPDOTQ
                  data.b $06, "HEADS/"
                  data.w KDOT
                  data.w KCR
                  data.w KPDOTQ
                  data.b $06, "CODES/"
                  data.w HERE
                  data.w KDOT
                  data.w KSEMIS
;;
;;    HWORD
;;
_HWORD             text.7 $85, "HWORD"
                  data.w _HC    ; link to H/C
                  data.w $d0c0    ; PFAPTR
;;
;;
;;
HWORD:         data.w KDOCOL
                  data.w HEADERLESS
                  data.w KAT
                  data.w KZBRAN
                  data.w $003e
                  data.w LATEST
                  data.w PFAPTR
                  data.w CFA
                  data.w KDUP
                  data.w KAT
                  data.w KOVER
                  data.w KTWOPLUS
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $000a
                  data.w HEREDIV
                  data.w KTWOPLUS
                  data.w KOVER
                  data.w KSTORE
                  data.w HERE
                  data.w KOVER
                  data.w KDUP
                  data.w DP
                  data.w KSTORE
                  data.w KSUB
                  data.w HEREDIV
                  data.w KTWOPLUS
                  data.w HEREDIV
                  data.w KTWOMINUS
                  data.w KSTORE
                  data.w HEREDIV
                  data.w KSWAP
                  data.w KDUP
                  data.w ALLOTDIV
                  data.w KCMOVE
                  data.w KSEMIS
;;
;;    ?KERNEL
;;
_QKERNEL             text.7 $87, "?KERNEL"
                  data.w _HWORD    ; link to HWORD
                  data.w $d114    ; PFAPTR
;;
;;
;;
QKERNEL:         data.w KDOCOL
                  data.w TICK
                  data.w CFA
                  data.w KLIT
                  data.w KINITVAR
                  data.w KULESS
                  data.w KZBRAN
                  data.w $0011
                  data.w KPDOTQ
                  data.b $08, "OUTSIDE "
                  data.w KBRAN
                  data.w $000c
                  data.w KPDOTQ
                  data.b $07, "INSIDE "
                  data.w KSEMIS
;;
;;    AUTOSTART
;;
_AUTOSTART             text.7 $89, "AUTOSTART"
                  data.w _QKERNEL    ; link to ?KERNEL
                  data.w $d14d    ; PFAPTR
;;
;;
;;
AUTOSTART:         data.w KDOCOL
                  data.w TICK
                  data.w KAT
                  data.w KDUP
                  data.w KLIT
                  data.w $c84a
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $0011
                  data.w KPDOTQ
                  data.b $0a, "NAME ERROR"
                  data.w QUIT
                  data.w KOVER
                  data.w KTWOPLUS
                  data.w KSTORE
                  data.w KLIT
                  data.w $a55a
                  data.w KSWAP
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    FORGET
;;
_FORGET             text.7 $86, "FORGET"
                  data.w _AUTOSTART    ; link to AUTOSTART
                  data.w $d189    ; PFAPTR
;;
;;
;;
FORGET:         data.w KDOCOL
                  data.w TICK
                  data.w NFA
                  data.w KDUP
                  data.w $d1fe
                  data.w KSWAP
                  data.w FENCE
                  data.w KAT
                  data.w KULESS
                  data.w KOR
                  data.w KCLIT
                  data.b $15
                  data.w QERROR
                  data.w KGTR
                  data.w VOCL
                  data.w KAT
                  data.w KR
                  data.w KOVER
                  data.w KULESS
                  data.w KZBRAN
                  data.w $0012
                  data.w FORTH
                  data.w DEFINITIONS
                  data.w KAT
                  data.w KDUP
                  data.w VOCL
                  data.w KSTORE
                  data.w KBRAN
                  data.w $ffe8
                  data.w KDUP
                  data.w KFOUR
                  data.w KSUB
                  data.w PFAPTR
                  data.w LFA
                  data.w KAT
                  data.w KDUP
                  data.w $d1fe
                  data.w KSWAP
                  data.w KR
                  data.w KULESS
                  data.w KOR
                  data.w KZBRAN
                  data.w $ffec
                  data.w KOVER
                  data.w KTWOMINUS
                  data.w KSTORE
                  data.w KAT
                  data.w KSUBDUP
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $ffd6
                  data.w KRFROM
                  data.w KDUP
                  data.w PFAPTR
                  data.w CFA
                  data.w DP
                  data.w KSTORE
                  data.w DPDIV
                  data.w KSTORE
                  data.w KSEMIS
                  data.w KDOCOL
                  data.w KLIT
                  data.w UNKNOWN
                  data.w KOVER
                  data.w KULESS
                  data.w KOVER
                  data.w KLIT
                  data.w PADDINGD
                  data.w KULESS
                  data.w KANDD
                  data.w KSEMIS
                  data.w KDOCOL
                  data.w HERE
                  data.w KSUB
                  data.w COMMA
                  data.w KSEMIS
;;
;;    BEGIN
;;
_BEGIN             text.7 $c5, "BEGIN"
                  data.w _FORGET    ; link to FORGET
                  data.w $d22a    ; PFAPTR
;;
;;
;;
BEGIN:         data.w KDOCOL
                  data.w QCOMP
                  data.w HERE
                  data.w KONE
                  data.w KSEMIS
;;
;;    ENDIF
;;
_FENDIF             text.7 $c5, "ENDIF"
                  data.w _BEGIN    ; link to BEGIN
                  data.w $d23e    ; PFAPTR
;;
;;
;;
FENDIF:         data.w KDOCOL
                  data.w QCOMP
                  data.w KTWO
                  data.w QPAIRS
                  data.w HERE
                  data.w KOVER
                  data.w KSUB
                  data.w KSWAP
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    THEN
;;
_FTHEN             text.7 $c4, "THEN"
                  data.w _FENDIF    ; link to ENDIF
                  data.w $d25b    ; PFAPTR
;;
;;
;;
FTHEN:         data.w KDOCOL
                  data.w FENDIF
                  data.w KSEMIS
;;
;;    DO
;;
_FDO             text.7 $c2, "DO"
                  data.w _FTHEN    ; link to THEN
                  data.w $d268    ; PFAPTR
;;
;;
;;
FDO:         data.w KDOCOL
                  data.w COMPILE
                  data.w KDO
                  data.w HERE
                  data.w KTHREE
                  data.w KSEMIS
;;
;;    LOOP
;;
_LOOP             text.7 $c4, "LOOP"
                  data.w _FDO    ; link to DO
                  data.w $d27d    ; PFAPTR
;;
;;
;;
LOOP:         data.w KDOCOL
                  data.w KTHREE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w KLOOP
                  data.w $d214
                  data.w KSEMIS
;;
;;    +LOOP
;;
_PLOOP             text.7 $c5, "+LOOP"
                  data.w _LOOP    ; link to LOOP
                  data.w $d295    ; PFAPTR
;;
;;
;;
PLOOP:         data.w KDOCOL
                  data.w KTHREE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w KPLOOP
                  data.w $d214
                  data.w KSEMIS
;;
;;    UNTIL
;;
_FUNTIL             text.7 $c5, "UNTIL"
                  data.w _PLOOP    ; link to +LOOP
                  data.w $d2ad    ; PFAPTR
;;
;;
;;
FUNTIL:         data.w KDOCOL
                  data.w KONE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w KZBRAN
                  data.w $d214
                  data.w KSEMIS
;;
;;    END
;;
_FEND             text.7 $c3, "END"
                  data.w _FUNTIL    ; link to UNTIL
                  data.w $d2c3    ; PFAPTR
;;
;;
;;
FEND:         data.w KDOCOL
                  data.w FUNTIL
                  data.w KSEMIS
;;
;;    AGAIN
;;
_AGAIN             text.7 $c5, "AGAIN"
                  data.w _FEND    ; link to END
                  data.w $d2d3    ; PFAPTR
;;
;;
;;
AGAIN:         data.w KDOCOL
                  data.w KONE
                  data.w QPAIRS
                  data.w COMPILE
                  data.w KBRAN
                  data.w $d214
                  data.w KSEMIS
;;
;;    REPEAT
;;
_FREPEAT             text.7 $c6, "REPEAT"
                  data.w _AGAIN    ; link to AGAIN
                  data.w $d2ec    ; PFAPTR
;;
;;
;;
FREPEAT:         data.w KDOCOL
                  data.w KGTR
                  data.w KGTR
                  data.w AGAIN
                  data.w KRFROM
                  data.w KRFROM
                  data.w KTWOMINUS
                  data.w FENDIF
                  data.w KSEMIS
;;
;;    IF
;;
_FIF             text.7 $c2, "IF"
                  data.w _FREPEAT    ; link to REPEAT
                  data.w $d305    ; PFAPTR
;;
;;
;;
FIF:         data.w KDOCOL
                  data.w COMPILE
                  data.w KZBRAN
                  data.w $c577
                  data.w KZERO
                  data.w COMMA
                  data.w KTWO
                  data.w KSEMIS
;;
;;    ELSE
;;
_FELSE             text.7 $c4, "ELSE"
                  data.w _FIF    ; link to IF
                  data.w $d31e    ; PFAPTR
;;
;;
;;
FELSE:         data.w KDOCOL
                  data.w KTWO
                  data.w QPAIRS
                  data.w COMPILE
                  data.w KBRAN
                  data.w $c577
                  data.w KZERO
                  data.w COMMA
                  data.w KSWAP
                  data.w KTWO
                  data.w FENDIF
                  data.w KTWO
                  data.w KSEMIS
;;
;;    WHILE
;;
_FWHILE             text.7 $c5, "WHILE"
                  data.w _FELSE    ; link to ELSE
                  data.w $d342    ; PFAPTR
;;
;;
;;
FWHILE:         data.w KDOCOL
                  data.w FIF
                  data.w KTWOPLUS
                  data.w KSEMIS
;;
;;    SPACES
;;
_SPACES             text.7 $86, "SPACES"
                  data.w _FWHILE    ; link to WHILE
                  data.w KSPACES+2    ; PFAPTR
;;
;;    <#
;;
_LTNUM             text.7 $82, "<#"
                  data.w _SPACES    ; link to SPACES
                  data.w KLEQ+2    ; PFAPTR
;;
;;    #>
;;
_NUMGT             text.7 $82, "#>"
                  data.w _LTNUM    ; link to <#
                  data.w KHASHGT+2    ; PFAPTR
;;
;;    SIGN
;;
_SIGN             text.7 $84, "SIGN"
                  data.w _NUMGT    ; link to #>
                  data.w KSIGN+2    ; PFAPTR
;;
;;    #
;;
_NUM             text.7 $81, "#"
                  data.w _SIGN    ; link to SIGN
                  data.w KHASH+2    ; PFAPTR
;;
;;    #S
;;
_NUMS             text.7 $82, "#S"
                  data.w _NUM    ; link to #
                  data.w KHASHS+2    ; PFAPTR
;;
;;    D.R
;;
_DDOTR             text.7 $83, "D.R"
                  data.w _NUMS    ; link to #S
                  data.w KDDOTR+2    ; PFAPTR
;;
;;    D.
;;
_DDOT             text.7 $82, "D."
                  data.w _DDOTR    ; link to D.R
                  data.w KDDOT+2    ; PFAPTR
;;
;;    .R
;;
_DOTR             text.7 $82, ".R"
                  data.w _DDOT    ; link to D.
                  data.w KDOTR+2    ; PFAPTR
;;
;;    .
;;
_DOT             text.7 $81, "."
                  data.w _DOTR    ; link to .R
                  data.w KDOT+2    ; PFAPTR
;;
;;    ?
;;
_Q             text.7 $81, "?"
                  data.w _DOT    ; link to .
                  data.w KQ+2    ; PFAPTR
;;
;;    LIST
;;
_FLIST             text.7 $84, "LIST"
                  data.w _Q    ; link to ?
                  data.w $d3a4    ; PFAPTR
;;
;;
;;
FLIST:         data.w KDOCOL
                  data.w KBASE
                  data.w KAT
                  data.w KSWAP
                  data.w KDECIMAL
                  data.w KCR
                  data.w KDUP
                  data.w SCR
                  data.w KSTORE
                  data.w KPDOTQ
                  data.b $06, "SCR # "
                  data.w KDOT
                  data.w KCLIT
                  data.b $10
                  data.w KZERO
                  data.w KDO
                  data.w KCR
                  data.w $c086
                  data.w KTHREE
                  data.w KDOTR
                  data.w KSPACE
                  data.w $c086
                  data.w SCR
                  data.w KAT
                  data.w DOTLINE
                  data.w KLOOP
                  data.w $ffec
                  data.w KBASE
                  data.w KSTORE
                  data.w KCR
                  data.w KSEMIS
;;
;;    INDEX
;;
_INDEX             text.7 $85, "INDEX"
                  data.w _FLIST    ; link to LIST
                  data.w $d3f0    ; PFAPTR
;;
;;
;;
INDEX:         data.w KDOCOL
                  data.w KCR
                  data.w KONEPLUS
                  data.w KSWAP
                  data.w KDO
                  data.w KCR
                  data.w $c086
                  data.w KTHREE
                  data.w KDOTR
                  data.w KSPACE
                  data.w KZERO
                  data.w $c086
                  data.w DOTLINE
                  data.w KQTERM
                  data.w KZBRAN
                  data.w $0004
                  data.w KLEAVE
                  data.w KLOOP
                  data.w $ffe6
                  data.w KPDOTQ
                  data.b $01, ""
                  data.w KSEMIS
                  data.w KDOCOL
                  data.w PFAPTR
                  data.w LFA
                  data.w KAT
                  data.w KDUP
                  data.w KZEQ
                  data.w KQTERM
                  data.w KOR
                  data.w KZEQ
                  data.w KSEMIS
                  data.w KDOCOL
                  data.w KDUP
                  data.w KTWODUP
                  data.w PFAPTR
                  data.w KZERO
                  data.w KCLIT
                  data.b $05
                  data.w KDDOTR
                  data.w KSPACE
                  data.w ID
                  data.w KCLIT
                  data.b $0c
                  data.w KROT
                  data.w KCAT
                  data.w KCLIT
                  data.b $1f
                  data.w KANDD
                  data.w KSUB
                  data.w KSPACES
                  data.w KSEMIS
;;
;;    VLIST
;;
_VLIST             text.7 $85, "VLIST"
                  data.w _INDEX    ; link to INDEX
                  data.w $d45f    ; PFAPTR
;;
;;
;;
VLIST:         data.w KDOCOL
                  data.w KBASE
                  data.w KAT
                  data.w KHEX
                  data.w KCR
                  data.w CONTEXT
                  data.w KAT
                  data.w KAT
                  data.w $d42e
                  data.w $d41a
                  data.w KZBRAN
                  data.w $001e
                  data.w $d42e
                  data.w $d41a
                  data.w KZBRAN
                  data.w $0016
                  data.w $d42e
                  data.w $d41a
                  data.w KZBRAN
                  data.w $000e
                  data.w $d42e
                  data.w KCR
                  data.w $d41a
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $ffde
                  data.w KDROP
                  data.w KBASE
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    MON
;;
_MON             text.7 $83, "MON"
                  data.w _VLIST    ; link to VLIST
                  data.w $d4a3    ; PFAPTR
;;
;;
;;
MON:         data.w KDOCOL
                  data.w KMON
                  data.w KSEMIS
;;
;;    .S
;;
_DOTS             text.7 $82, ".S"
                  data.w _MON    ; link to MON
                  data.w $d4b0    ; PFAPTR
;;
;;
;;
DOTS:         data.w KDOCOL
                  data.w KSZ
                  data.w KAT
                  data.w KSPAT
                  data.w KSUB
                  data.w KTWO
                  data.w KDIV_
                  data.w KDUP
                  data.w KONE
                  data.w KGT
                  data.w KZBRAN
                  data.w $0014
                  data.w KONE
                  data.w KDO
                  data.w $c086
                  data.w KPICK
                  data.w KCR
                  data.w KDOT
                  data.w KLOOP
                  data.w $fff6
                  data.w KSEMIS
                  data.w KCR
                  data.w KPDOTQ
                  data.b $06, "EMPTY "
                  data.w KDROP
                  data.w KSEMIS
;;
;;    C,CON
;;
_CCON             text.7 $85, "C,CON"
                  data.w _DOTS    ; link to .S
                  data.w $d4f3    ; PFAPTR
;;
;;
;;
CCON:         data.w KDOCOL
                  data.w LTBUILDS
                  data.w CCOMMA
                  data.w IMMEDIATE
                  data.w DOESGT
                  data.w KCAT
                  data.w STATE
                  data.w KAT
                  data.w KZBRAN
                  data.w $000a
                  data.w KLIT
                  data.w KCLIT
                  data.b $97
                  data.w $aac5
                  data.w $17c5
                  data.w $c6f7
                  data.w $4e49
                  data.w $4654
                  data.w $c74c
                  data.w _CCON
                  data.w $d51c
                  data.w KDOES
                  data.w $d4fb
                  data.w $c64a
                  data.w $4e49
                  data.w $5654
                  data.w $c345
                  data.w $d50f
                  data.w $d52c
                  data.w KDOES
                  data.w $d4fb
                  data.w $c65b
                  data.w $5249
                  data.w $5651
                  data.w $c345
                  data.w $d51f
                  data.w $d53c
                  data.w KDOES
                  data.w $d4fb
                  data.w $c65b
                  data.w $4d4e
                  data.w $5649
                  data.w $c345
                  data.w $d52f
                  data.w $d54c
                  data.w KDOES
                  data.w $d4fb
                  data.w $c242
                  data.w $c150
                  data.w $d53f
                  data.w $d558
                  data.w KDOES
                  data.w $d4fb
                  data.w $c200
                  data.w $c250
                  data.w $d54f
                  data.w $d564
                  data.w KDOES
                  data.w $d4fb
                  data.w $c201
                  data.w $c350
                  data.w $d55b
                  data.w $d570
                  data.w KDOES
                  data.w $d4fb
                  data.w $c202
                  data.w $c450
                  data.w $d567
                  data.w $d57c
                  data.w KDOES
                  data.w $d4fb
                  data.w $c203
                  data.w $c550
                  data.w $d573
                  data.w $d588
                  data.w KDOES
                  data.w $d4fb
                  data.w _OVER
                  data.w _NFA
                  data.w $d57f
                  data.w $d594
                  data.w KDOES
                  data.w $d4fb
                  data.w $c205
                  data.w $c750
                  data.w $d58b
                  data.w $d5a0
                  data.w KDOES
                  data.w $d4fb
                  data.w $c306
                  data.w $4649
                  data.w $97d2
                  data.w $add5
                  data.w _ROT
                  data.w $fbf9
                  data.w $11d4
                  data.w $49c3
                  data.w $d245
                  data.w $d5a3
                  data.w $d5ba
                  data.w KDOES
                  data.w $d4fb
                  data.w pad
                  data.w $434d
                  data.w $b0d2
                  data.w _COUNT
                  data.w _ROT
                  data.w $fbf9
                  data.w $14d4
                  data.w $53c4
                  data.w $4343
                  data.w $bdd2
                  data.w $d5d5
                  data.w _ROT
                  data.w $fbf9
                  data.w $15d4
                  data.w $53c4
                  data.w $5343
                  data.w CREATE5
                  data.w $e3d5
                  data.w _ROT
                  data.w $fbf9
                  data.w $16d4
;;
;;    SCDR
;;
_SCDR             text.7 $c4, "SCDR"
                  data.w $d5d8    ; link to C,CON
                  data.w $d5f1    ; PFAPTR
;;
;;
;;
SCDR:         data.w KDOES
                  data.w $d4fb
QQQ:         data.b $17
;;
;;    MEMTOP
;;
_MEMTOP             text.7 $86, "MEMTOP"
                  data.w _SCDR    ; link to SCDR
                  data.w $d602    ; PFAPTR
;;
;;
;;
MEMTOP:         data.w $74db
                  data.w $e5f8
                  data.w $daf7
                  data.w $58c3
                  data.w $0ef8
                  data.w $08f4
                  data.w $3008
                  data.w $ccf9
                  data.w $58c3
                  data.w $9cf8
                  data.w $17cd
_CASEPAD:         data.b $f7
;;
;;    CASE:
;;
_CASE             text.7 $85, "CASE:"
                  data.w _MEMTOP    ; link to MEMTOP
                  data.w $d622    ; PFAPTR
;;
;;
;;
CASE:         data.w KDOCOL
                  data.w LTBUILDS
                  data.w SMUDGE
                  data.w STORCSP
                  data.w RBRAC
                  data.w KLIT
                  data.w $ff87
                  data.w HERE
                  data.w KTWOMINUS
                  data.w KSTORE
                  data.w KLIT
                  data.w KDOES
                  data.w CSTOR
;;
;;    EEC!
;;
_EECSTOR             text.7 $84, "EEC!"
                  data.w _CASE    ; link to CASE:
                  data.w KEECSTORE+2    ; PFAPTR
;;
;;    BANKC!
;;
_BANKCSTOR             text.7 $86, "BANKC!"
                  data.w _EECSTOR    ; link to EEC!
                  data.w KBANKCSTOR+2    ; PFAPTR
;;
;;    BANKC@
;;
_BANKCAT             text.7 $86, "BANKC@"
                  data.w _BANKCSTOR    ; link to BANKC!
                  data.w KBANKCAT+2    ; PFAPTR
;;
;;    BANKEEC!
;;
_BANKEECSTOR             text.7 $88, "BANKEEC!"
                  data.w _BANKCAT    ; link to BANKC@
                  data.w KBANKEECS+2    ; PFAPTR
;;
;;    BANKEXECUTE
;;
_BANKEXECUTE             text.7 $8b, "BANKEXECUTE"
                  data.w _BANKEECSTOR    ; link to BANKEEC!
                  data.w KBANKEXEC+2    ; PFAPTR
;;
;;    FMTRK
;;
_FMTRK             text.7 $85, "FMTRK"
                  data.w _BANKEXECUTE    ; link to BANKEXECUTE
                  data.w $d682    ; PFAPTR
;;
;;
;;
FMTRK:         data.w $d682
          TXA 
          PHA 
          LDA #$02
          JSR $f460
          LDA #$f4
          LDY #$01
          STA KDSK_STATUS
          LDX #$31
          LDA #$4e
          BIT KDSK_CTL
          BVS $d694
          STA KDSK_DATA
          DEX 
          BNE $d694
          BIT KDSK_CTL
          BVS $d69f
          STA KDSK_DATA
          LDX #$0b
          LDA #$00
          BIT KDSK_CTL
          BVS $d6ab
          STA KDSK_DATA
          DEX 
          BNE $d6ab
          BIT KDSK_CTL
          BVS $d6b6
          STA KDSK_DATA
          LDX #$02
          LDA #$f5
          BIT KDSK_CTL
          BVS $d6c2
          STA KDSK_DATA
          DEX 
          BNE $d6c2
          BIT KDSK_CTL
          BVS $d6cd
          STA KDSK_DATA
          LDA #$fe
          BIT KDSK_CTL
          BVS $d6d7
          STA KDSK_DATA
          LDA KN
          BIT KDSK_CTL
          BVS $d6e1
          STA KDSK_DATA
          LDA KNP2
          BIT KDSK_CTL
          BVS $d6eb
          STA KDSK_DATA
          BIT KDSK_CTL
          BVS $d6f3
          STY KDSK_DATA
          LDA #$01
          BIT KDSK_CTL
          BVS $d6fd
          STA KDSK_DATA
          LDA #$f7
          BIT KDSK_CTL
          BVS $d707
          STA KDSK_DATA
          LDX #$15
          LDA #$4e
          BIT KDSK_CTL
          BVS $d713
          STA KDSK_DATA
          DEX 
          BNE $d713
          BIT KDSK_CTL
          BVS $d71e
          STA KDSK_DATA
          LDX #$0b
          LDA #$00
          BIT KDSK_CTL
          BVS $d72a
          STA KDSK_DATA
          DEX 
          BNE $d72a
          BIT KDSK_CTL
          BVS $d735
          STA KDSK_DATA
          LDX #$02
          LDA #$f5
          BIT KDSK_CTL
          BVS $d741
          STA KDSK_DATA
          DEX 
          BNE $d741
          BIT KDSK_CTL
          BVS $d74c
          STA KDSK_DATA
          LDX #$ff
          LDA #$fb
          BIT KDSK_CTL
          BVS $d758
          STA KDSK_DATA
          LDA #$20
          BIT KDSK_CTL
          BVS $d762
          STA KDSK_DATA
          DEX 
          BNE $d762
          BIT KDSK_CTL
          BVS $d76d
          STA KDSK_DATA
          LDA #$f7
          BIT KDSK_CTL
          BVS $d777
          STA KDSK_DATA
          LDX #$35
          LDA #$4e
          BIT KDSK_CTL
          BVS $d783
          STA KDSK_DATA
          DEX 
          BNE $d783
          BIT KDSK_CTL
          BVS $d78e
          STA KDSK_DATA
          INY 
          CPY #$11
          BEQ $d7b2
          BIT KDSK_CTL
          BVS $d79b
          STX KDSK_DATA
          LDX #$09
          LDA #$00
          BIT KDSK_CTL
          BVS $d7a7
          STA KDSK_DATA
          JMP $d6ab
          LDY #$4e
          BIT KDSK_CTL
          BVS $d7b4
          BPL $d7c1
          STY KDSK_DATA
          JMP $d7b4
          PLA 
          TAX 
          JMP KPOPTWO
;;
;;    FORMAT
;;
_FORMAT             text.7 $86, "FORMAT"
                  data.w _FMTRK    ; link to FMTRK
                  data.w $d7d3    ; PFAPTR
;;
;;
;;
FORMAT:         data.w KDOCOL
                  data.w KTWO
                  data.w KMUL
                  data.w KSWAP
                  data.w KZERO
                  data.w KDO
                  data.w KDUP
                  data.w KONEPLUS
                  data.w KSELECT
                  data.w KR
                  data.w KSEEK
                  data.w KONE
                  data.w KR
                  data.w FMTRK
                  data.w KDUP
                  data.w KSELECT
                  data.w KZERO
                  data.w KR
                  data.w FMTRK
                  data.w KLOOP
                  data.w $ffe4
                  data.w KDROP
                  data.w KSEMIS
;;
;;    ;DUMP
;;
_DUMP             text.7 $85, ";DUMP"
                  data.w _FORMAT    ; link to FORMAT
                  data.w $d80b    ; PFAPTR
;;
;;
;;
DUMP:         data.w KDOCOL
                  data.w KPDOTQ
                  data.b $01, ";"
                  data.w KHZ
                  data.w KAT
                  data.w KGTR
                  data.w KZERO
                  data.w KHZ
                  data.w KSTORE
                  data.w KTWODUP
                  data.w CODE2
                  data.w CODE1
                  data.w KBOUNDS
                  data.w KDO
                  data.w KR
                  data.w KCAT
                  data.w CODE2
                  data.w KLOOP
                  data.w $fff8
                  data.w KHZ
                  data.w KAT
                  data.w CODE1
                  data.w KCR
                  data.w KRFROM
                  data.w KHZ
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    ADMP
;;
_ADMP             text.7 $84, "ADMP"
                  data.w _DUMP    ; link to ;DUMP
                  data.w $d84a    ; PFAPTR
;;
;;
;;
ADMP:         data.w KDOCOL
                  data.w KCR
                  data.w KONE
                  data.w KGTR
                  data.w KTWODUP
                  data.w KONEPLUS
                  data.w KSWAP
                  data.w KSUB
                  data.w KSUBDUP
                  data.w KZBRAN
                  data.w $001f
                  data.w KCLIT
                  data.b $18
                  data.w KMIN
                  data.w KGTR
                  data.w KOVER
                  data.w KR
                  data.w DUMP
                  data.w KSWAP
                  data.w KRFROM
                  data.w KPLUS
                  data.w KSWAP
                  data.w KRFROM
                  data.w KONEPLUS
                  data.w KBRAN
                  data.w $ffd5
                  data.w KRFROM
                  data.w KPDOTQ
                  data.b $01, ";"
                  data.w KZERO
                  data.w CODE2
                  data.w KDUP
                  data.w CODE1
                  data.w CODE1
                  data.w KCR
                  data.w KTWODROP
                  data.w KSEMIS
;;
;;
;;
CODE1:         data.w $d893
          LDA KPortB,X
          JSR $d8a5
          JMP $d89d
;;
;;
;;
CODE2:         data.w $d89d
          LDA KPortA,X
          JSR $d8a5
          JMP KPOP
          PHA 
          LSR A
          LSR A
          LSR A
          LSR A
          JSR $d8be
          PLA 
          PHA 
          CLC 
          ADC $0352
          STA $0352
          BCC $d8bb
          INC $0353
          PLA 
          AND #$0f
          CLC 
          ADC #$30
          CMP #$3a
          BCC $d8c7
          ADC #$06
          JMP $f5ec
NAMES: data.b "M REARDON R DUMSE"
Z1:         data.b $00
CRIGHT: data.b "COPYRIGHT 1983 ROCKWELL "
;;
;;    N
;;
_N             text.7 $81, "N"
                  data.w $0332    ; link to ADMP
                  data.w $d8fc    ; PFAPTR
;;
;;
;;
N:         data.w KDOCON
                  data.w $0051
;;
;;    IP
;;
_IP             text.7 $82, "IP"
                  data.w _N    ; link to N
                  data.w $d907    ; PFAPTR
;;
;;
;;
IP:         data.w KDOCON
                  data.w $004e
;;
;;    W
;;
_W             text.7 $81, "W"
                  data.w _IP    ; link to IP
                  data.w $d911    ; PFAPTR
;;
;;
;;
W:         data.w KDOCON
                  data.w $004c
;;
;;    UP
;;
_UP             text.7 $82, "UP"
                  data.w _W    ; link to W
                  data.w $d91c    ; PFAPTR
;;
;;
;;
UP:         data.w KDOCON
                  data.w $0048
;;
;;    XSAVE
;;
_XSAVE             text.7 $85, "XSAVE"
                  data.w _UP    ; link to UP
                  data.w $d92a    ; PFAPTR
;;
;;
;;
XSAVE:         data.w KDOCON
                  data.w $0059
;;
;;    NEXT
;;
_NEXT             text.7 $84, "NEXT"
                  data.w _XSAVE    ; link to XSAVE
                  data.w $d937    ; PFAPTR
;;
;;
;;
NEXT:         data.w KDOCON
                  data.w $f428
;;
;;    PUSH
;;
_PUSH             text.7 $84, "PUSH"
                  data.w _NEXT    ; link to NEXT
                  data.w $d944    ; PFAPTR
;;
;;
;;
PUSH:         data.w KDOCON
                  data.w $f421
;;
;;    PUT
;;
_PUT             text.7 $83, "PUT"
                  data.w _PUSH    ; link to PUSH
                  data.w $d950    ; PFAPTR
;;
;;
;;
PUT:         data.w KDOCON
                  data.w $f423
;;
;;    POP
;;
_POP             text.7 $83, "POP"
                  data.w _PUT    ; link to PUT
                  data.w $d95c    ; PFAPTR
;;
;;
;;
POP:         data.w KDOCON
                  data.w $f508
;;
;;    POPTWO
;;
_POPTWO             text.7 $86, "POPTWO"
                  data.w _POP    ; link to POP
                  data.w $d96b    ; PFAPTR
;;
;;
;;
POPTWO:         data.w KDOCON
                  data.w $f506
;;
;;    PUSH0A
;;
_PUSH0A             text.7 $86, "PUSH0A"
                  data.w _POPTWO    ; link to POPTWO
                  data.w $d97a    ; PFAPTR
;;
;;
;;
PUSH0A:         data.w KDOCON
                  data.w $f6ed
;;
;;    PUT0A
;;
_PUT0A             text.7 $85, "PUT0A"
                  data.w _PUSH0A    ; link to PUSH0A
                  data.w $d988    ; PFAPTR
;;
;;
;;
PUT0A:         data.w KDOCON
                  data.w $f84f
;;
;;    BINARY
;;
_BINARY             text.7 $86, "BINARY"
                  data.w _PUT0A    ; link to PUT0A
                  data.w $d997    ; PFAPTR
;;
;;
;;
BINARY:         data.w KDOCON
                  data.w $f6c9
;;
;;    SETUP
;;
_SETUP             text.7 $85, "SETUP"
                  data.w _BINARY    ; link to BINARY
                  data.w $d9a5    ; PFAPTR
;;
;;
;;
SETUP:         data.w KDOCON
                  data.w $f460
UNK1:         data.b $09, $09, $05, $15, $15, $01, $11, $80, $09, $80, $0d, $1d, $19, $80, $80, $80
        data.b $80, $00, $04, $14, $14, $80, $80, $80, $80, $80, $0c, $1c, $1c, $80, $80, $2c
;;
;;
;;
UNK2:         data.w KCAT
                  data.w MODE
                  data.w KSTORE
                  data.w KSEMIS
;;
;;    .A
;;
DOTA             text.7 $82, ".A"
                  data.w _SETUP    ; link to SETUP
                  data.w $d9d8    ; PFAPTR
                  data.w KDOES
                  data.w UNK2
                  data.w $8100
                  data.w $cfa3
                  data.w $e3d9
                  data.w $c5d9
                  data.w $c7f9
                  data.w $01d9
                  data.w $4d83
                  data.w $cd45
                  data.w $d9db
                  data.w $d9f0
;;
;;
;;
UNK3:         data.w KDOES
                  data.w UNK2
                  data.w $8202
                  data.w $d82c
                  data.w $d9e6
                  data.w $d9fc
;;
;;
;;
UNK4:         data.w KDOES
                  data.w UNK2
                  data.w $8203
                  data.w _NEXT
                  data.w $d9f3
                  data.w $da08
;;
;;
;;
UNK5:         data.w KDOES
                  data.w UNK2
                  data.w $8204
                  data.w $a958
                  data.w $d9ff
                  data.w $da14
;;
;;
;;
UNK6:         data.w KDOES
                  data.w UNK2
                  data.w $8205
                  data.w $d929
                  data.w $da0b
                  data.w $da20
;;
;;
;;
UNK7:         data.w KDOES
                  data.w UNK2
                  data.w $8106
                  data.w $17a9
                  data.w $2bda
                  data.w $c5da
                  data.w $c7f9
                  data.w $0fd9
                  data.w $5483
                  data.w $d04f
                  data.w $da23
                  data.w $da38
;;
;;
;;
UNK8:         data.w KDOCOL
                  data.w UNK4
                  data.w KZERO
                  data.w KSEMIS
;;
;;    SEC
;;
_SECC             text.7 $83, "SEC"
                  data.w $da2e    ; link to .A
                  data.w $da48    ; PFAPTR
;;
;;
;;
SECC:         data.w KDOCOL
                  data.w UNK4
                  data.w KTWO
                  data.w KSEMIS
;;
;;
;;
RP:         data.w $5283
                  data.w $a950
                  data.w _SECC
                  data.w $da58
                  data.w KDOCOL
                  data.w UNK4
                  data.w KLIT
                  data.w KPortB
                  data.w KSEMIS
;;
;;
;;
UNK9:         data.w KDOCOL
                  data.w KZBRAN
                  data.w $0018
                  data.w MODE
                  data.w KCAT
                  data.w KCLIT
                  data.b $08
                  data.w KANDD
                  data.w KZEQ
                  data.w KZBRAN
                  data.w $0009
                  data.w KCLIT
                  data.b $08
                  data.w MODE
                  data.w KPSTORE
                  data.w KONE
                  data.w MODE
                  data.w KCAT
                  data.w KCLIT
                  data.b $0f
                  data.w KANDD
                  data.w KSUBDUP
                  data.w KZBRAN
                  data.w $000e
                  data.w KZERO
                  data.w KDO
                  data.w KDUP
                  data.w KPLUS
                  data.w KLOOP
                  data.w KNMIVEC
                  data.w KOVER
                  data.w KONEPLUS
                  data.w KAT
                  data.w KANDD
                  data.w KZEQ
                  data.w KSEMIS
                  data.w KCAT
                  data.w CCOMMA
                  data.w UNK3
                  data.w KSEMIS
                  data.w KDUP
                  data.w KONEPLUS
                  data.w KCAT
                  data.w KCLIT
                  data.b $80
                  data.w KANDD
                  data.w KZBRAN
                  data.w $0009
                  data.w KCLIT
                  data.b $10
                  data.w MODE
                  data.w KPSTORE
                  data.w KOVER
                  data.w KLIT
                  data.w $ff00
                  data.w KANDD
                  data.w UNK9
                  data.w UNK9
                  data.w KZBRAN
                  data.w $000e
                  data.w UNK3
                  data.w KCR
                  data.w LATEST
                  data.w ID
                  data.w KTHREE
                  data.w ERR
                  data.w KCAT
                  data.w MODE
                  data.w KCAT
                  data.w KLIT
                  data.w UNK1
                  data.w KPLUS
                  data.w KCAT
                  data.w KPLUS
                  data.w CCOMMA
                  data.w MODE
                  data.w KCAT
                  data.w KCLIT
                  data.b $07
                  data.w KANDD
                  data.w KZBRAN
                  data.w $001c
                  data.w MODE
                  data.w KCAT
                  data.w KCLIT
                  data.b $0f
                  data.w KANDD
                  data.w KCLIT
                  data.b $07
                  data.w KLESS
                  data.w KZBRAN
                  data.w $0008
                  data.w CCOMMA
                  data.w KBRAN
                  data.w $0004
                  data.w COMMA
                  data.w UNK3
                  data.w KSEMIS
;;
;;    BRK,
;;
_BRKC             text.7 $84, "BRK,"
                  data.w RP    ; link to SEC
                  data.w $db27    ; PFAPTR
;;
;;
;;
BRKC:         data.w KDOES
                  data.w $daa5
                  data.w $8400
                  data.w $4c43
                  data.w $ac43
                  data.w _BRKC
                  data.w $db35
                  data.w KDOES
                  data.w $daa5
                  data.w $8418
                  data.w $4c43
                  data.w $ac44
                  data.w $db2a
                  data.w $db43
                  data.w KDOES
                  data.w $daa5
                  data.w $84d8
                  data.w $4c43
                  data.w $ac49
                  data.w $db38
                  data.w $db51
                  data.w KDOES
                  data.w $daa5
                  data.w $8458
                  data.w $4c43
                  data.w $ac56
                  data.w $db46
                  data.w $db5f
                  data.w KDOES
                  data.w $daa5
                  data.w $84b8
                  data.w $4544
                  data.w $ac58
                  data.w $db54
                  data.w $db6d
                  data.w KDOES
                  data.w $daa5
                  data.w $84ca
                  data.w $4544
                  data.w $ac59
                  data.w $db62
                  data.w $db7b
                  data.w KDOES
                  data.w $daa5
                  data.w $8488
                  data.w $4e49
                  data.w $ac58
                  data.w $db70
                  data.w $db89
                  data.w KDOES
                  data.w $daa5
                  data.w $84e8
                  data.w $4e49
                  data.w $ac59
                  data.w $db7e
                  data.w $db97
                  data.w KDOES
                  data.w $daa5
                  data.w $84c8
                  data.w $4f4e
                  data.w $ac50
                  data.w $db8c
                  data.w $dba5
                  data.w KDOES
                  data.w $daa5
                  data.w $84ea
                  data.w $4850
                  data.w $ac41
                  data.w $db9a
                  data.w $dbb3
                  data.w KDOES
                  data.w $daa5
                  data.w $8448
                  data.w $4850
                  data.w $ac50
                  data.w $dba8
                  data.w $dbc1
                  data.w KDOES
                  data.w $daa5
                  data.w $8408
                  data.w $4c50
                  data.w $ac41
                  data.w $dbb6
                  data.w $dbcf
                  data.w KDOES
                  data.w $daa5
                  data.w $8468
                  data.w $4c50
                  data.w $ac50
                  data.w $dbc4
                  data.w $dbdd
                  data.w KDOES
                  data.w $daa5
                  data.w $8428
                  data.w $5452
                  data.w $ac49
                  data.w $dbd2
                  data.w $dbeb
                  data.w KDOES
                  data.w $daa5
                  data.w $8440
                  data.w $5452
                  data.w $ac53
                  data.w $dbe0
                  data.w $dbf9
                  data.w KDOES
                  data.w $daa5
                  data.w $8460
                  data.w $4553
                  data.w $ac43
                  data.w $dbee
                  data.w $dc07
                  data.w KDOES
                  data.w $daa5
                  data.w $8438
                  data.w $4553
                  data.w $ac44
                  data.w $dbfc
                  data.w $dc15
                  data.w KDOES
                  data.w $daa5
                  data.w $84f8
                  data.w $4553
                  data.w $ac49
                  data.w $dc0a
                  data.w $dc23
                  data.w KDOES
                  data.w $daa5
                  data.w $8478
                  data.w $4154
                  data.w $ac58
                  data.w $dc18
                  data.w $dc31
                  data.w KDOES
                  data.w $daa5
                  data.w $84aa
                  data.w $4154
                  data.w $ac59
                  data.w $dc26
                  data.w $dc3f
                  data.w KDOES
                  data.w $daa5
                  data.w $84a8
                  data.w $5354
                  data.w $ac58
                  data.w $dc34
                  data.w $dc4d
                  data.w KDOES
                  data.w $daa5
                  data.w $84ba
                  data.w $5854
                  data.w $ac41
                  data.w $dc42
                  data.w $dc5b
                  data.w KDOES
                  data.w $daa5
                  data.w $848a
                  data.w $5954
                  data.w $ac41
                  data.w $dc50
                  data.w $dc69
                  data.w KDOES
                  data.w $daa5
                  data.w $8498
                  data.w $5854
                  data.w $ac53
                  data.w $dc5e
                  data.w $dc77
                  data.w KDOES
                  data.w $daa5
                  data.w $849a
                  data.w $4441
                  data.w $ac43
                  data.w $dc6c
                  data.w $dc85
                  data.w KDOES
                  data.w $daad
                  data.w $6e60
                  data.w $841c
                  data.w $4e41
                  data.w $ac44
                  data.w $dc7a
                  data.w $dc95
                  data.w KDOES
                  data.w $daad
                  data.w $6e20
                  data.w $841c
                  data.w $4d43
                  data.w $ac50
                  data.w $dc8a
                  data.w $dca5
                  data.w KDOES
                  data.w $daad
                  data.w $6ec0
                  data.w $841c
                  data.w $4f45
                  data.w $ac52
                  data.w $dc9a
                  data.w $dcb5
                  data.w KDOES
                  data.w $daad
                  data.w $6e40
                  data.w $841c
                  data.w $444c
                  data.w $ac41
                  data.w $dcaa
                  data.w $dcc5
                  data.w KDOES
                  data.w $daad
                  data.w $6ea0
                  data.w $841c
                  data.w $524f
                  data.w $ac41
                  data.w $dcba
                  data.w $dcd5
                  data.w KDOES
                  data.w $daad
                  data.w $6e00
                  data.w $841c
                  data.w $4253
                  data.w $ac43
                  data.w $dcca
                  data.w $dce5
                  data.w KDOES
                  data.w $daad
                  data.w $6ee0
                  data.w $841c
                  data.w $5453
                  data.w $ac41
                  data.w $dcda
                  data.w $dcf5
                  data.w KDOES
                  data.w $daad
                  data.w $6c80
                  data.w $841c
                  data.w $5341
                  data.w $ac4c
                  data.w $dcea
                  data.w $dd05
                  data.w KDOES
                  data.w $daad
                  data.w $0d01
                  data.w $840d
                  data.w $4544
                  data.w $ac43
                  data.w $dcfa
                  data.w $dd15
                  data.w KDOES
                  data.w $daad
                  data.w $0cc1
                  data.w $840c
                  data.w $4e49
                  data.w $ac43
                  data.w $dd0a
                  data.w $dd25
                  data.w KDOES
                  data.w $daad
                  data.w $0ce1
                  data.w $840c
                  data.w $534c
                  data.w $ac52
                  data.w $dd1a
                  data.w $dd35
                  data.w KDOES
                  data.w $daad
                  data.w $0d41
                  data.w $840d
                  data.w $4f52
                  data.w $ac4c
                  data.w $dd2a
                  data.w $dd45
                  data.w KDOES
                  data.w $daad
                  data.w $0d21
                  data.w $840d
                  data.w $4f52
                  data.w $ac52
                  data.w $dd3a
                  data.w $dd55
                  data.w KDOES
                  data.w $daad
                  data.w $0d61
                  data.w $840d
                  data.w $5453
                  data.w $ac58
                  data.w $dd4a
                  data.w $dd65
                  data.w KDOES
                  data.w $daad
                  data.w $1481
                  data.w $8404
                  data.w $5043
                  data.w $ac58
                  data.w $dd5a
                  data.w $dd75
                  data.w KDOES
                  data.w $daad
                  data.w $86e0
                  data.w $8404
                  data.w $5043
                  data.w $ac59
                  data.w $dd6a
                  data.w $dd85
                  data.w KDOES
                  data.w $daad
                  data.w $86c0
                  data.w $8404
                  data.w $444c
                  data.w $ac58
                  data.w $dd7a
                  data.w $dd95
                  data.w KDOES
                  data.w $daad
                  data.w $96a2
                  data.w $8414
                  data.w $444c
                  data.w $ac59
                  data.w $dd8a
                  data.w $dda5
                  data.w KDOES
                  data.w $daad
                  data.w $8ea0
                  data.w $840c
                  data.w $5453
                  data.w $ac59
                  data.w $dd9a
                  data.w $ddb5
                  data.w KDOES
                  data.w $daad
                  data.w $8c80
                  data.w $8404
                  data.w $534a
                  data.w $ac52
                  data.w $ddaa
                  data.w $ddc5
                  data.w KDOES
                  data.w $daad
                  data.w $8014
                  data.w $8404
                  data.w $4d4a
                  data.w $ac50
                  data.w $ddba
                  data.w $ddd5
                  data.w KDOES
                  data.w $daad
                  data.w $8040
                  data.w $8484
                  data.w $4942
                  data.w $ac54
                  data.w $ddca
                  data.w $dde5
                  data.w KDOES
                  data.w $daad
                  data.w $8420
UNKA_:         data.b $04
;;
;;    SMB,
;;
_SMBC             text.7 $84, "SMB,"
                  data.w $ddda    ; link to BRK,
                  data.w $ddf5    ; PFAPTR
;;
;;
;;
SMBC:         data.w KDOCOL
                  data.w MODE
                  data.w KAT
                  data.w UNK3
                  data.w KTWO
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $001b
                  data.w KCLIT
                  data.b $87
                  data.w KSWAP
                  data.w KCLIT
                  data.b $07
                  data.w KANDD
                  data.w KCLIT
                  data.b $10
                  data.w KMUL
                  data.w KOR
                  data.w CCOMMA
                  data.w CCOMMA
                  data.w KBRAN
                  data.w $0006
                  data.w KTHREE
                  data.w ERR
                  data.w KSEMIS
;;
;;    RMB,
;;
_RMBC             text.7 $84, "RMB,"
                  data.w _SMBC    ; link to SMB,
                  data.w $de2d    ; PFAPTR
;;
;;
;;
RMBC:         data.w KDOCOL
                  data.w MODE
                  data.w KAT
                  data.w UNK3
                  data.w KTWO
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $ffe3
                  data.w KCLIT
                  data.b $07
                  data.w KBRAN
                  data.w $ffc6
                  data.w $4286
                  data.w $5449
                  data.w $4553
                  data.w $22d4
                  data.w $4fde
                  data.w $74de
                  data.w $c0f8
                  data.w $3bc4
                  data.w $b7f8
                  data.w $38f8
                  data.w $97f9
                  data.w $c3f4
                  data.w $58ff
                  data.w $0ff4
                  data.w KSWAP
                  data.w KCLIT
                  data.b $07
                  data.w KANDD
                  data.w KCLIT
                  data.b $10
                  data.w KMUL
                  data.w KOR
                  data.w CCOMMA
                  data.w KSEMIS
;;
;;    BITCLR
;;
_BITCLR             text.7 $86, "BITCLR"
                  data.w $de42    ; link to RMB,
                  data.w $de7d    ; PFAPTR
;;
;;
;;
BITCLR:         data.w KDOCOL
                  data.w MODE
                  data.w KAT
                  data.w KTWO
                  data.w KEQUAL
                  data.w KZBRAN
                  data.w $ff95
                  data.w KCLIT
                  data.b $8f
                  data.w KBRAN
                  data.w $ffd0
                  data.w $4286
                  data.w $4745
                  data.w $4e49
                  data.w $70ac
                  data.w $9dde
                  data.w $74de
                  data.w $77f8
                  data.w $b3c5
                  data.w $17f8
PADA2:         data.b $f7
;;
;;    UNTIL,
;;
_FUNTIL             text.7 $86, "UNTIL,"
                  data.w $de90    ; link to BITCLR
                  data.w $deb0    ; PFAPTR
;;
;;
;;
FUNTIL:         data.w KDOCOL
                  data.w KGTR
                  data.w KONE
                  data.w QPAIRS
                  data.w KRFROM
                  data.w CCOMMA
                  data.w HERE
                  data.w KONEPLUS
                  data.w KSUB
                  data.w CCOMMA
                  data.w KSEMIS
;;
;;    WHILE,
;;
_FWHILE             text.7 $86, "WHILE,"
                  data.w _FUNTIL    ; link to UNTIL,
                  data.w $ded1    ; PFAPTR
;;
;;
;;
FWHILE:         data.w KDOCOL
                  data.w CCOMMA
                  data.w HERE
                  data.w KZERO
                  data.w CCOMMA
                  data.w KTHREE
                  data.w KSEMIS
;;
;;    AGAIN,
;;
_AGAIN             text.7 $86, "AGAIN,"
                  data.w _FWHILE    ; link to WHILE,
                  data.w $deea    ; PFAPTR
;;
;;
;;
AGAIN:         data.w KDOCOL
                  data.w KONE
                  data.w QPAIRS
                  data.w $ddd3
                  data.w KSEMIS
;;
;;    REPEAT,
;;
_FREPEAT             text.7 $87, "REPEAT,"
                  data.w _AGAIN    ; link to AGAIN,
                  data.w $df00    ; PFAPTR
;;
;;
;;
FREPEAT:         data.w KDOCOL
                  data.w KTHREE
                  data.w QPAIRS
                  data.w KGTR
                  data.w AGAIN
                  data.w KRFROM
                  data.w HERE
                  data.w KOVER
                  data.w KONEPLUS
                  data.w KSUB
                  data.w KSWAP
                  data.w KCSTOR
                  data.w KSEMIS
;;
;;    IF,
;;
_FIF             text.7 $83, "IF,"
                  data.w _FREPEAT    ; link to REPEAT,
                  data.w $df22    ; PFAPTR
;;
;;
;;
FIF:         data.w KDOCOL
                  data.w CCOMMA
                  data.w HERE
                  data.w KZERO
                  data.w CCOMMA
                  data.w KTWO
                  data.w KSEMIS
;;
;;    ENDIF,
;;
_FENDIF             text.7 $86, "ENDIF,"
                  data.w _FIF    ; link to IF,
                  data.w $df3b    ; PFAPTR
;;
;;
;;
FENDIF:         data.w KDOCOL
                  data.w KTWO
                  data.w QPAIRS
                  data.w HERE
                  data.w KOVER
                  data.w KCAT
                  data.w KZBRAN
                  data.w $0008
                  data.w KSWAP
                  data.w KSTORE
                  data.w KSEMIS
                  data.w KOVER
                  data.w KONEPLUS
                  data.w KSUB
                  data.w KSWAP
                  data.w KCSTOR
                  data.w KSEMIS
;;
;;    THEN,
;;
_THEN             text.7 $85, "THEN,"
                  data.w _FENDIF    ; link to ENDIF,
                  data.w $df67    ; PFAPTR
;;
;;
;;
THEN:         data.w KDOCOL
                  data.w FENDIF
                  data.w KSEMIS
;;
;;    ELSE,
;;
_FELSE             text.7 $85, "ELSE,"
                  data.w _THEN    ; link to THEN,
                  data.w $df77    ; PFAPTR
;;
;;
;;
FELSE:         data.w KDOCOL
                  data.w KTWO
                  data.w QPAIRS
                  data.w HERE
                  data.w KONEPLUS
                  data.w KONE
                  data.w $ddd3
                  data.w KSWAP
                  data.w HERE
                  data.w KOVER
                  data.w KONEPLUS
                  data.w KSUB
                  data.w KSWAP
                  data.w KCSTOR
                  data.w KTWO
                  data.w KSEMIS
;;
;;    NOT
;;
_NOT             text.7 $83, "NOT"
                  data.w _FELSE    ; link to ELSE,
                  data.w $df9f    ; PFAPTR
;;
;;
;;
NOT:         data.w KDOCOL
                  data.w KBL
                  data.w KXOR
                  data.w KSEMIS
;;
;;    CS
;;
_CS             text.7 $82, "CS"
                  data.w _NOT    ; link to NOT
                  data.w $dfae    ; PFAPTR
;;
;;
;;
CS:         data.w KDOCON
                  data.w $0090
;;
;;    VS
;;
_VS             text.7 $82, "VS"
                  data.w _CS    ; link to CS
                  data.w $dfb9    ; PFAPTR
;;
;;
;;
VS:         data.w KDOCON
                  data.w $0050
;;
;;    0=
;;
_VS1             text.7 $82, "0="
                  data.w _VS    ; link to VS
                  data.w $dfc4    ; PFAPTR
;;
;;
;;
VS1:         data.w KDOCON
                  data.w $00d0
;;
;;    0<
;;
_VS2             text.7 $82, "0<"
                  data.w _VS1    ; link to 0=
                  data.w $dfcf    ; PFAPTR
;;
;;
;;
VS2:         data.w KDOCON
                  data.w $0010
;;
;;    END-CODE
;;
_ENDCODE             text.7 $c8, "END-CODE"
                  data.w _VS2    ; link to 0<
                  data.w $dfe0    ; PFAPTR
;;
;;
;;
ENDCODE:         data.w KDOCOL
                  data.w CURRENT
                  data.w KAT
                  data.w CONTEXT
                  data.w KSTORE
                  data.w QEXEC
                  data.w QCSP
                  data.w SMUDGE
                  data.w KSEMIS
;;
;;    TASK
;;
_TASK             text.7 $84, "TASK"
                  data.w _ADMP    ; link to END-CODE
                  data.w $dffb    ; PFAPTR
;;
;;
;;
TASK:         data.w KDOCOL
                  data.w KSEMIS
PADDINGD:         data.b $ff, $ff
                  data.b $ff
