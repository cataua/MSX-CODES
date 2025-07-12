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

void DrawBox(int x1, int y1, int x2, int y2, int color) {
    int i, j;
    // Borda superior (caracteres ASCII: ┌, ─, ┐)
    Locate(x1, y1);
    Print("+"); // ┌ (canto superior esquerdo)
    for (i = x1 + 1; i < x2; i++) Print("="); // ─ (linha horizontal)
    Print("+"); // ┐ (canto superior direito)

    // Bordas laterais (│)
    for (j = y1 + 1; j < y2; j++) {
        Locate(x1, j); Print("|"); // │ (linha vertical esquerda)
        Locate(x2, j); Print("|"); // │ (linha vertical direita)
    }

    // Borda inferior (└, ─, ┘)
    Locate(x1, y2);
    Print("+"); // └ (canto inferior esquerdo)
    for (i = x1 + 1; i < x2; i++) Print("="); // ─ (linha horizontal)
    Print("+"); // ┘ (canto inferior direito)
}

void CenterText(int y, const char* text) {
    int x = (int)(SCREEN_WIDTH - StrLen(text)) / 2;
    Locate(x, y);
    Print(text);
}

void main(void) {
    SetColors(FOREGROUND_COLOR, BG_COLOR, BORDER_COLOR);
    Screen(0);
    Width(SCREEN_WIDTH);
    Cls(); // Limpa a tela
    HideDisplay();
    // 1. Header (linhas 0 a 2)
    DrawBox(0, 0, (SCREEN_WIDTH - 1), 2, 15);
    Locate(2, 1);
    CenterText(1, "=== APLICACAO MSX ===");

    // 2. Área do Menu (linhas 3 a 20)
    DrawBox(0, 3, (SCREEN_WIDTH - 1), 19, 15);
    Locate(3, 5);
    Print("1. Opcao 1");
    Locate(3, 6);
    Print("2. Opcao 2");
    // ... (adicione mais itens do menu)

    // 3. Footer (linhas 21 a 23)
    DrawBox(0, 20, (SCREEN_WIDTH - 1), 22, 15);
    Locate(2, 21);
    CenterText(21,"Pressione ENTER para selecionar");
    ShowDisplay();
    WaitKey(); // Mantém a tela aberta
}

