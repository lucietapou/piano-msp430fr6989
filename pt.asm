;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"pt.h"      		; Include device header file
            .cdecls C,LIST,"msp430ports.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
	.global TabPuertos, TabBits
	.global ptConfigura
    .global ptLee
    .global ptEscribe
    .global ptLeeFlanco
    .global ptEscFlanco
    .global ptLeeHabIRQ
    .global ptEscHabIRQ
    .global ptLeeIRQ
    .global ptBorraIRQ



;-------------------------------------------------------------------------------
ptConfigura:
    push    r10
    push    r9
    cmp     #11,r12				;reviso rango
    jhs     ptCfg_Error
    mov.w   r12,r11
    rla.w   r11
    mov.w   TabPuertos(r11),r11	;dirección de puerto r11
    mov.w   r13,r10
    and.w   #7,r10
    mov.b   TabBits(r10),r10	;mascara de bit r10
    mov.w   r14,r15
    and.w   #MD_FUNC,r15
    jz      ptCfg_ES			; si la funcion es E/S salto
    rra.w   r15
    rra.w   r15
    bit.w   #1,r15				; muevo función a bits 1-0 y reviso BIT0
    jz      ptCfg_Sel0_0		; si es 0, SEL0=0
    bis.b   r10,PSEL0(r11)		;SEL0=1
    jmp     ptCfg_Sel1
ptCfg_Sel0_0:
    bic.b   r10,PSEL0(r11)		;SEL0=0
ptCfg_Sel1:
    bit.w   #2,r15				;BIT1 FUNCIÓN?
    jz      ptCfg_Sel1_0
    bis.b   r10,PSEL1(r11)		;SEL1=1
    jmp     ptCfg_Formato
ptCfg_Sel1_0:
    bic.b   r10,PSEL1(r11)
    jmp     ptCfg_Formato
ptCfg_ES:
    bic.b   r10,PSEL0(r11)
    bic.b   r10,PSEL1(r11)
    mov.w   r14,r15
    and.w   #MD_TIPO,r15
    cmp.w   #PT_SALIDA,r15		; es salida?
    jeq     ptCfg_Out
    bic.b   r10,PDIR(r11)		; PDIR=0 entrada
    cmp.w   #PT_ENTRADA,r15		;PREN?
    jeq     ptCfg_In
    bis.b   r10,PREN(r11)
    cmp.w   #PT_ENTRADA_PULLUP,r15
    jeq     ptCfg_Pullup
    bic.b   r10,POUT(r11)		;rpulldown POUT=0
    jmp     ptCfg_IRQ
ptCfg_Pullup:
    bis.b   r10,POUT(r11)		;rpullup POUT=1
    jmp     ptCfg_IRQ
ptCfg_In:
    bic.b   r10,PREN(r11)		;PREN=0 no R DE ENTRADa
    jmp     ptCfg_IRQ
ptCfg_Out:
    bis.b   r10,PDIR(r11)		;PDIR=1 salida
    bit.w   #MD_INI,r14			; valor inicial?
    jz      ptCfg_IniLow		;!=0? empieza en 1
    bit.w   #MD_POL,r14			;polaridad?
    jnz     ptCfg_Out0
    bis.b   r10,POUT(r11)		;si 0... POUT=1
    jmp     ptCfg_NoIRQ
ptCfg_IniLow:
    bit.w   #MD_POL,r14
    jnz     ptCfg_Out1
ptCfg_Out0:
    bic.b   r10,POUT(r11)		;POUT=0
    jmp     ptCfg_NoIRQ
ptCfg_Out1:
    bis.b   r10,POUT(r11)		;POUT=1
    jmp     ptCfg_NoIRQ
ptCfg_IRQ:
    mov.w   r12,r15
    cmp.w   #1,r15
    jlo     ptCfg_Formato
    cmp.w   #5,r15
    jhs     ptCfg_Formato		; compruebo rango entre 1-4
    bit.w   #MD_SF,r14			;miro flanco
    jz      ptCfg_Sub
    bis.b   r10,PIES(r11)		; bajada PIES=1
    jmp     ptCfg_Hab
ptCfg_Sub:
    bic.b   r10,PIES(r11)		;subida
ptCfg_Hab:
    bic.b   r10,PIFG(r11)		;limpiar flag
    bit.w   #MD_IRQ,r14
    jz      ptCfg_NoIRQ
    bis.b   r10,PIE(r11)		;PIE=1 habilito IRQ
    jmp     ptCfg_Formato
ptCfg_NoIRQ:
    bic.b   r10,PIE(r11)		;desactivo int
ptCfg_Formato:
    rla.w   r12
    rla.w   r12
    rla.w   r12					; R12 = Puerto << 3
    add.w   r13,r12				; R12 = (Puerto << 3) | Bit
    bit.w   #MD_POL,r14
    jz      ptCfg_Fin
    bis.w   #0x0080,r12
    jmp     ptCfg_Fin
ptCfg_Error:
    mov.w   #-1,r12
ptCfg_Fin:
    pop     r9
    pop     r10
    ret
;------------Función auxiliar-------------------------------------
; entrada r12= puerto_t r13= registro a modificar
;salida r14= mascara de bit	r15= dirección de puerto
direcP:
    push    r12
    rra.w   r12
    rra.w   r12
    rra.w   r12
    and.w   #0x000F,r12
    cmp     #11,r12
    jhs     direcP_Err
    cmp.w   #PIES,r13
    jlo     direcP_Calc
    cmp.w   #1,r12
    jlo     direcP_Err
    cmp.w   #5,r12
    jhs     direcP_Err
direcP_Calc:
    mov.w   r12,r15
    rla.w   r15
    mov.w   TabPuertos(r15),r15
    pop     r12
    mov.w   r12,r14
    and.w   #7,r14
    mov.b   TabBits(r14),r14
    ret
direcP_Err:
    pop     r12
    clr.w   r15
    ret
;---------Todas las funciones de lectura pasan por aquí---------
ptLeeReg:
    call    #direcP
    tst.w   r15				;reviso si está fuera de rango
    jz      ptLR_Err
    add.w   r13,r15			;dirección de registro+de puerto
    mov.b   0(r15),r12
    and.w   r14,r12			; modifico solo bit
    ret
ptLR_Err:
    clr.w   r12
    ret
;----------Todas las funciones de escritura pasan por aquí------------
ptEscribeReg:
    push    r14			; me dice la forma de escritura	0,1,xor
    call    #direcP
    mov.w   r14,r11		; mascara de bit a r11
    pop     r14
    tst.w   r15			; reviso si esá fuera de rango
    jz      ptER_Ret
    add.w   r13,r15		;dirección de registro+de puerto
    cmp.w   #0,r14
    jeq     ptER_0
    cmp.w   #1,r14
    jeq     ptER_1
    xor.b   r11,0(r15)
    ret
ptER_0:
    bic.b   r11,0(r15)
    ret
ptER_1:
    bis.b   r11,0(r15)
ptER_Ret:
    ret
;------------------------------------
ptLee:
    push    r12
    mov.w   #PIN,r13
    call    #ptLeeReg
    mov.w   r12,r14
    pop     r12
    tst.w   r14			;miro 	PIN
    jz      ptLee_0
    mov.w   #1,r14
ptLee_0:
    bit.w   #0x0080,r12	;reviso polaridad
    jz      ptLee_Fin	;directa
    xor.w   #1,r14		;inversa
ptLee_Fin:
    mov.w   r14,r12
    ret
;--------------------------------------
ptEscribe:
    mov.w   r12,r15
    mov.w   r13,r14
    mov.w   #POUT,r13
    bit.w   #0x0080,r15	;reviso polaridad
    jz      ptEsc_Go
    xor.w   #1,r14
    and.w   #1,r14
ptEsc_Go:
    call    #ptEscribeReg
    ret
;-----------------------------------------
ptLeeFlanco:
    mov.w   #PIES,r13
    call    #ptLeeReg
    tst.w   r12
    jz      ptLF_Ret
    mov.w   #1,r12
ptLF_Ret:
    ret
;--------------------------------------------
ptEscFlanco:
    mov.w   r13,r14
    mov.w   #PIES,r13
    call    #ptEscribeReg
    ret
;----------------------------------------
ptLeeHabIRQ:
    mov.w   #PIE,r13
    call    #ptLeeReg
    tst.w   r12
    jz      ptLHI_Ret
    mov.w   #1,r12
ptLHI_Ret:
    ret
;------------------------------------
ptEscHabIRQ:
    mov.w   r13,r14
    mov.w   #PIE,r13
    call    #ptEscribeReg
    ret
;-------------------------------------
ptLeeIRQ:
    mov.w   #PIFG,r13
    call    #ptLeeReg
    tst.w   r12
    jz      ptLI_Ret
    mov.w   #1,r12
ptLI_Ret:
    ret
;-----------------------------------------
ptBorraIRQ:
    mov.w   #PIFG,r13
    mov.w   #0,r14
    call    #ptEscribeReg
    ret
