ORG 0000H

; ----- Fase 1: Mostra a sequência de LEDs -----
START:
    MOV DPTR, #SEQUENCIA  ; Carrega o endereço da sequência
    MOV R0, #0            ; Inicializa o índice da sequência (0)

MOSTRA_SEQUENCIA:
    MOV A, R0             ; Pega o índice da sequência
    MOVC A, @A+DPTR       ; A = valor da sequência no índice
    MOV P1, A             ; Exibe o valor da sequência nos LEDs (P1)
    ACALL DELAY           ; Espera um tempo para mostrar o LED

    INC R0                ; Avança para o próximo índice
    CJNE R0, #5, MOSTRA_SEQUENCIA ; Repete até 5 LEDs

    MOV P1, #0FFh         ; Desliga todos os LEDs após mostrar a sequência

; ----- Fase 2: Modo de controle manual dos LEDs -----
; Configurações iniciais
MOV P1, #0FFh  ; Todos LEDs apagados inicialmente (1 = apagado)
MOV P2, #0FFh  ; Habilita pull-ups para os botões (teclas)

MAIN:
    ACALL LER_TECLA    ; Lê qual tecla foi pressionada
    CJNE A, #0FFh, ACENDE_LED  ; Se alguma tecla foi pressionada
    SJMP MAIN          ; Se não, continua no loop

ACENDE_LED:
    CPL A              ; Corrige a inversão (botão pressionado volta para 0)
    MOV P1, A          ; Acende o LED correspondente (0 = aceso)
    ACALL DELAY        ; Delay para evitar bouncing
    SJMP MAIN          ; Volta para o loop principal

; ---- Sub-rotina de leitura de tecla ----
; Retorna em A o valor da tecla pressionada (com bits invertidos)
; 0FFh = nenhuma tecla pressionada
LER_TECLA:
ESPERA_SOLTAR:
    MOV A, P2          ; Lê o estado atual das teclas
    CJNE A, #0FFh, ESPERA_SOLTAR  ; Espera até todas as teclas serem soltas

ESPERA_PRESSIONAR:
    MOV A, P2          ; Lê o estado das teclas novamente
    CJNE A, #0FFh, TECLA_PRESSIONADA  ; Se alguma tecla foi pressionada
    SJMP ESPERA_PRESSIONAR

TECLA_PRESSIONADA:
    CPL A              ; Inverte os bits (botão ativo em 0 -> 1)
    RET                ; Retorna o valor da tecla

; ---- Sub-rotina de delay ----
DELAY:
    MOV R6, #0FFh
DELAY_LOOP1:
    MOV R7, #0FFh
DELAY_LOOP2:
    DJNZ R7, DELAY_LOOP2
    DJNZ R6, DELAY_LOOP1
    RET

; ---- Dados da sequência de LEDs ----
SEQUENCIA:
    DB 11111110b       ; LED 0 aceso
    DB 10111111b       ; LED 5 aceso
    DB 11111011b       ; LED 2 aceso
    DB 11011111b       ; LED 6 aceso
    DB 11101111b       ; LED 4 aceso

END