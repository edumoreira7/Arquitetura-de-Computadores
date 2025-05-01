RS      equ     P1.3    ; Reg Select ligado em P1.3
EN      equ     P1.2    ; Enable ligado em P1.2

ORG 0000H
    LJMP MAIN

ORG 0100H
MAIN:
    ; Inicializa LCD e exibe mensagem
    ACALL lcd_init

    ; Primeira linha: "APERT E 0"
    MOV A, #01H
    ACALL posicionaCursor
    MOV A, #'A'   ; Letras da mensagem
    ACALL sendCharacter
    MOV A, #'P'
    ACALL sendCharacter
    MOV A, #'E'
    ACALL sendCharacter
    MOV A, #'R'
    ACALL sendCharacter
    MOV A, #'T'
    ACALL sendCharacter
    MOV A, #'E'
    ACALL sendCharacter
    MOV A, #' '
    ACALL sendCharacter
    MOV A, #'0'
    ACALL sendCharacter

    ; Segunda linha: "PARA INICIAR"
    MOV A, #0C0H
    ACALL posicionaCursor
    MOV A, #'P'
    ACALL sendCharacter
    MOV A, #'A'
    ACALL sendCharacter
    MOV A, #'R'
    ACALL sendCharacter
    MOV A, #'A'
    ACALL sendCharacter
    MOV A, #' '
    ACALL sendCharacter
    MOV A, #'I'
    ACALL sendCharacter
    MOV A, #'N'
    ACALL sendCharacter
    MOV A, #'I'
    ACALL sendCharacter
    MOV A, #'C'
    ACALL sendCharacter
    MOV A, #'I'
    ACALL sendCharacter
    MOV A, #'A'
    ACALL sendCharacter
    MOV A, #'R'
    ACALL sendCharacter

    ACALL retornaCursor

    ; Inicializa Timer
    MOV TMOD, #01H
    SETB TR0

ESPERA_USUARIO:
    MOV A, P2
    CJNE A, #0FFH, CONTINUA
    SJMP ESPERA_USUARIO

CONTINUA:
    MOV DPTR, #SEQUENCIA
    MOV R0, #0

MOSTRA_SEQUENCIA:
    MOV A, TL0
    ANL A, #07H
    CJNE A, #05H, OK
    MOV A, #00H
OK:
    CJNE A, #06H, OK2
    MOV A, #01H
OK2:
    CJNE A, #07H, MOSTRA_LED
    MOV A, #02H

MOSTRA_LED:
    MOV R5, A
    MOV A, R5
    MOVC A, @A+DPTR
    MOV P1, A
    ACALL DELAY

    INC R0
    CJNE R0, #5, MOSTRA_SEQUENCIA

    MOV P1, #0FFH
    MOV P2, #0FFH

LEITURA_TECLADO:
    ACALL LER_TECLA
    CJNE A, #0FFH, ACENDE_LED
    SJMP LEITURA_TECLADO

ACENDE_LED:
    CPL A
    MOV P1, A
    ACALL DELAY
    SJMP LEITURA_TECLADO

LER_TECLA:
ESPERA_SOLTAR:
    MOV A, P2
    CJNE A, #0FFH, ESPERA_SOLTAR

ESPERA_PRESSIONAR:
    MOV A, P2
    CJNE A, #0FFH, TECLA_PRESSIONADA
    SJMP ESPERA_PRESSIONAR

TECLA_PRESSIONADA:
    CPL A
    RET

DELAY:
    MOV R6, #0FFH
DELAY_LOOP1:
    MOV R7, #0FFH
DELAY_LOOP2:
    DJNZ R7, DELAY_LOOP2
    DJNZ R6, DELAY_LOOP1
    RET

SEQUENCIA:
    DB 11111110B
    DB 10111111B
    DB 11111011B
    DB 11011111B
    DB 11101111B
    DB 01111111B
    DB 11111101B
    DB 11110111B

lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay_lcd		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay_lcd		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay_lcd		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay_lcd		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay_lcd			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endere o da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	         ; clear RS - indicates that instruction is being sent to module
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay_lcd			; wait for BF to clear
	RET


;Retorna o cursor para primeira posi  o sem limpar o display
retornaCursor:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay_lcd		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay_lcd		; wait for BF to clear
	RET


delay_lcd:
	MOV R0, #50
	DJNZ R0, $
	RET
