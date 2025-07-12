#include "fusion-c/header/msx_fusion.h"
#include <stdio.h>

void main(void) {
    int i, x = 0, y = 0;

    Cls(); // Limpa a tela

    for (i = 0; i < 256; i++) { // Itera pelos códigos de 0 a 255
        Locate(x, y);          // Posiciona o cursor na tela
        PrintChar(i);          // Imprime o caractere correspondente
        x++;                   // Move para a próxima coluna

        if (x >= 40) {         // Se atingir o limite de colunas (SCREEN 0: 40 colunas)
            x = 0;             // Reinicia na primeira coluna
            y++;               // Avança para a próxima linha
        }

        if (y >= 24) {         // Se atingir o limite de linhas (SCREEN 0: 24 linhas)
            WaitKey();         // Aguarda uma tecla para continuar
            Cls();             // Limpa a tela
            x = 0;             // Reinicia na primeira coluna
            y = 0;             // Reinicia na primeira linha
        }
    }

    WaitKey(); // Aguarda uma tecla antes de encerrar o programa
}