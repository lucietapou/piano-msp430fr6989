;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"pt.h"      		; Include device header file
            .cdecls C,LIST,"msp430ports.h"
            ;.cdecls C,LIST,"teclado.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

            .global kbBarrido, kbLeeTecla, kbIni
            .global kbTeclaISR, kbReboteISR

TAMBUFTEC   .equ    16
ETX         .equ    3
NOTECLA     .equ    0

            .bss    Tecla, TAMBUFTEC, 2
            .bss    Indice, 2
            .bss    puntEscribe, 2
            .bss    puntLee, 2
            .bss    numTeclas, 2
            ;numTeclas aumenta al escribir y disminuye al leer
            ;no se puede escribir si numTeclas == TAMBUFTEC
            ;no se puede leer si numTeclas == 0
            .bss    TeclaAnterior, 1


TabTeclas:
    .byte   7,   'C', 'D', '+'     ; Bel, Do#, Re#, +
    .byte   'c', 'd', 'e', '-'     ; Do, Re, Mi, -
    .byte   13,  'F', 'G', 'A'     ; CR, Fa#, Sol#, La#
    .byte   'f', 'g', 'a', 'b'     ; Fa, Sol, La, Si

F0          .equ    BIT2        ; P3.2
F1          .equ    BIT7        ; P4.7
F2          .equ    BIT4        ; P2.4
F3          .equ    BIT5        ; P2.5
C0          .equ    BIT0        ; P2.0
C1          .equ    BIT3        ; P9.3
C2          .equ    BIT3        ; P4.3
C3          .equ    BIT2        ; P9.2

kbIni:
    clr.w   &Indice
    clr.w   &puntEscribe
    clr.w   &puntLee
    clr.w   &numTeclas
    mov.b   #0, &TeclaAnterior

    ;columnas como salidas
    bis.b   #C0, &P2DIR
    bic.b   #C0, &P2OUT
    bis.b   #C1, &P9DIR
    bic.b   #C1, &P9OUT
    bis.b   #C2, &P4DIR
    bic.b   #C2, &P4OUT
    bis.b   #C3, &P9DIR
    bic.b   #C3, &P9OUT

    ;filas como entradas con pullup y interrupción
    bic.b   #F0, &P3DIR
    bis.b   #F0, &P3REN
    bis.b   #F0, &P3OUT
    bis.b   #F0, &P3IES
    bic.b   #F0, &P3IFG
    bis.b   #F0, &P3IE

    bic.b   #F1, &P4DIR
    bis.b   #F1, &P4REN
    bis.b   #F1, &P4OUT
    bis.b   #F1, &P4IES
    bic.b   #F1, &P4IFG
    bis.b   #F1, &P4IE

    bic.b   #F2, &P2DIR
    bis.b   #F2, &P2REN
    bis.b   #F2, &P2OUT
    bis.b   #F2, &P2IES
    bic.b   #F2, &P2IFG
    bis.b   #F2, &P2IE

    bic.b   #F3, &P2DIR
    bis.b   #F3, &P2REN
    bis.b   #F3, &P2OUT
    bis.b   #F3, &P2IES
    bic.b   #F3, &P2IFG
    bis.b   #F3, &P2IE
    ret



kbBarrido:
    mov.w   #0, r14          ;contador de detecciones
    mov.w   #NOTECLA, r15    ;resultado por defecto

    ;desactivar columnas temporalmente
    bic.b   #C0, &P2DIR
    bic.b   #C1, &P9DIR
    bic.b   #C2, &P4DIR
    bic.b   #C3, &P9DIR

    ;C0 = salida y poner en 0V
    bis.b   #C0, &P2DIR
    bic.b   #C0, &P2OUT

    ;barrido fila a fila para C0
    bit.b   #F0, &P3IN
    jnz kb_C0F1
    mov.w   #0, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C0F1:
    bit.b   #F1, &P4IN
    jnz kb_C0F2
    mov.w   #4, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C0F2:
    bit.b   #F2, &P2IN
    jnz kb_C0F3
    mov.w   #8, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C0F3:
    bit.b   #F3, &P2IN
    jnz kb_C1_prep
    mov.w   #12, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error

;`preparar columna C1
kb_C1_prep:
    bic.b   #C0, &P2DIR
    bis.b   #C1, &P9DIR
    bic.b   #C1, &P9OUT

    bit.b   #F0, &P3IN
    jnz kb_C1F1
    mov.w   #1, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C1F1:
    bit.b   #F1, &P4IN
    jnz kb_C1F2
    mov.w   #5, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C1F2:
    bit.b   #F2, &P2IN
    jnz kb_C1F3
    mov.w   #9, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C1F3:
    bit.b   #F3, &P2IN
    jnz kb_C2_prep
    mov.w   #13, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error

;preparar columna C2
kb_C2_prep:
    bic.b   #C1, &P9DIR
    bis.b   #C2, &P4DIR
    bic.b   #C2, &P4OUT

    bit.b   #F0, &P3IN
    jnz kb_C2F1
    mov.w   #2, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C2F1:
    bit.b   #F1, &P4IN
    jnz kb_C2F2
    mov.w   #6, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C2F2:
    bit.b   #F2, &P2IN
    jnz kb_C2F3
    mov.w   #10, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C2F3:
    bit.b   #F3, &P2IN
    jnz kb_C3_prep
    mov.w   #14, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error

;preparar columna C3
kb_C3_prep:
    bic.b   #C2, &P4DIR
    bis.b   #C3, &P9DIR
    bic.b   #C3, &P9OUT

    bit.b   #F0, &P3IN
    jnz kb_C3F1
    mov.w   #3, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C3F1:
    bit.b   #F1, &P4IN
    jnz kb_C3F2
    mov.w   #7, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C3F2:
    bit.b   #F2, &P2IN
    jnz kb_C3F3
    mov.w   #11, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error
kb_C3F3:
    bit.b   #F3, &P2IN
    jnz kb_fin
    mov.w   #15, r15
    inc.w   r14
    cmp.w   #2, r14
    jhs kb_error

kb_fin:
    bic.b   #C3, &P9DIR
    cmp.w   #0, r14
    jeq kb_noTecla
    mov.w   #TabTeclas, r11
    add.w   r15, r11
    mov.b   @r11, r12
    jmp kb_activaTodo
kb_noTecla:
    mov.w   #ETX, r12
    jmp kb_activaTodo
kb_error:
    mov.w   #NOTECLA, r12
kb_activaTodo:
    bis.b   #C0, &P2DIR
    bic.b   #C0, &P2OUT
    bis.b   #C1, &P9DIR
    bic.b   #C1, &P9OUT
    bis.b   #C2, &P4DIR
    bic.b   #C2, &P4OUT
    bis.b   #C3, &P9DIR
    bic.b   #C3, &P9OUT
    ret


kbLeeTecla:
    mov.w   sr, r15
    dint
    nop
    cmp.w   #0, &numTeclas
    jeq kbLee_vacio
    mov.w   #Tecla, r11
    add.w   &puntLee, r11
    mov.b   @r11, r12
    and.w   #0xFF, r12
    inc.w   &puntLee
    cmp.w   #TAMBUFTEC, &puntLee
    jl kbLee_noWrap
    clr.w   &puntLee
kbLee_noWrap:
    dec.w   &numTeclas
    nop
    mov.w   r15, sr
    nop
    ret
kbLee_vacio:
    mov.w   #NOTECLA, r12
    nop
    mov.w   r15, sr
    nop
    ret

kbTeclaISR:
	; desactivo int
	bic.b #F0, &P3IE
	bic.b #F1, &P4IE
	bic.b #(F2|F3), &P2IE
	bic.b #F0, &P3IFG
	bic.b #F1, &P4IFG
	bic.b #(F2|F3), &P2IFG

	mov.w #(CAP|CM_3|CCIS_2), &TA2CCTL1	;cap en ambos flancos
	xor.w #CCIS0, &TA2CCTL1
	add.w #328, &TA2CCR1		; aprox 10ms
	;bic.w #CAP, &TA2CCTL1
	mov.w #CCIE, &TA2CCTL1
	bic.w #CCIFG, &TA2CCTL1
	reti

kbReboteISR:
	push	r11
	push	r12
	push 	r14
	push	r15
	push 	r13
    bic.w   #CCIFG, &TA2CCTL1
    bic.w   #CCIE, &TA2CCTL1
    call    #kbBarrido
    cmp.w   #NOTECLA, r12
    jeq kbReb_noEncolar
    cmp.w   #TAMBUFTEC, &numTeclas
    jhs kbReb_noEncolar

    mov.w   #Tecla, r11
    add.w   &puntEscribe,  bj bk bnkj bn bh b b bb bnnnnnnnn bb bbbbbbbbbbbbbbbbbbbbbbb n  b bbbbbbbbbbbbbbbbbb
    mov.b   r12, 0(r11)
    inc.w   &puntEscribe
    cmp.w   #TAMBUFTEC, &puntEscribe
    jl kbReb_noWrap
    clr.w   &puntEscribe
kbReb_noWrap:
    inc.w   &numTeclas
kbReb_noEncolar:
    ;reactivar interrupciones de filas
    xor.b   #F0, &P3IES
    xor.b   #F1, &P4IES
    xor.b   #(F2|F3), &P2IES
    bic.b   #F0, &P3IFG
    bic.b   #F1, &P4IFG
    bic.b   #(F2|F3), &P2IFG
    bis.b   #F0, &P3IE
    bis.b   #F1, &P4IE
    bis.b   #(F2|F3), &P2IE
    bic.w   #LPM3, 0(sp)
    pop 	r13
    pop		r15
    pop		r14
    pop		r12
    pop		r11
    reti


    .intvec PORT2_VECTOR, kbTeclaISR
    .intvec PORT3_VECTOR, kbTeclaISR
    .intvec PORT4_VECTOR, kbTeclaISR
    .intvec TIMER2_A1_VECTOR, kbReboteISR
