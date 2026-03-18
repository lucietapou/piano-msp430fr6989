;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"lcd.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global lcdIni,lcda2seg,lcdPintaIzq,lcdPintaDer,lcdBorraTodo,lcdBorra,lcdBateria,lcdIconos,lcdInterDigito

;-------------------------------------------------------------------------------
; void lcdIni (void)
;-------------------------------------------------------------------------------
lcdIni		;Conectar puertos del LCD con el exterior
			mov.w	#0xFFD0, &LCDCPCTL0
			mov.w	#0xF83F, &LCDCPCTL1
			mov.w	#0x00F8, &LCDCPCTL2

			;Reloj=ACLK, Divisor=1, Predivisor=16, 4MUX, Low power
			mov.w	#LCDDIV__2 | LCDPRE__16 | LCD4MUX | LCDLP, &LCDCCTL0; PONER DIVISOR A 1....

 			;VLCD=2'6 interno, V2-V5 interno, V5=0, charge pump con referencia interna
 			mov.w	#VLCD_1 | VLCDREF_0 | LCDCPEN, &LCDCVCTL
 			;Habilitar sincronizaci√≥n de reloj
 			mov.w	#LCDCPCLKSYNC, &LCDCCPCTL
 			mov.w	#LCDCLRM, &LCDCMEMCTL	;Borrar memoria del LCD

			bis.w	#LCDON, &LCDCCTL0		;Encender LCD_C
			ret

;-------------------------------------------------------------------------------
; Tabla de conversi√≥n de 14 segmentos
;-------------------------------------------------------------------------------
			;       abcdefgm   hjkpq-n-
Tab14Seg	.byte	00000000b, 00000000b	;Espacio
			.byte	00000000b, 00000000b	;!
			.byte	00000000b, 00000000b	;"
			.byte	00000000b, 00000000b	;#
			.byte	00000000b, 00000000b	;$
			.byte	00000000b, 00000000b	;%
			.byte	00000000b, 00000000b	;&
			.byte	00000000b, 00000000b	;'
			.byte	00000000b, 00000000b	;(
			.byte	00000000b, 00000000b	;)
			.byte	00000011b, 11111010b	;*
			.byte	00000011b, 01010000b	;+
			.byte	00000000b, 00000000b	;,
			.byte	00000011b, 00000000b	;-
			.byte	00000000b, 00000000b	;.
			.byte	00000000b, 00101000b	;/
			;       abcdefgm   hjkpq-n-
			.byte	11111100b, 00101000b	;0
			.byte	01100000b, 00100000b	;1
			.byte	11011011b, 00000000b	;2
			.byte	11110011b, 00000000b	;3
			.byte	01100111b, 00000000b	;4
			.byte	10110111b, 00000000b	;5
			.byte	10111111b, 00000000b	;6
			.byte	10000000b, 00110000b	;7
			.byte	11111111b, 00000000b	;8
			.byte	11100111b, 00000000b	;9
			.byte	00000000b, 00000000b	;:
			.byte	00000000b, 00000000b	;;
			.byte	00000000b, 00100010b	;<
			.byte	00010011b, 00000000b	;=
			.byte	00000000b, 10001000b	;>
			.byte	00000000b, 00000000b	;?
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 00000000b	;@
			.byte	01100001b, 00101000b	;A
			.byte	11110001b, 01010000b	;B
			.byte	10011100b, 00000000b	;C
			.byte	11110000b, 01010000b	;D
			.byte	10011110b, 00000000b	;E
			.byte	10001110b, 00000000b	;F
			.byte	10111101b, 00000000b	;G
			.byte	01101111b, 00000000b	;H
			.byte	10010000b, 01010000b	;I
			.byte	01111000b, 00000000b	;J
			.byte	00001110b, 00100010b	;K
			.byte	00011100b, 00000000b	;L
			.byte	01101100b, 10100000b	;M
			.byte	01101100b, 10000010b	;N
			.byte	11111100b, 00000000b	;O
			;       abcdefgm   hjkpq-n-
			.byte	11001111b, 00000000b	;P
			.byte	11111100b, 00000010b	;Q
			.byte	11001111b, 00000010b	;R
			.byte	10110111b, 00000000b	;S
			.byte	10000000b, 01010000b	;T
			.byte	01111100b, 00000000b	;U
			.byte	01100000b, 10000010b	;V
			.byte	01101100b, 00001010b	;W
			.byte	00000000b, 10101010b	;X
			.byte	00000000b, 10110000b	;Y
			.byte	10010000b, 00101000b	;Z
			.byte	10011100b, 00000000b	;[
			.byte	00000000b, 10000010b	;\
			.byte	11110000b, 00000000b	;]
			.byte	01000000b, 00100000b	;^
			.byte	00010000b, 00000000b	;_
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 10000000b	;`
			.byte	00011010b, 00010000b	;a
			.byte	00111111b, 00000000b	;b
			.byte	00011011b, 00000000b	;c
			.byte	01111011b, 00000000b	;d
			.byte	00011010b, 00001000b	;e
			.byte	10001110b, 00000000b	;f
			.byte	11110111b, 00000000b	;g
			.byte	00101111b, 00000000b	;h
			.byte	00000000b, 00010000b	;i
			.byte	01110000b, 00000000b	;j
			.byte	00000000b, 01110010b	;k
			.byte	00000000b, 01010000b	;l
			.byte	00101011b, 00010000b	;m
			.byte	00100001b, 00010000b	;n
			.byte	00111011b, 00000000b	;o
			;       abcdefgm   hjkpq-n-
			.byte	00001110b, 10000000b	;p
			.byte	11100111b, 00000000b	;q
			.byte	00000001b, 00010000b	;r
			.byte	00010001b, 00000010b	;s
			.byte	00000011b, 01010000b	;t
			.byte	00111000b, 00000000b	;u
			.byte	00100000b, 00000010b	;v
			.byte	00101000b, 00001010b	;w
			.byte	00000000b, 10101010b	;x
			.byte	01110001b, 01000000b	;y
			.byte	00010010b, 00001000b	;z
			.byte	00000000b, 00000000b	;{
			.byte	00000000b, 00000000b	;|
			.byte	00000000b, 00000000b	;}
			.byte	00000000b, 00000000b	;~
			.byte	00000000b, 00000000b	;




lcda2seg    cmp.b #32, R12;  es menor que 32?
            jlo   OutR
            cmp.b #128, R12;  es mayor o igual a 128?
            jhs   OutR
            mov.b R12,R13
            sub.b #32,R13
            rla.b R13
            mov.w Tab14Seg(R13), R12
            ret
OutR        mov.w #0xFFFF, R12
            ret


A6B	.equ LCDM8
A6H	.equ LCDM9
A5B	.equ LCDM15
A5H	.equ LCDM16
A4B	.equ LCDM19
A4H	.equ LCDM20
A3B	.equ LCDM4
A3H	.equ LCDM5
A2B	.equ LCDM6
A2H	.equ LCDM7
A1B	.equ LCDM10
A1H	.equ LCDM11


lcdPintaIzq:
            call    #lcda2seg
            cmp.w   #0xFFFF, R12
            jeq     lcdPintaIzqFin

            mov.w   R12, R13
            mov.b   #5, R11


A2_A1:
            mov.b   &A2B, &A1B
            mov.b   &A1H, R15
            and.b   R11, R15
            mov.b   &A2H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A1H


A3_A2:
            mov.b   &A3B,&A2B
            mov.b   &A2H, R15
            and.b   R11, R15
            mov.b   &A3H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A2H


A4_A3:
            mov.b   &A4B, &A3B
            mov.b   &A3H, R15
            and.b   R11, R15
            mov.b   &A4H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A3H


A5_A4:
            mov.b   &A5B,&A4B
            mov.b   &A4H, R15
            and.b   R11, R15
            mov.b   &A5H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A4H


A6_A5:
            mov.b   &A6B,&A5B
            mov.b   &A5H, R15
            and.b   R11, R15
            mov.b   &A6H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A5H


c_A6:
            mov.b   R13, &A6B
            mov.b   &A6H, R15
            and.b   R11, R15
            swpb    R13
            mov.b   R13, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A6H

lcdPintaIzqFin:
            ret







lcdPintaDer: call    #lcda2seg
            cmp.w   #0xFFFF, R12
            jeq     lcdPintaDerFin

            mov.b   #5, R11
            mov.w   R12, R13

A5_A6		mov.b   &A5B, &A6B
            mov.b   &A6H, R15
            and.b   R11, R15
            mov.b   &A5H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A6H

A4_A5		mov.b   &A4B, &A5B
            mov.b   &A5H, R15
            and.b   R11, R15
            mov.b   &A4H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A5H

A3_A4		mov.b   &A3B, &A4B
            mov.b   &A4H, R15
            and.b   R11, R15
            mov.b   &A3H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A4H

A2_A3		mov.b   &A2B, &A3B
            mov.b   &A3H, R15
            and.b   R11, R15
            mov.b   &A2H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A3H

A1_A2		mov.b   &A1B, &A2B
            mov.b   &A2H, R15
            and.b   R11, R15
            mov.b   &A1H, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A2H

c_A1
           	mov.b   R13, &A1B
            mov.b   &A1H, R15
            and.b   R11, R15
            swpb    R13
            mov.b   R13, R12
            bic.b   R11, R12
            bis.b   R12, R15
            mov.b   R15, &A1H

lcdPintaDerFin:	ret


lcdBorraTodo:
			bis.w   #LCDCLRM, &LCDCMEMCTL
            ret

lcdBorra	clr.b   &A1B
			bic.b	#-6,&A1H
            clr.b   &A2B
            bic.b	#-6,&A2H
            clr.b   &A3B
            bic.b	#-6,&A3H
            clr.b   &A4B
            bic.b	#-6,&A4H
            clr.b   &A5B
            bic.b	#-6,&A5H
            clr.b   &A6B
            bic.b	#-6,&A6H
            ret




Bpar:	.equ LCDM14
Bimpar:	.equ LCDM18

lcdBateria:	clr.w r13
		;LÛgico BIT0 (Barra 1) - FÌsico BIT5 Bimpar
           bit.b   #BIT5, &Bimpar	;miro como est·
            jnc     b1_leido		; si es 0 salto
            bis.b   #BIT0, R13		; guardo estado anterior 1
b1_leido
            bit.b   #BIT0, R12		; miro si hay que encender
            jnc     b1_apagar
            bis.b   #BIT5, &Bimpar
            jmp     b1fin
b1_apagar
            bic.b   #BIT5, &Bimpar	;
b1fin:

;  LÛgico BIT1 (Barra 2) - FÌsico BIT5 Bpar
            bit.b   #BIT5, &Bpar
            jnc     b2_leido
            bis.b   #BIT1, R13
b2_leido:
            bit.b   #BIT1, R12
            jnc     b2_apagar
            bis.b   #BIT5, &Bpar
            jmp     b2fin
b2_apagar:
            bic.b   #BIT5, &Bpar
b2fin:

;  LÛgico BIT2 (Barra 3) - FÌsico BIT6  Bimpar
            bit.b   #BIT6, &Bimpar
            jnc     b3_leido
            bis.b   #BIT2, R13
b3_leido
            bit.b   #BIT2, R12
            jnc     b3_apagar
            bis.b   #BIT6, &Bimpar
            jmp     b3fin
b3_apagar
            bic.b   #BIT6, &Bimpar
b3fin

;LÛgico BIT3 (Barra 4) -FÌsico BIT6 Bpar
            bit.b   #BIT6, &Bpar
            jnc     b4_leido
            bis.b   #BIT3, R13
b4_leido
            bit.b   #BIT3, R12
            jnc     b4_apagar
            bis.b   #BIT6, &Bpar
            jmp     b4fin
b4_apagar
            bic.b   #BIT6, &Bpar
b4fin
; LÛgico BIT4 (Barra 5) - FÌsico BIT7  Bimpar
            bit.b   #BIT7, &Bimpar
            jnc     b5_leido
            bis.b   #BIT4, R13
b5_leido
            bit.b   #BIT4, R12
            jnc     b5_apagar
            bis.b   #BIT7, &Bimpar
            jmp     b5fin
b5_apagar
            bic.b   #BIT7, &Bimpar
b5fin

; LÛgico BIT5 (Barra 6) - FÌsico BIT7 Bpar
            bit.b   #BIT7, &Bpar
            jnc     b6_leido
            bis.b   #BIT5, R13
b6_leido
            bit.b   #BIT5, R12
            jnc     b6_apagar
            bis.b   #BIT7, &Bpar
            jmp     b6fin
b6_apagar
            bic.b   #BIT7, &Bpar
b6fin

; LÛgico BIT6 (Marco) - FÌsico BIT4 Bimpar
            bit.b   #BIT4, &Bimpar
            jnc     bMarco_leido
            bis.b   #BIT6, R13
bMarco_leido
            bit.b   #BIT6, R12
            jnc     bMarco_apagar
            bis.b   #BIT4, &Bimpar
            jmp     bMarcofin
bMarco_apagar
            bic.b   #BIT4, &Bimpar
bMarcofin

;LÛgico BIT7 (Polo) - FÌsico BIT4 Bpar
            bit.b   #BIT4, &Bpar
            jnc     bPolo_leido
            bis.b   #BIT7, R13
bPolo_leido
            bit.b   #BIT7, R12
            jnc     bPolo_apagar
            bis.b   #BIT4, &Bpar
            jmp     bPolofin
bPolo_apagar
            bic.b   #BIT4, &Bpar
bPolofin

            mov.b   R13, R12
            ret

RDEG    .equ    LCDM16
DEG     .equ    BIT2
RANT    .equ    LCDM5
ANT     .equ    BIT2
RXX     .equ    LCDM9
TX      .equ    BIT2
RX      .equ    BIT0
RTOT    .equ    LCDM3
TMR     .equ    BIT3
HRT     .equ    BIT2
REC     .equ    BIT1
EX      .equ    BIT0
lcdIconos:	clr.b r13
;--------------EX--------------
           bit.b   #EX, &RTOT	;miro como est·
            jnc     EX_leido		; si es 0 salto
            bis.b   #BIT0, R13		; guardo estado anterior 1
EX_leido
            bit.b   #BIT0, R12		; miro si hay que encender
            jnc     EX_apagar
            bis.b   #EX, &RTOT
            jmp     EXfin
EX_apagar
            bic.w   #EX, &RTOT
EXfin:
;---------------REC-----------------
            bit.b   #REC, &RTOT
            jnc     REC_leido
            bis.b   #BIT1, R13
REC_leido:
            bit.b   #BIT1, R12
            jnc     REC_apagar
            bis.b   #REC, &RTOT
            jmp     RECfin
REC_apagar:
            bic.b   #REC, &RTOT
RECfin:
;--------------------HRT--------------
            bit.b   #HRT, &RTOT
            jnc     HRT_leido
            bis.b   #BIT2, R13
HRT_leido:
            bit.b   #BIT2, R12
            jnc     HRT_apagar
            bis.b   #HRT, &RTOT
            jmp     HRTfin
HRT_apagar:
            bic.b   #HRT, &RTOT
HRTfin:
         ;-----------TMR------------
            bit.b   #TMR, &RTOT
            jnc     TMR_leido
            bis.b   #BIT3, R13
TMR_leido:
            bit.b   #BIT3, R12
            jnc     TMR_apagar
            bis.b   #TMR, &RTOT
            jmp     TMRfin
TMR_apagar:
            bic.b   #TMR, &RTOT
TMRfin:

;----------------RX----------------
            bit.b   #RX, &RXX
            jnc     RX_leido
            bis.b   #BIT4, R13
RX_leido:
            bit.b   #BIT4, R12
            jnc     RX_apagar
            bis.b   #RX, &RXX
            jmp     RXfin
RX_apagar:
            bic.b   #RX, &RXX
RXfin:
  ;-----------------ANT--------------------

            bit.b   #ANT, &RANT
            jnc     ANT_leido
            bis.b   #BIT5, R13
ANT_leido:
            bit.b   #BIT5, R12
            jnc     ANT_apagar
            bis.b   #ANT, &RANT
            jmp     ANTfin
ANT_apagar:
            bic.b   #ANT, &RANT
ANTfin:
         ;--------TX------------------
            bit.b   #TX, &RXX
            jnc     TX_leido
            bis.b   #BIT6, R13
TX_leido:
            bit.b   #BIT6, R12
            jnc     TX_apagar
            bis.b   #TX, &RXX
            jmp     TXfin
TX_apagar:
            bic.b   #TX, &RXX
TXfin:
         ;---------DEG--------------------
            bit.b   #DEG, &RDEG
            jnc     DEG_leido
            bis.b   #BIT7, R13
DEG_leido:
            bit.b   #BIT7, R12
            jnc     DEG_apagar
            bis.b   #DEG, &RDEG
            jmp     DEGfin
DEG_apagar:
            bic.b   #DEG, &RDEG
DEGfin:
 			mov.b   R13, R12
            ret

RA4		.equ LCDM20
COL4	.equ BIT2
P4		.equ BIT0
RA5		.equ LCDM16
P5		.equ BIT0
RA1		.equ LCDM11
P1		.equ BIT0
NEG		.equ BIT2
RA2		.equ LCDM7
COL2	.equ BIT2
P2		.equ BIT0
RA3		.equ LCDM5
P3		.equ BIT0


lcdInterDigito: ;negativo
			clr.b r13
			bit.b   #NEG, &RA1		;miro como est·
            jnc     NEG_leido		; si es 0 salto
            bis.b   #BIT0, R13		; guardo estado anterior 1
NEG_leido
            bit.b   #BIT0, R12		; miro si hay que encender
            jnc     NEG_apagar
            bis.b   #NEG, &RA1
            jmp     NEGfin
NEG_apagar
            bic.b   #NEG, &RA1
NEGfin:

			;A1DP
			bit.b   #P1, &RA1
            jnc     P1_leido
            bis.b   #BIT1, R13
P1_leido
            bit.b   #BIT1, R12
            jnc     P1_apagar
            bis.b   #P1, &RA1
            jmp     P1fin
P1_apagar
            bic.b   #P1, &RA1
P1fin:
			;A2DP
			bit.b   #P2, &RA2
            jnc     P2_leido
            bis.b   #BIT2, R13
P2_leido
            bit.b   #BIT2, R12
            jnc     P2_apagar
            bis.b   #P2, &RA2
            jmp     P2fin
P2_apagar
            bic.b   #P2, &RA2
P2fin:
			;A3DP
			bit.b   #P3, &RA3
            jnc     P3_leido
            bis.b   #BIT3, R13
P3_leido
            bit.b   #BIT3, R12
            jnc     P3_apagar
            bis.b   #P3, &RA3
            jmp     P3fin
P3_apagar
            bic.b   #P3, &RA3
P3fin:

			;A4DP
			bit.b   #P4, &RA4
            jnc     P4_leido
            bis.b   #BIT4, R13
P4_leido
            bit.b   #BIT4, R12
            jnc     P4_apagar
            bis.b   #P4, &RA4
            jmp     P4fin
P4_apagar
            bic.b   #P4, &RA4
P4fin:
			;A5DP
			bit.b   #P5, &RA5
            jnc     P5_leido
            bis.b   #BIT5, R13
P5_leido
            bit.b   #BIT5, R12
            jnc     P5_apagar
            bis.b   #P5, &RA5
            jmp     P5fin
P5_apagar
            bic.b   #P5, &RA5
P5fin:

			;A4COL
			bit.b   #COL4, &RA4
            jnc     COL4_leido
            bis.b   #BIT6, R13
COL4_leido
            bit.b   #BIT6, R12
            jnc     COL4_apagar
            bis.b   #COL4, &RA4
            jmp     COL4fin
COL4_apagar
            bic.b   #COL4, &RA4
COL4fin:

			;A2COL
			bit.b   #COL2, &RA2
            jnc     COL2_leido
            bis.b   #BIT7, R13
COL2_leido
            bit.b   #BIT7, R12
            jnc     COL2_apagar
            bis.b   #COL2, &RA2
            jmp     COL2fin
COL2_apagar
            bic.b   #COL2, &RA2
COL2fin:

			mov.b   R13, R12
            ret
