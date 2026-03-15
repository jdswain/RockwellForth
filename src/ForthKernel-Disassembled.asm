        cpu := "R65C02"


        org := $f000

        PortA := $0000
        PortB := $0001
        PortE := $0004
        PortF := $0005
        PortG := $0006
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
        IRQSOFT := $0040
        NMISOFT := $0042
        UP := $0048
        INTFLAG := $004a
        WM1 := $004b
        W := $004c
        WP1 := $004d
        IP := $004e
        IPP1 := $004f
        NM1 := $0050
        N := $0051
        NP1 := $0052
        NP2 := $0053
        NP3 := $0054
        NP4 := $0055
        NP5 := $0056
        NP6 := $0057
        NP7 := $0058
        XSAVE := $0059
        INTVEC := $005b
        INTVECP1 := $005c
        TIB := $0300
        RO := $0302
        SO := $0304
        UC_L := $0306
        UPAD := $0308
        UR_W := $030a
        BASE := $030c
        CLD_WARM := $030e
        IN := $0310
        DPL := $0312
        HLD := $0314
        DISKNO := $0316
        CYLINDER := $0318
        B_SIDE := $031c
        DSK_STATUS := $e000
        DSK_TRACK := $e101
        DSK_SECTOR := $e102
        DSK_DATA := $e103
        DSK_CTL := $e106


f000: Unused:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f010:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f020:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f030:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f040:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f050:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f060:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f070:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f080:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f090:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0a0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0b0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0c0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0d0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0e0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f0f0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f100:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f110:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f120:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f130:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f140:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f150:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f160:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f170:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f180:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f190:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1a0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1b0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1c0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1d0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1e0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f1f0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f200:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f210:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f220:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f230:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f240:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f250:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f260:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f270:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f280:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f290:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2a0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2b0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2c0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2d0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2e0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f2f0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f300:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f310:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f320:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f330:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f340:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f350:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f360:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f370:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f380:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f390:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3a0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3b0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3c0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3d0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3e0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f3f0:         data.b $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
f400: INITVAR:         data.b $80, $03, $c2, $00, $ff, $00, $50, $00, $7e, $03, $08, $fd, $0a
f40d:                   data.b $00
f40e: ;;
f40e: ;;
f40e: ;;
f40e: LIT:         data.w $f410
f411:                   data.w $484e
f414:                   data.w $d04e
f417:                   data.w $4fe6
f41a:                   data.w $e64e
f41d:                   data.w $02d0
f420:                   data.w $ca4f
f423: ;
f423: PUT_:         data.w $0195
f426:                   data.w $0095
f429:                   data.w $304a
f42c:                   data.w $01a0
f42f:                   data.w $854e
f432:                   data.w $b188
f435:                   data.w $4c85
f438:                   data.w $4ea5
f43b:                   data.w $8502
f43e:                   data.w $0290
f441:                   data.w $4c4f
f444:                   data.w $7000
f447:                   data.w $5ba5
f44a:                   data.w $a54c
f44d:                   data.w $4d85
f450:                   data.w $8540
f453:                   data.w $00a0
f456:                   data.w WM1
f459:                   data.w $b1f4
f45c:                   data.w $9848
f45f:                   data.w $0abb
f462:                   data.w $b550
f465:                   data.w $5199
f468:                   data.w $c8e8
f46b:                   data.w $d050
f46e:                   data.w $00a0
f471: ;;
f471: ;;
f471: ;;
f471: EXECUTE:         data.w $f473
f474:                   data.w $8500
f477:                   data.w $01b5
f47a:                   data.w $e84d
f47d:                   data.w $4b4c
f480: ;;
f480: ;;
f480: ;;
f480: BRAN:         data.w $f484
f483:           EOR $1859,Y
f486:           LSR $654e
f489:           PHA 
f48a:           INY 
f48b:           LDA (IP),Y
f48d:           ADC IPP1
f48f:           STA IPP1
f491:           PLA 
f492:           STA IP
f494:           JMP $284c
f497: ;;
f497: ;;
f497: ;;
f497: ZBRAN:         data.w $f499
f49a:                   data.w $b5e8
f49d:                   data.w $ff15
f4a0:                   data.w $18e3
f4a3:                   data.w $694e
f4a6:                   data.w $4e85
f4a9:                   data.w $e602
f4ac:                   data.w $284c
f4af: ;;
f4af: ;;
f4af: ;;
f4af: LOOP:         data.w $f4b1
f4b2:                   data.w $ba59
f4b5:                   data.w $d001
f4b8:                   data.w $02f6
f4bb:                   data.w $03b5
f4be:                   data.w $b501
f4c1:                   data.w $02f5
f4c4:                   data.w $70bd
f4c7:                   data.w $e8e8
f4ca:                   data.w $9ae8
f4cd:                   data.w $5059
f4d0: ;;
f4d0: ;;
f4d0: ;;
f4d0: PLOOP:         data.w $f4d2
f4d3:                   data.w $86e8
f4d6:                   data.w $ffb5
f4d9:                   data.w $b548
f4dc:                   data.w $e8ba
f4df:                   data.w $7518
f4e2:                   data.w $0195
f4e5:                   data.w $0275
f4e8:                   data.w $6802
f4eb:                   data.w $18ce
f4ee:                   data.w $f501
f4f1:                   data.w $02b5
f4f4:                   data.w $4c04
f4f7:                   data.w HOLD
f4fa:                   data.w $03b5
f4fd:                   data.w $02b5
f500:                   data.w $01b5
f503:                   data.w $00b5
f506: ;
f506: POPTWO:         data.w $e8e8
f509:                   data.w $4ce8
f50c:                   data.w $0ff4
f50f:                   data.w $b538
f512:                   data.w $30e9
f515:                   data.w $c918
f518:                   data.w $0730
f51b:                   data.w $07e9
f51e:                   data.w $300a
f521:                   data.w $00d5
f524:                   data.w $9509
f527:                   data.w $01a9
f52a:                   data.w $4c98
f52d:                   data.w $98f4
f530:                   data.w $e8e8
f533:                   data.w PUT_
f536:                   data.w $a9f5
f539:                   data.w $6020
f53c:                   data.w $5986
f53f:                   data.w $b100
f542:                   data.w $5351
f545:                   data.w $d03f
f548:                   data.w $b1c8
f54b:                   data.w $5351
f54e:                   data.w $23d0
f551:                   data.w $a6f6
f554:                   data.w $caca
f557:                   data.w $18ca
f55a:                   data.w $0369
f55d:                   data.w $9551
f560:                   data.w $00a0
f563:                   data.w $5265
f566:                   data.w $9403
f569:                   data.w $51b1
f56c:                   data.w $a900
f56f:                   data.w $4c48
f572:                   data.w $b0f4
f575:                   data.w $b1c8
f578:                   data.w $fb10
f57b:                   data.w $51b1
f57e:                   data.w $b1c8
f581:                   data.w $5285
f584:                   data.w $0551
f587:                   data.w $b5d0
f58a:                   data.w $a959
f58d:                   data.w $4c48
f590:                   data.w $93f4
f593:                   data.w $02a9
f596:                   data.w $f460
f599:                   data.w $e938
f59c:                   data.w $94aa
f59f:                   data.w $0194
f5a2:                   data.w $c80b
f5a5:                   data.w $e608
f5a8:                   data.w $01f6
f5ab:                   data.w $f603
f5ae:                   data.w $53b1
f5b1:                   data.w $f051
f5b4:                   data.w $0494
f5b7:                   data.w $d053
f5ba:                   data.w $0294
f5bd:                   data.w $9800
f5c0:                   data.w $d004
f5c3:                   data.w $02f6
f5c6:                   data.w NEXT
f5c9:                   data.w $c802
f5cc:                   data.w $d051
f5cf:                   data.w $0094
f5d2:                   data.w NEXT
f5d5:                   data.w $b5f5
f5d8:                   data.w $08c9
f5db:                   data.w $200a
f5de:                   data.w $a9f5
f5e1:                   data.w $ec20
f5e4:                   data.w $08a9
f5e7:                   data.w $f5ec
f5ea:                   data.w POP
f5ed:                   data.w $0046
f5f0:                   data.w $5016
f5f3:                   data.w $1785
f5f6: ;;
f5f6: ;;
f5f6: ;;
f5f6: KEY:         data.w $f5f8
f5f9:                   data.w $f5fe
f5fc:                   data.w PUSHOA
f5ff:                   data.w $0044
f602:                   data.w $2916
f605:                   data.w $faf0
f608:                   data.w $6017
f60b:                   data.w $a5f6
f60e:                   data.w $0129
f611:                   data.w PUSHOA
f614:                   data.w $a9f6
f617:                   data.w $ec20
f61a:                   data.w $0aa9
f61d:                   data.w $f5ec
f620:                   data.w $ec20
f623:                   data.w $284c
f626: ;;
f626: ;;
f626: ;;
f626: CMOVE:         data.w $f628
f629:                   data.w $2003
f62c:                   data.w $c4f4
f62f:                   data.w $07d0
f632:                   data.w $1052
f635:                   data.w $284c
f638:                   data.w $55b1
f63b:                   data.w $c853
f63e:                   data.w $e6ee
f641:                   data.w $54e6
f644:                   data.w $f62d
f647:                   data.w $b5f6
f64a:                   data.w $5185
f64d:                   data.w $b502
f650:                   data.w $5285
f653:                   data.w $a003
f656:                   data.w $0216
f659:                   data.w $3603
f65c:                   data.w $0136
f65f:                   data.w $1815
f662:                   data.w $7551
f665:                   data.w $0295
f668:                   data.w $7552
f66b:                   data.w $0395
f66e:                   data.w $f606
f671:                   data.w $02d0
f674:                   data.w $8801
f677:                   data.w $4cde
f67a:                   data.w $7df4
f67d:                   data.w $04b5
f680:                   data.w $9402
f683:                   data.w $950a
f686:                   data.w $05b5
f689:                   data.w $9403
f68c:                   data.w $952a
f68f:                   data.w $10a9
f692:                   data.w $3651
f695:                   data.w $0536
f698:                   data.w $b538
f69b:                   data.w $00f5
f69e:                   data.w $05b5
f6a1:                   data.w $9001
f6a4:                   data.w $0494
f6a7:                   data.w $2805
f6aa:                   data.w $07b0
f6ad:                   data.w $0490
f6b0:                   data.w $9504
f6b3:                   data.w $0236
f6b6:                   data.w $c603
f6b9:                   data.w $d8d0
f6bc:                   data.w POP
f6bf:                   data.w $b5f6
f6c2:                   data.w $0235
f6c5:                   data.w $01b5
f6c8:                   data.w $e803
f6cb:                   data.w $234c
f6ce: ;;
f6ce: ;;
f6ce: ;;
f6ce: OR:         data.w $f6d0
f6d1:                   data.w $1500
f6d4:                   data.w $b548
f6d7:                   data.w $0315
f6da:                   data.w BINARY
f6dd:                   data.w $b5f6
f6e0:                   data.w $0255
f6e3:                   data.w $01b5
f6e6:                   data.w $4c03
f6e9:                   data.w $ecf6
f6ec:                   data.w $488a
f6ef:                   data.w $4c00
f6f2:                   data.w $f5f4
f6f5:                   data.w $02a0
f6f8:                   data.w $aa48
f6fb:                   data.w NEXT
f6fe:                   data.w $86f6
f701:                   data.w $04a0
f704:                   data.w $aa48
f707:                   data.w $59a6
f70a:                   data.w NEXT
f70d:                   data.w $86f7
f710:                   data.w $8aba
f713:                   data.w $4c59
f716:                   data.w $19f6
f719: SEMIS_C: PLA 
f71a:           STA IP
f71c:           PLA 
f71d:           STA IPP1
f71f:           JMP $284c
f722: ;;
f722: ;;
f722: ;;
f722: LEAVE:         data.w $f724
f725:                   data.w $ba59
f728:                   data.w $9501
f72b:                   data.w $02b5
f72e:                   data.w $a604
f731:                   data.w $284c
f734: ;;
f734: ;;
f734: ;;
f734: GTR:         data.w $f736
f737:                   data.w $4801
f73a:                   data.w $4800
f73d:                   data.w POP
f740:                   data.w $caf7
f743:                   data.w $9568
f746:                   data.w $9568
f749:                   data.w $284c
f74c: ;;
f74c: ;;
f74c: ;;
f74c: R:         data.w $f74e
f74f:                   data.w $ba59
f752:                   data.w $4801
f755:                   data.w $a602
f758:                   data.w $214c
f75b: ;;
f75b: ;;
f75b: ;;
f75b: ZEQ:         data.w $f75d
f75e:                   data.w $1500
f761:                   data.w $0194
f764:                   data.w $c801
f767:                   data.w $4c00
f76a:                   data.w $6df4
f76d:                   data.w $0116
f770:                   data.w $942a
f773:                   data.w $0095
f776:                   data.w NEXT
f779:                   data.w $18f7
f77c:                   data.w $7500
f77f:                   data.w $b548
f782:                   data.w $0375
f785:                   data.w BINARY
f788:                   data.w $18f7
f78b:                   data.w $7502
f78e:                   data.w $0695
f791:                   data.w $7503
f794:                   data.w $0795
f797:                   data.w $7500
f79a:                   data.w $0495
f79d:                   data.w $7501
f7a0:                   data.w $0595
f7a3:                   data.w POPTWO
f7a6:                   data.w $38f7
f7a9:                   data.w $00f5
f7ac:                   data.w $9800
f7af:                   data.w $9501
f7b2:                   data.w $284c
f7b5: ;;
f7b5: ;;
f7b5: ;;
f7b5: DNEGATE:         data.w $f7b7
f7b8:                   data.w $f598
f7bb:                   data.w $0295
f7be:                   data.w $03f5
f7c1:                   data.w $4c03
f7c4:                   data.w $c7f7
f7c7:                   data.w $02b5
f7ca:                   data.w $03b5
f7cd:                   data.w PUSH
f7d0:                   data.w $06f5
f7d3: ;;
f7d3: ;;
f7d3: ;;
f7d3: SWAP:         data.w $f7d5
f7d6:                   data.w $4802
f7d9:                   data.w $9500
f7dc:                   data.w $03b5
f7df:                   data.w $9401
f7e2:                   data.w $234c
f7e5: ;;
f7e5: ;;
f7e5: ;;
f7e5: DUP:         data.w $f7e7
f7e8:                   data.w $4800
f7eb:                   data.w $4c01
f7ee:                   data.w $f1f4
f7f1:                   data.w $caca
f7f4:                   data.w $9504
f7f7:                   data.w $05b5
f7fa:                   data.w $b501
f7fd:                   data.w $b548
f800:                   data.w $214c
f803: ;;
f803: ;;
f803: ;;
f803: BOUNDS:         data.w $f805
f806:                   data.w $b503
f809:                   data.w $1848
f80c: ;;
f80c: ;;
f80c: ;;
f80c: RPAT:         data.w $9500
f80f:                   data.w $7598
f812:                   data.w $0395
f815:                   data.w $234c
f818: ;;
f818: ;;
f818: ;;
f818: PSTORE:         data.w $f81a
f81b:                   data.w $00a1
f81e:                   data.w $8102
f821:                   data.w $00f6
f824:                   data.w $f602
f827:                   data.w $00a1
f82a:                   data.w $8103
f82d:                   data.w $064c
f830: ;;
f830: ;;
f830: ;;
f830: TOGGL:         data.w $f832
f833:                   data.w $5502
f836:                   data.w $0281
f839:                   data.w POPTWO
f83c:                   data.w $a1f8
f83f:                   data.w $f648
f842:                   data.w $02d0
f845:                   data.w $a101
f848:                   data.w $234c
f84b: ;;
f84b: ;;
f84b: ;;
f84b: CAT:         data.w $f84d
f84e:                   data.w $9500
f851:                   data.w $00a0
f854:                   data.w $4c01
f857:                   data.w $5af4
f85a:                   data.w $02b5
f85d:                   data.w $f600
f860:                   data.w $02d0
f863:                   data.w $b501
f866:                   data.w $0081
f869:                   data.w POPTWO
f86c:                   data.w $b5f8
f86f:                   data.w $0081
f872:                   data.w POPTWO
f875:                   data.w $484f
f878:                   data.w $484e
f87b:                   data.w $4ca5
f87e:                   data.w $8502
f881:                   data.w $6598
f884:                   data.w $4f85
f887:                   data.w NEXT
f88a:                   data.w $b102
f88d:                   data.w $c848
f890:                   data.w $4c4c
f893:                   data.w $18f4
f896:                   data.w $694c
f899:                   data.w $9848
f89c:                   data.w $4c4d
f89f:                   data.w $a0f4
f8a2:                   data.w $b118
f8a5:                   data.w $4865
f8a8:                   data.w $00a9
f8ab:                   data.w $4c49
f8ae:                   data.w $89f4
f8b1:                   data.w PortA
f8b4:                   data.w $01f8
f8b7: ;;
f8b7: ;;
f8b7: ;;
f8b7: TWO:         data.w DOCON
f8ba:                   data.w $8900
f8bd:                   data.w $0003
f8c0:                   data.w $04f8
f8c3: ;;
f8c3: ;;
f8c3: ;;
f8c3: BL:         data.w DOCON
f8c6:                   data.w $a000
f8c9:                   data.w $a000
f8cc:                   data.w $a002
f8cf:                   data.w $a004
f8d2:                   data.w $a006
f8d5:                   data.w $a008
f8d8:                   data.w $a00a
f8db:                   data.w $a00c
f8de:                   data.w $a00e
f8e1:                   data.w $a010
f8e4:                   data.w $a012
f8e7:                   data.w $7414
f8ea:                   data.w UCL
f8ed:                   data.w $17f8
f8f0: ;;
f8f0: ;;
f8f0: ;;
f8f0: PAD:         data.w DOCOL
f8f3:                   data.w $3bf8
f8f6:                   data.w SEMIS
f8f9:                   data.w $f6f8
f8fc:                   data.w $02d0
f8ff:                   data.w $4c01
f902:                   data.w $05f4
f905:                   data.w $b518
f908:                   data.w $0269
f90b:                   data.w $9000
f90e:                   data.w $01f6
f911:                   data.w NEXT
f914:                   data.w $b5f9
f917:                   data.w $02d0
f91a:                   data.w $d601
f91d:                   data.w $284c
f920: ;;
f920: ;;
f920: ;;
f920: TWOMINUS:         data.w $f922
f923:                   data.w $00b5
f926:                   data.w $9502
f929:                   data.w $02b0
f92c:                   data.w $4c01
f92f:                   data.w $74f4
f932:                   data.w NEGATE
f935:                   data.w $17f7
f938: ;;
f938: ;;
f938: ;;
f938: EQUAL:         data.w DOCOL
f93b:                   data.w $5bf9
f93e:                   data.w SEMIS
f941:                   data.w $38f9
f944:                   data.w $f502
f947:                   data.w $03b5
f94a:                   data.w $9801
f94d:                   data.w $0149
f950:                   data.w $4ce8
f953:                   data.w $56f8
f956:                   data.w $02b5
f959:                   data.w $b500
f95c:                   data.w $01f5
f95f:                   data.w $5003
f962:                   data.w $8049
f965:                   data.w $c801
f968:                   data.w $4c02
f96b:                   data.w $74f5
f96e:                   data.w SWAP
f971:                   data.w $17f9
f974: ;;
f974: ;;
f974: ;;
f974: ROT:         data.w $f976
f977:                   data.w $4804
f97a:                   data.w $9502
f97d:                   data.w $00b5
f980:                   data.w $b402
f983:                   data.w $03b5
f986:                   data.w $b505
f989:                   data.w $0395
f98c:                   data.w $234c
f98f: ;;
f98f: ;;
f98f: ;;
f98f: PICK:         data.w DOCOL
f992:                   data.w $78f7
f995:                   data.w SPAT
f998:                   data.w $3bf7
f99b:                   data.w SEMIS
f99e:                   data.w $c3f8
f9a1:                   data.w EMIT
f9a4:                   data.w $74f7
f9a7:                   data.w DUP
f9aa:                   data.w $04f4
f9ad:                   data.w DUP
f9b0:                   data.w $74f7
f9b3:                   data.w CLIT
f9b6:         data.b $d9
f9b7:                   data.w $58f8
f9ba:                   data.w SEMIS
f9bd:                   data.w $58f8
f9c0:                   data.w $800a
f9c3:                   data.w $fff3
f9c6:                   data.w $484f
f9c9:                   data.w $484e
f9cc:                   data.w $b102
f9cf:                   data.w $4e85
f9d2:                   data.w $4cb1
f9d5:                   data.w $184f
f9d8:                   data.w $694c
f9db:                   data.w $a548
f9de:                   data.w $0069
f9e1:                   data.w PUSH
f9e4:                   data.w $e5f8
f9e7:                   data.w ONEPLUS
f9ea:                   data.w $4bf7
f9ed:                   data.w SEMIS
f9f0:                   data.w $a5f8
f9f3:                   data.w ZBRAN
f9f7:         data.w $0012
f9f8:                   data.w ONEPLUS
f9fb:                   data.w R
f9fe:                   data.w $d4f8
fa01:                   data.w LOOP
fa04:                   data.w $17ff
fa07:                   data.w DROP
fa0a:                   data.w $74f7
fa0d:                   data.w DUP
fa10:                   data.w ONEPLUS
fa13:                   data.w TWODUP
fa16:                   data.w $13f7
fa19:                   data.w CAT
fa1c:                   data.w $30f8
fa1f:                   data.w ZBRAN
fa23:         data.w $0008
fa24:                   data.w $80f7
fa27:                   data.w PortE
fa2a:                   data.w $aff9
fa2d:                   data.w $ffe6
fa30:                   data.w $74f7
fa33:                   data.w R
fa36:                   data.w $e5f9
fa39:                   data.w ONEPLUS
fa3c:                   data.w $78f7
fa3f:                   data.w GTR
fa42:                   data.w $17f9
fa45: ;;
fa45: ;;
fa45: ;;
fa45: EXPECT:         data.w DOCOL
fa48:                   data.w $78f7
fa4b:                   data.w OVER
fa4e:                   data.w $c5f8
fa51:                   data.w STORE
fa54:                   data.w $e5f5
fa57:                   data.w CLIT
fa5a:         data.b $38
fa5b:                   data.w $97f9
fa5e:                   data.w $000c
fa61:                   data.w $9df7
fa64:                   data.w ONE
fa67:                   data.w $3af4
fa6a:                   data.w DUP
fa6d:                   data.w $7ff4
fa70:                   data.w $97f9
fa73:                   data.w $001f
fa76:                   data.w $bbf7
fa79:                   data.w PICK
fa7c:                   data.w $40f7
fa7f:                   data.w NEGATE
fa82:                   data.w $a5f7
fa85:                   data.w ZBRAN
fa89:         data.w $0015
fa8a:                   data.w $08f4
fa8d:                   data.w $80f5
fa90:                   data.w $000c
fa93:                   data.w $d3f7
fa96:                   data.w CSTOR
fa99:                   data.w $b3f5
fa9c:                   data.w PLUS
fa9f:                   data.w $38f7
faa2:                   data.w ZBRAN
faa6:         data.w $ffa9
faa7:                   data.w $cff7
faaa:                   data.w SEMIS
faad:                   data.w $c7f8
fab0:                   data.w AT
fab3:                   data.w $45f8
fab6:                   data.w ZERO
fab9:                   data.w $58f8
fabc:                   data.w SEMIS
fabf:                   data.w $d3f8
fac2:                   data.w DUP
fac5:                   data.w $54f8
fac8:                   data.w ZBRAN
facc:         data.w $0008
facd:                   data.w $cff7
fad0:                   data.w SEMIS
fad3:                   data.w $c5f7
fad6:                   data.w CSTOR
fad9:                   data.w $f8f7
fadc:                   data.w RFROM
fadf:                   data.w $26f9
fae2:                   data.w SEMIS
fae5:                   data.w $aff8
fae8:                   data.w FILL_
faeb:                   data.w $74f7
faee:                   data.w BL
faf1:                   data.w $17fa
faf4: ;;
faf4: ;;
faf4: ;;
faf4: HOLD:         data.w DOCOL
faf7:                   data.w $fff4
fafa:                   data.w HLD
fafd:                   data.w $e5f8
fb00:                   data.w AT
fb03:                   data.w $17f8
fb06: ;;
fb06: ;;
fb06: ;;
fb06: LTNUMBER:         data.w DOCOL
fb09:                   data.w $e5f8
fb0c:                   data.w GTR
fb0f:                   data.w $d9f8
fb12:                   data.w AT
fb15:                   data.w $97f5
fb18:                   data.w $002c
fb1b:                   data.w $d9f7
fb1e:                   data.w AT
fb21:                   data.w $cff6
fb24:                   data.w ROT
fb27:                   data.w $3bf8
fb2a:                   data.w UMUL
fb2d:                   data.w $e2f7
fb30:                   data.w AT
fb33:                   data.w $97f8
fb36:                   data.w $0008
fb39:                   data.w $e2f8
fb3c:                   data.w PSTORE
fb3f:                   data.w $80f7
fb42:                   data.w $ffc6
fb45:                   data.w $17f7
fb48: ;;
fb48: ;;
fb48: ;;
fb48: COLD:         data.w $fb4a
fb4b:                   data.w CLD_WARM
fb4e:                   data.w $9aff
fb51:                   data.w $a918
fb54:                   data.w $1485
fb57:                   data.w $8500
fb5a:                   data.w $1285
fb5d:                   data.w $85c4
fb60:                   data.w $34a9
fb63:                   data.w $a918
fb66:                   data.w $1a85
fb69:                   data.w $8516
fb6c:                   data.w $6ca9
fb6f:                   data.w $a94b
fb72:                   data.w $4685
fb75:                   data.w $85f5
fb78:                   data.w $aea9
fb7b:                   data.w $a944
fb7e:                   data.w $4585
fb81:                   data.w $8500
fb84:                   data.w $03a9
fb87:                   data.w $a049
fb8a:                   data.w $ec20
fb8d:                   data.w $0ead
fb90:                   data.w $5ac9
fb93:                   data.w $ad07
fb96:                   data.w $c903
fb99:                   data.w $15f0
fb9c:                   data.w $854a
fb9f:                   data.w $4285
fba2:                   data.w $a95b
fba5:                   data.w $4185
fba8:                   data.w $8543
fbab:                   data.w $0da0
fbae:                   data.w $fbec
fbb1:                   data.w $85fb
fbb4:                   data.w $f5a9
fbb7:                   data.w $584e
fbba:                   data.w $a9c2
fbbd:                   data.w $5e85
fbc0:                   data.w $8400
fbc3:                   data.w $b198
fbc6:                   data.w $5ac9
fbc9:                   data.w $c814
fbcc:                   data.w $c95d
fbcf:                   data.w $0dd0
fbd2:                   data.w $5db1
fbd5:                   data.w $c84e
fbd8:                   data.w $855d
fbdb:                   data.w $284c
fbde:                   data.w $5ea4
fbe1:                   data.w $c8c8
fbe4:                   data.w $f5f0
fbe7:                   data.w $a05e
fbea:                   data.w $d7f0
fbed:                   data.w INITVAR
fbf0:                   data.w $8848
fbf3:                   data.w $60f8
fbf6:                   data.w $31f6
fbf9:                   data.w $4e06
fbfc:                   data.w $5220
fbff:                   data.w $b64d
fc02:                   data.w ZERO
fc05:                   data.w $afff
fc08:                   data.w SEEK
fc0b:                   data.w $0efc
fc0e:                   data.w $dfa9
fc11:                   data.w $a951
fc14:                   data.w $5285
fc17:                   data.w $8501
fc1a:                   data.w $80a9
fc1d:                   data.w DSTAT
fc20:                   data.w $2080
fc23:                   data.w $d0fd
fc26:                   data.w $5f4c
fc29:                   data.w $4d4c
fc2c: ;;
fc2c: ;;
fc2c: ;;
fc2c: STOD:         data.w DOCOL
fc2f:                   data.w $6bf7
fc32:                   data.w NEGATE
fc35:                   data.w $74f7
fc38:                   data.w ZLT
fc3b:                   data.w $04f4
fc3e:                   data.w NEGATE
fc41:                   data.w $74f7
fc44:                   data.w ZLT
fc47:                   data.w $04f4
fc4a:                   data.w DNEGATE
fc4d:                   data.w $74f7
fc50:                   data.w DUP
fc53:                   data.w $17fc
fc56: ;;
fc56: ;;
fc56: ;;
fc56: DABS:         data.w DOCOL
fc59:                   data.w $42f7
fc5c:                   data.w SEMIS
fc5f:                   data.w $eff8
fc62:                   data.w GT
fc65:                   data.w $04f4
fc68:                   data.w SWAP
fc6b:                   data.w $17f7
fc6e:                   data.w DOCOL
fc71:                   data.w $54f7
fc74:                   data.w ZBRAN
fc78:         data.w $0004
fc79:                   data.w $cff7
fc7c:                   data.w SEMIS
fc7f:                   data.w $eff8
fc82:                   data.w XOR
fc85:                   data.w $4ef7
fc88:                   data.w SWAP
fc8b:                   data.w $46fc
fc8e:                   data.w RFROM
fc91:                   data.w $17fc
fc94: ;;
fc94: ;;
fc94: ;;
fc94: MDIV:         data.w DOCOL
fc97:                   data.w $34f7
fc9a:                   data.w GTR
fc9d:                   data.w $4cfc
fca0:                   data.w ABS
fca3:                   data.w $3ff6
fca6:                   data.w R
fca9:                   data.w $36f6
fcac:                   data.w SWAP
fcaf:                   data.w $36f7
fcb2:                   data.w SWAP
fcb5:                   data.w $74f7
fcb8:                   data.w UMUL
fcbb:                   data.w $17f7
fcbe: ;;
fcbe: ;;
fcbe: ;;
fcbe: DIVMOD:         data.w DOCOL
fcc1:                   data.w $2cf7
fcc4:                   data.w RFROM
fcc7:                   data.w $17fc
fcca: ;;
fcca: ;;
fcca: ;;
fcca: DIV_:         data.w DOCOL
fccd:                   data.w $d3fc
fcd0:                   data.w DROP
fcd3:                   data.w $74f7
fcd6:                   data.w DIVMOD
fcd9:                   data.w $17f7
fcdc: ;;
fcdc: ;;
fcdc: ;;
fcdc: MULDIVMOD:         data.w DOCOL
fcdf:                   data.w $7ef7
fce2:                   data.w RFROM
fce5:                   data.w $17fc
fce8: ;;
fce8: ;;
fce8: ;;
fce8: MULDIV:         data.w DOCOL
fceb:                   data.w $d3fc
fcee:                   data.w DROP
fcf1:                   data.w $74f7
fcf4:                   data.w GTR
fcf7:                   data.w $4cf8
fcfa:                   data.w UDIV
fcfd:                   data.w $d3f7
fd00:                   data.w GTR
fd03:                   data.w $3ff6
fd06:                   data.w SEMIS
fd09:                   data.w $d3f8
fd0c:                   data.w LIT
fd0f:                   data.w $3b03
fd12:                   data.w DIVMOD
fd15:                   data.w $bfff
fd18:                   data.w DIVMOD
fd1b:                   data.w $d3fe
fd1e:                   data.w ZBRAN
fd22:         data.w $0008
fd23:                   data.w $80fd
fd26:                   data.w PortE
fd29:                   data.w $a5fd
fd2c:                   data.w ZBRAN
fd30:         data.w $0013
fd31:                   data.w $0cfa
fd34:                   data.w $5349
fd37:                   data.w $4520
fd3a:                   data.w $4f52
fd3d:                   data.w $2320
fd40:                   data.w $17fe
fd43: ;;
fd43: ;;
fd43: ;;
fd43: SELECT:         data.w $fd45
fd46:                   data.w $4a00
fd49:                   data.w DISKNO
fd4c:                   data.w $0317
fd4f:                   data.w $fe05
fd52:                   data.w DSK_CTL
fd55:                   data.w POP
fd58:                   data.w $20fd
fd5b:                   data.w $20fd
fd5e:                   data.w $a9fd
fd61:                   data.w $b520
fd64:                   data.w $9320
fd67:                   data.w $bf29
fd6a:                   data.w $c604
fd6d:                   data.w $edd0
fd70:                   data.w $4ce8
fd73:                   data.w $16f8
fd76:                   data.w SCSR
fd79:                   data.w $a900
fd7c:                   data.w $5485
fd7f:                   data.w $04a9
fd82:                   data.w $b553
fd85:                   data.w $5185
fd88:                   data.w $8503
fd8b:                   data.w $00b5
fd8e:                   data.w DSK_SECTOR
fd91:                   data.w $fda8
fd94:                   data.w DSK_CTL
fd97:                   data.w $10fb
fd9a:                   data.w $03ad
fd9d:                   data.w $5191
fda0:                   data.w $f1d0
fda3:                   data.w $c652
fda6:                   data.w $ebd0
fda9:                   data.w $20d4
fdac:                   data.w $adfd
fdaf:                   data.w $4ae0
fdb2:                   data.w $2afa
fdb5: DSTAT: STA $008d
fdb8:           LDY #$08
fdba:           DEY 
fdbb:           BNE $fdba
fdbd:           RTS 
fdbe: ;;
fdbe: ;;
fdbe: ;;
fdbe: DWRITE:         data.w $fdc0
fdc1:                   data.w $fd74
fdc4:                   data.w $fd7f
fdc7:                   data.w $20b0
fdca:                   data.w $20fd
fdcd:                   data.w $29fd
fdd0:                   data.w $04f0
fdd3:                   data.w $d054
fdd6:                   data.w $6f4c
fdd9:                   data.w $062c
fddc:                   data.w $fb70
fddf:                   data.w $b1cd
fde2:                   data.w $038d
fde5:                   data.w $d0c8
fde8:                   data.w $52e6
fdeb:                   data.w $d053
fdee:                   data.w $a84c
fdf1: ;;
fdf1: ;;
fdf1: ;;
fdf1: INIT:         data.w $fdf3
fdf4:                   data.w DSK_STATUS
fdf7:                   data.w $a0ff
fdfa:                   data.w $1899
fdfd:                   data.w $1088
fe00:                   data.w $284c
fe03: SUB1: NOP 
fe04:           NOP 
fe05:           TAY 
fe06:           LDA #$00
fe08:           ROL A
fe09:           ORA $0d19,Y
fe0c:           RTS 
fe0d: TAB1:         data.b $22, $24, $28, $30
fe11: ;;
fe11: ;;
fe11: ;;
fe11: SEEK:         data.w $fe13
fe14:                   data.w DISKNO
fe17:                   data.w CYLINDER
fe1a:                   data.w $9050
fe1d:                   data.w $03a9
fe20:                   data.w $fdaa
fe23:                   data.w $8d00
fe26:                   data.w $b5e1
fe29:                   data.w $038d
fe2c:                   data.w $16ac
fe2f:                   data.w $1899
fe32:                   data.w $13a9
fe35:                   data.w $fdaa
fe38:                   data.w POP
fe3b:                   data.w $aff8
fe3e:                   data.w $fc6e
fe41:                   data.w $97f9
fe44:                   data.w $000c
fe47:                   data.w ONEPLUS
fe4a:                   data.w SPACE
fe4d:                   data.w $fcf4
fe50:                   data.w SEMIS
fe53:                   data.w $f0f8
fe56:                   data.w HLD
fe59:                   data.w $17f8
fe5c: ;;
fe5c: ;;
fe5c: ;;
fe5c: HASHGT:         data.w DOCOL
fe5f:                   data.w $e5f7
fe62:                   data.w AT
fe65:                   data.w $c5f8
fe68:                   data.w SUB
fe6b:                   data.w $74f7
fe6e:                   data.w ROT
fe71:                   data.w $97f7
fe74:                   data.w $0007
fe77:                   data.w $2df4
fe7a:                   data.w $17fa
fe7d: ;;
fe7d: ;;
fe7d: ;;
fe7d: HASH:         data.w DOCOL
fe80:                   data.w $3bf8
fe83:                   data.w MDIVMOD
fe86:                   data.w $58f9
fe89:                   data.w $c509
fe8c:                   data.w LESS
fe8f:                   data.w $07f4
fe92:                   data.w CLIT
fe95:         data.b $78
fe96:                   data.w $58f7
fe99:                   data.w $7830
fe9c:                   data.w HOLD
fe9f:                   data.w $74f7
fea2:                   data.w HASH
fea5:                   data.w $cef7
fea8:                   data.w ZEQ
feab:                   data.w $f6f4
feae:                   data.w SEMIS
feb1:                   data.w $34f8
feb4:                   data.w SWAP
feb7:                   data.w $56f7
feba:                   data.w LEQ
febd:                   data.w $6cfe
fec0:                   data.w HASHGT
fec3:                   data.w $c5f7
fec6:                   data.w SUB
fec9:                   data.w $effe
fecc:                   data.w SEMIS
fecf:                   data.w $aff8
fed2:                   data.w DDOTR
fed5:                   data.w $17f9
fed8: ;;
fed8: ;;
fed8: ;;
fed8: DOTR:         data.w DOCOL
fedb:                   data.w $2cf7
fede:                   data.w RFROM
fee1:                   data.w $17fe
fee4: ;;
fee4: ;;
fee4: ;;
fee4: DOT:         data.w DOCOL
fee7:                   data.w $cefc
feea:                   data.w SEMIS
feed:                   data.w $3bf8
fef0:                   data.w DOT
fef3:                   data.w $f6f7
fef6:                   data.w $04a0
fef9:                   data.w $6a03
fefc:                   data.w $8802
feff:                   data.w $b4fa
ff02:                   data.w $0384
ff05:                   data.w $086a
ff08:                   data.w $6a28
ff0b:                   data.w $856a
ff0e:                   data.w $60a9
ff11:                   data.w $b5ea
ff14:                   data.w $0277
ff17:                   data.w $b503
ff1a:                   data.w $1c85
ff1d:                   data.w $8501
ff20:                   data.w $115f
ff23:                   data.w $02d7
ff26:                   data.w $eae0
ff29:                   data.w $e8e8
ff2c:                   data.w POPTWO
ff2f:                   data.w $a5ff
ff32:                   data.w $b548
ff35:                   data.w $0185
ff38:                   data.w POP
ff3b:                   data.w $68ff
ff3e:                   data.w $4c01
ff41:                   data.w $74f7
ff44:                   data.w BANKPSH
ff47:                   data.w $3af8
ff4a: ;;
ff4a: ;;
ff4a: ;;
ff4a: BANKCAT:         data.w DOCOL
ff4d:                   data.w $4bff
ff50:                   data.w BANKPOP
ff53:                   data.w $2ef8
ff56:                   data.w EECSTORE
ff59:                   data.w $74ff
ff5c:                   data.w BANKPSH
ff5f:                   data.w $3af4
ff62: unkn5: STA W
ff64:           STY WP1
ff66:           LDY #$00
ff68:           PLA 
ff69:           STA $5d
ff6b:           PLA 
ff6c:           STA $5e
ff6e:           INC $5d
ff70:           BNE $ff74
ff72:           INC $5e
ff74:           LDA #$7f
ff76:           STA IP
ff78:           LDA #$ff
ff7a:           STA IPP1
ff7c:           JMP $4b4c
ff7f: unkn6: EOR $005d,X
ff82:           DATA.b $42 
ff83:           BRK 
ff84:           JMP ($406c)
ff87:           CMP $f7
ff89:           SEI 
ff8a:           SMB 7, $78
ff8c:           SMB 7, $3b
ff8e:           SED 
ff8f:           ADC ($f4),Y
ff91:           RMB 1, $f7
ff93:           STA $ff,X
ff95:           LDA #$20
ff97:           BIT $062c
ff9a:           BEQ $ffa8
ff9c:           STA $068d
ff9f:           STY $5d
ffa1:           DEC $5d
ffa3:           BNE $ffa1
ffa5:           DEY 
ffa6:           BNE $ffa1
ffa8:           JSR $a820
ffab:           JMP $454c
ffae:           LDA #$00
ffb0:           STA $068d
ffb3:           JMP $014c
ffb6: ;;
ffb6: ;;
ffb6: ;;
ffb6: unkna:         data.w DOCOL
ffb9:                   data.w $58f6
ffbc:                   data.w $4b17
ffbf:                   data.w CLIT
ffc2:         data.b $38
ffc3:                   data.w $97f9
ffc6:                   data.w $ffcb
ffc9:                   data.w $74ff
ffcc:                   data.w CR
ffcf:                   data.w $3ef4
ffd2:                   data.w $b1f5
ffd5:                   data.w QUERY
ffd8:                   data.w $aff8
ffdb:                   data.w TIB
ffde:                   data.w $06f8
ffe1:                   data.w TWODROP
ffe4:                   data.w $3bf8
ffe7:                   data.w CAT
ffea:                   data.w $57f4
ffed:                   data.w $97f9
fff0:                   data.w PortE
fff3:                   data.w $80f4
fff6:                   data.w $ffd6
fff9:                   data.w $81ff
fffc: RESETVEC:         data.w $fb4d
ffff:                   data.w $ffff
EOF
IndX: 0 IndY: 2
