#include "fusion-c/header/msx_fusion.h"
#include <stdio.h>

// Dimensões da tela (SCREEN 0 padrão: 40x24 colunas/linhas)
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 23

// Cores (dependem do MSX)
#define FOREGROUND_COLOR 2
#define BG_COLOR 1
#define BORDER_COLOR 1
#define HEADER_COLOR TXT_WHITE 15
#define FOOTER_COLOR TXT_CYAN 4
#define MENU_COLOR TXT_YELLOW 8
#define TXT_BLACK 1
#define KEY_UP 30
#define KEY_DOWN 31
#define KEY_ENTER 13

void DrawBox(int x1, int y1, int x2, int y2) {
    int i, j;
    // Borda superior (caracteres ASCII: ┌, ─, ┐)
    Locate(x1, y1);
    PrintChar(0x01);
    PrintChar(0x0158); // ┌ (canto superior esquerdo)
    
    for (i = x1 + 1; i < x2; i++) {
        PrintChar(0x01); PrintChar(0x0157); // ─ (linha horizontal)
    }
    
    PrintChar(0x01);
    PrintChar(0x0159); // ┐ (canto superior direito)

    // Bordas laterais (│)
    for (j = y1 + 1; j < y2; j++) {
        Locate(x1, j); PrintChar(0x01); PrintChar(0x0156); // │ (linha vertical esquerda)
        Locate(x2, j); PrintChar(0x01); PrintChar(0x0156); // │ (linha vertical direita)
    }

    // Borda inferior (└, ─, ┘)
    Locate(x1, y2);
    PrintChar(0x01);
    PrintChar(0x015A); // └ (canto inferior esquerdo)
    for (i = x1 + 1; i < x2; i++) {
        PrintChar(0x01); PrintChar(0x0157); // ─ (linha horizontal)
    }
    PrintChar(0x01); PrintChar(0x015B); // ┘ (canto inferior direito)
}

void CenterText(int y, const char* text) {
    int x = (int)(SCREEN_WIDTH - StrLen(text)) / 2;
    Locate(x, y);
    Print(text);
}

void main(void) {
    int opcao = 0;
    int opcaoY = 5; // Posição Y inicial do menu
    int opcaoYMax = 6; // Posição Y máxima do menu
    int opcaoYAnt = (opcaoY - 1);
    SetColors(FOREGROUND_COLOR, BG_COLOR, BORDER_COLOR);
    Screen(0);
    Width(SCREEN_WIDTH);
    Cls(); // Limpa a tela
    // HideDisplay();
    // 1. Header (linhas 0 a 2)
    DrawBox(0, 0, (SCREEN_WIDTH - 1), 2);
    Locate(2, 1);
    CenterText(1, "=== APLICACAO MSX ===");

    // 2. Área do Menu (linhas 3 a 20)
    DrawBox(0, 3, (SCREEN_WIDTH - 1), 19);
    Locate(3, 5);
    Print("1. Opcao 1");
    Locate(3, 6);
    Print("2. Opcao 2");
    // ... (adicione mais itens do menu)

    // 3. Footer (linhas 21 a 23)
    DrawBox(0, 20, (SCREEN_WIDTH - 1), 22);
    Locate(2, 21);
    CenterText(21,"Pressione ENTER para selecionar");

    // Cursor de escolha opcao
    Locate(2,opcaoY);
    Print(">"); // Cursor de seleção
    
    while(1) { 
        int mov = WaitKey();
        if (mov == KEY_UP) {
            opcaoYAnt = opcaoY; // Armazena a opção anterior
            opcaoY--;
            if (opcaoY < 5) opcaoY = 5; // Limita a opção mínima
            Locate(2, opcaoYAnt);
            Print(" ");
            Locate(2, opcaoY);
            Print(">");
        }
        if (mov == KEY_DOWN) {
            opcaoYAnt = opcaoY; // Armazena a opção anterior    
            
            opcaoY++;
            if (opcaoY > opcaoYMax) opcaoY = 5; // Limita a opção máxima e volta ao inicio
            Locate(2, opcaoYAnt);
            Print(" ");
            Locate(2, opcaoY);
            Print(">");
        }
        if (mov == KEY_ENTER) {
            // Ação para a opção selecionada
            Locate(2, 22);
            Print("Opcao selecionada: ");
            PrintChar(opcaoY - 4 + '0'); // Exibe o número da opção
            WaitKey(); // Mantém a tela aberta
        }
    }    
        // ShowDisplay();
}

