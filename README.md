# Memorização de sequência de LEDS acesos
Este projeto é um jogo da memória de LEDs feito em Assembly em um Intel Atmel 8051 no EdSim . O projeto consiste em acender LEDs em uma sequência aleatória, que é feita baseada no timer do
Atmel 8051, e o usuário deve reproduzir a sequência corretamente, caso contrário ele deve continuar tentando até que finalmente acerte a sequência. Quando a seqûencia estiver correta acende todos os
LEDs para simbolizar sucesso e a sequência se repete a cade vez que o usuário tentar acertar e não conseguir.
---
# Funcionamento
Primeiro, ele mostra uma sequência de LEDs piscando em uma ordem pré-definida, seguindo os valores armazenados na tabela SEQUENCIA. 
A cada etapa, o programa envia o valor para a porta P1, acendendo o LED correspondente, fazendo pausas com uma rotina de delay, e passa para o próximo LED até completar a sequência. Depois dessa exibição, 
o jogador deve replicar o a sequência que foi mostrada, usando os botões conectados à P2. Quando um botão é pressionado, o microcontrolador lê esse sinal e acende o LED correspondente em P1, 
usando também um delay para evitar erros de detecção.
