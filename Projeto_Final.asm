
RS      equ     P1.3    ; Reg Select ligado em P1.3
EN      equ     P1.2    ; Enable ligado em P1.2

ORG 0000H
    LJMP MAIN

ORG 0030H
APERTE0:
	DB "APERTE 0"
	DB 00H
PARAINICIAR:
	DB "PARA INICIAR"
	DB 00H
ACERTOU:
	DB "ACERTOU"
	DB 00H
ERROU:
	DB "ERROU"
	DB 00H
SUAVEZ:
	DB "SUA VEZ"
	DB 00H

ORG 0100H
MAIN:
    ; Inicializa LCD e exibe mensagem
    ACALL lcd_init

    ; Inicializa Timer
    MOV TMOD, #01H
    SETB TR0

MENSAGEM:
; Primeira linha: "APERTE 0"
    MOV A, #01H
    ACALL posicionaCursor
    MOV DPTR, #APERTE0
	ACALL escreveStringROM

    ; Segunda linha: "PARA INICIAR"
    MOV A, #0C0H
    ACALL posicionaCursor
    MOV DPTR, #PARAINICIAR
	ACALL escreveStringROM

    ACALL retornaCursor

ESPERA_USUARIO:
    MOV A, P2
    CJNE A, #0FFH, CONTINUA
    SJMP ESPERA_USUARIO

CONTINUA:
	ACALL clearDisplay
    MOV DPTR, #SEQUENCIA
    MOV R0, #30H          ; endereço base da RAM para armazenar a sequência mostrada
    MOV R7, #0            ; contador de LEDs mostrados (0 a 4)
    MOV R6, #0            ; índice auxiliar

GERA_SEQUENCIA:
    ; Usa TH0 como semente aleatória
    MOV A, TH0
    ANL A, #00000111B     ; mascara para valores de 0 a 7
    
    ; Verifica se o valor é válido (0-7)
    CJNE A, #8, VALOR_OK
    MOV A, #0             ; se for 8, ajusta para 0
VALOR_OK:

MOSTRA_LED:
    MOV R5, A             ; salva o índice aleatório
    MOVC A, @A+DPTR       ; obtém o padrão do LED
    MOV @R0, A            ; armazena na RAM (30H-34H)
    
    ; Mostra o LED
    MOV P1, A
    ACALL DELAY_200MS     ; mantém aceso por 500ms
    
    ; Apaga o LED
    MOV P1, #0FFH
    ACALL DELAY_100MS     ; pequeno intervalo entre LEDs
    
    ; Prepara próximo LED
    INC R0
    INC R7
    CJNE R7, #5, GERA_SEQUENCIA

    ; Sequência completa, prepara para captura do usuário
    MOV P1, #0FFH
    MOV P2, #0FFH
    MOV R0, #30H          ; reset do ponteiro para a sequência

; INÍCIO DA COMPARAÇÃO
COMPARA_USUARIO:
    ACALL LER_TECLA
    CJNE A, #0FFH, VERIFICA
    SJMP COMPARA_USUARIO

VERIFICA:
    CPL A                 ; inverte bits da tecla pressionada
    MOV B, A              ; salva tecla do usuário em B
    MOV A, @R0            ; carrega valor da sequência original
    CJNE A, B, ERRO

    ; Feedback visual - LED correto
    MOV P1, B
    ACALL DELAY_200MS
    MOV P1, #0FFH

    ; Próxima comparação
    INC R0
    INC R6
    CJNE R6, #5, COMPARA_USUARIO

    ; Todas as teclas conferem!
    SJMP ACERTO

ERRO:
	ACALL clearDisplay
    ACALL DELAY_200MS
    MOV A, #01H
    ACALL posicionaCursor
    MOV DPTR, #ERROU
	ACALL escreveStringROM
    ACALL DELAY_200MS
    SJMP MENSAGEM   ; Reinicia o jogo

ACERTO:
	ACALL clearDisplay
	ACALL DELAY_200MS
    MOV A, #01H
    ACALL posicionaCursor
    MOV DPTR, #ACERTOU
   	ACALL escreveStringROM
    ACALL DELAY_200MS
    LJMP MENSAGEM   ; Reinicia o jogo

; ==============================================
; Rotinas de leitura de tecla
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

; Delays melhor calibrados
DELAY_500MS:
    MOV R3, #5
DELAY_500_LOOP:
    ACALL DELAY_100MS
    DJNZ R3, DELAY_500_LOOP
    RET

DELAY_200MS:
    MOV R3, #2
DELAY_200_LOOP:
    ACALL DELAY_100MS
    DJNZ R3, DELAY_200_LOOP
    RET

DELAY_100MS:
    MOV R4, #100
DELAY_100_LOOP:
    MOV R5, #250
    DJNZ R5, $
    DJNZ R4, DELAY_100_LOOP
    RET

SEQUENCIA:
    DB 11111110B   ; LED 0
    DB 11111101B   ; LED 1
    DB 11111011B   ; LED 2
    DB 11110111B   ; LED 3
    DB 11101111B   ; LED 4
    DB 11011111B   ; LED 5
    DB 10111111B   ; LED 6
    DB 01111111B   ; LED 7

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

escreveStringROM:
  MOV R1, #00h
	; Inicia a escrita da String no Display LCD
loop:
  MOV A, R1
	MOVC A,@A+DPTR 	 ;lê da memória de programa
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	ACALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
   MOV A, R1
	JMP loop		; repeat
finish:
	RET



delay_lcd:
	MOV R0, #50
	DJNZ R0, $
	RET
