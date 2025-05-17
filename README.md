
#  Jogo da Memória com LEDs — Atmel 8051 (EdSim)

Este projeto implementa um **jogo da memória** com LEDs utilizando Assembly para o microcontrolador **Atmel 8051**, simulado no ambiente **EdSim51**. O jogo utiliza um display LCD para interação com o jogador, LEDs conectados à porta P1 e botões na porta P2. O objetivo é repetir corretamente a sequência de LEDs exibida.

---

## Funcionamento

1. **Tela Inicial (LCD)**  
   O jogo exibe no LCD as mensagens "**APERTE 0**" e "**PARA INICIAR**", aguardando o jogador pressionar qualquer botão em `P2`.

2. **Geração e Exibição da Sequência**  
   - Uma sequência de 5 LEDs é gerada aleatoriamente com base em valores dos temporizadores `TH0`, `TL0` e pinos da `P1`.
   - Os LEDs piscam um por um, com pequenos delays.
   - Os valores são armazenados em RAM para comparação posterior.

3. **Reprodução da Sequência**  
   - O jogador deve pressionar os botões correspondentes à sequência exibida.
   - Cada botão acende o LED correspondente e o valor é comparado.
   - Se errar, a pontuação é zerada. Se acertar, ganha um ponto.

4. **Pontuação e Recorde**  
   - A cada acerto, a pontuação (`PONTOS`) aumenta.
   - Se a nova pontuação for maior que o `RECORDE`, ele é atualizado.
   - Ambas as informações são exibidas no LCD.

5. **Reinício**  
   Após erro ou acerto, o jogo retorna ao menu inicial para uma nova rodada.

---

##  Especificações Técnicas

- **Microcontrolador**: Intel Atmel 8051
- **Portas utilizadas**:
  - `P1`: LEDs e comunicação com LCD (`RS`, `EN`, dados)
  - `P2`: Botões de entrada (jogador)
- **Display LCD**: 4 bits via `P1.4` a `P1.7`
- **Memória RAM**:
  - `20H`: Pontuação atual
  - `21H`: Recorde
  - `30H–34H`: Sequência gerada

---

##  Geração Aleatória

A sequência é definida com:

```asm
MOV A, TH0
XRL A, TL0
XRL A, P1
ANL A, #00000111B
```

Esse valor (0–7) é usado como índice na tabela `SEQUENCIA`, que define os padrões para cada LED.

---

##  Mensagens no LCD

Mensagens utilizadas no jogo:
- Início: "APERTE 0 / PARA INICIAR"
- **Erro**: "ERROU / RECORDE: xxx"
- **Acerto**: "ACERTOU / PONTOS: xxx"

---

##  Delays

Delays são usados para controle visual e debounce:
- `DELAY_100MS`
- `DELAY_200MS`
- `DELAY_500MS`

---

##  Estrutura do Código

- Inicialização do LCD e temporizador
- Geração aleatória da sequência de LEDs
- Armazenamento da sequência em RAM
- Leitura e comparação da entrada do jogador
- Atualização de pontuação e exibição no LCD

---

##  Recursos Adicionais

- Atualização automática do recorde
- Conversão de pontuação para ASCII no display
- Lógica de debounce para botões
- Escrita de strings armazenadas em ROM no LCD

---

## Fluxograma
![FLUXOGRAMA](https://github.com/user-attachments/assets/133426fc-49fa-4893-abc9-9307c8f12fe9)

---

##  Autores
- **Eduardo Gonçalves Moreira** RA:22.124.087-2
- **David Gabriel de Souza Batista** RA:22.123.056-8



