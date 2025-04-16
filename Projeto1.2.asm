ORG 0000H

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
    MOV R6, #50
DELAY_LOOP1:
    MOV R7, #255
DELAY_LOOP2:
    DJNZ R7, DELAY_LOOP2
    DJNZ R6, DELAY_LOOP1
    RET

END