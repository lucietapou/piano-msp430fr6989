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
	 .global stIni,stTime
	 .bss SystemTimer, 4, 2
	 .bss stPeriodo, 2




stIni:
	mov.w	#TASSEL__ACLK|MC__CONTINUOUS|TACLR,&TA2CTL
	mov.w	r12, &stPeriodo
	mov.w	r12, TA2CCR0
	mov.w	#CCIE,TA2CCTL0
	ret

stTime:
	mov.w	sr,r11
	dint
	nop
	mov.w	&SystemTimer, r12
	mov.w	&SystemTimer+2, r13
	nop
	mov.w	r11,sr
	nop
	ret

stA2ISR:
	bic.w	#CCIFG, &TA2CCTL0 ; en teoría ya se borra sola
	inc.w	&SystemTimer
	adc.w	&SystemTimer+2
	add.w   &stPeriodo, &TA2CCR0
	bic.w 	#LPM4, 0(sp)	;elimino el modo de bajo consumo en la dirección que hay en la pila que es SR porque se apila al interrumpir
	reti






	.intvec TIMER2_A0_VECTOR, stA2ISR

