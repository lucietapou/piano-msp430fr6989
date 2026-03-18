;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"cs.h"      		; Include device header file
            .cdecls C,LIST,"msp430ports.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
	.global csIniLFXT

	 .bss SystemTimer, 4, 2
	 .bss stPeriodo, 2



csIniLFXT:
	bis.w	#BIT4, &PJSEL0
	bic.w	#BIT4, &PJSEL1
	mov.b	#CSKEY_H, CSCTL0_H
	bic.w 	#LFXTOFF, CSCTL4
csIniLFXT_borrflg:
	bic.w 	#LFXTOFFG, CSCTL5
	bic.w	#OFIFG, SFRIFG1
	bit.w	#LFXTOFFG, CSCTL5
	jnz		csIniLFXT_borrflg
	clr.b	CSCTL0_H
	ret
