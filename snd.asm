;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"st.h"      		; Include device header file
            .cdecls C,LIST,"msp430ports.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

            .global sndIni
            .global sndMute
            .global sndNota

SMCLK       .equ    1000000        ; 1 MHz


TabOct4:    .word   SMCLK/262, SMCLK/277, SMCLK/294, SMCLK/311
            .word   SMCLK/330, SMCLK/349, SMCLK/370, SMCLK/392
            .word   SMCLK/415, SMCLK/440, SMCLK/466, SMCLK/494

TabOct5:    .word   SMCLK/523, SMCLK/554, SMCLK/587, SMCLK/622
            .word   SMCLK/659, SMCLK/698, SMCLK/740, SMCLK/784
            .word   SMCLK/831, SMCLK/880, SMCLK/932, SMCLK/988

TabOct6:    .word   SMCLK/1047, SMCLK/1109, SMCLK/1175, SMCLK/1245
            .word   SMCLK/1319, SMCLK/1397, SMCLK/1480, SMCLK/1568
            .word   SMCLK/1661, SMCLK/1760, SMCLK/1865, SMCLK/1976


            .bss    Notactiva,2,2   ; semiperiodo actual

sndIni:
    ;P1.0 -> TA0.1
    bis.b   #BIT0, &P1SEL0
    bic.b   #BIT0, &P1SEL1
    bis.b   #BIT0, &P1DIR

    mov.w   #TASSEL__SMCLK | MC__CONTINUOUS | TACLR, &TA0CTL
    mov.w   #OUTMOD_0, &TA0CCTL1
    ;mov.w   #0, &TA0CCR1
    mov.w   #0, &Notactiva
    ret


sndMute:
    tst.w   r12
    jz      snd_on
    ;mute != 0 → pin como entrada
    bic.b   #BIT0, &P1DIR
    ret
snd_on:
    ;mute = 0 → pin como salida
    bis.b   #BIT0, &P1DIR
    ret

sndNota:
    ;oct = 0 → silencio
    tst.w   r12
    jz      silencio
    ;comprobar octava
    cmp.w   #4, r12
    jlo     error
    cmp.w   #7, r12
    jhs     error
    ;comprobar nota
    cmp.w   #12, r13
    jhs     error
    add.w   r13, r13     ; offset word
    cmp.w   #4, r12
    jne     chk5
    mov.w   TabOct4(r13), r14
    jmp     cargar
chk5:
    cmp.w   #5, r12
    jne     chk6
    mov.w   TabOct5(r13), r14
    jmp     cargar
chk6:
    mov.w   TabOct6(r13), r14
cargar:
	rra.w   r14                 ; r14 = periodo/2 (para toggle)
    mov.w   r14, &Notactiva
    mov.w   &TA0R, r15
    add.w   r14, r15
    mov.w   r15, &TA0CCR1
    mov.w   #OUTMOD_4|CCIE, &TA0CCTL1
    clr.w   r12
    ret
silencio:
    mov.w   #OUTMOD_0, &TA0CCTL1
    clr.w   r12
    ret
error:
    mov.w   #-1, r12
    ret


TA0_1_ISR:
    add.w   &TA0IV, PC
    reti                    ; CCR0
    jmp     CC1
    reti
    reti
    reti
    reti
    reti
    reti

CC1:
    add.w   &Notactiva, &TA0CCR1
    reti

            .intvec TIMER0_A1_VECTOR, TA0_1_ISR
